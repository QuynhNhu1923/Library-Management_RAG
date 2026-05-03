namespace :books do
  # Hàm chuẩn hóa dùng chung
  def self.smart_normalize text
    return "" if text.blank?

    text = text.to_s.downcase
    # Bảng thay thế đầy đủ để tránh lỗi mất ký tự như "ạ" -> "-"
    map = {
      /[àáạảãâầấậẩẫăằắặẳẵ]/ => "a", /[èéẹẻẽêềếệểễ]/ => "e",
      /[ìíịỉĩ]/ => "i", /[òóọỏõôồốộổỗơờớợởỡ]/ => "o",
      /[ùúụủũưừứựửữ]/ => "u", /[ỳýỵỷỹ]/ => "y", /đ/ => "d"
    }
    map.each {|regex, replacement| text = text.gsub(regex, replacement)}

    # Giữ lại chữ và số, thay tất cả ký tự đặc biệt/khoảng trắng bằng 1 dấu gạch ngang duy nhất
    text.gsub(/[^a-z0-9]/, "-").gsub(/-+/,
                                     "-").delete_prefix("-").delete_suffix("-")
  end

  desc "Đồng bộ file PDF đã cắt và lưu danh sách đã xử lý"
  task sync_pdfs: :environment do
    cut_path = Rails.root.join("lib/assets/import_pdfs_cut")
    list_path = Rails.root.join("lib/assets/processed_list.txt")
    files = Dir.glob("#{cut_path}/*.pdf")

    # Đọc danh sách đã xử lý
    processed_files = File.exist?(list_path) ? File.readlines(list_path).map(&:strip) : []
    norm_map = Book.pluck(:id, :title).each_with_object({}) do |(id, title), h|
      h[smart_normalize(title)] = id
    end

    puts "🚀 Đang kiểm tra #{files.count} file PDF trong thư mục cut..."

    files.each do |path|
      filename = File.basename(path)
      next if processed_files.include?(filename)

      filename_no_ext = File.basename(path, ".pdf")
      book_id = norm_map[filename_no_ext] || norm_map.find do |k, _|
                                               filename_no_ext.include?(k) || k.include?(filename_no_ext)
                                             end&.last

      next unless book_id

      book = Book.find(book_id)
      begin
        File.open(path, "rb") do |f|
          book.pdf_file.attach(io: f, filename:)
          f.rewind
          book.preview_pdf.attach(io: f, filename: "preview_#{filename}")
        end
        File.open(list_path, "a") {|f| f.puts(filename)}
        puts "✅ Đã gán PDF: #{book.title}"
      rescue StandardError => e
        puts "❌ Lỗi PDF #{filename}: #{e.message}"
      end
    end
    puts "✨ Hoàn tất đồng bộ PDF!"
  end

  desc "Đồng bộ ảnh bìa (Chỉ xử lý sách chưa có ảnh hoặc lỗi 404)"
  task sync_covers: :environment do
    cover_dir = Rails.root.join("lib/assets/book_covers")
    all_files = Dir.glob("#{cover_dir}/*.{jpg,jpeg,png,webp}")
    default_cover = all_files.find {|f| f.include?("book_cover_default")}

    puts "🖼️  Đang quét ảnh bìa cho các đầu sách..."

    Book.find_each do |book|
      # Kiểm tra xem đã có ảnh vật lý chưa
      image_physically_exists = false
      if book.image.attached?
        begin
          image_physically_exists = File.exist?(book.image.blob.service.path_for(book.image.key))
        rescue StandardError
          image_physically_exists = false
        end
      end

      # Nếu đã có ảnh và không lỗi 404 thì bỏ qua
      next if book.image.attached? && image_physically_exists

      # Tìm ảnh phù hợp: Ưu tiên theo ID -> sau đó đến Tên sách
      path_by_id = all_files.find do |f|
        File.basename(f).start_with?("book_#{book.id}.")
      end

      norm_title = smart_normalize(book.title).gsub("-", "")
      path_by_name = all_files.find do |f|
        fname = smart_normalize(File.basename(f, ".*")).gsub("-", "")
        !fname.include?("default") && (fname.include?(norm_title) || norm_title.include?(fname))
      end

      target = path_by_id || path_by_name || default_cover

      if target
        begin
          File.open(target, "rb") do |file|
            book.image.attach(io: file, filename: File.basename(target))
          end
          puts "🖼️  Gán ảnh thành công: #{book.title}"
        rescue StandardError => e
          puts "❌ Lỗi gán ảnh #{book.title}: #{e.message}"
        end
      end
    end
    puts "✨ Hoàn tất đồng bộ ảnh bìa!"
  end
end
