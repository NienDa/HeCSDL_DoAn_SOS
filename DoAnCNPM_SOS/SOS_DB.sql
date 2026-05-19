CREATE DATABASE SOS -- SUPER MARKET & ONLINE SHOPPING
GO
USE SOS
GO

--------------------- TẠO BẢNG ------------------------------

-- 1. KHÁCH HÀNG
CREATE TABLE KH (
	KHID INT NOT NULL,
	TENKH NVARCHAR(50) NOT NULL,
	SDT VARCHAR(15) NOT NULL,
	DIACHI NVARCHAR(100),
	NGAYTG DATE DEFAULT GETDATE()
);

-- 2. NHÂN VIÊN
CREATE TABLE NV (
	NVID INT NOT NULL,
	TENNV NVARCHAR(50) NOT NULL,
	CAPBAC NVARCHAR(50) NOT NULL,
	LUONG MONEY NOT NULL CHECK (LUONG >= 0),
	SDT VARCHAR(15) NOT NULL,
	NGAYVL DATE DEFAULT GETDATE(),
	DIACHI NVARCHAR(100)
);

-- 3. DANH MỤC SẢN PHẨM
CREATE TABLE DMSP (
	DMSPID INT NOT NULL,
	TENDM NVARCHAR(100) NOT NULL,
	MOTA NVARCHAR(300)
);

-- 4. NHÀ CUNG CẤP
CREATE TABLE NCC (
	NCCID INT NOT NULL,
	TENNCC NVARCHAR(100) NOT NULL,
	SDTNCC VARCHAR(15),
	DIACHI NVARCHAR(100)
);

-- 5. SẢN PHẨM
CREATE TABLE SP (
	SPID INT NOT NULL,
	TENSP NVARCHAR(100) NOT NULL,
	DMSPID INT,
	NCCID INT,
	GIA MONEY NOT NULL CHECK (GIA > 0),
	SOLUONG INT DEFAULT 0 CHECK (SOLUONG >= 0),
	TRANGTHAI NVARCHAR(20) DEFAULT N'CÒN HÀNG',
	HINHANH NVARCHAR(255)
);

-- 6. HÓA ĐƠN
CREATE TABLE HD (
	HDID INT NOT NULL,
	KHID INT,
	NVID INT,
	NGAYLAP DATETIME DEFAULT GETDATE(),
	TONGTIEN MONEY CHECK (TONGTIEN >= 0),
	TRANGTHAI NVARCHAR(50) DEFAULT N'CHỜ XỬ LÝ'
);

-- 7. CHI TIẾT HÓA ĐƠN
CREATE TABLE CTHD (
	HDID INT NOT NULL,
	SPID INT NOT NULL,
	SOLUONG INT CHECK (SOLUONG > 0),
	DONGIA MONEY CHECK (DONGIA > 0)
);

-- 8. THANH TOÁN
CREATE TABLE TT (
	TTID INT NOT NULL,
	HDID INT,
	PHUONGTHUC NVARCHAR(50) DEFAULT N'TIỀN MẶT',
	NGAYTT DATETIME DEFAULT GETDATE(),
	SOTIEN MONEY CHECK (SOTIEN >= 0)
);

-- 9. GIAO HÀNG
CREATE TABLE GH (
	GHID INT NOT NULL,
	HDID INT,
	NVID INT,
	NGAYGIAO DATE,
	TRANGTHAI NVARCHAR(50) DEFAULT N'ĐANG GIAO'
);

-- 10. ĐÁNH GIÁ
CREATE TABLE DG (
	DGID INT NOT NULL,
	KHID INT NOT NULL,
	SPID INT NOT NULL,
	SAO INT CHECK (SAO BETWEEN 1 AND 5),
	BINHLUAN NVARCHAR(255),
	NGAYDG DATE DEFAULT GETDATE()
);

--------------------------------------------------------------
------------------ KHÓA CHÍNH (PRIMARY KEY) -----------------
--------------------------------------------------------------
ALTER TABLE KH ADD CONSTRAINT PK_KH PRIMARY KEY (KHID);
ALTER TABLE NV ADD CONSTRAINT PK_NV PRIMARY KEY (NVID);
ALTER TABLE DMSP ADD CONSTRAINT PK_DMSP PRIMARY KEY (DMSPID);
ALTER TABLE NCC ADD CONSTRAINT PK_NCC PRIMARY KEY (NCCID);
ALTER TABLE SP ADD CONSTRAINT PK_SP PRIMARY KEY (SPID);
ALTER TABLE HD ADD CONSTRAINT PK_HD PRIMARY KEY (HDID);
ALTER TABLE CTHD ADD CONSTRAINT PK_CTHD PRIMARY KEY (HDID, SPID);
ALTER TABLE TT ADD CONSTRAINT PK_TT PRIMARY KEY (TTID);
ALTER TABLE GH ADD CONSTRAINT PK_GH PRIMARY KEY (GHID);
ALTER TABLE DG ADD CONSTRAINT PK_DG PRIMARY KEY (DGID);

--------------------------------------------------------------
------------------ KHÓA NGOẠI (FOREIGN KEY) -----------------
--------------------------------------------------------------

