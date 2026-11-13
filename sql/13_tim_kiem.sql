SELECT d.MaDK, h.MaHV, h.HoTen, l.MaLop, l.TenLop, d.TrangThaiDK,
       d.KhoanPhaiThu, COALESCE(p.DaThu, 0) AS DaThu,
       CASE WHEN d.TrangThaiDK = 'DaHuy' THEN NULL
            ELSE d.KhoanPhaiThu - COALESCE(p.DaThu, 0) END AS SoDu
FROM DANG_KY d
JOIN HOC_VIEN h ON h.MaHV = d.MaHV
JOIN LOP_HOC l ON l.MaLop = d.MaLop
LEFT JOIN (
    SELECT MaDK, SUM(SoTien) AS DaThu
    FROM PHIEU_THANH_TOAN
    WHERE TrangThai = 'ThanhCong'
    GROUP BY MaDK
) p ON p.MaDK = d.MaDK
WHERE (:tuKhoa = '' OR LOCATE(:tuKhoa, h.MaHV) > 0 OR LOCATE(:tuKhoa, h.HoTen) > 0)
  AND (:maLop = '' OR l.MaLop = :maLop)
ORDER BY h.HoTen, h.MaHV, l.MaLop, d.MaDK
