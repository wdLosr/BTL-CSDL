package vn.edu.center;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.regex.Pattern;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class WebController {
    public record Field(String key, String label, String type, boolean required, String[] options) {}
    public record Page(String slug, String title, String group, List<Field> fields, boolean report) {}
    private final Map<String,Page> pages = new LinkedHashMap<>();
    private static Field f(String k,String l,String t) { return new Field(k,l,t,true,new String[0]); }
    private static Field opt(String k,String l,String t) { return new Field(k,l,t,false,new String[0]); }
    private static Field select(String k,String l,String... values) { return new Field(k,l,"select",true,values); }
    private void add(String slug,String title,String group,Field... fields) { pages.put(slug,new Page(slug,title,group,List.of(fields),false)); }
    private void report(String slug,String title,Field... fields) { pages.put(slug,new Page(slug,title,"Báo cáo",List.of(fields),true)); }
    public WebController() {
        add("hoc-vien","Học viên","Danh mục",f("maHV","Mã học viên","id"),f("hoTen","Họ tên","text"),f("ngaySinh","Ngày sinh","date"),opt("sdt","Số điện thoại","tel"),opt("email","Email","email"));
        add("khoa-hoc","Khóa học","Danh mục",f("maKH","Mã khóa","id"),f("tenKH","Tên khóa","text"),f("giaKH","Giá khóa học","moneyNonnegative"),f("thoiLuong","Thời lượng","positiveInt"));
        add("lop-hoc","Lớp học","Danh mục",f("maLop","Mã lớp","id"),f("tenLop","Tên lớp","text"),f("lichHoc","Lịch học","text"),f("siSoToiDa","Sĩ số tối đa","positiveInt"),select("trangThai","Trạng thái","Dự kiến","Đang học","Kết thúc"),f("maKH","Mã khóa học","id"),f("maCS","Mã cơ sở","id"));
        add("co-so","Cơ sở","Danh mục",f("maCS","Mã cơ sở","id"),f("tenCS","Tên cơ sở","text"),f("diaChi","Địa chỉ","text"));
        add("nhan-su","Nhân sự","Danh mục",f("maNS","Mã nhân sự","id"),f("hoTen","Họ tên","text"),f("ngaySinh","Ngày sinh","date"),opt("sdt","Số điện thoại","tel"),opt("email","Email","email"));
        add("giao-vien","Giáo viên","Danh mục",f("maNS","Mã nhân sự","id"),f("hocVi","Học vị","text"),f("chuyenMon","Chuyên môn","text"));
        add("nhan-vien","Nhân viên","Danh mục",f("maNS","Mã nhân sự","id"),f("viTri","Vị trí","text"));
        add("de-thi","Đề thi","Danh mục",f("maDe","Mã đề","id"),f("tenDe","Tên đề","text"),select("loaiDe","Loại đề","Đầu vào","Giữa khóa","Cuối khóa"),f("thoiLuong","Thời lượng","positiveInt"));
        add("bai-kiem-tra","Bài kiểm tra","Danh mục",f("maBKT","Mã bài kiểm tra","id"),f("tenBKT","Tên bài","text"),select("loaiBKT","Loại bài","Đầu vào","Giữa khóa","Cuối khóa"),f("thangDiem","Thang điểm","positiveDecimal"),f("maDe","Mã đề thi sử dụng","id"));
        add("phieu-thanh-toan","Phiếu thanh toán","Nghiệp vụ",f("maPhieu","Mã phiếu","id"),f("maDK","Mã đăng ký","id"),f("ngayThanhToan","Ngày giờ thanh toán","datetime-local"),f("soTien","Số tiền","positiveDecimal"),select("phuongThuc","Phương thức","Tiền mặt","Chuyển khoản"),select("trangThai","Trạng thái phiếu","Thành công","Thất bại","Đã hủy"));
        add("dang-ky-lop","Đăng ký lớp","Nghiệp vụ",f("maDK","Mã đăng ký","id"),f("maHV","Mã học viên","id"),f("maLop","Mã lớp","id"),f("ngayDK","Ngày đăng ký","date"),select("trangThaiDK","Trạng thái đăng ký","Chờ xác nhận","Đang học","Đã hủy"),f("khoanPhaiThu","Khoản phải thu đã chốt","moneyNonnegative"),f("hanNop","Hạn nộp","date"));
        add("phan-cong","Phân công giảng dạy","Nghiệp vụ",f("maLop","Mã lớp","id"),f("maGiaoVien","Mã giáo viên","id"),select("vaiTro","Vai trò","Chính","Trợ giảng"));
        add("ket-qua","Nhập kết quả làm bài","Nghiệp vụ",f("maDK","Mã đăng ký","id"),f("maBKT","Mã bài kiểm tra","id"),f("lanThi","Lần thi","positiveInt"),f("ngayThi","Ngày thi","date"),opt("diem","Điểm","nonnegativeDecimal"),opt("thangDiemApDung","Thang điểm áp dụng (hỗ trợ kiểm tra bản demo)","positiveDecimal"));
        report("thu-hoc-phi","Thu học phí theo kỳ",f("tuNgay","Từ ngày","date"),f("denNgay","Đến ngày","date"),opt("maLop","Mã lớp","id"));
        report("danh-gia","Kết quả đánh giá theo lớp",f("maLop","Mã lớp","id"),f("maBKT","Mã bài kiểm tra hoặc đợt đánh giá","id"));
    }
    @GetMapping("/") String home(Model model) { model.addAttribute("pages",pages.values()); return "home"; }
    @GetMapping("/m/{slug}") String form(@PathVariable String slug,Model model) {
        Page page=requiredPage(slug); fill(model,page,Map.of(),Map.of(),false); return page.report()?"report":"form";
    }
    @PostMapping("/m/{slug}") String submit(@PathVariable String slug,@RequestParam Map<String,String> input,Model model) {
        Page page=requiredPage(slug); Map<String,String> values=new LinkedHashMap<>(),errors=new LinkedHashMap<>();
        for(Field field:page.fields()) {
            String value=input.getOrDefault(field.key(),"").trim(); values.put(field.key(),value);
            if(value.isEmpty()) { if(field.required()) errors.put(field.key(),field.label()+" là trường bắt buộc."); continue; }
            String error=validate(field,value); if(error!=null) errors.put(field.key(),error);
        }
        if(slug.equals("dang-ky-lop") && !errors.containsKey("hanNop") && !errors.containsKey("ngayDK") && LocalDate.parse(values.get("hanNop")).isBefore(LocalDate.parse(values.get("ngayDK")))) errors.put("hanNop","Hạn nộp không được trước ngày đăng ký.");
        if(slug.equals("thu-hoc-phi") && !errors.containsKey("tuNgay") && !errors.containsKey("denNgay") && LocalDate.parse(values.get("tuNgay")).isAfter(LocalDate.parse(values.get("denNgay")))) errors.put("denNgay","Đến ngày không được trước từ ngày.");
        if(slug.equals("ket-qua") && !errors.containsKey("diem") && !errors.containsKey("thangDiemApDung") && !values.get("diem").isEmpty() && !values.get("thangDiemApDung").isEmpty() && new BigDecimal(values.get("diem")).compareTo(new BigDecimal(values.get("thangDiemApDung")))>0) errors.put("diem","Điểm không được vượt thang điểm áp dụng.");
        fill(model,page,values,errors,errors.isEmpty()); return page.report()?"report":"form";
    }
    private Page requiredPage(String slug) { Page page=pages.get(slug); if(page==null) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.NOT_FOUND); return page; }
    private void fill(Model model,Page page,Map<String,String> values,Map<String,String> errors,boolean success) { model.addAttribute("page",page);model.addAttribute("values",values);model.addAttribute("errors",errors);model.addAttribute("success",success); }
    private String validate(Field field,String value) {
        String label=field.label();
        if(field.type().equals("id") && !Pattern.matches("[\\p{L}\\p{N}_-]+",value)) return label+" chỉ được có chữ, số, dấu gạch ngang hoặc gạch dưới.";
        if(field.type().equals("email") && !Pattern.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$",value)) return label+" không đúng định dạng email.";
        if(field.type().equals("tel") && !Pattern.matches("0[0-9]{9,10}",value)) return label+" phải bắt đầu bằng 0 và có 10–11 chữ số.";
        if(field.type().equals("select") && !Arrays.asList(field.options()).contains(value)) return label+" phải thuộc danh sách lựa chọn.";
        try {
            if(field.type().equals("date")) { LocalDate date=LocalDate.parse(value); if(field.key().equals("ngaySinh") && date.isAfter(LocalDate.now())) return label+" không được ở tương lai."; }
            if(field.type().equals("datetime-local") && LocalDateTime.parse(value).isAfter(LocalDateTime.now())) return label+" không được ở tương lai.";
            if(field.type().equals("positiveInt") && Integer.parseInt(value)<=0) return label+" phải là số nguyên dương.";
            if(List.of("moneyNonnegative","positiveDecimal","nonnegativeDecimal").contains(field.type())) {
                BigDecimal n=new BigDecimal(value); if(n.compareTo(BigDecimal.ZERO)<0) return label+" không được âm.";
                if(field.type().equals("positiveDecimal") && n.compareTo(BigDecimal.ZERO)==0) return label+" phải lớn hơn 0.";
            }
        } catch(Exception e) { return label+" không đúng định dạng hoặc giá trị hợp lệ."; }
        return null;
    }
}
