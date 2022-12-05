using Yeha.Api.TestSdk.Contracts;

namespace Yeha.Api.TestSdk.RequestBuilders
{
    public abstract class RequestBuilderBase<T> where T : RequestBuilderBase<T>
    {
        public RequestBuilderBase()
        {
        }

        public abstract IRequest Build();
    }
}
