using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DoAnCNPM_SOS.Models;
using System.IO;
using System.Data.SqlClient;

namespace DoAnCNPM_SOS.Controllers
{
    public class AdminController : Controller
    {
        private SOSEntities1 db = new SOSEntities1();

        // GET: Admin/Dashboard
        // Trang hiển thị danh sách nhân viên và nút chức năng
        public ActionResult Dashboard()
        {
            if (Session["NVID"] == null)
            {
                return RedirectToAction("Login", "Auth");
            }
            // 1. Lấy danh sách nhân viên
            var listNV = db.NVs.OrderByDescending(x => x.LUONG).ToList();

            // 2. LẤY THỜI GIAN BACKUP GẦN NHẤT
            try
            {
                // Truy vấn vào bảng hệ thống msdb để tìm lịch sử backup của DB "SOS"
                string sqlQuery = @"
            SELECT TOP 1 backup_finish_date
            FROM msdb.dbo.backupset
            WHERE database_name = 'SOS' AND type = 'D' 
            ORDER BY backup_finish_date DESC";

                // type = 'D' nghĩa là Full Database Backup

                var lastBackupTime = db.Database.SqlQuery<DateTime?>(sqlQuery).FirstOrDefault();

                ViewBag.LastBackupTime = lastBackupTime;
            }
            catch
            {
                // Trường hợp không có quyền truy cập msdb hoặc chưa backup lần nào
                ViewBag.LastBackupTime = null;
            }
            // 3.Lấy danh sách file Backup trong ổ C
            var backupFolder = @"C:\Backup_SOS";
            if (!Directory.Exists(backupFolder))
            {
                Directory.CreateDirectory(backupFolder);
            }

            // Lấy tên file, sắp xếp mới nhất lên đầu
            var backupFiles = Directory.GetFiles(backupFolder, "*.bak")
                                 .Select(Path.GetFileName)
                                 .OrderByDescending(f => f)
                                 .ToList();

            ViewBag.BackupFiles = backupFiles; // Truyền sang View để hiển thị list

            return View(listNV);
        }

        // POST: Admin/CapNhatCapBac
        // Action này sẽ gọi Stored Procedure
        [HttpPost]
        public ActionResult CapNhatCapBac()
        {
            try
            {
                // Gọi Stored Procedure từ SQL
                // Hàm này được EF tự sinh ra ở Bước 1
                db.USP_CAPNHAT_CAPBAC_NV_TU_LUONG();

                // Lưu thông báo thành công để hiện bên View
                TempData["Message"] = "Đã chạy Cursor cập nhật cấp bậc thành công!";
                TempData["Type"] = "success"; // Màu xanh
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi: " + ex.Message;
                TempData["Type"] = "danger"; // Màu đỏ
            }

            // Load lại trang Dashboard để thấy sự thay đổi
            return RedirectToAction("Dashboard");
        }

        public ActionResult NhaCungCap()
        {
            // Lấy danh sách NCC
            return View(db.NCCs.ToList());
        }

        // POST: Admin/ThemNCC
        [HttpPost]
        public ActionResult ThemNCC(string tenNCC, string sdt, string diaChi)
        {
            try
            {
                // Tự động tăng ID (Lấy Max + 1)
                int newID = db.NCCs.Any() ? db.NCCs.Max(n => n.NCCID) + 1 : 1;

                var ncc = new NCC
                {
                    NCCID = newID,
                    TENNCC = tenNCC,
                    SDTNCC = sdt,
                    DIACHI = diaChi
                };

                db.NCCs.Add(ncc);
                db.SaveChanges(); // Lưu vào SQL

                TempData["Message"] = "Thêm Nhà cung cấp thành công!";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi: " + ex.Message;
                TempData["Type"] = "danger";
            }
            return RedirectToAction("NhaCungCap");
        }


        // --- CÁC CHỨC NĂNG NÂNG CAO (BACKUP & LOGIC) ---

        // 1. BACKUP DATABASE
        [HttpPost]
        public ActionResult BackupDatabase()
        {
            try
            {
                // Đường dẫn lưu file (LƯU Ý: Phải tạo thư mục C:\Backup_SOS trong máy tính trước)
                string fileName = $"SOS_Backup_{DateTime.Now:yyyyMMdd_HHmmss}.bak";
                string filePath = $@"C:\Backup_SOS\{fileName}";

                // Câu lệnh T-SQL Backup
                string sql = $"BACKUP DATABASE [SOS] TO DISK = '{filePath}' WITH INIT";

                // Thực thi lệnh (Quan trọng: Backup không được nằm trong Transaction nên phải dùng DoNotEnsureTransaction)
                db.Database.ExecuteSqlCommand(System.Data.Entity.TransactionalBehavior.DoNotEnsureTransaction, sql);

                TempData["Message"] = $"✅ Đã sao lưu dữ liệu thành công tại: {filePath}";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi Backup (Hãy chắc chắn bạn đã tạo thư mục C:\\Backup_SOS): " + ex.Message;
                TempData["Type"] = "danger";
            }
            return RedirectToAction("Dashboard");
        }

        // 2. TĂNG GIÁ HÀNG LOẠT (Gọi USP_TANG_GIA_DMSP)
        [HttpPost]
        public ActionResult TangGia(int? dmspId, double phanTram)
        {
            try
            {
                // Nếu dmspId null thì tăng tất cả
                db.Database.ExecuteSqlCommand("EXEC USP_TANG_GIA_DMSP @p0, @p1", dmspId, phanTram);

                TempData["Message"] = $"✅ Đã tăng giá {phanTram}% thành công!";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi: " + ex.Message;
                TempData["Type"] = "danger";
            }
            return RedirectToAction("Dashboard");
        }

