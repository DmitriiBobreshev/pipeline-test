using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Yeha.Api.Models;

namespace Yeha.Api.Controllers
{
    [ApiController]
    [Route("api/pingAuthorizedByMiddleware")]
    public class PingAuthorizedByMiddlewareController : ControllerBase
    {
        public PingAuthorizedByMiddlewareController()
        {
        }

        [HttpGet]
        public ActionResult<IEnumerable<Product>> Get()
        {
            return Ok("pong");
        }
    }
}
