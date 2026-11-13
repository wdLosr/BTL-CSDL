package vn.edu.center;

import java.time.LocalDate;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class ReportController {
    private static final MediaType XLSX=MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    private final ReportService reports;
    private final ExcelService excel;
    public ReportController(ReportService reports,ExcelService excel){this.reports=reports;this.excel=excel;}
    @GetMapping("/m/thu-hoc-phi/excel") ResponseEntity<byte[]> receipts(@RequestParam String tuNgay,@RequestParam String denNgay,@RequestParam(defaultValue="") String maLop){
        try{
            var data=reports.receipts(LocalDate.parse(tuNgay),LocalDate.parse(denNgay),maLop);
            if(data.rows().isEmpty())throw new ResponseStatusException(HttpStatus.NOT_FOUND,"Chưa có dữ liệu để xuất.");
            return file(excel.receipts(data),"bao_cao_thu_hoc_phi.xlsx");
        }catch(BusinessException|IllegalArgumentException e){throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Bộ lọc báo cáo không hợp lệ.");}
         catch(DataAccessException e){throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,"Không truy vấn được MySQL.");}
    }
    @GetMapping("/m/danh-gia/excel") ResponseEntity<byte[]> grades(@RequestParam String maLop,@RequestParam String maBKT){
        try{
            var data=reports.grades(maLop,maBKT);
            if(data.rows().isEmpty())throw new ResponseStatusException(HttpStatus.NOT_FOUND,"Chưa có dữ liệu để xuất.");
            return file(excel.grades(data),"bao_cao_ket_qua_lop.xlsx");
        }catch(BusinessException|IllegalArgumentException e){throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Bộ lọc báo cáo không hợp lệ.");}
         catch(DataAccessException e){throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,"Không truy vấn được MySQL.");}
    }
    private ResponseEntity<byte[]> file(byte[] bytes,String name){return ResponseEntity.ok().contentType(XLSX).header(HttpHeaders.CONTENT_DISPOSITION,"attachment; filename=\""+name+"\"").body(bytes);}
}
