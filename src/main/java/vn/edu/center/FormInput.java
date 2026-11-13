package vn.edu.center;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;

public record FormInput(Map<String,String> values) {
    public String s(String key) { return values.getOrDefault(key, "").trim(); }
    public BigDecimal money(String key) { return new BigDecimal(s(key)); }
    public LocalDate day(String key) { return LocalDate.parse(s(key)); }
    public LocalDateTime time(String key) { return LocalDateTime.parse(s(key)); }
    public int number(String key) { return Integer.parseInt(s(key)); }
    public String nullable(String key) { return s(key).isEmpty() ? null : s(key); }
}
