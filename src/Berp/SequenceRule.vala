
namespace Berp
{
    public class SequenceRule : DerivedRule
    {
        private RuleElement[] originalRuleElements = null;
		
		public SequenceRule(string name, params RuleElement[] ruleElements) {
			base(name, ruleElements);
		}

        public override string GetRuleDescription(bool embedNonProductionRules)
        {
            var result = new StringBuilder();
            foreach (var ruleElement in originalRuleElements ?? RuleElements)
            {
                if (result.len > 0)
                    result.append(" ");
                result.append(ruleElement.ToString(embedNonProductionRules));
            }
            return result.str;
        }

        public override void Resolve(RuleSet ruleSet)
        {
            base.Resolve(ruleSet);
            var resolvedRules = new List<RuleElement>();
            foreach (var ruleElement in RuleElements)
            {
                if (ruleElement.Multilicator == Multilicator.OneOrMore)
                {
                    resolvedRules.append(new RuleElement(ruleElement.RuleName, Multilicator.One) { ResolvedRule = ruleElement.ResolvedRule });
                    resolvedRules.append(new RuleElement(ruleElement.RuleName, Multilicator.Any) { ResolvedRule = ruleElement.ResolvedRule });
                }
                else
                {
                    resolvedRules.append(ruleElement);
                }
            }
            originalRuleElements = RuleElements;
			resolvedRules.foreach ((d) => { RuleElements += d; });
        }
    }
}
