using FluentAssertions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Linq;
using System.Reflection;
using Yeha.Api.Controllers;
using Yeha.Api.TestSdk.RequestBuilders;

namespace Yeha.Api.AcceptanceTests
{
    /// <summary>
    /// Checks Security: this test ensures that a Method that has no AllowAnonymous and no Authorize method in a controller with no AllowAnonymous and no Authorize method will throw Unauthorized.
    ///    This ensures the middleware filter is present in the default case. 
    /// </summary>
    [TestClass]
    public class MiddlewareSecurityTests : AcceptanceTestBase
    {
        [TestInitialize]
        public void SetupSecurityTests()
        {
            // ASSUME:
            //    The controller has no Authorize attribute
            //    The controller has no AllowAnonymous attribute
            //    The method has no Authorize attribute
            //    The method has no AllowAnonymous attribute

            // Assume that PingAuthorizedByMiddlewareController does not have a AllowAnonymous or Authorize attribute
            typeof(PingAuthorizedByMiddlewareController).GetCustomAttributes<AllowAnonymousAttribute>().Count().Should().Be(0, because: "we need a controller that has no explicit [AllowAnonymous] attribute to ensure the Middleware is configured. ");
            typeof(PingAuthorizedByMiddlewareController).GetCustomAttributes<AuthorizeAttribute>().Count().Should().Be(0, because: "we need a controller that has no explicit [Authorize] attributes to ensure the Middleware is configured. ");

            // Assume the Get method does not have any attributes
            typeof(PingAuthorizedByMiddlewareController).GetMethod("Get").GetCustomAttributes<AllowAnonymousAttribute>().Count().Should().Be(0, because: "we need a method that has no explicit [AllowAnonymous] attribute to ensure the Middleware is configured. ");
            typeof(PingAuthorizedByMiddlewareController).GetMethod("Get").GetCustomAttributes<AuthorizeAttribute>().Count().Should().Be(0, because: "we need a method that has no explicit [Authorize] attributes to ensure the Middleware is configured. ");
        }

        [TestMethod]
        public void WhenWeAccessAMethodInAController_TheDefaultMiddlewareAuthenticationIsUsed()
        {
            // Arrange
            var getPingAuthorizedByMiddlewareBuilderRequest = Resolve<GetPingAuthorizedByMiddlewareBuilder>()
                .Build();

            // Act, Assert
            // We will get Unauthorized because the default (Middleware) Authentication and Authorization is applied: the TestInitialize method assumes there are no AllowAnonymous or Authorize methods on the method being invoked.
            Client.Execute(getPingAuthorizedByMiddlewareBuilderRequest, andExpect: System.Net.HttpStatusCode.Unauthorized);
        }
    }
}
