using DoAnCNPM_SOS.Models; // Nhớ sửa Namespace
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Web;
using System.Web.Mvc;

namespace DoAnCNPM_SOS.Controllers
{
    public class OrderController : Controller
    {
        private SOSEntities1 db = new SOSEntities1();

        // Trang hiển thị Form mua hàng
        public ActionResult Create()
        {
            ViewBag.KHID = new SelectList(db.KHs, "KHID", "TENKH");

            var listSP = db.SPs.Select(s => new {
                s.SPID,
                TenHienThi = s.TENSP + " - " + s.GIA + " VNĐ" // Hiển thị đơn giản hơn
            }).ToList();
            ViewBag.SPID = new SelectList(listSP, "SPID", "TenHienThi");

            return View();
        }

        // POST: Order/SubmitOrder
        [HttpPost]
        public ActionResult SubmitOrder(string tenKH, string sdt, string diaChi, int spId, int soLuong)
        {
            using (var db = new SOSEntities1())
            {

                try
                {
                    var khachHang = db.KHs.FirstOrDefault(k => k.SDT == sdt);
                    int khachHangID;

                    if (khachHang != null)
                    {
                        khachHangID = khachHang.KHID;
                    }
                    else
                    {
                        int newKhId = db.KHs.Any() ? db.KHs.Max(k => k.KHID) + 1 : 1;
                        var newKH = new KH { KHID = newKhId, TENKH = tenKH, SDT = sdt, DIACHI = diaChi, NGAYTG = DateTime.Now };
                        db.KHs.Add(newKH);
                        db.SaveChanges();
                        khachHangID = newKhId;
                    }

                    int autoNVID = 999;
                    var sp = db.SPs.Find(spId);
                    string cthdString = $"{spId},{soLuong},{Convert.ToInt32(sp.GIA)}";

                    db.USP_TAO_HOADON(khachHangID, autoNVID, "TIỀN MẶT", cthdString);

                    TempData["Message"] = $"Đặt hàng thành công! Cảm ơn {tenKH}.";
                    TempData["Type"] = "success";
                }
                catch (Exception ex)
                {

                    string errorMsg = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
                    TempData["Message"] = "Lỗi: " + errorMsg;
                    TempData["Type"] = "danger";
                }
            }
            return RedirectToAction("Create");
        }
    }
}