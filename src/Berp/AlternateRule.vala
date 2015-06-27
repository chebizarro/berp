namespace Berp {

	public class AlternateRule : DerivedRule {

		public AlternateRule (string name, string[] alternateRules) {
			base(name, alternateRules.foreach((rn) => { new RuleElement(rn)).ToArray() });
		}

		public AlternateRule.WithTokens(string name, TokenType[] alternateRules) {
			base(name, alternateRules.Select(rn => new RuleElement(rn)).ToArray());
		}
		
		public override string GetRuleDescription(bool embedNonProductionRules) {
			var result = new StringBuilder("(");
			foreach (var ruleElement in RuleElements) {
				if (result.Length > 1)
					result.Append(" | ");
				result.Append(ruleElement.ToString(embedNonProductionRules));
			}
			result.Append(")");
			return result.ToString();
		}
	}
}
