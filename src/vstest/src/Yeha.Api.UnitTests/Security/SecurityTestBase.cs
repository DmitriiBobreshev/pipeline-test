using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Yeha.Api.Controllers;

namespace Yeha.Api.UnitTests.Security
{
    [TestClass]
    public class SecurityTestBase
    {
        // We need to take a strong reference on something in the API so we can find it in the AppDomain
        public Type ProductControllerType = typeof(ProductsController);

        public const string FILENAME_PREFIX = "Yeha";

        protected IEnumerable<Type> Controllers;
        protected IEnumerable<Type> AuthorizedControllers;
        protected IEnumerable<Type> AllowAnonymousControllers;

        [TestInitialize]
        public void SetupControllerSecurityTests()
        {
            var candidateAssemblies = AppDomain.CurrentDomain.GetAssemblies()
                .Where(assembly => !assembly.IsDynamic)
                .Where(assembly => System.IO.Path.GetFileName(assembly.Location).StartsWith(FILENAME_PREFIX));

            Controllers = GetAllControllers(fromAssemblies: candidateAssemblies);
            AuthorizedControllers = GetAuthorizedControllers(fromControllers: Controllers);
            AllowAnonymousControllers = GetAllowAnonymousControllers(fromControllers: Controllers);
        }

        protected IEnumerable<Type> GetAllControllers(IEnumerable<Assembly> fromAssemblies)
        {
            var result = new List<Type>();

            foreach (var assembly in fromAssemblies)
            {
                result.AddRange(GetAllControllers(fromAssembly: assembly));
            };

            return result;
        }

        protected IEnumerable<Type> GetAllControllers(Assembly fromAssembly)
        {
            var controllers = fromAssembly.GetTypes().Where(t => t.IsSubclassOf(typeof(ControllerBase)));
            return controllers;
        }
        protected IEnumerable<Type> GetAuthorizedControllers(IEnumerable<Type> fromControllers)
        {
            var authorizedControllers = fromControllers.Where(c => c.GetCustomAttributes<AuthorizeAttribute>().Count() > 0);
            return authorizedControllers;
        }
        protected IEnumerable<Type> GetAllowAnonymousControllers(IEnumerable<Type> fromControllers)
        {
            var allowAnonymousControllers = fromControllers.Where(c => c.GetCustomAttributes<AllowAnonymousAttribute>().Count() > 0);
            return allowAnonymousControllers;
        }
    }
}
