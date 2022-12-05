using Microsoft.VisualStudio.TestTools.UnitTesting;
using Yeha.Api.TestSdk.RequestBuilders;
using Yeha.Api.TestSdk.ResponseModels;

namespace Yeha.Api.AcceptanceTests
{
    [TestClass]
    public abstract class ProductTestBase : AcceptanceTestBase
    {

        protected void AddItem(string id, string description)
        {
            // Arrange
            var request = Resolve<AddProductRequestBuilder>()
                .WithId(id)
                .WithDescription(description)
                .Build();

            // Act
            Client.Execute(request, andExpect: System.Net.HttpStatusCode.OK);
        }

        protected void AssertProductItem(Product product, string id, string description)
        {
            Assert.AreEqual(description, product.Description);
            Assert.AreEqual(id, product.Id);
        }

        protected ProductCollection GetProducts()
        {
            // Arrange
            var request = Resolve<GetAllProductsRequestBuilder>()
                .Build();

            // Act
            var response = Client.Execute(request, andExpect: System.Net.HttpStatusCode.OK)
                .As<ProductCollection>();

            return response;
        }
    }
}
