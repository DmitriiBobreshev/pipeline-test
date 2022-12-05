using System;

namespace Yeha.Api.TestSdk.Security.Infrastructure
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class AcknowledgeAllowAnonymousMethodAttribute : Attribute
    {
        public AcknowledgeAllowAnonymousMethodAttribute()
        {
        }

        public Type Controller { get; set; }
        public string MethodName { get; set; }
        public string FullyQualifiedName => $"{Controller?.FullName ?? "ControllerPropertyNotset"}.{MethodName}";
    }
}
