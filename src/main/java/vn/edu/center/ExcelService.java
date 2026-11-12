package vn.edu.center;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

@Service
public class ExcelService {
    private byte[] bytes(XSSFWorkbook book) {
        try(book; ByteArrayOutputStream out=new ByteArrayOutputStream()) { book.write(out); return out.toByteArray(); }
        catch(IOException e) { throw new IllegalStateException("Không tạo được file Excel",e); }
    }
    private CellStyle style(XSSFWorkbook book,String format) {
        CreationHelper helper=book.getCreationHelper(); CellStyle style=book.createCellStyle();
        style.setDataFormat(helper.createDataFormat().getFormat(format)); return style;
    }
    private void cell(Row row,int column,Object value,CellStyle numeric) {
        var c=row.createCell(column);
        if(value instanceof BigDecimal n) { c.setCellValue(n.doubleValue()); if(numeric!=null)c.setCellStyle(numeric); }
        else if(value instanceof Number n) c.setCellValue(n.doubleValue());
        else if(value instanceof Timestamp t) { c.setCellValue(t); if(numeric!=null)c.setCellStyle(numeric); }
        else if(value instanceof java.sql.Date d) { c.setCellValue(d); if(numeric!=null)c.setCellStyle(numeric); }
        else if(value instanceof LocalDateTime d) { c.setCellValue(d); if(numeric!=null)c.setCellStyle(numeric); }
        else if(value instanceof LocalDate d) { c.setCellValue(d); if(numeric!=null)c.setCellStyle(numeric); }
        else c.setCellValue(value==null?"":value.toString());
    }
    public byte[] receipts(ReportService.ReceiptReport report) {
        XSSFWorkbook book=new XSSFWorkbook(); Sheet sheet=book.createSheet("Thu học phí");
        CellStyle money=style(book,"#,##0.00");
        CellStyle date=style(book,"dd/mm/yyyy hh:mm");
        cell(sheet.createRow(0),0,"BÁO CÁO THU HỌC PHÍ",null);
        cell(sheet.createRow(1),0,"Từ "+report.from()+" đến "+report.to()+" | Lớp: "+(report.classId().isBlank()?"Tất cả":report.classId()),null);
        String[] heads={"Mã phiếu","Ngày thu","Mã học viên","Học viên","Mã lớp","Lớp","Phương thức","Số tiền"};
        Row header=sheet.createRow(3); for(int i=0;i<heads.length;i++)cell(header,i,heads[i],null);
        int row=4; for(Map<String,Object> r:report.rows()) {
            Row line=sheet.createRow(row++); Object[] v={r.get("MaPhieu"),r.get("NgayThanhToan"),r.get("MaHV"),r.get("TenHocVien"),r.get("MaLop"),r.get("TenLop"),r.get("PhuongThucHienThi"),r.get("SoTien")};
            for(int i=0;i<v.length;i++)cell(line,i,v[i],i==7?money:i==1?date:null);
        }
        Row total=sheet.createRow(row);cell(total,6,"Tổng thực thu ("+report.count()+" phiếu)",null);cell(total,7,report.total(),money);
        for(int i=0;i<heads.length;i++)sheet.setColumnWidth(i,i==3||i==5?7000:4500);
        return bytes(book);
    }
    public byte[] grades(ReportService.GradeReport report) {
        XSSFWorkbook book=new XSSFWorkbook(); Sheet sheet=book.createSheet("Kết quả lớp");
        CellStyle score=style(book,"0.00");
        CellStyle date=style(book,"dd/mm/yyyy");
        cell(sheet.createRow(0),0,"BÁO CÁO KẾT QUẢ ĐÁNH GIÁ",null);
        cell(sheet.createRow(1),0,"Lớp: "+report.classId()+" | Bài kiểm tra: "+report.testId()+" | Lấy lần thi mới nhất",null);
        String[] heads={"Mã học viên","Họ tên","Bài kiểm tra","Lần thi","Ngày thi","Điểm","Thang điểm","Trạng thái"};
        Row header=sheet.createRow(3);for(int i=0;i<heads.length;i++)cell(header,i,heads[i],null);
        int row=4;for(Map<String,Object> r:report.rows()) {
            Row line=sheet.createRow(row++);Object[] v={r.get("MaHV"),r.get("HoTen"),r.get("TenBKT"),r.get("LanThi"),r.get("NgayThi"),r.get("Diem"),r.get("ThangDiem"),r.get("TrangThaiDiem")};
            for(int i=0;i<v.length;i++)cell(line,i,v[i],i==5||i==6?score:i==4?date:null);
        }
        Row total=sheet.createRow(row);cell(total,0,"Đủ điều kiện: "+report.eligible()+" | Đã nhập: "+report.entered()+" | Chưa nhập: "+report.missing(),null);cell(total,5,report.average(),score);
        for(int i=0;i<heads.length;i++)sheet.setColumnWidth(i,i==1||i==2?7000:4500);
        return bytes(book);
    }
}
