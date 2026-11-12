# TỪ ĐIỂN DỮ LIỆU (DATA DICTIONARY)
## HỆ THỐNG QUẢN LÝ TRUNG TÂM TIẾNG ANH
**Bài tập lớn môn Cơ sở dữ liệu · Nhóm 2**  
**Người phụ trách thiết kế CSDL (Tiêu chí 3):** Quang  
**Phiên bản:** 1.0 · Ngày 12/11/2026  
**Căn cứ thiết kế:** Bản đặc tả yêu cầu dữ liệu (`design/01_yeu_cau_du_lieu.docx`) và Sơ đồ ERD (`design/02_erd.drawio`) do Nam bàn giao.

---

## 1. QUY ƯỚC CHUNG

### 1.1. Quy ước đặt tên
- **Tên bảng:** Viết hoa toàn bộ, các từ phân cách bằng dấu gạch dưới `_` (snake_case in hoa), ví dụ: `HOC_VIEN`, `LOP_HOC`, `DANG_KY`, `PHIEU_THANH_TOAN`.
- **Tên cột / trường:** Dùng kiểu PascalCase hoặc gộp từ có nghĩa rõ ràng, ví dụ: `MaHV`, `HoTen`, `NgaySinh`, `KhoanPhaiThu`, `TrangThaiDK`.
- **Khóa chính (PK):** Tiền tố `Ma` kết hợp với viết tắt thực thể, ví dụ: `MaHV`, `MaLop`, `MaDK`, `MaPhieu`, `MaBKT`, `MaDe`, `MaCS`, `MaNS`.
- **Khóa ngoại (FK):** Đặt tên trùng với tên cột khóa chính của bảng được tham chiếu để đảm bảo tính nhất quán và dễ truy vấn nối (JOIN).

### 1.2. Quy ước kiểu dữ liệu chuẩn (SQL Standard)
- `VARCHAR(n)`: Chuỗi ký tự có độ dài biến đổi (tối đa `n` ký tự), hỗ trợ Unicode/UTF-8.
- `INT`: Số nguyên (4 bytes), dùng cho sĩ số, thời lượng, số lần thi.
- `DECIMAL(p, s)`: Số thực có độ chính xác cố định (`p` chữ số, `s` số sau dấu phẩy), bắt buộc dùng cho tiền tệ (`DECIMAL(12,2)`) và điểm số (`DECIMAL(4,2)`), tuyệt đối không dùng FLOAT/DOUBLE để tránh sai số làm tròn tài chính.
- `DATE`: Kiểu ngày (YYYY-MM-DD), dùng cho ngày sinh, ngày đăng ký, ngày khai giảng.
- `DATETIME`: Kiểu ngày và giờ địa phương, dùng cho thời điểm thanh toán phiếu thu.

---

## 2. DANH MỤC CÁC BẢNG TRONG CƠ SỞ DỮ LIỆU

Hệ thống gồm **13 bảng quan hệ** chuẩn hóa:

| STT | Tên bảng | Tên tiếng Việt | Vai trò trong hệ thống |
| :---: | :--- | :--- | :--- |
| 1 | `CO_SO` | Cơ sở đào tạo | Lưu thông tin các cơ sở/điểm trường của trung tâm. |
| 2 | `KHOA_HOC` | Khóa học đào tạo | Chương trình đào tạo danh mục, học phí niêm yết tham khảo. |
| 3 | `NHAN_SU` | Nhân sự | Thực thể cha (Supertype ISA), lưu thông tin chung của cán bộ, giáo viên, nhân viên. |
| 4 | `GIAO_VIEN` | Giáo viên | Thực thể con (Subtype ISA), lưu học vị và chuyên môn của giáo viên. |
| 5 | `NHAN_VIEN` | Nhân viên | Thực thể con (Subtype ISA), lưu vị trí công tác (tư vấn, giáo vụ, thu ngân). |
| 6 | `HOC_VIEN` | Học viên | Hồ sơ lý lịch người học tại trung tâm. |
| 7 | `LOP_HOC` | Lớp học | Lớp học cụ thể thuộc một khóa học, tổ chức tại một cơ sở, có học phí áp dụng riêng. |
| 8 | `GIANG_DAY` | Phân công giảng dạy | Bảng liên kết N-N giữa giáo viên và lớp học, lưu vai trò giảng dạy. |
| 9 | `DANG_KY` | Đăng ký học | Bản ghi ghi danh của học viên vào lớp học, chốt học phí phải nộp và hạn nộp. |
| 10 | `PHIEU_THANH_TOAN` | Phiếu thanh toán | Ghi nhận từng lần nộp tiền học phí của học viên theo một đăng ký cụ thể. |
| 11 | `DE_THI` | Đề thi | Danh mục các đề thi, cấu trúc và thời lượng bài thi. |
| 12 | `BAI_KIEM_TRA` | Bài kiểm tra | Các bài kiểm tra/đợt đánh giá được tổ chức cho một lớp học cụ thể. |
| 13 | `LAM_BAI` | Kết quả làm bài | Điểm số và thông tin làm bài kiểm tra của học viên (hỗ trợ nhiều lần thi). |

