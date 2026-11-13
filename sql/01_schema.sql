-- ============================================================================
-- HỆ THỐNG QUẢN LÝ TRUNG TÂM TIẾNG ANH (MYSQL / MARIADB VERSION)
-- Bài tập lớn môn Cơ sở dữ liệu · Nhóm 2 · PTIT
-- Phụ trách thiết kế và cài đặt CSDL (Tiêu chí 3, 4, 8): Quang
-- Tệp tin: 01_schema.sql
-- Mục đích: DDL khởi tạo toàn bộ cấu trúc CSDL trên MySQL / MariaDB (InnoDB, UTF-8)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. THIẾT LẬP MÔI TRƯỜNG VÀ CƠ SỞ DỮ LIỆU MYSQL
-- ----------------------------------------------------------------------------
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- Tạo cơ sở dữ liệu nếu chưa tồn tại và kích hoạt sử dụng
CREATE DATABASE IF NOT EXISTS english_center_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE english_center_db;

-- ----------------------------------------------------------------------------
-- 1. XÓA CÁC ĐỐI TƯỢNG CŨ NẾU ĐÃ TỒN TẠI (THEO CÚ PHÁP MYSQL)
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS v_bao_cao_ket_qua_lop;
DROP VIEW IF EXISTS v_bao_cao_thu_hoc_phi;
DROP VIEW IF EXISTS v_dang_ky_hoc_phi;
DROP VIEW IF EXISTS v_si_so_lop;

DROP TABLE IF EXISTS LAM_BAI;
DROP TABLE IF EXISTS BAI_KIEM_TRA;
DROP TABLE IF EXISTS DE_THI;
DROP TABLE IF EXISTS PHIEU_THANH_TOAN;
DROP TABLE IF EXISTS DANG_KY;
DROP TABLE IF EXISTS GIANG_DAY;
DROP TABLE IF EXISTS LOP_HOC;
DROP TABLE IF EXISTS HOC_VIEN;
DROP TABLE IF EXISTS NHAN_VIEN;
DROP TABLE IF EXISTS GIAO_VIEN;
DROP TABLE IF EXISTS NHAN_SU;
DROP TABLE IF EXISTS KHOA_HOC;
DROP TABLE IF EXISTS CO_SO;

-- ----------------------------------------------------------------------------
-- 2. TẠO CÁC BẢNG QUAN HỆ (ENGINE=InnoDB, ĐẦY ĐỦ KHÓA CHÍNH, NGOẠI, CHECK)
-- ----------------------------------------------------------------------------

