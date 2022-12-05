using System;

namespace Yeha.Api.Models
{
    public class Primitives
    {
        public string ThisIsAString { get; set; }
        public string ThisIsAStringWithNullValue { get; set; }

        // Object
        // Array
        // Constructor
        // Property
        // Comment
        public byte ThisIsAByte { get; set; }
        public short ThisIsAShort { get; set; }
        public int ThisIsAnInt { get; set; }
        public long ThisIsALong { get; set; }

        public float ThisIsAFloat { get; set; }
        public double ThisIsADouble { get; set; }

        public bool ThisIsAFalseBoolean { get; set; }
        public bool ThisIsATrueBoolean { get; set; }

        public Guid ThisIsAGuid { get; set; }

        public TimeSpan ThisIsATimeSpan { get; set; }

        public DateTime ThisIsADateTime { get; set; }

        public Uri ThisIsAUri { get; set; }

        public int[] ThisIsAnEmptyIntArray { get; set; }

        public int[] ThisIsAnIntArrayWithOneElement { get; set; }

        public NestedPrimitives ThisIsANestedObject { get; set; }

        public byte[] TheseAreBytes { get; set; }
    }
}