-- SẢN PHẨM thuộc DANH MỤC và NHÀ CUNG CẤP
ALTER TABLE SP ADD CONSTRAINT FK_SP_DMSP FOREIGN KEY (DMSPID) REFERENCES DMSP(DMSPID);
ALTER TABLE SP ADD CONSTRAINT FK_SP_NCC FOREIGN KEY (NCCID) REFERENCES NCC(NCCID);

-- HÓA ĐƠN có KHÁCH HÀNG và NHÂN VIÊN
ALTER TABLE HD ADD CONSTRAINT FK_HD_KH FOREIGN KEY (KHID) REFERENCES KH(KHID);
ALTER TABLE HD ADD CONSTRAINT FK_HD_NV FOREIGN KEY (NVID) REFERENCES NV(NVID);

-- CHI TIẾT HÓA ĐƠN thuộc HÓA ĐƠN và SẢN PHẨM
ALTER TABLE CTHD ADD CONSTRAINT FK_CTHD_HD FOREIGN KEY (HDID) REFERENCES HD(HDID);
ALTER TABLE CTHD ADD CONSTRAINT FK_CTHD_SP FOREIGN KEY (SPID) REFERENCES SP(SPID);

-- THANH TOÁN thuộc HÓA ĐƠN
ALTER TABLE TT ADD CONSTRAINT FK_TT_HD FOREIGN KEY (HDID) REFERENCES HD(HDID);

-- GIAO HÀNG thuộc HÓA ĐƠN và NHÂN VIÊN
ALTER TABLE GH ADD CONSTRAINT FK_GH_HD FOREIGN KEY (HDID) REFERENCES HD(HDID);
ALTER TABLE GH ADD CONSTRAINT FK_GH_NV FOREIGN KEY (NVID) REFERENCES NV(NVID);

-- ĐÁNH GIÁ thuộc KHÁCH HÀNG và SẢN PHẨM
ALTER TABLE DG ADD CONSTRAINT FK_DG_KH FOREIGN KEY (KHID) REFERENCES KH(KHID);
ALTER TABLE DG ADD CONSTRAINT FK_DG_SP FOREIGN KEY (SPID) REFERENCES SP(SPID);

--------------------------------------------------------------
------------------ DỮ LIỆU MẪU ------------------------------
--------------------------------------------------------------

INSERT INTO DMSP (DMSPID, TENDM, MOTA)
VALUES (1, N'ĐỒ UỐNG', N'Nước giải khát'), (2, N'THỰC PHẨM', N'Đồ ăn nhanh');

-- Thêm các danh mục khác (chỉ thực phẩm, đồ uống, rau củ, trái cây, bánh kẹo)
INSERT INTO DMSP (DMSPID, TENDM, MOTA)
VALUES (3, N'TRÁI CÂY', N'Trái cây tươi theo mùa'),
       (4, N'RAU CỦ', N'Rau củ quả tươi'),
       (5, N'BÁNH KẸO', N'Bánh mì, bánh quy, kẹo');

INSERT INTO NCC (NCCID, TENNCC, SDTNCC, DIACHI)
VALUES (1, N'CÔNG TY COCA-COLA', '0901234567', N'HCM'),
       (2, N'VINAMILK', '0912345678', N'HÀ NỘI');

-- Thêm nhiều nhà cung cấp khác
INSERT INTO NCC (NCCID, TENNCC, SDTNCC, DIACHI)
VALUES (3, N'UNILEVER VIETNAM', '0283911111', N'HCM'),
       (4, N'SUNTORY PEPSICO VN', '0283922222', N'HCM'),
       (5, N'CÔNG TY THỰC PHẨM ABC', '0283933333', N'ĐÀ NẴNG'),
       (6, N'PANASONIC VIET NAM', '0283944444', N'HÀ NỘI');

INSERT INTO SP (SPID, TENSP, DMSPID, NCCID, GIA, SOLUONG,HINHANH)
VALUES (1, N'COKE', 1, 1, 10000, 100,'coke.jpg'),
       (2, N'MILO', 1, 2, 15000, 50,'milo.jpg'),
       (3, N'MÌ GÓI HAO HAO', 2, 2, 5000, 200,'haohao.jpg');

-- Thêm nhiều sản phẩm khác (chỉ đồ ăn, thức uống, trái cây, rau củ)
INSERT INTO SP (SPID, TENSP, DMSPID, NCCID, GIA, SOLUONG, HINHANH)
VALUES (4, N'PEPSI', 1, 4, 10000, 120,'pepsi.jpg'),
       (5, N'7UP', 1, 4, 9000, 80,'7up.jpg'),
       (6, N'DẦU ĂN TƯỜNG AN 1L', 2, 5, 55000, 60,'dauanta1l.jpg'),
       (7, N'NƯỚC MẮM NAM NGƯ 900ML', 2, 5, 32000, 70,'nuocmamnn900ml.jpg'),
       (8, N'GẠO ST25 5KG', 2, 5, 145000, 40,'st255kg.jpg'),
       (9, N'GẠO JASMINE 10KG', 2, 5, 260000, 20,'gaojamine10kg.jpg'),
       (10, N'CAM SÀNH 1KG', 3, 5, 40000, 40,'camsanh1kg.jpg'),
       (11, N'TÁO MỸ 1KG', 3, 5, 70000, 30,'taomy1kg.jpg'),
       (12, N'RAU MUỐNG 1 BÓ', 4, 5, 10000, 50,'raumuong1bo.jpg'),
       (13, N'CÀ RỐT 1KG', 4, 5, 20000, 50,'carot1kg.jpg'),
       (14, N'BÁNH MÌ Ổ', 5, 5, 5000, 100,'banhmio.jpg'),
       (15, N'BÁNH QUY COSY 300G', 5, 5, 30000, 40,'banhcosy300g.jpg');

