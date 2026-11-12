package vn.edu.center;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class CenterRepository {
    public record Choice(String value, String label) {}
    private final JdbcTemplate db;
    public CenterRepository(JdbcTemplate db) { this.db = db; }

    public List<Choice> choices(String kind, String parent) {
        String sql = switch (kind) {
            case "hoc-vien" -> "SELECT MaHV id, CONCAT(MaHV, ' — ', HoTen) label FROM HOC_VIEN ORDER BY HoTen";
            case "khoa-hoc" -> "SELECT MaKH id, CONCAT(MaKH, ' — ', TenKH) label FROM KHOA_HOC ORDER BY TenKH";
            case "co-so" -> "SELECT MaCS id, CONCAT(MaCS, ' — ', TenCS) label FROM CO_SO ORDER BY TenCS";
            case "lop-hoc" -> "SELECT MaLop id, CONCAT(MaLop, ' — ', TenLop) label FROM LOP_HOC ORDER BY TenLop";
            case "giao-vien" -> "SELECT g.MaNS id, CONCAT(g.MaNS, ' — ', n.HoTen) label FROM GIAO_VIEN g JOIN NHAN_SU n ON n.MaNS=g.MaNS ORDER BY n.HoTen";
            case "nhan-su" -> "SELECT MaNS id, CONCAT(MaNS, ' — ', HoTen) label FROM NHAN_SU ORDER BY HoTen";
            case "de-thi" -> "SELECT MaDe id, CONCAT(MaDe, ' — ', TenDe) label FROM DE_THI ORDER BY TenDe";
            case "dang-ky" -> "SELECT d.MaDK id, CONCAT(d.MaDK, ' — ', h.HoTen, ' / ', l.TenLop) label FROM DANG_KY d JOIN HOC_VIEN h ON h.MaHV=d.MaHV JOIN LOP_HOC l ON l.MaLop=d.MaLop WHERE d.TrangThaiDK IN ('DaXacNhan','DaHoanThanh') ORDER BY d.MaDK";
            case "bai-kiem-tra" -> "SELECT MaBKT id, CONCAT(MaBKT, ' — ', TenBKT) label FROM BAI_KIEM_TRA ORDER BY TenBKT";
            case "bai-theo-lop" -> "SELECT MaBKT id, CONCAT(MaBKT, ' — ', TenBKT) label FROM BAI_KIEM_TRA WHERE MaLop=? ORDER BY TenBKT";
            default -> throw new IllegalArgumentException("Danh mục không hợp lệ");
        };
        return db.query(sql, (rs, n) -> new Choice(rs.getString("id"), rs.getString("label")),
                kind.equals("bai-theo-lop") ? new Object[]{parent == null ? "" : parent} : new Object[]{});
    }

    public Map<String,Object> classInfo(String maLop, boolean lock) {
        return one("SELECT MaLop,TenLop,SiSoToiDa,HocPhi,TrangThai FROM LOP_HOC WHERE MaLop=?" + (lock ? " FOR UPDATE" : ""), maLop);
    }
    public Map<String,Object> enrollment(String maHV, String maLop, boolean lock) {
        return one("SELECT MaDK,NgayDK,KhoanPhaiThu,HanNop,TrangThaiDK FROM DANG_KY WHERE MaHV=? AND MaLop=?" + (lock ? " FOR UPDATE" : ""), maHV, maLop);
    }
    public Map<String,Object> enrollmentById(String maDK, boolean lock) {
        if(lock) return one("SELECT MaDK,MaHV,MaLop,KhoanPhaiThu,HanNop,TrangThaiDK FROM DANG_KY WHERE MaDK=? FOR UPDATE", maDK);
        return one("SELECT d.MaDK,d.MaHV,d.MaLop,d.KhoanPhaiThu,d.HanNop,d.TrangThaiDK,h.HoTen,l.TenLop FROM DANG_KY d JOIN HOC_VIEN h ON h.MaHV=d.MaHV JOIN LOP_HOC l ON l.MaLop=d.MaLop WHERE d.MaDK=?", maDK);
    }
    public Map<String,Object> payment(String maPhieu) {
        return one("SELECT p.MaPhieu,p.MaDK,p.NgayThanhToan,p.SoTien,p.PhuongThuc,p.TrangThai,h.HoTen,l.TenLop FROM PHIEU_THANH_TOAN p JOIN DANG_KY d ON d.MaDK=p.MaDK JOIN HOC_VIEN h ON h.MaHV=d.MaHV JOIN LOP_HOC l ON l.MaLop=d.MaLop WHERE p.MaPhieu=?", maPhieu);
    }
    public Map<String,Object> test(String maBKT) {
        return one("SELECT MaBKT,MaLop,ThangDiem FROM BAI_KIEM_TRA WHERE MaBKT=?", maBKT);
    }
    public Map<String,Object> one(String sql, Object... args) {
        List<Map<String,Object>> rows = db.queryForList(sql, args);
        return rows.isEmpty() ? null : rows.get(0);
    }
    public int count(String sql, Object... args) { return db.queryForObject(sql, Integer.class, args); }
    public BigDecimal sumPaid(String maDK) {
        return db.queryForObject("SELECT COALESCE(SUM(SoTien),0) FROM PHIEU_THANH_TOAN WHERE MaDK=? AND TrangThai='ThanhCong'", BigDecimal.class, maDK);
    }
    public int seats(String maLop) {
        return count("SELECT COUNT(*) FROM DANG_KY WHERE MaLop=? AND TrangThaiDK IN ('DaXacNhan','DaHoanThanh')", maLop);
    }
    public List<Map<String,Object>> receiptRows(LocalDate from, LocalDate to, String maLop) {
        return db.queryForList("SELECT MaPhieu,NgayThanhToan,MaHV,TenHocVien,MaLop,TenLop,PhuongThuc,SoTien FROM v_bao_cao_thu_hoc_phi WHERE NgayThanhToan>=? AND NgayThanhToan<? AND (?='' OR MaLop=?) ORDER BY NgayThanhToan,MaPhieu",
                Timestamp.valueOf(from.atStartOfDay()), Timestamp.valueOf(to.plusDays(1).atStartOfDay()), maLop, maLop);
    }
    public List<Map<String,Object>> gradeRows(String maLop, String maBKT) {
        return db.queryForList("SELECT h.MaHV,h.HoTen,b.MaBKT,b.TenBKT,b.ThangDiem,k.LanThi,k.NgayThi,k.Diem,CASE WHEN k.Diem IS NULL THEN 'Chưa nhập' ELSE 'Đã nhập' END TrangThaiDiem FROM BAI_KIEM_TRA b JOIN DANG_KY d ON d.MaLop=b.MaLop AND d.TrangThaiDK IN ('DaXacNhan','DaHoanThanh') JOIN HOC_VIEN h ON h.MaHV=d.MaHV LEFT JOIN LAM_BAI k ON k.MaHV=h.MaHV AND k.MaBKT=b.MaBKT AND k.LanThi=(SELECT MAX(x.LanThi) FROM LAM_BAI x WHERE x.MaHV=h.MaHV AND x.MaBKT=b.MaBKT) WHERE b.MaLop=? AND b.MaBKT=? ORDER BY h.HoTen,h.MaHV", maLop, maBKT);
    }
    public boolean exists(String sql, Object... args) { return count(sql, args)>0; }
    public void update(String sql, Object... args) { db.update(sql, args); }
    public static Date date(String value) { return Date.valueOf(LocalDate.parse(value)); }
    public static Timestamp datetime(String value) { return Timestamp.valueOf(LocalDateTime.parse(value)); }
}
