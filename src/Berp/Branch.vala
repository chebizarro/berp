
namespace Berp
{
    class Branch
    {
        class BranchProductionComparer : Gee.Comparable<Branch>, Object
        {
            public bool Equals(Branch x, Branch y)
            {
                return x.TokenType.Equals(y.TokenType)
                    && x.OptimizedProductions.SequenceEqual(y.OptimizedProductions)
                    && CallStackItem.PositionAgnosticEquals(x.CallStackItem, y.CallStackItem)
                    ;
            }

            public uint GetHashCode(Branch obj)
            {
                return obj.TokenType.GetHashCode();
            }
        }
        public static Gee.Comparable<Branch> ProductionComparer = new BranchProductionComparer();


        public TokenType TokenType { get; private set; }
        public CallStackItem CallStackItem { get; private set; }

        public List<ProductionRule> Productions { get; private set; }
        public List<ProductionRule> OptimizedProductions { get; set; }

        public LookAheadHint LookAheadHint { get; set; }

        public Branch(TokenType tokenType, CallStackItem callStackItem, List<ProductionRule> productions)
        {
            TokenType = tokenType;
            CallStackItem = callStackItem;
            Productions = productions;
        }

        public string ToString()
        {
            return string.Format("{0} -> {1}", TokenType, CallStackItem);
        }

        public string GetProductionsText()
        {
            return string.Format("[{0}]", string.Join(",", OptimizedProductions ?? Productions));
        }

        public int compare_to(Branch other) {
            return TokenType.Equals(other.TokenType)
                && CallStackItem.Equals(other.CallStackItem)
                && OptimizedProductions.SequenceEqual(other.OptimizedProductions);
        }

/*
		public override int compare_to (Object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != GetType()) return false;
            return Equals((Branch) obj);
        }
*/
        public override int GetHashCode() {
			return (TokenType.GetHashCode()*397);
		}
	}
}
