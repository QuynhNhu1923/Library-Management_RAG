# config/initializers/content_security_policy.rb

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    
    # Fix lỗi Loading the script 'blob:...' (do Importmaps tạo ra)
    policy.script_src  :self, :https, :blob, :unsafe_inline
    
    # Fix lỗi style inline và blob cho CSS
    policy.style_src   :self, :https, :blob, :unsafe_inline
    
    # QUAN TRỌNG: Cho phép hiện PDF báo cáo của Như
    policy.object_src  :self, :blob, :https
    policy.frame_src   :self, :blob, :https
    policy.child_src   :self, :blob, :https
    
    # Cho phép kết nối đến localhost (ActionCable, Hotwire) và Gemini API sau này
    # policy.connect_src :self, :https, "http://localhost:3000", "ws://localhost:3000"
    policy.connect_src :self, :https, "http://localhost:3000", "ws://localhost:3000", "http://127.0.0.1:8000", "http://localhost:8000"
  end

  # Vô hiệu hóa Nonce vì nó sẽ "vô hiệu hóa" unsafe_inline mà Như đang cần
  config.content_security_policy_nonce_generator = nil
  config.content_security_policy_nonce_directives = nil
end
