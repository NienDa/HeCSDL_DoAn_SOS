using DoAnCNPM_SOS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using System.Web;
using System.Web.Mvc;

namespace DoAnCNPM_SOS.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index(string searchString, int? categoryId)
        {
            var db = new SOSEntities1();
            List<SP> sanPhams;

            if (!string.IsNullOrEmpty(searchString))
            {
                sanPhams = db.Database.SqlQuery<SP>("EXEC USP_TIM_SP @p0", searchString).ToList();
            }
            else if (categoryId.HasValue)
            {
                sanPhams = db.SPs.Where(x => x.DMSPID == categoryId).ToList();
            }
            else
            {
                sanPhams = db.SPs.ToList();
            }
            ViewBag.Categories = db.DMSPs.ToList();

            return View(sanPhams);
        }
    }
}