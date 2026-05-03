class ApiRag::RagDataController < ActionController::API
  def metadata
    # 1. Eager loading để tránh N+1 query (theo đúng cấu trúc Model của Như)
    books = Book.includes(:author, :categories, :publisher, :reviews).all

    # 2. Xử lý dữ liệu
    data = books.map do |book|
      # Gọi hàm to_rag_context đã có trong Model
      context = book.to_rag_context

      # 3. Xác định file_name để Python có thể khớp dữ liệu
      # Nếu đã upload file qua Rails, nó sẽ lấy đúng tên file đó.
      # Nếu chưa upload, ta sẽ lấy tiêu đề sách làm tên file (giả định đuôi .pdf)
      filename = if book.pdf_file.attached?
                   book.pdf_file.filename.to_s
                 else
                   # Chuyển tiêu đề thành dạng không dấu, gạch ngang (ví dụ: "Lão Hạc" -> "lao-hac.pdf")
                   "#{book.title.parameterize}.pdf"
                 end

      context.merge(file_name: filename)
    end

    render json: {
      status: "success",
      count: data.size,
      data:
    }
  rescue StandardError => e
    render json: {status: "error", message: e.message},
           status: :internal_server_error
  end
end
