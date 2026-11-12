# HỒ SƠ KIỂM TRA CHUẨN HÓA DỮ LIỆU (3NF / BCNF)
## HỆ THỐNG QUẢN LÝ TRUNG TÂM TIẾNG ANH
**Bài tập lớn môn Cơ sở dữ liệu · Nhóm 2**  
**Người phụ trách chuẩn hóa và chứng minh (Tiêu chí 4):** Quang  
**Phiên bản:** 1.0 · Ngày 12/11/2026  
**Căn cứ thiết kế:** Từ điển dữ liệu (`design/03_tu_dien_du_lieu.docx`) và Sơ đồ ERD (`design/02_erd.drawio`).

---

## 1. CƠ SỞ LÝ THUYẾT VỀ CHUẨN HÓA CƠ SỞ DỮ LIỆU

### 1.1. Các khái niệm nền tảng
Cho lược đồ quan hệ $R(A_1, A_2, \dots, A_n)$ với tập phụ thuộc hàm $F$:

1. **Phụ thuộc hàm (Functional Dependency - FD):**
   - Ký hiệu $X \to Y$ (với $X, Y \subseteq R$): Nếu hai bộ bất kỳ $t_1, t_2$ trong quan hệ có $t_1[X] = t_2[X]$ thì luôn suy ra $t_1[Y] = t_2[Y]$.
   - Phụ thuộc hàm tầm thường (Trivial FD): Nếu $Y \subseteq X$.
   - Phụ thuộc hàm không tầm thường (Non-trivial FD): Nếu $Y \not\subseteq X$.

2. **Bao đóng của tập thuộc tính (Attribute Closure):**
   - Ký hiệu $X^+$ là tập hợp tất cả các thuộc tính $A \in R$ mà $X \to A$ được suy dẫn logic từ $F$ thông qua hệ tiên đề Armstrong (phản xạ, tăng trưởng, bắc cầu).

3. **Siêu khóa (Superkey):**
   - Tập thuộc tính $K \subseteq R$ là siêu khóa của $R$ nếu $K^+ = R$ (tức là $K$ xác định hàm toàn bộ các thuộc tính của quan hệ).

4. **Khóa ứng viên (Candidate Key - CK):**
   - Tập thuộc tính $K \subseteq R$ là khóa ứng viên của $R$ nếu:
     - $K$ là một siêu khóa ($K^+ = R$).
     - $K$ có tính tối thiểu (không tồn tại bất kỳ tập con thực sự nào $K' \subset K$ sao cho $K'^+ = R$).

5. **Thuộc tính khóa và thuộc tính không khóa:**
   - **Thuộc tính khóa (Prime Attribute):** Là thuộc tính xuất hiện trong **ít nhất một** khóa ứng viên của quan hệ.
   - **Thuộc tính không khóa (Non-prime Attribute):** Là thuộc tính **không xuất hiện trong bất kỳ** khóa ứng viên nào của quan hệ.

### 1.2. Định nghĩa các dạng chuẩn (Normal Forms)
1. **Dạng chuẩn 1 (1NF - First Normal Form):**
   - Một lược đồ quan hệ $R$ đạt 1NF nếu và chỉ nếu miền giá trị của tất cả các thuộc tính trong $R$ chỉ chứa các giá trị nguyên tố (atomic values - đơn trị), không có thuộc tính đa trị (multivalued) hay thuộc tính phức hợp (composite).

2. **Dạng chuẩn 2 (2NF - Second Normal Form):**
   - Một lược đồ quan hệ $R$ đạt 2NF nếu và chỉ nếu $R$ đạt 1NF và **mọi thuộc tính không khóa đều phụ thuộc hàm đầy đủ vào mỗi khóa ứng viên** của $R$ (không tồn tại bất kỳ thuộc tính không khóa nào phụ thuộc hàm vào một tập con thực sự của bất kỳ khóa ứng viên nào).

3. **Dạng chuẩn 3 (3NF - Third Normal Form):**
   - Một lược đồ quan hệ $R$ đạt 3NF nếu và chỉ nếu $R$ đạt 2NF và không có thuộc tính không khóa nào phụ thuộc bắc cầu vào khóa chính.
   - **Định nghĩa chuẩn tương đương của 3NF:** Với mọi phụ thuộc hàm không tầm thường $X \to Y \in F^+$, ít nhất một trong hai điều kiện sau phải thỏa mãn:
     - $X$ là một **siêu khóa** của $R$.
     - Mọi thuộc tính $A \in Y \setminus X$ đều là **thuộc tính khóa** (thuộc một khóa ứng viên nào đó của $R$).

4. **Dạng chuẩn Boyce-Codd (BCNF - Boyce-Codd Normal Form):**
   - Một lược đồ quan hệ $R$ đạt BCNF nếu và chỉ nếu với **mọi** phụ thuộc hàm không tầm thường $X \to Y \in F^+$, vế trái $X$ đều phải là một **siêu khóa** của $R$.
   - BCNF là dạng chuẩn nghiêm ngặt hơn 3NF (loại bỏ hoàn toàn dị thường cập nhật do phụ thuộc giữa các thuộc tính khóa gây ra).

---

## 2. PHÂN TÍCH VÀ CHỨNG MINH 3NF CHO TỪNG BẢNG

---

### 2.1. Bảng `CO_SO` (Cơ sở đào tạo)
- **Tập thuộc tính:**
  $$R_1 = \{\text{MaCS}, \text{TenCS}, \text{DiaChi}, \text{SDT}, \text{TrangThai}\}$$
