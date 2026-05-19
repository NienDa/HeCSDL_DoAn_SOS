using DoAnCNPM_SOS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Web;
using System.Web.Mvc;

namespace DoAnCNPM_SOS.Controllers
{
    public class AuthController : Controller
    {
        private SOSEntities1 db = new SOSEntities1();

        // GET: Auth/Login
        public ActionResult Login()
        {
            return View();
        }

        // POST: Auth/Login
        [HttpPost]
        public ActionResult Login(string sdt, string password)
        {
            var nv = db.NVs.FirstOrDefault(x => x.SDT == sdt);

            if (nv != null && password == "123")
            {
                // Lưu thông tin vào Session
                Session["User"] = nv;
                Session["TenNV"] = nv.TENNV;
                Session["NVID"] = nv.NVID;
                Session["Role"] = nv.CAPBAC;

                return RedirectToAction("Index", "Home");
            }
            else
            {
                ViewBag.Error = "Sai số điện thoại hoặc mật khẩu!";
                return View();
            }
        }

        public ActionResult Logout()
        {
            Session.Clear();
            return RedirectToAction("Index", "Home");
        }
    }
}