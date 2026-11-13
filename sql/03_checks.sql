-- ============================================================================
-- HỆ THỐNG QUẢN LÝ TRUNG TÂM TIẾNG ANH (MYSQL / MARIADB VERSION)
-- Bài tập lớn môn Cơ sở dữ liệu · Nhóm 2 · PTIT
-- Phụ trách thiết kế và cài đặt CSDL (Tiêu chí 3, 4, 8): Quang
-- Tệp tin: 03_checks.sql
-- Mục đích: Kịch bản kiểm thử toàn vẹn dữ liệu, kiểm tra ràng buộc (PK, FK, UNIQUE, CHECK),
--          xác minh các View dùng chung, và đặc tả giao dịch an toàn (Transaction Locking)
-- ============================================================================

-- Kích hoạt database
USE english_center_db;

-- ============================================================================
-- PHẦN 1: KIỂM TRA DỮ LIỆU ĐÃ SEED (POSITIVE VERIFICATION)
-- Mục đích: Đảm bảo dữ liệu mẫu đã nạp chính xác, các View tính toán chuẩn xác
-- ============================================================================

-- 1.1 Kiểm tra số lượng bản ghi trên tất cả 13 bảng
SELECT 'CO_SO' AS TenBang, COUNT(*) AS SoBanGhi FROM CO_SO
UNION ALL
SELECT 'KHOA_HOC', COUNT(*) FROM KHOA_HOC
UNION ALL
SELECT 'NHAN_SU', COUNT(*) FROM NHAN_SU
UNION ALL
SELECT 'GIAO_VIEN', COUNT(*) FROM GIAO_VIEN
UNION ALL
SELECT 'NHAN_VIEN', COUNT(*) FROM NHAN_VIEN
UNION ALL
SELECT 'HOC_VIEN', COUNT(*) FROM HOC_VIEN
UNION ALL
SELECT 'LOP_HOC', COUNT(*) FROM LOP_HOC
UNION ALL
SELECT 'GIANG_DAY', COUNT(*) FROM GIANG_DAY
UNION ALL
SELECT 'DANG_KY', COUNT(*) FROM DANG_KY
UNION ALL
SELECT 'PHIEU_THANH_TOAN', COUNT(*) FROM PHIEU_THANH_TOAN
UNION ALL
SELECT 'DE_THI', COUNT(*) FROM DE_THI
UNION ALL
SELECT 'BAI_KIEM_TRA', COUNT(*) FROM BAI_KIEM_TRA
UNION ALL
SELECT 'LAM_BAI', COUNT(*) FROM LAM_BAI;

-- 1.2 Kiểm tra VIEW 1: Theo dõi sĩ số và tình trạng đăng ký lớp (v_si_so_lop)
-- Kỳ vọng:
-- - LOP_TOEIC_A: SiSoToiDa = 2, SiSoHienTai = 2, SoChoConLai = 0, TinhTrang = 'DaDay'
-- - LOP_GT_01:   SiSoToiDa = 3, SiSoHienTai = 2, SoChoConLai = 1, TinhTrang = 'ConCho' (Cho Khanh demo)
-- - LOP_IE_01:   SiSoToiDa = 20, SiSoHienTai = 2, SoChoConLai = 18 (Bản ghi DK004 'DaHuy' không được tính)
-- - LOP_IE_02:   SiSoToiDa = 15, SiSoHienTai = 0, SoChoConLai = 15, TinhTrang = 'ConCho'
SELECT 
    MaLop,
    TenLop,
    SiSoToiDa,
    SiSoHienTai,
    SoChoConLai,
    TrangThaiLop,
    TinhTrangDangKy
FROM v_si_so_lop
ORDER BY MaLop;