- **Tập phụ thuộc hàm $F_1$:**
  - $f_{1.1}: \text{MaCS} \to \text{TenCS}, \text{DiaChi}, \text{SDT}, \text{TrangThai}$
- **Tìm khóa ứng viên:**
  - $(\text{MaCS})^+ = \{\text{MaCS}, \text{TenCS}, \text{DiaChi}, \text{SDT}, \text{TrangThai}\} = R_1$.
  - $\implies CK_1 = \{\text{MaCS}\}$. Khóa chính chọn: `MaCS`.
- **Phân loại thuộc tính:**
  - Thuộc tính khóa: `MaCS`.
  - Thuộc tính không khóa: `TenCS`, `DiaChi`, `SDT`, `TrangThai`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Mọi cột đều lưu dữ liệu nguyên tố (chuỗi ký tự, không lặp). $\to$ Đạt 1NF.
  2. **2NF:** Khóa ứng viên chỉ gồm 1 thuộc tính đơn (`MaCS`), do đó không thể tồn tại phụ thuộc bộ phận vào tập con của khóa. $\to$ Đạt 2NF.
  3. **3NF:** Với phụ thuộc hàm không tầm thường duy nhất $f_{1.1}$, vế trái $X = \{\text{MaCS}\}$ là siêu khóa của $R_1$. Không có phụ thuộc bắc cầu giữa các thuộc tính không khóa. $\to$ Đạt 3NF.
  4. **BCNF:** Mọi vế trái của các phụ thuộc hàm không tầm thường đều là siêu khóa. $\to$ Đạt BCNF.
- **Kết luận:** Bảng `CO_SO` đạt dạng chuẩn cao nhất **BCNF (và hiển nhiên đạt 3NF)**.

---

### 2.2. Bảng `KHOA_HOC` (Khóa học đào tạo)
- **Tập thuộc tính:**
  $$R_2 = \{\text{MaKH}, \text{TenKH}, \text{GiaKH}, \text{ThoiLuong}, \text{MoTa}, \text{TrangThai}\}$$
- **Tập phụ thuộc hàm $F_2$:**
  - $f_{2.1}: \text{MaKH} \to \text{TenKH}, \text{GiaKH}, \text{ThoiLuong}, \text{MoTa}, \text{TrangThai}$
- **Tìm khóa ứng viên:**
  - $(\text{MaKH})^+ = R_2 \implies CK_1 = \{\text{MaKH}\}$. Khóa chính chọn: `MaKH`.
- **Phân loại thuộc tính:**
  - Thuộc tính khóa: `MaKH`.
  - Thuộc tính không khóa: `TenKH`, `GiaKH`, `ThoiLuong`, `MoTa`, `TrangThai`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Tất cả các thuộc tính đều nguyên tố. $\to$ Đạt 1NF.
  2. **2NF:** Khóa là đơn thuộc tính (`MaKH`), không có phụ thuộc bộ phận. $\to$ Đạt 2NF.
  3. **3NF & BCNF:** Vế trái của phụ thuộc hàm $f_{2.1}$ là siêu khóa. Không có phụ thuộc bắc cầu.
- **Kết luận:** Bảng `KHOA_HOC` đạt **BCNF (và 3NF)**.

---

### 2.3. Bảng `NHAN_SU` (Nhân sự)
- **Tập thuộc tính:**
  $$R_3 = \{\text{MaNS}, \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{SDT}, \text{Email}, \text{DiaChi}, \text{TrangThai}\}$$
- **Tập phụ thuộc hàm $F_3$:**
  Theo quy định nhân sự của trung tâm, mỗi nhân sự có mã số riêng, đồng thời số điện thoại và email cá nhân là duy nhất:
  - $f_{3.1}: \text{MaNS} \to \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{SDT}, \text{Email}, \text{DiaChi}, \text{TrangThai}$
  - $f_{3.2}: \text{SDT} \to \text{MaNS}, \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{Email}, \text{DiaChi}, \text{TrangThai}$
  - $f_{3.3}: \text{Email} \to \text{MaNS}, \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{SDT}, \text{DiaChi}, \text{TrangThai}$
- **Tìm khóa ứng viên:**
  - $(\text{MaNS})^+ = R_3 \implies CK_1 = \{\text{MaNS}\}$.
  - $(\text{SDT})^+ = R_3 \implies CK_2 = \{\text{SDT}\}$.
  - $(\text{Email})^+ = R_3 \implies CK_3 = \{\text{Email}\}$.
  - Chọn khóa chính: `MaNS`. Hai khóa ứng viên còn lại `SDT`, `Email` được cài đặt ràng buộc `UNIQUE`.
- **Phân loại thuộc tính:**
  - Thuộc tính khóa: `MaNS`, `SDT`, `Email`.
  - Thuộc tính không khóa: `HoTen`, `NgaySinh`, `GioiTinh`, `DiaChi`, `TrangThai`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Dữ liệu nguyên tố. $\to$ Đạt 1NF.
  2. **2NF:** Mọi khóa ứng viên đều là khóa đơn lẻ (1 thuộc tính). Mọi thuộc tính không khóa phụ thuộc đầy đủ vào từng khóa ứng viên. $\to$ Đạt 2NF.
  3. **3NF & BCNF:** Xét mọi phụ thuộc hàm không tầm thường trong $F_3$, các vế trái $X \in \{\text{MaNS}, \text{SDT}, \text{Email}\}$ đều là siêu khóa của $R_3$. Do đó điều kiện BCNF được thỏa mãn hoàn toàn.
