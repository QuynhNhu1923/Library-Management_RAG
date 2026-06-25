require "net/http"
require "uri"
require "json"

class ChatbotController < ApplicationController
  # Endpoint dự phòng không Streaming (nếu bạn vẫn cần dùng qua Rails)
  def query
    user_query = params[:query]
    chat_history = params[:chat_history] || []

    if user_query.blank?
      return render json: { answer: "Câu hỏi đang trống!" }, status: :bad_request
    end

    begin
      uri = URI.parse("http://127.0.0.1:8000/ask")

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 30 
      http.open_timeout = 5  

      # Thay đổi từ Form_Data sang JSON
      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request.body = {
        question: user_query,
        chat_history: chat_history
      }.to_json

      response = http.request(request)

      if response.code == "200"
        result = JSON.parse(response.body)
        render json: {
          answer: result.fetch("answer", "Không nhận được phản hồi từ AI."),
          sources: result.fetch("sources", [])
        }
      else
        render json: { answer: "Hệ thống AI đang bận (Lỗi #{response.code}), Bạn đợi chút nhé!" }, status: :service_unavailable
      end
    rescue Net::ReadTimeout
      render json: { answer: "AI xử lý hơi lâu, Bạn thử lại câu hỏi ngắn hơn nhé!" }, status: :request_timeout
    rescue StandardError => e
      logger.error "Chatbot Error: #{e.message}"
      render json: { answer: "Lỗi kết nối tới AI: #{e.message}" }, status: :internal_server_error
    end
  end
end
