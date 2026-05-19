using System;
using System.Linq;
using System.Web.Mvc;
using DoAnCNPM_SOS.Models; // Nhớ sửa Namespace

namespace DoAnCNPM_SOS.Controllers
{
    public class ProductController : Controller
    {
        private SOSEntities1 db = new SOSEntities1();

        // GET: Product/Details/5
        public ActionResult Details(int id)
        {
            // Tìm sản phẩm theo ID
            var sp = db.SPs.Find(id);
            if (sp == null) return HttpNotFound();

            // Lấy danh sách khách hàng để giả lập người đánh giá
            ViewBag.KHID = new SelectList(db.KHs, "KHID", "TENKH");

            // Lấy danh sách đánh giá cũ của sản phẩm này để hiện ra
            ViewBag.DanhSachDanhGia = db.DGs.Where(x => x.SPID == id).OrderByDescending(x => x.NGAYDG).ToList();

            return View(sp);
        }

        // POST: Product/SubmitReview
        [HttpPost]
        public ActionResult SubmitReview(int spId, int khId, int sao, string binhLuan)
        {
            try
            {
                // Gọi câu lệnh SQL Insert trực tiếp
                // Điều này sẽ kích hoạt Trigger TRG_DG_KIEMTRA_TRUNG trong SQL Server
                string sql = @"INSERT INTO DG (DGID, KHID, SPID, SAO, BINHLUAN, NGAYDG) 
               VALUES ((SELECT ISNULL(MAX(DGID), 0) + 1 FROM DG), @p0, @p1, @p2, @p3, GETDATE())";

                db.Database.ExecuteSqlCommand(sql, khId, spId, sao, binhLuan);

                TempData["Message"] = "Gửi đánh giá thành công!";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                // QUAN TRỌNG: Bắt lỗi từ Trigger SQL ném ra
                // Lỗi: "Khách hàng chỉ được đánh giá 1 lần cho mỗi sản phẩm."
                string sqlError = ex.InnerException != null ? ex.InnerException.Message : ex.Message;

                TempData["Message"] = "Lỗi từ Trigger SQL: " + sqlError;
                TempData["Type"] = "danger";
            }

            return RedirectToAction("Details", new { id = spId });
        }
    }
}