- **Kết luận:** Bảng `NHAN_SU` đạt **BCNF (và 3NF)**.

---

### 2.4. Bảng `GIAO_VIEN` (Giáo viên - Chuyên biệt hóa ISA)
- **Tập thuộc tính:**
  $$R_4 = \{\text{MaNS}, \text{HocVi}, \text{ChuyenMon}\}$$
- **Tập phụ thuộc hàm $F_4$:**
  - $f_{4.1}: \text{MaNS} \to \text{HocVi}, \text{ChuyenMon}$
- **Khóa ứng viên:** $CK_1 = \{\text{MaNS}\}$. Khóa chính chọn: `MaNS` (đồng thời là khóa ngoại tham chiếu `NHAN_SU.MaNS`).
- **Kiểm tra:**
  - Vế trái `MaNS` là siêu khóa. Khóa đơn, không phụ thuộc bộ phận, không phụ thuộc bắc cầu.
- **Kết luận:** Bảng `GIAO_VIEN` đạt **BCNF (và 3NF)**.

---

### 2.5. Bảng `NHAN_VIEN` (Nhân viên hành chính - Chuyên biệt hóa ISA)
- **Tập thuộc tính:**
  $$R_5 = \{\text{MaNS}, \text{ViTri}\}$$
- **Tập phụ thuộc hàm $F_5$:**
  - $f_{5.1}: \text{MaNS} \to \text{ViTri}$
- **Khóa ứng viên:** $CK_1 = \{\text{MaNS}\}$. Khóa chính chọn: `MaNS` (FK tham chiếu `NHAN_SU.MaNS`).
- **Kiểm tra:**
  - Vế trái `MaNS` là siêu khóa.
- **Kết luận:** Bảng `NHAN_VIEN` đạt **BCNF (và 3NF)**.

---

### 2.6. Bảng `HOC_VIEN` (Học viên)
- **Tập thuộc tính:**
  $$R_6 = \{\text{MaHV}, \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{SDT}, \text{Email}, \text{DiaChi}, \text{NgayTao}\}$$
- **Tập phụ thuộc hàm $F_6$:**
  Tương tự hồ sơ nhân sự, mỗi học viên có mã định danh `MaHV`, số điện thoại và email độc lập:
  - $f_{6.1}: \text{MaHV} \to \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{SDT}, \text{Email}, \text{DiaChi}, \text{NgayTao}$
  - $f_{6.2}: \text{SDT} \to \text{MaHV}, \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{Email}, \text{DiaChi}, \text{NgayTao}$
  - $f_{6.3}: \text{Email} \to \text{MaHV}, \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{SDT}, \text{DiaChi}, \text{NgayTao}$
- **Tìm khóa ứng viên:**
  - $CK_1 = \{\text{MaHV}\}$, $CK_2 = \{\text{SDT}\}$, $CK_3 = \{\text{Email}\}$.
  - Khóa chính chọn: `MaHV`. Cài đặt ràng buộc `UNIQUE` cho `SDT` và `Email`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Mọi thuộc tính đều mang giá trị đơn nhất. $\to$ Đạt 1NF.
  2. **2NF:** Tất cả các khóa ứng viên đều là khóa đơn vị. Mọi thuộc tính không khóa đều phụ thuộc đầy đủ vào từng khóa. $\to$ Đạt 2NF.
  3. **3NF & BCNF:** Mọi vế trái trong $F_6$ đều là siêu khóa của quan hệ.
- **Kết luận:** Bảng `HOC_VIEN` đạt **BCNF (và 3NF)**.

---

### 2.7. Bảng `LOP_HOC` (Lớp học)
- **Tập thuộc tính:**
  $$R_7 = \{\text{MaLop}, \text{TenLop}, \text{MaKH}, \text{MaCS}, \text{LichHoc}, \text{SiSoToiDa}, \text{HocPhi}, \text{TrangThai}, \text{NgayKhaiGiang}, \text{NgayKetThuc}\}$$
- **Tập phụ thuộc hàm $F_7$:**
  - $f_{7.1}: \text{MaLop} \to \text{TenLop}, \text{MaKH}, \text{MaCS}, \text{LichHoc}, \text{SiSoToiDa}, \text{HocPhi}, \text{TrangThai}, \text{NgayKhaiGiang}, \text{NgayKetThuc}$
- **Chứng minh không có phụ thuộc hàm ngoài $f_{7.1}$:**
  - *Câu hỏi thiết kế quan trọng:* Liệu có phụ thuộc hàm $\text{MaKH} \to \text{HocPhi}$ hay không?  
    **Trả lời:** **KHÔNG**. Trong bảng `KHOA_HOC`, cột `GiaKH` chỉ là mức giá danh mục niêm yết (tham khảo). Mỗi lớp học cụ thể mở theo thời gian, hình thức hoặc ca học khác nhau có thể áp dụng mức `HocPhi` riêng (ví dụ: lớp học cuối tuần có học phí khác ngày thường, hoặc lớp có chương trình ưu đãi đầu năm). Do đó, một khóa học có thể có nhiều lớp với mức học phí khác nhau: $\text{MaKH} \not\to \text{HocPhi}$. Thuộc tính `HocPhi` phụ thuộc đầy đủ và trực tiếp vào `MaLop`.
  - Tương tự, một khóa học mở nhiều lớp ($\text{MaKH} \not\to \text{MaLop}$), một cơ sở tổ chức nhiều lớp ($\text{MaCS} \not\to \text{MaLop}$).
