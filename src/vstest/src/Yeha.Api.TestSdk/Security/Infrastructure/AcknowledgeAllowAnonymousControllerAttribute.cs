using System;

namespace Yeha.Api.TestSdk.Security.Infrastructure
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class AcknowledgeAllowAnonymousControllerAttribute : Attribute
    {
        public AcknowledgeAllowAnonymousControllerAttribute()
        {
        }

        public Type Controller { get; set; }
    }
}
