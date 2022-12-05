using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Hosting;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Net.Http;
using System.Threading.Tasks;
using Yeha.Api;

namespace Yeha.Api.IntegrationTests
{
    /// <summary>
    /// Integration Tests
    /// References: https://adamstorr.azurewebsites.net/blog/integration-testing-with-aspnetcore-3-1-testing-your-app
    /// </summary>
    [TestClass]
    public class IntegrationTestBase
    {
        protected IHost Host;
        protected HttpClient TestClient => Host?.GetTestClient() ?? throw new System.InvalidOperationException($"The Host must be initialized before requesting its TestClient");

        [TestInitialize]
        public async Task Setup()
        {
            var hostBuilder = Program
                .CreateHostBuilder()
                .ConfigureWebHost(webHost =>
                {
                    webHost.UseTestServer();
                    webHost.UseStartup<Startup>();
                });

            Host = await hostBuilder.StartAsync();
        }

        [TestCleanup]
        public async Task Teardown()
        {
            if (Host != null)
            {
                await Host.StopAsync();
                Host.Dispose();
                Host = null;
            }
        }
    }
}