---

## 3. TỪ ĐIỂN DỮ LIỆU CHI TIẾT TỪNG BẢNG

### 3.1. Bảng `CO_SO` (Cơ sở đào tạo)
- **Mục đích:** Quản lý danh sách các cơ sở trực thuộc trung tâm ngoại ngữ.
- **Khóa chính:** `MaCS`

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaCS` | Mã cơ sở | VARCHAR(20) | NO | PK | | Mã định danh duy nhất (vd: 'CS01', 'CS02'). |
| `TenCS` | Tên cơ sở | VARCHAR(100) | NO | | | Tên gọi cơ sở (vd: 'Cơ sở Cầu Giấy'). |
| `DiaChi` | Địa chỉ | VARCHAR(255) | NO | | | Địa chỉ thực tế của cơ sở. |
| `SDT` | Số điện thoại | VARCHAR(15) | YES | | NULL | Số hotline/điện thoại bàn của cơ sở. |
| `TrangThai` | Trạng thái hoạt động | VARCHAR(20) | NO | CHECK | 'HoatDong' | Miền giá trị: `'HoatDong'`, `'TamDung'`. |

---

### 3.2. Bảng `KHOA_HOC` (Khóa học đào tạo)
- **Mục đích:** Quản lý danh mục các chương trình học, giá niêm yết danh mục và thời lượng đào tạo chuẩn.
- **Khóa chính:** `MaKH`

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaKH` | Mã khóa học | VARCHAR(20) | NO | PK | | Mã định danh khóa học (vd: 'KH_IELTS_65'). |
| `TenKH` | Tên khóa học | VARCHAR(150) | NO | | | Tên khóa học (vd: 'Khóa luyện thi IELTS 6.5+'). |
| `GiaKH` | Học phí niêm yết | DECIMAL(12,2) | NO | CHECK | | Học phí tham khảo danh mục. CHECK: `GiaKH >= 0`. |
| `ThoiLuong` | Thời lượng khóa học | INT | NO | CHECK | | Số giờ học hoặc số buổi. CHECK: `ThoiLuong > 0`. |
| `MoTa` | Mô tả khái quát | TEXT | YES | | NULL | Nội dung chương trình, chuẩn đầu ra. |
| `TrangThai` | Trạng thái đào tạo | VARCHAR(20) | NO | CHECK | 'DangMo' | Miền giá trị: `'DangMo'`, `'NgungMo'`. |

---

