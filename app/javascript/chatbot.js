function toggleChat() {
  const chatBox = document.getElementById('chat-box');
  chatBox.classList.toggle('d-none');
}

function handleKeyPress(e) {
  if (e.key === 'Enter') processChat();
}

async function processChat() {
  const input = document.getElementById('chat-input');
  const content = document.getElementById('chat-content');
  const query = input.value.trim();

  if (!query) return;

  // 1. Hiển thị tin nhắn User (Sử dụng div thay vì badge để hiển thị tốt hơn)
  content.innerHTML += `
    <div class="user-msg mb-3 text-end">
      <div class="d-inline-block p-2 px-3 rounded-3 bg-primary text-white shadow-sm" style="max-width: 85%; font-size: 0.9rem;">
        ${query}
      </div>
    </div>`;

  input.value = '';
  content.scrollTop = content.scrollHeight;

  // Hiệu ứng loading
  const loadingId = "loading-" + Date.now();
  content.innerHTML += `
    <div id="${loadingId}" class="bot-msg mb-3">
      <div class="d-inline-block p-2 px-3 rounded-3 bg-white text-muted shadow-sm border">
        <small><i class="fas fa-spinner fa-spin me-2"></i>Thủ thư đang tra cứu...</small>
      </div>
    </div>`;
  content.scrollTop = content.scrollHeight;

  try {
    const response = await fetch('/chatbot/query', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ query: query })
    });

    const data = await response.json();
    document.getElementById(loadingId).remove();

    // 2. Render Markdown cho câu trả lời
    // marked.parse giúp chuyển các ký tự ** hoặc list 1. 2. thành HTML chuẩn
    const formattedAnswer = marked.parse(data.answer);

    // 3. Xử lý phần nguồn trích dẫn (Sources)
    let sourcesHtml = '';
    if (data.sources && data.sources.length > 0) {
      sourcesHtml = '<hr class="my-2 text-muted"><div class="sources-container d-flex flex-wrap gap-1">';
      data.sources.forEach(src => {
        sourcesHtml += `
          <span class="badge rounded-pill border text-dark bg-light p-2" 
                style="font-size: 0.65rem; cursor: help;" 
                title="${src.full_info}">
            <i class="fas fa-book me-1 text-primary"></i>${src.book_title} (Tr. ${src.page})
          </span>`;
      });
      sourcesHtml += '</div>';
    }

    // 4. Hiển thị tin nhắn của Bot
    content.innerHTML += `
      <div class="bot-msg mb-3">
        <div class="d-inline-block p-3 rounded-3 bg-white text-dark shadow-sm border" style="max-width: 95%; font-size: 0.9rem;">
          <div class="markdown-body">
            ${formattedAnswer}
          </div>
          ${sourcesHtml}
        </div>
      </div>`;

    content.scrollTop = content.scrollHeight;
  } catch (error) {
    if (document.getElementById(loadingId)) document.getElementById(loadingId).remove();
    content.innerHTML += `<div class="text-center my-2"><small class="text-danger">Lỗi kết nối server AI</small></div>`;
    console.error("Lỗi chatbot:", error);
  }
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
window.toggleChat = toggleChat;
window.handleKeyPress = handleKeyPress;
window.processChat = processChat;