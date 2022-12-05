using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Linq;
using Yeha.Api.TestSdk.RequestBuilders;

namespace Yeha.Api.AcceptanceTests
{
    [TestClass]
    public class AddProductTests : ProductTestBase
    {
        [TestInitialize] 
        public void RemoveExistingProducts()
        {
            var request = Resolve<RemoveAllProductsBuilder>()
                .Build();

            Client.Execute(request, andExpect: System.Net.HttpStatusCode.OK);
        }

        [TestMethod]
        [TestCategory("Zero")]
        public void WhenZeroProduct_GetAllReturnsEmptyArray()
        {
            // Arrange, Act
            var response = GetProducts();

            // Assert
            Assert.AreEqual(0, response.Count);
        }

        [TestMethod]
        [TestCategory("One")]
        public void WhenZeroProduct_CanAddAProduct()
        {
            AddItem("the Id", "the Product");

            // Assert
            var products = GetProducts();
            Assert.AreEqual(1, products.Count());

            AssertProductItem(products.First(), "the Id", "the Product");
        }

        [TestMethod]
        [TestCategory("Many")]
        public void WhenOneProduct_CanAddAProduct()
        {
            // Arrange
            AddItem("the Id1", "the Product1");
            AddItem("the Id2", "the Product2");

            // Assert
            var products = GetProducts();
            Assert.AreEqual(2, products.Count());

            AssertProductItem(products.First(), "the Id1", "the Product1");
            AssertProductItem(products.Last(), "the Id2", "the Product2");
        }
    }
}
