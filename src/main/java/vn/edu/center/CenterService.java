package vn.edu.center;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Isolation;

@Service
public class CenterService {
    private final CenterRepository db;
    public CenterService(CenterRepository db) { this.db = db; }
    public List<CenterRepository.Choice> choices(String kind, String parent) { return db.choices(kind, parent); }
    public Map<String,Object> classInfo(String id) { return id == null || id.isBlank() ? null : db.classInfo(id, false); }
    public Map<String,Object> enrollmentInfo(String id) { return id == null || id.isBlank() ? null : db.enrollmentById(id, false); }
    public Map<String,Object> receipt(String id) { return db.payment(id); }
    public BigDecimal paid(String id) { return db.sumPaid(id); }
    public int seats(String id) { return db.seats(id); }

    // Sau khi chờ khóa dòng, các phép đếm/thu phải nhìn thấy bản ghi vừa COMMIT.
    @Transactional(isolation = Isolation.READ_COMMITTED)
    public String save(String slug, FormInput f) {
        return switch (slug) {
            case "dang-ky-lop" -> register(f);
            case "phieu-thanh-toan" -> collect(f);
            case "hoc-vien" -> { db.update("INSERT INTO HOC_VIEN(MaHV,HoTen,NgaySinh,GioiTinh,SDT,Email,DiaChi) VALUES(?,?,?,?,?,?,?)",f.s("maHV"),f.s("hoTen"),CenterRepository.date(f.s("ngaySinh")),f.s("gioiTinh"),f.s("sdt"),f.s("email"),f.nullable("diaChi")); yield f.s("maHV"); }
            case "khoa-hoc" -> { db.update("INSERT INTO KHOA_HOC(MaKH,TenKH,GiaKH,ThoiLuong,MoTa) VALUES(?,?,?,?,?)",f.s("maKH"),f.s("tenKH"),f.money("giaKH"),f.number("thoiLuong"),f.nullable("moTa")); yield f.s("maKH"); }
            case "co-so" -> { db.update("INSERT INTO CO_SO(MaCS,TenCS,DiaChi,SDT) VALUES(?,?,?,?)",f.s("maCS"),f.s("tenCS"),f.s("diaChi"),f.nullable("sdt")); yield f.s("maCS"); }
            case "lop-hoc" -> { require(db.exists("SELECT COUNT(*) FROM KHOA_HOC WHERE MaKH=?",f.s("maKH")),"maKH","Khóa học không tồn tại."); require(db.exists("SELECT COUNT(*) FROM CO_SO WHERE MaCS=?",f.s("maCS")),"maCS","Cơ sở không tồn tại."); db.update("INSERT INTO LOP_HOC(MaLop,TenLop,MaKH,MaCS,LichHoc,SiSoToiDa,HocPhi,TrangThai,NgayKhaiGiang,NgayKetThuc) VALUES(?,?,?,?,?,?,?,?,?,?)",f.s("maLop"),f.s("tenLop"),f.s("maKH"),f.s("maCS"),f.s("lichHoc"),f.number("siSoToiDa"),f.money("hocPhi"),f.s("trangThai"),f.nullable("ngayKhaiGiang")==null?null:CenterRepository.date(f.s("ngayKhaiGiang")),f.nullable("ngayKetThuc")==null?null:CenterRepository.date(f.s("ngayKetThuc"))); yield f.s("maLop"); }
            case "nhan-su" -> { db.update("INSERT INTO NHAN_SU(MaNS,HoTen,NgaySinh,GioiTinh,SDT,Email,DiaChi) VALUES(?,?,?,?,?,?,?)",f.s("maNS"),f.s("hoTen"),CenterRepository.date(f.s("ngaySinh")),f.s("gioiTinh"),f.s("sdt"),f.s("email"),f.nullable("diaChi")); yield f.s("maNS"); }
            case "giao-vien" -> { require(db.exists("SELECT COUNT(*) FROM NHAN_SU WHERE MaNS=?",f.s("maNS")),"maNS","Nhân sự không tồn tại."); db.update("INSERT INTO GIAO_VIEN(MaNS,HocVi,ChuyenMon) VALUES(?,?,?)",f.s("maNS"),f.s("hocVi"),f.s("chuyenMon")); yield f.s("maNS"); }
            case "nhan-vien" -> { require(db.exists("SELECT COUNT(*) FROM NHAN_SU WHERE MaNS=?",f.s("maNS")),"maNS","Nhân sự không tồn tại."); db.update("INSERT INTO NHAN_VIEN(MaNS,ViTri) VALUES(?,?)",f.s("maNS"),f.s("viTri")); yield f.s("maNS"); }
            case "de-thi" -> { db.update("INSERT INTO DE_THI(MaDe,TenDe,LoaiDe,ThoiLuong,MoTa) VALUES(?,?,?,?,?)",f.s("maDe"),f.s("tenDe"),f.s("loaiDe"),f.number("thoiLuong"),f.nullable("moTa")); yield f.s("maDe"); }
            case "bai-kiem-tra" -> { require(db.exists("SELECT COUNT(*) FROM LOP_HOC WHERE MaLop=?",f.s("maLop")),"maLop","Lớp không tồn tại."); require(db.exists("SELECT COUNT(*) FROM DE_THI WHERE MaDe=?",f.s("maDe")),"maDe","Đề thi không tồn tại."); db.update("INSERT INTO BAI_KIEM_TRA(MaBKT,TenBKT,LoaiBKT,ThangDiem,MaDe,MaLop,NgayKiemTra) VALUES(?,?,?,?,?,?,?)",f.s("maBKT"),f.s("tenBKT"),f.s("loaiBKT"),f.money("thangDiem"),f.s("maDe"),f.s("maLop"),f.nullable("ngayKiemTra")==null?null:CenterRepository.date(f.s("ngayKiemTra"))); yield f.s("maBKT"); }
            case "phan-cong" -> { require(db.exists("SELECT COUNT(*) FROM GIAO_VIEN WHERE MaNS=?",f.s("maGiaoVien")),"maGiaoVien","Giáo viên không tồn tại."); require(db.exists("SELECT COUNT(*) FROM LOP_HOC WHERE MaLop=?",f.s("maLop")),"maLop","Lớp không tồn tại."); db.update("INSERT INTO GIANG_DAY(MaNS,MaLop,VaiTro) VALUES(?,?,?)",f.s("maGiaoVien"),f.s("maLop"),f.s("vaiTro")); yield f.s("maLop"); }
            case "ket-qua" -> { grade(f); yield f.s("maBKT"); }
            default -> throw new IllegalArgumentException("Trang không hợp lệ");
        };
    }

