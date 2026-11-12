-- ============================================================================
-- HỆ THỐNG QUẢN LÝ TRUNG TÂM TIẾNG ANH (MYSQL / MARIADB VERSION)
-- Bài tập lớn môn Cơ sở dữ liệu · Nhóm 2 · PTIT
-- Phụ trách thiết kế và cài đặt CSDL (Tiêu chí 3, 4, 8): Quang
-- Tệp tin: 02_seed.sql
-- Mục đích: Dữ liệu mẫu chuẩn hóa trên MySQL/MariaDB phục vụ demo các ca kiểm thử T01–T10
-- ============================================================================

-- Kích hoạt database
USE english_center_db;

/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- ----------------------------------------------------------------------------
-- 0. XÓA SẠCH DỮ LIỆU CŨ ĐỂ ĐẶT LẠI TRẠNG THÁI DEMO BAN ĐẦU
-- ----------------------------------------------------------------------------
DELETE FROM LAM_BAI;
DELETE FROM BAI_KIEM_TRA;
DELETE FROM DE_THI;
DELETE FROM PHIEU_THANH_TOAN;
DELETE FROM DANG_KY;
DELETE FROM GIANG_DAY;
DELETE FROM LOP_HOC;
DELETE FROM HOC_VIEN;
DELETE FROM NHAN_VIEN;
DELETE FROM GIAO_VIEN;
DELETE FROM NHAN_SU;
DELETE FROM KHOA_HOC;
DELETE FROM CO_SO;

-- ----------------------------------------------------------------------------
-- 1. CƠ SỞ ĐÀO TẠO
-- ----------------------------------------------------------------------------
INSERT INTO CO_SO (MaCS, TenCS, DiaChi, SDT, TrangThai) VALUES
('CS01', 'Cơ sở Cầu Giấy', '236 Hoàng Quốc Việt, Cầu Giấy, Hà Nội', '02437549888', 'HoatDong'),
('CS02', 'Cơ sở Hà Đông', 'Km 10 Đường Nguyễn Trãi, Hà Đông, Hà Nội', '02433528122', 'HoatDong');

-- ----------------------------------------------------------------------------
-- 2. KHÓA HỌC ĐÀO TẠO
-- ----------------------------------------------------------------------------
INSERT INTO KHOA_HOC (MaKH, TenKH, GiaKH, ThoiLuong, MoTa, TrangThai) VALUES
('KH_IELTS_FND', 'IELTS Foundation (3.5 - 4.5)', 3000000.00, 48, 'Khóa học nền tảng củng cố ngữ pháp, từ vựng và phát âm học thuật', 'DangMo'),
('KH_IELTS_INT', 'IELTS Intermediate (5.0 - 6.0)', 4500000.00, 60, 'Rèn luyện chuyên sâu 4 kỹ năng Nghe - Nói - Đọc - Viết', 'DangMo'),
('KH_TOEIC_650', 'TOEIC Cấp Tốc 650+', 2500000.00, 36, 'Chiến thuật giải đề và nâng cao kỹ năng phản xạ đề thi TOEIC', 'DangMo'),
('KH_GIAO_TIEP', 'Tiếng Anh Giao Tiếp Phản Xạ', 2000000.00, 30, 'Giao tiếp hàng ngày và thuyết trình tự tin', 'DangMo');

