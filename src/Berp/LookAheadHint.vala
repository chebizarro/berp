
namespace Berp
{
    public class LookAheadHint
    {
        public int Id { get; set; }

        public TokenType[] Skip { get; private set; }

        public TokenType[] ExpectedTokens { get; private set; }

        public LookAheadHint(TokenType expectedToken, TokenType[] skip)
        {
            this.Skip = skip;
            ExpectedTokens = {expectedToken};
        }

        public LookAheadHint.FromTokens(TokenType[] expectedTokens, TokenType[] skip)
        {
            this.ExpectedTokens = expectedTokens;
            this.Skip = skip;
        }
    }
}
