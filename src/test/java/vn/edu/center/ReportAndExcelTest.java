package vn.edu.center;

import static org.junit.jupiter.api.Assertions.*;

import java.io.ByteArrayInputStream;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.jupiter.api.Test;

class ReportAndExcelTest {
    @Test
    void receiptExportHasFilteredNumericTotalAndVietnamese() throws Exception {
        StubRepository db=new StubRepository();
        Map<String,Object> receipt=new LinkedHashMap<>();
        receipt.put("MaPhieu","P1");
        receipt.put("NgayThanhToan",LocalDateTime.of(2026,11,12,23,59));
        receipt.put("MaHV","HV1");receipt.put("TenHocVien","Nguyễn An");
        receipt.put("MaLop","L1");receipt.put("TenLop","Lớp một");
        receipt.put("PhuongThuc","TienMat");receipt.put("SoTien",new BigDecimal("1500000.00"));
        db.receipts=List.of(receipt);
        var report=new ReportService(db).receipts(LocalDate.of(2026,11,12),LocalDate.of(2026,11,12),"L1");
        assertEquals(new BigDecimal("1500000.00"),report.total());
        assertEquals("12/11/2026 23:59",report.rows().get(0).get("NgayThuHienThi"));
        try(var book=new XSSFWorkbook(new ByteArrayInputStream(new ExcelService().receipts(report)))) {
            var sheet=book.getSheetAt(0);
            assertEquals("BÁO CÁO THU HỌC PHÍ",sheet.getRow(0).getCell(0).getStringCellValue());
            assertEquals("Nguyễn An",sheet.getRow(4).getCell(3).getStringCellValue());
            assertEquals(CellType.NUMERIC,sheet.getRow(4).getCell(1).getCellType());
            assertEquals(CellType.NUMERIC,sheet.getRow(4).getCell(7).getCellType());
            assertEquals(1500000.0,sheet.getRow(5).getCell(7).getNumericCellValue());
        }
    }

    @Test
    void latestGradeSummaryCountsZeroButNotMissing() throws Exception {
        StubRepository db=new StubRepository();
        Map<String,Object> zero=grade("HV1",new BigDecimal("0.00"));
        Map<String,Object> missing=grade("HV2",null);
        Map<String,Object> eight=grade("HV3",new BigDecimal("8.00"));
        db.grades=List.of(zero,missing,eight);
        var report=new ReportService(db).grades("L1","B1");
        assertEquals(3,report.eligible());
        assertEquals(2,report.entered());
        assertEquals(1,report.missing());
        assertEquals(new BigDecimal("4.00"),report.average());
        try(var book=new XSSFWorkbook(new ByteArrayInputStream(new ExcelService().grades(report)))) {
            var sheet=book.getSheetAt(0);
            assertEquals("Nguyễn An",sheet.getRow(4).getCell(1).getStringCellValue());
            assertEquals(0.0,sheet.getRow(4).getCell(5).getNumericCellValue());
            assertEquals(CellType.NUMERIC,sheet.getRow(4).getCell(6).getCellType());
            assertEquals("Chưa nhập",sheet.getRow(5).getCell(7).getStringCellValue());
            assertEquals(4.0,sheet.getRow(7).getCell(5).getNumericCellValue());
        }
    }
    private Map<String,Object> grade(String id,BigDecimal score) {
        Map<String,Object> r=new LinkedHashMap<>();
        r.put("MaHV",id);r.put("HoTen","Nguyễn An");r.put("TenBKT","Bài một");
        r.put("LanThi",2);r.put("NgayThi",Date.valueOf("2026-11-12"));
        r.put("Diem",score);r.put("ThangDiem",new BigDecimal("10.00"));
        r.put("TrangThaiDiem",score==null?"Chưa nhập":"Đã nhập");
        return r;
    }

    private static class StubRepository extends CenterRepository {
        List<Map<String,Object>> receipts=List.of();
        List<Map<String,Object>> grades=List.of();
        StubRepository() { super(null); }
        @Override public List<Map<String,Object>> receiptRows(LocalDate from,LocalDate to,String classId) {
            assertEquals(LocalDate.of(2026,11,12),from);
            assertEquals(LocalDate.of(2026,11,12),to);
            assertEquals("L1",classId);
            return receipts;
        }
        @Override public Map<String,Object> test(String id) {
            assertEquals("B1",id);
            return Map.of("MaLop","L1");
        }
        @Override public List<Map<String,Object>> gradeRows(String classId,String testId) {
            assertEquals("L1",classId);
            assertEquals("B1",testId);
            return grades;
        }
    }
}
