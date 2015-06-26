
namespace Berp
{
    [Serializable]
    public class ParserGeneratorException : Exception
    {
        public ParserGeneratorException()
        {
        }

        public ParserGeneratorException(string message) : base(message)
        {
        }

        public ParserGeneratorException(string messageFormat, params object[] args) : base(string.Format(messageFormat, args))
        {
        }

        protected ParserGeneratorException(
            SerializationInfo info,
            StreamingContext context) : base(info, context)
        {
        }
    }
}
