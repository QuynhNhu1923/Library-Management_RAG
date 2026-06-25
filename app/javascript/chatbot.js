// Khởi tạo bộ nhớ hội thoại ngay khi load trang
window.chatHistory = [];

function toggleChat() {
  const chatBox = document.getElementById('chat-box');
  if (chatBox) chatBox.classList.toggle('d-none');
}

function handleKeyPress(e) {
  if (e.key === 'Enter') processChat();
}

function scrollToBottom() {
  const content = document.getElementById('chat-content');
  if (content) content.scrollTop = content.scrollHeight;
}

async function processChat() {
  const input = document.getElementById('chat-input');
  const content = document.getElementById('chat-content');
  const query = input.value.trim();

  if (!query) return;

  // 1. Lưu câu hỏi vào Trí nhớ
  window.chatHistory.push({ role: 'user', content: query });

  // Giữ tối đa 6 lượt hội thoại gần nhất để tránh quá tải API
  if (window.chatHistory.length > 6) {
    window.chatHistory = window.chatHistory.slice(-6);
  }

  // 2. Hiển thị tin nhắn người dùng
  content.innerHTML += `
    <div class="user-msg mb-3 text-end">
      <div class="d-inline-block p-2 px-3 rounded-3 bg-primary text-white shadow-sm" style="max-width: 85%; font-size: 0.9rem; text-align: left;">
        ${query}
      </div>
    </div>`;

  input.value = '';
  scrollToBottom();

  // 3. Khởi tạo Box trống cho Bot và hiệu ứng Loading
  const msgId = "msg-" + Date.now();
  content.innerHTML += `
    <div class="bot-msg mb-3">
      <div id="${msgId}" class="d-inline-block p-3 rounded-3 bg-white text-dark shadow-sm border markdown-body" style="max-width: 95%; font-size: 0.9rem;">
        <span class="spinner-grow spinner-grow-sm text-primary"></span> <small class="text-muted">Đang lục tìm tài liệu...</small>
      </div>
    </div>`;
  scrollToBottom();

  const msgBox = document.getElementById(msgId);
  let fullBotResponse = "";
  let sourcesHtml = "";

  try {
    // 4. Gọi API trực tiếp tới FastAPI với chuẩn JSON và truyền Lịch sử hội thoại
    const response = await fetch('http://127.0.0.1:8000/ask_stream', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        question: query,
        chat_history: window.chatHistory
      })
    });

    if (!response.ok) throw new Error("Network response was not ok");

    // 5. Giải mã luồng Streaming
    const reader = response.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let buffer = "";
    msgBox.innerHTML = ""; // Xóa hiệu ứng loading

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n\n');
      buffer = lines.pop(); // Giữ lại phần data chưa hoàn chỉnh cho vòng lặp sau

      for (const line of lines) {
        if (line.startsWith('data: ')) {
          try {
            const parsedData = JSON.parse(line.replace('data: ', ''));

            if (parsedData.type === 'sources') {
              if (parsedData.data.length > 0) {
                sourcesHtml = '<hr class="my-2 text-muted"><div class="sources-container d-flex flex-wrap gap-1">';
                parsedData.data.forEach(src => {
                  sourcesHtml += `
                    <span class="badge rounded-pill border text-dark bg-light p-2" 
                          style="font-size: 0.65rem; cursor: help;" 
                          title="Trang ${src.page}">
                      <i class="fas fa-book me-1 text-primary"></i>${src.book_title}
                    </span>`;
                });
                sourcesHtml += '</div>';
              }
            } else if (parsedData.type === 'text') {
              fullBotResponse += parsedData.text;
              // Render Markdown mượt mà cùng thẻ sources
              msgBox.innerHTML = marked.parse(fullBotResponse) + sourcesHtml;
              scrollToBottom();
            }
          } catch (e) {
            console.error("Lỗi parse chunk JSON:", e);
          }
        }
      }
    }

    // 6. Lưu câu trả lời hoàn chỉnh của Bot vào Trí nhớ sau khi kết thúc stream
    window.chatHistory.push({ role: 'assistant', content: fullBotResponse });

  } catch (error) {
    msgBox.innerHTML = `<span class="text-danger"><i class="fas fa-wifi me-1"></i> Không thể kết nối với Thư viện AI.</span>`;
    console.error("Lỗi chatbot streaming:", error);
  }
  scrollToBottom();
}

// Cập nhật ngày giờ (Dành cho hiển thị header)
function updateClock() {
  const now = new Date();
  const dateStr = now.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' });
  const timeStr = now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
  const element = document.getElementById('current-date-display');
  if (element) element.textContent = `${timeStr} - ${dateStr}`;
}

document.addEventListener('turbo:load', () => {
  updateClock();
  setInterval(updateClock, 60000);
});

// Gắn hàm vào Window để HTML gọi được
window.toggleChat = toggleChat;
window.handleKeyPress = handleKeyPress;
window.processChat = processChat;
