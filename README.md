# BTL-CSDL
Hệ thống quản lý trung tâm tiếng Anh


Bài tập lớn môn Cơ sở dữ liệu của Nhóm 2 PTIT. Mục tiêu là phân tích, thiết kế và cài đặt CSDL, sau đó minh họa hai form nhập liệu, một màn hình tìm kiếm và hai báo cáo có thể xuất Excel.

**Công nghệ:** Java 17+, Spring Boot MVC, Thymeleaf, Spring JDBC, MySQL 8.0 và Apache POI.

## Phân công và đường dẫn

| Thành viên | Trách nhiệm | Nơi bàn giao |
| --- | --- | --- |
| Lộc | Tìm kiếm, tích hợp và báo cáo cuối | SearchController.java, search.html, sql/13_tim_kiem.sql, demo/kich_ban/, final-report/Bao_cao_BTL_Nhom_2.docx, README.md |
| Nam | Phân tích yêu cầu và ERD | design/01_yeu_cau_du_lieu.docx, design/02_erd.drawio. Xuất design/02_erd.png sau khi chốt sơ đồ. |
| Quang | Mô hình quan hệ, 3NF, CSDL và dữ liệu mẫu | design/03_data_diagram/, design/03_tu_dien_du_lieu.docx, design/04_kiem_tra_3NF.docx, sql/01_schema.sql, sql/02_seed.sql, sql/03_checks.sql, tests/database/ |
| Khanh | Form đăng ký lớp và thu học phí | app/dang-ky/, app/thu-hoc-phi/, sql/11_dang_ky.sql, sql/12_thu_hoc_phi.sql, tests/forms/ |
| Huy | Báo cáo thu học phí và kết quả lớp | app/bao-cao/, sql/14_bao_cao_thu.sql, sql/15_bao_cao_ket_qua.sql, reports/bao_cao_thu_hoc_phi/, reports/bao_cao_ket_qua_lop/, tests/reports/ |

Tài liệu thiết kế nằm trong `design/`, truy vấn và script trong `sql/`, mã ứng dụng trong `src/`, ca thử trong `tests/`, tệp báo cáo xuất trong `reports/`, kịch bản và minh chứng trong `demo/`, báo cáo BTL trong `final-report/`. Tệp `.gitkeep` giữ chỗ cho thư mục chưa có nội dung.

## Cách làm việc

1. Clone repository và tạo một nhánh cho nhiệm vụ. Ví dụ của Nam:

   ~~~powershell
   git clone https://github.com/wdLosr/BTL-CSDL.git
   cd BTL-CSDL
   git switch -c feature/nam-erd
   ~~~

   Nhánh gợi ý cho các việc khác gồm `feature/quang-schema`, `feature/khanh-dang-ky`, `feature/loc-search` và `feature/huy-reports`.

2. Sửa tệp thuộc nhiệm vụ. Chạy `git status` và `git diff` để xem thay đổi. Ví dụ bàn giao ERD:

   ~~~powershell
   git add -- design/02_erd.drawio
   git commit -m "Add ERD for English center"
   git push -u origin feature/nam-erd
   ~~~

3. Trên GitHub, mở Pull Request từ nhánh nhiệm vụ vào `main`. Ghi mã công việc, tệp bàn giao, cách kiểm tra và kết quả thử. Lộc hoặc người được giao sẽ rà soát. Nếu cần sửa, commit và push tiếp vào cùng nhánh.
4. Merge sau khi nghiệm thu. Mọi thay đổi trong quá trình làm bài đi qua Pull Request. Tránh sửa trực tiếp `main`.

## Mốc bàn giao

Nam giao ERD đã duyệt cho Quang. Quang giao schema và dữ liệu mẫu cho Lộc, Khanh, Huy để nối và kiểm thử các chức năng. Khanh cung cấp mã đăng ký và mã biên nhận demo để Lộc và Huy đối chiếu. Lộc tổng hợp báo cáo và minh chứng. Dùng dữ liệu mẫu không chứa thông tin cá nhân thật. Giữ thông tin kết nối có bí mật trong cấu hình cục bộ.

## Chạy ứng dụng và demo

Ứng dụng tích hợp dùng Java 17 trở lên, Spring Boot và MySQL 8.0.16 trở lên.
Mã nguồn Maven ở thư mục `src/`. Các thư mục `app/` là đường dẫn bàn giao trong bản phân công.
Hai form dùng `FormController`, `CenterService` và `CenterRepository`.
Hai báo cáo dùng `ReportService`, `ReportController` và `ExcelService`.
Các script SQL 11, 12, 14 và 15 là thủ tục tương ứng để đối chiếu.
Ứng dụng dùng Spring JDBC và không tự chạy các thủ tục này. Trang tìm kiếm tại `/tim-kiem` dùng trực tiếp truy vấn có tham số trong `sql/13_tim_kiem.sql`, được Maven đóng gói vào JAR.

Trên MySQL dành riêng cho demo, chạy `sql/01_schema.sql` rồi `sql/02_seed.sql`.
Hai script đặt lại bảng và dữ liệu trong `english_center_db`. Nếu đã có dữ liệu cần giữ, dùng bản sao script với tên database demo riêng và cấu hình URL tương ứng.

Trong PowerShell ở gốc repository:

~~~powershell
$env:DB_URL = 'jdbc:mysql://127.0.0.1:3306/english_center_db?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Bangkok'
$env:DB_USERNAME = Read-Host 'Tai khoan MySQL'
$password = Read-Host 'Mat khau MySQL' -AsSecureString
$env:DB_PASSWORD = [System.Net.NetworkCredential]::new('', $password).Password
.\mvnw.cmd clean package
.\run.cmd
~~~

Mở [trang demo](http://localhost:8080/) để xác nhận đăng ký, ghi phiếu thu, xem báo cáo theo kỳ và xem kết quả theo lớp. Hai báo cáo cho tải Excel khi có dữ liệu. Chạy `.\mvnw.cmd test` để kiểm tra logic báo cáo và tệp xuất.

[Kịch bản demo đầy đủ](demo/kich_ban/README.md) và [biên bản kiểm thử tích hợp](demo/minh_chung/kiem_thu_tich_hop.md).
