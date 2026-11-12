# HƯỚNG DẪN THỰC THI VÀ TÀI LIỆU KỸ THUẬT CSDL
**Hệ thống Quản lý Trung tâm Tiếng Anh · BTL Cơ sở dữ liệu · Nhóm 2**  
*Người phụ trách thiết kế và cài đặt CSDL (Tiêu chí 3, 4, 8):* **Quang**

---

## 1. Cấu trúc thư mục SQL
Thư mục `sql/` chứa toàn bộ mã nguồn DDL, dữ liệu mẫu chuẩn hóa và các kịch bản kiểm thử:

```text
sql/
├── 01_schema.sql           # DDL khởi tạo 13 bảng, PK, FK, UNIQUE, CHECK, Index, 4 View dùng chung
├── 02_seed.sql             # Dữ liệu mẫu chuẩn hóa bao phủ toàn bộ các ca kiểm thử T01–T10
├── 03_checks.sql           # Kịch bản kiểm thử toàn vẹn, xác minh View, negative test & transaction locking
├── 11_dang_ky.sql          # Module nghiệp vụ: Xác nhận đăng ký lớp (Khanh phụ trách)
├── 12_thu_hoc_phi.sql      # Module nghiệp vụ: Thu học phí (Khanh phụ trách)
├── 13_tim_kiem.sql         # Module nghiệp vụ: Tìm kiếm và tra cứu (Lộc phụ trách)
├── 14_bao_cao_thu.sql      # Module nghiệp vụ: Báo cáo thu học phí theo kỳ (Huy phụ trách)
├── 15_bao_cao_ket_qua.sql  # Module nghiệp vụ: Báo cáo kết quả học tập theo lớp (Huy phụ trách)
└── README.md               # Tài liệu hướng dẫn thực thi và thông số kỹ thuật (Quang biên soạn)
```

---

## 2. Thứ tự thực thi chuẩn (Execution Order)

Để dựng mới hoặc khởi tạo lại môi trường kiểm thử cho nhóm, chạy lần lượt các tệp tin theo đúng thứ tự:

### **Bước 1: Khởi tạo cấu trúc CSDL (`01_schema.sql`)**
- Xóa sạch bảng và view cũ (nếu có) theo thứ tự phụ thuộc ngược (`CASCADE`).
- Tạo 13 bảng theo thứ tự cha trước – con sau:
  1. `CO_SO` $\to$ 2. `KHOA_HOC` $\to$ 3. `NHAN_SU` $\to$ 4. `GIAO_VIEN` $\to$ 5. `NHAN_VIEN` $\to$ 6. `HOC_VIEN` $\to$ 7. `LOP_HOC` $\to$ 8. `GIANG_DAY` $\to$ 9. `DANG_KY` $\to$ 10. `PHIEU_THANH_TOAN` $\to$ 11. `DE_THI` $\to$ 12. `BAI_KIEM_TRA` $\to$ 13. `LAM_BAI`.
- Khởi tạo các Index tối ưu truy vấn (`IDX_LOP_HOC_KH`, `IDX_DANG_KY_Lop`, `IDX_PHIEU_DK`,...).
- Tạo 4 View tiện ích dùng chung cho các màn hình của Khanh, Lộc và báo cáo của Huy.

### **Bước 2: Nạp dữ liệu mẫu chuẩn (`02_seed.sql`)**
- Làm sạch các bảng (`DELETE FROM`).
- Nạp đầy đủ dữ liệu demo chuẩn hóa:
  - 2 cơ sở (`CS01`, `CS02`).
  - 4 khóa học (`KH_IELTS_FND`, `KH_IELTS_INT`, `KH_TOEIC_650`, `KH_GIAO_TIEP`).
  - 6 nhân sự (3 giáo viên `GV001`–`GV003`, 3 nhân viên `NV001`–`NV003`).
  - 6 học viên (`HV001`–`HV006`).
  - 4 lớp học (có đủ trạng thái: còn chỗ, đầy chỗ, còn đúng 1 chỗ).
  - 8 lượt đăng ký (có đủ: nợ tiền, nộp đủ, quá hạn, đã hủy).
  - 5 phiếu thanh toán (tiền mặt, chuyển khoản, thẻ, có phiếu hủy).
  - 3 đề thi, 2 bài kiểm tra và kết quả làm bài có điểm 8.0, điểm 0.0 và chưa nhập điểm.

### **Bước 3: Chạy kiểm thử xác minh (`03_checks.sql`)**
- Chạy các truy vấn Phần 1 để xác nhận toàn bộ 4 View trả về số liệu chuẩn xác.
- (Tùy chọn) Bỏ comment từng khối lệnh ở Phần 2 để demo việc DBMS từ chối các thao tác vi phạm ràng buộc (PK, FK, UNIQUE, CHECK).

---

## 3. Lệnh thực thi trên các Hệ quản trị CSDL phổ biến

