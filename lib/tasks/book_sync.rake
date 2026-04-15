require 'combine_pdf'

namespace :books do
  # Hàm dùng chung cho cả namespace
  def self.smart_normalize(text)
    return "" if text.blank?
    text = text.to_s.downcase
    map = {
      /[àáạảãâầấậẩẫăằắặẳẵ]/ => 'a', /[èéẹẻẽêềếệểễ]/ => 'e',
      /[ìíịỉĩ]/ => 'i', /[òóọỏõôồốộổỗơờớợởỡ]/ => 'o',
      /[ùúụủũưừứựửữ]/ => 'u', /[ỳýỵỷỹ]/ => 'y', /[đ]/ => 'd'
    }
    map.each { |regex, replacement| text.gsub!(regex, replacement) }
    text.gsub(/[^a-z0-9\s]/, '').squish.gsub(' ', '-')
  end

  desc "Gán PDF thông minh, sửa lỗi 404 vật lý và tạo preview"
  task sync_pdfs: :environment do
    import_path = Rails.root.join("lib/assets/import_pdfs/*.pdf")
    files = Dir.glob(import_path)
    
    # Tạo Hash để tra cứu nhanh
    norm_map = Book.pluck(:id, :title).each_with_object({}) do |(id, title), hash|
      hash[smart_normalize(title)] = id
    end

    puts "🚀 Đang quét #{files.count} file PDF..."

    files.each do |path|
      filename_raw = File.basename(path, '.pdf')
      # Tìm ID sách dựa trên tên file
      book_id = norm_map[filename_raw] || norm_map.find { |k, v| filename_raw.include?(k) || k.include?(filename_raw) }&.last

      if book_id
        book = Book.find(book_id)
        
        # KIỂM TRA LOGIC MỚI: 
        # Nếu đã đính kèm, phải kiểm tra xem file vật lý CÓ THỰC SỰ tồn tại không
        file_physically_exists = false
        if book.pdf_file.attached?
          begin
            file_physically_exists = File.exist?(book.pdf_file.blob.service.path_for(book.pdf_file.key))
          rescue
            file_physically_exists = false
          end
        end

        # Nếu chưa có file HOẶC có liên kết nhưng file vật lý bị mất (Lỗi 404)
        if !book.pdf_file.attached? || !file_physically_exists
          puts "🛠️  Đang đồng bộ file vật lý cho: #{book.title}..."
          
          File.open(path, 'rb') do |file|
            # Gán lại file (Nếu đã có liên kết lỗi, .attach sẽ ghi đè và tạo file mới chuẩn)
            book.pdf_file.attach(io: file, filename: File.basename(path))
            
            # Xử lý Preview 30 trang
            begin
              pdf = CombinePDF.load(path)
              preview = CombinePDF.new
              preview << pdf.pages[0..[pdf.pages.length, 29].min]
              
              preview_path = Rails.root.join("tmp", "preview_#{book.id}.pdf")
              preview.save(preview_path)
              
              File.open(preview_path, 'rb') do |p_file|
                book.preview_pdf.attach(io: p_file, filename: "preview_#{File.basename(path)}")
              end
              File.delete(preview_path) if File.exist?(preview_path)
            rescue => e
              puts "⚠️  Lỗi tạo preview cho #{book.title}: #{e.message}"
            end
          end
          puts "✅ Đã xử lý xong: #{book.title}"
        else
          puts "ℹ️  Bỏ qua: #{book.title} (File đã tồn tại và hợp lệ)"
        end
      else
        puts "❌ Không tìm thấy sách khớp với file: #{filename_raw}"
      end
    end
    puts "✨ Hoàn tất đồng bộ PDF!"
  end

  desc "Đồng bộ ảnh bìa và sửa lỗi ảnh mất file vật lý"
  task sync_covers: :environment do
    cover_dir = Rails.root.join("lib", "assets", "book_covers")
    all_files = Dir.glob("#{cover_dir}/*.{jpg,jpeg,png,webp}")
    default_cover = all_files.find { |f| f.include?("book_cover_default") }

    Book.find_each do |book|
      # Kiểm tra file vật lý của ảnh
      image_exists = false
      if book.image.attached?
        begin
          image_exists = File.exist?(book.image.blob.service.path_for(book.image.key))
        rescue
          image_exists = false
        end
      end

      # Chỉ xử lý nếu chưa có ảnh hoặc file vật lý bị mất
      next if book.image.attached? && image_exists

      path_by_id = all_files.find { |f| File.basename(f).start_with?("book_#{book.id}.") }
      
      norm_title = smart_normalize(book.title).gsub('-', '')
      path_by_name = all_files.find do |f|
        fname = smart_normalize(File.basename(f, '.*')).gsub('-', '')
        !fname.include?("default") && (fname.include?(norm_title) || norm_title.include?(fname))
      end

      target = path_by_id || path_by_name || default_cover
      if target
        File.open(target, 'rb') do |file|
          book.image.attach(io: file, filename: File.basename(target))
        end
        puts "🖼️  Đã khôi phục/Gán ảnh cho: #{book.title}"
      end
    end
    puts "✨ Hoàn tất đồng bộ ảnh bìa!"
  end
end
