package vn.edu.center;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class FormController {
    private final PageCatalog catalog=new PageCatalog();
    private final CenterService service;
    private final ReportService reports;
    public FormController(CenterService service,ReportService reports){this.service=service;this.reports=reports;}
    @GetMapping("/") String home(Model model){model.addAttribute("pages",catalog.all());return "home";}
    private PageCatalog.Page page(String slug){var p=catalog.get(slug);if(p==null)throw new ResponseStatusException(HttpStatus.NOT_FOUND);return p;}
    private PageCatalog.Page choices(PageCatalog.Page p,Model model,String parent){
        try{return catalog.withChoices(p,service,parent);}
        catch(DataAccessException e){model.addAttribute("dbError","Không kết nối được MySQL. Kiểm tra DB_URL, DB_USERNAME, DB_PASSWORD và trạng thái máy chủ.");return p;}
    }
    @GetMapping("/m/{slug}") String show(@PathVariable String slug,@RequestParam Map<String,String> input,Model model){
        var p=page(slug);Map<String,String> values=new LinkedHashMap<>(input),errors=new LinkedHashMap<>();
        model.addAttribute("viewed",false);
        var rendered=choices(p,model,values.get("maLop"));
        if(p.report() && input.containsKey("view") && !model.containsAttribute("dbError")){
            validate(rendered,values,errors);
            if(errors.isEmpty()) try {
                if(slug.equals("thu-hoc-phi")) model.addAttribute("receiptReport",reports.receipts(LocalDate.parse(values.get("tuNgay")),LocalDate.parse(values.get("denNgay")),values.get("maLop")));
                else model.addAttribute("gradeReport",reports.grades(values.get("maLop"),values.get("maBKT")));
                model.addAttribute("viewed",true);
            } catch(BusinessException e){errors.put(e.field(),e.getMessage());}
              catch(DataAccessException e){model.addAttribute("dbError","Không truy vấn được báo cáo từ MySQL.");}
        }
        model.addAttribute("page",rendered);model.addAttribute("values",values);model.addAttribute("errors",errors);
        if(model.containsAttribute("savedId") && slug.equals("phieu-thanh-toan")) {
            try{model.addAttribute("savedReceipt",service.receipt((String)model.asMap().get("savedId")));}
            catch(DataAccessException e){model.addAttribute("dbError","Đã lưu phiếu nhưng chưa đọc lại được từ MySQL.");}
        }
        return p.report()?"report":"form";
    }
    @PostMapping("/m/{slug}") String submit(@PathVariable String slug,@RequestParam Map<String,String> input,Model model,RedirectAttributes redirect){
        var p=page(slug);if(p.report())throw new ResponseStatusException(HttpStatus.METHOD_NOT_ALLOWED);
        Map<String,String> values=new LinkedHashMap<>(),errors=new LinkedHashMap<>();
        for(var f:p.fields())values.put(f.key(),input.getOrDefault(f.key(),"").trim());
        var rendered=choices(p,model,values.get("maLop"));
        if(!model.containsAttribute("dbError")) validate(rendered,values,errors);
        if(errors.isEmpty() && !model.containsAttribute("dbError"))try{
            String id=service.save(slug,new FormInput(values));
            redirect.addFlashAttribute("savedId",id);
            return "redirect:/m/"+slug;
        }catch(BusinessException e){errors.put(e.field(),e.getMessage());}
         catch(org.springframework.dao.DuplicateKeyException e){errors.put(p.fields().get(0).key(),"Mã hoặc cặp liên kết đã tồn tại trong MySQL.");}
         catch(org.springframework.dao.DataIntegrityViolationException e){model.addAttribute("dbError","Dữ liệu vi phạm khóa hoặc ràng buộc MySQL. Kiểm tra các mã và giá trị đã nhập.");}
         catch(DataAccessException e){model.addAttribute("dbError","Không lưu được dữ liệu. Kiểm tra kết nối MySQL và thử lại.");}
        model.addAttribute("page",rendered);model.addAttribute("values",values);model.addAttribute("errors",errors);return "form";
    }
    private void validate(PageCatalog.Page page,Map<String,String> values,Map<String,String> errors){
        for(var f:page.fields()){
            String v=values.getOrDefault(f.key(),"").trim();values.put(f.key(),v);
            if(v.isEmpty()){if(f.required())errors.put(f.key(),f.label()+" là trường bắt buộc.");continue;}
            String problem=validateField(f,v);if(problem!=null)errors.put(f.key(),problem);
        }
        if(page.slug().equals("lop-hoc") && !errors.containsKey("ngayKhaiGiang") && !errors.containsKey("ngayKetThuc") && !values.getOrDefault("ngayKhaiGiang","").isBlank() && !values.getOrDefault("ngayKetThuc","").isBlank() && LocalDate.parse(values.get("ngayKetThuc")).isBefore(LocalDate.parse(values.get("ngayKhaiGiang"))) )errors.put("ngayKetThuc","Ngày kết thúc không được trước ngày khai giảng.");
        if(page.slug().equals("dang-ky-lop") && !errors.containsKey("hanNop") && !values.getOrDefault("hanNop","").isBlank() && LocalDate.parse(values.get("hanNop")).isBefore(LocalDate.now()))errors.put("hanNop","Hạn nộp không được trước hôm nay.");
        if(page.slug().equals("thu-hoc-phi") && !errors.containsKey("tuNgay") && !errors.containsKey("denNgay") && !values.getOrDefault("tuNgay","").isBlank() && !values.getOrDefault("denNgay","").isBlank() && LocalDate.parse(values.get("tuNgay")).isAfter(LocalDate.parse(values.get("denNgay"))))errors.put("denNgay","Đến ngày không được trước từ ngày.");
    }
    private String validateField(PageCatalog.Field f,String v){
        String l=f.label();
        if(f.type().equals("id") && !Pattern.matches("[\\p{L}\\p{N}_-]+",v))return l+" chỉ được có chữ, số, dấu gạch ngang hoặc gạch dưới.";
        if(f.type().equals("id") && v.length()>20)return l+" có tối đa 20 ký tự.";
        if(f.type().equals("email") && !Pattern.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$",v))return l+" không đúng định dạng email.";
        if(f.type().equals("tel") && !Pattern.matches("0[0-9]{9,10}",v))return l+" phải bắt đầu bằng 0 và có 10–11 chữ số.";
        if((f.type().equals("select")||f.type().equals("lookup")) && f.options().stream().noneMatch(o->o.value().equals(v)))return l+" không thuộc danh sách MySQL.";
        try{
            if(f.type().equals("date")){LocalDate date=LocalDate.parse(v);if(f.key().equals("ngaySinh") && date.isAfter(LocalDate.now()))return l+" không được ở tương lai.";}
            if(f.type().equals("datetime-local") && LocalDateTime.parse(v).isAfter(LocalDateTime.now()))return l+" không được ở tương lai.";
            if(f.type().equals("positiveInt") && Integer.parseInt(v)<=0)return l+" phải là số nguyên dương.";
            if(Arrays.asList("moneyNonnegative","positiveDecimal","nonnegativeDecimal").contains(f.type())){
                BigDecimal n=new BigDecimal(v);if(n.signum()<0)return l+" không được âm.";
                if(f.type().equals("positiveDecimal") && n.signum()==0)return l+" phải lớn hơn 0.";
                if(n.scale()>2)return l+" có tối đa hai chữ số thập phân.";
                if(n.compareTo(new BigDecimal(f.key().equals("thangDiem") || f.key().equals("diem") ? "99.99" : "9999999999.99"))>0)return l+" vượt giới hạn của cột MySQL.";
            }
        }catch(Exception e){return l+" không đúng định dạng hoặc giá trị hợp lệ.";}
        return null;
    }
    @GetMapping("/api/lop/{id}") @ResponseBody Map<String,Object> classPreview(@PathVariable String id){
        var c=service.classInfo(id);if(c==null)return Map.of("error","Lớp không tồn tại.");
        var result=new LinkedHashMap<String,Object>();result.put("tenLop",c.get("TenLop"));result.put("hocPhi",c.get("HocPhi"));result.put("siSo",service.seats(id));result.put("siSoToiDa",c.get("SiSoToiDa"));result.put("trangThai",c.get("TrangThai"));return result;
    }
    @GetMapping("/api/dang-ky/{id}") @ResponseBody Map<String,Object> paymentPreview(@PathVariable String id){
        var d=service.enrollmentInfo(id);if(d==null)return Map.of("error","Đăng ký không tồn tại.");
        var result=new LinkedHashMap<String,Object>();result.put("hocVien",d.get("HoTen"));result.put("lop",d.get("TenLop"));result.put("phaiThu",d.get("KhoanPhaiThu"));result.put("daThu",service.paid(id));result.put("conNo",((BigDecimal)d.get("KhoanPhaiThu")).subtract(service.paid(id)));result.put("hanNop",d.get("HanNop").toString());return result;
    }
}
