using System.Collections.Generic;
using Yeha.Api.Contracts;
using Yeha.Api.Models;

namespace Yeha.Api.AcceptanceTests.Mocks
{
    /// <summary>
    /// Overrides the IProductRepository in the API and returns canned data. Shows how to override the DI when starting up a service. 
    /// See GetProductViaMockTests for more information. 
    /// </summary>
    public class ProductRepositoryMock : IProductRepository
    {
        public void Add(IProduct product)
        {
        }

        public IEnumerable<Product> GetAll()
        {
            return new Product[]
            {
                new Product() { Description = "This Is The Mocked Description", Id = "MockedId" }
            };
        }

        public void RemoveAll()
        {
        }
    }
}