INSERT INTO KH (KHID, TENKH, SDT, DIACHI)
VALUES (1, N'NGUYỄN VĂN A', '0987654321', N'HÀ NỘI'),
       (2, N'TRẦN THỊ B', '0977123456', N'HCM');

-- Thêm khách hàng khác
INSERT INTO KH (KHID, TENKH, SDT, DIACHI)
VALUES (3, N'LÊ VĂN C', '0901112222', N'ĐÀ NẴNG'),
       (4, N'PHẠM THỊ D', '0912223333', N'CẦN THƠ'),
       (5, N'TRƯƠNG MINH E', '0923334444', N'HẢI PHÒNG'),
       (6, N'ĐỖ THỊ F', '0934445555', N'HUẾ'),
       (7, N'NGÔ VĂN G', '0945556666', N'NHA TRANG'),
       (8, N'VŨ THỊ H', '0956667777', N'HCM');

INSERT INTO NV (NVID, TENNV, CAPBAC, LUONG, SDT, DIACHI)
VALUES (1, N'LÊ MINH', N'QUẢN LÝ', 15000000, '0909999999', N'HÀ NỘI'),
       (2, N'PHẠM ANH', N'NHÂN VIÊN', 8000000, '0918888888', N'HCM');

-- Thêm nhiều nhân viên khác
INSERT INTO NV (NVID, TENNV, CAPBAC, LUONG, SDT, DIACHI)
VALUES (3, N'TRẦN QUỐC BẢO', N'THỬ VIỆC', 6000000, '0938000001', N'HCM'),
       (4, N'NGUYỄN THU TRANG', N'NHÂN VIÊN', 9000000, '0938000002', N'HÀ NỘI'),
       (5, N'PHẠM THÀNH LONG', N'THU NGÂN', 8500000, '0938000003', N'ĐÀ NẴNG');

INSERT INTO HD (HDID, KHID, NVID, TONGTIEN)
VALUES (1, 1, 2, 30000);

-- Một số hóa đơn khác
INSERT INTO HD (HDID, KHID, NVID, TONGTIEN)
VALUES (2, 2, 1, 35000),
       (3, 3, 2, 145000),
       (4, 4, 3, 110000),
       (5, 5, 4, 55000),
       (6, 6, 5, 124000);

INSERT INTO CTHD (HDID, SPID, SOLUONG, DONGIA)
VALUES ( 1, 1, 2, 10000),
       ( 1, 3, 2, 5000);

-- Chi tiết cho các hóa đơn khác
INSERT INTO CTHD (HDID, SPID, SOLUONG, DONGIA)
VALUES ( 2, 2, 1, 15000),   -- MILO x1
       ( 2, 4, 2, 10000),   -- PEPSI x2
       ( 3, 8, 1, 145000),  -- GẠO ST25 5KG x1
       ( 4, 10, 2, 40000),  -- CAM x2
       ( 4, 12, 3, 10000),  -- RAU MUỐNG x3
       ( 5, 14, 5, 5000),   -- BÁNH MÌ x5
       ( 5, 15, 1, 30000),  -- BÁNH QUY x1
       ( 6, 6, 1, 55000),   -- DẦU ĂN x1
       ( 6, 7, 1, 32000);   -- NƯỚC MẮM x1

INSERT INTO TT (TTID, HDID, PHUONGTHUC, SOTIEN)
VALUES (1, 1, N'TIỀN MẶT', 30000);

-- Thanh toán cho các hóa đơn khác
INSERT INTO TT (TTID, HDID, PHUONGTHUC, SOTIEN)
VALUES (2, 2, N'TIỀN MẶT', 35000),
       (3, 3, N'CHUYỂN KHOẢN', 145000),
       (4, 4, N'TIỀN MẶT', 110000),
       (5, 5, N'TIỀN MẶT', 55000),
       (6, 6, N'CHUYỂN KHOẢN', 124000);

-- Giao hàng mẫu
INSERT INTO GH (GHID, HDID, NVID, NGAYGIAO, TRANGTHAI)
VALUES (1, 3, 2, '2025-01-05', N'ĐÃ GIAO'),
       (2, 4, 3, '2025-01-06', N'ĐANG GIAO');

-- Đánh giá sản phẩm mẫu
INSERT INTO DG (DGID, KHID, SPID, SAO, BINHLUAN)
VALUES (1, 1, 1, 5, N'Nước ngọt mát, giao hàng nhanh'),
       (2, 2, 3, 4, N'Mì ngon, giá hợp lý'),
       (3, 3, 10, 5, N'Cam tươi, ngọt');