### 3.3. Bảng `NHAN_SU` (Nhân sự - Supertype)
- **Mục đích:** Lưu trữ hồ sơ định danh và lý lịch cá nhân của toàn bộ đội ngũ nhân sự tại trung tâm (giáo viên, nhân viên, quản lý).
- **Khóa chính:** `MaNS`
- **Khóa duy nhất (Unique):** `SDT`, `Email`

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaNS` | Mã nhân sự | VARCHAR(20) | NO | PK | | Mã định danh duy nhất (vd: 'GV001', 'NV001'). |
| `HoTen` | Họ và tên | VARCHAR(100) | NO | | | Họ tên đầy đủ của nhân sự. |
| `NgaySinh` | Ngày sinh | DATE | NO | | | Ngày tháng năm sinh. |
| `GioiTinh` | Giới tính | VARCHAR(10) | NO | CHECK | 'Nam' | Miền giá trị: `'Nam'`, `'Nu'`, `'Khac'`. |
| `SDT` | Số điện thoại | VARCHAR(15) | NO | UNIQUE | | Số điện thoại liên hệ duy nhất. |
| `Email` | Thư điện tử | VARCHAR(100) | NO | UNIQUE | | Email liên hệ công việc duy nhất. |
| `DiaChi` | Địa chỉ thường trú | VARCHAR(255) | YES | | NULL | Nơi cư trú của nhân sự. |
| `TrangThai` | Tình trạng công tác | VARCHAR(20) | NO | CHECK | 'DangLamViec' | Miền giá trị: `'DangLamViec'`, `'NghiViec'`. |

---

### 3.4. Bảng `GIAO_VIEN` (Giáo viên - Subtype của NHAN_SU)
- **Mục đích:** Lưu thông tin bằng cấp, chuyên môn giảng dạy của các giảng viên.
- **Khóa chính:** `MaNS` (đồng thời là Khóa ngoại tham chiếu `NHAN_SU.MaNS`).

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaNS` | Mã giáo viên | VARCHAR(20) | NO | PK, FK | | Tham chiếu `NHAN_SU(MaNS)` (ON DELETE CASCADE). |
| `HocVi` | Trình độ học vị | VARCHAR(50) | NO | | | Học vị cao nhất: 'CuNhan', 'ThacSi', 'TienSi'. |
| `ChuyenMon` | Chuyên môn giảng dạy | VARCHAR(100) | NO | | | Lĩnh vực phụ trách: 'IELTS', 'TOEIC', 'GiaoTiep'. |

---

### 3.5. Bảng `NHAN_VIEN` (Nhân viên hành chính - Subtype của NHAN_SU)
- **Mục đích:** Lưu vị trí nghiệp vụ của nhân viên phòng ban (tư vấn, giáo vụ, thu ngân, quản lý).
- **Khóa chính:** `MaNS` (đồng thời là Khóa ngoại tham chiếu `NHAN_SU.MaNS`).

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaNS` | Mã nhân viên | VARCHAR(20) | NO | PK, FK | | Tham chiếu `NHAN_SU(MaNS)` (ON DELETE CASCADE). |
| `ViTri` | Vị trí công tác | VARCHAR(50) | NO | CHECK | 'TuVan' | Miền giá trị: `'TuVan'`, `'GiaoVu'`, `'ThuNgan'`, `'QuanLy'`. |

---

### 3.6. Bảng `HOC_VIEN` (Học viên)
- **Mục đích:** Quản lý hồ sơ thông tin của học viên đăng ký theo học tại trung tâm.
- **Khóa chính:** `MaHV`
- **Khóa duy nhất (Unique):** `SDT`, `Email`

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaHV` | Mã học viên | VARCHAR(20) | NO | PK | | Mã định danh học viên duy nhất (vd: 'HV001'). |
| `HoTen` | Họ và tên | VARCHAR(100) | NO | | | Họ tên đầy đủ của học viên. |
| `NgaySinh` | Ngày sinh | DATE | NO | | | Ngày tháng năm sinh. |
| `GioiTinh` | Giới tính | VARCHAR(10) | NO | CHECK | 'Nam' | Miền giá trị: `'Nam'`, `'Nu'`, `'Khac'`. |
| `SDT` | Số điện thoại | VARCHAR(15) | NO | UNIQUE | | Số điện thoại liên hệ chính thức. |
| `Email` | Thư điện tử | VARCHAR(100) | NO | UNIQUE | | Email nhận thông báo học tập. |
| `DiaChi` | Địa chỉ liên lạc | VARCHAR(255) | YES | | NULL | Địa chỉ cư trú của học viên. |
| `NgayTao` | Ngày lập hồ sơ | DATE | NO | | CURRENT_DATE | Ngày đầu tiên tiếp nhận thông tin học viên. |