-- 1.3 Kiểm tra VIEW 2: Tổng hợp học phí, công nợ và số dư theo đăng ký (v_dang_ky_hoc_phi)
-- Kỳ vọng:
-- - DK001 (HV001): Phải thu 3.000.000đ, Đã thu 1.500.000đ (bỏ qua phiếu hủy PTT004 200k), Số dư = 1.500.000đ, Trạng thái: 'ConNo'
-- - DK002 (HV002): Phải thu 3.000.000đ, Đã thu 3.000.000đ, Số dư = 0.00đ, Trạng thái: 'DaHoanThanh'
-- - DK003 (HV003): Phải thu 3.000.000đ, Đã thu 0.00đ, Số dư = 3.000.000đ, Hạn nộp quá khứ -> Trạng thái: 'QuaHan'
-- - DK004 (HV004): Đã hủy -> Số dư = NULL, Trạng thái: 'KhongApDung'
-- - DK005 (HV005): Phải thu 2.500.000đ, Đã thu 2.500.000đ, Số dư = 0.00đ, Trạng thái: 'DaHoanThanh'
SELECT 
    MaDK,
    HoTen,
    TenLop,
    KhoanPhaiThu,
    TongDaThu,
    SoDu,
    HanNop,
    TrangThaiDK,
    TrangThaiHocPhi
FROM v_dang_ky_hoc_phi
ORDER BY MaDK;

-- 1.4 Kiểm tra VIEW 3: Báo cáo thu học phí (v_bao_cao_thu_hoc_phi)
-- Kỳ vọng: Tổng doanh thu thực tế đã thu = 1.000.000 + 500.000 + 3.000.000 + 2.500.000 = 7.000.000đ.
-- Phiếu PTT004 (200.000đ - DaHuy) TUYỆT ĐỐI không được nằm trong báo cáo này.
SELECT 
    MaPhieu,
    NgayThanhToan,
    SoTien,
    PhuongThuc,
    TenHocVien,
    TenLop,
    TenCS
FROM v_bao_cao_thu_hoc_phi
ORDER BY NgayThanhToan;

-- Đối chiếu tổng doanh thu theo từng lớp:
SELECT 
    MaLop,
    TenLop,
    COUNT(MaPhieu) AS SoPhieuThu,
    SUM(SoTien) AS TongDoanhThu
FROM v_bao_cao_thu_hoc_phi
GROUP BY MaLop, TenLop;

-- 1.5 Kiểm tra VIEW 4: Báo cáo kết quả đánh giá theo lớp (v_bao_cao_ket_qua_lop)
-- Kỳ vọng tại lớp LOP_IE_01, bài kiểm tra BKT01:
-- - HV001: Diem = 8.00 (DaCoDiem)
-- - HV002: Diem = 0.00 (DiemKhong - phân biệt rõ điểm 0 với chưa có kết quả)
-- - HV003: Diem = NULL (ChuaNhapDiem - có tên trong danh sách lớp nhưng chưa có bài làm)
-- - Điểm trung bình của lớp chỉ tính trên các điểm đã nhập: (8.00 + 0.00) / 2 = 4.00 (NULL không được chia vào mẫu số)
SELECT 
    TenLop,
    TenBKT,
    ThangDiem,
    MaHV,
    TenHocVien,
    LanThi,
    Diem,
    TinhTrangDiem
FROM v_bao_cao_ket_qua_lop
WHERE MaBKT = 'BKT01'
ORDER BY MaHV;

-- Đối chiếu điểm trung bình chuẩn mực (loại trừ NULL):
SELECT 
    MaBKT,
    TenBKT,
    COUNT(MaHV) AS TongSoHocVienTrongLop,
    COUNT(Diem) AS SoHocVienDaCoDiem,
    SUM(CASE WHEN Diem IS NULL THEN 1 ELSE 0 END) AS SoHocVienChuaNhapDiem,
    ROUND(AVG(Diem), 2) AS DiemTrungBinhThucTe
FROM v_bao_cao_ket_qua_lop
WHERE MaBKT = 'BKT01'
GROUP BY MaBKT, TenBKT;


-- ============================================================================
-- PHẦN 2: KIỂM TRA CÁC RÀNG BUỘC TOÀN VẸN (NEGATIVE TESTS - BẮT BUỘC BỊ TỪ CHỐI)
-- Hướng dẫn: Khi chạy các câu lệnh dưới đây, MySQL/MariaDB PHẢI báo lỗi và từ chối.
-- Mỗi câu lệnh minh họa một ràng buộc đã định nghĩa trong DDL 01_schema.sql.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TEST 2.1: VI PHẠM KHÓA CHÍNH (PRIMARY KEY VIOLATION)
-- Mô tả: Thêm mới một cơ sở có mã đã tồn tại (CS01).
-- Kỳ vọng MySQL: Lỗi "Duplicate entry 'CS01' for key 'PRIMARY'"
-- ----------------------------------------------------------------------------
-- INSERT INTO CO_SO (MaCS, TenCS, DiaChi, SDT, TrangThai)
-- VALUES ('CS01', 'Cơ sở Trùng Mã', '123 Đường Láng', '0988888888', 'HoatDong');

