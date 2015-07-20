using Gee;

namespace Berp
{
    public class RuleSet : Gee.ArrayList<Rule>
    {
        private HashMap<string, Object> settings;
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

        public RuleIterator<Rule> DerivedRules
        {
            get { return this.Where(r => r is DerivedRule); }
        } 

        public RuleIterator<Rule> TokenRules
        {
            get { return this.Where(r => r is TokenRule); }
        }

        public RuleIterator<LookAheadHint> LookAheadHints
        {
            get { return new RuleIterator<LookAheadHint>(lookAheadHints); }
        }

        public T GetSetting<T>(string name, T? defaultValue = null)
        {
            //Object paramValue;
            if (settings.has_key(name))
            {
                return (T)settings.get(name);
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
			TokenType[] tokens;
			foreach (var token in GetSetting("IgnoredTokens", tokens)) {
				tokens += new TokenType(token.ToString().substring(1));
			}
			
            SetIgnoredContent(tokens);
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
			
			var firstSet = new ArrayList<Rule> ();
			var secondSet = new ArrayList<Rule> ();
			
			this.foreach ((r) => {
				if (!r.TempRule || !embedNonProductionRules) {
					firstSet.add(r);
				}
			});
			
			firstSet.foreach ((r) => {
				if (!r.TempRule || !embedNonProductionRules) {
					firstSet.add(r);
				}
			});
			
			
            foreach (var rule in this.Where(r => !r.TempRule || !embedNonProductionRules)
				.Where(r => !(r is TokenRule) || !embedNonProductionRules)
			)
            {
                ruleSetBuilder.append(rule.ToString(embedNonProductionRules) + "\n");
            }

            return ruleSetBuilder.str;
        }

        public Rule? Resolve(string? ruleName = null)
        {
			if (ruleName != null) {
				return this.SingleOrDefault(r => r.Name == ruleName);
			} else {
				foreach (var rule in this) {
					rule.Resolve(this);
					if (rule.LookAheadHint != null)
						ResolveWithLookAhead(rule.LookAheadHint);
				}
				return null;
			}
        }

        private void ResolveWithLookAhead(LookAheadHint lookAheadHint)
        {
            lookAheadHint.Id = lookAheadHints.size;
            lookAheadHints.add(lookAheadHint);
        }

        public void SetIgnoredContent(TokenType[] newIgnoredTokens)
        {
            ignoredTokens = newIgnoredTokens;
        }

		public delegate bool WhereFunc<T>(T rule);
        
        public RuleIterator<Rule> Where (WhereFunc func) {
			return new RuleIterator<Rule>(this as ArrayList<Rule>, func); 
		}
		
		public class RuleIterator<T> : Object {
			
			internal ArrayList<T> _ruleset;
			internal WhereFunc? _wherefunc;
			internal Iterator<T> _iterator;
			
			internal RuleIterator (ArrayList<T> ruleset, WhereFunc? wherefunc = null) {
				_ruleset = ruleset;
				_iterator = ruleset.iterator();
				_wherefunc = wherefunc;
			}
			
			public bool next () {
				if (_wherefunc != null) {
					while (_iterator.next()) {
						T rule = _iterator.get();
						if (_wherefunc(rule)) {
							return true;
						}
					}
					return false;
				}
				return _iterator.next();
			}
			
			public new T get() {
				return _iterator.get();
			}
			
		}
    }
}