---

### 3.7. Bảng `LOP_HOC` (Lớp học)
- **Mục đích:** Quản lý từng lớp học mở cụ thể của một khóa học, tại một cơ sở, quy định sĩ số và học phí áp dụng.
- **Khóa chính:** `MaLop`
- **Khóa ngoại:** `MaKH` tham chiếu `KHOA_HOC(MaKH)`, `MaCS` tham chiếu `CO_SO(MaCS)`.

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaLop` | Mã lớp học | VARCHAR(20) | NO | PK | | Mã định danh lớp học duy nhất (vd: 'LOP_IE_01'). |
| `TenLop` | Tên lớp học | VARCHAR(150) | NO | | | Tên lớp (vd: 'Lớp IELTS Chuyên Sâu Tối 2-4-6'). |
| `MaKH` | Mã khóa học | VARCHAR(20) | NO | FK | | Khóa học mà lớp này trực thuộc. |
| `MaCS` | Mã cơ sở | VARCHAR(20) | NO | FK | | Cơ sở nơi lớp học được tổ chức. |
| `LichHoc` | Lịch học mô tả | VARCHAR(100) | NO | | | Chuỗi mô tả ca học (vd: 'T2-T4-T6 (18h-20h)'). |
| `SiSoToiDa` | Sĩ số tối đa | INT | NO | CHECK | 20 | Sĩ số giới hạn. CHECK: `SiSoToiDa > 0`. |
| `HocPhi` | Mức học phí của lớp | DECIMAL(12,2) | NO | CHECK | | Học phí áp dụng thực tế cho lớp. CHECK: `HocPhi >= 0`. |
| `TrangThai` | Trạng thái lớp | VARCHAR(25) | NO | CHECK | 'ChuanBi' | `'ChuanBi'`, `'DangNhanDangKy'`, `'DangHoc'`, `'DaKetThuc'`. |
| `NgayKhaiGiang` | Ngày khai giảng | DATE | YES | | NULL | Ngày dự kiến bắt đầu buổi học đầu tiên. |
| `NgayKetThuc` | Ngày kết thúc | DATE | YES | CHECK | NULL | Ngày bế giảng dự kiến. CHECK: `NgayKetThuc >= NgayKhaiGiang`. |

---

### 3.8. Bảng `GIANG_DAY` (Phân công giảng dạy)
- **Mục đích:** Biểu diễn quan hệ N-N giữa giáo viên và lớp học, ghi nhận vai trò giáo viên (giáo viên chính hoặc trợ giảng).
- **Khóa chính:** `(MaNS, MaLop)`
- **Khóa ngoại:** `MaNS` tham chiếu `GIAO_VIEN(MaNS)`, `MaLop` tham chiếu `LOP_HOC(MaLop)`.

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaNS` | Mã giáo viên | VARCHAR(20) | NO | PK, FK | | Tham chiếu `GIAO_VIEN(MaNS)`. |
| `MaLop` | Mã lớp học | VARCHAR(20) | NO | PK, FK | | Tham chiếu `LOP_HOC(MaLop)` (ON DELETE CASCADE). |
| `VaiTro` | Vai trò giảng dạy | VARCHAR(30) | NO | CHECK | 'GiaoVienChinh' | Miền giá trị: `'GiaoVienChinh'`, `'TroGiang'`. |
| `NgayPhanCong` | Ngày phân công | DATE | NO | | CURRENT_DATE | Thời điểm giáo vụ ghi nhận phân công. |

---