    private String register(FormInput f) {
        require(db.exists("SELECT COUNT(*) FROM HOC_VIEN WHERE MaHV=?",f.s("maHV")),"maHV","Học viên không tồn tại.");
        Map<String,Object> c=db.classInfo(f.s("maLop"),true);
        require(c!=null,"maLop","Lớp không tồn tại.");
        Map<String,Object> old=db.enrollment(f.s("maHV"),f.s("maLop"),true);
        require(old==null || "DaHuy".equals(old.get("TrangThaiDK")),"maHV","Học viên đã đăng ký lớp này.");
        require(old==null ? "DangNhanDangKy".equals(c.get("TrangThai")) : List.of("DangNhanDangKy","DangHoc").contains(c.get("TrangThai")),"maLop","Lớp không nhận đăng ký.");
        require(db.seats(f.s("maLop"))<((Number)c.get("SiSoToiDa")).intValue(),"maLop","Lớp đã đủ sĩ số.");
        require(!f.day("hanNop").isBefore(LocalDate.now()),"hanNop","Hạn nộp không được trước hôm nay.");
        if(old==null) {
            require(!db.exists("SELECT COUNT(*) FROM DANG_KY WHERE MaDK=?",f.s("maDK")),"maDK","Mã đăng ký đã tồn tại.");
            db.update("INSERT INTO DANG_KY(MaDK,MaHV,MaLop,NgayDK,KhoanPhaiThu,HanNop,TrangThaiDK) VALUES(?,?,?,CURRENT_DATE,?,?,'DaXacNhan')",f.s("maDK"),f.s("maHV"),f.s("maLop"),c.get("HocPhi"),CenterRepository.date(f.s("hanNop")));
            return f.s("maDK");
        }
        String id=(String)old.get("MaDK");
        int history=db.count("SELECT COUNT(*) FROM PHIEU_THANH_TOAN WHERE MaDK=?",id);
        if(history==0) db.update("UPDATE DANG_KY SET NgayDK=CURRENT_DATE,HanNop=?,KhoanPhaiThu=?,TrangThaiDK='DaXacNhan' WHERE MaDK=?",CenterRepository.date(f.s("hanNop")),c.get("HocPhi"),id);
        else {
            BigDecimal fee=(BigDecimal)old.get("KhoanPhaiThu"), paid=db.sumPaid(id);
            require(paid.compareTo(fee)<=0,"maDK","Lịch sử thanh toán vượt khoản phải thu; cần đối soát.");
            db.update("UPDATE DANG_KY SET HanNop=?,TrangThaiDK=? WHERE MaDK=?",CenterRepository.date(f.s("hanNop")),paid.compareTo(fee)==0?"DaHoanThanh":"DaXacNhan",id);
        }
        return id;
    }
    private String collect(FormInput f) {
        Map<String,Object> d=db.enrollmentById(f.s("maDK"),true);
        require(d!=null,"maDK","Đăng ký không tồn tại.");
        require(List.of("DaXacNhan","DaHoanThanh").contains(d.get("TrangThaiDK")),"maDK","Đăng ký đã hủy hoặc không hợp lệ.");
        require(!db.exists("SELECT COUNT(*) FROM PHIEU_THANH_TOAN WHERE MaPhieu=?",f.s("maPhieu")),"maPhieu","Mã phiếu đã tồn tại.");
        BigDecimal remaining=((BigDecimal)d.get("KhoanPhaiThu")).subtract(db.sumPaid(f.s("maDK")));
        require(f.money("soTien").compareTo(remaining)<=0,"soTien","Số tiền vượt công nợ còn lại.");
        db.update("INSERT INTO PHIEU_THANH_TOAN(MaPhieu,MaDK,NgayThanhToan,SoTien,PhuongThuc,TrangThai) VALUES(?,?,?,?,?,'ThanhCong')",f.s("maPhieu"),f.s("maDK"),CenterRepository.datetime(f.s("ngayThanhToan")),f.money("soTien"),f.s("phuongThuc"));
        if(f.money("soTien").compareTo(remaining)==0) db.update("UPDATE DANG_KY SET TrangThaiDK='DaHoanThanh' WHERE MaDK=?",f.s("maDK"));
        return f.s("maPhieu");
    }
    private void grade(FormInput f) {
        Map<String,Object> d=db.enrollmentById(f.s("maDK"),false), b=db.test(f.s("maBKT"));
        require(d!=null,"maDK","Đăng ký không tồn tại."); require(b!=null,"maBKT","Bài kiểm tra không tồn tại.");
        require(List.of("DaXacNhan","DaHoanThanh").contains(d.get("TrangThaiDK")) && d.get("MaLop").equals(b.get("MaLop")),"maDK","Đăng ký không thuộc lớp của bài kiểm tra.");
        if(f.nullable("diem")!=null) require(f.money("diem").compareTo((BigDecimal)b.get("ThangDiem"))<=0,"diem","Điểm vượt thang điểm lưu trong MySQL.");
        require(!db.exists("SELECT COUNT(*) FROM LAM_BAI WHERE MaHV=? AND MaBKT=? AND LanThi=?",d.get("MaHV"),f.s("maBKT"),f.number("lanThi")),"lanThi","Lần thi này đã tồn tại.");
        db.update("INSERT INTO LAM_BAI(MaHV,MaBKT,LanThi,NgayThi,Diem) VALUES(?,?,?,?,?)",d.get("MaHV"),f.s("maBKT"),f.number("lanThi"),CenterRepository.date(f.s("ngayThi")),f.nullable("diem")==null?null:f.money("diem"));
    }
    private void require(boolean ok,String field,String message) { if(!ok) throw new BusinessException(field,message); }
}
