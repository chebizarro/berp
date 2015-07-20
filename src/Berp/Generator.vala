
namespace Berp
{
    class Generator
    {
        private string ns;
        private string className;
        private string targetNamespace;
        private string targetClassName;

        public Generator(string ns, string className, string targetNamespace, string targetClassName)
        {
            this.ns = ns;
            this.className = className;
            this.targetNamespace = targetNamespace ?? ns;
            this.targetClassName = targetClassName;
        }

        public void Generate(string templatePath, RuleSet ruleSet, HashTable<int, State> states, string outputPath)
        {
            string template = File.ReadAllText(templatePath);

            var model = new GeneratorModel(states)
            {
                Namespace = ns,
                ParserClassName = className,
                TargetNamespace = targetNamespace,
                TargetClassName = targetClassName,
                RuleSet = ruleSet
            };

            string result = Razor.Parse(template, model);

			if(FileUtils.test(outputPath, FileTest.EXISTS)) {
				string content;
				FileUtils.get_contents(outputPath, content);
				if (content == result) {
					stdout.puts("Parser class up-to-date.\n");
					return;
				}
			}
			
            FileUtils.set_contents(outputPath, result);
            stdout.printf("Parser class generated to '%s'.\n", outputPath);
        }
    }
}
