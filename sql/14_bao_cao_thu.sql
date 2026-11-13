-- MySQL 8.0.16+. Hai result set: chi tiết phiếu thu, rồi tổng thực thu.
-- Chỉ phiếu ThanhCong; cả ngày kết thúc được tính vào kỳ báo cáo.
-- Ví dụ: CALL sp_bao_cao_thu('2026-09-01', '2026-10-31', NULL);
USE english_center_db;

DROP PROCEDURE IF EXISTS sp_bao_cao_thu;
DELIMITER $$
CREATE PROCEDURE sp_bao_cao_thu(
    IN p_tu_ngay DATE,
    IN p_den_ngay DATE,
    IN p_ma_lop VARCHAR(20)
)
BEGIN
    IF p_tu_ngay IS NULL OR p_den_ngay IS NULL OR p_tu_ngay > p_den_ngay THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khoảng ngày báo cáo không hợp lệ';
    END IF;

    SELECT v.MaPhieu, v.NgayThanhToan AS NgayThu, v.MaHV,
           v.TenHocVien AS HocVien, v.MaLop, v.TenLop,
           v.PhuongThuc, v.SoTien
      FROM v_bao_cao_thu_hoc_phi v
     WHERE v.NgayThanhToan >= p_tu_ngay
       AND v.NgayThanhToan < DATE_ADD(p_den_ngay, INTERVAL 1 DAY)
       AND (NULLIF(TRIM(p_ma_lop), '') IS NULL OR v.MaLop = TRIM(p_ma_lop))
     ORDER BY v.NgayThanhToan, v.MaPhieu;

    SELECT COUNT(*) AS SoPhieuThu,
           COALESCE(SUM(v.SoTien), 0.00) AS TongThucThu
      FROM v_bao_cao_thu_hoc_phi v
     WHERE v.NgayThanhToan >= p_tu_ngay
       AND v.NgayThanhToan < DATE_ADD(p_den_ngay, INTERVAL 1 DAY)
       AND (NULLIF(TRIM(p_ma_lop), '') IS NULL OR v.MaLop = TRIM(p_ma_lop));
END$$
DELIMITER ;
