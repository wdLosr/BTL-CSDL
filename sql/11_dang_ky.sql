-- MySQL 8.0.16+. Chạy sau 01_schema.sql và 02_seed.sql.
-- Procedure tự quản lý giao dịch; không gọi khi ứng dụng đang mở giao dịch khác.
-- Mọi luồng thêm/hủy/xác nhận đăng ký phải khóa LOP_HOC trước khi đổi DANG_KY.
-- Ví dụ: CALL sp_dang_ky_lop('DK009', 'HV003', 'LOP_GT_01', DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY));
USE english_center_db;

DROP PROCEDURE IF EXISTS sp_dang_ky_lop;
DELIMITER $$
CREATE PROCEDURE sp_dang_ky_lop(
    IN p_ma_dk VARCHAR(20),
    IN p_ma_hv VARCHAR(20),
    IN p_ma_lop VARCHAR(20),
    IN p_han_nop DATE
)
BEGIN
    DECLARE v_si_so_toi_da INT DEFAULT NULL;
    DECLARE v_hoc_phi DECIMAL(12,2) DEFAULT NULL;
    DECLARE v_trang_thai_lop VARCHAR(25) DEFAULT NULL;
    DECLARE v_ma_dk_cu VARCHAR(20) DEFAULT NULL;
    DECLARE v_trang_thai_dk VARCHAR(20) DEFAULT NULL;
    DECLARE v_khoan_phai_thu_cu DECIMAL(12,2) DEFAULT NULL;
    DECLARE v_so_phieu INT DEFAULT 0;
    DECLARE v_da_thu DECIMAL(14,2) DEFAULT 0;
    DECLARE v_si_so INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NULLIF(TRIM(p_ma_dk), '') IS NULL OR NULLIF(TRIM(p_ma_hv), '') IS NULL
       OR NULLIF(TRIM(p_ma_lop), '') IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã đăng ký, học viên và lớp là bắt buộc';
    END IF;
    IF p_han_nop IS NULL OR p_han_nop < CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hạn nộp không được trước ngày đăng ký';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM HOC_VIEN WHERE MaHV = TRIM(p_ma_hv)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Học viên không tồn tại';
    END IF;

    START TRANSACTION;
    SELECT SiSoToiDa, HocPhi, TrangThai
      INTO v_si_so_toi_da, v_hoc_phi, v_trang_thai_lop
      FROM LOP_HOC WHERE MaLop = TRIM(p_ma_lop) FOR UPDATE;
    IF v_si_so_toi_da IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp không tồn tại';
    END IF;
    SELECT MaDK, TrangThaiDK, KhoanPhaiThu INTO v_ma_dk_cu, v_trang_thai_dk, v_khoan_phai_thu_cu
      FROM DANG_KY WHERE MaHV = TRIM(p_ma_hv) AND MaLop = TRIM(p_ma_lop)
      FOR UPDATE;
    IF v_ma_dk_cu IS NOT NULL AND v_trang_thai_dk <> 'DaHuy' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Học viên đã đăng ký lớp này';
    END IF;
    -- T03: hồ sơ DK004 đã hủy ở LOP_IE_01 đang học được xác nhận lại.
    -- Chỉ cho đăng ký mới vào lớp đang nhận đăng ký; lớp đã kết thúc không nhận ai.
    IF (v_ma_dk_cu IS NULL AND v_trang_thai_lop <> 'DangNhanDangKy')
       OR (v_ma_dk_cu IS NOT NULL
           AND v_trang_thai_lop NOT IN ('DangNhanDangKy', 'DangHoc')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp không nhận đăng ký';
    END IF;

    -- Đã nộp đủ vẫn chiếm chỗ. Mọi writer phải tuân theo khóa lớp ở trên.
    SELECT COUNT(*) INTO v_si_so FROM DANG_KY
      WHERE MaLop = TRIM(p_ma_lop)
        AND TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh');
    IF v_si_so >= v_si_so_toi_da THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp đã đủ sĩ số';
    END IF;

    IF v_ma_dk_cu IS NOT NULL THEN
        SELECT COUNT(*), COALESCE(SUM(CASE WHEN TrangThai = 'ThanhCong' THEN SoTien ELSE 0 END), 0)
          INTO v_so_phieu, v_da_thu FROM PHIEU_THANH_TOAN WHERE MaDK = v_ma_dk_cu;
        IF v_so_phieu = 0 THEN
            UPDATE DANG_KY
               SET NgayDK = CURRENT_DATE, HanNop = p_han_nop,
                   KhoanPhaiThu = v_hoc_phi, TrangThaiDK = 'DaXacNhan'
             WHERE MaDK = v_ma_dk_cu;
        ELSE
            -- Giữ nguyên khoản phải thu và ngày đăng ký đã chốt; phiếu cũ vẫn thuộc hồ sơ này.
            IF v_da_thu > v_khoan_phai_thu_cu THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lịch sử thanh toán vượt khoản phải thu';
            END IF;
            UPDATE DANG_KY SET HanNop = p_han_nop,
                   TrangThaiDK = IF(v_da_thu = v_khoan_phai_thu_cu, 'DaHoanThanh', 'DaXacNhan')
             WHERE MaDK = v_ma_dk_cu;
        END IF;
    ELSE
        INSERT INTO DANG_KY
            (MaDK, MaHV, MaLop, NgayDK, KhoanPhaiThu, HanNop, TrangThaiDK)
        VALUES
            (TRIM(p_ma_dk), TRIM(p_ma_hv), TRIM(p_ma_lop), CURRENT_DATE,
             v_hoc_phi, p_han_nop, 'DaXacNhan');
        SET v_ma_dk_cu = TRIM(p_ma_dk);
    END IF;
    COMMIT;

    -- Trả mã cũ khi tái kích hoạt, vì UNIQUE(MaHV, MaLop) chỉ cho một hồ sơ.
    SELECT MaDK, MaHV, MaLop, NgayDK, HanNop, KhoanPhaiThu, TrangThaiDK
      FROM DANG_KY WHERE MaDK = v_ma_dk_cu;
END$$
DELIMITER ;
