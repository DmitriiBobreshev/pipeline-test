using FluentAssertions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Yeha.Api.Controllers;
using Yeha.Api.TestSdk.Security.Infrastructure;

namespace Yeha.Api.UnitTests.Security
{
    /// <summary>
    /// These tests ensure that every controller has a [Authorize] attribute or is declared here to help prevent insecure controllers getting onto the code base. Security is often tinkered with during local development... and accidents happen. 
    /// </summary>
    [TestClass]
    [AcknowledgeNotAuthorizedController(Controller = typeof(ProductsController))]
    [AcknowledgeNotAuthorizedController(Controller = typeof(PrimitivesController))]
    [AcknowledgeNotAuthorizedController(Controller = typeof(AllowAnonymousPingController))]
    [AcknowledgeNotAuthorizedController(Controller = typeof(PingAuthorizedByMiddlewareController))]
    [AcknowledgeNotAuthorizedController(Controller = typeof(DiagnosticsController))]
    public class ControllerAuthorizeTests : SecurityTestBase
    {
        [TestMethod]
        [TestCategory("Smoke")]
        public void EnsureWeFindAKnownNotAuthorizedController()
        {
            // Arrange
            var knownNotAuthorizedcontrollers = Controllers
                .Except(AuthorizedControllers)
                .Where(m => m.FullName == typeof(ProductsController).FullName);

            // Assert
            knownNotAuthorizedcontrollers.Count().Should().Be(1, because: "we know there is at least one non-Authorized controller in the API so we are explicitly looking for it. Given we scan assemblies by convention, no matches could imply we are not scanning the assembly (not loaded into AppDomain) which is a false positive. This test helps prevent that happening. ");
        }

        [TestMethod]
        [TestCategory("Smoke")]
        public void EnsureThereIsAtLeastOneController()
        {
            // Assert
            Controllers.Count().Should().BeGreaterThan(0, because: "there should be at least one controller defined somewhere. If not, this algorithm might not be finding the assembly. ");
        }

        [TestMethod]
        [TestCategory("Smoke")]
        public void EnsureThereIsAtLeastOneAuthorizedController()
        {
            // Assert
            AuthorizedControllers.Count().Should().BeGreaterThan(0, because: "there should be at least one controller with the [Authorize] attribute defined somewhere. If not, this algorithm might not be finding the assembly. ");
        }

        [TestMethod]
        [TestCategory("Security")]
        [TestCategory("CodingStandards")]
        public void ByConvention_EveryControllerMustBeAuthorizedUnlessExplicitlyAcknowledgedAsInsecure()
        {
            // Arrange
            var controllersThatAreNotAuthorizedAndNotAcknowledgedAsInsecure = Controllers
                .Except(AuthorizedControllers)
                .Except(AcknowledgedNotAuthorizedControllers);

            // Assert
            controllersThatAreNotAuthorizedAndNotAcknowledgedAsInsecure.Count().Should().Be(0, because: $"every controller should be explicitly Authorized or explicitly acknowledged as insecure by adding the [AcknowledgedNotAuthorizedControllers] to this class with the following types: {string.Join(',', controllersThatAreNotAuthorizedAndNotAcknowledgedAsInsecure)}");
        }

        private IEnumerable<Type> AcknowledgedNotAuthorizedControllers

        {
            get
            {
                var result = GetType().GetCustomAttributes<AcknowledgeNotAuthorizedControllerAttribute>().Select(a => a.Controller);
                return result;
            }
        }
    }
}
