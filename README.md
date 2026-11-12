# Quản lý trung tâm tiếng Anh — bản giao diện

Ứng dụng Spring Boot và Thymeleaf cho bài tập lớn Cơ sở dữ liệu. Mỗi form chỉ kiểm tra dữ liệu gửi lên và trả về trang cùng thông báo; ứng dụng không kết nối CSDL, không tạo dữ liệu mẫu và không lưu form ở máy chủ, file hoặc trình duyệt.

## Chạy ứng dụng

Yêu cầu Java 17 trở lên. Dự án đã có Maven Wrapper, không cần thêm Maven vào PATH.

Trong File Explorer, mở thư mục english-center-web và nhấp đúp vào file run.cmd để chạy. Không mở file rồi dán các dòng @echo off, cd, call hoặc if vào PowerShell. Nếu đang ở PowerShell trong thư mục này, chỉ gõ đúng MỘT dòng sau rồi nhấn Enter:

.\run.cmd

Chỉ chạy tên file; không dán nội dung bên trong file. Dòng lệnh không có dấu nháy hoặc dấu backtick ở đầu hay cuối. File run.cmd chạy JAR đã biên dịch; nó không tự đóng gói lại khi ứng dụng đang mở. Khi hiện "Tomcat started on port 8080", mở http://localhost:8080/. Giữ cửa sổ đang chạy; nhấn Ctrl+C để dừng. Khi cần biên dịch lại sau khi sửa mã nguồn, dừng ứng dụng bằng Ctrl+C, chạy .\mvnw.cmd -q clean package rồi chạy lại .\run.cmd. Lệnh Maven có thể in cảnh báo tương thích Java; nếu không có dòng ERROR và file JAR được tạo thì có thể chạy.
## Màn hình

- Danh mục: Học viên, Khóa học, Lớp học, Cơ sở, Nhân sự, Giáo viên, Nhân viên, Đề thi, Bài kiểm tra.
- Nghiệp vụ: Phiếu thanh toán, Đăng ký lớp, Phân công giảng dạy, Nhập kết quả làm bài.
- Báo cáo: Thu học phí theo kỳ, Kết quả đánh giá theo lớp.

Các trang bắt đầu với form trống. Lỗi định dạng như email có hai dấu @ được báo ngay khi nhập; trường bắt buộc để trống được báo khi rời ô. Nút **Lưu** trên form nhập liệu gửi dữ liệu đến Java để kiểm tra lại, giữ dữ liệu đã nhập và báo lỗi ngay dưới trường sai. Bản demo chưa lưu dữ liệu; khi kết nối CSDL, nút này sẽ lưu bản ghi để các thực thể khác liên kết. Hai trang báo cáo dùng nút **Xem báo cáo**. Các bảng báo cáo luôn rỗng trong bản demo. Nút **Xuất Excel** chỉ được bật khi giai đoạn sau có dữ liệu.

## Đối chiếu EER và quyết định giao diện

`EER.drawio` có các thực thể Học viên, Khóa học, Lớp học, Cơ sở, Nhân sự với ISA Giáo viên/Nhân viên, Đề thi, Bài kiểm tra và Phiếu thanh toán. Các quan hệ gốc gồm đăng ký học, lớp thuộc khóa học, lớp tại cơ sở, giảng dạy, làm bài và bài kiểm tra dùng đề thi. Form lớp dùng mã khóa và mã cơ sở để biểu diễn liên kết; form giáo viên và nhân viên dùng mã nhân sự kế thừa.

`Mã đăng ký` trên phiếu thanh toán và kết quả làm bài, cùng `Khoản phải thu` và `Hạn nộp` trên form đăng ký, là các trường bổ sung để nối được luồng đăng ký, thu học phí và báo cáo. Phiếu thanh toán và kết quả làm bài được liên kết về đăng ký trong bản giao diện. Không có trang Học phí riêng. `Thang điểm áp dụng` là ô hỗ trợ kiểm tra điểm ở bản demo; sau khi có CSDL sẽ lấy thang điểm từ Bài kiểm tra. Thời lượng Khóa học được thêm theo yêu cầu giao diện; file EER gốc có giá khóa học nhưng chưa có trường thời lượng của khóa.

Danh sách lựa chọn tối thiểu vì EER chưa định nghĩa tập giá trị: trạng thái lớp `Dự kiến / Đang học / Kết thúc`; trạng thái đăng ký `Chờ xác nhận / Đang học / Đã hủy`; loại đề và bài kiểm tra `Đầu vào / Giữa khóa / Cuối khóa`; phương thức thanh toán `Tiền mặt / Chuyển khoản`; trạng thái phiếu `Thành công / Thất bại / Đã hủy`; vai trò giảng dạy `Chính / Trợ giảng`.

## Kiểm tra hiện có và giai đoạn CSDL

Máy chủ kiểm tra trường bắt buộc sau khi cắt khoảng trắng; ký tự mã; email; số điện thoại dạng chuỗi bắt đầu bằng `0`, dài 10–11 chữ số; ngày sinh, ngày giờ thanh toán; số nguyên dương; số tiền; hạn nộp so với ngày đăng ký; khoảng ngày báo cáo; điểm không âm và điểm không vượt thang khi có ô thang điểm. Điểm `0` và điểm chưa nhập đều hợp lệ.

Khi kết nối CSDL cần kiểm tra sự tồn tại của các mã liên kết, trùng đăng ký, sĩ số lớp, phân công hợp lệ, biên nhận trùng, thu vượt khoản phải thu, điểm trong thang điểm lưu thực tế và các điều kiện phụ thuộc trạng thái. Hai báo cáo khi đó mới tổng hợp dữ liệu thực và bật xuất Excel.
