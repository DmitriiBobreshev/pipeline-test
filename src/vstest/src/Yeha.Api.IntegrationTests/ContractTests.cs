using FluentAssertions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static Newtonsoft.Json.Linq.JTokenType;
using System.Threading.Tasks;
using System.Linq;

namespace Yeha.Api.IntegrationTests
{
    /// <summary>
    /// Rationale: Lock in the shape ('contract') of your response: strings, integers, booleans and so forth. 
    /// </summary>
    /// <remarks>
    /// It is trivial to add these kinds of contract tests by piggy backing on your functional/integration tests; works well for small teams. 
    /// 
    /// References:
    /// For testing deserialized models (ranges and so forth), consider using the likes of FluentValidator Contracts (https://github.com/andrebaltieri/FluentValidator/wiki/Using-Validation-Contracts). 
    ///    However, that is better done as a functional test on the service - not on the contract side. 
    /// For a Consumer/Contract Driven Testing Solution that scales across large, distributed teams, see https://pact.io
    /// </remarks>
    [TestClass]
    public class ContractTests_AsAConsumer_IAlwaysWant : IntegrationTestBase
    {
        private JObject _content;

        [TestInitialize]
        public async Task SetupContractTests()
        {
            var response = await TestClient.GetAsync("/api/primitives");
            var result = await response.Content.ReadAsStringAsync();

            _content = JsonConvert.DeserializeObject<JObject>(result);
        }

        [TestMethod]
        public void AString()
        {
            AssertThat(thePropertyCalled: "thisIsAString", inPayload: _content, isOfType: String);
            AssertThat(thePropertyCalled: "thisIsAString", inPayload: _content, isOneOfTheseTypes: new[] { String, Null });
        }

        [TestMethod]
        public void AStringWithNullValue()
        {
            AssertThat(thePropertyCalled: "thisIsAStringWithNullValue", inPayload: _content, isOfType: Null);
            AssertThat(thePropertyCalled: "thisIsAStringWithNullValue", inPayload: _content, isOneOfTheseTypes: new[] { String, Null });
        }

        [TestMethod]
        public void Integers()
        {
            AssertThat(thePropertyCalled: "thisIsAByte", inPayload: _content, isOfType: Integer);
            AssertThat(thePropertyCalled: "thisIsAShort", inPayload: _content, isOfType: Integer);
            AssertThat(thePropertyCalled: "thisIsAnInt", inPayload: _content, isOfType: Integer);
            AssertThat(thePropertyCalled: "thisIsALong", inPayload: _content, isOfType: Integer);
        }

        [TestMethod]
        public void FloatsAndDoubles()
        {
            AssertThat(thePropertyCalled: "thisIsAFloat", inPayload: _content, isOfType: Float);
            AssertThat(thePropertyCalled: "thisIsADouble", inPayload: _content, isOfType: Float);
        }

        [TestMethod]
        public void ABoolean()
        {
            AssertThat(thePropertyCalled: "thisIsAFalseBoolean", inPayload: _content, isOfType: Boolean);
            AssertThat(thePropertyCalled: "thisIsATrueBoolean", inPayload: _content, isOfType: Boolean);
        }

        [TestMethod]
        public void AGuid()
        {
            // A C# Guid is serialized as a string. 
            AssertThat(thePropertyCalled: "thisIsAGuid", inPayload: _content, isOfType: String);
        }

        [TestMethod]
        public void ATimeSpan()
        {
            // By default, a TimeSpan is serialized as a struct.
            // If deserializing into a C# POCO with a TimeSpan Property, Newtonsoft can work out that it is a TimeSpan and deserialize accordingly. 
            // If deserializing into a JObject, Newtonsoft does not have all of the context it needs to know its a TimeSpan - so treats it as an Object
            // See https://stackoverflow.com/questions/13484540/how-to-parse-a-timespan-value-in-newtonsoft-json for more information
            AssertThat(thePropertyCalled: "thisIsATimeSpan", inPayload: _content, isOfType: Object);
        }

        [TestMethod]
        public void ADateTime()
        {
            AssertThat(thePropertyCalled: "thisIsADateTime", inPayload: _content, isOfType: Date);
        }

        [TestMethod]
        public void AUri()
        {
            // C# Uri objects are always serialized as a String
            AssertThat(thePropertyCalled: "thisIsAUri", inPayload: _content, isOfType: String);
        }

        [TestMethod]
        public void AnArrayEmptyInteger()
        {
            AssertThat(thePropertyCalled: "thisIsAnEmptyIntArray", inPayload: _content, isOfType: Array);
        }

        [TestMethod]
        public void AnArrayOneInteger()
        {
            AssertThat(thePropertyCalled: "thisIsAnEmptyIntArray", inPayload: _content, isOfType: Array);
        }

        [TestMethod]
        public void WantAnObject()
        {
            AssertThat(thePropertyCalled: "thisIsANestedObject", inPayload: _content, isOfType: Object);
        }

        [TestMethod]
        public void ANestedPropertyInObject()
        {
            var nestedObject = _content.SelectToken("$.thisIsANestedObject");
            AssertThat(thePropertyCalled: "nestedString", inPayload: nestedObject, isOfType: String);
        }

        [TestMethod]
        public void SerializedBytes()
        {
            // NOTE: A byte array will be deserialized as a string (without a model)
            AssertThat(thePropertyCalled: "theseAreBytes", inPayload: _content, isOfType: String);
        }

        [TestMethod]
        [ExpectedException(typeof(AssertFailedException))]
        public void PropertyDoesNotExist()
        {
            _content["ThisPropertyDoesnotExist"].Should().NotBeNull(because: "the ThisPropertyDoesnotExist property does not exist. ");
        }

        private void AssertThat(string thePropertyCalled, JToken inPayload, JTokenType isOfType)
        {
            inPayload[thePropertyCalled].Should().NotBeNull(because: $"the {thePropertyCalled} property should always be present. ");
            inPayload[thePropertyCalled].Type.Should().Be(isOfType, because: $"the expected type of {thePropertyCalled} is {isOfType}");
        }

        private void AssertThat(string thePropertyCalled, JToken inPayload, JTokenType[] isOneOfTheseTypes)
        {
            var candidateTypes = isOneOfTheseTypes.Select(type => type.ToString());

            inPayload[thePropertyCalled].Should().NotBeNull(because: $"the {thePropertyCalled} property should always be present. ");
            inPayload[thePropertyCalled].Type.ToString().Should().BeOneOf(candidateTypes, because: $"the expected type of {thePropertyCalled} is one of {string.Join(',', candidateTypes)}");
        }
    }
}
