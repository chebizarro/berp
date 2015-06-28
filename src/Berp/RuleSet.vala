using Gee;

namespace Berp
{
    public class RuleSet : Gee.ArrayList<Rule>
    {
        private HashTable<string, Object> settings;
        private Gee.ArrayList<LookAheadHint> lookAheadHints = new Gee.ArrayList<LookAheadHint>();
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

        public Gee.Iterable<Rule> DerivedRules
        {
            get { return this.Where(r => r is DerivedRule); }
        } 

        public Gee.Iterable<Rule> TokenRules
        {
            get { return this.Where(r => r is TokenRule); }
        }

        public Gee.Iterable<LookAheadHint> LookAheadHints
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
            add(new TokenRule(TokenType.EOF));
            foreach (var fieldInfo in tokenType.GetFields(BindingFlags.Static | BindingFlags.Public))
            {
                add(new TokenRule((TokenType)fieldInfo.GetValue(null)));
            }
            add(new TokenRule(TokenType.Other));
        }

        public RuleSet.WithSettings(HashMap<string, Object> settings)
        {
            this.settings = settings ?? new HashMap<string, Object>();

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
            add(new TokenRule(TokenType.EOF));
            foreach (var token in GetSetting("Tokens", new Object[0]))
            {
                add(new TokenRule(new TokenType(token.ToString().Substring(1))));
            }
            add(new TokenRule(TokenType.Other));
        }


        public string ToString(bool embedNonProductionRules = false)
        {
            var ruleSetBuilder = new StringBuilder();

            foreach (var rule in this.Where(r => !r.TempRule || !embedNonProductionRules).Where(r => !(r is TokenRule) || !embedNonProductionRules))
            {
                ruleSetBuilder.append(rule.ToString(embedNonProductionRules) + "\n");
            }

            return ruleSetBuilder.str;
        }

        public Rule ResolveRule(string ruleName)
        {
            return this.SingleOrDefault(r => r.Name == ruleName);
        }

        private void ResolveWithLookAhead(LookAheadHint lookAheadHint)
        {
            lookAheadHint.Id = lookAheadHints.length();
            lookAheadHints.add(lookAheadHint);
        }

        public void Resolve()
        {
            foreach (var rule in this)
            {
                rule.ResolveRule(this);

                if (rule.LookAheadHint != null)
                    ResolveWithLookAhead(rule.LookAheadHint);
            }
        }

        public void SetIgnoredContent(params TokenType[] newIgnoredTokens)
        {
            ignoredTokens = newIgnoredTokens;
        }
    }
}