### 3.9. Bảng `DANG_KY` (Đăng ký học)
- **Mục đích:** Ghi nhận hồ sơ đăng ký của học viên vào lớp học; **chốt mức học phí phải thu** tại thời điểm xác nhận và quản lý công nợ.
- **Khóa chính:** `MaDK`
- **Khóa duy nhất (Unique):** `(MaHV, MaLop)` (Một học viên chỉ có 1 đăng ký duy nhất trong 1 lớp).
- **Khóa ngoại:** `MaHV` tham chiếu `HOC_VIEN(MaHV)`, `MaLop` tham chiếu `LOP_HOC(MaLop)`.

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaDK` | Mã đăng ký | VARCHAR(20) | NO | PK | | Mã định danh hồ sơ đăng ký duy nhất (vd: 'DK001'). |
| `MaHV` | Mã học viên | VARCHAR(20) | NO | FK, UNIQUE(1) | | Tham chiếu `HOC_VIEN(MaHV)`. |
| `MaLop` | Mã lớp học | VARCHAR(20) | NO | FK, UNIQUE(2) | | Tham chiếu `LOP_HOC(MaLop)`. |
| `NgayDK` | Ngày đăng ký | DATE | NO | | CURRENT_DATE | Ngày xác nhận ghi danh hoặc cập nhật đăng ký lại. |
| `KhoanPhaiThu` | Học phí chốt | DECIMAL(12,2) | NO | CHECK | | Số tiền học phí phải nộp chốt tại thời điểm đăng ký. |
| `HanNop` | Hạn nộp học phí | DATE | NO | CHECK | | Hạn cuối đóng tiền. CHECK: `HanNop >= NgayDK`. |
| `TrangThaiDK` | Trạng thái đăng ký | VARCHAR(20) | NO | CHECK | 'DaXacNhan' | Miền giá trị: `'DaXacNhan'`, `'DaHuy'`, `'DaHoanThanh'`. |

*Quy tắc nghiệp vụ:*
1. Cặp `(MaHV, MaLop)` là DUY NHẤT (`UNIQUE`).
2. Đăng ký có `TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')` được tính vào sĩ số hiện tại của lớp để kiểm tra `SiSoToiDa`; `DaHuy` không chiếm chỗ.
3. Khi học viên hủy đăng ký, bản ghi được cập nhật `TrangThaiDK = 'DaHuy'`. Nếu học viên đăng ký lại, cập nhật lại chính bản ghi này, kiểm tra chỗ trống, gán lại `NgayDK = CURRENT_DATE`, chốt lại `KhoanPhaiThu` theo mức học phí mới của lớp.

---

### 3.10. Bảng `PHIEU_THANH_TOAN` (Phiếu thanh toán / Lần thu học phí)
- **Mục đích:** Quản lý chi tiết từng lần nộp tiền học phí của học viên theo một mã đăng ký.
- **Khóa chính:** `MaPhieu`
- **Khóa ngoại:** `MaDK` tham chiếu `DANG_KY(MaDK)`.

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaPhieu` | Mã phiếu thanh toán | VARCHAR(20) | NO | PK | | Mã biên nhận thu tiền duy nhất (vd: 'PTT001'). |
| `MaDK` | Mã đăng ký | VARCHAR(20) | NO | FK | | Đăng ký được thanh toán. Tham chiếu `DANG_KY(MaDK)`. |
| `NgayThanhToan` | Thời điểm thanh toán | DATETIME | NO | | CURRENT_TIMESTAMP | Ngày và giờ lập phiếu thu theo giờ địa phương của trung tâm. |
| `SoTien` | Số tiền thu | DECIMAL(12,2) | NO | CHECK | | Số tiền đóng của lần này. Bắt buộc: `SoTien > 0`. |
| `PhuongThuc` | Hình thức thu tiền | VARCHAR(30) | NO | CHECK | 'TienMat' | `'TienMat'`, `'ChuyenKhoan'`, `'The'`, `'ViDienTu'`. |
| `TrangThai` | Trạng thái phiếu | VARCHAR(20) | NO | CHECK | 'ThanhCong' | Miền giá trị: `'ThanhCong'`, `'DaHuy'`. |
| `GhiChu` | Ghi chú thu tiền | VARCHAR(255) | YES | | NULL | Số mã giao dịch ngân hàng / lý do nộp. |

*Quy tắc nghiệp vụ kiểm tra:*
- Chỉ được lập phiếu thu cho đăng ký có `TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')`.
- Ràng buộc số tiền nộp: Số tiền nộp `SoTien` không được vượt quá số dư còn lại:  
  $$\text{SoTien} \le \text{KhoanPhaiThu} - \sum (\text{SoTien các phiếu 'ThanhCong' trước đó})$$

