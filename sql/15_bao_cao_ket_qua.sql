-- MySQL 8.0.16+. Hai result set: một dòng/học viên, rồi thống kê.
-- Chọn lần thi có LanThi lớn nhất (kể cả Diem NULL); Diem=0 là đã nhập.
-- Chỉ xét đăng ký có trạng thái hiện tại DaXacNhan/DaHoanThanh.
-- Ví dụ: CALL sp_bao_cao_ket_qua('LOP_IE_01', 'BKT01');
USE english_center_db;

DROP PROCEDURE IF EXISTS sp_bao_cao_ket_qua;
DELIMITER $$
CREATE PROCEDURE sp_bao_cao_ket_qua(
    IN p_ma_lop VARCHAR(20),
    IN p_ma_bkt VARCHAR(20)
)
BEGIN
    IF NULLIF(TRIM(p_ma_lop), '') IS NULL OR NULLIF(TRIM(p_ma_bkt), '') IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã lớp và bài kiểm tra là bắt buộc';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM BAI_KIEM_TRA b
                    WHERE b.MaBKT = TRIM(p_ma_bkt) AND b.MaLop = TRIM(p_ma_lop)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bài kiểm tra không thuộc lớp';
    END IF;

    SELECT h.MaHV, h.HoTen, l.MaLop, l.TenLop,
           b.MaBKT, b.TenBKT, b.NgayKiemTra, b.ThangDiem,
           k.LanThi, k.Diem,
           CASE WHEN k.Diem IS NULL THEN 'Chưa nhập' ELSE 'Đã nhập' END AS TrangThaiDiem
      FROM BAI_KIEM_TRA b
      JOIN LOP_HOC l ON l.MaLop = b.MaLop
      JOIN DANG_KY d ON d.MaLop = l.MaLop
                    AND d.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')
      JOIN HOC_VIEN h ON h.MaHV = d.MaHV
      LEFT JOIN LAM_BAI k ON k.MaHV = h.MaHV AND k.MaBKT = b.MaBKT
                         AND k.LanThi = (SELECT MAX(x.LanThi) FROM LAM_BAI x
                                          WHERE x.MaHV = h.MaHV AND x.MaBKT = b.MaBKT)
     WHERE b.MaLop = TRIM(p_ma_lop) AND b.MaBKT = TRIM(p_ma_bkt)
     ORDER BY h.HoTen, h.MaHV;

    SELECT COUNT(*) AS SoDuDieuKien,
           COUNT(k.Diem) AS SoDaNhap,
           COUNT(*) - COUNT(k.Diem) AS SoChuaNhap,
           ROUND(AVG(k.Diem), 2) AS DiemTrungBinh
      FROM BAI_KIEM_TRA b
      JOIN DANG_KY d ON d.MaLop = b.MaLop
                    AND d.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')
      LEFT JOIN LAM_BAI k ON k.MaHV = d.MaHV AND k.MaBKT = b.MaBKT
                         AND k.LanThi = (SELECT MAX(x.LanThi) FROM LAM_BAI x
                                          WHERE x.MaHV = d.MaHV AND x.MaBKT = b.MaBKT)
     WHERE b.MaLop = TRIM(p_ma_lop) AND b.MaBKT = TRIM(p_ma_bkt);
END$$
DELIMITER ;
