
namespace Berp
{
    public class RuleSet : List<Rule>
    {
        private HashTable<string, Object> settings;
        private List<LookAheadHint> lookAheadHints = new List<LookAheadHint>();
        private TokenType[] ignoredTokens = new TokenType[0];

        public TokenType[] IgnoredTokens
        {
            get { return ignoredTokens; }
        }

        public Rule StartRule
        {
            get
            {
                return this.SingleOrDefault(r => r is StartRule);
            }
        }

        public IEnumerable<Rule> DerivedRules
        {
            get { return this.Where(r => r is DerivedRule); }
        } 

        public IEnumerable<Rule> TokenRules
        {
            get { return this.Where(r => r is TokenRule); }
        }

        public IEnumerable<LookAheadHint> LookAheadHints
        {
            get { return lookAheadHints; }
        }

        public T GetSetting<T>(string name, T defaultValue = default(T))
        {
            Object paramValue;
            if (settings.TryGetValue(name, out paramValue))
            {
                return (T)paramValue;
            }
            return defaultValue;
        }

        public RuleSet(Type tokenType)
        {
            Add(new TokenRule(TokenType.EOF));
            foreach (var fieldInfo in tokenType.GetFields(BindingFlags.Static | BindingFlags.Public))
            {
                Add(new TokenRule((TokenType)fieldInfo.GetValue(null)));
            }
            Add(new TokenRule(TokenType.Other));
        }

        public RuleSet.WithSettings(HashTable<string, Object> settings)
        {
            this.settings = settings ?? new HashTable<string, Object>();

            AddTokens();
            AddIgnoredContent();
        }

        private void AddIgnoredContent()
        {
            SetIgnoredContent(GetSetting("IgnoredTokens", new Object[0])
                .Select(token => new TokenType(token.ToString().Substring(1))).ToArray());
        }

        private void AddTokens()
        {
            Add(new TokenRule(TokenType.EOF));
            foreach (var token in GetSetting("Tokens", new Object[0]))
            {
                Add(new TokenRule(new TokenType(token.ToString().Substring(1))));
            }
            Add(new TokenRule(TokenType.Other));
        }


        public string ToString(bool embedNonProductionRules = false)
        {
            var ruleSetBuilder = new StringBuilder();

            foreach (var rule in this.Where(r => !r.TempRule || !embedNonProductionRules).Where(r => !(r is TokenRule) || !embedNonProductionRules))
            {
                ruleSetBuilder.AppendLine(rule.ToString(embedNonProductionRules));
            }

            return ruleSetBuilder.ToString();
        }

        public Rule Resolve.Rule(string ruleName)
        {
            return this.SingleOrDefault(r => r.Name == ruleName);
        }

        private void Resolve.LookAhead(LookAheadHint lookAheadHint)
        {
            lookAheadHint.Id = lookAheadHints.Count;
            lookAheadHints.Add(lookAheadHint);
        }

        public void Resolve()
        {
            foreach (var rule in this)
            {
                rule.Resolve(this);

                if (rule.LookAheadHint != null)
                    Resolve(rule.LookAheadHint);
            }
        }

        public void SetIgnoredContent(params TokenType[] newIgnoredTokens)
        {
            ignoredTokens = newIgnoredTokens;
        }
    }
}
