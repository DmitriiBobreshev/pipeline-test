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
    /// These tests ensure that every controller that has a [AllowAnonymous] attribute is declared here to help prevent insecure controllers getting onto the code base. Security is often tinkered with during local development... and accidents happen. 
    /// </summary>
    [TestClass]
    [AcknowledgeAllowAnonymousController(Controller = typeof(AllowAnonymousPingController))]
    [AcknowledgeAllowAnonymousController(Controller = typeof(PrimitivesController))]
    [AcknowledgeAllowAnonymousController(Controller = typeof(ProductsController))]
    [AcknowledgeAllowAnonymousController(Controller = typeof(DiagnosticsController))]
    public class AllowAnonymousControllerTests : SecurityTestBase
    {
        [TestMethod]
        [TestCategory("Smoke")]
        public void WhenWeLookForASpecificAllowAnonymousController_ThenWeFindIt()
        {
            var knownAllowAnonymousController = AllowAnonymousControllers
                .Where(c => c.FullName == typeof(AllowAnonymousPingController).FullName);

            knownAllowAnonymousController.Count().Should().Be(1, because: "we know there is at least one [AllowAnonymous] controller in the API so we are explicitly looking for it. Given we scan assemblies by convention, no matches could imply we are not scanning the assembly (not loaded into AppDomain) which is a false positive. This test helps prevent that happening. ");
        }

        [TestMethod]
        [TestCategory("Security")]
        [TestCategory("CodingStandards")]
        public void ByConvention_EveryAllowAnonmousControllerMustBeAcknowledged()
        {
            // Arrange
            var controllersThatAreNotAuthorizedAndNotAcknowledgedAsAllowAnonymous = AllowAnonymousControllers
                .Except(AcknowledgedAllowAnonymousControllers);

            // Assert
            controllersThatAreNotAuthorizedAndNotAcknowledgedAsAllowAnonymous.Count().Should().Be(0, because: $"every controller that is explicitly marked as [AllowAnonymous] must be acknowledged here by adding the [AcknowledgeAllowAnonymousController] attribute to this class with the following types: {string.Join(',', controllersThatAreNotAuthorizedAndNotAcknowledgedAsAllowAnonymous)}");
        }

        private IEnumerable<Type> AcknowledgedAllowAnonymousControllers

        {
            get
            {
                var result = GetType().GetCustomAttributes<AcknowledgeAllowAnonymousControllerAttribute>().Select(a => a.Controller);
                return result;
            }
        }
    }
}
