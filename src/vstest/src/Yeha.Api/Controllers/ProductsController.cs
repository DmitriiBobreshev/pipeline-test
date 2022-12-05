using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using Yeha.Api.Contracts;
using Yeha.Api.Models;

namespace Yeha.Api.Controllers
{
    [ApiController]
    [Route("api/products")]
    [AllowAnonymous]
    public class ProductsController : ControllerBase
    {
        private readonly ILogger<ProductsController> _logger;
        private readonly IProductRepository _productRepository;

        public ProductsController(ILogger<ProductsController> logger, IProductRepository productRepository)
        {
            _logger = logger;
            _productRepository = productRepository;
        }

        [HttpGet]
        public ActionResult<IEnumerable<Product>> Get()
        {
            var result = _productRepository.GetAll();
            return Ok(result);
        }

        [HttpPost]
        public ActionResult Add([FromBody] Product product)
        {
            _productRepository.Add(product);

            return Ok();
        }

        [HttpDelete]
        public ActionResult RemoveAll()
        {
            _productRepository.RemoveAll();
            return Ok();
        }
    }
}