- **Tìm khóa ứng viên:**
  - $(\text{MaLop})^+ = R_7 \implies CK_1 = \{\text{MaLop}\}$. Khóa chính chọn: `MaLop`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Các cột đều nguyên tố. $\to$ Đạt 1NF.
  2. **2NF:** Khóa chính đơn (`MaLop`), không tồn tại phụ thuộc hàm bộ phận. $\to$ Đạt 2NF.
  3. **3NF & BCNF:** Vế trái của $f_{7.1}$ là siêu khóa. Không có phụ thuộc bắc cầu giữa các thuộc tính không khóa.
- **Kết luận:** Bảng `LOP_HOC` đạt **BCNF (và 3NF)**.

---

### 2.8. Bảng `GIANG_DAY` (Phân công giảng dạy)
- **Tập thuộc tính:**
  $$R_8 = \{\text{MaNS}, \text{MaLop}, \text{VaiTro}, \text{NgayPhanCong}\}$$
- **Tập phụ thuộc hàm $F_8$:**
  Theo quy tắc nghiệp vụ C02 và bảng số N-N giữa giáo viên và lớp học:
  - Một giáo viên có thể tham gia giảng dạy nhiều lớp.
  - Một lớp có thể có nhiều giáo viên (ví dụ: 1 giáo viên chính và 1 trợ giảng phụ trách chữa bài).
  - Do đó, để xác định vai trò và ngày phân công, bắt buộc phải biết đồng thời cả giáo viên và lớp học:
  - $f_{8.1}: (\text{MaNS}, \text{MaLop}) \to \text{VaiTro}, \text{NgayPhanCong}$
- **Tìm khóa ứng viên:**
  - $(\text{MaNS}, \text{MaLop})^+ = R_8 \implies CK_1 = \{(\text{MaNS}, \text{MaLop})\}$.
  - Khóa chính chọn: Cặp thuộc tính kết hợp `(MaNS, MaLop)`.
- **Phân loại thuộc tính:**
  - Thuộc tính khóa: `MaNS`, `MaLop`.
  - Thuộc tính không khóa: `VaiTro`, `NgayPhanCong`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Đạt 1NF.
  2. **2NF:** 
     - Xét thuộc tính không khóa `VaiTro`: Giáo viên `MaNS` tham gia lớp A có thể là `GiaoVienChinh`, nhưng ở lớp B có thể là `TroGiang`. Do đó $\text{MaNS} \not\to \text{VaiTro}$ và $\text{MaLop} \not\to \text{VaiTro}$.
     - Tương tự với `NgayPhanCong`: Mỗi phân công có thời điểm riêng, không thể suy ra từ `MaNS` hay `MaLop` đơn lẻ.
     - Như vậy, các thuộc tính không khóa phụ thuộc hàm đầy đủ vào toàn bộ khóa chính hợp thành $\{(\text{MaNS}, \text{MaLop})\}$, không phụ thuộc vào bất kỳ tập con thực sự nào. $\to$ Đạt 2NF.
  3. **3NF & BCNF:** Vế trái của $f_{8.1}$ là siêu khóa duy nhất của $R_8$. Không có thuộc tính không khóa nào phụ thuộc bắc cầu.
- **Kết luận:** Bảng `GIANG_DAY` đạt **BCNF (và 3NF)**.

---

### 2.9. Bảng `DANG_KY` (Đăng ký học)
- **Tập thuộc tính:**
  $$R_9 = \{\text{MaDK}, \text{MaHV}, \text{MaLop}, \text{NgayDK}, \text{KhoanPhaiThu}, \text{HanNop}, \text{TrangThaiDK}\}$$
- **Tập phụ thuộc hàm $F_9$:**
  Dựa trên quy tắc nghiệp vụ đề tài (mục DK02: mỗi học viên chỉ có đúng một bản ghi đăng ký trong một lớp nhất định) và mã định danh tự sinh `MaDK`:
  - $f_{9.1}: \text{MaDK} \to \text{MaHV}, \text{MaLop}, \text{NgayDK}, \text{KhoanPhaiThu}, \text{HanNop}, \text{TrangThaiDK}$
  - $f_{9.2}: (\text{MaHV}, \text{MaLop}) \to \text{MaDK}, \text{NgayDK}, \text{KhoanPhaiThu}, \text{HanNop}, \text{TrangThaiDK}$
- **Tìm khóa ứng viên:**
  - $(\text{MaDK})^+ = R_9 \implies CK_1 = \{\text{MaDK}\}$ (Khóa đại diện nhân tạo - Surrogate Key).
  - $(\text{MaHV}, \text{MaLop})^+ = R_9 \implies CK_2 = \{(\text{MaHV}, \text{MaLop})\}$ (Khóa tự nhiên kết hợp - Natural Key).
  - Khóa chính được chọn: `MaDK` (nhằm tối ưu hiệu năng tạo khóa ngoại ở bảng `PHIEU_THANH_TOAN`). Cặp `(MaHV, MaLop)` được gắn ràng buộc `UNIQUE`.