--------------------------------------------------------------
------------------ CHƯƠNG 2: XỬ LÝ (T-SQL) -------------------
--------------------------------------------------------------

/*
1. HÀM TÍNH TỔNG TIỀN HÓA ĐƠN
   -> dùng để kiểm tra nhanh tổng tiền từ chi tiết hóa đơn
*/
GO
CREATE OR ALTER FUNCTION FN_TINH_TONG_HD (@HDID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TONG MONEY;
    SELECT @TONG = SUM(SOLUONG * DONGIA)
    FROM CTHD
    WHERE HDID = @HDID;

    RETURN ISNULL(@TONG, 0);
END;
GO

/*
2. TRIGGER TỰ ĐỘNG CẬP NHẬT TỔNG TIỀN VÀ TỒN KHO
   - Sau khi INSERT/UPDATE/DELETE CTHD
   - Cập nhật TONGTIEN của HD
   - Cập nhật tồn kho sản phẩm SP.SOLUONG
*/
GO
CREATE OR ALTER TRIGGER TRG_CTHD_CAPNHAT_HD_SP
ON CTHD
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật tồn kho: trừ số lượng mới thêm, cộng lại số lượng bị xóa/sửa
    -- Xử lý phần bị xóa hoặc cũ trong UPDATE
    UPDATE SP
    SET SOLUONG = SOLUONG + x.SL
    FROM SP
    JOIN (
        SELECT SPID, SUM(SOLUONG) SL
        FROM DELETED
        GROUP BY SPID
    ) x ON SP.SPID = x.SPID;

    -- Xử lý phần mới thêm hoặc mới trong UPDATE
    UPDATE SP
    SET SOLUONG = SOLUONG - x.SL
    FROM SP
    JOIN (
        SELECT SPID, SUM(SOLUONG) SL
        FROM INSERTED
        GROUP BY SPID
    ) x ON SP.SPID = x.SPID;

    -- Cập nhật TONGTIEN cho các hóa đơn bị ảnh hưởng
    DECLARE @HDID INT;

    DECLARE HD_CURSOR CURSOR FAST_FORWARD FOR
        SELECT DISTINCT HDID FROM (
            SELECT HDID FROM INSERTED
            UNION
            SELECT HDID FROM DELETED
        ) AS H
        WHERE HDID IS NOT NULL;

    OPEN HD_CURSOR;
    FETCH NEXT FROM HD_CURSOR INTO @HDID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE HD
        SET TONGTIEN = dbo.FN_TINH_TONG_HD(@HDID)
        WHERE HDID = @HDID;

        FETCH NEXT FROM HD_CURSOR INTO @HDID;
    END

    CLOSE HD_CURSOR;
    DEALLOCATE HD_CURSOR;
END;
GO

/*
3. THỦ TỤC LẬP HÓA ĐƠN BÁN HÀNG (CÓ TRANSACTION)
   - Tạo hóa đơn HD
   - Thêm nhiều dòng CTHD
   - Cập nhật tồn kho (thông qua trigger)
   - Chèn bản ghi thanh toán TT
*/
GO
CREATE OR ALTER PROCEDURE USP_TAO_HOADON
    @KHID INT,
    @NVID INT,
    @PHUONGTHUC NVARCHAR(50),
    @CTHD_LIST NVARCHAR(MAX) -- format: 'SPID,SOLUONG,DONGIA;SPID,SOLUONG,DONGIA;...'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- nếu có lỗi thì ROLLBACK toàn bộ

    BEGIN TRAN

    DECLARE @HDID INT;
    DECLARE @NEW_ID INT;

    -- Tạo mã hóa đơn mới
    SELECT @NEW_ID = ISNULL(MAX(HDID), 0) + 1 FROM HD;
    SET @HDID = @NEW_ID;

    INSERT INTO HD(HDID, KHID, NVID, NGAYLAP, TONGTIEN, TRANGTHAI)
    VALUES(@HDID, @KHID, @NVID, GETDATE(), 0, N'CHỜ XỬ LÝ');

    -- Phân tích chuỗi CTHD_LIST bằng cursor trên bảng tạm
    DECLARE @DATA TABLE (SPID INT, SOLUONG INT, DONGIA MONEY);

    DECLARE @ITEM NVARCHAR(200);
    DECLARE @POS INT;
    DECLARE @INPUT NVARCHAR(MAX);

    SET @INPUT = @CTHD_LIST + ';';

    WHILE LEN(@INPUT) > 1
    BEGIN
        SET @POS = CHARINDEX(';', @INPUT);
        SET @ITEM = SUBSTRING(@INPUT, 1, @POS - 1);
        SET @INPUT = SUBSTRING(@INPUT, @POS + 1, LEN(@INPUT));

        DECLARE @SPID INT, @SL INT, @DG MONEY;
        -- tách SPID,SOLUONG,DONGIA
        DECLARE @P1 INT = CHARINDEX(',', @ITEM);
        DECLARE @P2 INT = CHARINDEX(',', @ITEM, @P1 + 1);

        SET @SPID = CAST(SUBSTRING(@ITEM, 1, @P1 - 1) AS INT);
        SET @SL   = CAST(SUBSTRING(@ITEM, @P1 + 1, @P2 - @P1 - 1) AS INT);
        SET @DG   = CAST(SUBSTRING(@ITEM, @P2 + 1, LEN(@ITEM) - @P2) AS MONEY);

        INSERT INTO @DATA(SPID, SOLUONG, DONGIA)
        VALUES(@SPID, @SL, @DG);
    END

    -- Kiểm tra tồn kho đơn giản
    IF EXISTS (
        SELECT 1
        FROM @DATA d
        JOIN SP ON d.SPID = SP.SPID
        WHERE d.SOLUONG > SP.SOLUONG
    )
    BEGIN
        RAISERROR (N'Số lượng đặt vượt quá tồn kho.', 16, 1);
        ROLLBACK TRAN;
        RETURN;
    END

    -- Ghi chi tiết hóa đơn
    INSERT INTO CTHD(HDID, SPID, SOLUONG, DONGIA)
    SELECT @HDID, SPID, SOLUONG, DONGIA
    FROM @DATA;

    -- Tạo bản ghi thanh toán
    DECLARE @TTID INT;
    SELECT @TTID = ISNULL(MAX(TTID), 0) + 1 FROM TT;

    INSERT INTO TT(TTID, HDID, PHUONGTHUC, NGAYTT, SOTIEN)
    VALUES(@TTID, @HDID, @PHUONGTHUC, GETDATE(), dbo.FN_TINH_TONG_HD(@HDID));

    -- Đổi trạng thái hóa đơn
    UPDATE HD
    SET TRANGTHAI = N'ĐÃ THANH TOÁN',
        TONGTIEN  = dbo.FN_TINH_TONG_HD(@HDID)
    WHERE HDID = @HDID;

    COMMIT TRAN;

    SELECT @HDID AS HDID_DUOC_TAO;
END;
GO

/*
4. THỦ TỤC TRA CỨU SẢN PHẨM ĐƠN GIẢN
*/
GO
CREATE OR ALTER PROCEDURE USP_TIM_SP
    @TUKHOA NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SPID, TENSP, GIA, SOLUONG, TRANGTHAI
    FROM SP
    WHERE TENSP LIKE '%' + @TUKHOA + '%';
END;
GO

/*
5. CURSOR TÍNH TỔNG DOANH THU THEO NHÂN VIÊN (ĐƠN GIẢN)
   -> Lưu vào bảng tạm #DOANHTHU_NV để người dùng xem
*/
GO
CREATE OR ALTER PROCEDURE USP_TINH_DOANHTHU_NV
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#DOANHTHU_NV') IS NOT NULL DROP TABLE #DOANHTHU_NV;

    CREATE TABLE #DOANHTHU_NV (
        NVID INT,
        TENNV NVARCHAR(50),
        DOANHTHU MONEY
    );

    DECLARE @NVID INT, @TENNV NVARCHAR(50), @DT MONEY;

    DECLARE CUR_NV CURSOR FAST_FORWARD FOR
        SELECT NVID, TENNV FROM NV;

    OPEN CUR_NV;
    FETCH NEXT FROM CUR_NV INTO @NVID, @TENNV;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @DT = SUM(TONGTIEN)
        FROM HD
        WHERE NVID = @NVID;

        INSERT INTO #DOANHTHU_NV(NVID, TENNV, DOANHTHU)
        VALUES(@NVID, @TENNV, ISNULL(@DT, 0));

        FETCH NEXT FROM CUR_NV INTO @NVID, @TENNV;
    END

    CLOSE CUR_NV;
    DEALLOCATE CUR_NV;

    SELECT * FROM #DOANHTHU_NV;
