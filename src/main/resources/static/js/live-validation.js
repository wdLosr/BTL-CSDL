(() => {
  const form = document.querySelector('form[data-live-validation]');
  if (!form) return;

  function message(field, checkEmpty) {
    const value = field.value.trim();
    const label = field.dataset.label;
    const kind = field.dataset.kind;
    if (!value) return checkEmpty && field.required ? `${label} là trường bắt buộc.` : '';
    if (field.validity.badInput) return `${label} không đúng định dạng hoặc giá trị hợp lệ.`;
    if (kind === 'id' && !/^[\p{L}\p{N}_-]+$/u.test(value)) return `${label} chỉ được có chữ, số, dấu gạch ngang hoặc gạch dưới.`;
    if (kind === 'email' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) return `${label} không đúng định dạng email.`;
    if (kind === 'tel' && !/^0[0-9]{9,10}$/.test(value)) return `${label} phải bắt đầu bằng 0 và có 10–11 chữ số.`;
    if (kind === 'date' && !/^\d{4}-\d{2}-\d{2}$/.test(value)) return `${label} không đúng định dạng ngày.`;
    if (kind === 'datetime-local' && Number.isNaN(new Date(value).getTime())) return `${label} không đúng định dạng ngày giờ.`;
    const today = new Date();
    const localToday = [today.getFullYear(), String(today.getMonth() + 1).padStart(2, '0'), String(today.getDate()).padStart(2, '0')].join('-');
    if (field.name === 'ngaySinh' && value > localToday) return `${label} không được ở tương lai.`;
    if (field.name === 'ngayThanhToan' && new Date(value) > new Date()) return `${label} không được ở tương lai.`;
    if (kind === 'positiveInt' && (!/^[0-9]+$/.test(value) || Number(value) <= 0)) return `${label} phải là số nguyên dương.`;
    if (['moneyNonnegative', 'positiveDecimal', 'nonnegativeDecimal'].includes(kind)) {
      const number = Number(value);
      if (!Number.isFinite(number)) return `${label} không đúng định dạng số.`;
      if (number < 0) return `${label} không được âm.`;
      if (kind === 'positiveDecimal' && number === 0) return `${label} phải lớn hơn 0.`;
    }
    const get = name => form.elements.namedItem(name)?.value.trim() || '';
    if (field.name === 'hanNop' && value < localToday) return 'Hạn nộp không được trước hôm nay.';
    if (field.name === 'ngayKetThuc' && get('ngayKhaiGiang') && value < get('ngayKhaiGiang')) return 'Ngày kết thúc không được trước ngày khai giảng.';
    if (field.name === 'denNgay' && get('tuNgay') && value < get('tuNgay')) return 'Đến ngày không được trước từ ngày.';
    return '';
  }

  function show(field, checkEmpty) {
    const error = field.closest('.field').querySelector('.error');
    const text = message(field, checkEmpty);
    error.textContent = text;
    field.setAttribute('aria-invalid', text ? 'true' : 'false');
  }

  form.querySelectorAll('input, select').forEach(field => {
    field.addEventListener('input', () => show(field, false));
    field.addEventListener('change', () => show(field, false));
    field.addEventListener('blur', () => show(field, true));
  });
  [['ngayKhaiGiang', 'ngayKetThuc'], ['tuNgay', 'denNgay']].forEach(([a, b]) => {
    const source = form.elements.namedItem(a), target = form.elements.namedItem(b);
    if (source && target) source.addEventListener('input', () => { if (target.value) show(target, false); });
  });
})();
