using System;
using Newtonsoft.Json;

namespace SimpleProject
{
    class Program
    {
        static void Main(string[] args)
        {
            TestClass test = new TestClass()
            {
                Number = 1,
                String = "ABC"
            };
            Console.WriteLine(JsonConvert.SerializeObject(test));
        }
    }

    public class TestClass
    {
        public int Number { get; set; }

        public string String { get; set; }
    }
}
