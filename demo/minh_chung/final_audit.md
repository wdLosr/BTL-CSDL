# Kết quả kiểm tra cuối

Kiểm tra trên bản tích hợp PR #9 với JDK 21, Maven Wrapper và MySQL 8.0.46 mới. Kiểm tra web qua HTTP và đối chiếu SQL. Kiểm tra bản in bằng Microsoft Excel.

| Tiêu chí | Trạng thái | Bằng chứng |
| --- | --- | --- |
| 1. Đặc tả | Đạt trong phạm vi demo | Đặc tả Nam mô tả dữ liệu, liên kết và giới hạn. Phân tích ban đầu rộng hơn mô hình hiện tại. |
| 2. ERD | Đạt trong phạm vi demo | ERD mô tả ghi danh, lần thu, bài kiểm tra, chuyên biệt hóa nhân sự. Báo cáo giải thích ánh xạ sang khóa ghép. |
| 3. Mô hình quan hệ | Đạt | DDL 13 bảng và bốn view nạp được. Kiểm tra PK, FK, UNIQUE, NOT NULL và CHECK từ chối dữ liệu lỗi. |
| 4. Chuẩn hóa 3NF | Đạt theo phụ thuộc đã đặc tả | Hồ sơ Quang và bảng tổng hợp trong báo cáo ghi khóa ứng viên và phụ thuộc hàm của 13 bảng. |
| 5. Hai form | Đạt các ca kỹ thuật | Ghi thành công, từ chối đăng ký trùng, đầy, đóng, hạn quá khứ. Xác nhận lại dùng đúng DK004. Từ chối thu 0, âm, vượt dư, trùng mã và thu đăng ký hủy. |
| 6. Tìm kiếm | Đạt | Mã, tên có dấu, chuỗi một phần, lớp, bộ lọc kết hợp, ca rỗng, đăng ký hủy và số dư sau hai lần thu. |
| 7. Hai báo cáo | Đạt các ca kỹ thuật | Hai trang và hai tệp Excel cùng dữ liệu. Thu theo ngày và lớp có hai phiếu, tổng 1.000.000 đồng. Kết quả BKT01 có 3 học viên, 2 điểm đã nhập, 1 chưa nhập, trung bình 4,00. Mỗi báo cáo in trên một trang ngang trong Excel. |
| 8. Tài liệu và demo | Đạt các đầu ra | Word 16 trang, mục lục, bảy mục, hai sơ đồ, SQL và kịch bản tái lập. |

## Kết quả kiểm thử bổ sung

- PASS Maven package, hai bài kiểm thử báo cáo.
- PASS `03_checks.sql` và gọi bốn thủ tục nghiệp vụ. Lệnh DELETE trong giao dịch thử được hoàn tác.
- PASS Đăng ký và thu học phí đọc cùng CSDL với tìm kiếm và báo cáo. Số dư DKQA lần lượt 2.000.000, 1.500.000 và 1.000.000 đồng.
- PASS Lỗi cưỡng bức khi cập nhật đăng ký sau INSERT khiến phiếu thu được rollback. Hai yêu cầu đồng thời, mỗi yêu cầu 700.000 đồng khi còn dư 1.000.000 đồng, chỉ ghi một phiếu. Tổng sau thử là 1.700.000 đồng.
- PASS Từ chối điểm 11/10 tại ứng dụng. Báo cáo thu kỳ rỗng hiển thị thông báo phù hợp.
- NOT RUN Thao tác giao diện bằng trình duyệt và cạnh tranh đăng ký cho chỗ cuối. Schema chỉ lưu lịch dạng chuỗi nên không có đối tượng buổi/phòng để kiểm tra trùng lịch.

## Điểm cần nhóm chốt

- Mã hiện hành có thể đặt `DaHoanThanh` khi thu đủ và vẫn đếm trạng thái này vào sĩ số. Bản phân tích gắn hoàn thành với kết thúc lớp và đếm đăng ký đã xác nhận. View sĩ số hiện chỉ đếm `DaXacNhan`, khác cách tính trong form đối với lớp có đăng ký đã hoàn thành.
- Báo cáo điểm lấy lần thi mới nhất và xét trạng thái đăng ký hiện tại. Bản phân tích yêu cầu xét hiệu lực tại ngày đánh giá. Cần thống nhất quy tắc và dữ liệu lịch sử trước khi coi hai cách là tương đương.
- Bản demo đáp ứng luồng bảo vệ. Mức độ đáp ứng toàn bộ đặc tả ban đầu còn phụ thuộc vào việc xác nhận các điểm trên.
