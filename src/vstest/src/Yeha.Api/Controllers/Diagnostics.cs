using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Yeha.Api.Models;

namespace Yeha.Api.Controllers
{
    [ApiController]
    [Route("api/diagnostics")]
    [AllowAnonymous]
    public class DiagnosticsController : ControllerBase
    {
        public DiagnosticsController()
        {
        }

        [HttpGet]
        [Route("ready")]
        public ActionResult<IEnumerable<Product>> Get()
        {
            return Ok("Ready");
        }
    }
}
