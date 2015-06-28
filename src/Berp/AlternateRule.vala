namespace Berp {

	public class AlternateRule : DerivedRule {

		public AlternateRule (string name, string[] alternateRules) {
			RuleElement[] rules = {};
			
			foreach (string rule in alternateRules) {
				rules += new RuleElement (rule);
			}
			
			base(name, rules);
		}

		public AlternateRule.FromToken(string name, TokenType[] alternateRules) {
			RuleElement[] rules = {};
			
			foreach (TokenType rule in alternateRules) {
				rules += new RuleElement.FromToken (rule);
			}
			
			base(name, rules);
		}
		
		public override string GetRuleDescription(bool embedNonProductionRules) {
			var result = new StringBuilder("(");
			foreach (var ruleElement in RuleElements) {
				if (result.len > 1)
					result.append(" | ");
				result.append(ruleElement.ToString(embedNonProductionRules));
			}
			result.append(")");
			return result.str;
		}
	}
}
