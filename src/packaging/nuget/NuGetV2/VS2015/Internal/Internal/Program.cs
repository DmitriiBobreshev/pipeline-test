using System;

namespace Internal
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(Calculator.Calculate());
        }
    }

    public class Calculator
    {
        public static int Calculate()
        {
            return BuildCanary.NuGet.MathLib.Operators.Add(1, 1);
        }
    }
}