-- ----------------------------------------------------------------------------
-- TEST 2.2: VI PHẠM RÀNG BUỘC DUY NHẤT (UNIQUE VIOLATION)
-- Mô tả 2.2.1: Đăng ký học viên mới với Số điện thoại đã có trong hệ thống.
-- Kỳ vọng MySQL: Lỗi "Duplicate entry '0901112233' for key 'UQ_HOC_VIEN_SDT'"
-- ----------------------------------------------------------------------------
-- INSERT INTO HOC_VIEN (MaHV, HoTen, NgaySinh, GioiTinh, SDT, Email, DiaChi, NgayTao)
-- VALUES ('HV999', 'Nguyễn Trùng SDT', '2004-01-01', 'Nam', '0901112233', 'unique.test@gmail.com', 'HN', CURRENT_DATE);

-- Mô tả 2.2.2: Cùng một học viên đăng ký 2 lần vào CÙNG MỘT LỚP HỌC.
-- Kỳ vọng MySQL: Lỗi "Duplicate entry 'HV001-LOP_IE_01' for key 'UQ_DANG_KY_HV_Lop'"
-- ----------------------------------------------------------------------------
-- INSERT INTO DANG_KY (MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK)
-- VALUES ('DK999', 'HV001', 'LOP_IE_01', CURRENT_DATE, 3000000.00, DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY), 'DaXacNhan');

-- ----------------------------------------------------------------------------
-- TEST 2.3: VI PHẠM KHÓA NGOẠI (FOREIGN KEY VIOLATION)
-- Mô tả 2.3.1: Đăng ký học cho một mã học viên KHÔNG TỒN TẠI (HV999).
-- Kỳ vọng MySQL: Lỗi "Cannot add or update a child row: a foreign key constraint fails (`FK_DANG_KY_HOC_VIEN`)"
-- ----------------------------------------------------------------------------
-- INSERT INTO DANG_KY (MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK)
-- VALUES ('DK998', 'HV999', 'LOP_GT_01', CURRENT_DATE, 2000000.00, DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY), 'DaXacNhan');

-- Mô tả 2.3.2: Lập phiếu thu cho một mã đăng ký KHÔNG TỒN TẠI (DK999).
-- Kỳ vọng MySQL: Lỗi "Cannot add or update a child row: a foreign key constraint fails (`FK_PHIEU_THANH_TOAN_DANG_KY`)"
-- ----------------------------------------------------------------------------
-- INSERT INTO PHIEU_THANH_TOAN (MaPhieu, MaDK, NgayThanhToan, SoTien, PhuongThuc, TrangThai)
-- VALUES ('PTT999', 'DK999', CURRENT_TIMESTAMP, 500000.00, 'TienMat', 'ThanhCong');

-- ----------------------------------------------------------------------------
-- TEST 2.4: VI PHẠM RÀNG BUỘC MIỀN GIÁ TRỊ VÀ SỐ HỌC (CHECK CONSTRAINTS)
-- ----------------------------------------------------------------------------

-- Mô tả 2.4.1: Thu học phí với số tiền âm hoặc bằng 0 (SoTien <= 0).
-- Kỳ vọng MySQL: Lỗi "Check constraint 'CK_PHIEU_THANH_TOAN_SoTien' is violated"
-- ----------------------------------------------------------------------------
-- INSERT INTO PHIEU_THANH_TOAN (MaPhieu, MaDK, NgayThanhToan, SoTien, PhuongThuc, TrangThai)
-- VALUES ('PTT998', 'DK001', CURRENT_TIMESTAMP, -500000.00, 'TienMat', 'ThanhCong');