---

### 3.11. Bảng `DE_THI` (Đề thi)
- **Mục đích:** Danh mục các đề thi chuẩn được tạo ra và tái sử dụng cho các bài kiểm tra.
- **Khóa chính:** `MaDe`

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaDe` | Mã đề thi | VARCHAR(20) | NO | PK | | Mã định danh đề thi duy nhất (vd: 'DE01'). |
| `TenDe` | Tên đề thi | VARCHAR(150) | NO | | | Tên đề (vd: 'Đề thi giữa kỳ IELTS Listening Test 1'). |
| `ThoiLuong` | Thời lượng làm bài | INT | NO | CHECK | 60 | Thời lượng tính bằng phút. CHECK: `ThoiLuong > 0`. |
| `LoaiDe` | Loại hình đề thi | VARCHAR(50) | NO | | 'TracNghiem' | 'TracNghiem', 'TuLuan', 'KetHop', 'VanDap'. |
| `MoTa` | Mô tả chi tiết | TEXT | YES | | NULL | Cấu trúc đề, số lượng phần thi/câu hỏi. |

---

### 3.12. Bảng `BAI_KIEM_TRA` (Bài kiểm tra / Đợt đánh giá)
- **Mục đích:** Quản lý các bài kiểm tra, đợt đánh giá học tập được tổ chức trong phạm vi một lớp học cụ thể, sử dụng một đề thi.
- **Khóa chính:** `MaBKT`
- **Khóa ngoại:** `MaLop` tham chiếu `LOP_HOC(MaLop)`, `MaDe` tham chiếu `DE_THI(MaDe)`.

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaBKT` | Mã bài kiểm tra | VARCHAR(20) | NO | PK | | Mã định danh bài kiểm tra (vd: 'BKT01'). |
| `TenBKT` | Tên bài kiểm tra | VARCHAR(150) | NO | | | Tên gọi bài kiểm tra (vd: 'Kiểm tra Giữa kỳ'). |
| `MaLop` | Mã lớp học | VARCHAR(20) | NO | FK | | Lớp học được tổ chức bài kiểm tra. |
| `MaDe` | Mã đề thi | VARCHAR(20) | NO | FK | | Đề thi được sử dụng cho bài kiểm tra này. |
| `LoaiBKT` | Loại bài kiểm tra | VARCHAR(50) | NO | CHECK | 'GiuaKy' | `'GiuaKy'`, `'CuoiKy'`, `'ChuyenCan'`, `'DinhKy'`. |
| `ThangDiem` | Thang điểm tối đa | DECIMAL(4,2) | NO | CHECK | 10.00 | Thang điểm cao nhất. CHECK: `ThangDiem > 0`. |
| `NgayKiemTra` | Ngày tổ chức kiểm tra | DATE | YES | | NULL | Ngày diễn ra bài kiểm tra tại lớp. |

---

### 3.13. Bảng `LAM_BAI` (Kết quả làm bài kiểm tra)
- **Mục đích:** Lưu kết quả điểm số thi cử của học viên cho từng bài kiểm tra, hỗ trợ quản lý các đợt thi lại (`LanThi`).
- **Khóa chính:** `(MaHV, MaBKT, LanThi)`
- **Khóa ngoại:** `MaHV` tham chiếu `HOC_VIEN(MaHV)`, `MaBKT` tham chiếu `BAI_KIEM_TRA(MaBKT)`.

| Tên cột | Ý nghĩa nghiệp vụ | Kiểu dữ liệu | Null | Khóa / Ràng buộc | Giá trị mặc định | Diễn giải / Quy tắc |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `MaHV` | Mã học viên | VARCHAR(20) | NO | PK, FK | | Tham chiếu `HOC_VIEN(MaHV)`. |
| `MaBKT` | Mã bài kiểm tra | VARCHAR(20) | NO | PK, FK | | Tham chiếu `BAI_KIEM_TRA(MaBKT)` (ON DELETE CASCADE). |
| `LanThi` | Lần thi | INT | NO | PK, CHECK | 1 | Số thứ tự lần thi (1: thi lần đầu, 2: thi lại). CHECK: `LanThi >= 1`. |
| `NgayThi` | Ngày làm bài | DATE | NO | | CURRENT_DATE | Ngày học viên thực tế làm bài kiểm tra. |
| `Diem` | Điểm số đạt được | DECIMAL(4,2) | YES | CHECK | NULL | Điểm thi. `NULL`: Chưa chấm/chưa nhập. CHECK: `Diem >= 0`. |
| `GhiChu` | Nhận xét giáo viên | VARCHAR(255) | YES | | NULL | Nhận xét của giáo viên chấm bài. |

