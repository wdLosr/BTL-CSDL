package vn.edu.center;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class PageCatalog {
    public record Field(String key,String label,String type,boolean required,List<CenterRepository.Choice> options,String lookup) {}
    public record Page(String slug,String title,String group,List<Field> fields,boolean report) {}
    private final Map<String,Page> pages=new LinkedHashMap<>();
    private static Field f(String k,String l,String t){return new Field(k,l,t,true,List.of(),null);}
    private static Field o(String k,String l,String t){return new Field(k,l,t,false,List.of(),null);}
    private static Field lookup(String k,String l,String kind){return new Field(k,l,"lookup",true,List.of(),kind);}
    private static Field optionalLookup(String k,String l,String kind){return new Field(k,l,"lookup",false,List.of(),kind);}
    private static Field choice(String k,String l,String... pairs){
        var options=new java.util.ArrayList<CenterRepository.Choice>();
        for(String pair:pairs){String[] a=pair.split("=",2);options.add(new CenterRepository.Choice(a[0],a[1]));}
        return new Field(k,l,"select",true,options,null);
    }
    private void add(String slug,String title,String group,Field... fields){pages.put(slug,new Page(slug,title,group,List.of(fields),false));}
    private void report(String slug,String title,Field... fields){pages.put(slug,new Page(slug,title,"Báo cáo",List.of(fields),true));}
    public PageCatalog(){
        add("hoc-vien","Học viên","Danh mục",f("maHV","Mã học viên","id"),f("hoTen","Họ tên","text"),f("ngaySinh","Ngày sinh","date"),choice("gioiTinh","Giới tính","Nam=Nam","Nu=Nữ","Khac=Khác"),f("sdt","Số điện thoại","tel"),f("email","Email","email"),o("diaChi","Địa chỉ","text"));
        add("khoa-hoc","Khóa học","Danh mục",f("maKH","Mã khóa","id"),f("tenKH","Tên khóa","text"),f("giaKH","Giá khóa học","moneyNonnegative"),f("thoiLuong","Thời lượng","positiveInt"),o("moTa","Mô tả","text"));
        add("co-so","Cơ sở","Danh mục",f("maCS","Mã cơ sở","id"),f("tenCS","Tên cơ sở","text"),f("diaChi","Địa chỉ","text"),o("sdt","Số điện thoại","tel"));
        add("lop-hoc","Lớp học","Danh mục",f("maLop","Mã lớp","id"),f("tenLop","Tên lớp","text"),lookup("maKH","Khóa học","khoa-hoc"),lookup("maCS","Cơ sở","co-so"),f("lichHoc","Lịch học","text"),f("siSoToiDa","Sĩ số tối đa","positiveInt"),f("hocPhi","Học phí lớp","moneyNonnegative"),choice("trangThai","Trạng thái","ChuanBi=Chuẩn bị","DangNhanDangKy=Đang nhận đăng ký","DangHoc=Đang học","DaKetThuc=Đã kết thúc"),o("ngayKhaiGiang","Ngày khai giảng","date"),o("ngayKetThuc","Ngày kết thúc","date"));
        add("nhan-su","Nhân sự","Danh mục",f("maNS","Mã nhân sự","id"),f("hoTen","Họ tên","text"),f("ngaySinh","Ngày sinh","date"),choice("gioiTinh","Giới tính","Nam=Nam","Nu=Nữ","Khac=Khác"),f("sdt","Số điện thoại","tel"),f("email","Email","email"),o("diaChi","Địa chỉ","text"));
        add("giao-vien","Giáo viên","Danh mục",lookup("maNS","Nhân sự","nhan-su"),f("hocVi","Học vị","text"),f("chuyenMon","Chuyên môn","text"));
        add("nhan-vien","Nhân viên","Danh mục",lookup("maNS","Nhân sự","nhan-su"),choice("viTri","Vị trí","TuVan=Tư vấn","GiaoVu=Giáo vụ","ThuNgan=Thu ngân","QuanLy=Quản lý"));
        add("de-thi","Đề thi","Danh mục",f("maDe","Mã đề","id"),f("tenDe","Tên đề","text"),choice("loaiDe","Loại đề","TracNghiem=Trắc nghiệm","TuLuan=Tự luận","KetHop=Kết hợp","VanDap=Vấn đáp"),f("thoiLuong","Thời lượng (phút)","positiveInt"),o("moTa","Mô tả","text"));
        add("bai-kiem-tra","Bài kiểm tra","Danh mục",f("maBKT","Mã bài kiểm tra","id"),f("tenBKT","Tên bài","text"),lookup("maLop","Lớp","lop-hoc"),lookup("maDe","Đề thi","de-thi"),choice("loaiBKT","Loại bài","GiuaKy=Giữa kỳ","CuoiKy=Cuối kỳ","ChuyenCan=Chuyên cần","DinhKy=Định kỳ"),f("thangDiem","Thang điểm","positiveDecimal"),o("ngayKiemTra","Ngày kiểm tra","date"));
        add("dang-ky-lop","Đăng ký lớp","Nghiệp vụ",f("maDK","Mã đăng ký mới","id"),lookup("maHV","Học viên","hoc-vien"),lookup("maLop","Lớp học","lop-hoc"),f("hanNop","Hạn nộp","date"));
        add("phieu-thanh-toan","Phiếu thanh toán","Nghiệp vụ",f("maPhieu","Mã phiếu","id"),lookup("maDK","Đăng ký","dang-ky"),f("ngayThanhToan","Ngày giờ thanh toán","datetime-local"),f("soTien","Số tiền thu","positiveDecimal"),choice("phuongThuc","Phương thức","TienMat=Tiền mặt","ChuyenKhoan=Chuyển khoản","The=Thẻ","ViDienTu=Ví điện tử"));
        add("phan-cong","Phân công giảng dạy","Nghiệp vụ",lookup("maLop","Lớp","lop-hoc"),lookup("maGiaoVien","Giáo viên","giao-vien"),choice("vaiTro","Vai trò","GiaoVienChinh=Giáo viên chính","TroGiang=Trợ giảng"));
        add("ket-qua","Nhập kết quả làm bài","Nghiệp vụ",lookup("maDK","Đăng ký","dang-ky"),lookup("maBKT","Bài kiểm tra","bai-kiem-tra"),f("lanThi","Lần thi","positiveInt"),f("ngayThi","Ngày thi","date"),o("diem","Điểm (để trống nếu chưa nhập)","nonnegativeDecimal"));
        report("thu-hoc-phi","Thu học phí theo kỳ",f("tuNgay","Từ ngày","date"),f("denNgay","Đến ngày","date"),optionalLookup("maLop","Lớp (tùy chọn)","lop-hoc"));
        report("danh-gia","Kết quả đánh giá theo lớp",lookup("maLop","Lớp","lop-hoc"),lookup("maBKT","Bài kiểm tra của lớp","bai-theo-lop"));
    }
    public Page get(String slug){return pages.get(slug);}
    public List<Page> all(){return List.copyOf(pages.values());}
    public Page withChoices(Page page,CenterService service,String parent){
        return new Page(page.slug(),page.title(),page.group(),page.fields().stream().map(f->f.lookup()==null?f:new Field(f.key(),f.label(),f.type(),f.required(),service.choices(f.lookup(),parent),f.lookup())).toList(),page.report());
    }
}