- **Phân loại thuộc tính:**
  - Thuộc tính khóa: `MaDK`, `MaHV`, `MaLop` (vì thuộc ít nhất một khóa ứng viên: $CK_1$ hoặc $CK_2$).
  - Thuộc tính không khóa: `NgayDK`, `KhoanPhaiThu`, `HanNop`, `TrangThaiDK`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Các trường đều nguyên tố. $\to$ Đạt 1NF.
  2. **2NF:**
     - Xét đối với khóa $CK_1 = \{\text{MaDK}\}$: Là khóa đơn, hiển nhiên mọi thuộc tính không khóa đều phụ thuộc đầy đủ vào `MaDK`.
     - Xét đối với khóa $CK_2 = \{(\text{MaHV}, \text{MaLop})\}$: 
       - `MaHV` một mình không xác định được `NgayDK`, `KhoanPhaiThu`, `HanNop` (vì 1 học viên đăng ký nhiều lớp khác nhau với ngày, học phí, hạn nộp khác nhau).
       - `MaLop` một mình không xác định được `NgayDK`, `HanNop` (mỗi học viên đăng ký vào ngày khác nhau).
       - Đối với `KhoanPhaiThu`: Học viên đăng ký vào thời điểm khác nhau hoặc được hưởng chính sách tại thời điểm xác nhận (snapshot) nên `KhoanPhaiThu` phụ thuộc vào chính lượt đăng ký của học viên đó vào lớp đó.
       - Do đó, không có thuộc tính không khóa nào phụ thuộc vào tập con thực sự của $CK_2$.
     - $\implies$ Đạt 2NF.
  3. **3NF & BCNF:**
     - Xét các phụ thuộc hàm không tầm thường $f_{9.1}$ và $f_{9.2}$:
       - Vế trái của $f_{9.1}$ là $X_1 = \{\text{MaDK}\}$, là một siêu khóa.
       - Vế trái của $f_{9.2}$ là $X_2 = \{(\text{MaHV}, \text{MaLop})\}$, cũng là một siêu khóa.
     - Vì **mọi** vế trái của các phụ thuộc hàm không tầm thường đều là siêu khóa của $R_9$, điều kiện của BCNF được thỏa mãn triệt để.
- **Kết luận:** Bảng `DANG_KY` đạt **BCNF (và 3NF)**.

---

### 2.10. Bảng `PHIEU_THANH_TOAN` (Phiếu thanh toán / Lần thu học phí)
- **Tập thuộc tính:**
  $$R_{10} = \{\text{MaPhieu}, \text{MaDK}, \text{NgayThanhToan}, \text{SoTien}, \text{PhuongThuc}, \text{TrangThai}, \text{GhiChu}\}$$
- **Tập phụ thuộc hàm $F_{10}$:**
  Mỗi phiếu thanh toán có một mã biên nhận duy nhất `MaPhieu`. Một đăng ký có thể được đóng tiền nhiều lần (trả góp/chia đợt):
  - $f_{10.1}: \text{MaPhieu} \to \text{MaDK}, \text{NgayThanhToan}, \text{SoTien}, \text{PhuongThuc}, \text{TrangThai}, \text{GhiChu}$
  - Lưu ý: Do một đăng ký có thể có nhiều phiếu thanh toán, nên $\text{MaDK} \not\to \text{MaPhieu}$, $\text{MaDK} \not\to \text{SoTien}$.
- **Tìm khóa ứng viên:**
  - $(\text{MaPhieu})^+ = R_{10} \implies CK_1 = \{\text{MaPhieu}\}$. Khóa chính chọn: `MaPhieu`.
- **Phân loại thuộc tính:**
  - Thuộc tính khóa: `MaPhieu`.
  - Thuộc tính không khóa: `MaDK`, `NgayThanhToan`, `SoTien`, `PhuongThuc`, `TrangThai`, `GhiChu`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Đạt 1NF.
  2. **2NF:** Khóa đơn vị `MaPhieu`, không có phụ thuộc bộ phận. $\to$ Đạt 2NF.
  3. **3NF & BCNF:** Vế trái của $f_{10.1}$ là siêu khóa duy nhất. Không có phụ thuộc bắc cầu giữa các thuộc tính không khóa. $\to$ Đạt BCNF và 3NF.
- **Kết luận:** Bảng `PHIEU_THANH_TOAN` đạt **BCNF (và 3NF)**.

---

### 2.11. Bảng `DE_THI` (Đề thi)
- **Tập thuộc tính:**
  $$R_{11} = \{\text{MaDe}, \text{TenDe}, \text{ThoiLuong}, \text{LoaiDe}, \text{MoTa}\}$$
- **Tập phụ thuộc hàm $F_{11}$:**
  - $f_{11.1}: \text{MaDe} \to \text{TenDe}, \text{ThoiLuong}, \text{LoaiDe}, \text{MoTa}$
- **Khóa ứng viên:** $CK_1 = \{\text{MaDe}\}$. Khóa chính: `MaDe`.
- **Kết luận:** Bảng `DE_THI` đạt **BCNF (và 3NF)**.

---

### 2.12. Bảng `BAI_KIEM_TRA` (Bài kiểm tra / Đợt đánh giá)
- **Tập thuộc tính:**
  $$R_{12} = \{\text{MaBKT}, \text{TenBKT}, \text{MaLop}, \text{MaDe}, \text{LoaiBKT}, \text{ThangDiem}, \text{NgayKiemTra}\}$$
- **Tập phụ thuộc hàm $F_{12}$:**
  - $f_{12.1}: \text{MaBKT} \to \text{TenBKT}, \text{MaLop}, \text{MaDe}, \text{LoaiBKT}, \text{ThangDiem}, \text{NgayKiemTra}$
