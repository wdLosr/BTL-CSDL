-- MySQL 8.0.16+. Procedure tự quản lý giao dịch; không gọi trong giao dịch khác.
-- Mọi luồng thêm/hủy/xác nhận phiếu thu phải khóa DANG_KY trước khi đổi phiếu.
-- Ví dụ: CALL sp_thu_hoc_phi('PTT006', 'DK001', NOW(), 500000.00, 'TienMat', NULL);
USE english_center_db;

DROP PROCEDURE IF EXISTS sp_thu_hoc_phi;
DELIMITER $$
CREATE PROCEDURE sp_thu_hoc_phi(
    IN p_ma_phieu VARCHAR(20),
    IN p_ma_dk VARCHAR(20),
    IN p_thoi_diem DATETIME,
    IN p_so_tien DECIMAL(18,4),
    IN p_phuong_thuc VARCHAR(30),
    IN p_ghi_chu VARCHAR(255)
)
BEGIN
    DECLARE v_khoan_phai_thu DECIMAL(12,2) DEFAULT NULL;
    DECLARE v_trang_thai_dk VARCHAR(20) DEFAULT NULL;
    DECLARE v_da_thu DECIMAL(14,2) DEFAULT 0;
    DECLARE v_so_du DECIMAL(14,2) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NULLIF(TRIM(p_ma_phieu), '') IS NULL OR NULLIF(TRIM(p_ma_dk), '') IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã phiếu và mã đăng ký là bắt buộc';
    END IF;
    IF p_thoi_diem IS NULL OR p_thoi_diem > NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày giờ thanh toán không hợp lệ';
    END IF;
    IF p_so_tien IS NULL OR p_so_tien <= 0 OR p_so_tien <> ROUND(p_so_tien, 2)
       OR p_so_tien > 9999999999.99 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Số tiền phải dương, vừa cột và tối đa hai chữ số lẻ';
    END IF;
    IF p_phuong_thuc IS NULL
       OR p_phuong_thuc NOT IN ('TienMat', 'ChuyenKhoan', 'The', 'ViDienTu') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phương thức thanh toán không hợp lệ';
    END IF;

    START TRANSACTION;
    SELECT KhoanPhaiThu, TrangThaiDK
      INTO v_khoan_phai_thu, v_trang_thai_dk
      FROM DANG_KY WHERE MaDK = TRIM(p_ma_dk) FOR UPDATE;
    IF v_khoan_phai_thu IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đăng ký không tồn tại';
    END IF;
    IF v_trang_thai_dk NOT IN ('DaXacNhan', 'DaHoanThanh') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đăng ký không đủ điều kiện thu';
    END IF;

    SELECT COALESCE(SUM(SoTien), 0) INTO v_da_thu
      FROM PHIEU_THANH_TOAN
     WHERE MaDK = TRIM(p_ma_dk) AND TrangThai = 'ThanhCong';
    SET v_so_du = v_khoan_phai_thu - v_da_thu;
    IF p_so_tien > v_so_du THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số tiền vượt số dư còn phải thu';
    END IF;

    INSERT INTO PHIEU_THANH_TOAN
        (MaPhieu, MaDK, NgayThanhToan, SoTien, PhuongThuc, TrangThai, GhiChu)
    VALUES
        (TRIM(p_ma_phieu), TRIM(p_ma_dk), p_thoi_diem, p_so_tien,
         p_phuong_thuc, 'ThanhCong', p_ghi_chu);
    IF p_so_tien = v_so_du THEN
        UPDATE DANG_KY SET TrangThaiDK = 'DaHoanThanh'
         WHERE MaDK = TRIM(p_ma_dk);
    END IF;
    COMMIT;

    SELECT TRIM(p_ma_phieu) AS MaPhieu, TRIM(p_ma_dk) AS MaDK,
           v_da_thu + p_so_tien AS TongDaThu,
           v_so_du - p_so_tien AS SoDuConLai;
END$$
DELIMITER ;
