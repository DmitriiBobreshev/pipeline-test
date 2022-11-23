namespace External
{
    public class Calculator
    {
        public static int Calculate()
        {
            return TestPackages.Subtracter.Subtract(1, 1);
        }
    }
}
