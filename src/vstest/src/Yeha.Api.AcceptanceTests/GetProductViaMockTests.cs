using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Linq;
using Yeha.Api.AcceptanceTests.Mocks;
using Yeha.Api.Contracts;

namespace Yeha.Api.AcceptanceTests
{
    /// <summary>
    /// Demonstrates how to overload the API DI Container with a mock: handy for mocking out databases, repositories, external services/clients and so forth. 
    /// </summary>
    [TestClass]
    public class GetProductViaMockTests : ProductTestBase
    {
        /// <summary>
        /// Overridden to inject the mock. 
        /// </summary>
        /// <param name="services"></param>
        protected override void ConfigureServices(IServiceCollection services)
        {
            // NOTE: We could look at attributes on the test class here (via the Test Context) and set up the mocks and so forth automatically.
            //       Lots of possibilities.
            services.AddSingleton<IProductRepository, ProductRepositoryMock>();
        }

        // We are using MOCKS - so we can only run these tests if we are self hosting the service. 
        protected override bool IsInProcessOnly => true;

        [TestMethod]
        [TestCategory("One")]
        [TestCategory("RequiresInProcess")]
        public void WhenUsingMock_AlwaysReturnsMockedData()
        {
            // Assert
            var products = GetProducts();
            Assert.AreEqual(1, products.Count);

            AssertProductItem(products.First(), "MockedId", "This Is The Mocked Description");
        }
    }
}