-- ----------------------------------------------------------------------------
-- 3. NHÂN SỰ VÀ PHÂN CẤP ISA (GIÁO VIÊN & NHÂN VIÊN)
-- ----------------------------------------------------------------------------
INSERT INTO NHAN_SU (MaNS, HoTen, NgaySinh, GioiTinh, SDT, Email, DiaChi, TrangThai) VALUES
('GV001', 'Nguyễn Văn Tuấn', '1988-05-12', 'Nam', '0912345601', 'tuan.nguyen@engcenter.edu.vn', 'Cầu Giấy, Hà Nội', 'DangLamViec'),
('GV002', 'Trần Thị Mai', '1992-09-20', 'Nu', '0912345602', 'mai.tran@engcenter.edu.vn', 'Đống Đa, Hà Nội', 'DangLamViec'),
('GV003', 'Lê Hoàng Long', '1990-11-15', 'Nam', '0912345603', 'long.le@engcenter.edu.vn', 'Thanh Xuân, Hà Nội', 'DangLamViec'),
('NV001', 'Phạm Hồng Ánh', '1995-03-08', 'Nu', '0987654301', 'anh.pham@engcenter.edu.vn', 'Hà Đông, Hà Nội', 'DangLamViec'),
('NV002', 'Đỗ Minh Quân', '1994-07-25', 'Nam', '0987654302', 'quan.do@engcenter.edu.vn', 'Bắc Từ Liêm, Hà Nội', 'DangLamViec'),
('NV003', 'Vũ Thùy Linh', '1993-12-01', 'Nu', '0987654303', 'linh.vu@engcenter.edu.vn', 'Nam Từ Liêm, Hà Nội', 'DangLamViec');

-- Subtype GIAO_VIEN
INSERT INTO GIAO_VIEN (MaNS, HocVi, ChuyenMon) VALUES
('GV001', 'ThacSi', 'IELTS'),
('GV002', 'CuNhan', 'TOEIC'),
('GV003', 'ThacSi', 'GiaoTiep');

-- Subtype NHAN_VIEN
INSERT INTO NHAN_VIEN (MaNS, ViTri) VALUES
('NV001', 'TuVan'),
('NV002', 'ThuNgan'),
('NV003', 'GiaoVu');

-- ----------------------------------------------------------------------------
-- 4. HỌC VIÊN
-- ----------------------------------------------------------------------------
INSERT INTO HOC_VIEN (MaHV, HoTen, NgaySinh, GioiTinh, SDT, Email, DiaChi, NgayTao) VALUES
('HV001', 'Nguyễn Minh Triết', '2004-06-15', 'Nam', '0901112233', 'triet.nguyen@gmail.com', 'Hà Nội', '2026-09-20'),
('HV002', 'Lê Thị Thu Thảo', '2003-08-22', 'Nu', '0902223344', 'thao.le@gmail.com', 'Hà Nội', '2026-09-21'),
('HV003', 'Trần Quốc Bảo', '2004-01-10', 'Nam', '0903334455', 'bao.tran@gmail.com', 'Hà Nội', '2026-09-22'),
('HV004', 'Hoàng Thùy Dương', '2005-11-30', 'Nu', '0904445566', 'duong.hoang@gmail.com', 'Hà Nội', '2026-09-23'),
('HV005', 'Đặng Tiến Dũng', '2002-04-18', 'Nam', '0905556677', 'dung.dang@gmail.com', 'Hà Nội', '2026-10-01'),
('HV006', 'Vũ Phương Anh', '2004-09-05', 'Nu', '0906667788', 'anh.vu@gmail.com', 'Hà Nội', '2026-10-02');

-- ----------------------------------------------------------------------------
-- 5. LỚP HỌC (ĐỦ CÁC TRẠNG THÁI: CÒN CHỖ, ĐẦY CHỖ, CÒN ĐÚNG 1 CHỖ)
-- ----------------------------------------------------------------------------
INSERT INTO LOP_HOC (MaLop, TenLop, MaKH, MaCS, LichHoc, SiSoToiDa, HocPhi, TrangThai, NgayKhaiGiang, NgayKetThuc) VALUES
-- Lớp 1: Lớp chuẩn đang học, đã chốt học phí
('LOP_IE_01', 'Lớp IELTS Foundation K01', 'KH_IELTS_FND', 'CS01', 'T2-T4-T6 (18:00 - 20:00)', 20, 3000000.00, 'DangHoc', '2026-10-01', '2026-12-15'),

-- Lớp 2: Lớp TOEIC giới hạn sĩ số 2 học viên và ĐÃ ĐẦY CHỖ (SiSoToiDa = 2, Đã xác nhận = 2)
('LOP_TOEIC_A', 'Lớp TOEIC Cấp Tốc Đầy Chỗ', 'KH_TOEIC_650', 'CS01', 'T3-T5-T7 (18:00 - 20:00)', 2, 2500000.00, 'DangHoc', '2026-10-15', '2026-12-20'),

