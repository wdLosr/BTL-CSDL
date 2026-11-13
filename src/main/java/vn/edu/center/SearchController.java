package vn.edu.center;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import org.springframework.core.io.ClassPathResource;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class SearchController {
    private final CenterRepository repository;
    private final NamedParameterJdbcTemplate db;
    private final String searchSql;

    public SearchController(CenterRepository repository, NamedParameterJdbcTemplate db) throws IOException {
        this.repository = repository;
        this.db = db;
        searchSql = new ClassPathResource("sql/13_tim_kiem.sql").getContentAsString(StandardCharsets.UTF_8);
    }

    @GetMapping("/tim-kiem")
    String search(@RequestParam(defaultValue = "") String tuKhoa,
                  @RequestParam(defaultValue = "") String maLop, Model model) {
        String keyword = tuKhoa.strip();
        String classId = maLop.strip();
        model.addAttribute("tuKhoa", keyword);
        model.addAttribute("maLop", classId);
        try {
            model.addAttribute("classes", repository.choices("lop-hoc", null));
            model.addAttribute("rows", db.queryForList(searchSql, Map.of("tuKhoa", keyword, "maLop", classId)));
        } catch (DataAccessException e) {
            model.addAttribute("dbError", "Không đọc được dữ liệu tìm kiếm từ MySQL.");
        }
        return "search";
    }
}
