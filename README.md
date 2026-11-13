# Quản lý trung tâm tiếng Anh

Ứng dụng Java 17, Spring Boot MVC, Thymeleaf, Spring JDBC và MySQL cho bài tập lớn Cơ sở dữ liệu. Form **Lưu** ghi dữ liệu thật; hai báo cáo đọc dữ liệu thật và xuất `.xlsx`. Ứng dụng không tự tạo, xóa, cập nhật cấu trúc hay nạp lại dữ liệu khi khởi động.

## Chuẩn bị MySQL

Database hiện dùng là `english_center_db` theo `sql/01_schema.sql`. Cần MySQL 8.0.16 trở lên, schema và các view đã được cài sẵn. Báo cáo thu cần `v_bao_cao_thu_hoc_phi`. Script `01_schema.sql` và `02_seed.sql` có lệnh xóa/tạo lại dữ liệu; **không chạy trên database đang sử dụng** chỉ để khởi động web. Các script `11_dang_ky.sql`–`15_bao_cao_ket_qua.sql` là thủ tục/truy vấn nghiệp vụ để đối chiếu và kiểm thử; web thực hiện các giao dịch tương ứng bằng Spring JDBC, không tự chạy script.

Kiểm tra kết nối bằng MySQL Workbench hoặc lệnh sau (thay tài khoản của bạn):

```powershell
mysql -h 127.0.0.1 -P 3306 -u root -p -D english_center_db -e "SELECT COUNT(*) FROM HOC_VIEN; SELECT COUNT(*) FROM v_bao_cao_thu_hoc_phi;"
```

## Cấu hình và chạy bằng PowerShell

Dùng biến môi trường cho **cửa sổ PowerShell hiện tại**. Thay mật khẩu thật tại máy của bạn; không ghi vào Git hoặc `application.properties`:

```powershell
cd 'C:\Users\chaut\Documents\Trung tâm tiếng anh\english-center-web'
$env:DB_URL = 'jdbc:mysql://127.0.0.1:3306/english_center_db?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Bangkok'
$env:DB_USERNAME = 'root'
$env:DB_PASSWORD = 'huy050506'
.\mvnw.cmd clean package
.\run.cmd
```

