# bundle exec rake pdf:cut_previews
# bundle exec rake books:sync_pdfs
# bundle exec rake books:sync_covers
require "combine_pdf"

namespace :pdf do
  desc "Cắt 30 trang đầu PDF và lưu vào thư mục import_pdfs_cut"
  task cut_previews: :environment do
    input_dir  = Rails.root.join("lib/assets/import_pdfs")
    output_dir = Rails.root.join("lib/assets/import_pdfs_cut")
    FileUtils.mkdir_p(output_dir)

    files = Dir.glob("#{input_dir}/*.pdf")
    puts "✂️  Bắt đầu cắt #{files.count} file PDF..."

    files.each do |path|
      filename = File.basename(path)
      output_path = output_dir.join(filename)

      next if File.exist?(output_path) # Bỏ qua nếu đã làm rồi

      begin
        pdf = CombinePDF.load(path)
        preview = CombinePDF.new
        # Lấy tối đa 30 trang đầu
        preview << pdf.pages[0..29]
        preview.save(output_path)
        puts "✅ Đã tạo file cut: #{filename}"
      rescue StandardError => e
        puts "❌ Lỗi khi cắt file #{filename}: #{e.message}"
      end
    end
    puts "✨ Hoàn tất chuẩn bị kho file cut!"
  end
end
