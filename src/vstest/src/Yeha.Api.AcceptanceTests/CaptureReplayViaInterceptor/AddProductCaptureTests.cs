using FluentAssertions;
using GreyhamWooHoo.Interceptor.Core.Builders;
using GreyhamWooHoo.Interceptor.Core.Contracts;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using Yeha.Api.Contracts;
using Yeha.Api.Services;
using Yeha.Api.TestSdk.RequestBuilders;
using Yeha.Api.TestSdk.ResponseModels;

namespace Yeha.Api.AcceptanceTests.CaptureReplayViaInterceptor
{
    /// <summary>
    /// Demonstrates how to "intercept" interface method calls and capture the return value as a test attachment. 
    /// 
    /// Capture: This is the 'capture' side; the AddProductReplayTests will show how to use the Snapshots by intercepting method calls and injecting the snapshots as responses. 
    /// After running these tests:
    /// 1. Save the Snapshot from each test as Zero.json, One.json and Many.json in the Snapshots folder (this has been done for you... override them if the contracts change)
    /// 2. Rebuild, then run the Replay tests: the Snapshots will be injected as responses.
    /// </summary>
    [TestClass]
    public class AddProductCaptureTests : ProductTestBase
    {
        // We want to override the DI Container - so we need to host this inprocess
        protected override bool IsInProcessOnly => true;

        protected Dictionary<string, string> Snapshots = new Dictionary<string, string>();

        protected void ToSnapshot<T>(IAfterExecutionResult result) where T : class
        {
            var returnValue = result.ReturnValue as T;
            var asJson = JsonConvert.SerializeObject(returnValue, Formatting.Indented);
            Snapshots.Add($"{result.Rule.MethodName}", asJson);
        }

        /// <summary>
        /// Overridden so that we can inject our own interfaces.
        /// 
        /// </summary>
        /// <param name="services"></param>
        protected override void ConfigureServices(IServiceCollection services)
        {
            // The original interface is: IProductRepository
            // The original implementation is: ProductRepository

            // We will provide our own interface and the original implementation; we will callback "just before" the IProductRepository GetAll() method returns - thereby giving us the return value. 
            var originalImplementation = new ProductRepository();

            var interceptedProductRepository = new InterceptorProxyBuilder<IProductRepository>()
                .For(originalImplementation)
                .InterceptAfterExecutionOf(theMethodCalled: nameof(IProductRepository.GetAll), andCallbackWith: result => ToSnapshot<IEnumerable<IProduct>>(result))
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
            Snapshots.ToList().ForEach(pair =>
            {
                string path = System.IO.Path.Combine(System.IO.Path.GetTempPath(), $"{DateTime.Now.ToString("HHmmssfff")}-{pair.Key}.json");
                System.IO.File.WriteAllText(path, pair.Value);
                TestContext.AddResultFile(path);

                // Wait a millisecond so we dont step on the prior test file...! Or pick a better naming strategy. 
                System.Threading.Thread.Sleep(1);
            });
        }

        [TestMethod]
        [TestCategory("Zero")]
        [TestCategory("RequiresInProcess")]
        public void WhenThereAreNoProducts()
        {
            // Arrange
            var request = Resolve<GetAllProductsRequestBuilder>()
                .Build();

            // Act
            var products = Client.Execute(request, andExpect: System.Net.HttpStatusCode.OK)
                .As<ProductCollection>();

            products.Count().Should().Be(0, because: "there are no products at the moment. ");
        }

        [TestMethod]
        [TestCategory("One")]
        [TestCategory("RequiresInProcess")]
        public void WhenThereIsOneProduct()
        {
            AddItem("TheItemId1", "TheItemDescription1");

            // Arrange
            var request = Resolve<GetAllProductsRequestBuilder>()
                .Build();

            // Act
            var products = Client.Execute(request, andExpect: System.Net.HttpStatusCode.OK)
                .As<ProductCollection>();

            products.Count().Should().Be(1, because: "there should be exactly one product. ");
        }

        [TestMethod]
        [TestCategory("Many")]
        [TestCategory("RequiresInProcess")]
        public void WhenThereAreManyProducts()
        {
            AddItem("TheItemId1", "TheItemDescription1");
            AddItem("TheItemId2", "TheItemDescription2");

            // Arrange
            var request = Resolve<GetAllProductsRequestBuilder>()
                .Build();

            // Act
            var products = Client.Execute(request, andExpect: System.Net.HttpStatusCode.OK)
                .As<ProductCollection>();

            products.Count().Should().Be(2, because: "there should be two products. ");
        }
    }
}