Nếu MySQL ở cổng khác, sửa `3306` trong `DB_URL`. `run.cmd` chạy JAR đã build, nên sau khi sửa code hãy dừng bằng `Ctrl+C`, build lại rồi chạy tiếp. Có thể dùng `.\mvnw.cmd spring-boot:run` sau khi đặt biến môi trường. Mở [http://localhost:8080/](http://localhost:8080/). Không dán dấu backtick Markdown hoặc nội dung bên trong `run.cmd` vào PowerShell. Spring không tự đọc file `.env`.

Mặc định `DB_URL` trỏ `localhost:3306/english_center_db`, `DB_USERNAME=root`, `DB_PASSWORD` trống; nên đặt cả ba biến để tránh nhầm database. Ứng dụng có thể khởi động khi MySQL chưa sẵn sàng, nhưng các trang cần danh sách và thao tác dữ liệu sẽ báo lỗi kết nối.

## Màn hình và trình tự demo

Từ trang chủ, mỗi nút mở trực tiếp một trang. Các URL nhập liệu:

- Danh mục: `/m/hoc-vien`, `/m/khoa-hoc`, `/m/co-so`, `/m/lop-hoc`, `/m/nhan-su`, `/m/giao-vien`, `/m/nhan-vien`, `/m/de-thi`, `/m/bai-kiem-tra`.
- Nghiệp vụ: `/m/dang-ky-lop`, `/m/phieu-thanh-toan`, `/m/phan-cong`, `/m/ket-qua`.
- Báo cáo: `/m/thu-hoc-phi`, `/m/danh-gia`.

Trình tự dễ trình bày: tạo khóa học, cơ sở và học viên → tạo lớp đang nhận đăng ký với **Học phí lớp** → đăng ký học viên → xem khoản phải thu và số chỗ → thu học phí một hoặc nhiều phiếu → xem báo cáo thu theo ngày/lớp → tạo đề và bài kiểm tra thuộc lớp → nhập kết quả → xem báo cáo kết quả. Nhân sự và giáo viên/nhân viên dùng khóa `MaNS` chung; có thể tạo trước để phân công. Danh sách chọn học viên, lớp, nhân sự, giáo viên, đề và đăng ký đều lấy từ MySQL.

Sau khi lưu, ứng dụng chuyển về form và hiển thị mã vừa lưu; phiếu thu được đọc lại từ MySQL để xác nhận. Khi nhập sai, dữ liệu đã gõ được giữ lại và lỗi hiện dưới trường. Nút **Xuất Excel** chỉ bật khi báo cáo có dòng; file gồm cùng bộ lọc, chi tiết và tổng như trên màn hình. Báo cáo phân biệt trạng thái chưa chọn điều kiện với “Chưa có dữ liệu”.

## Quy tắc nghiệp vụ hiện tại

- Lớp mới chỉ nhận đăng ký khi `TrangThai = DangNhanDangKy`; hồ sơ đã hủy có thể xác nhận lại khi lớp `DangNhanDangKy` hoặc `DangHoc` và còn chỗ. Schema có khóa UNIQUE cho cặp học viên–lớp. Nếu hồ sơ cũ có bất kỳ phiếu nào, giữ mã đăng ký, ngày đăng ký, khoản phải thu và lịch sử phiếu; chỉ cập nhật hạn nộp và trạng thái sau đối soát.
- Học phí đăng ký được chốt từ `LOP_HOC.HocPhi` phía máy chủ. Sĩ số đếm cả `DaXacNhan` và `DaHoanThanh`; đóng đủ không giải phóng chỗ. Đăng ký khóa dòng lớp bằng `FOR UPDATE`; thu phí khóa dòng đăng ký, tính lại số dư và chỉ cộng phiếu `ThanhCong` trong cùng giao dịch. Giao dịch ứng dụng dùng `READ_COMMITTED` để thấy bản ghi vừa được giao dịch khác xác nhận.
- Phiếu do form tạo luôn ở trạng thái `ThanhCong`, số tiền dương và không vượt số dư. Khi thu đủ, `DANG_KY.TrangThaiDK` thành `DaHoanThanh`. Gửi lặp cùng mã phiếu không tạo thêm phiếu. `MaDK` trên form kết quả chỉ dùng để tìm `MaHV` và đối chiếu lớp; `LAM_BAI` lưu khóa `(MaHV, MaBKT, LanThi)`. Thang điểm lấy từ `BAI_KIEM_TRA` trong MySQL.
- Báo cáo thu lọc từ đầu ngày bắt đầu đến **trước đầu ngày kế tiếp** của ngày kết thúc, chỉ lấy phiếu `ThanhCong` qua view. Báo cáo kết quả hiển thị **lần thi có `LanThi` lớn nhất** của mỗi học viên đủ điều kiện trong lớp. Nếu lần mới nhất chưa có điểm, hiển thị “Chưa nhập”; điểm `0` vẫn được tính vào trung bình. Không áp ngưỡng đạt/rớt vì schema chưa quy định.
- `BAI_KIEM_TRA.MaLop` bắt buộc theo schema thực tế, nên form bài kiểm tra luôn chọn lớp. Enum giao diện dùng đúng mã trong `CHECK`: lớp `ChuanBi/DangNhanDangKy/DangHoc/DaKetThuc`, đăng ký `DaXacNhan/DaHuy/DaHoanThanh`, phiếu `ThanhCong/DaHuy`, phương thức `TienMat/ChuyenKhoan/The/ViDienTu`, bài `GiuaKy/CuoiKy/ChuyenCan/DinhKy`. Loại đề dùng nhóm tối thiểu `TracNghiem/TuLuan/KetHop/VanDap`; cột hiện chưa có `CHECK`.

Không có module tìm kiếm của Lộc, CRUD tổng quát, đăng nhập hay phân quyền. Nếu thêm thao tác hủy/chỉnh sửa phiếu hoặc đăng ký, cần giữ cùng thứ tự khóa và cập nhật công nợ/sĩ số.

## Lỗi thường gặp

| Hiện tượng | Cách kiểm tra |
|---|---|
| `mvn` không được nhận diện | Dùng `.\mvnw.cmd`, không cần cài Maven toàn cục. |
| Không kết nối được MySQL | Kiểm tra máy chủ, cổng trong `DB_URL`, tên database, user/password và quyền SELECT/INSERT/UPDATE. |
| `Access denied` | Đặt lại `$env:DB_USERNAME`/`$env:DB_PASSWORD` trong đúng cửa sổ chạy web. |
| `Unknown database` hoặc thiếu view/bảng | Kiểm tra đúng `english_center_db` và schema/view đã cài; không chạy script DROP trên dữ liệu thật. |
| Cổng 8080 bận hoặc JAR không build được | Dừng tiến trình web cũ bằng `Ctrl+C`, build lại, rồi chạy lại. |

Các test ghi dữ liệu phải dùng **database thử nghiệm riêng**. Không dùng `02_seed.sql` để đặt lại database đang phục vụ nhóm.