END;
GO

/*
6. HÀM LẤY TÊN KHÁCH HÀNG THEO MÃ
*/
GO
CREATE OR ALTER FUNCTION FN_LAY_TEN_KH (@KHID INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @TEN NVARCHAR(50);
    SELECT @TEN = TENKH FROM KH WHERE KHID = @KHID;
    RETURN @TEN;
END;
GO

/*
7. HÀM BẢNG: DANH SÁCH SẢN PHẨM THEO DANH MỤC
   - Nếu @DMSPID = NULL thì trả về tất cả sản phẩm
*/
GO
CREATE OR ALTER FUNCTION FN_DANHSACH_SP_DM (@DMSPID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT SPID, TENSP, DMSPID, GIA, SOLUONG, TRANGTHAI
    FROM SP
    WHERE (@DMSPID IS NULL OR DMSPID = @DMSPID)
);
GO

/*
8. TRIGGER CẬP NHẬT TRẠNG THÁI SẢN PHẨM KHI SỐ LƯỢNG THAY ĐỔI
*/
GO
CREATE OR ALTER TRIGGER TRG_SP_CAPNHAT_TRANGTHAI
ON SP
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE SP
    SET TRANGTHAI = CASE WHEN SOLUONG <= 0 THEN N'HẾT HÀNG' ELSE N'CÒN HÀNG' END
    WHERE SPID IN (SELECT SPID FROM INSERTED);
END;
GO

/*
9. TRIGGER CHỐNG ĐÁNH GIÁ TRÙNG MỘT SẢN PHẨM CỦA CÙNG KHÁCH HÀNG
*/
GO
CREATE OR ALTER TRIGGER TRG_DG_KIEMTRA_TRUNG
ON DG
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM DG d
        JOIN INSERTED i
          ON d.KHID = i.KHID
         AND d.SPID = i.SPID
         AND d.DGID <> i.DGID
    )
    BEGIN
        RAISERROR (N'Khách hàng chỉ được đánh giá 1 lần cho mỗi sản phẩm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/*
10. THỦ TỤC THÊM SẢN PHẨM MỚI (ĐƠN GIẢN)
*/
GO
CREATE OR ALTER PROCEDURE USP_THEM_SP
    @TENSP NVARCHAR(100),
    @DMSPID INT,
    @NCCID INT,
    @GIA MONEY,
    @SOLUONG INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM DMSP WHERE DMSPID = @DMSPID)
    BEGIN
        RAISERROR (N'Danh mục không tồn tại.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM NCC WHERE NCCID = @NCCID)
    BEGIN
        RAISERROR (N'Nhà cung cấp không tồn tại.', 16, 1);
        RETURN;
    END

    DECLARE @NEW_SPID INT;
    SELECT @NEW_SPID = ISNULL(MAX(SPID),0) + 1 FROM SP;

    INSERT INTO SP(SPID, TENSP, DMSPID, NCCID, GIA, SOLUONG)
    VALUES(@NEW_SPID, @TENSP, @DMSPID, @NCCID, @GIA, @SOLUONG);

    SELECT @NEW_SPID AS SPID_MOI;
END;
GO

/*
11. THỦ TỤC TĂNG GIÁ THEO DANH MỤC (CÓ THỂ @DMSPID = NULL ĐỂ TĂNG TẤT CẢ)
*/
GO
CREATE OR ALTER PROCEDURE USP_TANG_GIA_DMSP
    @DMSPID INT,
    @PHANTRAM FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    IF @PHANTRAM = 0 RETURN;

    UPDATE SP
    SET GIA = GIA * (1 + @PHANTRAM / 100.0)
    WHERE (@DMSPID IS NULL OR DMSPID = @DMSPID);

    SELECT SPID, TENSP, GIA
    FROM SP
    WHERE (@DMSPID IS NULL OR DMSPID = @DMSPID);
END;
GO

/*
12. THỦ TỤC DÙNG CURSOR CẬP NHẬT CẤP BẬC NHÂN VIÊN TỪ LƯƠNG
*/
GO
CREATE OR ALTER PROCEDURE USP_CAPNHAT_CAPBAC_NV_TU_LUONG
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NVID INT, @LUONG MONEY, @CAPBAC NVARCHAR(50);

    DECLARE CUR_LUONG CURSOR FAST_FORWARD FOR
        SELECT NVID, LUONG FROM NV;

    OPEN CUR_LUONG;
    FETCH NEXT FROM CUR_LUONG INTO @NVID, @LUONG;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @CAPBAC =
            CASE 
                WHEN @LUONG >= 12000000 THEN N'QUẢN LÝ'
                WHEN @LUONG >= 8000000 THEN N'NHÂN VIÊN CHÍNH THỨC'
                ELSE N'THỬ VIỆC'
            END;

        UPDATE NV
        SET CAPBAC = @CAPBAC
        WHERE NVID = @NVID;

        FETCH NEXT FROM CUR_LUONG INTO @NVID, @LUONG;
    END

    CLOSE CUR_LUONG;
    DEALLOCATE CUR_LUONG;
END;
GO

--------------------------------------------------------------
------------------ CHƯƠNG 3: QUẢN TRỊ HỆ THỐNG ---------------
--------------------------------------------------------------

/*
1. TẠO LOGIN VÀ USER ĐƠN GIẢN
   (Có thể chỉnh lại tên/mật khẩu cho phù hợp máy của bạn)
*/
GO
-- Login cho nhân viên bán hàng
CREATE LOGIN NV_BANHANG WITH PASSWORD = 'Nv_banhang@123', CHECK_POLICY = OFF;
GO
CREATE USER NV_BANHANG FOR LOGIN NV_BANHANG;
GO

-- Role chỉ cho phép xem sản phẩm, tạo hóa đơn
CREATE ROLE ROLE_BANHANG;
GO
GRANT SELECT ON SP TO ROLE_BANHANG;
GRANT SELECT, INSERT ON HD TO ROLE_BANHANG;
GRANT SELECT, INSERT ON CTHD TO ROLE_BANHANG;
GRANT EXECUTE ON USP_TAO_HOADON TO ROLE_BANHANG;
GO
ALTER ROLE ROLE_BANHANG ADD MEMBER NV_BANHANG;
GO

/*
2. TẠO LOGIN QUẢN TRỊ
*/
CREATE LOGIN QL_SOS WITH PASSWORD = 'Ql_sos@123', CHECK_POLICY = OFF;
GO
CREATE USER QL_SOS FOR LOGIN QL_SOS;
GO
ALTER ROLE db_owner ADD MEMBER QL_SOS;
GO

/*
3. KẾ HOẠCH SAO LƯU HÀNG TUẦN CHO CSDL SOS
   - Thư mục backup: C:\Backup_SOS (tự tạo trước nếu chưa có)
   - FULL BACKUP: 06:00 sáng Thứ 7 và Chủ nhật
   - DIFFERENTIAL BACKUP: 23:00 mỗi ngày (không phải full)
   - Dùng SQL Server Agent job (chạy 1 lần script này để tạo job)
*/

USE msdb;
GO

-- JOB FULL BACKUP CUỐI TUẦN
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'SOS_FULL_BACKUP')
BEGIN
    EXEC sp_add_job @job_name = N'SOS_FULL_BACKUP';

    EXEC sp_add_jobstep 
        @job_name = N'SOS_FULL_BACKUP',
        @step_name = N'FULL_BACKUP_STEP',
        @subsystem = N'TSQL',
        @database_name = N'master',
        @command = N'
