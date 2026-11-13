# HƯỚNG DẪN THỰC THI VÀ TÀI LIỆU KỸ THUẬT CSDL (MYSQL / MARIADB)
**Hệ thống Quản lý Trung tâm Tiếng Anh · BTL Cơ sở dữ liệu · Nhóm 2**  
*Người phụ trách thiết kế và cài đặt CSDL (Tiêu chí 3, 4, 8):* **Quang**

---

## 1. Cấu trúc thư mục SQL
Toàn bộ mã nguồn DDL, dữ liệu mẫu chuẩn hóa và các kịch bản kiểm thử đã được chuẩn hóa 100% theo cú pháp **MySQL / MariaDB (InnoDB, UTF-8)**:

```text
sql/
├── 01_schema.sql           # DDL khởi tạo 13 bảng (InnoDB), PK, FK, UNIQUE, CHECK, Index, 4 View và trigger kiểm tra liên bảng
├── 02_seed.sql             # Dữ liệu mẫu chuẩn hóa bao phủ toàn bộ các ca kiểm thử T01–T10
├── 03_checks.sql           # Kịch bản kiểm thử toàn vẹn, xác minh 4 View, negative tests & transaction locking
├── 11_dang_ky.sql          # Module nghiệp vụ: Xác nhận đăng ký lớp (Khanh phụ trách)
├── 12_thu_hoc_phi.sql      # Module nghiệp vụ: Thu học phí (Khanh phụ trách)
├── 13_tim_kiem.sql         # Module nghiệp vụ: Tìm kiếm và tra cứu (Lộc phụ trách)
├── 14_bao_cao_thu.sql      # Module nghiệp vụ: Báo cáo thu học phí theo kỳ (Huy phụ trách)
├── 15_bao_cao_ket_qua.sql  # Module nghiệp vụ: Báo cáo kết quả học tập theo lớp (Huy phụ trách)
└── README.md               # Tài liệu kỹ thuật và hướng dẫn thực thi (Quang biên soạn)
```

---

## 2. Thông số kỹ thuật MySQL / MariaDB đã thiết lập

1. **Hệ quản trị CSDL:** Dùng MySQL 8.0.16 trở lên để các ràng buộc `CHECK` được thực thi. Năm thủ tục 11–15 đã được chạy thử trên MySQL 8.0.46; chưa kiểm thử với MariaDB/XAMPP.
2. **Database:** `english_center_db` (Tự động tạo mới và chuyển đổi bằng `CREATE DATABASE IF NOT EXISTS ...; USE english_center_db;`). Database tên `english_center` là database khác và không được năm file 11–15 sử dụng.
3. **Storage Engine:** `ENGINE=InnoDB` cho toàn bộ 13 bảng để đảm bảo tính toàn vẹn tham chiếu (Foreign Keys) và hỗ trợ giao dịch ACID.
4. **Bảng mã và đối chiếu:** `CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci` hỗ trợ lưu trữ tiếng Việt có dấu đầy đủ và không bị lỗi font.
5. **Khóa ngoại:** `01_schema.sql` tạm tắt kiểm tra khi xóa/tạo lại bảng. `02_seed.sql` giữ kiểm tra khóa ngoại bật; dữ liệu được xóa và nạp theo đúng thứ tự phụ thuộc.
6. **Kiểm tra ràng buộc miền giá trị:** Thực thi `CHECK constraints` trực tiếp trên tầng lưu trữ MySQL.

---

## 3. Thứ tự thực thi chuẩn (Execution Order)

Để dựng mới hoặc khởi tạo lại môi trường kiểm thử cho nhóm, chạy lần lượt các tệp tin theo đúng thứ tự:

### **Bước 1: Khởi tạo cấu trúc CSDL (`01_schema.sql`)**
- Tự động xóa sạch bảng và View cũ nếu đã tồn tại.
- Tạo 13 bảng theo thứ tự cha trước – con sau:
  1. `CO_SO` $\to$ 2. `KHOA_HOC` $\to$ 3. `NHAN_SU` $\to$ 4. `GIAO_VIEN` $\to$ 5. `NHAN_VIEN` $\to$ 6. `HOC_VIEN` $\to$ 7. `LOP_HOC` $\to$ 8. `GIANG_DAY` $\to$ 9. `DANG_KY` $\to$ 10. `PHIEU_THANH_TOAN` $\to$ 11. `DE_THI` $\to$ 12. `BAI_KIEM_TRA` $\to$ 13. `LAM_BAI`.
- Khởi tạo 8 chỉ mục Index tối ưu hóa truy vấn (`IDX_LOP_HOC_KH`, `IDX_DANG_KY_Lop`, `IDX_PHIEU_DK`,...).
- Tạo 4 View tiện ích dùng chung (`v_si_so_lop`, `v_dang_ky_hoc_phi`, `v_bao_cao_thu_hoc_phi`, `v_bao_cao_ket_qua_lop`).