*Quy tắc nghiệp vụ kiểm tra:*
1. Học viên `MaHV` phải có đăng ký hợp lệ (`TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')`) tại lớp học mà bài kiểm tra `MaBKT` trực thuộc.
2. Giá trị `Diem` hợp lệ phải thỏa mãn: $0 \le \text{Diem} \le \text{ThangDiem}$ của bài kiểm tra đó.
3. Điểm 0 là điểm đã nhập (chứng minh học viên làm bài đạt 0 điểm). Giá trị `NULL` là học viên chưa có điểm / chưa nhập điểm. Khi tính điểm trung bình cho báo cáo của Huy, chỉ tính trung bình trên các bản ghi có điểm khác `NULL` (`AVG(Diem)` tự động bỏ qua `NULL`).

---

## 4. MA TRẬN RÀNG BUỘC TOÀN VẸN THAM CHIẾU (FOREIGN KEYS)

| STT | Bảng con (Child Table) | Cột khóa ngoại (FK) | Bảng cha (Parent Table) | Cột tham chiếu (PK) | Hành vi ON DELETE | Hành vi ON UPDATE |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | `GIAO_VIEN` | `MaNS` | `NHAN_SU` | `MaNS` | CASCADE | CASCADE |
| 2 | `NHAN_VIEN` | `MaNS` | `NHAN_SU` | `MaNS` | CASCADE | CASCADE |
| 3 | `LOP_HOC` | `MaKH` | `KHOA_HOC` | `MaKH` | RESTRICT | CASCADE |
| 4 | `LOP_HOC` | `MaCS` | `CO_SO` | `MaCS` | RESTRICT | CASCADE |
| 5 | `GIANG_DAY` | `MaNS` | `GIAO_VIEN` | `MaNS` | RESTRICT | CASCADE |
| 6 | `GIANG_DAY` | `MaLop` | `LOP_HOC` | `MaLop` | CASCADE | CASCADE |
| 7 | `DANG_KY` | `MaHV` | `HOC_VIEN` | `MaHV` | RESTRICT | CASCADE |
| 8 | `DANG_KY` | `MaLop` | `LOP_HOC` | `MaLop` | RESTRICT | CASCADE |
| 9 | `PHIEU_THANH_TOAN` | `MaDK` | `DANG_KY` | `MaDK` | RESTRICT | CASCADE |
| 10 | `BAI_KIEM_TRA` | `MaLop` | `LOP_HOC` | `MaLop` | CASCADE | CASCADE |
| 11 | `BAI_KIEM_TRA` | `MaDe` | `DE_THI` | `MaDe` | RESTRICT | CASCADE |
| 12 | `LAM_BAI` | `MaHV` | `HOC_VIEN` | `MaHV` | RESTRICT | CASCADE |
| 13 | `LAM_BAI` | `MaBKT` | `BAI_KIEM_TRA` | `MaBKT` | CASCADE | CASCADE |

---

## 5. CÔNG THỨC VÀ QUY TẮC TÍNH TOÁN CÁC CHỈ TIÊU DẪN XUẤT

Các chỉ tiêu dưới đây **không được lưu trữ trực tiếp dưới dạng cột cố định** trong cơ sở dữ liệu để tránh dư thừa và dị thường cập nhật, mà được tính toán trực tiếp trong các câu lệnh truy vấn SQL (View, Stored Procedure, hàm hoặc Query):