### A. Đối với PostgreSQL (Khuyến nghị cho nhóm)
Chạy trực tiếp từ terminal / command prompt:
```bash
# 1. Chạy schema DDL
psql -U postgres -d english_center_db -f sql/01_schema.sql

# 2. Nạp seed data
psql -U postgres -d english_center_db -f sql/02_seed.sql

# 3. Kiểm thử xác minh
psql -U postgres -d english_center_db -f sql/03_checks.sql
```
*Hoặc trong pgAdmin / DBeaver:* Mở từng file theo thứ tự và nhấn `Execute (F5)`.

### B. Đối với MySQL / MariaDB
```bash
mysql -u root -p english_center_db < sql/01_schema.sql
mysql -u root -p english_center_db < sql/02_seed.sql
mysql -u root -p english_center_db < sql/03_checks.sql
```

---

## 4. Cách Reset dữ liệu về trạng thái ban đầu khi Demo
Khi Khanh nhập thử form hoặc nhóm test làm sai lệch dữ liệu demo, chỉ cần chạy lại file `sql/02_seed.sql`.  
Tệp tin này tự động dọn dẹp các bảng con trước, sau đó nạp lại chính xác dữ liệu gốc trong vòng dưới 1 giây mà **không cần phải tạo lại bảng (DDL)**.

---

## 5. Bảng ma trận ca kiểm thử (T01–T10) và dữ liệu bàn giao cho nhóm

| Mã Test | Nghiệp vụ kiểm thử | Dữ liệu mẫu tương ứng | Kết quả đối chiếu chuẩn | Thành viên phụ trách |
| :--- | :--- | :--- | :--- | :--- |
| **T01** | Đăng ký lớp còn đúng 1 chỗ | Lớp `LOP_GT_01` (Sĩ số tối đa 3, đã có 2 học viên: `DK007`, `DK008`) | Đăng ký thành công, sĩ số lên 3/3, trạng thái lớp chuyển sang `DaDay`. | **Khanh** (Form Đăng ký) |
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

## 6. Hướng dẫn thiết kế Transaction & Concurrency Control (Dành cho Khanh)

Để đảm bảo đạt điểm tối đa ở **Tiêu chí 5 và Tiêu chí 8 (Xử lý giao dịch và tranh chấp đồng thời)**, Khanh cần áp dụng mô hình khóa bi quan (**Pessimistic Locking**) trong Backend:

### Ngăn chặn vượt sĩ số (Over-enrollment Race Condition)
```sql
BEGIN TRANSACTION;

-- 1. Khóa dòng lớp học để serialize các yêu cầu đăng ký cùng lớp
SELECT MaLop, SiSoToiDa, TrangThai, HocPhi 
FROM LOP_HOC 
WHERE MaLop = :MaLop AND TrangThai = 'DangNhanDangKy'
FOR UPDATE;

-- 2. Đếm sĩ số thực tế
SELECT COUNT(*) AS SiSoHienTai 
FROM DANG_KY 
WHERE MaLop = :MaLop AND TrangThaiDK = 'DaXacNhan';

-- 3. Kiểm tra điều kiện
-- Nếu SiSoHienTai >= SiSoToiDa:
--     ROLLBACK; (Ném lỗi: Lớp đã đầy)
-- Ngược lại:
--     INSERT INTO DANG_KY (MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK)
--     VALUES (:MaDK, :MaHV, :MaLop, CURRENT_DATE, :HocPhi, :HanNop, 'DaXacNhan');
--     COMMIT;
```

### Ngăn chặn thu vượt số dư (Over-collection Race Condition)
```sql
BEGIN TRANSACTION;

-- 1. Khóa dòng đăng ký để ngăn 2 giao dịch thu cùng lúc
SELECT MaDK, KhoanPhaiThu, TrangThaiDK 
FROM DANG_KY 
WHERE MaDK = :MaDK 
FOR UPDATE;

-- 2. Tính số tiền đã thu thực tế
SELECT COALESCE(SUM(SoTien), 0) AS TongDaThu 
FROM PHIEU_THANH_TOAN 
WHERE MaDK = :MaDK AND TrangThai = 'ThanhCong';

-- 3. Kiểm tra:
-- SoDuConLai = KhoanPhaiThu - TongDaThu;
-- Nếu SoTienNop <= 0 HOẶC SoTienNop > SoDuConLai:
--     ROLLBACK; (Ném lỗi: Số tiền không hợp lệ hoặc vượt dư nợ)
-- Ngược lại:
--     INSERT INTO PHIEU_THANH_TOAN (...);
--     Nếu SoTienNop == SoDuConLai: UPDATE DANG_KY SET TrangThaiDK = 'DaHoanThanh';
--     COMMIT;
```

---
*Mọi thắc mắc hoặc yêu cầu bổ sung trường dữ liệu/View, các bạn nhóm 2 liên hệ Quang để được hỗ trợ.*