- **Chứng minh tính độc lập của các thuộc tính:**
  - Một lớp học có thể có nhiều bài kiểm tra (giữa kỳ, cuối kỳ) $\implies \text{MaLop} \not\to \text{MaBKT}$.
  - Một đề thi có thể dùng chung cho nhiều bài kiểm tra ở các lớp khác nhau $\implies \text{MaDe} \not\to \text{MaBKT}$.
  - Thang điểm và loại bài kiểm tra gắn liền với bài kiểm tra cụ thể đó.
- **Khóa ứng viên:** $CK_1 = \{\text{MaBKT}\}$. Khóa chính: `MaBKT`.
- **Kết luận:** Bảng `BAI_KIEM_TRA` đạt **BCNF (và 3NF)**.

---

### 2.13. Bảng `LAM_BAI` (Kết quả làm bài kiểm tra)
- **Tập thuộc tính:**
  $$R_{13} = \{\text{MaHV}, \text{MaBKT}, \text{LanThi}, \text{NgayThi}, \text{Diem}, \text{GhiChu}\}$$
- **Tập phụ thuộc hàm $F_{13}$:**
  Theo yêu cầu nghiệp vụ và mở rộng C03, hệ thống cho phép học viên thi lại nếu điểm chưa đạt hoặc vắng có lý do:
  - Một học viên `MaHV` tham gia một bài kiểm tra `MaBKT` có thể có nhiều lần thi (`LanThi = 1, 2, ...`).
  - Mỗi lần thi cụ thể của một học viên đối với một bài kiểm tra sẽ xác định ngày thi thực tế và điểm số đạt được:
  - $f_{13.1}: (\text{MaHV}, \text{MaBKT}, \text{LanThi}) \to \text{NgayThi}, \text{Diem}, \text{GhiChu}$
- **Tìm khóa ứng viên:**
  - $(\text{MaHV}, \text{MaBKT}, \text{LanThi})^+ = R_{13} \implies CK_1 = \{(\text{MaHV}, \text{MaBKT}, \text{LanThi})\}$.
  - Khóa chính được chọn: Bộ 3 thuộc tính `(MaHV, MaBKT, LanThi)`.
- **Phân loại thuộc tính:**
  - Thuộc tính khóa: `MaHV`, `MaBKT`, `LanThi`.
  - Thuộc tính không khóa: `NgayThi`, `Diem`, `GhiChu`.
- **Kiểm tra các dạng chuẩn:**
  1. **1NF:** Đạt 1NF.
  2. **2NF:**
     - Xét thuộc tính `Diem`:
       - Chỉ biết `MaHV` không xác định được điểm ($\text{MaHV} \not\to \text{Diem}$).
       - Chỉ biết `MaBKT` không xác định được điểm ($\text{MaBKT} \not\to \text{Diem}$).
       - Biết cặp $(\text{MaHV}, \text{MaBKT})$ vẫn chưa đủ xác định nếu học viên thi lại 2 lần (lần 1 được 4 điểm, lần 2 thi lại được 8 điểm). Do đó $(\text{MaHV}, \text{MaBKT}) \not\to \text{Diem}$.
       - Điểm số `Diem` phụ thuộc hàm đầy đủ vào cả bộ ba $(\text{MaHV}, \text{MaBKT}, \text{LanThi})$.
     - Tương tự đối với `NgayThi` và `GhiChu`.
     - Như vậy, mọi thuộc tính không khóa đều phụ thuộc đầy đủ vào toàn bộ khóa ứng viên, không phụ thuộc bộ phận vào bất kỳ tập con nào của khóa. $\to$ Đạt 2NF.
  3. **3NF & BCNF:**
     - Vế trái của phụ thuộc hàm $f_{13.1}$ là tập $\{(\text{MaHV}, \text{MaBKT}, \text{LanThi})\}$, chính là siêu khóa duy nhất của quan hệ $R_{13}$.
     - Do đó, quan hệ đạt chuẩn BCNF và hiển nhiên đạt 3NF.
- **Kết luận:** Bảng `LAM_BAI` đạt **BCNF (và 3NF)**.

---

## 3. CÁC QUYẾT ĐỊNH THIẾT KẾ CỐT LÕI VÀ CHỨNG MINH KỸ THUẬT

### 3.1. Giải thích lưu trữ `KhoanPhaiThu` tại bảng `DANG_KY` và tính toán `SoDu` từ `PHIEU_THANH_TOAN`
Trong quá trình thiết kế, hai câu hỏi nghiệp vụ và kỹ thuật cốt lõi được đặt ra:
1. *Tại sao `KhoanPhaiThu` lại được lưu trực tiếp tại bảng `DANG_KY` mà không lấy trực tiếp qua khóa ngoại từ `LOP_HOC.HocPhi`? Liệu việc này có làm dư thừa dữ liệu hay vi phạm 3NF không?*
2. *Tại sao trường `SoDu` (số tiền còn thiếu) và `TongDaThu` lại KHÔNG được lưu thành cột trong bảng `DANG_KY`?*