-- Lớp 3: Lớp Giao tiếp đang nhận đăng ký và CÒN ĐÚNG 1 CHỖ (SiSoToiDa = 3, Đã xác nhận = 2 -> Còn 1 chỗ cho ca demo T01 của Khanh)
('LOP_GT_01', 'Lớp Giao Tiếp Còn 1 Chỗ', 'KH_GIAO_TIEP', 'CS01', 'T7-CN (09:00 - 11:00)', 3, 2000000.00, 'DangNhanDangKy', '2026-11-20', '2027-01-20'),

-- Lớp 4: Lớp mới mở, nhiều chỗ trống
('LOP_IE_02', 'Lớp IELTS Intermediate K02', 'KH_IELTS_INT', 'CS02', 'T2-T4-T6 (19:30 - 21:30)', 15, 4500000.00, 'DangNhanDangKy', '2026-12-01', '2027-02-28');

-- ----------------------------------------------------------------------------
-- 6. PHÂN CÔNG GIẢNG DẠY
-- ----------------------------------------------------------------------------
INSERT INTO GIANG_DAY (MaNS, MaLop, VaiTro, NgayPhanCong) VALUES
('GV001', 'LOP_IE_01', 'GiaoVienChinh', '2026-09-25'),
('GV002', 'LOP_IE_01', 'TroGiang', '2026-09-25'),
('GV002', 'LOP_TOEIC_A', 'GiaoVienChinh', '2026-10-10'),
('GV003', 'LOP_GT_01', 'GiaoVienChinh', '2026-11-01');

-- ----------------------------------------------------------------------------
-- 7. ĐĂNG KÝ HỌC (CHỐT HỌC PHÍ, CÓ CA HỦY, CA CHƯA THU, CA THU ĐỦ)
-- ----------------------------------------------------------------------------
INSERT INTO DANG_KY (MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK) VALUES
-- DK001: HV001 vào LOP_IE_01. Phí chốt 3tr, nộp 2 lần (1tr + 500k) -> Còn nợ 1.5tr
('DK001', 'HV001', 'LOP_IE_01', '2026-09-26', 3000000.00, '2026-10-10', 'DaXacNhan'),

-- DK002: HV002 vào LOP_IE_01. Phí chốt 3tr, nộp đủ 3tr -> Hoàn thành
('DK002', 'HV002', 'LOP_IE_01', '2026-09-27', 3000000.00, '2026-10-10', 'DaHoanThanh'),

-- DK003: HV003 vào LOP_IE_01. Phí chốt 3tr, CHƯA NỘP LẦN NÀO, đã quá hạn nộp -> Nợ 3tr, Quá hạn
('DK003', 'HV003', 'LOP_IE_01', '2026-09-28', 3000000.00, '2026-10-10', 'DaXacNhan'),

-- DK004: HV004 vào LOP_IE_01. ĐÃ HỦY ĐĂNG KÝ -> Để Khanh demo xác nhận lại bản ghi cũ
('DK004', 'HV004', 'LOP_IE_01', '2026-09-29', 3000000.00, '2026-10-10', 'DaHuy'),

-- DK005 & DK006: Chiếm trọn 2 chỗ của LOP_TOEIC_A -> Làm cho lớp đầy chỗ
('DK005', 'HV005', 'LOP_TOEIC_A', '2026-10-10', 2500000.00, '2026-10-20', 'DaXacNhan'),
('DK006', 'HV006', 'LOP_TOEIC_A', '2026-10-11', 2500000.00, '2026-10-20', 'DaXacNhan'),

-- DK007 & DK008: Chiếm 2/3 chỗ của LOP_GT_01 -> Còn lại đúng 1 chỗ trống!
('DK007', 'HV001', 'LOP_GT_01', '2026-11-05', 2000000.00, '2026-11-18', 'DaXacNhan'),
('DK008', 'HV002', 'LOP_GT_01', '2026-11-06', 2000000.00, '2026-11-18', 'DaXacNhan');