        // 3. TÍNH DOANH THU NHÂN VIÊN (Gọi USP_TINH_DOANHTHU_NV)
        public ActionResult DoanhThuNhanVien()
        {
            // Procedure này trả về bảng kết quả, ta dùng SqlQuery để map vào class tạm
            var report = db.Database.SqlQuery<DoanhThuReport>("EXEC USP_TINH_DOANHTHU_NV").ToList();
            return View(report);
        }

        // Demo: USP_TINH_DOANHTHU_NV (Sử dụng Cursor)
        public ActionResult BaoCaoDoanhThu()
        {
            var data = db.Database.SqlQuery<DoanhThuViewModel>("EXEC USP_TINH_DOANHTHU_NV").ToList();
            return View(data);
        }

        public class DoanhThuViewModel
        {
            public int NVID { get; set; }
            public string TENNV { get; set; }
            public decimal DOANHTHU { get; set; }
        }

        public ActionResult ThemSanPham()
        {
            ViewBag.DMSPID = new SelectList(db.DMSPs, "DMSPID", "TENDM");
            ViewBag.NCCID = new SelectList(db.NCCs, "NCCID", "TENNCC");
            return View();
        }

        // POST: Admin/ThemSanPham
        [HttpPost]
        public ActionResult ThemSanPham(string tenSP, int dmspId, int nccId, decimal gia, int soLuong, HttpPostedFileBase hinhAnh)
        {
            try
            {
                string tenFileAnh = null;

                // Xử lý file ảnh upload
                if (hinhAnh != null && hinhAnh.ContentLength > 0)
                {
                    // Có chọn ảnh -> Lưu ảnh thật
                    string fileName = System.IO.Path.GetFileName(hinhAnh.FileName);
                    tenFileAnh = fileName;
                    string path = Server.MapPath("~/images/" + fileName);
                    hinhAnh.SaveAs(path);
                }
                else
                {
                    tenFileAnh = "default.png";
                }

                // Gọi Stored Procedure với tham số mới
                string sql = "EXEC USP_THEM_SP @p0, @p1, @p2, @p3, @p4, @p5";
                db.Database.ExecuteSqlCommand(sql, tenSP, dmspId, nccId, gia, soLuong, tenFileAnh);

                TempData["Message"] = "Thêm sản phẩm thành công!";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi: " + ex.Message;
                TempData["Type"] = "danger";
            }
            return RedirectToAction("Dashboard");
        }

        // GET: Admin/ThemDanhMuc
        public ActionResult ThemDanhMuc()
        {
            // Nếu muốn hiện danh sách danh mục cũ bên dưới form thì lấy list
            ViewBag.ListDMSP = db.DMSPs.OrderByDescending(d => d.DMSPID).ToList();
            return View();
        }

        // POST: Admin/ThemDanhMuc
        [HttpPost]
        public ActionResult ThemDanhMuc(string tenDM, string moTa)
        {
            try
            {
                // Gọi Stored Procedure thêm danh mục
                string sql = "EXEC USP_THEM_DMSP @p0, @p1";
                db.Database.ExecuteSqlCommand(sql, tenDM, moTa);

                TempData["Message"] = "Thêm danh mục thành công!";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                // Lấy lỗi từ SQL (ví dụ trùng tên)
                string errorMsg = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
                TempData["Message"] = "Lỗi: " + errorMsg;
                TempData["Type"] = "danger";
            }
            return RedirectToAction("ThemDanhMuc");
        }

        // Class tạm để hứng dữ liệu báo cáo
        public class DoanhThuReport
        {
            public string TENNV { get; set; }
            public decimal DOANHTHU { get; set; }
        }

        // GET: Admin/RestoreDatabase
        // Hiển thị danh sách các bản Backup có trong ổ cứng
        public ActionResult RestoreDatabase()
        {
            var backupFolder = @"C:\Backup_SOS";
            if (!Directory.Exists(backupFolder))
            {
                Directory.CreateDirectory(backupFolder);
            }

            // Lấy danh sách file .bak
            var files = Directory.GetFiles(backupFolder, "*.bak")
                                 .Select(Path.GetFileName)
                                 .OrderByDescending(f => f) // File mới nhất lên đầu
                                 .ToList();

            return View(files);
        }

        // POST: Admin/ProcessRestore
        // Thực hiện phục hồi dữ liệu
        [HttpPost]
        public ActionResult ProcessRestore(string fileName)
        {
            try
            {
                string filePath = $@"C:\Backup_SOS\{fileName}";

                // 1. Tạo chuỗi kết nối tới MASTER (Không kết nối vào SOS để tránh bị khóa)
                // Lưu ý: Lấy connection string hiện tại nhưng đổi Initial Catalog thành master
                string connectionString = db.Database.Connection.ConnectionString.Replace("Initial Catalog=SOS", "Initial Catalog=master");

                // 2. Câu lệnh SQL "Quyền lực"
                // - Chuyển DB về chế độ SINGLE_USER (Đá văng mọi kết nối khác ra, kể cả Web)
                // - Restore dữ liệu
                // - Chuyển lại về MULTI_USER (Cho phép kết nối lại)
                string sql = $@"
            USE master;
            ALTER DATABASE [SOS] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
            RESTORE DATABASE [SOS] FROM DISK = '{filePath}' WITH REPLACE;
            ALTER DATABASE [SOS] SET MULTI_USER;
        ";

                // 3. Thực thi bằng SqlConnection riêng
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }

                TempData["Message"] = "✅ Khôi phục dữ liệu thành công! Hệ thống đã quay về trạng thái cũ.";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi Restore: " + ex.Message;
                TempData["Type"] = "danger";
            }

            return RedirectToAction("Dashboard");
        }
    }
}