### **Bước 2: Nạp dữ liệu mẫu chuẩn (`02_seed.sql`)**
- Xóa sạch dữ liệu cũ và nạp bộ dữ liệu demo chuẩn hóa:
  - 2 cơ sở (`CS01`, `CS02`).
  - 4 khóa học (`KH_IELTS_FND`, `KH_IELTS_INT`, `KH_TOEIC_650`, `KH_GIAO_TIEP`).
  - 6 nhân sự (3 giáo viên `GV001`–`GV003`, 3 nhân viên `NV001`–`NV003`).
  - 6 học viên (`HV001`–`HV006`).
  - 4 lớp học (có đủ trạng thái: còn chỗ, đầy chỗ, còn đúng 1 chỗ).
  - 8 lượt đăng ký (có đủ: nợ tiền, nộp đủ, quá hạn, đã hủy).
  - 5 phiếu thanh toán (tiền mặt, chuyển khoản, thẻ, có phiếu hủy).
  - 3 đề thi, 2 bài kiểm tra và kết quả làm bài (điểm 8.0, điểm 0.0, chưa nhập điểm).

### **Bước 3: Chạy kiểm thử xác minh (`03_checks.sql`)**
- **Phần 1:** Kiểm tra số lượng bản ghi và đối chiếu kết quả 4 View.
- **Phần 2:** Chạy thử các ca vi phạm (PK, FK, UNIQUE, CHECK số tiền âm, ngày sai) $\to$ Chứng minh MySQL từ chối và báo lỗi.
- **Phần 3:** Cung cấp đặc tả giao dịch an toàn (`START TRANSACTION`, `SELECT ... FOR UPDATE`) chống vượt sĩ số và thu vượt công nợ.

---

## 4. Hướng dẫn thực thi trên MySQL / MariaDB (XAMPP)

