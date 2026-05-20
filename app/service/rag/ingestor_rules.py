import sys
from pathlib import Path
from langchain_core.documents import Document
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma

# Thêm path để import được file Config
current_dir = Path(__file__).resolve().parent
if str(current_dir) not in sys.path:
    sys.path.append(str(current_dir))

try:
    from config import Config
except ImportError:
    from app.service.rag.config import Config

def ingest_rules():
    print("🚀 Bắt đầu quá trình Ingest Nội quy thư viện...")

    # 1. Định nghĩa các khối nội dung chất lượng cao
    rules_data = [
        {
            "section": "Thời gian hoạt động tại quầy",
            "content": "Giao dịch trực tiếp tại quầy (Nhận/Trả sách, Hỗ trợ kỹ thuật):\n- Thứ 2 đến Thứ 6: Sáng từ 07:30 – 11:30 | Chiều từ 13:00 – 21:00.\n- Thứ 7: Sáng từ 08:00 – 12:00 | Chiều từ 13:30 – 17:00.\n- Chủ Nhật và Ngày Lễ (Tết, Lễ quốc gia): Nghỉ toàn bộ các dịch vụ trực tiếp. Quầy thủ thư sẽ đóng cửa."
        },
        {
            "section": "Thời gian hoạt động hệ thống số trực tuyến",
            "content": "Hệ thống số và Dịch vụ trực tuyến:\n- Tiếp nhận Đơn mượn sách: Cổng mở từ 06:00 đến 20:00 hàng ngày (bao gồm cả Chủ Nhật/Ngày Lễ). Yêu cầu gửi ngoài khung giờ này hệ thống sẽ tự động từ chối hoặc đẩy sang ngày hôm sau.\n- Tra cứu & Quản lý tài khoản (24/7): Tìm kiếm sách, kiểm tra dư nợ, xem lịch sử mượn trả hoạt động 24/7 không giới hạn thời gian."
        },
        {
            "section": "Định danh QR và tài khoản không thẻ",
            "content": "Chính sách \"Thư viện số không thẻ\":\n- Thư viện không phát hành thẻ vật lý. Người dùng sử dụng mã QR động trên ứng dụng/website.\n- Yêu cầu khi giao dịch: Bắt buộc xuất trình mã QR động trên ứng dụng trực tiếp, không chấp nhận ảnh chụp màn hình.\n- Tính công bằng: Tuyệt đối không có hệ thống hạng thẻ VIP hoặc ưu tiên giữ sách. Phục vụ theo nguyên tắc: Ai đặt trước được phục vụ trước (First come, First served)."
        },
        {
            "section": "Hạn mức mượn và Cơ chế tự chọn thời gian linh hoạt",
            "content": "Khung quy định mượn sách:\n- Tổng số lượng sách đang giữ trên một tài khoản ở cùng một thời điểm tối đa: 05 cuốn.\n- Sách Thường: Không có ký hiệu, hạn mức nằm trong tổng số 5 cuốn, khung thời gian tự chọn từ 01 đến 21 ngày, được phép mang ra khỏi thư viện.\n- Sách Tham Khảo (Ký hiệu: TR): Hạn mức tối đa 01 cuốn, khung thời gian tự chọn từ 01 đến 03 ngày, ưu tiên đọc tại chỗ, hạn chế mang về.\n- Sách Đặc Biệt (Ký hiệu: SP): KHÔNG ĐƯỢC MƯỢN, chỉ đọc tại phòng đọc chỉ định.\n- Quy tắc KHÔNG GIA HẠN: Hệ thống không có nút gia hạn. Người dùng chọn Ngày trả dự kiến ngay từ đầu khi đặt đơn, khi Admin duyệt sẽ không thể thay đổi."
        },
        {
            "section": "Quy trình 5 bước mượn sách trực tuyến",
            "content": "Quy trình mượn sách gồm 5 bước:\n- Bước 1 (Lựa chọn): Đăng nhập hệ thống, tra cứu tài liệu và chọn \"Thêm vào giỏ mượn\".\n- Bước 2 (Thiết lập thời gian): Tại Giỏ mượn, dùng lịch pop-up ấn định \"Ngày trả dự kiến\" cho từng cuốn riêng biệt.\n- Bước 3 (Phê duyệt): Admin kiểm tra tình trạng sách và duyệt trong vòng 02 giờ (trong khung giờ 06:00 - 20:00).\n- Bước 4 (Khung giờ vàng nhận sách): Từ khi đơn \"Đã duyệt\", người dùng có đúng 24 giờ để đến quầy lấy sách. Quá 24 giờ hệ thống tự động hủy đơn và ghi nhận lịch sử.\n- Bước 5 (Định danh & Nhận sách): Tại quầy, xuất trình mã QR để thủ thư quét mã định danh và quét mã vạch sách. Giờ mượn tính từ giây phút này."
        },
        {
            "section": "Phạt vi phạm quá hạn sách thường và sách tham khảo TR",
            "content": "Thời gian quá hạn tính từ 00:00 ngày hôm sau hoặc ngay sau giờ trả của Ngày/Giờ trả dự kiến.\n- Đối với Sách Thường: Mức phạt 5.000đ / cuốn / ngày. (Ví dụ: Quá hạn 2 ngày phạt 2 x 5.000 = 10.000đ).\n- Đối với Sách Tham Khảo (TR): Phạt theo giờ rất nghiêm ngặt. Mức phạt 20.000đ / cuốn / giờ (Làm tròn lên theo từng block 60 phút). (Ví dụ: Quá hạn 1 giờ 15 phút tính thành 2 giờ, phạt 2 x 20.000đ = 40.000đ)."
        },
        {
            "section": "Phạt mất sách, làm hư hỏng sách và lỗi trả sách sai quy định",
            "content": "Chế tài xử lý vi phạm tài sản:\n- Mất sách: Lựa chọn 1 là bồi thường tiền mặt bằng 150% giá trị gốc của sách (giá bìa + chi phí xử lý). Lựa chọn 2 là mua đúng tựa sách đó, cùng phiên bản, cùng nhà xuất bản (mới 100%) đền lại.\n- Hư hỏng tài liệu (rách trang, thấm nước, bôi bẩn, viết vẽ bậy): Phạt tiền từ 20.000đ (lỗi nhỏ như gấp mép, viết chì mờ) lên đến 150% giá trị sách (nếu sách hỏng nặng, mất trang).\n- Trả sách sai quy định (Lén bỏ lại quầy không quét mã xác nhận, tự ý đặt lên giá, nhờ tài khoản khác trả hộ): Phạt trừ thẳng 50.000đ vào tài khoản và Tạm khóa quyền mượn trong 07 ngày."
        },
        {
            "section": "Các cấp độ khóa tài khoản vi phạm hành chính",
            "content": "Hệ thống tự động kích hoạt các chốt chặn khóa tài khoản theo cấp độ:\n- Cấp độ 1 (Khóa chức năng mượn tạm thời): Kích hoạt ngay khi có sách quá hạn 1 phút (với sách TR) hoặc 1 ngày (với sách thường). Bị vô hiệu hóa nút \"Thêm vào giỏ\" cho đến khi trả sách và đóng phạt xong.\n- Cấp độ 2 (Đình chỉ tài khoản 30 ngày): Kích hoạt khi giữ sách quá hạn trên 07 ngày. Sau khi trả sách và nộp phạt xong vẫn bị đình chỉ giao dịch trong 30 ngày tiếp theo.\n- Cấp độ 3 (Trục xuất và Khóa vĩnh viễn): Kích hoạt nếu nợ quá hạn trên 30 ngày HOẶC tích lũy tiền phạt chưa đóng vượt quá 100.000đ. Tài khoản bị xóa vĩnh viễn và đưa vào danh sách đen (Blacklist)."
        },
        {
            "section": "Quy định không gian vật lý và an ninh hệ thống nhắc nhở",
            "content": "Quy tắc ứng xử và an ninh:\n- Không gian đọc: Giữ trật tự tuyệt đối, điện thoại để im lặng. Nghiêm cấm mang thức ăn và đồ uống có mùi (cà phê, trà sữa, nước ngọt) vào kho sách. Chỉ được mang nước lọc đóng chai nắp vặn kín. Mỗi người dùng chỉ rút tối đa 03 cuốn sách đọc tại chỗ cùng lúc, đọc xong phải để vào xe đẩy \"Sách trả lại\".\n- Hệ thống nhắc nhở tự động: Hệ thống gửi thông báo (Push Notification và Email) trước 03 ngày tính đến Ngày trả tự chọn. Việc không nhận được email không được chấp nhận làm lý do miễn phạt.\n- An ninh tài khoản: Nghiêm cấm cho mượn tài khoản/mã QR. Nghiêm cấm dùng tool, bot, script tự động săn sách. Vi phạm lưu lượng bất thường sẽ bị khóa vĩnh viễn không báo trước.\n- Khiếu nại: Chụp màn hình làm bằng chứng, gửi khiếu nại qua biểu mẫu \"Liên hệ\" trên Website. Ban quản trị giải quyết trong 24 giờ làm việc."
        }
    ]

    # 2. Khởi tạo kết nối tới Vector DB hiện tại của project
    embeddings = HuggingFaceEmbeddings(model_name=Config.EMBEDDING_MODEL)
    vector_db = Chroma(persist_directory=Config.VECTOR_DB_PATH, embedding_function=embeddings)

    # 3. Đóng gói thành đối tượng Document của LangChain
    documents = []
    for item in rules_data:
        # Chuẩn hóa văn bản thô đưa vào Vector để khớp cấu trúc hiển thị của chuỗi QA
        formatted_content = f"[Tài liệu: Nội quy thư viện] | [Mục: {item['section']}]\nNội dung: {item['content']}"
        
        doc = Document(
            page_content=formatted_content,
            metadata={
                "source": "so-tay-huong-dan-va-noi-quy-thu-vien",
                "type": "library_rules",
                "title": "Nội quy vận hành thư viện",
                "author": "Ban Quản Lý Thư Viện"
            }
        )
        documents.append(doc)

    # 4. Lưu dữ liệu vào ChromaDB
    vector_db.add_documents(documents)
    print(f"✅ Đã tải thành công {len(documents)} phân đoạn Nội quy vào dữ liệu của hệ thống!")

if __name__ == "__main__":
    ingest_rules()