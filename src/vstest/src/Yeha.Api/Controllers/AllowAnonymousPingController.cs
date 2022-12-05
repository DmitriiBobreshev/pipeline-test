using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Yeha.Api.Models;

namespace Yeha.Api.Controllers
{
    [ApiController]
    [Route("api/allowAnonymousPing")]
    [AllowAnonymous]
    public class AllowAnonymousPingController : ControllerBase
    {
        public AllowAnonymousPingController()
        {
        }

        [HttpGet]
        public ActionResult<IEnumerable<Product>> Get()
        {
            return Ok("pong");
        }
    }
}
