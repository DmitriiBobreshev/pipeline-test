using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Yeha.Api.Models;

namespace Yeha.Api.Controllers
{
    [ApiController]
    [Route("api/pingAuthorizedWithAnonymousMethods")]
    [Authorize]
    public class PingWithAllowAnonymousMethodsController : ControllerBase
    {
        public PingWithAllowAnonymousMethodsController()
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public ActionResult<IEnumerable<Product>> Get()
        {
            return Ok("pongFromPingAuthorizedWithAnonymousMethods");
        }

        [HttpDelete]
        [AllowAnonymous]
        public ActionResult<IEnumerable<Product>> Delete()
        {
            return Ok("pong");
        }

        [HttpOptions]
        public ActionResult<IEnumerable<Product>> Options()
        {
            return Ok("pong");
        }
    }
}
