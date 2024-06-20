namespace External
{
    public class Calculator
    {
        public static int Calculate()
        {
            var substracter = new TestPackages.Subtracter();
            return substracter.Subtract(1, 1);
        }
    }
}