DECLARE @FileName NVARCHAR(260);
SET @FileName = ''C:\\Backup_SOS\\SOS_FULL_'' + 
    CONVERT(CHAR(8), GETDATE(), 112) + ''_'' + 
    REPLACE(CONVERT(CHAR(5), GETDATE(), 108), '':'', '''') + ''.bak'';

BACKUP DATABASE SOS
TO DISK = @FileName
WITH INIT, COMPRESSION, NAME = ''FULL BACKUP SOS'';
';

    EXEC sp_add_schedule 
        @schedule_name = N'SCHED_SOS_FULL_WEEKEND',
        @freq_type = 8,              -- weekly
        @freq_interval = 65,         -- Saturday (64) + Sunday (1)
        @active_start_time = 60000;  -- 06:00

    EXEC sp_attach_schedule 
        @job_name = N'SOS_FULL_BACKUP',
        @schedule_name = N'SCHED_SOS_FULL_WEEKEND';

    EXEC sp_add_jobserver @job_name = N'SOS_FULL_BACKUP';
END
GO

-- JOB DIFFERENTIAL BACKUP 23:00 HÀNG NGÀY
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'SOS_DIFF_BACKUP')
BEGIN
    EXEC sp_add_job @job_name = N'SOS_DIFF_BACKUP';

    EXEC sp_add_jobstep 
        @job_name = N'SOS_DIFF_BACKUP',
        @step_name = N'DIFF_BACKUP_STEP',
        @subsystem = N'TSQL',
        @database_name = N'master',
        @command = N'
DECLARE @FileName NVARCHAR(260);
SET @FileName = ''C:\\Backup_SOS\\SOS_DIFF_'' + 
    CONVERT(CHAR(8), GETDATE(), 112) + ''_'' + 
    REPLACE(CONVERT(CHAR(5), GETDATE(), 108), '':'', '''') + ''.bak'';

BACKUP DATABASE SOS
TO DISK = @FileName
WITH DIFFERENTIAL, INIT, COMPRESSION, NAME = ''DIFF BACKUP SOS'';
';

    EXEC sp_add_schedule 
        @schedule_name = N'SCHED_SOS_DIFF_DAILY',
        @freq_type = 4,              -- daily
        @freq_interval = 1,          -- mỗi ngày
        @active_start_time = 230000; -- 23:00

    EXEC sp_attach_schedule 
        @job_name = N'SOS_DIFF_BACKUP',
        @schedule_name = N'SCHED_SOS_DIFF_DAILY';

    EXEC sp_add_jobserver @job_name = N'SOS_DIFF_BACKUP';
END
GO

-- Lệnh phục hồi cơ bản (CHỈ CHẠY KHI CẦN RESTORE THỰC SỰ)
-- RESTORE DATABASE SOS FROM DISK = 'C:\\Backup_SOS\\TEN_FILE_FULL.bak' WITH REPLACE;
--------------------------------------------------------------
------------------ CHƯƠNG 4: KIỂM THỬ ĐƠN GIẢN --------------
--------------------------------------------------------------

/*
HƯỚNG DẪN TEST TỪNG PHẦN (chạy sau khi tạo CSDL)
--------------------------------------------------
Lưu ý: Tất cả câu lệnh dưới đây đều ở dạng gợi ý.
Bạn có thể copy từng khối, bỏ dấu "--" ở đầu dòng rồi chạy thử.

1) KIỂM TRA DỮ LIỆU CƠ BẢN
--------------------------------------------------
-- SELECT * FROM DMSP;
-- SELECT * FROM NCC;
-- SELECT * FROM SP;
-- SELECT * FROM KH;
-- SELECT * FROM NV;

2) TEST HÀM TÍNH TỔNG TIỀN HÓA ĐƠN: FN_TINH_TONG_HD
--------------------------------------------------
-- SELECT dbo.FN_TINH_TONG_HD(1) AS TONG_HD_1;

3) TEST THỦ TỤC TẠO HÓA ĐƠN + TRIGGER TỒN KHO & TỔNG TIỀN
   (USP_TAO_HOADON, TRG_CTHD_CAPNHAT_HD_SP, TRG_SP_CAPNHAT_TRANGTHAI)
--------------------------------------------------
-- EXEC USP_TAO_HOADON
--      @KHID = 1,
--      @NVID = 2,
--      @PHUONGTHUC = N'TIỀN MẶT',
--      @CTHD_LIST = '1,1,10000;3,2,5000';
--
-- SELECT * FROM HD ORDER BY HDID DESC;    -- xem hóa đơn mới tạo
-- SELECT * FROM CTHD ORDER BY HDID DESC;  -- chi tiết hóa đơn
-- SELECT * FROM SP;                       -- tồn kho đã trừ
-- SELECT * FROM TT ORDER BY TTID DESC;    -- thanh toán đã ghi nhận

4) TEST THỦ TỤC TÌM KIẾM SẢN PHẨM + HÀM BẢNG DANH SÁCH SP
   (USP_TIM_SP, FN_DANHSACH_SP_DM)
--------------------------------------------------
-- EXEC USP_TIM_SP @TUKHOA = N'MÌ';
-- SELECT * FROM dbo.FN_DANHSACH_SP_DM(1);     -- sản phẩm thuộc danh mục 1
-- SELECT * FROM dbo.FN_DANHSACH_SP_DM(NULL);  -- tất cả sản phẩm

5) TEST THỦ TỤC DOANH THU THEO NHÂN VIÊN (CURSOR)
   (USP_TINH_DOANHTHU_NV)
--------------------------------------------------
-- EXEC USP_TINH_DOANHTHU_NV;

6) TEST HÀM LẤY TÊN KHÁCH HÀNG
   (FN_LAY_TEN_KH)
--------------------------------------------------
-- SELECT dbo.FN_LAY_TEN_KH(1) AS TEN_KH_1;

7) TEST THỦ TỤC THÊM SẢN PHẨM MỚI + TRIGGER TRẠNG THÁI
   (USP_THEM_SP, TRG_SP_CAPNHAT_TRANGTHAI)
--------------------------------------------------
-- EXEC USP_THEM_SP
--      @TENSP = N'BÁNH MÌ',
--      @DMSPID = 2,
--      @NCCID = 2,
--      @GIA = 7000,
--      @SOLUONG = 30;
--
-- SELECT * FROM SP WHERE TENSP = N'BÁNH MÌ';

8) TEST THỦ TỤC TĂNG GIÁ THEO DANH MỤC
   (USP_TANG_GIA_DMSP)
--------------------------------------------------
-- EXEC USP_TANG_GIA_DMSP @DMSPID = 1, @PHANTRAM = 10;  -- tăng 10% nhóm đồ uống
-- SELECT * FROM SP WHERE DMSPID = 1;

9) TEST TRIGGER KIỂM TRA ĐÁNH GIÁ TRÙNG
   (TRG_DG_KIEMTRA_TRUNG)
--------------------------------------------------
-- -- Lần 1: thêm đánh giá hợp lệ
-- INSERT INTO DG(DGID, KHID, SPID, SAO, BINHLUAN)
-- VALUES (1, 1, 1, 5, N'Rất ngon');
--
-- -- Lần 2: thử đánh giá lại cùng KHID, SPID -> sẽ báo lỗi và ROLLBACK
-- INSERT INTO DG(DGID, KHID, SPID, SAO, BINHLUAN)
-- VALUES (2, 1, 1, 4, N'Ngon nhưng hơi ngọt');

10) TEST THỦ TỤC CẬP NHẬT CẤP BẬC NHÂN VIÊN (CURSOR)
    (USP_CAPNHAT_CAPBAC_NV_TU_LUONG)
--------------------------------------------------
-- SELECT * FROM NV;  -- xem CAPBAC hiện tại
-- EXEC USP_CAPNHAT_CAPBAC_NV_TU_LUONG;
-- SELECT * FROM NV;  -- CAPBAC đã được cập nhật lại theo LUONG

11) KIỂM TRA LOGIN / ROLE
    (NV_BANHANG, ROLE_BANHANG, QL_SOS)
--------------------------------------------------
-- Bước 1: Trong SQL Server Management Studio, đăng nhập bằng login NV_BANHANG.
-- Bước 2: Thử SELECT * FROM SP;  -> ĐƯỢC PHÉP.
-- Bước 3: Thử DELETE FROM SP;     -> BỊ TỪ CHỐI.
-- Bước 4: Thử EXEC USP_TAO_HOADON ... -> ĐƯỢC PHÉP.
-- Bước 5: Tài khoản QL_SOS (db_owner) có thể làm mọi thao tác.

12) KIỂM TRA JOB BACKUP HÀNG NGÀY/HÀNG TUẦN
--------------------------------------------------
-- USE msdb;
-- GO
-- SELECT name FROM dbo.sysjobs WHERE name LIKE 'SOS_%';
-- SELECT j.name AS JobName, s.name AS ScheduleName, s.freq_type, s.freq_interval, s.active_start_time
-- FROM sysjobs j
-- JOIN sysjobschedules js ON j.job_id = js.job_id
-- JOIN sysschedules s ON js.schedule_id = s.schedule_id
-- WHERE j.name LIKE 'SOS_%';

-- Sau khi đợi job chạy (hoặc chạy tay), kiểm tra thư mục C:\Backup_SOS
-- sẽ thấy các file SOS_FULL_yyyyMMdd_hhmm.bak và SOS_DIFF_yyyyMMdd_hhmm.bak.
*/
