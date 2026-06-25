# encoding: utf-8

puts "🌱 Đang tạo dữ liệu mẫu cho hệ thống thư viện..."

puts "🧹 Đang xóa dữ liệu cũ..."
[Review, Favorite, BorrowRequestItem, BorrowRequest, BookCategory, Book, Category, Author, Publisher, User].each(&:destroy_all)

puts "📚 Đang tạo thể loại sách..."
categories = [
  { name: "Tiểu thuyết", description: "Tác phẩm văn học dài" },
  { name: "Khoa học", description: "Sách về các chủ đề khoa học" },
  { name: "Lập trình", description: "Sách dạy lập trình" },
  { name: "Kinh tế", description: "Sách về kinh tế, tài chính" },
  { name: "Lịch sử - Chính trị", description: "Sách về lịch sử" },
  { name: "Tâm lý học", description: "Sách về tâm lý con người" },
  { name: "Truyện ngắn", description: "Tập hợp các truyện ngắn" },
  { name: "Trinh thám", description: "Truyện trinh thám, hình sự" },
  { name: "Tiên hiệp - Kiếm hiệp", description: "Thể loại giả tưởng" },
  { name: "Thiếu nhi", description: "Sách dành cho trẻ em" },
  { name: "Kỹ năng", description: "Sách phát triển bản thân" },
  { name: "Văn hóa", description: "Sách về văn hóa các nước" },
  { name: "Lãng mạn", description: "Sách về tình yêu" },
  { name: "Kinh tế - Quản lý", description: "Sách về kinh tế và quản lý"  },
  { name: "Truyện cười", description: "Sách về truyện cười  "},
  { name: "Chiến tranh", description: "Sách về chiến tranh"},
  { name: "Y học - Sức khỏe", description: "Sách về y học và sức khỏe"},
  { name: "Ngoại ngữ", description: "Sách về ngoại ngữ"},
].map { |cat| Category.create!(cat) }

puts "👨‍💼 Đang tạo tài khoản admin..."
admin = User.create!(
  name: "Quản trị viên",
  email: "admin@thuvien.com",
  password: "123456",
  password_confirmation: "123456",
  date_of_birth: Date.new(1990, 1, 1),
  gender: "male",
  role: "admin",
  confirmed_at: Time.zone.now,
  status: 1
)

puts "👥 Đang tạo người dùng thường..."
users = [
  { name: "Nguyễn Văn An", email: "nguyenvanan@example.com", gender: "male", dob: "1990-01-12" },
  { name: "Trần Thị Hoa", email: "tranthihoa@example.com", gender: "female", dob: "1992-03-25" },
  { name: "Lê Văn Minh", email: "levanminh@example.com", gender: "male", dob: "1988-07-09" },
  { name: "Phạm Thị Hồng", email: "phamthihong@example.com", gender: "female", dob: "1995-10-14" },
  { name: "Hoàng Văn Quang", email: "hoangvanquang@example.com", gender: "male", dob: "1991-06-18" },
  { name: "Đỗ Thị Lan", email: "dothilan@example.com", gender: "female", dob: "1993-04-02" },
  { name: "Bùi Văn Nam", email: "buivannam@example.com", gender: "male", dob: "1989-08-30" },
  { name: "Vũ Thị Mai", email: "vuthimai@example.com", gender: "female", dob: "1996-12-21" },
  { name: "Ngô Văn Khánh", email: "ngovankhanh@example.com", gender: "male", dob: "1994-05-11" },
  { name: "Đặng Thị Yến", email: "dangthiyen@example.com", gender: "female", dob: "1990-09-27" },
  { name: "Trịnh Văn Hùng", email: "trinhvanhung@example.com", gender: "male", dob: "1992-02-14" },
  { name: "Lương Thị Hạnh", email: "luongthihanh@example.com", gender: "female", dob: "1997-11-08" },
  { name: "Phan Văn Tuấn", email: "phanvantuan@example.com", gender: "male", dob: "1987-03-19" },
  { name: "Tạ Thị Thu", email: "tathithu@example.com", gender: "female", dob: "1995-07-23" },
  { name: "Nguyễn Văn Lâm", email: "nguyenvanlam@example.com", gender: "male", dob: "1991-10-05" },
  { name: "Trần Thị Vân", email: "tranthivan@example.com", gender: "female", dob: "1989-01-28" },
  { name: "Lê Văn Hoàng", email: "levanhoang@example.com", gender: "male", dob: "1993-06-17" },
  { name: "Phạm Thị Thảo", email: "phamthithao@example.com", gender: "female", dob: "1994-08-12" },
  { name: "Hoàng Văn Dũng", email: "hoangvandung@example.com", gender: "male", dob: "1988-05-03" },
  { name: "Đỗ Thị Ngọc", email: "dothingoc@example.com", gender: "female", dob: "1992-12-15" },
  { name: "Bùi Văn Toàn", email: "buivantoan@example.com", gender: "male", dob: "1990-07-19" },
  { name: "Vũ Thị Kim", email: "vuthikim@example.com", gender: "female", dob: "1996-03-07" },
  { name: "Ngô Văn Huy", email: "ngovanhuy@example.com", gender: "male", dob: "1991-09-14" },
  { name: "Đặng Thị Nhung", email: "dangthinhung@example.com", gender: "female", dob: "1987-11-30" },
  { name: "Trịnh Văn Phúc", email: "trinhvanphuc@example.com", gender: "male", dob: "1994-04-28" },
  { name: "Lương Thị Thanh", email: "luongthithanh@example.com", gender: "female", dob: "1993-08-16" },
  { name: "Phan Văn Hòa", email: "phanvanhoa@example.com", gender: "male", dob: "1989-02-09" },
  { name: "Tạ Thị Hương", email: "tatihuong@example.com", gender: "female", dob: "1995-06-22" },
  { name: "Nguyễn Văn Phong", email: "nguyenvanphong@example.com", gender: "male", dob: "1990-10-18" },
  { name: "Trần Thị Tâm", email: "tranthitam@example.com", gender: "female", dob: "1992-01-26" }
].map do |u|
  User.create!(
    name: u[:name],
    email: u[:email],
    password: "123456",
    password_confirmation: "123456",
    gender: u[:gender],
    date_of_birth: Date.parse(u[:dob]),
    confirmed_at: Time.zone.now,
    status: 1
  )
end

