class PagesController < ApplicationController
  def view_rules_pdf
    pdf_path = "/home/quynhnhu/Projects/Library-Management_RAG/lib/assets/import_pdfs_cut/so-tay-huong-dan-va-noi-quy-thu-vien.pdf"

    if File.exist?(pdf_path)
      send_file pdf_path, type: "application/pdf", disposition: "inline"
    else
      render plain: "Không tìm thấy file nội quy thư viện", status: :not_found
    end
  end
end