1. **Tổng tiền đã thu của một đăng ký (`TongDaThu`):**
   $$\text{TongDaThu} = \sum_{\text{TrangThai} = \text{'ThanhCong'}} \text{PHIEU\_THANH\_TOAN.SoTien}$$
   *(Nếu chưa có phiếu thanh toán thành công nào, giá trị mặc định là 0).*

2. **Số tiền còn phải thu / Số dư công nợ (`SoDu`):**
   $$\text{SoDu} = \text{DANG\_KY.KhoanPhaiThu} - \text{TongDaThu}$$
   *(Đối với đăng ký có `TrangThaiDK = 'DaHuy'`, số dư được quy ước là "Không áp dụng" - N/A).*

3. **Sĩ số thực tế hiện tại của lớp học (`SiSoHienTai`):**
   $$\text{SiSoHienTai} = \text{COUNT}(\text{DANG\_KY.MaDK}) \quad \text{với } \text{TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')}$$

4. **Số chỗ còn trống của lớp (`SoChoConLai`):**
   $$\text{SoChoConLai} = \text{LOP\_HOC.SiSoToiDa} - \text{SiSoHienTai}$$

5. **Trạng thái quá hạn học phí (`QuaHan`):**
   $$\text{QuaHan} = (\text{CURRENT\_DATE} > \text{DANG\_KY.HanNop}) \land (\text{SoDu} > 0) \land (\text{TrangThaiDK} = \text{'DaXacNhan'})$$

6. **Điểm trung bình bài kiểm tra theo lớp (`DiemTrungBinh`):**
   $$\text{DiemTrungBinh} = \text{AVG}(\text{LAM\_BAI.Diem}) \quad \text{với } \text{Diem IS NOT NULL}$$
   *(Hàm `AVG` trong SQL chuẩn tự động loại bỏ các giá trị `NULL`. Nếu chưa học viên nào có điểm, trả về `NULL` - hiển thị "Chưa có dữ liệu").*

---

## 6. ĐỐI CHIẾU VỚI CÁC MODULE CỦA KHANH, LỘC VÀ HUY

1. **Module Khanh (Hai form nhập liệu):**
   - **Form Đăng ký lớp:** Đọc `LOP_HOC(MaLop, TenLop, SiSoToiDa, HocPhi)` và `HOC_VIEN(MaHV, HoTen)`. Khi lưu, chèn vào `DANG_KY(MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK)`. Trường `KhoanPhaiThu` được gán chính xác bằng `LOP_HOC.HocPhi` tại thời điểm xác nhận.
   - **Form Thu học phí:** Đọc `DANG_KY(MaDK, KhoanPhaiThu)` kèm thông tin học viên và lớp; tính số dư tức thời từ `PHIEU_THANH_TOAN`. Khi thu, kiểm tra số tiền `SoTien <= SoDu`, chèn vào `PHIEU_THANH_TOAN(MaPhieu, MaDK, NgayThanhToan, SoTien, PhuongThuc, TrangThai)`.
2. **Module Lộc (Màn hình tìm kiếm):**
   - Đọc kết hợp `HOC_VIEN`, `DANG_KY`, `LOP_HOC` và nối trái (`LEFT JOIN`) với bảng tổng hợp `PHIEU_THANH_TOAN` nhóm theo `MaDK`. Đảm bảo mỗi đăng ký chỉ xuất hiện đúng một dòng, hiển thị đầy đủ `MaHV`, `HoTen`, `TenLop`, `TrangThaiDK`, `KhoanPhaiThu`, `TongDaThu`, `SoDu`.
3. **Module Huy (Hai báo cáo có thể xuất Excel):**
   - **Báo cáo Thu học phí:** Đọc `PHIEU_THANH_TOAN` lọc theo khoảng `NgayThanhToan` và `MaLop`, gom nhóm và tính tổng tiền thực thu.
   - **Báo cáo Kết quả kiểm tra:** Đọc `LOP_HOC`, `BAI_KIEM_TRA`, lấy danh sách học viên đăng ký đủ điều kiện qua `DANG_KY`, nối trái với `LAM_BAI` để thống kê số lượng đã nhập điểm, số lượng chưa nhập điểm, điểm 0 và điểm trung bình.

