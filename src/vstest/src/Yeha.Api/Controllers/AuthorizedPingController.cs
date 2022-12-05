using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Yeha.Api.Models;

namespace Yeha.Api.Controllers
{
    [ApiController]
    [Route("api/pingAuthorized")]
    [Authorize]
    public class PingController : ControllerBase
    {
        public PingController()
        {
        }

        [HttpGet]
        public ActionResult<IEnumerable<Product>> Get()
        {
            return Ok("pong");
        }
    }
}
