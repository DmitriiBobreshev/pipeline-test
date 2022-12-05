using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using Yeha.Api.Models;

namespace Yeha.Api.Controllers
{
    [ApiController]
    [Route("api/primitives")]
    [AllowAnonymous]
    public class PrimitivesController : ControllerBase
    {
        private readonly ILogger<PrimitivesController> _logger;

        public PrimitivesController(ILogger<PrimitivesController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public ActionResult<Primitives> Get()
        {
            return new Primitives()
            {
                ThisIsAString = "thisIsAString",
                ThisIsAStringWithNullValue = null,
                ThisIsAByte = byte.MaxValue,
                ThisIsAShort = short.MaxValue,
                ThisIsAnInt = int.MaxValue,
                ThisIsALong = long.MaxValue,
                ThisIsAFloat = float.MaxValue,
                ThisIsADouble = double.MaxValue,
                ThisIsAFalseBoolean = false,
                ThisIsATrueBoolean = true,
                ThisIsAGuid = Guid.NewGuid(),
                ThisIsATimeSpan = TimeSpan.FromSeconds(1234),
                ThisIsADateTime = DateTime.Now,
                ThisIsAUri = new Uri("https://www.google.com.au"),
                ThisIsAnEmptyIntArray = new int[0],
                ThisIsAnIntArrayWithOneElement = new int[1] { 123 },
                ThisIsANestedObject = new NestedPrimitives() { NestedString = "thisIsANestedString" },
                TheseAreBytes = new byte[] { 1, 2, 3 }
            };
        }
    }
}
