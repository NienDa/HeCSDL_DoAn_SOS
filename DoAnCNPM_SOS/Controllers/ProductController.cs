using System;
using System.Linq;
using System.Web.Mvc;
using DoAnCNPM_SOS.Models;

namespace DoAnCNPM_SOS.Controllers
{
    public class ProductController : Controller
    {
        private SOSEntities1 db = new SOSEntities1();

        // GET: Product/Details/5
        public ActionResult Details(int id)
        {

            var sp = db.SPs.Find(id);
            if (sp == null) return HttpNotFound();

            ViewBag.KHID = new SelectList(db.KHs, "KHID", "TENKH");
            ViewBag.DanhSachDanhGia = db.DGs.Where(x => x.SPID == id).OrderByDescending(x => x.NGAYDG).ToList();

            return View(sp);
        }

        // POST: Product/SubmitReview
        [HttpPost]
        public ActionResult SubmitReview(int spId, int khId, int sao, string binhLuan)
        {
            try
            {
                string sql = @"INSERT INTO DG (DGID, KHID, SPID, SAO, BINHLUAN, NGAYDG) 
               VALUES ((SELECT ISNULL(MAX(DGID), 0) + 1 FROM DG), @p0, @p1, @p2, @p3, GETDATE())";

                db.Database.ExecuteSqlCommand(sql, khId, spId, sao, binhLuan);

                TempData["Message"] = "Gửi đánh giá thành công!";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                string sqlError = ex.InnerException != null ? ex.InnerException.Message : ex.Message;

                TempData["Message"] = "Lỗi từ Trigger SQL: " + sqlError;
                TempData["Type"] = "danger";
            }

            return RedirectToAction("Details", new { id = spId });
        }
    }
}