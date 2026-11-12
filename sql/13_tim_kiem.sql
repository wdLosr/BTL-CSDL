-- MySQL 8.0.16+. NULL hoặc chuỗi rỗng bỏ qua bộ lọc tương ứng.
-- Từ khóa tìm trong học viên, lớp hoặc khóa học; mã lớp lọc chính xác.
-- Ví dụ: CALL sp_tim_kiem_dang_ky('HV001', NULL);
USE english_center_db;

DROP PROCEDURE IF EXISTS sp_tim_kiem_dang_ky;
DELIMITER $$
CREATE PROCEDURE sp_tim_kiem_dang_ky(
    IN p_tu_khoa VARCHAR(100),
    IN p_ma_lop VARCHAR(20)
)
BEGIN
    SELECT v.MaDK, v.MaHV, v.HoTen, v.MaLop, v.TenLop,
           v.TrangThaiDK, v.KhoanPhaiThu, v.TongDaThu, v.SoDu,
           v.TrangThaiHocPhi, kh.TenKH,
           l.SiSoToiDa, COALESCE(s.SiSoHienTai, 0) AS SiSoHienTai,
           l.SiSoToiDa - COALESCE(s.SiSoHienTai, 0) AS SoChoConLai,
           CASE WHEN COALESCE(s.SiSoHienTai, 0) >= l.SiSoToiDa THEN 'DaDay'
                WHEN l.TrangThai <> 'DangNhanDangKy' THEN 'NgungNhan'
                ELSE 'ConCho' END AS TinhTrangDangKy
      FROM v_dang_ky_hoc_phi v
      JOIN LOP_HOC l ON l.MaLop = v.MaLop
      JOIN KHOA_HOC kh ON kh.MaKH = l.MaKH
      LEFT JOIN (SELECT MaLop, COUNT(*) AS SiSoHienTai
                   FROM DANG_KY
                  WHERE TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')
                  GROUP BY MaLop) s ON s.MaLop = v.MaLop
     WHERE (NULLIF(TRIM(p_tu_khoa), '') IS NULL
            OR LOCATE(LOWER(TRIM(p_tu_khoa)), LOWER(v.MaHV)) > 0
            OR LOCATE(LOWER(TRIM(p_tu_khoa)), LOWER(v.HoTen)) > 0
            OR LOCATE(LOWER(TRIM(p_tu_khoa)), LOWER(v.MaLop)) > 0
            OR LOCATE(LOWER(TRIM(p_tu_khoa)), LOWER(v.TenLop)) > 0
            OR LOCATE(LOWER(TRIM(p_tu_khoa)), LOWER(kh.TenKH)) > 0)
       AND (NULLIF(TRIM(p_ma_lop), '') IS NULL OR v.MaLop = TRIM(p_ma_lop))
     ORDER BY v.HoTen, v.MaHV, v.MaLop, v.MaDK;
END$$
DELIMITER ;
