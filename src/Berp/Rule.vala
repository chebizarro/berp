
namespace Berp
{
    public abstract class Rule
    {
        private bool tempRule = false;
        private bool allowProductionRules = true;
        public abstract string Name { get; }
        public LookAheadHint LookAheadHint { get; set; }

        public bool AllowProductionRules
        {
            get { return allowProductionRules; }
        }

        public bool TempRule
        {
            get { return tempRule; }
        }

        public Rule IgnoreProduction()
        {
            allowProductionRules = false;
            return this;
        }

        public Rule Temporary()
        {
            IgnoreProduction();
            tempRule = true;
            return this;
        }

        public abstract string GetRuleDescription(bool embedNonProductionRules);


        public virtual string ToString(bool embedNonProductionRules = false)
        {
            var result = new StringBuilder(Name);
            if (AllowProductionRules)
                result.append("!");
            if (LookAheadHint != null)
                result.append_printf(" [%s->%s]", "|" + LookAheadHint.Skip.foreach(t => "#" + t.Name), "|" + LookAheadHint.ExpectedTokens.Select(t => "#" + t.Name));

            result.append(" := ");
            result.append(GetRuleDescription(embedNonProductionRules));
            return result.str;
        }

        public abstract void Resolve(RuleSet ruleSet);
    }
}