### Cách A: Sử dụng giao diện phpMyAdmin (Trực quan cho thuyết trình)
1. Mở **XAMPP Control Panel**, nhấn **Start** cho **Apache** và **MySQL**.
2. Mở trình duyệt, truy cập: `http://localhost/phpmyadmin/`.
3. Nhấp vào tab **Import** (Nhập):
   - Chọn tệp [01_schema.sql](file:///e:/BTL_CSDL/BTL-CSDL/sql/01_schema.sql) $\to$ Bấm **Go / Thực hiện**.
   - Chọn tệp [02_seed.sql](file:///e:/BTL_CSDL/BTL-CSDL/sql/02_seed.sql) $\to$ Bấm **Go / Thực hiện**.
4. Vào tab **SQL**, copy các truy vấn trong [03_checks.sql](file:///e:/BTL_CSDL/BTL-CSDL/sql/03_checks.sql) để kiểm tra kết quả dạng bảng.

### Cách B: Sử dụng dòng lệnh Command Line / PowerShell (Chỉ 3 giây)
Chạy trực tiếp từ terminal dự án:
```powershell
# 1. Chạy DDL schema (Tự tạo CSDL english_center_db nếu chưa có)
& "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 -e "source e:/BTL_CSDL/BTL-CSDL/sql/01_schema.sql"

# 2. Nạp dữ liệu mẫu seed
& "C:\xampp\mysql\bin\mysql.exe" -u root english_center_db --default-character-set=utf8mb4 -e "source e:/BTL_CSDL/BTL-CSDL/sql/02_seed.sql"

# 3. Chạy kịch bản kiểm thử xác minh
& "C:\xampp\mysql\bin\mysql.exe" -u root english_center_db --default-character-set=utf8mb4 -e "source e:/BTL_CSDL/BTL-CSDL/sql/03_checks.sql"
```

---

## 5. Cách Reset dữ liệu về trạng thái ban đầu khi Demo
Khi các thành viên trong nhóm nhập thử dữ liệu làm biến đổi sĩ số hoặc công nợ, chỉ cần chạy lại duy nhất file `02_seed.sql`:
File này tự tạm tắt `SQL_SAFE_UPDATES` trong lúc xóa dữ liệu mẫu rồi khôi phục giá trị cũ, nên chạy được cả khi MySQL Workbench bật Safe Updates. Chạy toàn bộ file trong một phiên kết nối; việc chạy lại sẽ xóa dữ liệu đang có trong `english_center_db`.
- **Trong phpMyAdmin:** Mở database `english_center_db` $\to$ Tab **Import** $\to$ Chọn `02_seed.sql` $\to$ Bấm **Go**.
- **Trong Terminal:**
  ```powershell
  & "C:\xampp\mysql\bin\mysql.exe" -u root english_center_db --default-character-set=utf8mb4 -e "source e:/BTL_CSDL/BTL-CSDL/sql/02_seed.sql"
  ```
Toàn bộ CSDL sẽ trở lại trạng thái ban đầu trong vòng dưới 1 giây mà **không cần tạo lại bảng**.

---

## 6. Bảng ma trận ca kiểm thử (T01–T10) và dữ liệu bàn giao cho nhóm

| Mã Test | Nghiệp vụ kiểm thử | Dữ liệu mẫu tương ứng trong MySQL | Kết quả đối chiếu chuẩn | Thành viên phụ trách |
| :--- | :--- | :--- | :--- | :--- |
| **T01** | Đăng ký lớp còn đúng 1 chỗ | Lớp `LOP_GT_01` (Sĩ số tối đa 3, hiện đã có 2 học viên: `DK007`, `DK008`) | Đăng ký thành công, sĩ số lên 3/3; view `v_si_so_lop` tính `DaDay`. Không ghi `DaDay` vào `LOP_HOC.TrangThai`. | **Khanh** (Form Đăng ký) |
| **T02** | Chặn đăng ký vào lớp đã đầy | Lớp `LOP_TOEIC_A` (Sĩ số tối đa 2, đã có 2 học viên: `DK005`, `DK006`) | Bị chặn, thông báo lỗi: "Lớp học đã đủ sĩ số". Không phát sinh bản ghi. | **Khanh** (Form Đăng ký) |
| **T03** | Tái kích hoạt đăng ký đã hủy | Đăng ký `DK004` (HV004 tại lớp `LOP_IE_01` có trạng thái `DaHuy`) | Cập nhật lại bản ghi `DK004` sang `DaXacNhan`, không thêm mã mới trùng lặp. | **Khanh** (Form Đăng ký) |
| **T04** | Thu học phí nhiều lần (nợ còn lại) | Đăng ký `DK001` (Phải thu 3.000.000đ, đã thu 1.500.000đ qua PTT001 và PTT002) | Thu thêm tối đa 1.500.000đ. Thu xong số dư = 0đ, trạng thái `DaHoanThanh`. | **Khanh** (Form Thu phí) |
| **T05** | Chặn thu học phí vượt số dư nợ | Đăng ký `DK001` (Số dư nợ hiện tại = 1.500.000đ) | Nhập số tiền thu 2.000.000đ $\implies$ Bị từ chối: "Vượt quá công nợ còn lại". | **Khanh** (Form Thu phí) |
| **T06** | Tìm kiếm lớp & học viên theo tiêu chí | Học viên `HV001`, lớp `LOP_IE_01`, từ khóa `IELTS` | Trả về đúng danh sách kèm số chỗ còn lại và tình trạng công nợ từ View. | **Lộc** (Màn Tìm kiếm) |
| **T07** | Báo cáo doanh thu học phí | View `v_bao_cao_thu_hoc_phi` | Tổng thu chuẩn = **7.000.000đ** (4 phiếu hợp lệ). Phiếu hủy PTT004 bị loại bỏ. | **Huy** (Báo cáo Thu) |
| **T08** | Báo cáo điểm: phân biệt điểm 0 và chưa nhập | Lớp `LOP_IE_01`, bài `BKT01`: `HV001` (8.0đ), `HV002` (0.0đ), `HV003` (NULL) | `HV002` hiện điểm 0.0, `HV003` hiện "Chưa nhập". Điểm TB lớp = **4.00** (8.0/2). | **Huy** (Báo cáo Điểm) |
| **T09** | Chặn nhập số tiền thanh toán âm | Thêm `PHIEU_THANH_TOAN` có `SoTien = -500000` | Bị từ chối ngay tại CSDL bởi `CK_PHIEU_THANH_TOAN_SoTien`. | **Quang** (DDL/Constraint) |
| **T10** | Chặn học viên đăng ký trùng lớp | Thêm `DANG_KY` với cặp (`HV001`, `LOP_IE_01`) | Bị từ chối ngay tại CSDL bởi `UQ_DANG_KY_HV_Lop`. | **Quang** (DDL/Constraint) |

---

## 7. Mẫu Transaction & Concurrency Locking chuẩn MySQL (Dành cho Khanh)

### A. Ngăn chặn vượt sĩ số (Over-enrollment Race Condition)
```sql
START TRANSACTION;

-- 1. Khóa dòng lớp học bằng FOR UPDATE
SELECT MaLop, SiSoToiDa, TrangThai, HocPhi 
FROM LOP_HOC 
WHERE MaLop = :MaLop AND TrangThai = 'DangNhanDangKy'
FOR UPDATE;

-- 2. Đếm sĩ số thực tế
SELECT COUNT(*) AS SiSoHienTai 
FROM DANG_KY 
WHERE MaLop = :MaLop AND TrangThaiDK = 'DaXacNhan';

-- 3. Kiểm tra điều kiện nghiệp vụ
-- Nếu SiSoHienTai >= SiSoToiDa:
--     ROLLBACK;
-- Ngược lại:
--     INSERT INTO DANG_KY (MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK)
--     VALUES (:MaDK, :MaHV, :MaLop, CURRENT_DATE, :HocPhi, DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY), 'DaXacNhan');
--     COMMIT;
```

### B. Ngăn chặn thu vượt số dư (Over-collection Race Condition)
```sql
START TRANSACTION;

-- 1. Khóa bản ghi đăng ký
SELECT MaDK, KhoanPhaiThu, TrangThaiDK 
FROM DANG_KY 
WHERE MaDK = :MaDK 
FOR UPDATE;

-- 2. Tính số tiền đã thu thực tế
SELECT COALESCE(SUM(SoTien), 0) AS TongDaThu 
FROM PHIEU_THANH_TOAN 
WHERE MaDK = :MaDK AND TrangThai = 'ThanhCong';

-- 3. Kiểm tra công nợ:
-- SoDuConLai = KhoanPhaiThu - TongDaThu;
-- Nếu SoTienNop <= 0 HOẶC SoTienNop > SoDuConLai:
--     ROLLBACK;
-- Ngược lại:
--     INSERT INTO PHIEU_THANH_TOAN (MaPhieu, MaDK, NgayThanhToan, SoTien, PhuongThuc, TrangThai, GhiChu)
--     VALUES (:MaPhieu, :MaDK, CURRENT_TIMESTAMP, :SoTienNop, :PhuongThuc, 'ThanhCong', :GhiChu);
--     Nếu SoTienNop == SoDuConLai: UPDATE DANG_KY SET TrangThaiDK = 'DaHoanThanh' WHERE MaDK = :MaDK;
--     COMMIT;
```

## 8. Các thủ tục nghiệp vụ MySQL (file 11–15)

Chạy `01_schema.sql`, `02_seed.sql`, rồi lần lượt chạy `11_dang_ky.sql` đến `15_bao_cao_ket_qua.sql` bằng **Execute All** trong MySQL Workbench. Mỗi file tự chọn `english_center_db`. `DELIMITER` là lệnh của MySQL client/Workbench, vì vậy cần chạy toàn bộ file thay vì chỉ bôi đen phần `CREATE PROCEDURE`.

| File | Thủ tục | Kết quả |
|---|---|---|
| `11_dang_ky.sql` | `CALL sp_dang_ky_lop('DK009','HV003','LOP_GT_01',DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY));` | Một dòng đăng ký. Đăng ký mới chỉ vào lớp `DangNhanDangKy`; hồ sơ đã hủy có thể xác nhận lại ở lớp `DangHoc` nếu còn chỗ, dùng mã đăng ký cũ. |
| `12_thu_hoc_phi.sql` | `CALL sp_thu_hoc_phi('PTT006','DK001',NOW(),500000.00,'TienMat',NULL);` | Mã phiếu, tổng đã thu và số dư sau thu. |
| `13_tim_kiem.sql` | `CALL sp_tim_kiem_dang_ky('IELTS','LOP_IE_01');` | Đăng ký, công nợ và sĩ số. Từ khóa tìm theo học viên, lớp hoặc khóa học; tham số mã lớp lọc chính xác. Dùng `NULL` hoặc chuỗi rỗng để bỏ bộ lọc. |
| `14_bao_cao_thu.sql` | `CALL sp_bao_cao_thu('2026-09-01','2026-10-31',NULL);` | Hai bảng kết quả: chi tiết phiếu thu thành công và tổng thực thu. |
| `15_bao_cao_ket_qua.sql` | `CALL sp_bao_cao_ket_qua('LOP_IE_01','BKT01');` | Hai bảng kết quả: một dòng mỗi học viên đủ điều kiện và thống kê. Điểm `0` tính là đã nhập; `NULL` là chưa nhập. |

Hai thủ tục ghi dữ liệu **tự mở và kết thúc giao dịch**; chỉ gọi trực tiếp ngoài giao dịch ứng dụng. Ứng dụng web hiện dùng Spring JDBC với giao dịch Java tương ứng, không gọi thủ tục khi bấm **Lưu** và không tự chạy SQL khi khởi động. Cả hai luồng đều khóa lớp trước khi xác nhận đăng ký và khóa đăng ký trước khi thu phí. Hồ sơ đã hủy có phiếu cũ được tái kích hoạt trên mã cũ: nếu có lịch sử phiếu, giữ nguyên khoản phải thu và ngày đăng ký, đối soát tiền đã thu trước khi đổi trạng thái. `01_schema.sql` tạo lại bảng; `02_seed.sql` đặt lại dữ liệu mẫu. Không chạy hai file này trên database có dữ liệu cần giữ.
