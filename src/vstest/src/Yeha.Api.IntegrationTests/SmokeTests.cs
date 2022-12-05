using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Threading.Tasks;

namespace Yeha.Api.IntegrationTests
{
    [TestClass]
    public class SmokeTests : IntegrationTestBase
    {
        [TestMethod]
        [TestCategory("Smoke")]
        public async Task WhenIGetPrimitivies_PrimitiviesAreReturned()
        {
            // Act
            var response = await TestClient.GetAsync("/api/primitives");
            response.EnsureSuccessStatusCode();
        }
    }
}
