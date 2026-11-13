package vn.edu.center;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class ReportService {
    public record ReceiptReport(List<Map<String,Object>> rows, BigDecimal total, int count, LocalDate from, LocalDate to, String classId) {}
    public record GradeReport(List<Map<String,Object>> rows, int eligible, int entered, int missing, BigDecimal average, String classId, String testId) {}
    private final CenterRepository db;
    public ReportService(CenterRepository db) { this.db=db; }
    public ReceiptReport receipts(LocalDate from,LocalDate to,String classId) {
        if(from==null || to==null || from.isAfter(to)) throw new BusinessException("denNgay","Khoảng ngày không hợp lệ.");
        String id=classId==null?"":classId.trim();
        List<Map<String,Object>> rows=db.receiptRows(from,to,id);
        DateTimeFormatter display=DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        rows.forEach(r -> {
            Object value=r.get("NgayThanhToan");
            LocalDateTime date=value instanceof LocalDateTime t ? t : ((java.util.Date)value).toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDateTime();
            r.put("NgayThuHienThi",date.format(display));
            r.put("PhuongThucHienThi",switch(String.valueOf(r.get("PhuongThuc"))){
                case "TienMat" -> "Tiền mặt";
                case "ChuyenKhoan" -> "Chuyển khoản";
                case "The" -> "Thẻ";
                case "ViDienTu" -> "Ví điện tử";
                default -> String.valueOf(r.get("PhuongThuc"));
            });
        });
        BigDecimal total=rows.stream().map(r->(BigDecimal)r.get("SoTien")).reduce(BigDecimal.ZERO,BigDecimal::add);
        return new ReceiptReport(rows,total,rows.size(),from,to,id);
    }
    public GradeReport grades(String classId,String testId) {
        Map<String,Object> b=db.test(testId);
        if(b==null || !classId.equals(b.get("MaLop"))) throw new BusinessException("maBKT","Bài kiểm tra không thuộc lớp đã chọn.");
        List<Map<String,Object>> rows=db.gradeRows(classId,testId);
        List<BigDecimal> scores=rows.stream().map(r->(BigDecimal)r.get("Diem")).filter(v->v!=null).toList();
        BigDecimal average=scores.isEmpty()?null:scores.stream().reduce(BigDecimal.ZERO,BigDecimal::add).divide(BigDecimal.valueOf(scores.size()),2,RoundingMode.HALF_UP);
        return new GradeReport(rows,rows.size(),scores.size(),rows.size()-scores.size(),average,classId,testId);
    }
}