-- ----------------------------------------------------------------------------
-- 8. PHIẾU THANH TOÁN (LẦN THU)
-- ----------------------------------------------------------------------------
INSERT INTO PHIEU_THANH_TOAN (MaPhieu, MaDK, NgayThanhToan, SoTien, PhuongThuc, TrangThai, GhiChu) VALUES
-- DK001: Lần thu 1 (1.000.000đ)
('PTT001', 'DK001', '2026-10-02 09:30:00', 1000000.00, 'ChuyenKhoan', 'ThanhCong', 'Thanh toán đợt 1 chuyển khoản'),

-- DK001: Lần thu 2 (500.000đ) -> Tổng thu 1.500.000đ, còn nợ 1.500.000đ
('PTT002', 'DK001', '2026-10-05 14:15:00', 500000.00, 'TienMat', 'ThanhCong', 'Thanh toán đợt 2 tiền mặt'),

-- DK002: Nộp đủ 3.000.000đ
('PTT003', 'DK002', '2026-09-28 10:00:00', 3000000.00, 'ChuyenKhoan', 'ThanhCong', 'Nộp trọn gói một lần'),

-- DK001: Phiếu thu bị HỦY (không được cộng vào tổng đã thu)
('PTT004', 'DK001', '2026-10-06 16:00:00', 200000.00, 'TienMat', 'DaHuy', 'Thu ngân lập sai thông tin, đã hủy phiếu'),

-- DK005: Nộp đủ học phí lớp TOEIC
('PTT005', 'DK005', '2026-10-12 11:20:00', 2500000.00, 'The', 'ThanhCong', 'Quẹt thẻ POS');

-- ----------------------------------------------------------------------------
-- 9. ĐỀ THI
-- ----------------------------------------------------------------------------
INSERT INTO DE_THI (MaDe, TenDe, ThoiLuong, LoaiDe, MoTa) VALUES
('DE_IE_MID', 'Đề thi giữa kỳ IELTS Listening & Reading Đề 01', 60, 'KetHop', 'Gồm 40 câu trắc nghiệm và điền từ'),
('DE_IE_FIN', 'Đề thi cuối kỳ IELTS 4 kỹ năng', 120, 'KetHop', 'Đánh giá toàn diện theo format quốc tế'),
('DE_TOEIC_MOCK', 'Đề thi thử TOEIC chuẩn ETS', 75, 'TracNghiem', '100 câu trắc nghiệm Nghe và Đọc');

-- ----------------------------------------------------------------------------
-- 10. BÀI KIỂM TRA
-- ----------------------------------------------------------------------------
INSERT INTO BAI_KIEM_TRA (MaBKT, TenBKT, MaLop, MaDe, LoaiBKT, ThangDiem, NgayKiemTra) VALUES
('BKT01', 'Kiểm tra Giữa kỳ IELTS K01', 'LOP_IE_01', 'DE_IE_MID', 'GiuaKy', 10.00, '2026-11-05'),
('BKT02', 'Kiểm tra Cuối kỳ IELTS K01', 'LOP_IE_01', 'DE_IE_FIN', 'CuoiKy', 10.00, '2026-12-10');

-- ----------------------------------------------------------------------------
-- 11. KẾT QUẢ LÀM BÀI (ĐỦ CA: ĐIỂM 8, ĐIỂM 0, VÀ CA CHƯA NHẬP ĐIỂM)
-- ----------------------------------------------------------------------------
INSERT INTO LAM_BAI (MaHV, MaBKT, LanThi, NgayThi, Diem, GhiChu) VALUES
-- HV001 làm BKT01: đạt 8.0 điểm
('HV001', 'BKT01', 1, '2026-11-05', 8.00, 'Làm bài tốt, kỹ năng nghe tốt'),

-- HV002 làm BKT01: đạt 0.0 điểm (Ca điểm 0 đã nhập thực tế, không được nhầm với chưa nhập)
('HV002', 'BKT01', 1, '2026-11-05', 0.00, 'Bỏ bài trắng hoặc vi phạm quy chế');

-- Khôi phục kiểm tra khóa ngoại
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
