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

        public ActionResult Dashboard()
        {
            if (Session["NVID"] == null)
            {
                return RedirectToAction("Login", "Auth");
            }
            // 1. Lấy danh sách nhân viên
            var listNV = db.NVs.OrderByDescending(x => x.LUONG).ToList();

            try
            {
                // Truy vấn vào bảng hệ thống msdb để tìm lịch sử backup của DB "SOS"
                string sqlQuery = @"
            SELECT TOP 1 backup_finish_date
            FROM msdb.dbo.backupset
            WHERE database_name = 'SOS' AND type = 'D' 
            ORDER BY backup_finish_date DESC";

                var lastBackupTime = db.Database.SqlQuery<DateTime?>(sqlQuery).FirstOrDefault();

                ViewBag.LastBackupTime = lastBackupTime;
            }
            catch
            {
                ViewBag.LastBackupTime = null;
            }
            var backupFolder = @"C:\Backup_SOS";
            if (!Directory.Exists(backupFolder))
            {
                Directory.CreateDirectory(backupFolder);
            }

            var backupFiles = Directory.GetFiles(backupFolder, "*.bak")
                                 .Select(Path.GetFileName)
                                 .OrderByDescending(f => f)
                                 .ToList();

            ViewBag.BackupFiles = backupFiles;

            return View(listNV);
        }

        // POST: Admin/CapNhatCapBac
        [HttpPost]
        public ActionResult CapNhatCapBac()
        {
            try
            {
                db.USP_CAPNHAT_CAPBAC_NV_TU_LUONG();
                TempData["Message"] = "Đã chạy Cursor cập nhật cấp bậc thành công!";
                TempData["Type"] = "success"; 
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi: " + ex.Message;
                TempData["Type"] = "danger"; 
            }
            return RedirectToAction("Dashboard");
        }

        public ActionResult NhaCungCap()
        {
            return View(db.NCCs.ToList());
        }

        // POST: Admin/ThemNCC
        [HttpPost]
        public ActionResult ThemNCC(string tenNCC, string sdt, string diaChi)
        {
            try
            {
                int newID = db.NCCs.Any() ? db.NCCs.Max(n => n.NCCID) + 1 : 1;

                var ncc = new NCC
                {
                    NCCID = newID,
                    TENNCC = tenNCC,
                    SDTNCC = sdt,
                    DIACHI = diaChi
                };

                db.NCCs.Add(ncc);
                db.SaveChanges();

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

        // 1. BACKUP DATABASE
        [HttpPost]
        public ActionResult BackupDatabase()
        {
            try
            {
                string fileName = $"SOS_Backup_{DateTime.Now:yyyyMMdd_HHmmss}.bak";
                string filePath = $@"C:\Backup_SOS\{fileName}";

                string sql = $"BACKUP DATABASE [SOS] TO DISK = '{filePath}' WITH INIT";
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

        // 2.TĂNG GIÁ HÀNG LOẠT (Gọi USP_TANG_GIA_DMSP)
        [HttpPost]
        public ActionResult TangGia(int? dmspId, double phanTram)
        {
            try
            {
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

        // 3.TÍNH DOANH THU NHÂN VIÊN (Gọi USP_TINH_DOANHTHU_NV)
        public ActionResult DoanhThuNhanVien()
        {
            var report = db.Database.SqlQuery<DoanhThuReport>("EXEC USP_TINH_DOANHTHU_NV").ToList();
            return View(report);
        }

        //USP_TINH_DOANHTHU_NV (Sử dụng Cursor)
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

                if (hinhAnh != null && hinhAnh.ContentLength > 0)
                {
                    string fileName = System.IO.Path.GetFileName(hinhAnh.FileName);
                    tenFileAnh = fileName;
                    string path = Server.MapPath("~/images/" + fileName);
                    hinhAnh.SaveAs(path);
                }
                else
                {
                    tenFileAnh = "default.png";
                }

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
            ViewBag.ListDMSP = db.DMSPs.OrderByDescending(d => d.DMSPID).ToList();
            return View();
        }

        // POST: Admin/ThemDanhMuc
        [HttpPost]
        public ActionResult ThemDanhMuc(string tenDM, string moTa)
        {
            try
            {
                string sql = "EXEC USP_THEM_DMSP @p0, @p1";
                db.Database.ExecuteSqlCommand(sql, tenDM, moTa);

                TempData["Message"] = "Thêm danh mục thành công!";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
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
                                 .OrderByDescending(f => f)
                                 .ToList();

            return View(files);
        }

        // POST: Admin/ProcessRestore
        [HttpPost]
        public ActionResult ProcessRestore(string fileName)
        {
            try
            {
                string filePath = $@"C:\Backup_SOS\{fileName}";
                string connectionString = db.Database.Connection.ConnectionString.Replace("Initial Catalog=SOS", "Initial Catalog=master");
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