puts "✍️ Đang tạo tác giả..."
authors = [
  { name: "Nguyễn Nhật Ánh", nationality: "Việt Nam", birth_date: "1955-05-07" },
  { name: "J.K. Rowling", nationality: "Anh", birth_date: "1965-07-31" },
  { name: "Stephen King", nationality: "Mỹ", birth_date: "1947-09-21" },
  { name: "Haruki Murakami", nationality: "Nhật Bản", birth_date: "1949-01-12" },
  { name: "Paulo Coelho", nationality: "Brazil", birth_date: "1947-08-24" },
  { name: "Nguyễn Ngọc Tư", nationality: "Việt Nam", birth_date: "1976-03-06" },
  { name: "Tô Hoài", nationality: "Việt Nam", birth_date: "1920-09-27", death_date: "2014-07-06" },
  { name: "Nam Cao", nationality: "Việt Nam", birth_date: "1917-10-29", death_date: "1951-11-30" },
  { name: "George Orwell", nationality: "Anh", birth_date: "1903-06-25", death_date: "1950-01-21" },
  { name: "Ernest Hemingway", nationality: "Mỹ", birth_date: "1899-07-21", death_date: "1961-07-02" },
  { name: "Vũ Trọng Phụng", nationality: "Việt Nam", birth_date: "1912-10-29", death_date: "1939-12-13" },
  { name: "Milan Kundera", nationality: "Séc", birth_date: "1929-04-01", death_date: "2023-07-11" },
  { name: "Nguyễn Du", nationality: "Việt Nam", birth_date: "1765-01-03", death_date: "1820-08-16" },
  { name: "Nguyễn Văn Huyên", nationality: "Việt Nam", birth_date: "1905-06-06", death_date: "1975-02-17" },
  { name: "Thái Văn Kiểm", nationality: "Việt Nam", birth_date: "1920-01-01" },
  { name: "Nguyên Hồng", nationality: "Việt Nam", birth_date: "1918-10-05", death_date: "1982-05-31" },
  { name: "Thích Nhất Hạnh", nationality: "Việt Nam", birth_date: "1926-10-11", death_date: "2022-01-22" },
  { name: "Fukuzawa Yukichi", nationality: "Nhật Bản", birth_date: "1835-01-10", death_date: "1901-02-03" },
  { name: "Gustave Dumoutie", nationality: "Pháp", birth_date: "1850-01-01" },
  { name: "Đào Duy Anh", nationality: "Việt Nam", birth_date: "1904-09-05", death_date: "1988-05-24" },
  { name: "Minh Niệm", nationality: "Việt Nam", birth_date: "1970-01-01" },
  { name: "An Chi", nationality: "Việt Nam", birth_date: "1935-01-01" },
  { name: "Đại Sư Trí Hải", nationality: "Việt Nam", birth_date: "1937-01-01" },
  { name: "Nguyễn Mạnh Tuấn", nationality: "Việt Nam", birth_date: "1945-01-01" },
  { name: "Đoàn Văn Thông", nationality: "Việt Nam", birth_date: "1940-01-01" },
  { name: "Lê Mai Dung", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Mika Waltari", nationality: "Phần Lan", birth_date: "1908-09-19", death_date: "1979-08-26" },
  { name: "Rodney Smith", nationality: "Mỹ", birth_date: "1947-01-01" },
  { name: "Joe Vitale", nationality: "Mỹ", birth_date: "1953-12-29" },
  { name: "Tế Xuyên", nationality: "Việt Nam", birth_date: "1920-01-01" },
  { name: "Ajahn Chah", nationality: "Thái Lan", birth_date: "1918-06-17", death_date: "1992-01-16" },
  { name: "Trần Quang Đức", nationality: "Việt Nam", birth_date: "1945-01-01" },
  { name: "Phan Kế Bính", nationality: "Việt Nam", birth_date: "1872-04-26", death_date: "1921-09-21" },
  { name: "Nguyễn Văn", nationality: "Việt Nam", birth_date: "1910-01-01" },
  { name: "Xuân Sách", nationality: "Việt Nam", birth_date: "1916-01-01" },
  { name: "Gaston Leroux", nationality: "Pháp", birth_date: "1868-05-06", death_date: "1927-04-15" },
  { name: "Đào Hiếu", nationality: "Việt Nam", birth_date: "1945-01-01" },
  { name: "Nguyễn Tuân", nationality: "Việt Nam", birth_date: "1910-07-20", death_date: "1987-07-28" },
  { name: "Hoàng Hải Lâm", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Nguyễn Thị Thu Huệ", nationality: "Việt Nam", birth_date: "1968-01-01" },
  { name: "Phạm Thị Thanh Hoa", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Rita Nguyễn", nationality: "Việt Nam", birth_date: "1980-01-01" },
  { name: "Matayoshi Naoki", nationality: "Nhật Bản", birth_date: "1957-01-01" },
  { name: "Linda Lê", nationality: "Pháp", birth_date: "1963-08-11" },
  { name: "Mạc Ngôn", nationality: "Trung Quốc", birth_date: "1955-02-17" },
  { name: "Nguyễn Minh Châu", nationality: "Việt Nam", birth_date: "1930-10-17", death_date: "1989-01-25" },
  { name: "Nguyễn Quang Lập", nationality: "Việt Nam", birth_date: "1959-01-01", death_date: "2022-12-31" },
  { name: "Hải Hồ", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Yukio Mishima", nationality: "Nhật Bản", birth_date: "1925-01-14", death_date: "1970-11-25" },
  { name: "Chu Lai", nationality: "Việt Nam", birth_date: "1946-01-01" },
  { name: "Ngọc Giao", nationality: "Việt Nam", birth_date: "1930-01-01" },
  { name: "Lê Minh Khuê", nationality: "Việt Nam", birth_date: "1949-01-01" },
  { name: "Hoàng Công Danh", nationality: "Việt Nam", birth_date: "1945-01-01" },
  { name: "Sơn Nam", nationality: "Việt Nam", birth_date: "1926-08-24", death_date: "2008-10-16" },
  { name: "Vũ Hạnh", nationality: "Việt Nam", birth_date: "1931-01-01" },
  { name: "Hoàng Nhật Tuyên", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Diệp Thạch Đào", nationality: "Việt Nam", birth_date: "1927-01-01" },
  { name: "Mị Ngữ Giả", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Ánh Tuyết Triều Dương", nationality: "Việt Nam", birth_date: "1980-01-01" },
  { name: "Nguyễn Một", nationality: "Việt Nam", birth_date: "1930-01-01" },
  { name: "Erich Maria Remarque", nationality: "Đức", birth_date: "1898-06-22", death_date: "1970-09-25" },
  { name: "Rafael Sabatini", nationality: "Ý", birth_date: "1875-06-10", death_date: "1950-02-13" },
  { name: "Jean-Paul Dubois", nationality: "Pháp", birth_date: "1950-01-01" },
  { name: "Hồ Biểu Chánh", nationality: "Việt Nam", birth_date: "1885-10-15", death_date: "1958-11-22" },
  { name: "Hồ Anh Thái", nationality: "Việt Nam", birth_date: "1954-01-01" },
  { name: "Nguyễn Thu Hoài", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Jules Verne", nationality: "Pháp", birth_date: "1828-02-08", death_date: "1905-03-24" },
  { name: "Nathaniel Hawthorne", nationality: "Mỹ", birth_date: "1804-07-04", death_date: "1864-05-19" },
  { name: "Yasushi Kitagawa", nationality: "Nhật Bản", birth_date: "1900-01-01" },
  { name: "Vĩ Ngư", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Tạ Duy Anh", nationality: "Việt Nam", birth_date: "1959-01-01" },
  { name: "Hà Ân", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Chung Serang", nationality: "Hàn Quốc", birth_date: "1980-01-01" },
  { name: "Gary Shteyngart", nationality: "Mỹ", birth_date: "1972-07-05" },
  { name: "Bùi Bình Thi", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Tú Cẩm", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Christopher Isherwood", nationality: "Anh", birth_date: "1904-08-26", death_date: "1986-01-04" },
  { name: "Hosoda Mamoru", nationality: "Nhật Bản", birth_date: "1967-09-19" },
  { name: "Bình Ca", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Chu Mạt", nationality: "Trung Quốc", birth_date: "1929-01-01" },
  { name: "Nguyễn Ngọc Tiến", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Quỳnh Dao", nationality: "Trung Quốc", birth_date: "1938-04-20" },
  { name: "Luis Sepúlveda", nationality: "Chile", birth_date: "1949-10-04", death_date: "2020-04-16" },
  { name: "Nguyễn Đình Thi", nationality: "Việt Nam", birth_date: "1924-12-20", death_date: "2003-04-18" },
  { name: "Trung Sỹ", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Tessa Dare", nationality: "Mỹ", birth_date: "1979-01-01" },
  { name: "Ichikawa Takuji", nationality: "Nhật Bản", birth_date: "1962-01-01" },
  { name: "Tân Dân Tử", nationality: "Việt Nam", birth_date: "1930-01-01" },
  { name: "Min Jin Lee", nationality: "Mỹ", birth_date: "1976-01-01" },
  { name: "Nam Dao", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Paul Jennings", nationality: "Úc", birth_date: "1943-04-30" },
  { name: "Lâm Thành Đạt", nationality: "Việt Nam", birth_date: "1980-01-01" },
  { name: "Aziz Nesin", nationality: "Thổ Nhĩ Kỳ", birth_date: "1915-12-20", death_date: "1995-07-06" },
  { name: "Agnes Abécassis", nationality: "Pháp", birth_date: "1965-01-01" },
  { name: "Tạ Đức Hiền", nationality: "Việt Nam", birth_date: "1920-01-01" },
  { name: "Quỷ Miêu Tử", nationality: "Trung Quốc", birth_date: "1950-01-01" },
  { name: "Ngô Hách", nationality: "Trung Quốc", birth_date: "1950-01-01" },
  { name: "Kim Lĩnh", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Nguyễn Tiến Hưng", nationality: "Việt Nam", birth_date: "1940-01-01" },
  { name: "James G. Zumwalt", nationality: "Mỹ", birth_date: "1950-01-01" },
  { name: "Nguyên Ngọc", nationality: "Việt Nam", birth_date: "1932-01-01" },
  { name: "Trần Trọng Trung", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Phạm Hồng Tung", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Phạm Văn Sơn", nationality: "Việt Nam", birth_date: "1920-01-01", death_date: "2008-01-01" },
  { name: "Minh Châu", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Vũ Thanh Sơn", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Erwan Bergot", nationality: "Pháp", birth_date: "1930-01-01" },
  { name: "Nguyễn Quỳnh", nationality: "Việt Nam", birth_date: "1940-01-01" },
  { name: "Nguyễn Tử Siêu", nationality: "Việt Nam", birth_date: "1805-01-01", death_date: "1868-01-01" },
  { name: "Phan Trần Chúc", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "James Raven", nationality: "Anh", birth_date: "1950-01-01" },
  { name: "Nguyễn Trọng Phấn", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Nguyễn Thiệu Lâu", nationality: "Việt Nam", birth_date: "1930-01-01" },
  { name: "Nguyễn Anh Thái", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Trúc Khê", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Văn Tiến Dũng", nationality: "Việt Nam", birth_date: "1917-05-02", death_date: "2002-08-17" },
  { name: "Mã Thiện Đồng", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Ngô Văn", nationality: "Việt Nam", birth_date: "1940-01-01" },
  { name: "Nguyễn Thị Hồng Hà", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Douglas B. Holt", nationality: "Mỹ", birth_date: "1958-01-01" },
  { name: "Eli Cohen", nationality: "Israel", birth_date: "1924-12-26", death_date: "1965-05-18" },
  { name: "Craig Nathanson", nationality: "Mỹ", birth_date: "1960-01-01" },
  { name: "Lê Minh Quốc", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Kashiwagi Yoshiki", nationality: "Nhật Bản", birth_date: "1950-01-01" },
  { name: "Donald R. Keough", nationality: "Mỹ", birth_date: "1926-08-04", death_date: "2015-02-24" },
  { name: "Peter F. Drucker", nationality: "Mỹ", birth_date: "1909-11-19", death_date: "2005-11-11" },
  { name: "Michael E. Porter", nationality: "Mỹ", birth_date: "1947-05-23" },
  { name: "John Warrillow", nationality: "Canada", birth_date: "1970-01-01" },
  { name: "William H. Draper III", nationality: "Mỹ", birth_date: "1928-01-01" },
  { name: "Robert Heller", nationality: "Anh", birth_date: "1932-01-01" },
  { name: "Verne Harnish", nationality: "Mỹ", birth_date: "1960-01-01" },
  { name: "Jeffrey A. Krames", nationality: "Mỹ", birth_date: "1960-01-01" },
  { name: "Nguyễn Đặng Tuấn Minh", nationality: "Việt Nam", birth_date: "1980-01-01" },
  { name: "Masanobu Fukuoka", nationality: "Nhật Bản", birth_date: "1913-02-02", death_date: "2008-08-16" },
  { name: "Patricia F. Nicolino", nationality: "Mỹ", birth_date: "1960-01-01" },
  { name: "Madhavan Ramanujam", nationality: "Mỹ", birth_date: "1970-01-01" },
  { name: "Gary Vaynerchuk", nationality: "Mỹ", birth_date: "1975-11-14" },
  { name: "Patrick Lencioni", nationality: "Mỹ", birth_date: "1965-01-01" },
  { name: "Tim Smith", nationality: "Mỹ", birth_date: "1960-01-01" },
  { name: "Siddhartha Mukherjee", nationality: "Ấn Độ", birth_date: "1970-11-21" },
  { name: "Trình Ngọc Hoa", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "William Dufty", nationality: "Mỹ", birth_date: "1916-01-01", death_date: "2008-01-01" },
  { name: "Ngô Đức Hùng", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "Trần Anh Kiệt", nationality: "Việt Nam", birth_date: "1970-01-01" },
  { name: "Cao Bảo Anh", nationality: "Việt Nam", birth_date: "1980-01-01" },
  { name: "Jason Fung", nationality: "Canada", birth_date: "1973-01-01" },
  { name: "BS. Tố Hoài", nationality: "Việt Nam", birth_date: "1960-01-01" },
  { name: "GS. Nguyễn Văn Thành", nationality: "Việt Nam", birth_date: "1940-01-01" },
  { name: "Giá Oản Chúc", nationality: "Việt Nam", birth_date: "1950-01-01" },
  { name: "Dale Carnegie", nationality: "Mỹ", birth_date: "1888-11-24", death_date: "1955-11-01" },
  { name: "Viktor Frankl", nationality: "Áo", birth_date: "1905-03-26", death_date: "1997-09-02"},
  { name: "Tony Buổi Sáng", nationality: "Việt Nam", birth_date: "1970-01-01"},
  { name: "Robert C. Martin", nationality: "Mỹ", birth_date: "1952-01-01"},
  { name: "Erich Gamma", nationality: "Thụy Sĩ", birth_date: "1961-03-13"},
  { name: "Mario Puzo", nationality: "Mỹ", birth_date: "1920-10-15", death_date: "1999-07-02"},
  { name: "Victor Hugo", nationality: "Pháp", birth_date: "1802-02-26", death_date: "1885-05-22"},  
  { name: "Arthur Conan Doyle", nationality: "Anh", birth_date: "1859-05-22", death_date: "1930-07-07"},
  { name: "Edwin Jerome", nationality: "Mỹ", birth_date: "1877-09-09", death_date: "1927-09-07"},
  { name: "David J. Lieberman", nationality: "Mỹ", birth_date: "1960-01-01"},
  { name: "Robin Sharma", nationality: "Canada", birth_date: "1965-01-01"},  
  { name: "Rosie Nguyen", nationality: "Việt Nam", birth_date: "1990-01-01"},
  { name: "Trần Duy Thanh", nationality: "Việt Nam", birth_date: "1990-01-01"},
  { name: "Stephen Hawking", nationality: "Anh", birth_date: "1942-01-08", death_date: "2018-03-14"},    
  { name: "Yuval Noah Harari", nationality: "Israel", birth_date: "1976-02-24"}, 
  { name: "Leo Tolstoy", nationality: "Nga", birth_date: "1828-09-09", death_date: "1910-11-20"},  
  { name: "J. D. Salinger", nationality: "Mỹ", birth_date: "1919-01-01", death_date: "2010-01-27"},
  { name: "Variétés Tonkinoises", nationality: "Pháp", birth_date: "1910-01-01"},
  { name: "Thích Minh Nghiêm", nationality: "Việt Nam", birth_date: "1960-01-01"},
  { name: "Mường Mán", nationality: "Việt Nam", birth_date: "1970-01-01"},
  { name: "GS.TS. Bùi Thế Cường", nationality: "Việt Nam", birth_date: "1960-01-01"},
  { name: "Suối Thông", nationality: "Việt Nam", birth_date: "1970-01-01"} 
].map { |a| Author.create!(a) } 

puts "🏢 Đang tạo nhà xuất bản..."
publishers = [
  { name: "Nhà xuất bản Trẻ", address: "TP.HCM, Việt Nam" },
  { name: "Nhà xuất bản Kim Đồng", address: "Hà Nội, Việt Nam" },
  { name: "Penguin Random House", address: "New York, Mỹ" },
  { name: "HarperCollins", address: "London, Anh" },
  { name: "Simon & Schuster", address: "New York, Mỹ" },
  { name: "Nhà xuất bản Hội Nhà Văn", address: "Hà Nội, Việt Nam" },
  { name: "Nhà xuất bản Phụ Nữ", address: "Hà Nội, Việt Nam" },
  { name: "Nhà xuất bản Văn học", address: "Hà Nội, Việt Nam"},
  { name: "Nhà xuất bản Thanh niên", address: "Hà Nội, Việt Nam"},
  { name: "Nhà xuất bản Văn hóa Văn Nghệ", address: "Hà Nội, Việt Nam"},
  { name: "Nhà xuất bản Lao Động", address: "Hà Nội, Việt Nam"}  
].map { |p| Publisher.create!(p) }

puts "📖 Đang tạo thông tin sách..."
puts "Authors count: #{Author.count}"
puts Author.pluck(:id, :name).inspect
books = [
  {
    title: "Tôi thấy hoa vàng trên cỏ xanh",
    description: "Câu chuyện xoay quanh nhân vật chính là Thiều,
     một cậu bé đang sống những năm tháng tuổi thơ ở một vùng quê nghèo miền Trung cùng 
     em trai là Tường – hiền lành, nhạy cảm và đặc biệt thông minh. Tình cảm anh em, 
     những rung động đầu đời, nỗi ghen tị âm thầm, sự ngây thơ và đôi lúc là ích kỷ trẻ con… 
     được Nguyễn Nhật Ánh thể hiện vô cùng tinh tế qua lời kể mộc mạc nhưng sâu sắc. 
     Tường như là hình ảnh phản chiếu của sự trong sáng, 
     còn Thiều – dù yêu thương em – vẫn có lúc ích kỷ, nóng nảy và phạm sai lầm.",
    publication_year: 2010,
    author: Author.find_by!(name: "Nguyễn Nhật Ánh"),
    publisher: publishers[0],
    categories: [categories[9]],
    total_quantity: 15,
    available_quantity: 12
  },
  {
    title: "Harry Potter và Hòn đá Phù thủy",
    description: "Câu chuyện kể về hành trình của cậu bé Harry Potter,
     một cậu bé mồ côi sống với gia đình dì dượng ghẻ lạnh. Vào sinh nhật lần thứ 11,
     Harry biết được mình là một phù thủy và được nhận vào trường Hogwarts danh tiếng. Tại đây, 
     Harry kết bạn với Ron và Hermione, cùng nhau trải qua những cuộc phiêu lưu kỳ thú và đối mặt
      với thế lực hắc ám của Chúa tể Voldemort.",
    publication_year: 1997,
    author: Author.find_by!(name: "J.K. Rowling"),
    publisher: publishers[2],
    categories: [categories[8]],
    total_quantity: 20,
    available_quantity: 18
  },
  {
    title: "Đắc nhân tâm",
    description: "Đắc Nhân Tâm của Dale Carnegie là một trong những cuốn sách kinh điển và có 
    ảnh hưởng sâu rộng nhất mọi thời đại trong lĩnh vực giao tiếp, ứng xử và phát triển bản thân. 
    Được xuất bản lần đầu vào năm 1936, cuốn sách đã được dịch ra hàng chục ngôn ngữ và bán ra 
    hàng triệu bản trên toàn thế giới, trở thành kim chỉ nam cho bất kỳ ai mong muốn xây dựng 
    mối quan hệ tốt đẹp, tạo dựng lòng tin và đạt được thành công thông qua việc thấu hiểu và 
    chạm tới trái tim người khác.",
    publication_year: 1936,
    author: Author.find_by!(name: "Dale Carnegie"),
    publisher: publishers[3],
    categories: [categories[10]],
    total_quantity: 25,
    available_quantity: 20
  },
  {
    title: "Nhà giả kim",
    description: "Nhà Giả Kim của Paulo Coelho là một trong những tác phẩm văn học đương 
    đại nổi tiếng và có sức ảnh hưởng sâu rộng nhất trên toàn thế giới. Được viết bằng một 
    giọng văn giản dị nhưng hàm chứa nhiều tầng ý nghĩa, cuốn sách là hành trình vừa thực tế 
    vừa mang màu sắc huyền thoại về việc theo đuổi ước mơ, khám phá bản thân và sống đúng với 
    “Thiên mệnh” – khái niệm xuyên suốt và cốt lõi trong toàn bộ tác phẩm.",
    publication_year: 1988,
    author: Author.find_by!(name: "Paulo Coelho"),
    publisher: publishers[3],
    categories: [categories[0]],
    total_quantity: 18,
    available_quantity: 15
  },
  {
    title: "Rừng Na Uy",
    description: "Rừng Na Uy là một trong những cuốn tiểu thuyết
     lãng mạn và u buồn, mang tính biểu tượng sâu sắc nhất của văn học Nhật Bản hiện đại.
      Được xuất bản lần đầu vào năm 1987, tác phẩm đã ngay lập tức gây tiếng vang lớn 
      không chỉ ở Nhật Bản mà còn trên toàn thế giới, đưa tên tuổi Haruki Murakami trở thành
       một trong những nhà văn đương đại được yêu thích nhất. Truyện không chỉ là lời tự sự về
        tình yêu và tuổi trẻ, mà còn là tiếng lòng của cả một thế hệ – thế hệ đã lớn lên giữa 
        những đổi thay nhanh chóng của xã hội Nhật Bản, mang trong mình nỗi cô đơn, khao khát kết nối,
         và sự day dứt về những lựa chọn đã qua.",
    publication_year: 1987,
    author: Author.find_by!(name: "Haruki Murakami"),
    publisher: publishers[4],
    categories: [categories[0]],
    total_quantity: 12,
    available_quantity: 10
  },
  {
    title: "1984",
    description: "1984 là một trong những cuốn tiểu thuyết dystopian kinh điển và có sức 
    ảnh hưởng nhất mọi thời đại của George Orwell. Được xuất bản vào năm 1949, tác phẩm đã 
    ngay lập tức gây chấn động và được coi là một lời cảnh báo sâu sắc về những nguy cơ 
    của chủ nghĩa toàn trị, sự thao túng quyền lực, và sự xâm phạm quyền tự do cá nhân 
    trong một xã hội công nghệ cao. Lấy bối cảnh tại Oceania, một trong ba siêu cường 
    trên thế giới, câu chuyện xoay quanh Winston Smith, một công chức bình thường đang sống 
    dưới chế độ độc tài tàn bạo của Đảng, đứng đầu là Big Brother – một nhân vật bí ẩn 
    luôn theo dõi mọi hành động và suy nghĩ của người dân thông qua hệ thống màn hình giám sát 
    (telescreen). Winston, với tư tưởng độc lập và khát khao tìm kiếm sự thật, bắt đầu cuộc 
    nổi loạn ngầm trong tâm tưởng của mình, khi anh bí mật viết nhật ký – hành động bị coi 
    là trọng tội trong xã hội nơi “Tư tưởng là Tội lỗi” (Thoughtcrime).",
    publication_year: 1949,
    author: Author.find_by!(name: "George Orwell"),
    publisher: publishers[2],
    categories: [categories[0]],
    total_quantity: 15,
    available_quantity: 13
  },
  {
    title: "Dế Mèn phiêu lưu ký",
    description: "Tác phẩm văn học thiếu nhi kinh điển kể về hành trình trưởng thành 
    của chú Dế Mèn kiêu căng nhưng giàu khát vọng. Qua những chuyến phiêu lưu, Dế Mèn dần 
    nhận ra sai lầm của bản thân và học cách sống có trách nhiệm hơn với người khác.Câu 
    chuyện phản ánh sâu sắc bài học về lòng dũng cảm, tình bạn và sự cảm thông trong cuộc 
    sống. Thế giới côn trùng được miêu tả sinh động, gần gũi nhưng cũng đầy tính biểu 
    tượng về xã hội loài người. Đây là tác phẩm nổi bật giúp nhiều thế hệ độc giả nhỏ 
    tuổi hình thành nhân cách và cách nhìn nhận cuộc đời.",
    publication_year: 1941,
    author: Author.find_by!(name: "Tô Hoài"),
    publisher: publishers[1],
    categories: [categories[9]],
    total_quantity: 20,
    available_quantity: 18
  },
  {
    title: "Số đỏ",
    description: "Tác phẩm trào phúng đặc sắc phản ánh xã hội Việt Nam thời kỳ nửa thực dân 
    nửa phong kiến với nhiều thói hư tật xấu.Nhân vật Xuân Tóc Đỏ từ một kẻ vô học lại nhờ 
    may mắn và sự lố bịch của xã hội mà trở thành người nổi tiếng.Qua đó, tác giả phơi bày sự 
    giả dối, lố lăng của tầng lớp thượng lưu và những phong trào “Âu hóa” rỗng tuếch.Giọng 
    văn châm biếm sắc sảo kết hợp với tình huống hài hước tạo nên sức hấp dẫn đặc biệt cho tác 
    phẩm. Đây là một trong những tiểu thuyết hiện thực phê phán tiêu biểu của văn học Việt Nam.",
    publication_year: 1936,
    author: Author.find_by!(name: "Vũ Trọng Phụng"),
    publisher: publishers[5],
    categories: [categories[0]],
    total_quantity: 10,
    available_quantity: 8
  },
  {
    title: "Đi tìm lẽ sống",
    description: "Cuốn sách là tập hợp những hồi ức đau thương nhưng đầy hy vọng của một bác sĩ 
    tâm thần sống sót qua trại tập trung Đức Quốc xã. Thay vì gục ngã trước cái chết và nỗi 
    tuyệt vọng, tác giả đã khám phá ra sức mạnh của ý chí con người khi có một lý do để tồn 
    tại. Frankl khẳng định rằng ý nghĩa cuộc sống không phải thứ để tìm kiếm một cách trừu 
    tượng, mà là trách nhiệm mà mỗi cá nhân phải thực hiện. Tác phẩm là một bài ca về sự tự 
    do nội tâm, nơi con người vẫn có quyền lựa chọn thái độ của mình trước mọi nghịch cảnh 
    khắc nghiệt nhất.",
    publication_year: 1946,
    author: Author.find_by!(name: "Viktor Frankl"),
    publisher: publishers[4],
    categories: [categories[5]],
    total_quantity: 12,
    available_quantity: 10
  },
  {
    title: "Cà phê cùng Tony",
    description: "Cuốn sách là tập hợp những câu chuyện ngắn gọn, dí dỏm và đầy suy ngẫm của
     tác giả Tony Buổi Sáng, được chắt lọc từ kinh nghiệm sống và sự quan sát tinh tế của 
     anh về xã hội Việt Nam đương đại. Qua lăng kính hóm hỉnh nhưng không kém phần sâu sắc, 
     tác phẩm đề cập đến nhiều khía cạnh của cuộc sống, từ học đường, công sở đến các vấn đề 
     văn hóa, xã hội, và quan trọng nhất là hành trình tìm kiếm ý nghĩa và hạnh phúc của 
     mỗi cá nhân.",
    publication_year: 2015,
    author: Author.find_by!(name: "Tony Buổi Sáng"),
    publisher: publishers[0],
    categories: [categories[10]],
    total_quantity: 30,
    available_quantity: 25
  },
  {
    title: "Clean Code",
    description: "Đây không chỉ là một cuốn sách, mà là một bản tuyên ngôn về nghề lập trình. 
    Tác giả Robert C. Martin (Uncle Bob) đã hệ thống hóa những kinh nghiệm thực chiến 
    hàng chục năm vào 46 nguyên tắc, 76 ví dụ code “xấu” và “tốt” rõ ràng. Cuốn sách 
    đi sâu vào bản chất của “Code Clean” – thứ không nằm ở việc code chạy được, mà nằm ở 
    việc code dễ đọc, dễ bảo trì và dễ thay đổi. Từ cách đặt tên biến, viết comment, 
    quản lý lỗi, cho đến kiến trúc hàm, tác giả đều đưa ra những lời khuyên đanh thép nhưng 
    cực kỳ thực tế.",
    publication_year: 2008,
    author: Author.find_by!(name: "Robert C. Martin"),
    publisher: publishers[4],
    categories: [categories[2]],
    total_quantity: 15,
    available_quantity: 12
  },
  {
    title: "Design Patterns", # khong co
    description: "Cuốn sách kinh điển được mệnh danh là “Kinh Thánh” của giới lập trình viên 
    hướng đối tượng. Khái niệm Gang of Four (GoF) bốn tác giả Erich Gamma, Richard Helm, 
    Ralph Johnson và John Vlissides đã trở thành huyền thoại. Cuốn sách trình bày 23 mẫu 
    thiết kế (Design Patterns) đã được đúc kết từ thực tiễn, phân loại rõ ràng thành 3 nhóm: 
    Tạo sinh (Creational), Kết cấu (Structural) và Hành vi (Behavioral). Không chỉ đưa ra lý 
    thuyết khô khan, GoF còn chỉ ra những vấn đề mà các mẫu này giải quyết, ưu nhược điểm và 
    thời điểm nên sử dụng. Đây là tác phẩm bắt buộc phải đọc để hiểu sâu sắc về tư duy lập 
    trình hiện đại và cách xây dựng phần mềm linh hoạt, dễ bảo trì.",
    publication_year: 1994,
    author: Author.find_by!(name: "Erich Gamma"),
    publisher: publishers[4],
    categories: [categories[2]],
    total_quantity: 10,
    available_quantity: 8
  },
  {
    title: "Bố già",
    description: "Tiểu thuyết về gia đình mafia Corleone.
     Câu chuyện xoay quanh Don Vito Corleone, 
     ông trùm khét tiếng của gia đình mafia Corleone tại New York, 
     và cuộc đấu tranh quyền lực đẫm máu với các gia đình đối thủ. 
     Qua lăng kính của gia tộc Corleone, tác phẩm phơi bày mặt trái của quyền lực, 
     tiền tài và thế giới ngầm, nơi danh dự và lòng trung thành được đổi bằng bạo lực 
     và những quyết định sinh tử. Bố già không chỉ là một cuốn tiểu thuyết tội phạm mà 
     còn là bức tranh phản ánh về cấu trúc gia đình, sự tha hóa của con người trước 
     cám dỗ quyền lực và những bi kịch không thể tránh khỏi của một đế chế ngầm.",
    publication_year: 1969,
    author: Author.find_by!(name: "Mario Puzo"),
    publisher: publishers[2],
    categories: [categories[0]],
    total_quantity: 18,
    available_quantity: 15
  },
  {
    title: "Những người khốn khổ",
    description: "Kiệt tác văn học của Victor Hugo. Câu chuyện xoay quanh Jean Valjean,
     một người đàn ông bị kết án oan 19 năm tù giam chỉ vì ăn trộm một ổ bánh mì để nuôi 
     gia đình. Sau khi được trả tự do, ông quyết tâm hoàn lương, nhưng xã hội lại không
     ngừng truy đuổi quá khứ của ông thông qua thanh tra Javert. Trên hành trình đó,
     ông gặp gỡ và bảo vệ Cosette, con gái của Fantine, một phụ nữ nghèo bị xã hội ruồng bỏ. 
     Tác phẩm là bản hùng ca về lòng trắc ẩn, sự hy sinh và cuộc chiến không ngừng 
     nghỉ giữa công lý và lòng nhân ái, giữa luật lệ hà khắc và tình người ấm áp.",
    publication_year: 1862,
    author: Author.find_by!(name: "Victor Hugo"),
    publisher: publishers[3],
    categories: [categories[4]],
    total_quantity: 12,
    available_quantity: 10
  },
  {
    title: "Sherlock Holmes",
    description: "Tuyển tập truyện trinh thám kinh điển",
    publication_year: 1887,
    author: Author.find_by!(name: "Arthur Conan Doyle"),
    publisher: publishers[3],
    categories: [categories[7]],
    total_quantity: 15,
    available_quantity: 12
  },
  {
    title: "Trí tuệ do thái",
    description: "Sách về tư duy và cách sống của người Do Thái",
    publication_year: 2010,
    author: Author.find_by!(name: "Edwin Jerome"),
    publisher: publishers[0],
    categories: [categories[10]],
    total_quantity: 20,
    available_quantity: 18
  },
  {
    title: "Đọc vị bất kỳ ai",
    description: "Sách về tâm lý và cách đọc suy nghĩ người khác",
    publication_year: 2007,
    author: Author.find_by!(name: "David J. Lieberman"),
    publisher: publishers[1],
    categories: [categories[5]],
    total_quantity: 25,
    available_quantity: 20
  },
  {
    title: "Nhà lãnh đạo không chức danh",
    description: "Sách về phát triển khả năng lãnh đạo",
    publication_year: 2010,
    author: Author.find_by!(name: "Robin Sharma"),
    publisher: publishers[0],
    categories: [categories[10]],
    total_quantity: 15,
    available_quantity: 12
  },
  {
    title: "Tuổi trẻ đáng giá bao nhiêu",
    description: "Sách truyền cảm hứng cho giới trẻ",
    publication_year: 2016,
    author: Author.find_by!(name: "Rosie Nguyen"),
    publisher: publishers[0],
    categories: [categories[10]],
    total_quantity: 30,
    available_quantity: 25
  },
  {
    title: "Tôi đi code dạo",
    description: "Hành trình trở thành lập trình viên",
    publication_year: 2017,
    author: Author.find_by!(name: "Trần Duy Thanh"),
    publisher: publishers[1],
    categories: [categories[2]],
    total_quantity: 20,
    available_quantity: 18
  },
  {
    title: "Lược sử thời gian",
    description: "Sách về vũ trụ và vật lý lý thuyết",
    publication_year: 1988,
    author: Author.find_by!(name: "Stephen Hawking"),
    publisher: publishers[3],
    categories: [categories[1]],
    total_quantity: 15,
    available_quantity: 12
  },
  {
    title: "Sapiens: Lược sử loài người",
    description: "Lịch sử tiến hóa của loài người",
    publication_year: 2011,
    author: Author.find_by!(name: "Yuval Noah Harari"),
    publisher: publishers[3],
    categories: [categories[1]],
    total_quantity: 18,
    available_quantity: 15
  },
  {
    title: "Chiến tranh và hòa bình",
    description: "Tiểu thuyết sử thi về xã hội Nga thời Napoleon",
    publication_year: 1869,
    author: Author.find_by!(name: "Leo Tolstoy"),
    publisher: publishers[2],
    categories: [categories[4]],
    total_quantity: 10,
    available_quantity: 8
  },
  {
    title: "Bắt trẻ đồng xanh",
    description: "Tiểu thuyết về tuổi trẻ nổi loạn",
    publication_year: 1951,
    author: Author.find_by!(name: "J. D. Salinger"),
    publisher: publishers[2],
    categories: [categories[0]],
    total_quantity: 15,
    available_quantity: 12
  },
  {
    title: "Ông già và biển cả",
    description: "Câu chuyện về lão ngư dân và con cá kiếm",
    publication_year: 1952,
    author: Author.find_by!(name: "Ernest Hemingway"),
    publisher: publishers[2],
    categories: [categories[0]],
    total_quantity: 12,
    available_quantity: 10
  },
  {
    title: "Mắt biếc",
    description: "Câu chuyện tình yêu tuổi học trò",
    publication_year: 1990,
    author: Author.find_by!(name: "Nguyễn Nhật Ánh"),
    publisher: publishers[0],
    categories: [categories[0]],
    total_quantity: 20,
    available_quantity: 18
  },
  {
    title: "Cho tôi xin một vé đi tuổi thơ",
    description: "Hồi ức về tuổi thơ với những trò chơi và kỷ niệm",
    publication_year: 2008,
    author: Author.find_by!(name: "Nguyễn Nhật Ánh"),
    publisher: publishers[0],
    categories: [categories[0]],
    total_quantity: 25,
    available_quantity: 20
  },
  {
    title: "Cánh đồng bất tận",
    description: "Tập truyện ngắn về vùng đất Nam Bộ",
    publication_year: 2005,
    author: Author.find_by!(name: "Nguyễn Ngọc Tư"),
    publisher: publishers[6],
    categories: [categories[6]],
    total_quantity: 15,
    available_quantity: 12
  },
  {
    title: "Chí Phèo",
    description: "Kiệt tác văn học hiện thực phê phán",
    publication_year: 1941,
    author: Author.find_by!(name: "Nam Cao"),
    publisher: publishers[5],
    categories: [categories[0]],
    total_quantity: 20,
    available_quantity: 18
  },
  {
    title: "Lão Hạc",
    description: "Truyện ngắn về số phận người nông dân",
    publication_year: 1943,
    author: Author.find_by!(name: "Nam Cao"),
    publisher: publishers[5],
    categories: [categories[6]],
    total_quantity: 15,
    available_quantity: 12
  },
  {
    title: "Những di chúc bị phản bội",
    description: "Những Di Chúc Bị Phản Bội (Les Testaments trahis) của Milan 
    Kundera là một tập tiểu luận giàu tính suy tư, nơi tác giả tiếp tục đào 
    sâu những vấn đề ông từng đặt ra trong Nghệ thuật Tiểu Thuyết. Nếu cuốn sách
    trước là hành trình truy nguyên lịch sử và bản chất của tiểu thuyết từ Miguel 
    de Cervantes đến Franz Kafka, thì ở tác phẩm này, Kundera mở rộng phạm vi khảo sát,
     đối thoại với nhiều tên tuổi lớn của văn chương và âm nhạc châu Âu.",
    publication_year: 2005,
    author: Author.find_by!(name: "Milan Kundera"),
    publisher: publishers[0],
    categories: [categories[4]], # Lịch sử - Chính trị
    total_quantity: 25,
    available_quantity: 8
  },
  {
    title: "Chiêu hồn thập loại chúng sinh",
    description: "Tác phẩm Chiêu Hồn Thập Loại Chúng Sinh (hay còn gọi là 
    Văn tế thập loại chúng sinh) là một trong những áng văn chương đỉnh cao
     của đại thi hào Nguyễn Du, thể hiện tinh thần nhân đạo bao la và sự thấ
     u cảm sâu sắc đối với thân phận con người. Khác với những tác phẩm viết 
     về giới thượng lưu hay các anh hùng, bài văn tế này hướng cái nhìn thương 
     xót đến tất cả mọi tầng lớp trong xã hội, từ những kẻ quyền quý sa cơ đến 
     những người cùng khổ, cô độc không nơi nương tựa. Qua ngòi bút tài hoa và 
     đầy tâm huyết, tác giả đã dựng lên một bức tranh tâm linh huyền ảo nhưng 
     cũng đầy tính hiện thực về kiếp nhân sinh phù du.",
    publication_year: 1998,
    author: Author.find_by!(name: "Nguyễn Du"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 35,
    available_quantity: 15
  },
  {
    title: "Văn minh Việt Nam",
    description: "Nghiên cứu toàn diện về văn minh Việt Nam qua các thời kỳ",
    publication_year: 1940,
    author: Author.find_by(name: "Nguyễn Văn Huyên"),
    publisher: publishers[0],
    categories: [categories[4], categories[11]], # Lịch sử - Chính trị, Văn hóa
    total_quantity: 30,
    available_quantity: 10
  },
  {
    title: "Đất Việt Trời Nam",
    description: "Sử thi về lịch sử và văn hóa dân tộc Việt Nam",
    publication_year: 1960,
    author: Author.find_by!(name: "Thái Văn Kiểm"),
    publisher: publishers[0],
    categories: [categories[0], categories[4]], # Tiểu thuyết, Lịch sử
    total_quantity: 40,
    available_quantity: 18
  },
  {
    title: "Lịch sử truyền giáo ở Việt Nam",
    description: "Nghiên cứu lịch sử truyền giáo Công giáo tại Việt Nam",
    publication_year: 1950,
    author: Author.find_by!(name: "Nguyên Hồng"),
    publisher: publishers[0],
    categories: [categories[4]], # Lịch sử - Chính trị
    total_quantity: 20,
    available_quantity: 7
  },
  {
    title: "Tương lai Thiền học Việt Nam",
    description: "Triển vọng phát triển Thiền học trong tương lai",
    publication_year: 2000,
    author: Author.find_by!(name: "Thích Nhất Hạnh"),
    publisher: publishers[0],
    categories: [categories[11], categories[5]], # Văn hóa, Tâm lý học
    total_quantity: 45,
    available_quantity: 22
  },
  {
    title: "Sen Nở Trời Phương Ngoại",
    description: "Tiểu thuyết về hành trình tâm linh",
    publication_year: 1995,
    author: Author.find_by!(name: "Thích Nhất Hạnh"),
    publisher: publishers[0],
    categories: [categories[0], categories[5]], # Tiểu thuyết, Tâm lý học
    total_quantity: 38,
    available_quantity: 16
  },
  {
    title: "Khái lược văn minh Luận",
    description: "Luận thuyết về văn minh nhân loại",
    publication_year: 1930,
    author: Author.find_by!(name: "Fukuzawa Yukichi"),
    publisher: publishers[0],
    categories: [categories[11], categories[4]], # Văn hóa, Lịch sử
    total_quantity: 28,
    available_quantity: 9
  },
  {
    title: "Bắc Kỳ Tạp lục",
    description: "Tập hợp ghi chép về phong tục Bắc Kỳ",
    publication_year: 1910,
    author: Author.find_by!(name: "Variétés Tonkinoises"),
    publisher: publishers[0],
    categories: [categories[11]], # Văn hóa
    total_quantity: 22,
    available_quantity: 6
  },
  {
    title: "Nghi thức Tang lễ của người An Nam",
    description: "Nghiên cứu nghi lễ tang ma truyền thống Việt Nam",
    publication_year: 1920,
    author: Author.find_by!(name: "Gustave Dumoutie"),
    publisher: publishers[0],
    categories: [categories[11]], # Văn hóa
    total_quantity: 18,
    available_quantity: 5
  },
  {
    title: "Việt Nam Văn Hóa Sử Cương",
    description: "Dàn ý lịch sử văn hóa Việt Nam",
    publication_year: 1950,
    author: Author.find_by!(name: "Đào Duy Anh"),
    publisher: publishers[0],
    categories: [categories[4], categories[11]], # Lịch sử, Văn hóa
    total_quantity: 32,
    available_quantity: 12
  },
  {
    title: "Đọc hiểu kinh dịch",
    description: "Hướng dẫn nghiên cứu Kinh Dịch",
    publication_year: 2008,
    author: Author.find_by!(name: "Thích Minh Nghiêm"),
    publisher: publishers[0],
    categories: [categories[11], categories[5]], # Văn hóa, Tâm lý học
    total_quantity: 50,
    available_quantity: 25
  },
  {
    title: "Hiểu về trái tim",
    description: "Sách tâm linh về bản chất con người",
    publication_year: 2010,
    author: Author.find_by!(name: "Minh Niệm"),
    publisher: publishers[0],
    categories: [categories[5]], # Tâm lý học
    total_quantity: 60,
    available_quantity: 35
  },
  {
    title: "Rong chơi miền chữ nghĩa",
    description: "Tùy bút về văn học và ngôn ngữ",
    publication_year: 2005,
    author: Author.find_by!(name: "An Chi"),
    publisher: publishers[0],
    categories: [categories[11]], # Văn hóa
    total_quantity: 42,
    available_quantity: 20
  },
  {
    title: "Thiền Căn Bản",
    description: "Hướng dẫn thiền cơ bản",
    publication_year: 1990,
    author: Author.find_by!(name: "Đại Sư Trí Hải"),
    publisher: publishers[0],
    categories: [categories[5], categories[10]], # Tâm lý học, Kỹ năng
    total_quantity: 55,
    available_quantity: 28
  },
  {
    title: "Linh Ứng",
    description: "Truyện tâm linh về các hiện tượng lạ",
    publication_year: 1985,
    author: Author.find_by!(name: "Nguyễn Mạnh Tuấn"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 36,
    available_quantity: 14
  },
  {
    title: "Bí Ẩn Tiền Kiếp Và Hậu Kiếp",
    description: "Khám phá bí ẩn luân hồi",
    publication_year: 2002,
    author: Author.find_by!(name: "Đoàn Văn Thông"),
    publisher: publishers[0],
    categories: [categories[5]], # Tâm lý học
    total_quantity: 48,
    available_quantity: 24
  },
  {
    title: "Bí Ẩn Của Các Nhà Ngoại Cảm Việt Nam",
    description: "Nghiên cứu hiện tượng ngoại cảm",
    publication_year: 1999,
    author: Author.find_by!(name: "Lê Mai Dung"),
    publisher: publishers[0],
    categories: [categories[5], categories[17]], # Tâm lý học, Y học
    total_quantity: 40,
    available_quantity: 18
  },
  {
    title: "Dấu chân trên cát",
    description: "Tiểu thuyết tâm linh kinh điển",
    publication_year: 1965,
    author: Author.find_by!(name: "Mika Waltari"),
    publisher: publishers[0],
    categories: [categories[0], categories[5]], # Tiểu thuyết, Tâm lý học
    total_quantity: 65,
    available_quantity: 30
  },
  {
    title: "Bạn Muốn Biết Chết Là Như Thế Nào",
    description: "Hướng dẫn về quá trình ra đi",
    publication_year: 2012,
    author: Author.find_by!(name: "Rodney Smith"),
    publisher: publishers[0],
    categories: [categories[5]], # Tâm lý học
    total_quantity: 52,
    available_quantity: 26
  },
  {
    title: "Trở Về Không",
    description: "Hành trình trở về bản thể",
    publication_year: 2007,
    author: Author.find_by!(name: "Joe Vitale"),
    publisher: publishers[0],
    categories: [categories[5], categories[10]], # Tâm lý học, Kỹ năng
    total_quantity: 58,
    available_quantity: 32
  },
  {
    title: "Gương Người Xưa",
    description: "Tiểu sử các bậc hiền triết",
    publication_year: 1955,
    author: Author.find_by!(name: "Tế Xuyên"),
    publisher: publishers[0],
    categories: [categories[4]], # Lịch sử - Chính trị
    total_quantity: 30,
    available_quantity: 12
  },
  {
    title: "Tiếp Xúc Với Sự Sống",
    description: "Thiền tập về sự sống",
    publication_year: 1990,
    author: Author.find_by!(name: "Thích Nhất Hạnh"),
    publisher: publishers[0],
    categories: [categories[5]], # Tâm lý học
    total_quantity: 50,
    available_quantity: 25
  },
  {
    title: "Ước Hẹn Với Sự Sống – Khi Người Biết Sống Một Mình",
    description: "Nghệ thuật sống một mình hạnh phúc",
    publication_year: 2015,
    author: Author.find_by!(name: "Thích Nhất Hạnh"),
    publisher: publishers[0],
    categories: [categories[5], categories[10]], # Tâm lý học, Kỹ năng
    total_quantity: 45,
    available_quantity: 22
  },
  {
    title: "Một Cội Cây Rừng",
    description: "Tiểu thuyết về thiên nhiên và con người",
    publication_year: 1980,
    author: Author.find_by!(name: "Ajahn Chah"),
    publisher: publishers[0],
    categories: [categories[10]],
    total_quantity: 38,
    available_quantity: 15
  },
  {
    title: "Sống Đời Bình An",
    description: "Hướng dẫn sống an lạc",
    publication_year: 2003,
    author: Author.find_by!(name: "Suối Thông"),
    publisher: publishers[0],
    categories: [categories[10]], # Kỹ năng
    total_quantity: 62,
    available_quantity: 35
  },
  {
    title: "Ngàn Năm Áo Mũ",
    description: "Lịch sử trang phục truyền thống Việt Nam",
    publication_year: 1975,
    author: Author.find_by!(name: "Trần Quang Đức"),
    publisher: publishers[0],
    categories: [categories[11], categories[4]], # Văn hóa, Lịch sử
    total_quantity: 25,
    available_quantity: 8
  },
  {
    title: "Việt Nam Phong Tục",
    description: "Tổng hợp phong tục Việt Nam",
    publication_year: 1915,
    author: Author.find_by!(name: "Phan Kế Bính"),
    publisher: publishers[0],
    categories: [categories[11]], # Văn hóa
    total_quantity: 28,
    available_quantity: 10
  },
  {
    title: "Làng Xưa",
    description: "Hồi ký về làng quê Việt Nam xưa",
    publication_year: 1965,
    author: Author.find_by!(name: "Nguyễn Văn"),
    publisher: publishers[0],
    categories: [categories[4], categories[11]], # Lịch sử, Văn hóa
    total_quantity: 35,
    available_quantity: 14
  },
  {
    title: "Con Ốc Biển",
    description: "Truyện ngắn miền biển",
    publication_year: 1970,
    author: Author.find_by!(name: "Xuân Sách"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 32,
    available_quantity: 12
  },
  {
    title: "Bóng Ma Trong Nhà Hát",
    description: "Tiểu thuyết kinh dị kinh điển",
    publication_year: 1910,
    author: Author.find_by!(name: "Gaston Leroux"),
    publisher: publishers[0],
    categories: [categories[7]], # Trinh thám
    total_quantity: 55,
    available_quantity: 28
  },
  {
    title: "Đốt Đời",
    description: "Tiểu thuyết về số phận con người",
    publication_year: 1985,
    author: Author.find_by!(name: "Đào Hiếu"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 40,
    available_quantity: 18
  },
  {
    title: "Ngọn Đèn Dầu Lạc",
    description: "Truyện ngắn về đời sống nông thôn",
    publication_year: 1940,
    author: Author.find_by!(name: "Nguyễn Tuân"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 45,
    available_quantity: 20
  },
  {
    title: "Sao Anh Lại Lấy Chồng Em",
    description: "Tiểu thuyết tình cảm",
    publication_year: 1990,
    author: Author.find_by!(name: "Hoàng Hải Lâm"),
    publisher: publishers[0],
    categories: [categories[12]], # Lãng mạn
    total_quantity: 38,
    available_quantity: 16
  },
  {
    title: "Bàn Có Năm Chỗ Ngồi",
    description: "Truyện ngắn về gia đình",
    publication_year: 1985,
    author: Author.find_by!(name: "Nguyễn Nhật Ánh"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 42,
    available_quantity: 19
  },
  {
    title: "Thành Phố Đi Vắng",
    description: "Tiểu thuyết về chiến tranh",
    publication_year: 1972,
    author: Author.find_by!(name: "Nguyễn Thị Thu Huệ"),
    publisher: publishers[0],
    categories: [categories[0], categories[15]], # Tiểu thuyết, Chiến tranh
    total_quantity: 35,
    available_quantity: 13
  },
  {
    title: "Hoa Hồng Không Gai",
    description: "Tiểu thuyết tình yêu",
    publication_year: 1995,
    author: Author.find_by!(name: "Phạm Thị Thanh Hoa"),
    publisher: publishers[0],
    categories: [categories[12]], # Lãng mạn
    total_quantity: 40,
    available_quantity: 17
  },
  {
    title: "Người Đàn Bà Về Phía Mặt Trời",
    description: "Tiểu thuyết về hành trình người phụ nữ",
    publication_year: 2000,
    author: Author.find_by!(name: "Rita Nguyễn"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 36,
    available_quantity: 14
  },
  {
    title: "Tia Lửa",
    description: "Truyện ngắn tình yêu",
    publication_year: 1980,
    author: Author.find_by!(name: "Matayoshi Naoki"),
    publisher: publishers[0],
    categories: [categories[6], categories[12]], # Truyện ngắn, Lãng mạn
    total_quantity: 33,
    available_quantity: 11
  },
  {
    title: "Lại Chơi Với Lửa",
    description: "Phần tiếp theo của Tia Lửa",
    publication_year: 1982,
    author: Author.find_by!(name: "Linda Lê"),
    publisher: publishers[0],
    categories: [categories[6], categories[12]], # Truyện ngắn, Lãng mạn
    total_quantity: 30,
    available_quantity: 10
  },
  {
    title: "Con Đường Nước Mắt",
    description: "Tiểu thuyết bi kịch",
    publication_year: 1975,
    author: Author.find_by!(name: "Mạc Ngôn"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 39,
    available_quantity: 15
  },
  {
    title: "Bông Hồng Cài Áo",
    description: "Truyện ngắn tình yêu bất hủ",
    publication_year: 1950,
    author: Author.find_by!(name: "Thích Nhất Hạnh"),
    publisher: publishers[0],
    categories: [categories[6], categories[12]], # Truyện ngắn, Lãng mạn
    total_quantity: 50,
    available_quantity: 25
  },
  {
    title: "Chiếc Thuyền Ngoài Xa",
    description: "Truyện ngắn kinh điển về gia đình",
    publication_year: 1983,
    author: Author.find_by!(name: "Nguyễn Minh Châu"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 60,
    available_quantity: 32
  },
  {
    title: "Chuyện Nhà Quê",
    description: "Tập truyện ngắn về nông thôn",
    publication_year: 1945,
    author: Author.find_by!(name: "Nguyễn Quang Lập"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 48,
    available_quantity: 22
  },
  {
    title: "Cố Định Một Đám Mây",
    description: "Tiểu thuyết hiện đại",
    publication_year: 1985,
    author: Author.find_by!(name: "Nguyễn Quang Lập"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 35,
    available_quantity: 14
  },
  {
    title: "Hải Đảo Xa Xôi",
    description: "Truyện ngắn về ngư dân",
    publication_year: 1962,
    author: Author.find_by!(name: "Hải Hồ"),
    publisher: publishers[0],
    categories: [categories[6], categories[15]], # Truyện ngắn, Chiến tranh
    total_quantity: 42,
    available_quantity: 18
  },
  {
    title: "Chết Giữa Mùa Hè",
    description: "Tiểu thuyết chiến tranh",
    publication_year: 1979,
    author: Author.find_by!(name: "Yukio Mishima"),
    publisher: publishers[0],
    categories: [categories[0], categories[15]], # Tiểu thuyết, Chiến tranh
    total_quantity: 38,
    available_quantity: 16
  },
  {
    title: "Truyện Ngắn Chu Lai",
    description: "Tuyển tập truyện ngắn",
    publication_year: 1990,
    author: Author.find_by!(name: "Chu Lai"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 45,
    available_quantity: 20
  },
  {
    title: "Mưa Thu",
    description: "Truyện ngắn tình cảm",
    publication_year: 1975,
    author: Author.find_by!(name: "Ngọc Giao"),
    publisher: publishers[0],
    categories: [categories[6], categories[12]], # Truyện ngắn, Lãng mạn
    total_quantity: 40,
    available_quantity: 17
  },
  {
    title: "Khói Trời Lộng Lẫy",
    description: "Tiểu thuyết miền Nam",
    publication_year: 1968,
    author: Author.find_by!(name: "Nguyễn Ngọc Tư"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 36,
    available_quantity: 14
  },
  {
    title: "Làn Gió Chảy Qua",
    description: "Truyện ngắn hiện đại",
    publication_year: 1980,
    author: Author.find_by!(name: "Lê Minh Khuê"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 39,
    available_quantity: 16
  },
  {
    title: "Cõng Nhau Trong Một Cõi Người",
    description: "Tiểu thuyết về tình người",
    publication_year: 1995,
    author: Author.find_by!(name: "Hoàng Công Danh"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 42,
    available_quantity: 19
  },
  {
    title: "Tập Truyện Ngắn Một Đồng Bạc",
    description: "Tuyển tập truyện ngắn kinh điển",
    publication_year: 1943,
    author: Author.find_by!(name: "Vũ Trọng Phụng"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 55,
    available_quantity: 28
  },
  {
    title: "Chuyện Xưa Tích Cũ",
    description: "Truyện dân gian Việt Nam",
    publication_year: 1950,
    author: Author.find_by!(name: "Sơn Nam"),
    publisher: publishers[0],
    categories: [categories[6], categories[11]], # Truyện ngắn, Văn hóa
    total_quantity: 50,
    available_quantity: 24
  },
  {
    title: "Hương Rừng Cà Mau",
    description: "Tiểu thuyết về rừng U Minh",
    publication_year: 1965,
    author: Author.find_by!(name: "Sơn Nam"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 48,
    available_quantity: 22
  },
  {
    title: "Vàng Tháp Hời",
    description: "Truyện lịch sử Óc Eo",
    publication_year: 1970,
    author: Author.find_by!(name: "Vũ Hạnh"),
    publisher: publishers[0],
    categories: [categories[0], categories[4]], # Tiểu thuyết, Lịch sử
    total_quantity: 35,
    available_quantity: 13
  },
  {
    title: "Hoa Tường Vi Trong Đêm",
    description: "Truyện ngắn tình yêu",
    publication_year: 1985,
    author: Author.find_by!(name: "Hoàng Nhật Tuyên"),
    publisher: publishers[0],
    categories: [categories[6], categories[12]], # Truyện ngắn, Lãng mạn
    total_quantity: 38,
    available_quantity: 15
  },
  {
    title: "Giấc Mộng Xuân Trong Ngõ Hồ Lô",
    description: "Tiểu thuyết Hà Nội xưa",
    publication_year: 1990,
    author: Author.find_by!(name: "Diệp Thạch Đào"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 40,
    available_quantity: 18
  },
  {
    title: "Tô Tịch",
    description: "Truyện ngắn bi kịch",
    publication_year: 1940,
    author: Author.find_by!(name: "Mị Ngữ Giả"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 45,
    available_quantity: 20
  },
  {
    title: "Chữ Người Tử Tù",
    description: "Truyện ngắn bất hủ về nhân văn",
    publication_year: 1940,
    author: Author.find_by!(name: "Nguyễn Tuân"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 70,
    available_quantity: 40
  },
  {
    title: "Chuyến Tàu Vé Ngắn",
    description: "Truyện ngắn hiện đại",
    publication_year: 1980,
    author: Author.find_by!(name: "Hoàng Công Danh"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 42,
    available_quantity: 19
  },
  {
    title: "Thiên Hạ Kỳ Duyên",
    description: "Tiểu thuyết kiếm hiệp",
    publication_year: 1995,
    author: Author.find_by!(name: "Ánh Tuyết Triều Dương"),
    publisher: publishers[0],
    categories: [categories[0], categories[8]], # Tiểu thuyết, Tiên hiệp - Kiếm hiệp
    total_quantity: 36,
    available_quantity: 14
  },
  {
    title: "Đất Trời Vần Vũ",
    description: "Thơ văn trữ tình",
    publication_year: 1970,
    author: Author.find_by!(name: "Nguyễn Một"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 30,
    available_quantity: 12
  },
  {
    title: "Lửa Yêu Thương, Lửa Ngục Tù",
    description: "Tiểu thuyết về lao tù",
    publication_year: 1985,
    author: Author.find_by!(name: "Erich Maria Remarque"),
    publisher: publishers[0],
    categories: [categories[0], categories[15]], # Tiểu thuyết, Chiến tranh
    total_quantity: 38,
    available_quantity: 16
  },
  {
    title: "Bóng Tối Thiên Đường",
    description: "Tiểu thuyết tâm lý",
    publication_year: 1990,
    author: Author.find_by!(name: "Erich Maria Remarque"),
    publisher: publishers[0],
    categories: [categories[0], categories[5]], # Tiểu thuyết, Tâm lý học
    total_quantity: 40,
    available_quantity: 17
  },
  {
    title: "Bản Du Ca Cuối Cùng",
    description: "Tiểu thuyết chiến tranh",
    publication_year: 1978,
    author: Author.find_by!(name: "Erich Maria Remarque"),
    publisher: publishers[0],
    categories: [categories[0], categories[15]], # Tiểu thuyết, Chiến tranh
    total_quantity: 42,
    available_quantity: 18
  },
  {
    title: "Này Trận Chiến, Này Cuồng Si",
    description: "Nhật ký chiến trường",
    publication_year: 1980,
    author: Author.find_by!(name: "Rafael Sabatini"),
    publisher: publishers[0],
    categories: [categories[15]], # Chiến tranh
    total_quantity: 35,
    available_quantity: 13
  },
  {
    title: "Không Ai Sống Giống Ai Trong Cuộc Đời Này",
    description: "Tiểu thuyết hiện đại",
    publication_year: 2000,
    author: Author.find_by!(name: "Jean-Paul Dubois"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 45,
    available_quantity: 22
  },
  {
    title: "Người Thất Chí",
    description: "Truyện ngắn bi quan",
    publication_year: 1940,
    author: Author.find_by!(name: "Hồ Biểu Chánh"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 48,
    available_quantity: 23
  },
  {
    title: "Người Và Xe Chạy Dưới Ánh Trăng",
    description: "Tiểu thuyết lãng mạn",
    publication_year: 1985,
    author: Author.find_by!(name: "Hồ Anh Thái"),
    publisher: publishers[0],
    categories: [categories[0], categories[12]], # Tiểu thuyết, Lãng mạn
    total_quantity: 39,
    available_quantity: 16
  },
  {
    title: "Đợi Anh Ở Toronto",
    description: "Tiểu thuyết di cư",
    publication_year: 1995,
    author: Author.find_by!(name: "Nguyễn Thu Hoài"),
    publisher: publishers[0],
    categories: [categories[0], categories[12]], # Tiểu thuyết, Lãng mạn
    total_quantity: 36,
    available_quantity: 14
  },
  {
    title: "Ngọc Phương Nam",
    description: "Tiểu thuyết miền Nam",
    publication_year: 1970,
    author: Author.find_by!(name: "Jules Verne"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 40,
    available_quantity: 17
  },
  {
    title: "Nhà Có Bảy Đầu Hồi",
    description: "Truyện ngắn gia đình",
    publication_year: 1980,
    author: Author.find_by!(name: "Nathaniel Hawthorne"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 42,
    available_quantity: 19
  },
  {
    title: "Chúng Ta Sẽ Còn Gặp Lại",
    description: "Tiểu thuyết tình yêu",
    publication_year: 1990,
    author: Author.find_by!(name: "Yasushi Kitagawa"),
    publisher: publishers[0],
    categories: [categories[0], categories[12]], # Tiểu thuyết, Lãng mạn
    total_quantity: 45,
    available_quantity: 21
  },
  {
    title: "Cú Rời Đất Xanh",
    description: "Truyện thiếu nhi",
    publication_year: 1985,
    author: Author.find_by!(name: "Vĩ Ngư"),
    publisher: publishers[0],
    categories: [categories[9]], # Thiếu nhi
    total_quantity: 60,
    available_quantity: 35
  },
  {
    title: "Lão Khổ",
    description: "Tiểu thuyết về người già",
    publication_year: 1975,
    author: Author.find_by!(name: "Tạ Duy Anh"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 35,
    available_quantity: 12
  },
  {
    title: "Khúc Khải Hoàn Dang Dở",
    description: "Tiểu thuyết chiến tranh",
    publication_year: 1980,
    author: Author.find_by!(name: "Hà Ân"),
    publisher: publishers[0],
    categories: [categories[0], categories[15]], # Tiểu thuyết, Chiến tranh
    total_quantity: 38,
    available_quantity: 15
  },
  {
    title: "Năm Mươi Người",
    description: "Truyện ngắn tập thể",
    publication_year: 1970,
    author: Author.find_by!(name: "Chung Serang"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 40,
    available_quantity: 18
  },
  {
    title: "Chuyện Tình Đích Thực Siêu Buồn",
    description: "Tiểu thuyết tình yêu bi kịch",
    publication_year: 2005,
    author: Author.find_by!(name: "Gary Shteyngart"),
    publisher: publishers[0],
    categories: [categories[0], categories[12]], # Tiểu thuyết, Lãng mạn
    total_quantity: 55,
    available_quantity: 30
  },
  {
    title: "Đường Về Cánh Đồng Chum",
    description: "Tiểu thuyết chiến tranh",
    publication_year: 1985,
    author: Author.find_by!(name: "Bùi Bình Thi"),
    publisher: publishers[0],
    categories: [categories[0], categories[15]], # Tiểu thuyết, Chiến tranh
    total_quantity: 42,
    available_quantity: 19
  },
  {
    title: "Trở Về Năm 1981",
    description: "Tiểu thuyết hồi ký",
    publication_year: 2010,
    author: Author.find_by!(name: "Tú Cẩm"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 38,
    available_quantity: 16
  },
  {
    title: "Người Chuyển Tàu",
    description: "Truyện ngắn hiện đại",
    publication_year: 1995,
    author: Author.find_by!(name: "Christopher Isherwood"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 45,
    available_quantity: 22
  },
  {
    title: "Mirai Đến Từ Tương Lai",
    description: "Tiểu thuyết khoa học viễn tưởng",
    publication_year: 2006,
    author: Author.find_by!(name: "Hosoda Mamoru"),  
    publisher: publishers[0],
    categories: [categories[0], categories[1]], # Tiểu thuyết, Khoa học
    total_quantity: 50,
    available_quantity: 25
  },
  {
    title: "Đi Trốn",
    description: "Tiểu thuyết phiêu lưu",
    publication_year: 2000,
    author: Author.find_by!(name: "Bình Ca"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 58,
    available_quantity: 33
  },
  {
    title: "Diên Hi Công Lược Truyện",
    description: "Tiểu thuyết cung đấu",
    publication_year: 2018,
    author: Author.find_by!(name: "Chu Mạt"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 52,
    available_quantity: 28
  },
  {
    title: "Chị Đào Chị Lý",
    description: "Truyện thiếu nhi",
    publication_year: 1975,
    author: Author.find_by!(name: "Hồ Biểu Chánh"),
    publisher: publishers[0],
    categories: [categories[9]], # Thiếu nhi
    total_quantity: 65,
    available_quantity: 38
  },
  {
    title: "Me Tư Hồng",
    description: "Truyện miền Nam",
    publication_year: 1960,
    author: Author.find_by!(name: "Nguyễn Ngọc Tiến"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 40,
    available_quantity: 17
  },
  {
    title: "Hư Ảo Một Cuộc Tình",
    description: "Tiểu thuyết tình yêu ảo mộng",
    publication_year: 1990,
    author: Author.find_by!(name: "Quỳnh Dao"),
    publisher: publishers[0],
    categories: [categories[0], categories[12]], # Tiểu thuyết, Lãng mạn
    total_quantity: 45,
    available_quantity: 20
  },
  {
    title: "Chuyện Con Mèo Và Con Chuột Bạn Thân Của Nó",
    description: "Truyện thiếu nhi hài hước",
    publication_year: 2008,
    author: Author.find_by!(name: "Luis Sepúlveda"),
    publisher: publishers[0],
    categories: [categories[9], categories[14]], # Thiếu nhi, Truyện cười
    total_quantity: 70,
    available_quantity: 42
  },
  {
    title: "Hoa Hồng Sa Mạc",
    description: "Tiểu thuyết tình yêu",
    publication_year: 1995,
    author: Author.find_by!(name: "Luis Sepúlveda"),
    publisher: publishers[0],
    categories: [categories[12]], # Lãng mạn
    total_quantity: 48,
    available_quantity: 24
  },
  {
    title: "Vỡ Bờ",
    description: "Tiểu thuyết nông thôn",
    publication_year: 1980,
    author: Author.find_by!(name: "Nguyễn Đình Thi"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 39,
    available_quantity: 16
  },
  {
    title: "Phía Núi Bên Kia",
    description: "Truyện ngắn miền núi",
    publication_year: 1970,
    author: Author.find_by!(name: "Xuân Sách"),
    publisher: publishers[0],
    categories: [categories[6]], # Truyện ngắn
    total_quantity: 36,
    available_quantity: 14
  },
  {
    title: "Út Teng",
    description: "Truyện thiếu nhi",
    publication_year: 1965,
    author: Author.find_by!(name: "Chu Lai"),
    publisher: publishers[0],
    categories: [categories[9]], # Thiếu nhi
    total_quantity: 55,
    available_quantity: 30
  },
  {
    title: "Đội Trinh Sát Và Con Chó Sara",
    description: "Truyện thiếu nhi chiến tranh",
    publication_year: 1970,
    author: Author.find_by!(name: "Trung Sỹ"),
    publisher: publishers[0],
    categories: [categories[9], categories[15]], # Thiếu nhi, Chiến tranh
    total_quantity: 62,
    available_quantity: 35
  },
  {
    title: "Thử Thách Và Tình Yêu",
    description: "Truyện thiếu nhi",
    publication_year: 1985,
    author: Author.find_by!(name: "Tessa Dare"),
    publisher: publishers[0],
    categories: [categories[9], categories[12]], # Thiếu nhi, Lãng mạn
    total_quantity: 58,
    available_quantity: 32
  },
  {
    title: "Thế Giới Kết Thúc Dịu Dàng Đến Thế",
    description: "Tiểu thuyết dystopia",
    publication_year: 2017,
    author: Author.find_by!(name: "Ichikawa Takuji"),
    publisher: publishers[0],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 50,
    available_quantity: 26
  },
  {
    title: "Giọt Máu Chung Tình",
    description: "Tiểu thuyết lịch sử",
    publication_year: 1990,
    author: Author.find_by!(name: "Tân Dân Tử"),
    publisher: publishers[0],
    categories: [categories[0], categories[4]], # Tiểu thuyết, Lịch sử
    total_quantity: 42,
    available_quantity: 18
  },
  {
    title: "Pachinko",
    description: "Tiểu thuyết sử thi gia đình người Hàn",
    publication_year: 2017,
    author: Author.find_by!(name: "Min Jin Lee"),
    publisher: publishers[0],
    categories: [categories[0], categories[4]], # Tiểu thuyết, Lịch sử
    total_quantity: 55,
    available_quantity: 30
  },
  {
    title: "Gió Lửa",
    description: "Tiểu thuyết tình yêu và chiến tranh",
    publication_year: 1980,
    author: Author.find_by!(name: "Nam Dao"),
    publisher: publishers[0],
    categories: [categories[0], categories[12], categories[15]], # Tiểu thuyết, Lãng mạn, Chiến tranh
    total_quantity: 45,
    available_quantity: 20
  },
  {
    title: "Những Câu Chuyện Hài Hước Nhất",
    description: "Tuyển tập các câu chuyện cười dân gian và hiện đại",
    publication_year: 2015,
    author: Author.find_by!(name: "Paul Jennings"),
    publisher: publishers[0],
    categories: [categories[14]], # Truyện cười
    total_quantity: 50,
    available_quantity: 25
  },
  {
    title: "Một Cuốn Sách Buồn Cười",
    description: "Góc nhìn hóm hỉnh về cuộc sống thường ngày",
    publication_year: 2018,
    author: Author.find_by!(name: "Lâm Thành Đạt"),
    publisher: publishers[0],
    categories: [categories[14]], # Truyện cười
    total_quantity: 30,
    available_quantity: 10
  },
  {
    title: "Vui Vẻ Không Quạu Nha",
    description: "Cuốn sách giúp bạn giải tỏa căng thẳng bằng sự hài hước",
    publication_year: 2020,
    author: Author.find_by!(name: "Lâm Thành Đạt"),
    publisher: publishers[0],
    categories: [categories[14]], # Truyện cười
    total_quantity: 100,
    available_quantity: 60
  },
  {
    title: "Xứ Ngáp Vặt",
    description: "Tập truyện ngắn trào phúng về xã hội",
    publication_year: 2005,
    author: Author.find_by!(name: "Aziz Nesin"),
    publisher: publishers[0],
    categories: [categories[14]], # Truyện ngắn
    total_quantity: 40,
    available_quantity: 15
  },
  {
    title: "Leo Lên và Tụt Xuống",
    description: "Tập truyện ngắn trào phúng về xã hội",
    publication_year: 2005,
    author: Author.find_by!(name: "Aziz Nesin"),
    publisher: publishers[0],
    categories: [categories[14]], # Truyện ngắn
    total_quantity: 40,
    available_quantity: 15
  },
  {
    title: "Chúa Ơi Chàng Muốn Lấy Con",
    description: "Tiểu thuyết lãng mạn hài hước",
    publication_year: 2012,
    author: Author.find_by!(name: "Agnes Abécassis"),
    publisher: publishers[0],
    categories: [categories[0], categories[14]], # Lãng mạn, Truyện cười
    total_quantity: 35,
    available_quantity: 20
  },
  {
    title: "Tiếu Lâm Việt Nam",
    description: "Tiểu thuyết lãng mạn hài hước",
    publication_year: 2012,
    author: Author.find_by!(name: "Tạ Đức Hiền"),
    publisher: publishers[0],
    categories: [categories[14]], # Lãng mạn, Truyện cười
    total_quantity: 35,
    available_quantity: 20
  },
  {
    title: "Mẹ Lưu Manh Con Thiên Tài",
    description: "Tiểu thuyết lãng mạn hài hước",
    publication_year: 2012,
    author: Author.find_by!(name: "Quỷ Miêu Tử"),
    publisher: publishers[0],
    categories: [categories[14]], #Truyện cười
    total_quantity: 35,
    available_quantity: 20
  },
  {
    title: "Trinh Quán Chính Yếu – Phép Trị Nước Của Đường Thái Tông",
    description: "Những bài học về trị quốc và quản lý nhân sự",
    publication_year: 2014,
    author: Author.find_by!(name: "Ngô Hách"),
    publisher: publishers[0],
    categories: [categories[4]], # Lịch sử - Chính trị
    total_quantity: 20,
    available_quantity: 5
  },
  {
    title: "30 Tháng 4 – Chuyện Những Người Tháo Chạy",
    description: "Ghi chép lịch sử về những ngày cuối tháng 4 năm 1975",
    publication_year: 2015,
    author: Author.find_by!(name: "Kim Lĩnh"),
    publisher: publishers[0],
    categories: [categories[4], categories[15]], # Lịch sử, Chiến tranh
    total_quantity: 30,
    available_quantity: 12
  },
  {
    title: "Khi Đồng Minh Tháo Chạy",
    description: "Phân tích về quan hệ ngoại giao và sự sụp đổ của một chính thể",
    publication_year: 2005,
    author: Author.find_by!(name: "Nguyễn Tiến Hưng"),
    publisher: publishers[0],
    categories: [categories[4]],
    total_quantity: 45,
    available_quantity: 18
  },
  {
    title: "Chân Trần Chí Thép",
    description: "Viết về sức mạnh và ý chí của con người Việt Nam trong chiến tranh",
    publication_year: 2010,
    author: Author.find_by!(name: "James G. Zumwalt"),
    publisher: publishers[0],
    categories: [categories[15], categories[4]],
    total_quantity: 50,
    available_quantity: 30
  },
  {
    title: "Đất Nước Đứng Lên",
    description: "Tiểu thuyết về cuộc kháng chiến của người Ba Na",
    publication_year: 1955,
    author: Author.find_by!(name: "Nguyên Ngọc"),
    publisher: publishers[0],
    categories: [categories[0], categories[15]], # Tiểu thuyết, Chiến tranh
    total_quantity: 60,
    available_quantity: 25
  },
  {
    title: "Lịch Sử Một Cuộc Chiến Tranh Bẩn Thỉu",
    description: "Tiểu thuyết về cuộc kháng chiến của người Ba Na",
    publication_year: 1955,
    author: Author.find_by!(name: "Trần Trọng Trung"),
    publisher: publishers[0],
    categories: [categories[15]], # Chiến tranh
    total_quantity: 60,
    available_quantity: 25
  },
  {
    title: "40 Năm Sau Vụ Thảm Sát Mỹ Lai",
    description: "Phân tích về vụ thảm sát Mỹ Lai",
    publication_year: 2008,
    author: Author.find_by!(name: "Phạm Hồng Tung"),
    publisher: publishers[0],
    categories: [categories[15]], # Chiến tranh
    total_quantity: 60,
    available_quantity: 25
  },
  {
    title: "Khi Đồng Minh Nhảy Vào",
    description: "Phân tích về vai trò của các nước đồng minh trong chiến tranh Việt Nam",
    publication_year: 2008,
    author: Author.find_by!(name: "Nguyễn Tiến Hưng"),
    publisher: publishers[0],
    categories: [categories[15]], # Chiến tranh
    total_quantity: 60,
    available_quantity: 25
  },
  {
    title: "Việt Sử Toàn Thư",
    description: "Bộ thông sử chi tiết về lịch sử Việt Nam",
    publication_year: 1960,
    author: Author.find_by!(name: "Phạm Văn Sơn"),
    publisher: publishers[0],
    categories: [categories[4]], # Lịch sử
    total_quantity: 20,
    available_quantity: 4
  },
  {
    title: "Hồn Sử Việt: Những Giai Thoại Và Truyền Thuyết Nổi Tiếng",
    description: "Tóm lược tiểu sử các nhân vật lịch sử nổi tiếng",
    publication_year: 2012,
    author: Author.find_by!(name: "Minh Châu"),
    publisher: publishers[0],
    categories: [categories[4]],
    total_quantity: 40,
    available_quantity: 22
  },
  {
    title: "284 Anh Hùng Hào Kiệt Của Việt Nam",
    description: "Tóm lược tiểu sử các nhân vật lịch sử nổi tiếng",
    publication_year: 2012,
    author: Author.find_by!(name: "Vũ Thanh Sơn"),
    publisher: publishers[0],
    categories: [categories[4]],
    total_quantity: 40,
    available_quantity: 22
  },
  {
    title: "Điện Biên Phủ – 170 Ngày Đêm Bị Vây Hãm",
    description: "Góc nhìn từ phía bên kia chiến tuyến về trận Điện Biên Phủ",
    publication_year: 1990,
    author: Author.find_by!(name: "Erwan Bergot"),
    publisher: publishers[0],
    categories: [categories[4], categories[15]],
    total_quantity: 25,
    available_quantity: 8
  },
  {
    title: "Hà Nội Cũ Nằm Đây",
    description: "Những khảo cứu về văn hóa và địa lý Hà Nội xưa",
    publication_year: 2010,
    author: Author.find_by!(name: "Ngọc Giao"),
    publisher: publishers[0],
    categories: [categories[11]], # Văn hóa
    total_quantity: 35,
    available_quantity: 15
  },
  {
    title: "Nguyễn Trãi Ở Đông Quan",
    description: "Tiểu thuyết lịch sử về danh nhân Nguyễn Trãi",
    publication_year: 1980,
    author: Author.find_by!(name: "Nguyễn Đình Thi"),
    publisher: publishers[0],
    categories: [categories[4]],
    total_quantity: 30,
    available_quantity: 10
  },
  {
    title: "Đội Cấn Khởi Nghĩa",
    description: "Tiểu thuyết lịch sử về danh nhân Nguyễn Trãi",
    publication_year: 1980,
    author: Author.find_by!(name: "Nguyễn Quỳnh"),
    publisher: publishers[0],
    categories: [categories[4]],
    total_quantity: 30,
    available_quantity: 10
  },
  {
    title: "Bên Bờ Thiên Mạc",
    description: "Truyện lịch sử về thời kỳ kháng chiến chống Nguyên Mông",
    publication_year: 1975,
    author: Author.find_by!(name: "Hà Ân"),
    publisher: publishers[0],
    categories: [categories[4]], #Lịch sử
    total_quantity: 70,
    available_quantity: 45
  },
  {
    title: "Vua Bà Triệu Ẩu",
    description: "Truyện lịch sử về thời kỳ Bà Triệu",
    publication_year: 1975,
    author: Author.find_by!(name: "Nguyễn Tử Siêu"),
    publisher: publishers[0],
    categories: [categories[4]], # Lịch sử
    total_quantity: 70,
    available_quantity: 45
  },
  {
    title: "Vua Hàm Nghi",
    description: "Truyện lịch sử về thời kỳ Bà Triệu",
    publication_year: 1975,
    author: Author.find_by!(name: "Phan Trần Chúc"),
    publisher: publishers[0],
    categories: [categories[4]], # Lịch sử
    total_quantity: 70,
    available_quantity: 45
  },
  {
    title: "Lịch Sử Của Sách",
    description: "Tìm hiểu về lịch sử phát triển của sách",
    publication_year: 2018,
    author: Author.find_by!(name: "James Raven"),
    publisher: publishers[0],
    categories: [categories[12],categories[11]], # Lịch sử, Văn hóa
    total_quantity: 30,
    available_quantity: 15
  },
  {
    title: "Xã Hội Việt Nam Từ Thế Kỷ XVII",
    description: "Nghiên cứu sâu về cấu trúc xã hội Việt Nam xưa",
    publication_year: 1950,
    author: Author.find_by!(name: "Nguyễn Trọng Phấn"),
    publisher: publishers[0],
    categories: [categories[4], categories[11]],
    total_quantity: 15,
    available_quantity: 3
  },
  {
    title: "Lịch Sử Thế Giới Hiện Đại (1917 – 1995)",
    description: "Nghiên cứu sâu về lịch sử thế giới hiện đại",
    publication_year: 1950,
    author: Author.find_by!(name: "Nguyễn Anh Thái"),
    publisher: publishers[0],
    categories: [categories[4]],
    total_quantity: 15,
    available_quantity: 3
  },
  {
    title: "Lịch Sử Nam Tiến Của Dân Tộc Việt Nam",
    description: "Nghiên cứu sâu về lịch sử nam tiến của dân tộc Việt Nam",
    publication_year: 1950,
    author: Author.find_by!(name: "Trúc Khê"),
    publisher: publishers[0],
    categories: [categories[4]],
    total_quantity: 15,
    available_quantity: 3
  },
  {
    title: "Quốc Sử Tạp Lục",
    description: "Nghiên cứu sâu về cấu trúc xã hội Việt Nam xưa",
    publication_year: 1950,
    author: Author.find_by!(name: "Nguyễn Thiệu Lâu"),
    publisher: publishers[0],
    categories: [categories[4]],
    total_quantity: 15,
    available_quantity: 3
  },
  {
    title: "Đại Thắng Mùa Xuân",
    description: "Hồi ký quân sự về chiến dịch năm 1975",
    publication_year: 1976,
    author: Author.find_by!(name: "Văn Tiến Dũng"),
    publisher: publishers[0],
    categories: [categories[15], categories[4]],
    total_quantity: 50,
    available_quantity: 20
  },

  {
    title: "Biệt Động Sài Gòn – Chuyện Bây Giờ Mới Kể",
    description: "Những câu chuyện chân thực về lực lượng biệt động Sài Gòn trong chiến tranh",
    publication_year: 2010,
    author: Author.find_by!(name: "Mã Thiện Đồng"),
    publisher: publishers[0],
    categories: [categories[15]], # Chiến tranh
    total_quantity: 40,
    available_quantity: 15
  },

  {
    title: "Việt Nam 1920-1945: Cách Mạng Và Phản Cách Mạng",
    description: "Phân tích các phong trào cách mạng và phản cách mạng tại Việt Nam",
    publication_year: 1996,
    author: Author.find_by!(name: "Ngô Văn"),
    publisher: publishers[1],
    categories: [categories[4]], # Lịch sử - Chính trị
    total_quantity: 35,
    available_quantity: 12
  },

  {
    title: "Cần Vương – Lê Dung Mật Kháng Trịnh",
    description: "Nghiên cứu về các phong trào kháng chiến lịch sử Việt Nam",
    publication_year: 1985,
    author: Author.find_by(name: "Phan Trần Chúc"),
    publisher: publishers[1],
    categories: [categories[4]],
    total_quantity: 30,
    available_quantity: 10
  },

  {
    title: "Bí Quyết Thành Công Của Các Doanh Nhân Thành Đạt",
    description: "Tổng hợp kinh nghiệm thành công từ các doanh nhân nổi tiếng",
    publication_year: 2015,
    author: Author.find_by!(name: "Nguyễn Thị Hồng Hà"), 
    publisher: publishers[2],
    categories: [categories[13]], # Kinh tế - Quản lý
    total_quantity: 50,
    available_quantity: 20
  },

  {
    title: "Hành Trình Biến Thương Hiệu Thành Biểu Tượng",
    description: "Chiến lược xây dựng thương hiệu mạnh và bền vững",
    publication_year: 2012,
    author: Author.find_by!(name: "Douglas B. Holt"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 45,
    available_quantity: 18
  },

  {
    title: "Xây Dựng Bộ Máy Lãnh Đạo Để Trường Tồn",
    description: "Cách xây dựng đội ngũ lãnh đạo hiệu quả trong doanh nghiệp",
    publication_year: 2010,
    author: Author.find_by!(name: "Eli Cohen"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 40,
    available_quantity: 15
  },

  {
    title: "Nhà Quản Lý Tài Giỏi",
    description: "Những nguyên tắc quản lý hiệu quả dành cho nhà lãnh đạo",
    publication_year: 2005,
    author: Author.find_by!(name: "Craig Nathanson"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },

  {
    title: "Doanh Nghiệp Việt Nam Xưa và Nay",
    description: "So sánh sự phát triển doanh nghiệp Việt Nam qua các thời kỳ",
    publication_year: 2018,
    author: Author.find_by!(name: "Lê Minh Quốc"),
    publisher: publishers[1],
    categories: [categories[13]],
    total_quantity: 35,
    available_quantity: 12
  },

  {
    title: "Sức Mạnh Của Những Con Số",
    description: "Ứng dụng dữ liệu và số liệu trong quản trị kinh doanh",
    publication_year: 2016,
    author: Author.find_by!(name: "Kashiwagi Yoshiki"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 45,
    available_quantity: 18
  },

  {
    title: "10 Điều Răn Về Những Thất Bại Trong Kinh Doanh",
    description: "Những bài học đắt giá từ các thất bại trong kinh doanh",
    publication_year: 2003,
    author: Author.find_by!(name: "Donald R. Keough"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 30,
    available_quantity: 10
  },

  {
    title: "Quản Trị Trong Thời Khủng Hoảng",
    description: "Chiến lược quản trị doanh nghiệp trong thời kỳ bất ổn",
    publication_year: 2009,
    author: Author.find_by!(name: "Peter F. Drucker"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 40,
    available_quantity: 15
  },

  {
    title: "Lợi Thế Cạnh Tranh",
    description: "Phân tích các yếu tố tạo nên lợi thế cạnh tranh bền vững",
    publication_year: 1985,
    author: Author.find_by!(name: "Michael E. Porter"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },
  {
    title: "Nhà Quản Trị Thành Công",
    description: "Bí quyết trở thành một nhà quản trị thành công",
    publication_year: 1999,
    author: Author.find_by!(name: "Peter F. Drucker"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },
  {
    title: "Kinh Doanh Dựa Trên Thành Viên",
    description: "Xây dựng doanh nghiệp dựa trên thành viên",
    publication_year: 2017,
    author: Author.find_by!(name: "John Warrillow"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },
  {
    title: "Kinh Doanh Dựa Trên Thành Viên",
    description: "Xây dựng doanh nghiệp dựa trên thành viên",
    publication_year: 2017,
    author: Author.find_by!(name: "John Warrillow"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },
  {
    title: "Cuộc Chơi Khởi Nghiệp",
    description: "Những bài học khởi nghiệp",
    publication_year: 2019,
    author: Author.find_by!(name: "William H. Draper III"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 45,
    available_quantity: 18
  },
  {
    title: "Kỹ Năng Ra Quyết Định",
    description: "Kỹ năng ra quyết định hiệu quả",
    publication_year: 2000,
    author: Author.find_by!(name: "Robert Heller"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 30,
    available_quantity: 10
  },
  {
    title: "Quản Lý Sự Thay Đổi",
    description: "Quản lý sự thay đổi hiệu quả",
    publication_year: 2005,
    author: Author.find_by!(name: "Robert Heller"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 30,
    available_quantity: 10
  },
  {
    title: "Chiến Lược Cạnh Tranh",
    description: "Chiến lược cạnh tranh hiệu quả",
    publication_year: 1980,
    author: Author.find_by!(name: "Michael E. Porter"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },
  {
    title: "Quản Lý Nhóm",
    description: "Quản lý nhóm hiệu quả",
    publication_year: 1980,
    author: Author.find_by!(name: "Robert Heller"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },
  {
    title: "Mở Rộng Doanh Nghiệp",
    description: "Mở rộng doanh nghiệp hiệu quả",
    publication_year: 1980,
    author: Author.find_by!(name: "Verne Harnish"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 45,
    available_quantity: 18
  },
  {
    title: "Lãnh Đạo Bằng Sự Khiêm Nhường",
    description: "Lãnh đạo bằng sự khiêm nhường hiệu quả",
    publication_year: 2014,
    author: Author.find_by!(name: "Jeffrey A. Krames"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },
  {
    title: "Kinh Doanh Trực Tuyến",
    description: "Kinh doanh trực tuyến hiệu quả",
    publication_year: 2021,
    author: Author.find_by!(name: "Nguyễn Đặng Tuấn Minh"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 50,
    available_quantity: 20
  },
  {
    title: "Cuộc Cách Mạng Một Cọng Rơm",
    description: "Triết lý nông nghiệp tự nhiên và bền vững",
    publication_year: 1975,
    author: Author.find_by!(name: "Masanobu Fukuoka"),
    publisher: publishers[2],
    categories: [categories[1]], # Khoa học
    total_quantity: 30,
    available_quantity: 10
  },

  {
    title: "Quản Trị Thương Hiệu",
    description: "Nguyên tắc xây dựng và quản lý thương hiệu",
    publication_year: 2011,
    author: Author.find_by!(name: "Patricia F. Nicolino"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 40,
    available_quantity: 15
  },

  {
    title: "Định Giá Thông Minh, Chinh Phục Người Dùng",
    description: "Chiến lược định giá dựa trên giá trị khách hàng",
    publication_year: 2017,
    author: Author.find_by!(name: "Madhavan Ramanujam"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 35,
    available_quantity: 12
  },
  {
    title: "Thế Giới Ảo, Thương Hiệu Thật",
    description: "Xây dựng thương hiệu trong môi trường số",
    publication_year: 2000,
    author: Author.find_by!(name: "Gary Vaynerchuk"),
    publisher: publishers[3],
    categories: [categories[13]],
    total_quantity: 40,
    available_quantity: 15
  },
  {
    title: "Động Lực Của Nhà Lãnh Đạo",
    description: "Phát triển năng lực lãnh đạo và tạo động lực cho đội nhóm",
    publication_year: 2014,
    author: Author.find_by!(name: "Patrick Lencioni"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 45,
    available_quantity: 18
  },
  {
    title: "Định Giá Dựa Trên Giá Trị",
    description: "Những nguyên lý cơ bản trong định giá và cách áp dụng vào thực tiễn",
    publication_year: 2012,
    author: Author.find_by!(name: "Tim Smith"),
    publisher: publishers[2],
    categories: [categories[13]],
    total_quantity: 45,
    available_quantity: 18
  },
  {
    title: "Định Luật Y Học",
    description: "Những nguyên lý cơ bản trong y học và cách áp dụng vào thực tiễn",
    publication_year: 2012,
    author: Author.find_by!(name: "Siddhartha Mukherjee"),
    publisher: publishers[0],
    categories: [categories[16]], # Y học - Sức khỏe
    total_quantity: 40,
    available_quantity: 15
  },

  {
    title: "Những Câu Chuyện Trung Hoa Xưa: Danh Y",
    description: "Tuyển tập những câu chuyện về các danh y nổi tiếng trong lịch sử Trung Hoa",
    publication_year: 2005,
    author: Author.find_by!(name: "Trình Ngọc Hoa"),
    publisher: publishers[1],
    categories: [
      categories[16], # Y học
      categories[4]   # Lịch sử - Chính trị
    ],
    total_quantity: 35,
    available_quantity: 12
  },

  {
    title: "Đường Là Hiểm Họa Của Toàn Nhân Loại",
    description: "Phân tích tác hại của đường đối với sức khỏe con người",
    publication_year: 2018,
    author: Author.find_by!(name: "William Dufty"),
    publisher: publishers[2],
    categories: [categories[16]],
    total_quantity: 50,
    available_quantity: 22
  },

  {
    title: "Ba Phút Sơ Cứu",
    description: "Hướng dẫn sơ cứu nhanh trong các tình huống khẩn cấp",
    publication_year: 2016,
    author: Author.find_by!(name: "Ngô Đức Hùng"),
    publisher: publishers[0],
    categories: [categories[16]],
    total_quantity: 45,
    available_quantity: 20
  },

  {
    title: "Món Ăn Chay Và Sức Khỏe",
    description: "Chế độ ăn chay và ảnh hưởng tích cực đến sức khỏe",
    publication_year: 2014,
    author: Author.find_by!(name: "Trần Anh Kiệt"),
    publisher: publishers[1],
    categories: [categories[16]],
    total_quantity: 30,
    available_quantity: 10
  },

  {
    title: "Hệ Miễn Dịch – Kiệt Tác Của Sự Sống",
    description: "Giải thích cách hệ miễn dịch hoạt động và bảo vệ cơ thể",
    publication_year: 2019,
    author: Author.find_by!(name: "Cao Bảo Anh"),
    publisher: publishers[2],
    categories: [categories[16]],
    total_quantity: 50,
    available_quantity: 25
  },

  {
    title: "Mật Mã Tiểu Đường",
    description: "Giải mã bệnh tiểu đường và cách kiểm soát hiệu quả",
    publication_year: 2017,
    author: Author.find_by!(name: "GS.TS. Bùi Thế Cường"),
    publisher: publishers[2],
    categories: [categories[16]],
    total_quantity: 40,
    available_quantity: 18
  },

  {
    title: "Tuổi Dậy Thì – Giới Tính, Tránh Thai, Bệnh Tật",
    description: "Cẩm nang giáo dục giới tính và sức khỏe tuổi dậy thì",
    publication_year: 2015,
    author: Author.find_by!(name: "BS. Tố Hoài"),
    publisher: publishers[0],
    categories: [categories[16]],
    total_quantity: 60,
    available_quantity: 30
  },

  {
    title: "Trẻ Em Tự Kỷ: Phương Thức Giáo Dục",
    description: "Các phương pháp giáo dục và hỗ trợ trẻ tự kỷ",
    publication_year: 2020,
    author: Author.find_by!(name: "GS. Nguyễn Văn Thành"),
    publisher: publishers[1],
    categories: [
      categories[16], # Y học
      categories[5]   # Tâm lý học
    ],
    total_quantity: 35,
    available_quantity: 14
  },
  {
    title: "Hôn Hoàng",
    description: "Câu chuyện tình yêu đầy day dứt giữa những con người lạc lối trong cuộc đời",
    publication_year: 2018,
    author: Author.find_by!(name: "Giá Oản Chúc"),
    publisher: publishers[0],
    categories: [
      categories[0],  # Tiểu thuyết
      categories[12]  # Lãng mạn
    ],
    total_quantity: 35,
    available_quantity: 12
  },

  {
    title: "Phùng Thanh",
    description: "Hành trình trưởng thành và những biến cố trong cuộc đời một con người",
    publication_year: 2016,
    author: Author.find_by!(name: "Giá Oản Chúc"),
    publisher: publishers[1],
    categories: [categories[0]], # Tiểu thuyết
    total_quantity: 30,
    available_quantity: 10
  },

  {
    title: "Phù Lam",
    description: "Một câu chuyện nhẹ nhàng về tình yêu và ký ức tuổi trẻ",
    publication_year: 2019,
    author: Author.find_by!(name: "Giá Oản Chúc"),
    publisher: publishers[2],
    categories: [categories[12]], # Lãng mạn
    total_quantity: 40,
    available_quantity: 15
  },

  {
    title: "Khóc Nữa Đi Sớm Mai",
    description: "Tập truyện buồn về tình yêu, mất mát và hy vọng",
    publication_year: 2020,
    author: Author.find_by!(name: "Mường Mán"),
    publisher: publishers[0],
    categories: [
      categories[0],  # Tiểu thuyết
      categories[12]  # Lãng mạn
    ],
    total_quantity: 45,
    available_quantity: 18
  }

].map do |book_data| 
  book = Book.create!( 
    title: book_data[:title], 
    description: book_data[:description], 
    publication_year: book_data[:publication_year], 
    author: book_data[:author], 
    publisher: book_data[:publisher], 
    total_quantity: book_data[:total_quantity], 
    available_quantity: book_data[:available_quantity], 
    borrow_count: book_data[:total_quantity] - book_data[:available_quantity] 
  ) 
  book_data[:categories].each { |cat| book.categories << cat } 
  book 
end

puts "⭐ Đang tạo đánh giá..."
reviews = [
  { user: users[0], book: books[0], score: 5, comment: "Sách rất hay, cảm xúc dạt dào" },
  { user: users[1], book: books[0], score: 4, comment: "Đọc mà nhớ lại tuổi thơ" },
  { user: users[2], book: books[1], score: 5, comment: "Phù thủy Harry Potter thật tuyệt vời" },
  { user: users[0], book: books[2], score: 5, comment: "Sách thay đổi cuộc đời tôi" },
  { user: users[3], book: books[3], score: 4, comment: "Câu chuyện ý nghĩa, đáng đọc" },
  { user: users[4], book: books[4], score: 3, comment: "Hơi buồn nhưng hay" },
  { user: users[1], book: books[5], score: 5, comment: "Đáng sợ nhưng rất thực tế" },
  { user: users[2], book: books[6], score: 5, comment: "Tuổi thơ của tôi với Dế Mèn" },
  { user: users[3], book: books[7], score: 4, comment: "Châm biếm sâu sắc" },
  { user: users[4], book: books[8], score: 5, comment: "Truyền cảm hứng sống mạnh mẽ" },
  { user: users[0], book: books[9], score: 4, comment: "Giọng văn hài hước, dễ đọc" },
  { user: users[1], book: books[10], score: 5, comment: "Lập trình viên nào cũng nên đọc" },
  { user: users[2], book: books[11], score: 5, comment: "Kinh điển về design pattern" },
  { user: users[3], book: books[12], score: 4, comment: "Tiểu thuyết mafia hay nhất" },
  { user: users[4], book: books[13], score: 5, comment: "Kiệt tác văn học thế giới" }
].map { |r| Review.create!(r) }

puts "⭐ Đang tạo yêu thích..."
favorites = []
(1..30).each do |user_id|
  liked_books = [
    ((user_id - 1) % 30) + 1,
    ((user_id + 4) % 30) + 1,
    ((user_id + 9) % 30) + 1
  ]

  liked_books.each do |book_id|
    favorites << {
      user_id: user_id,
      favorable_type: "Book",
      favorable_id: book_id,
      created_at: Time.now,
      updated_at: Time.now
    }
  end
end

Favorite.insert_all(favorites)
puts "📋 Đang tạo yêu cầu mượn sách..."

# Generate 200 borrow requests with various statuses and realistic dates
200.times do |i|
  user_id = users.sample.id
  request_date = rand(60.days).seconds.ago
  start_date = request_date.to_date + rand(1..7).days
  end_date = start_date + rand(7..30).days

  # Determine status based on dates and randomization
  status = if end_date < Date.current && rand < 0.1
             [:overdue, :expired].sample
           elsif start_date < Date.current && rand < 0.3
             [:borrowed, :returned].sample
           elsif request_date.to_date < Date.current && rand < 0.2
             [:approved, :rejected].sample
           else
             :pending
           end

  # Set dates based on status with proper validation
  approved_date = nil
  actual_borrow_date = nil
  actual_return_date = nil

  if status.in?([:approved, :borrowed, :returned, :overdue])
    # Approved date must be after request date and before start date
    approved_date = [request_date.to_date + rand(1..3).days, start_date - 1.day].min
  end

  if status.in?([:borrowed, :returned, :overdue])
    # Actual borrow date must be after start date and after approved date
    min_borrow_date = [start_date, approved_date].compact.max
    actual_borrow_date = min_borrow_date + rand(0..2).days

    # Ensure actual_borrow_date is not after end_date for validation
    actual_borrow_date = [actual_borrow_date, end_date - 1.day].min
  end

  if status == :returned
    # Actual return date must be after actual_borrow_date and not in the future
    min_return_date = actual_borrow_date + 1.day
    max_return_date = [end_date + rand(1..10).days, Date.current - 1.day].min

    # Only set return date if we have a valid range
    if min_return_date <= max_return_date
      actual_return_date = min_return_date + rand(0..(max_return_date - min_return_date).to_i).days
    else
      # If we can't set a valid return date, change status to borrowed
      status = :borrowed
      actual_return_date = nil
    end
  end

  # Admin assignments
  admin_id = status.in?([:approved, :borrowed, :returned, :overdue]) ? admin.id : nil
  rejected_admin_id = status == :rejected ? admin.id : nil

  begin
    borrow_request = BorrowRequest.create!(
  
      user_id: user_id,
      request_date: request_date,
      status: status,
      start_date: start_date,
      end_date: end_date,
      actual_return_date: actual_return_date,
      admin_note: status == :rejected ? "Không đủ điều kiện mượn sách" : nil,
      approved_by_admin_id: admin_id,
      rejected_by_admin_id: rejected_admin_id,
      returned_by_admin_id: status == :returned ? admin.id : nil,
      borrowed_by_admin_id: status.in?([:borrowed, :returned, :overdue]) ? admin.id : nil,
      approved_date: approved_date,
      actual_borrow_date: actual_borrow_date
    )

    # Create 1-3 borrow request items per request
    num_books = rand(1..3)
    selected_books = books.sample(num_books)

    selected_books.each do |book|
      BorrowRequestItem.create!(
        borrow_request_id: borrow_request.id,
        book_id: book.id,
        quantity: 1
      )
    end

    # Update book quantities for borrowed/overdue books
    if status.in?([:borrowed, :overdue])
      selected_books.each do |book|
        book.update!(
          available_quantity: [book.available_quantity - 1, 0].max,
          borrow_count: book.borrow_count + 1
        )
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "⚠️  Skipping invalid borrow request #{i + 1}: #{e.message}"
    next
  end
end

puts "🎉 Hoàn thành tạo dữ liệu mẫu!"
puts "📊 Thống kê:"
puts "- 📚 Sách: #{Book.count}"
puts "- ✍️ Tác giả: #{Author.count}"
puts "- 🏢 Nhà xuất bản: #{Publisher.count}"
puts "- 🏷️ Thể loại: #{Category.count}"
puts "- 👥 Người dùng: #{User.count}"
puts "- ⭐ Đánh giá: #{Review.count}"
puts "- 📋 Yêu cầu mượn sách: #{BorrowRequest.count}"
puts "- 📖 Chi tiết mượn sách: #{BorrowRequestItem.count}"

# Display borrow request statistics
puts "\n📋 Thống kê yêu cầu mượn sách:"
BorrowRequest.statuses.each do |status, _|
  count = BorrowRequest.where(status: status).count
  puts "- #{status.humanize}: #{count}"
end

puts "\n🔑 Thông tin đăng nhập:"
puts "- Admin: admin@thuvien.com / 123456"
puts "- Người dùng thường: nguyenvana@example.com / 123456, tranthib@example.com / 123456,..."

puts "\n📌 Lưu ý:"
puts "1. Để thêm ảnh bìa, đặt file ảnh vào thư mục lib/assets/book_covers/ với tên book_[id].jpg"
puts "2. Chạy rails db:seed để cập nhật ảnh bìa sau khi thêm file ảnh"
