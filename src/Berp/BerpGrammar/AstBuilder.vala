
namespace Berp.BerpGrammar
{
	
	public struct KeyValuePair<TKey, TValue> {
		private TKey Key { get; private set;}
		private TValue @Value { get; set;}
	}

	
    public class AstBuilder : IAstBuilder
    {
        public class AstNode
        {
            public RuleType Node { get; set; }
            public List<KeyValuePair<RuleType, List<Object>>> SubNodes { get; set; }

            public Gee.Iterable<Object> GetSubNodesOf(RuleType ruleType)
            {
                return SubNodes.Where(sn => sn.Key == ruleType).SelectMany(sn => sn.Value);
            }

            public Gee.Iterable<Object> GetAllSubNodes()
            {
                return SubNodes.SelectMany(sn => sn.Value);
            }

            public void AddSubNode(RuleType nodeName, Object subNode)
            {
                if (SubNodes.Count > 0)
                {
                    var lastSubNode = SubNodes.LastOrDefault();
                    if (lastSubNode.Key == nodeName)
                    {
                        lastSubNode.Value.Add(subNode);
                        return;
                    }
                }
				List<Object> subNodes = new List<Object> ();
				subNodes.append (subNode);
                SubNodes.append (KeyValuePair<RuleType, List<Object>> (nodeName, subNodes));
            }

            public AstNode()
            {
                SubNodes = new List<KeyValuePair<RuleType, List<Object>>>();
            }

            public override string ToString()
            {
                return string.Format("<{0}>{1}</{0}>", Node, string.Join(", ", SubNodes.Select(sn =>
                    string.Format("[{0}:{1}]", sn.Key, string.Join(", ", sn.Value.Select(v => v.ToString()))))));
            }
        }


        private DomBuilder domBuilder = new DomBuilder();
        private Gee.LinkedList<AstNode> stack = new Gee.LinkedList<AstNode>();
        public AstNode CurrentNode { get { return stack.Peek(); } }

        public AstBuilder()
        {
			AstNode node = new AstNode ();
			node.Node = RuleType.None;
            stack.Push(node);
        }

        public void Build(Token token)
        {
            var subNodes = domBuilder.BuildFromToken(token);
            foreach (var subNode in subNodes)
            {
                CurrentNode.AddSubNode((RuleType)token.TokenType, subNode);
            }
        }

        public void StartRule(RuleType node) {
			stack.Push(new AstNode ().Node = node);
        }

        public void EndRule(RuleType node)
        {
            Pop();
        }

        public void Pop()
        {
            var astNode = stack.Pop();
            var subNode = domBuilder.BuildFromNode(astNode);
            CurrentNode.AddSubNode(astNode.Node, subNode);
        }

        public RuleSet GetResult() { return (RuleSet)CurrentNode.SubNodes[0].Value[0]; }
    }
}
