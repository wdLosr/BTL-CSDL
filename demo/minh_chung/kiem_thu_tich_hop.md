# Biên bản kiểm thử tích hợp

Thực hiện ngày 13/11/2026 bằng JDK 21, Maven Wrapper, Spring Boot và MySQL 8.0.46 cục bộ. MySQL dùng thư mục dữ liệu mới. Ứng dụng chạy từ JAR, các trang và form được gọi qua HTTP. Xác minh lưu trữ bằng truy vấn trực tiếp. Hai tệp mẫu trong `reports/` là bản tải từ các endpoint xuất Excel của lần chạy này.

| Ca | Kết quả quan sát |
| --- | --- |
| Maven package | Build thành công, 2 bài kiểm thử báo cáo và Excel đạt. |
| Khởi tạo | Nạp schema, seed và bốn thủ tục 11, 12, 14, 15 thành công. |
| Đăng ký hợp lệ | `DKQA` được ghi cho `HV003` tại `LOP_GT_01`, phải thu 2.000.000 đồng. |
| Đăng ký lỗi | Ca trùng và ca lớp đầy không sinh bản ghi. |
| Thu học phí | Hai lần thu 500.000 đồng. Thử mã phiếu trùng và thu 1.000.001 đồng. SQL xác nhận chỉ có 2 phiếu và tổng đúng 1.000.000 đồng. |
| Tìm kiếm | Kiểm tra mã, mã một phần, tên có dấu, một phần tên, lớp, bộ lọc kết hợp và không có kết quả. `DKQA` xuất hiện một dòng trong lớp đã lọc. |
| Số dư | `DKQA` có số dư 2.000.000, 1.500.000 và 1.000.000 đồng qua ba thời điểm. `DK004` hiển thị không áp dụng. |
| Báo cáo | Hai trang HTML trả dữ liệu. Xuất và kiểm tra cấu trúc hai workbook XLSX. |

Phạm vi kiểm tra thực tế gồm phản hồi HTTP, bản ghi MySQL và nội dung tệp xuất. Chưa thao tác bằng trình duyệt, chưa xem bản in trong Excel, chưa kiểm tra ghi đồng thời và xác nhận lại đăng ký hủy.
