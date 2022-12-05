using FluentAssertions;
using GreyhamWooHoo.Interceptor.Core.Builders;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System.Linq;
using Yeha.Api.Contracts;
using Yeha.Api.Services;
using Yeha.Api.TestSdk.RequestBuilders;
using Yeha.Api.TestSdk.ResponseModels;

namespace Yeha.Api.AcceptanceTests.CaptureReplayViaInterceptor
{
    /// <summary>
    /// Demonstrates how to stub method calls using the interceptor. Instead of constructing the object, you could read and deserialize the Snapshots contents by using:
    /// 
    /// var snapshotPath = System.IO.Path.Combine(TestContext.DeploymentDirectory, "Snapshots", "thenthesnapshotname.json")
    /// var content = System.IO.File.ReadAllText(snapshotPath)
    /// var stubValue = JsonConvert.Deserialize<....>(content)
    /// 
    /// This includes only a single example. 
    /// </summary>
    [TestClass]
    public class AddProductReplayTests : ProductTestBase
    {
        // We want to override the DI Container - so we need to host this inprocess
        protected override bool IsInProcessOnly => true;

        /// <summary>
        /// Overridden so that we can inject our own interfaces.
        /// 
        /// </summary>
        /// <param name="services"></param>
        protected override void ConfigureServices(IServiceCollection services)
        {
            // The original interface is: IProductRepository
            // The original implementation is: ProductRepository
            var originalImplementation = new ProductRepository();
            
            var interceptedProductRepository = new InterceptorProxyBuilder<IProductRepository>()
                .For(originalImplementation)
                .InterceptAndStub(theMethodCalled: nameof(IProductRepository.GetAll), withValue: new List<Models.Product>()
                {
                    new Models.Product() { Id = "TheStubbedItemId1", Description = "TheStubbedItemDescription1" },
                    new Models.Product() { Id = "TheStubbedItemId2", Description = "TheStubbedItemDescription2" }
                })
                .Build();

            var existingDescriptors = services.Where(s => s.ServiceType == typeof(IProductRepository));
            existingDescriptors.ToList().ForEach(descriptor =>
            {
                services.Remove(descriptor);
            });

            services.AddSingleton(interceptedProductRepository);
        }

        [TestCleanup]
        public void Cleanup()
        {
        }

        [TestMethod]
        [TestCategory("Many")]
        [TestCategory("RequiresInProcess")]
        public void WhenThereAreManyProducts()
        {
            // Add the item using the original interface implementation... but the service (above) has stubbed the call to GetAll which means we will get the results that we assert below. 
            AddItem("TheItemId1", "TheItemDescription1WillNeverBeReturnedBecauseGetAllIsstubbed");

            // Arrange
            var request = Resolve<GetAllProductsRequestBuilder>()
                .Build();

            // Act
            var products = Client.Execute(request, andExpect: System.Net.HttpStatusCode.OK)
                .As<ProductCollection>();

            // Assert
            products.Count().Should().Be(2, because: "there should be two products. ");

            AssertProductItem(products.First(), "TheStubbedItemId1", "TheStubbedItemDescription1");
            AssertProductItem(products.Last(), "TheStubbedItemId2", "TheStubbedItemDescription2");
        }
    }
}