#### Chứng minh:
- **Bản chất của `KhoanPhaiThu`:**
  - Về mặt kế toán tài chính, khi một học viên ký hợp đồng đăng ký học và được trung tâm xác nhận (`TrangThaiDK = 'DaXacNhan'`), khoản học phí được hình thành như một nghĩa vụ công nợ pháp lý cố định tại thời điểm đó (gọi là *Snapshot Fact* / *Historical Data*).
  - Giả sử lớp học ban đầu có mức học phí là 3.000.000 VNĐ. Học viên A đăng ký ngày 01/10/2026 với `KhoanPhaiThu = 3.000.000`. Đến ngày 15/10/2026, do chính sách lạm phát hoặc đổi mới giáo trình, trung tâm điều chỉnh học phí của lớp `LOP_HOC.HocPhi = 3.500.000 VNĐ`.
  - Nếu hệ thống không lưu `KhoanPhaiThu` ở `DANG_KY` mà luôn truy vấn động từ `LOP_HOC.HocPhi`, thì học viên A (đã đăng ký trước đó) sẽ tự động bị hệ thống báo nợ tăng lên 3.500.000 VNĐ. Điều này hoàn toàn sai lệch về mặt nghiệp vụ kế toán và xâm phạm hợp đồng đã chốt.
  - Về mặt lý thuyết chuẩn hóa: `KhoanPhaiThu` phụ thuộc vào chính sự kiện đăng ký cụ thể của học viên ($\text{MaDK} \to \text{KhoanPhaiThu}$). Nó không phụ thuộc vào `LOP_HOC.HocPhi` trong tương lai. Do đó, phụ thuộc hàm $\text{MaDK} \to \text{KhoanPhaiThu}$ là hoàn toàn hợp lệ, vế trái là siêu khóa, **không vi phạm 3NF/BCNF**.
- **Bản chất của `TongDaThu` và `SoDu`:**
  - Ngược lại với `KhoanPhaiThu`, `TongDaThu` là tổng số tiền của các phiếu thanh toán hợp lệ theo đăng ký:
    $$\text{TongDaThu} = \sum \text{PHIEU\_THANH\_TOAN.SoTien}$$
  - `SoDu` là hiệu số:
    $$\text{SoDu} = \text{DANG\_KY.KhoanPhaiThu} - \text{TongDaThu}$$
  - Nếu ta lưu thêm 2 cột `TongDaThu` và `SoDu` vào bảng `DANG_KY`, ta sẽ tạo ra phụ thuộc hàm giữa các thuộc tính không khóa:
    $$\{\text{KhoanPhaiThu}, \text{TongDaThu}\} \to \text{SoDu}$$
  - Điều này trực tiếp vi phạm nguyên tắc chuẩn hóa 3NF (tạo ra phụ thuộc hàm bắc cầu) và gây ra **dị thường cập nhật (Update Anomaly)**: Khi nhân viên thêm một phiếu thu mới, hoặc khi hủy một phiếu thu sai, lập trình viên bắt buộc phải nhớ cập nhật lại 2 cột `TongDaThu` và `SoDu` ở bảng cha. Nếu một giao dịch gặp lỗi giữa chừng, dữ liệu sẽ bị mất nhất quán (số tiền trên các phiếu không khớp với số dư hiển thị).
  - **Kết luận:** Quyết định lưu `KhoanPhaiThu` tại `DANG_KY` và tính toán động `TongDaThu`, `SoDu` thông qua truy vấn tổng hợp `SUM` là giải pháp kỹ thuật tối ưu, vừa bảo đảm tính toàn vẹn lịch sử vừa tuân thủ tuyệt đối chuẩn 3NF.

---

### 3.2. Chứng minh phân rã chuyên biệt hóa (ISA) Nhân sự: Tính nối không mất mát và bảo toàn phụ thuộc
Trong ERD, thực thể tổng quát `NHAN_SU` có hai chuyên biệt hóa là `GIÁO VIÊN` và `NHÂN VIÊN`. Ta phân rã thành 3 bảng quan hệ:
- $R_{NS} = \{\text{MaNS}, \text{HoTen}, \text{NgaySinh}, \text{GioiTinh}, \text{SDT}, \text{Email}, \text{DiaChi}, \text{TrangThai}\}$
- $R_{GV} = \{\text{MaNS}, \text{HocVi}, \text{ChuyenMon}\}$
- $R_{NV} = \{\text{MaNS}, \text{ViTri}\}$

#### 1. Chứng minh Tính nối không mất mát (Lossless-Join Decomposition):
- Định lý: Phép phân rã lược đồ $R$ thành hai lược đồ con $(R_1, R_2)$ là nối không mất mát đối với tập phụ thuộc hàm $F$ nếu và chỉ nếu:
  $$(R_1 \cap R_2) \to R_1 \quad \text{hoặc} \quad (R_1 \cap R_2) \to R_2$$
- Xét phép nối giữa $R_{NS}$ và $R_{GV}$:
  - Tập giao: $R_{NS} \cap R_{GV} = \{\text{MaNS}\}$.
  - Trong lược đồ $R_{GV}$, ta có phụ thuộc hàm: $\text{MaNS} \to \text{HocVi}, \text{ChuyenMon}$. Do đó:
    $$(\text{MaNS})^+_{R_{GV}} = \{\text{MaNS}, \text{HocVi}, \text{ChuyenMon}\} = R_{GV} \implies (R_{NS} \cap R_{GV}) \to R_{GV}$$
  - Điều kiện định lý được thỏa mãn. Do đó phép nối tự nhiên $R_{NS} \bowtie R_{GV}$ là **nối không mất mát 100%**.