-- Mô tả 2.4.2: Ngày kết thúc lớp học trước Ngày khai giảng (NgayKetThuc < NgayKhaiGiang).
-- Kỳ vọng MySQL: Lỗi "Check constraint 'CK_LOP_HOC_Ngay' is violated"
-- ----------------------------------------------------------------------------
-- INSERT INTO LOP_HOC (MaLop, TenLop, MaKH, MaCS, LichHoc, SiSoToiDa, HocPhi, TrangThai, NgayKhaiGiang, NgayKetThuc)
-- VALUES ('LOP_ERR', 'Lớp Sai Ngày', 'KH_GIAO_TIEP', 'CS01', 'T2-T4', 20, 2000000.00, 'ChuanBi', '2026-12-01', '2026-10-01');

-- Mô tả 2.4.3: Hạn nộp học phí trước Ngày đăng ký (HanNop < NgayDK).
-- Kỳ vọng MySQL: Lỗi "Check constraint 'CK_DANG_KY_HanNop' is violated"
-- ----------------------------------------------------------------------------
-- INSERT INTO DANG_KY (MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK)
-- VALUES ('DK997', 'HV003', 'LOP_GT_01', '2026-11-10', 2000000.00, '2026-11-01', 'DaXacNhan');

-- Mô tả 2.4.4: Nhập điểm số âm vào bảng kết quả làm bài (Diem < 0).
-- Kỳ vọng MySQL: Lỗi "Check constraint 'CK_LAM_BAI_Diem' is violated"
-- ----------------------------------------------------------------------------
-- INSERT INTO LAM_BAI (MaHV, MaBKT, LanThi, NgayThi, Diem)
-- VALUES ('HV003', 'BKT01', 1, CURRENT_DATE, -2.50);

-- Mô tả 2.4.5: Nhập giá trị sai danh mục quy định (Ví dụ chức vụ nhân viên không hợp lệ).
-- Kỳ vọng MySQL: Lỗi "Check constraint 'CK_NHAN_VIEN_ViTri' is violated"
-- ----------------------------------------------------------------------------
-- INSERT INTO NHAN_VIEN (MaNS, ViTri) VALUES ('GV001', 'GiamDocKhongHopLe');


-- ============================================================================
-- PHẦN 3: ĐẶC TẢ GIAO DỊCH AN TOÀN VÀ KIỂM SOÁT ĐỒNG THỜI (TRANSACTIONS)
-- Phục vụ: Cung cấp mẫu truy vấn chuẩn MySQL có Transaction & Pessimistic Locking
--          để Khanh nhúng vào Backend Form Nhập Liệu (Tiêu chí 5, 8).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- GIAO DỊCH 3.1: XÁC NHẬN ĐĂNG KÝ LỚP MỚI (CHỐNG VƯỢT SĨ SỐ - OVER-ENROLLMENT)
-- Bài toán: Khi nhiều nhân viên tư vấn đồng thời ghi danh học viên vào lớp sắp đầy
--           (Ví dụ LOP_GT_01 hiện chỉ còn đúng 1 chỗ).
-- Giải pháp: Dùng khóa hàng SELECT ... FOR UPDATE trên LOP_HOC trong MySQL InnoDB.
-- ----------------------------------------------------------------------------

-- Bước 1: Bắt đầu giao dịch trên MySQL
-- START TRANSACTION;

-- Bước 2: Đọc thông tin lớp và KHÓA dòng lớp học để ngăn giao dịch khác sửa đổi/tính sĩ số
-- SELECT MaLop, TenLop, SiSoToiDa, HocPhi, TrangThai
-- FROM LOP_HOC
-- WHERE MaLop = 'LOP_GT_01' AND TrangThai = 'DangNhanDangKy'
-- FOR UPDATE;

-- Bước 3: Đếm số lượng học viên ĐÃ XÁC NHẬN trong lớp
-- SELECT COUNT(*) AS SiSoHienTai
-- FROM DANG_KY
-- WHERE MaLop = 'LOP_GT_01' AND TrangThaiDK = 'DaXacNhan';

-- Bước 4: Kiểm tra điều kiện nghiệp vụ trong tầng ứng dụng:
-- IF (SiSoHienTai >= SiSoToiDa) THEN
--     ROLLBACK; -- Hủy giao dịch, thông báo "Lớp đã đủ sĩ số, không thể ghi danh!"
-- ELSE
--     -- Bước 5: Chốt học phí từ LOP_HOC.HocPhi sang DANG_KY.KhoanPhaiThu
--     INSERT INTO DANG_KY (MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK)
--     VALUES ('DK009', 'HV003', 'LOP_GT_01', CURRENT_DATE, 2000000.00, DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY), 'DaXacNhan');
--     COMMIT; -- Ghi nhận thành công, giải phóng khóa
-- END IF;