-- BẢNG 1: CƠ SỞ ĐÀO TẠO
CREATE TABLE CO_SO (
    MaCS        VARCHAR(20)     NOT NULL,
    TenCS       VARCHAR(100)    NOT NULL,
    DiaChi      VARCHAR(255)    NOT NULL,
    SDT         VARCHAR(15)     NULL,
    TrangThai   VARCHAR(20)     NOT NULL DEFAULT 'HoatDong',
    CONSTRAINT PK_CO_SO PRIMARY KEY (MaCS),
    CONSTRAINT CK_CO_SO_TrangThai CHECK (TrangThai IN ('HoatDong', 'TamDung'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 2: KHÓA HỌC ĐÀO TẠO
CREATE TABLE KHOA_HOC (
    MaKH        VARCHAR(20)     NOT NULL,
    TenKH       VARCHAR(150)    NOT NULL,
    GiaKH       DECIMAL(12,2)   NOT NULL,
    ThoiLuong   INT             NOT NULL,
    MoTa        TEXT            NULL,
    TrangThai   VARCHAR(20)     NOT NULL DEFAULT 'DangMo',
    CONSTRAINT PK_KHOA_HOC PRIMARY KEY (MaKH),
    CONSTRAINT CK_KHOA_HOC_GiaKH CHECK (GiaKH >= 0),
    CONSTRAINT CK_KHOA_HOC_ThoiLuong CHECK (ThoiLuong > 0),
    CONSTRAINT CK_KHOA_HOC_TrangThai CHECK (TrangThai IN ('DangMo', 'NgungMo'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 3: NHÂN SỰ (SUPERTYPE TRONG MÔ HÌNH ISA)
CREATE TABLE NHAN_SU (
    MaNS        VARCHAR(20)     NOT NULL,
    HoTen       VARCHAR(100)    NOT NULL,
    NgaySinh    DATE            NOT NULL,
    GioiTinh    VARCHAR(10)     NOT NULL DEFAULT 'Nam',
    SDT         VARCHAR(15)     NOT NULL,
    Email       VARCHAR(100)    NOT NULL,
    DiaChi      VARCHAR(255)    NULL,
    TrangThai   VARCHAR(20)     NOT NULL DEFAULT 'DangLamViec',
    CONSTRAINT PK_NHAN_SU PRIMARY KEY (MaNS),
    CONSTRAINT UQ_NHAN_SU_SDT UNIQUE (SDT),
    CONSTRAINT UQ_NHAN_SU_Email UNIQUE (Email),
    CONSTRAINT CK_NHAN_SU_GioiTinh CHECK (GioiTinh IN ('Nam', 'Nu', 'Khac')),
    CONSTRAINT CK_NHAN_SU_TrangThai CHECK (TrangThai IN ('DangLamViec', 'NghiViec'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 4: GIÁO VIÊN (SUBTYPE ISA CỦA NHAN_SU)
CREATE TABLE GIAO_VIEN (
    MaNS        VARCHAR(20)     NOT NULL,
    HocVi       VARCHAR(50)     NOT NULL,
    ChuyenMon   VARCHAR(100)    NOT NULL,
    CONSTRAINT PK_GIAO_VIEN PRIMARY KEY (MaNS),
    CONSTRAINT FK_GIAO_VIEN_NHAN_SU FOREIGN KEY (MaNS) 
        REFERENCES NHAN_SU(MaNS) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 5: NHÂN VIÊN HÀNH CHÍNH / TƯ VẤN / THU NGÂN (SUBTYPE ISA CỦA NHAN_SU)
CREATE TABLE NHAN_VIEN (
    MaNS        VARCHAR(20)     NOT NULL,
    ViTri       VARCHAR(50)     NOT NULL,
    CONSTRAINT PK_NHAN_VIEN PRIMARY KEY (MaNS),
    CONSTRAINT FK_NHAN_VIEN_NHAN_SU FOREIGN KEY (MaNS) 
        REFERENCES NHAN_SU(MaNS) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CK_NHAN_VIEN_ViTri CHECK (ViTri IN ('TuVan', 'GiaoVu', 'ThuNgan', 'QuanLy'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 6: HỌC VIÊN
CREATE TABLE HOC_VIEN (
    MaHV        VARCHAR(20)     NOT NULL,
    HoTen       VARCHAR(100)    NOT NULL,
    NgaySinh    DATE            NOT NULL,
    GioiTinh    VARCHAR(10)     NOT NULL DEFAULT 'Nam',
    SDT         VARCHAR(15)     NOT NULL,
    Email       VARCHAR(100)    NOT NULL,
    DiaChi      VARCHAR(255)    NULL,
    NgayTao     DATE            NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT PK_HOC_VIEN PRIMARY KEY (MaHV),
    CONSTRAINT UQ_HOC_VIEN_SDT UNIQUE (SDT),
    CONSTRAINT UQ_HOC_VIEN_Email UNIQUE (Email),
    CONSTRAINT CK_HOC_VIEN_GioiTinh CHECK (GioiTinh IN ('Nam', 'Nu', 'Khac'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 7: LỚP HỌC CỤ THỂ
CREATE TABLE LOP_HOC (
    MaLop           VARCHAR(20)     NOT NULL,
    TenLop          VARCHAR(150)    NOT NULL,
    MaKH            VARCHAR(20)     NOT NULL,
    MaCS            VARCHAR(20)     NOT NULL,
    LichHoc         VARCHAR(100)    NOT NULL,
    SiSoToiDa       INT             NOT NULL DEFAULT 20,
    HocPhi          DECIMAL(12,2)   NOT NULL,
    TrangThai       VARCHAR(25)     NOT NULL DEFAULT 'ChuanBi',
    NgayKhaiGiang   DATE            NULL,
    NgayKetThuc     DATE            NULL,
    CONSTRAINT PK_LOP_HOC PRIMARY KEY (MaLop),
    CONSTRAINT FK_LOP_HOC_KHOA_HOC FOREIGN KEY (MaKH) 
        REFERENCES KHOA_HOC(MaKH) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_LOP_HOC_CO_SO FOREIGN KEY (MaCS) 
        REFERENCES CO_SO(MaCS) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT CK_LOP_HOC_SiSoToiDa CHECK (SiSoToiDa > 0),
    CONSTRAINT CK_LOP_HOC_HocPhi CHECK (HocPhi >= 0),
    CONSTRAINT CK_LOP_HOC_TrangThai CHECK (TrangThai IN ('ChuanBi', 'DangNhanDangKy', 'DangHoc', 'DaKetThuc')),
    CONSTRAINT CK_LOP_HOC_Ngay CHECK (NgayKetThuc IS NULL OR NgayKhaiGiang IS NULL OR NgayKetThuc >= NgayKhaiGiang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 8: PHÂN CÔNG GIẢNG DẠY (LIÊN KẾT N-N GIỮA GIÁO VIÊN VÀ LỚP)
CREATE TABLE GIANG_DAY (
    MaNS            VARCHAR(20)     NOT NULL,
    MaLop           VARCHAR(20)     NOT NULL,
    VaiTro          VARCHAR(30)     NOT NULL DEFAULT 'GiaoVienChinh',
    NgayPhanCong    DATE            NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT PK_GIANG_DAY PRIMARY KEY (MaNS, MaLop),
    CONSTRAINT FK_GIANG_DAY_GIAO_VIEN FOREIGN KEY (MaNS) 
        REFERENCES GIAO_VIEN(MaNS) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_GIANG_DAY_LOP_HOC FOREIGN KEY (MaLop) 
        REFERENCES LOP_HOC(MaLop) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CK_GIANG_DAY_VaiTro CHECK (VaiTro IN ('GiaoVienChinh', 'TroGiang'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 9: ĐĂNG KÝ HỌC (CHỐT HỌC PHÍ TẠI THỜI ĐIỂM GHI DANH)
CREATE TABLE DANG_KY (
    MaDK            VARCHAR(20)     NOT NULL,
    MaHV            VARCHAR(20)     NOT NULL,
    MaLop           VARCHAR(20)     NOT NULL,
    NgayDK          DATE            NOT NULL DEFAULT (CURRENT_DATE),
    KhoanPhaiThu    DECIMAL(12,2)   NOT NULL,
    HanNop          DATE            NOT NULL,
    TrangThaiDK     VARCHAR(20)     NOT NULL DEFAULT 'DaXacNhan',
    CONSTRAINT PK_DANG_KY PRIMARY KEY (MaDK),
    CONSTRAINT UQ_DANG_KY_HV_Lop UNIQUE (MaHV, MaLop),
    CONSTRAINT FK_DANG_KY_HOC_VIEN FOREIGN KEY (MaHV) 
        REFERENCES HOC_VIEN(MaHV) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_DANG_KY_LOP_HOC FOREIGN KEY (MaLop) 
        REFERENCES LOP_HOC(MaLop) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT CK_DANG_KY_KhoanPhaiThu CHECK (KhoanPhaiThu >= 0),
    CONSTRAINT CK_DANG_KY_TrangThai CHECK (TrangThaiDK IN ('DaXacNhan', 'DaHuy', 'DaHoanThanh')),
    CONSTRAINT CK_DANG_KY_HanNop CHECK (HanNop >= NgayDK)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 10: PHIẾU THANH TOÁN (LẦN THU HỌC PHÍ)
CREATE TABLE PHIEU_THANH_TOAN (
    MaPhieu         VARCHAR(20)     NOT NULL,
    MaDK            VARCHAR(20)     NOT NULL,
    NgayThanhToan   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SoTien          DECIMAL(12,2)   NOT NULL,
    PhuongThuc      VARCHAR(30)     NOT NULL DEFAULT 'TienMat',
    TrangThai       VARCHAR(20)     NOT NULL DEFAULT 'ThanhCong',
    GhiChu          VARCHAR(255)    NULL,
    CONSTRAINT PK_PHIEU_THANH_TOAN PRIMARY KEY (MaPhieu),
    CONSTRAINT FK_PHIEU_THANH_TOAN_DANG_KY FOREIGN KEY (MaDK) 
        REFERENCES DANG_KY(MaDK) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT CK_PHIEU_THANH_TOAN_SoTien CHECK (SoTien > 0),
    CONSTRAINT CK_PHIEU_THANH_TOAN_PhuongThuc CHECK (PhuongThuc IN ('TienMat', 'ChuyenKhoan', 'The', 'ViDienTu')),
    CONSTRAINT CK_PHIEU_THANH_TOAN_TrangThai CHECK (TrangThai IN ('ThanhCong', 'DaHuy'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 11: ĐỀ THI
CREATE TABLE DE_THI (
    MaDe            VARCHAR(20)     NOT NULL,
    TenDe           VARCHAR(150)    NOT NULL,
    ThoiLuong       INT             NOT NULL DEFAULT 60,
    LoaiDe          VARCHAR(50)     NOT NULL DEFAULT 'TracNghiem',
    MoTa            TEXT            NULL,
    CONSTRAINT PK_DE_THI PRIMARY KEY (MaDe),
    CONSTRAINT CK_DE_THI_ThoiLuong CHECK (ThoiLuong > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 12: BÀI KIỂM TRA (ĐỢT ĐÁNH GIÁ THEO LỚP)
CREATE TABLE BAI_KIEM_TRA (
    MaBKT           VARCHAR(20)     NOT NULL,
    TenBKT          VARCHAR(150)    NOT NULL,
    MaLop           VARCHAR(20)     NOT NULL,
    MaDe            VARCHAR(20)     NOT NULL,
    LoaiBKT         VARCHAR(50)     NOT NULL DEFAULT 'GiuaKy',
    ThangDiem       DECIMAL(4,2)    NOT NULL DEFAULT 10.00,
    NgayKiemTra     DATE            NULL,
    CONSTRAINT PK_BAI_KIEM_TRA PRIMARY KEY (MaBKT),
    CONSTRAINT FK_BAI_KIEM_TRA_LOP_HOC FOREIGN KEY (MaLop) 
        REFERENCES LOP_HOC(MaLop) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_BAI_KIEM_TRA_DE_THI FOREIGN KEY (MaDe) 
        REFERENCES DE_THI(MaDe) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT CK_BAI_KIEM_TRA_ThangDiem CHECK (ThangDiem > 0),
    CONSTRAINT CK_BAI_KIEM_TRA_LoaiBKT CHECK (LoaiBKT IN ('GiuaKy', 'CuoiKy', 'ChuyenCan', 'DinhKy'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG 13: KẾT QUẢ LÀM BÀI KIỂM TRA (HỖ TRỢ THI LẠI QUA LanThi)
CREATE TABLE LAM_BAI (
    MaHV            VARCHAR(20)     NOT NULL,
    MaBKT           VARCHAR(20)     NOT NULL,
    LanThi          INT             NOT NULL DEFAULT 1,
    NgayThi         DATE            NOT NULL DEFAULT (CURRENT_DATE),
    Diem            DECIMAL(4,2)    NULL,
    GhiChu          VARCHAR(255)    NULL,
    CONSTRAINT PK_LAM_BAI PRIMARY KEY (MaHV, MaBKT, LanThi),
    CONSTRAINT FK_LAM_BAI_HOC_VIEN FOREIGN KEY (MaHV) 
        REFERENCES HOC_VIEN(MaHV) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_LAM_BAI_BAI_KIEM_TRA FOREIGN KEY (MaBKT) 
        REFERENCES BAI_KIEM_TRA(MaBKT) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CK_LAM_BAI_LanThi CHECK (LanThi >= 1),
    CONSTRAINT CK_LAM_BAI_Diem CHECK (Diem IS NULL OR Diem >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 3. CÁC CHỈ MỤC TỐI ƯU TRUY VẤN (INDEXES)
-- ----------------------------------------------------------------------------
CREATE INDEX IDX_LOP_HOC_KH ON LOP_HOC(MaKH);
CREATE INDEX IDX_LOP_HOC_CS ON LOP_HOC(MaCS);
CREATE INDEX IDX_DANG_KY_Lop ON DANG_KY(MaLop);
CREATE INDEX IDX_DANG_KY_HV ON DANG_KY(MaHV);
CREATE INDEX IDX_PHIEU_DK ON PHIEU_THANH_TOAN(MaDK);
CREATE INDEX IDX_PHIEU_Ngay ON PHIEU_THANH_TOAN(NgayThanhToan);
CREATE INDEX IDX_BKT_Lop ON BAI_KIEM_TRA(MaLop);
CREATE INDEX IDX_LAM_BAI_BKT ON LAM_BAI(MaBKT);

-- ----------------------------------------------------------------------------
-- 4. CÁC VIEW TIỆN ÍCH DÙNG CHUNG CHO CẢ NHÓM (KHANH, LỘC, HUY)
-- ----------------------------------------------------------------------------

-- VIEW 1: THEO DÕI SĨ SỐ THỰC TẾ VÀ SỐ CHỖ CÒN LẠI CỦA TỪNG LỚP
-- Phục vụ: Khanh (Form đăng ký lớp) & Lộc (Màn hình tìm kiếm)
CREATE OR REPLACE VIEW v_si_so_lop AS
SELECT 
    l.MaLop,
    l.TenLop,
    l.SiSoToiDa,
    l.HocPhi,
    l.TrangThai AS TrangThaiLop,
    COUNT(CASE WHEN dk.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh') THEN 1 END) AS SiSoHienTai,
    (l.SiSoToiDa - COUNT(CASE WHEN dk.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh') THEN 1 END)) AS SoChoConLai,
    CASE 
        WHEN (l.SiSoToiDa - COUNT(CASE WHEN dk.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh') THEN 1 END)) <= 0 THEN 'DaDay'
        WHEN l.TrangThai != 'DangNhanDangKy' THEN 'NgungNhan'
        ELSE 'ConCho'
    END AS TinhTrangDangKy
FROM LOP_HOC l
LEFT JOIN DANG_KY dk ON l.MaLop = dk.MaLop
GROUP BY l.MaLop, l.TenLop, l.SiSoToiDa, l.HocPhi, l.TrangThai;

-- VIEW 2: TỔNG HỢP CÔNG NỢ, ĐÃ THU VÀ SỐ DƯ THEO ĐĂNG KÝ
-- Phục vụ: Khanh (Form thu học phí) & Lộc (Màn hình tìm kiếm theo học viên/lớp)
CREATE OR REPLACE VIEW v_dang_ky_hoc_phi AS
SELECT 
    dk.MaDK,
    dk.MaHV,
    hv.HoTen,
    hv.SDT,
    hv.Email,
    dk.MaLop,
    lh.TenLop,
    dk.NgayDK,
    dk.KhoanPhaiThu,
    dk.HanNop,
    dk.TrangThaiDK,
    COALESCE(SUM(CASE WHEN ptt.TrangThai = 'ThanhCong' THEN ptt.SoTien ELSE 0 END), 0.00) AS TongDaThu,
    CASE 
        WHEN dk.TrangThaiDK = 'DaHuy' THEN NULL
        ELSE (dk.KhoanPhaiThu - COALESCE(SUM(CASE WHEN ptt.TrangThai = 'ThanhCong' THEN ptt.SoTien ELSE 0 END), 0.00))
    END AS SoDu,
    CASE 
        WHEN dk.TrangThaiDK = 'DaHuy' THEN 'KhongApDung'
        WHEN COALESCE(SUM(CASE WHEN ptt.TrangThai = 'ThanhCong' THEN ptt.SoTien ELSE 0 END), 0.00) >= dk.KhoanPhaiThu THEN 'DaHoanThanh'
        WHEN CURRENT_DATE > dk.HanNop THEN 'QuaHan'
        ELSE 'ConNo'
    END AS TrangThaiHocPhi
FROM DANG_KY dk
JOIN HOC_VIEN hv ON dk.MaHV = hv.MaHV
JOIN LOP_HOC lh ON dk.MaLop = lh.MaLop
LEFT JOIN PHIEU_THANH_TOAN ptt ON dk.MaDK = ptt.MaDK
GROUP BY dk.MaDK, dk.MaHV, hv.HoTen, hv.SDT, hv.Email, dk.MaLop, lh.TenLop, dk.NgayDK, dk.KhoanPhaiThu, dk.HanNop, dk.TrangThaiDK;

-- VIEW 3: BÁO CÁO THU HỌC PHÍ THEO KỲ
-- Phục vụ: Huy (Báo cáo thu học phí có thể xuất Excel)
CREATE OR REPLACE VIEW v_bao_cao_thu_hoc_phi AS
SELECT 
    ptt.MaPhieu,
    ptt.NgayThanhToan,
    ptt.SoTien,
    ptt.PhuongThuc,
    ptt.TrangThai AS TrangThaiPhieu,
    dk.MaDK,
    dk.MaHV,
    hv.HoTen AS TenHocVien,
    lh.MaLop,
    lh.TenLop,
    kh.TenKH,
    cs.TenCS
FROM PHIEU_THANH_TOAN ptt
JOIN DANG_KY dk ON ptt.MaDK = dk.MaDK
JOIN HOC_VIEN hv ON dk.MaHV = hv.MaHV
JOIN LOP_HOC lh ON dk.MaLop = lh.MaLop
JOIN KHOA_HOC kh ON lh.MaKH = kh.MaKH
JOIN CO_SO cs ON lh.MaCS = cs.MaCS
WHERE ptt.TrangThai = 'ThanhCong';

-- VIEW 4: BÁO CÁO KẾT QUẢ ĐÁNH GIÁ THEO LỚP
-- Phục vụ: Huy (Báo cáo kết quả lớp có thể xuất Excel)
CREATE OR REPLACE VIEW v_bao_cao_ket_qua_lop AS
SELECT 
    lh.MaLop,
    lh.TenLop,
    bkt.MaBKT,
    bkt.TenBKT,
    bkt.LoaiBKT,
    bkt.ThangDiem,
    bkt.NgayKiemTra,
    hv.MaHV,
    hv.HoTen AS TenHocVien,
    lb.LanThi,
    lb.NgayThi,
    lb.Diem,
    CASE 
        WHEN lb.Diem IS NULL THEN 'ChuaNhapDiem'
        WHEN lb.Diem = 0.00 THEN 'DiemKhong'
        ELSE 'DaCoDiem'
    END AS TinhTrangDiem
FROM BAI_KIEM_TRA bkt
JOIN LOP_HOC lh ON bkt.MaLop = lh.MaLop
JOIN DANG_KY dk ON lh.MaLop = dk.MaLop AND dk.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')
JOIN HOC_VIEN hv ON dk.MaHV = hv.MaHV
LEFT JOIN LAM_BAI lb ON bkt.MaBKT = lb.MaBKT AND hv.MaHV = lb.MaHV
    AND lb.LanThi = (SELECT MAX(x.LanThi) FROM LAM_BAI x
                     WHERE x.MaBKT = bkt.MaBKT AND x.MaHV = hv.MaHV);

-- ---------------------------------------------------------------------------
-- 5. RÀNG BUỘC LIÊN BẢNG: bảo vệ cả khi ghi SQL trực tiếp, không qua procedure
-- ---------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_lam_bai_bi BEFORE INSERT ON LAM_BAI FOR EACH ROW
BEGIN
    DECLARE v_thang_diem DECIMAL(4,2);
    SELECT ThangDiem INTO v_thang_diem FROM BAI_KIEM_TRA WHERE MaBKT = NEW.MaBKT;
    IF v_thang_diem IS NOT NULL THEN
        IF NEW.Diem IS NOT NULL AND NEW.Diem > v_thang_diem THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Điểm vượt thang điểm bài kiểm tra';
        END IF;
        IF NOT EXISTS (
            SELECT 1 FROM BAI_KIEM_TRA b JOIN DANG_KY d ON d.MaLop = b.MaLop
             WHERE b.MaBKT = NEW.MaBKT AND d.MaHV = NEW.MaHV
               AND d.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Học viên không có đăng ký hợp lệ ở lớp của bài kiểm tra';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_lam_bai_bu BEFORE UPDATE ON LAM_BAI FOR EACH ROW
BEGIN
    DECLARE v_thang_diem DECIMAL(4,2);
    SELECT ThangDiem INTO v_thang_diem FROM BAI_KIEM_TRA WHERE MaBKT = NEW.MaBKT;
    IF v_thang_diem IS NOT NULL THEN
        IF NEW.Diem IS NOT NULL AND NEW.Diem > v_thang_diem THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Điểm vượt thang điểm bài kiểm tra';
        END IF;
        IF NOT EXISTS (
            SELECT 1 FROM BAI_KIEM_TRA b JOIN DANG_KY d ON d.MaLop = b.MaLop
             WHERE b.MaBKT = NEW.MaBKT AND d.MaHV = NEW.MaHV
               AND d.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh')
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Học viên không có đăng ký hợp lệ ở lớp của bài kiểm tra';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_bai_kiem_tra_bu BEFORE UPDATE ON BAI_KIEM_TRA FOR EACH ROW
BEGIN
    IF NEW.MaLop <> OLD.MaLop AND EXISTS (SELECT 1 FROM LAM_BAI WHERE MaBKT = OLD.MaBKT) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không chuyển bài kiểm tra đã có kết quả sang lớp khác';
    END IF;
    IF EXISTS (SELECT 1 FROM LAM_BAI WHERE MaBKT = OLD.MaBKT AND Diem > NEW.ThangDiem) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thang điểm mới thấp hơn điểm đã nhập';
    END IF;
END$$

CREATE TRIGGER trg_phieu_bi BEFORE INSERT ON PHIEU_THANH_TOAN FOR EACH ROW
BEGIN
    DECLARE v_phai_thu DECIMAL(12,2);
    DECLARE v_trang_thai VARCHAR(20);
    DECLARE v_da_thu DECIMAL(14,2);
    IF NEW.TrangThai = 'ThanhCong' THEN
        SELECT KhoanPhaiThu, TrangThaiDK INTO v_phai_thu, v_trang_thai
          FROM DANG_KY WHERE MaDK = NEW.MaDK FOR UPDATE;
        IF v_phai_thu IS NOT NULL THEN
            IF v_trang_thai NOT IN ('DaXacNhan', 'DaHoanThanh') THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đăng ký không đủ điều kiện thu';
            END IF;
            SELECT COALESCE(SUM(SoTien), 0) INTO v_da_thu FROM PHIEU_THANH_TOAN
             WHERE MaDK = NEW.MaDK AND TrangThai = 'ThanhCong';
            IF v_da_thu + NEW.SoTien > v_phai_thu THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số tiền vượt số dư còn phải thu';
            END IF;
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_phieu_bu BEFORE UPDATE ON PHIEU_THANH_TOAN FOR EACH ROW
BEGIN
    DECLARE v_phai_thu DECIMAL(12,2);
    DECLARE v_trang_thai VARCHAR(20);
    DECLARE v_da_thu DECIMAL(14,2);
    IF NEW.MaDK <> OLD.MaDK THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không chuyển phiếu thu sang đăng ký khác';
    END IF;
    IF NEW.TrangThai = 'ThanhCong' THEN
        SELECT KhoanPhaiThu, TrangThaiDK INTO v_phai_thu, v_trang_thai
          FROM DANG_KY WHERE MaDK = NEW.MaDK FOR UPDATE;
        IF v_trang_thai NOT IN ('DaXacNhan', 'DaHoanThanh') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đăng ký không đủ điều kiện thu';
        END IF;
        SELECT COALESCE(SUM(SoTien), 0) INTO v_da_thu FROM PHIEU_THANH_TOAN
         WHERE MaDK = NEW.MaDK AND MaPhieu <> OLD.MaPhieu AND TrangThai = 'ThanhCong';
        IF v_da_thu + NEW.SoTien > v_phai_thu THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số tiền vượt số dư còn phải thu';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_phieu_ai AFTER INSERT ON PHIEU_THANH_TOAN FOR EACH ROW
BEGIN
    IF NEW.TrangThai = 'ThanhCong' THEN
        UPDATE DANG_KY d SET TrangThaiDK = 'DaHoanThanh'
         WHERE d.MaDK = NEW.MaDK AND d.TrangThaiDK = 'DaXacNhan'
           AND d.KhoanPhaiThu = (SELECT SUM(p.SoTien) FROM PHIEU_THANH_TOAN p
                                WHERE p.MaDK = NEW.MaDK AND p.TrangThai = 'ThanhCong');
    END IF;
END$$

CREATE TRIGGER trg_phieu_au AFTER UPDATE ON PHIEU_THANH_TOAN FOR EACH ROW
BEGIN
    UPDATE DANG_KY d
       SET TrangThaiDK = CASE WHEN d.KhoanPhaiThu <=
             (SELECT COALESCE(SUM(p.SoTien), 0) FROM PHIEU_THANH_TOAN p
               WHERE p.MaDK = OLD.MaDK AND p.TrangThai = 'ThanhCong')
             THEN 'DaHoanThanh' ELSE 'DaXacNhan' END
     WHERE d.MaDK = OLD.MaDK AND d.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh');
END$$

CREATE TRIGGER trg_phieu_ad AFTER DELETE ON PHIEU_THANH_TOAN FOR EACH ROW
BEGIN
    UPDATE DANG_KY d
       SET TrangThaiDK = CASE WHEN d.KhoanPhaiThu <=
             (SELECT COALESCE(SUM(p.SoTien), 0) FROM PHIEU_THANH_TOAN p
               WHERE p.MaDK = OLD.MaDK AND p.TrangThai = 'ThanhCong')
             THEN 'DaHoanThanh' ELSE 'DaXacNhan' END
     WHERE d.MaDK = OLD.MaDK AND d.TrangThaiDK IN ('DaXacNhan', 'DaHoanThanh');
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- 6. KHÔI PHỤC CẤU HÌNH HỆ THỐNG MYSQL
-- ----------------------------------------------------------------------------
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
