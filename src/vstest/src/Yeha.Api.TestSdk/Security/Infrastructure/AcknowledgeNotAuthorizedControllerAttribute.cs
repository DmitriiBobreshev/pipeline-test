using System;

namespace Yeha.Api.TestSdk.Security.Infrastructure
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class AcknowledgeNotAuthorizedControllerAttribute : Attribute
    {
        public AcknowledgeNotAuthorizedControllerAttribute()
        {
        }

        public Type Controller { get; set; }
    }
}
