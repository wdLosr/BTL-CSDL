(() => {
  const reportClass = document.querySelector('form.filters #maLop');
  if (reportClass && location.pathname.endsWith('/danh-gia')) {
    reportClass.addEventListener('change', () => {
      location.href = '/m/danh-gia' + (reportClass.value ? '?maLop=' + encodeURIComponent(reportClass.value) : '');
    });
  }
  const preview = document.getElementById('linked-preview');
  if (!preview) return;
  const classSelect = document.getElementById('maLop');
  const enrollmentSelect = document.getElementById('maDK');
  const format = n => Number(n).toLocaleString('vi-VN') + ' đ';
  const classState = {ChuanBi: 'Chuẩn bị', DangNhanDangKy: 'Đang nhận đăng ký', DangHoc: 'Đang học', DaKetThuc: 'Đã kết thúc'};
  async function load(select, kind) {
    if (!select?.value) { preview.textContent = 'Chọn lớp hoặc đăng ký để xem thông tin từ MySQL.'; return; }
    try {
      const response = await fetch('/api/' + kind + '/' + encodeURIComponent(select.value));
      if (!response.ok) throw Error();
      const data = await response.json();
      if (data.error) { preview.textContent = data.error; return; }
      preview.textContent = kind === 'lop'
        ? `${data.tenLop} · Học phí: ${format(data.hocPhi)} · Sĩ số: ${data.siSo}/${data.siSoToiDa} · Còn ${data.siSoToiDa - data.siSo} chỗ · ${classState[data.trangThai] || data.trangThai}`
        : `${data.hocVien} / ${data.lop} · Phải thu: ${format(data.phaiThu)} · Đã thu: ${format(data.daThu)} · Còn nợ: ${format(data.conNo)} · Hạn nộp: ${data.hanNop}`;
    } catch { preview.textContent = 'Không đọc được thông tin từ MySQL.'; }
  }
  const select = classSelect || enrollmentSelect;
  const kind = classSelect ? 'lop' : 'dang-ky';
  select?.addEventListener('change', () => load(select, kind));
  if (select?.value) load(select, kind);
})();
