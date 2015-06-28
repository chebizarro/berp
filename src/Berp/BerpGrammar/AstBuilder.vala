using Gee;

namespace Berp.BerpGrammar
{
	
	public struct KeyValuePair<K,V> {
		private K Key { get; private set;}
		private V @Value { get; set;}
	}

	
    public class AstBuilder : IAstBuilder
    {
        public class AstNode
        {
            public RuleType Node { get; set; }
            public ArrayList<KeyValuePair<RuleType, ArrayList<Object>>> SubNodes { get; set; }

			
            public Gee.Iterable<Object> GetSubNodesOf(RuleType ruleType)
            {
                return SubNodes.foreach((sn) => {sn.Key == ruleType;}).SelectMany(sn => sn.Value);
            }

            public Gee.Iterable<Object> GetAllSubNodes()
            {
                return SubNodes.SelectMany(sn => sn.Value);
            }

			
            public void AddSubNode(RuleType nodeName, Object subNode)
            {
                if (SubNodes.size > 0) {
					
                    var lastSubNode = SubNodes.get(SubNodes.size - 1);
					
                    if (lastSubNode.Key == nodeName)
                    {
                        lastSubNode.Value = subNode;
                        return;
                    }
                }
				ArrayList<Object> subNodes = new ArrayList<Object> ();
				subNodes.add (subNode);
                SubNodes.add (KeyValuePair<RuleType, List<Object>> (nodeName, subNodes));
            }

            public AstNode()
            {
                SubNodes = new ArrayList<KeyValuePair<RuleType, ArrayList<Object>>>();
            }

            public override string ToString()
            {
                return string.Format("<{0}>{1}</{0}>", Node, string.Join(", ", SubNodes.Select(sn =>
                    string.Format("[{0}:{1}]", sn.Key, string.Join(", ", sn.Value.Select(v => v.ToString()))))));
            }
        }


        private DomBuilder domBuilder = new DomBuilder();
        private Gee.LinkedList<AstNode> stack = new Gee.LinkedList<AstNode>();
        public AstNode CurrentNode { get { return stack.peek(); } }

        public AstBuilder()
        {
			AstNode node = new AstNode ();
			node.Node = RuleType.None;
            stack.push(node);
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
			stack.push(new AstNode ().Node = node);
        }

        public void EndRule(RuleType node)
        {
            Pop();
        }

        public void Pop()
        {
            var astNode = stack.pop();
            var subNode = domBuilder.BuildFromNode(astNode);
            CurrentNode.AddSubNode(astNode.Node, subNode);
        }

        public RuleSet GetResult() { return (RuleSet)CurrentNode.SubNodes[0].Value[0]; }
    }
}
