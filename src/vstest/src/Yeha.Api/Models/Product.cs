using Yeha.Api.Contracts;

namespace Yeha.Api.Models
{
    public class Product : IProduct
    {
        public string Id { get; set; }

        public string Description { get; set; }
    }
}
