require "net/http"
require "uri"

class ChatbotController < ApplicationController
  def query
    user_query = params[:query]

    # Kiểm tra query trống ngay từ đầu để đỡ tốn tài nguyên gọi AI
    if user_query.blank?
      return render json: {answer: "Như ơi, câu hỏi đang trống nè!"},
                    status: :bad_request
    end

    begin
      uri = URI.parse("http://127.0.0.1:8000/ask")

      # Thiết lập HTTP với Timeout
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 30 # Chờ tối đa 30s để AI trả lời
      http.open_timeout = 5  # Chờ tối đa 5s để kết nối tới FastAPI

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data("question" => user_query)

      response = http.request(request)

      if response.code == "200"
        result = JSON.parse(response.body)
        render json: {
          # Trả về dữ liệu an toàn, nếu không có sources thì trả về mảng rỗng []
          answer: result.fetch("answer", "Không nhận được phản hồi từ AI."),
          sources: result.fetch("sources", [])
        }
      else
        render json: {answer: "Hệ thống AI đang bận (Lỗi #{response.code}), Như đợi chút nhé!"},
               status: :service_unavailable
      end
    rescue Net::ReadTimeout
      render json: {answer: "AI xử lý hơi lâu, Như thử lại câu hỏi ngắn hơn nhé!"},
             status: :request_timeout
    rescue StandardError => e
      # Log lỗi ra terminal để dễ debug khi làm đồ án
      logger.error "Chatbot Error: #{e.message}"
      render json: {answer: "Lỗi kết nối tới AI: #{e.message}"},
             status: :internal_server_error
    end
  end
end