- Tương tự, xét phép nối giữa $R_{NS}$ và $R_{NV}$:
  - Tập giao: $R_{NS} \cap R_{NV} = \{\text{MaNS}\}$.
  - Trong lược đồ $R_{NV}$, ta có $\text{MaNS} \to \text{ViTri} \implies (R_{NS} \cap R_{NV}) \to R_{NV}$.
  - Phép nối tự nhiên $R_{NS} \bowtie R_{NV}$ cũng là **nối không mất mát 100%**.

#### 2. Chứng minh Bảo toàn phụ thuộc hàm (Dependency Preservation):
- Mọi phụ thuộc hàm của thực thể cha ($F_{NS}$) được kiểm tra trọn vẹn trên bảng $R_{NS}$.
- Mọi phụ thuộc hàm riêng của giáo viên ($\text{MaNS} \to \text{HocVi}, \text{ChuyenMon}$) được bảo toàn trọn vẹn trên bảng $R_{GV}$.
- Mọi phụ thuộc hàm riêng của nhân viên ($\text{MaNS} \to \text{ViTri}$) được bảo toàn trọn vẹn trên bảng $R_{NV}$.
- Không có bất kỳ phụ thuộc hàm liên bảng nào bị phân tán hoặc mất đi sau phân rã.
- **Lợi ích thực tế:** Tránh việc tạo ra bảng nhân sự gộp duy nhất chứa hàng loạt cột bị `NULL` (ví dụ nhân viên không có `HocVi`, `ChuyenMon`; giáo viên không có `ViTri`).

---

### 3.3. Chứng minh thiết kế bảng `LAM_BAI` với khóa `(MaHV, MaBKT, LanThi)`
- **Vấn đề đặt ra:** Trong mô hình khái niệm ERD ban đầu, quan hệ `LÀM BÀI` được biểu diễn như một liên kết N-N thông thường giữa Học viên và Bài kiểm tra. Nếu chuyển đổi thành bảng với khóa chỉ gồm `(MaHV, MaBKT)`, hệ thống sẽ chỉ cho phép mỗi học viên làm bài đúng một lần duy nhất.
- **Thực tế nghiệp vụ (Quy tắc C03):** Trong đào tạo tiếng Anh, các bài kiểm tra định kỳ hoặc bài thi đánh giá thường có các đợt thi bù, thi cải thiện hoặc thi lại.
- **Giải pháp chuyển đổi:** Bổ sung thuộc tính `LanThi` (số nguyên dương $\ge 1$) vào khóa chính:
  $$\text{PK} = (\text{MaHV}, \text{MaBKT}, \text{LanThi})$$
- **Kết quả:**
  - Khóa chính định danh duy nhất từng bài làm của từng lần thi.
  - Vẫn giữ trọn vẹn quan hệ cha - con với `HOC_VIEN` và `BAI_KIEM_TRA`.
  - Không vi phạm 3NF/BCNF vì mọi thuộc tính (`NgayThi`, `Diem`, `GhiChu`) phụ thuộc đầy đủ vào bộ ba này.

---

## 4. BẢNG TỔNG HỢP KẾT QUẢ CHUẨN HÓA TOÀN BỘ CSDL

| STT | Tên bảng | Khóa chính (PK) | Các khóa ứng viên (CK) | Vế trái mọi FD ($X$) | Dạng chuẩn cao nhất | Đánh giá |
| :---: | :--- | :--- | :--- | :--- | :---: | :--- |
| 1 | `CO_SO` | `MaCS` | `{MaCS}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 2 | `KHOA_HOC` | `MaKH` | `{MaKH}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 3 | `NHAN_SU` | `MaNS` | `{MaNS}`, `{SDT}`, `{Email}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 4 | `GIAO_VIEN` | `MaNS` | `{MaNS}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 5 | `NHAN_VIEN` | `MaNS` | `{MaNS}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 6 | `HOC_VIEN` | `MaHV` | `{MaHV}`, `{SDT}`, `{Email}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 7 | `LOP_HOC` | `MaLop` | `{MaLop}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 8 | `GIANG_DAY` | `(MaNS, MaLop)` | `{(MaNS, MaLop)}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 9 | `DANG_KY` | `MaDK` | `{MaDK}`, `{(MaHV, MaLop)}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 10 | `PHIEU_THANH_TOAN` | `MaPhieu` | `{MaPhieu}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 11 | `DE_THI` | `MaDe` | `{MaDe}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 12 | `BAI_KIEM_TRA` | `MaBKT` | `{MaBKT}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |
| 13 | `LAM_BAI` | `(MaHV, MaBKT, LanThi)` | `{(MaHV, MaBKT, LanThi)}` | Siêu khóa | **BCNF / 3NF** | Hoàn hảo |

**KẾT LUẬN CHUNG:**  
Toàn bộ **13/13 bảng** trong thiết kế cơ sở dữ liệu của Nhóm 2 đều đạt dạng chuẩn **3NF**, và trên thực tế đều đạt mức chuẩn hóa cao nhất **BCNF (Boyce-Codd Normal Form)**. Thiết kế triệt tiêu hoàn toàn dư thừa dữ liệu bất hợp lý, loại bỏ mọi nguy cơ dị thường khi Thêm (Insertion Anomaly), Xóa (Deletion Anomaly) và Cập nhật (Update Anomaly), đồng thời bảo đảm tính toàn vẹn lịch sử và hiệu năng truy vấn cho các module ứng dụng của Khanh, Lộc và Huy.

