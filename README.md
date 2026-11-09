# Hệ thống quản lý trung tâm tiếng Anh

Bài tập lớn Cơ sở dữ liệu của Nhóm 2 PTIT. Đây là bộ khung bàn giao. Mỗi thành viên hoàn thiện phần được giao trên nhánh riêng rồi mở Pull Request về nhánh mặc định.

| Thành viên | Nhánh gợi ý | Đường dẫn làm việc |
| --- | --- | --- |
| Lộc | feature/loc-search | app/tim-kiem, sql/13_tim_kiem.sql, demo/kich_ban.md, Bao_cao_BTL_Nhom_2.docx |
| Nam | feature/nam-analysis-erd | design/01_yeu_cau_du_lieu.docx, design/02_erd.drawio, design/02_erd.png |
| Quang | feature/quang-database | design/03_data_diagram.drawio, design/03_tu_dien_du_lieu.docx, design/04_kiem_tra_3NF.docx, sql/01_schema.sql đến sql/03_checks.sql |
| Khanh | feature/khanh-forms | app/dang-ky, app/thu-hoc-phi, sql/11_dang_ky.sql, sql/12_thu_hoc_phi.sql |
| Huy | feature/huy-reports | app/bao-cao, sql/14_bao_cao_thu.sql, sql/15_bao_cao_ket_qua.sql |

## Quy ước bàn giao

- Nhận ERD đã duyệt từ Nam trước khi Quang chốt mô hình quan hệ và 3NF.
- Có thể dựng khung giao diện và mẫu báo cáo trong khi thiết kế CSDL. Kết nối sau khi nhận schema Q3. Nghiệm thu riêng bằng dữ liệu Q4. Dùng mã đăng ký và biên nhận từ Khanh để kiểm tra liên module.
- Lưu ca kiểm thử tại tests. Mỗi Pull Request nêu mã công việc, tệp bàn giao và ca đã chạy.
- Các tệp SQL hiện là mẫu có chú thích. Lộc cập nhật yêu cầu cài đặt và lệnh chạy tại đây sau khi nhóm thống nhất công nghệ. Thứ tự dự kiến là tạo schema, nạp dữ liệu mẫu, rồi kiểm tra ràng buộc.
- Dùng dữ liệu giả cho demo. Giữ mật khẩu và chuỗi kết nối chứa bí mật trong cấu hình cục bộ.
