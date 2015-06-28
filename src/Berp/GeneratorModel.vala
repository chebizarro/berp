
namespace Berp
{
    public class GeneratorModel
    {
        public HashTable<int, State> States { get; private set; }
        public string Namespace { get; set; }
        public string ParserClassName { get; set; }
        public string TargetNamespace { get; set; }
        public string TargetClassName { get; set; }
        public RuleSet RuleSet { get; set; }

        public State EndState
        {
            get { return States.Values.FirstOrDefault(s => s.IsEndState); }
        }

        public GeneratorModel(HashTable<int, State> states)
        {
            States = states;
        }
    }
}
