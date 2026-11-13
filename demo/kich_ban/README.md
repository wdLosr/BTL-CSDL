# Kịch bản demo tích hợp

## 1. Dựng môi trường

Dùng Java 17 trở lên, MySQL 8.0.16 trở lên và một CSDL riêng cho demo. Trên máy chủ thử nghiệm, chạy toàn bộ `sql/01_schema.sql` rồi `sql/02_seed.sql` bằng MySQL Workbench. Hai script đặt lại bảng và dữ liệu trong `english_center_db`. Nếu tên này đã có dữ liệu cần giữ, thay tên database trong bản sao của cả hai script và dùng tên mới trong `DB_URL`. Kiểm tra có các mã `HV003`, `LOP_GT_01` và `BKT01`. Lớp `LOP_GT_01` có hai đăng ký trong tổng số ba chỗ và học phí 2.000.000 đồng.

Đặt các biến kết nối, build và khởi động theo [README](../../README.md). Tất cả bước bên dưới dùng chung URL ứng dụng và CSDL. Dùng mã mới hoặc nạp lại bộ dữ liệu thử riêng trước khi lặp demo.

## 2. Đăng ký

1. Mở `/m/dang-ky-lop`. Nhập mã `DKQA`, chọn `HV003` và `LOP_GT_01`, chọn hạn nộp từ ngày chạy trở đi rồi lưu.
2. Mở `/tim-kiem`, lọc `HV003` và `LOP_GT_01`. Dòng vừa tạo có phải thu 2.000.000, đã thu 0 và số dư 2.000.000 đồng.
3. Thử tạo `DKDUP` cho cùng học viên và lớp. Thử tiếp `DKQA2` cho `HV004` vào lớp đó. Cả hai phải bị từ chối, lần lượt vì trùng và vì lớp đầy.

## 3. Thu học phí

1. Mở `/m/phieu-thanh-toan`, chọn `DKQA`. Ghi phiếu `PTTQA1` số tiền 500.000 đồng, chọn Tiền mặt và thời điểm không muộn hơn hiện tại.
2. Tải lại trang tìm kiếm. Số dư là 1.500.000 đồng.
3. Ghi `PTTQA2` thêm 500.000 đồng cùng ngày. Thử gửi lại mã phiếu này rồi thử `PTTQA3` với 1.000.001 đồng. Hai lần thử sai giữ nguyên hai phiếu hợp lệ.

## 4. Tìm kiếm

Tìm theo `HV003`, một phần mã `V003`, tên có dấu hoặc một phần tên của học viên. Kết hợp với lớp `LOP_GT_01` để thấy một dòng có tổng đã thu 1.000.000 và số dư 1.000.000 đồng. Bỏ lọc lớp để thấy các lớp khác của học viên. Thử từ khóa `zz-no-such-user` để thấy thông báo rỗng. Tìm `HV004` ở `LOP_IE_01` để kiểm tra đăng ký hủy và số dư “Không áp dụng”.

## 5. Báo cáo và xuất tệp

- Mở `/m/thu-hoc-phi`, lọc đúng ngày của hai phiếu và lớp `LOP_GT_01`. Kiểm tra hai dòng với tổng 1.000.000 đồng. Bấm **Xuất Excel**, mở tệp và đối chiếu số dòng, tổng tiền cùng người lập, người nhận.
- Mở `/m/danh-gia`, chọn `LOP_IE_01` và `BKT01`. Dữ liệu mẫu có 3 học viên đủ điều kiện theo ứng dụng, gồm điểm 8, điểm 0 và một trường hợp chưa nhập. Trung bình 4,00. Xuất Excel và đối chiếu nội dung.

## 6. Đối chiếu trực tiếp

Chạy các truy vấn sau trên cùng CSDL demo.

~~~sql
SELECT MaDK, KhoanPhaiThu, TrangThaiDK
FROM DANG_KY
WHERE MaDK IN ('DKQA', 'DKDUP', 'DKQA2');

SELECT MaDK, COUNT(*) AS SoPhieu, SUM(SoTien) AS DaThu
FROM PHIEU_THANH_TOAN
WHERE MaDK = 'DKQA' AND TrangThai = 'ThanhCong'
GROUP BY MaDK;

SELECT MaPhieu, SoTien
FROM v_bao_cao_thu_hoc_phi
WHERE MaPhieu IN ('PTTQA1', 'PTTQA2', 'PTTQA3');

SELECT MaHV, LanThi, Diem FROM LAM_BAI WHERE MaBKT = 'BKT01';
~~~

Kỳ vọng có một đăng ký `DKQA`, hai phiếu thu thành công và không có mã của các ca bị từ chối. Truy vấn tìm kiếm mà web thực thi nằm ở [sql/13_tim_kiem.sql](../../sql/13_tim_kiem.sql). Dừng ứng dụng bằng Ctrl+C.