-- ----------------------------------------------------------------------------
-- GIAO DỊCH 3.2: THU HỌC PHÍ AN TOÀN (CHỐNG THU VƯỢT CÔNG NỢ - OVER-COLLECTION)
-- Bài toán: Nhiều thu ngân hoặc cổng thanh toán trực tuyến đồng thời xác nhận thanh toán
--           cho cùng một đăng ký DK001 (Hiện còn nợ 1.500.000đ).
-- Giải pháp: Dùng khóa hàng SELECT ... FOR UPDATE trên DANG_KY.
-- ----------------------------------------------------------------------------

-- Bước 1: Bắt đầu giao dịch trên MySQL
-- START TRANSACTION;

-- Bước 2: Khóa dòng đăng ký cần thanh toán
-- SELECT MaDK, KhoanPhaiThu, TrangThaiDK
-- FROM DANG_KY
-- WHERE MaDK = 'DK001'
-- FOR UPDATE;

-- Bước 3: Tính chính xác số dư nợ còn lại tại thời điểm hiện tại
-- SELECT 
--     (dk.KhoanPhaiThu - COALESCE(SUM(CASE WHEN ptt.TrangThai = 'ThanhCong' THEN ptt.SoTien ELSE 0 END), 0.00)) AS SoDuConLai
-- FROM DANG_KY dk
-- LEFT JOIN PHIEU_THANH_TOAN ptt ON dk.MaDK = ptt.MaDK
-- WHERE dk.MaDK = 'DK001'
-- GROUP BY dk.MaDK, dk.KhoanPhaiThu;

-- Bước 4: Kiểm tra số tiền khách nộp ($SoTienMoi)
-- IF ($SoTienMoi <= 0 OR $SoTienMoi > SoDuConLai) THEN
--     ROLLBACK; -- Hủy giao dịch, báo lỗi "Số tiền thanh toán không hợp lệ hoặc vượt quá số dư nợ!"
-- ELSE
--     -- Bước 5: Thêm phiếu thanh toán mới
--     INSERT INTO PHIEU_THANH_TOAN (MaPhieu, MaDK, NgayThanhToan, SoTien, PhuongThuc, TrangThai, GhiChu)
--     VALUES ('PTT006', 'DK001', CURRENT_TIMESTAMP, 1500000.00, 'ChuyenKhoan', 'ThanhCong', 'Thanh toán dứt điểm học phí');
--
--     -- Bước 6: Nếu số tiền nộp vừa khít với số dư -> Cập nhật trạng thái đăng ký sang 'DaHoanThanh'
--     IF ($SoTienMoi = SoDuConLai) THEN
--         UPDATE DANG_KY SET TrangThaiDK = 'DaHoanThanh' WHERE MaDK = 'DK001';
--     END IF;
--
--     COMMIT; -- Hoàn tất giao dịch
-- END IF;


-- ----------------------------------------------------------------------------
-- GIAO DỊCH 3.3: TÁI KÍCH HOẠT HỒ SƠ ĐĂNG KÝ ĐÃ HỦY (RE-ENROLLMENT)
-- Bài toán: Học viên HV004 trước đây đã hủy đăng ký DK004 ở lớp LOP_IE_01.
--           Nay học viên muốn đăng ký học lại.
-- Giải pháp: Để không vi phạm UQ_DANG_KY_HV_Lop, hệ thống cập nhật lại bản ghi cũ.
-- ----------------------------------------------------------------------------

-- START TRANSACTION;
--
-- SELECT MaLop, SiSoToiDa FROM LOP_HOC WHERE MaLop = 'LOP_IE_01' FOR UPDATE;
--
-- UPDATE DANG_KY
-- SET 
--     KhoanPhaiThu = (SELECT HocPhi FROM LOP_HOC WHERE MaLop = 'LOP_IE_01'),
--     NgayDK = CURRENT_DATE,
--     HanNop = DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY),
--     TrangThaiDK = 'DaXacNhan'
-- WHERE MaDK = 'DK004' AND TrangThaiDK = 'DaHuy';
--
-- COMMIT;
