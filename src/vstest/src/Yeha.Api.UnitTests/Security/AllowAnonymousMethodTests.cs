using FluentAssertions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Yeha.Api.TestSdk.Security.Infrastructure;

namespace Yeha.Api.UnitTests.Security
{
    /// <summary>
    /// These tests ensure that every [AllowAnonymous] method is declared here to help prevent insecure methods getting onto the code base. Security is often tinkered with during local development... and accidents happen. 
    /// </summary>
    [TestClass]
    [AcknowledgeAllowAnonymousMethod(Controller = typeof(Controllers.PingWithAllowAnonymousMethodsController), MethodName = "Get")]
    [AcknowledgeAllowAnonymousMethod(Controller = typeof(Controllers.PingWithAllowAnonymousMethodsController), MethodName = "Delete")]
    public class AllowAnonymousMethodTests : SecurityTestBase
    {
        [TestMethod]
        [TestCategory("Smoke")]
        public void WhenWeLookForASpecificAllowAnonymousMethod_ThenWeFindIt()
        {
            // Arrange
            var knownAllowAnonymousMethod = FindAllMethods(Controllers)
                .Where(m => IsAllowAnonymousMethod(m))
                .Where(m => m.DeclaringType.FullName == typeof(Controllers.PingWithAllowAnonymousMethodsController).FullName)
                .Where(m => m.Name == "Get");

            // Assert
            knownAllowAnonymousMethod.Count().Should().Be(1, because: "we know there is at least one AllowAnonymous method in the API so we are explicitly looking for it. Given we scan assemblies by convention, no matches could imply we are not scanning the assembly (not loaded into AppDomain) which is a false positive. This test helps prevent that happening. ");
        }

        [TestMethod]
        [TestCategory("Security")]
        [TestCategory("CodingStandards")]
        public void ByConvention_AllowAnonymousMethodsMustBeDeclaredHere()
        {
            // Arrange
            var anonymousMethods = FindAllMethods(inControllers: Controllers)
                .Where(m => IsAllowAnonymousMethod(m));

            var allowAnonymousMethodsNotAcknowledged = anonymousMethods.Select(m => ToFullyQualifiedMethodName(m)).Except(AcknowledgedAllowAnonymousMethods);

            // Assert
            allowAnonymousMethodsNotAcknowledged.Count().Should().Be(0, because: $"every method marked 'AllowAnonymous' must be specified in this test class to help prevent insecure methods getting into Production. Either remove 'AllowAnonymous' from the following methods or acknowledge them by adding an [AcknowledgeAllowAnonymousMethod] attribute on this test class with these fully qualified names: {string.Join(',', allowAnonymousMethodsNotAcknowledged)}");
        }

        private IEnumerable<string> AcknowledgedAllowAnonymousMethods
        {
            get
            {
                var result = GetType().GetCustomAttributes<AcknowledgeAllowAnonymousMethodAttribute>().Select(a => $"{a.FullyQualifiedName}");
                return result;
            }
        }

        private IEnumerable<MethodInfo> FindAllMethods(IEnumerable<Type> inControllers)
        {
            var result = new List<MethodInfo>();
            foreach (var controller in inControllers)
            {
                result.AddRange(controller.GetMethods());
            }
            return result;
        }

        private bool IsAllowAnonymousMethod(MethodInfo methodInfo)
        {
            if (null == methodInfo) return false;

            return methodInfo.GetCustomAttributes<AllowAnonymousAttribute>().Count() > 0;
        }

        private string ToFullyQualifiedMethodName(MethodInfo methodInfo)
        {
            return $"{methodInfo.DeclaringType.FullName}.{methodInfo.Name}";
        }
    }
}
