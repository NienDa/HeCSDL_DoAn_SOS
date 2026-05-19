using DoAnCNPM_SOS.Models;
using System;
using System.Linq;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Web.Mvc;

namespace DoAnCNPM_SOS.Controllers
{
    public class DeliveryController : Controller
    {
        private SOSEntities1 db = new SOSEntities1();

        // 1. DÀNH CHO QUẢN LÝ: ĐIỀU PHỐI ĐƠN HÀNG
        public ActionResult Index()
        {
            // Kiểm tra quyền: Chỉ QUẢN LÝ mới được vào trang điều phối
            if (Session["Role"] == null || Session["Role"].ToString() != "QUẢN LÝ")
            {
                // Nếu là Shipper (Nhân viên), chuyển thẳng sang trang nhiệm vụ của họ
                return RedirectToAction("MyTasks");
            }

            // Lấy các Hóa đơn chưa có trong bảng GH (Chưa ai giao)
            var listHD = db.HDs.Where(h => !db.GHs.Any(g => g.HDID == h.HDID))
                               .OrderByDescending(h => h.NGAYLAP)
                               .ToList();

            // Lấy danh sách nhân viên (trừ Quản lý ra) để gán việc
            ViewBag.Shippers = new SelectList(db.NVs.Where(n => n.CAPBAC != "QUẢN LÝ"), "NVID", "TENNV");

            return View(listHD);
        }

        // Action Phân công (Insert vào bảng GH) - Giữ nguyên như cũ
        [HttpPost]
        public ActionResult ShipOrder(int hdId, int shipperId, DateTime ngayGiao)
        {
            try
            {
                int newID = db.GHs.Any() ? db.GHs.Max(g => g.GHID) + 1 : 1;
                var gh = new GH
                {
                    GHID = newID,
                    HDID = hdId,
                    NVID = shipperId,
                    NGAYGIAO = ngayGiao,
                    TRANGTHAI = "ĐANG GIAO"
                };
                db.GHs.Add(gh);
                db.SaveChanges();

                TempData["Message"] = $"Đã phân công đơn #{hdId} cho nhân viên #{shipperId}";
                TempData["Type"] = "success";
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi: " + ex.Message;
                TempData["Type"] = "danger";
            }
            return RedirectToAction("Index");
        }

        // 2. DÀNH CHO SHIPPER: NHIỆM VỤ CỦA TÔI
        public ActionResult MyTasks()
        {
            if (Session["NVID"] == null) return RedirectToAction("Login", "Auth");

            int currentNvId = (int)Session["NVID"];

            // Lấy danh sách đơn hàng ĐANG GIAO được phân công cho nhân viên này
            var myTasks = db.GHs.Where(g => g.NVID == currentNvId && g.TRANGTHAI == "ĐANG GIAO")
                                .OrderBy(g => g.NGAYGIAO).ToList();

            return View(myTasks);
        }

        // 3. CẬP NHẬT TRẠNG THÁI (ĐÃ GIAO / HỦY)
        [HttpPost]
        public ActionResult UpdateStatus(int ghId, string status)
        {
            try
            {
                var gh = db.GHs.Find(ghId);
                if (gh != null)
                {
                    // Cập nhật bảng GH
                    gh.TRANGTHAI = status; // "ĐÃ GIAO" hoặc "ĐÃ HỦY"

                    // Cập nhật luôn bảng HD cho đồng bộ
                    var hd = db.HDs.Find(gh.HDID);
                    if (status == "ĐÃ GIAO") hd.TRANGTHAI = "HOÀN THÀNH";
                    else if (status == "ĐÃ HỦY") hd.TRANGTHAI = "ĐÃ HỦY";

                    db.SaveChanges();
                    TempData["Message"] = "Cập nhật trạng thái thành công!";
                    TempData["Type"] = "success";
                }
            }
            catch (Exception ex)
            {
                TempData["Message"] = "Lỗi: " + ex.Message;
                TempData["Type"] = "danger";
            }
            return RedirectToAction("MyTasks");
        }

        // Lịch sử chung (Ai cũng xem được)
        public ActionResult History()
        {
            var listGH = db.GHs.OrderByDescending(g => g.NGAYGIAO).ToList();
            return View(listGH);
        }
    }
}