namespace Berp
{
	public class Options : GLib.Object {

		public string GetUsage()
		{
			var help = GetHeader();
			help.AddPreOptionsLine(string.Empty);
			help.AddPreOptionsLine("Usage: berp.exe -g grammar.berp -t template.razor -o parseroutpout [-d]");
			help.AddPreOptionsLine("	   Check details at https://github.com/gasparnagy/berp");
			help.AddOptions(this);
			return help;
		}

		public HelpText GetHeader()
		{
			var help = new HelpText
			{
				Heading = HeadingInfo.Default,
				Copyright = CopyrightInfo.Default,
				AdditionalNewLineAfterOption = false,
				AddDashesToOption = true
			};
			help.AddPreOptionsLine(string.Empty);
			help.AddPreOptionsLine("Licensed under the Apache License, Version 2.0 (the \"License\")");
			help.AddPreOptionsLine("	http://www.apache.org/licenses/LICENSE-2.0");
			return help;
		}
	}

	class Main : Object {

		private static string template;
		private static string grammar;
		private static string? output_file = null;
		private static string? diagnostics_mode = null;

		private const OptionEntry[] option_entries = {
			{ "template", 't', 0, OptionArg.FILENAME, ref template, N_("Template (.razor) file for generation."), "FILE" },
			{ "grammar", 'g',  0, OptionArg.FILENAME, ref grammar, N_("Grammar (.berp) file for generation."), "FILE" },
			{ "output", 'o',  0, OptionArg.FILENAME, ref output_file, N_("Generated parser class file."), "FILE" },
			{ null, 'd',  0, OptionArg.STRING, ref diagnostics_mode, N_("Print details during execution."), null },
			{ null }
		};
				
		public static int main(string[] args) {
			try {
				var opt_context = new OptionContext ();
				opt_context.set_help_enabled (true);
				opt_context.add_main_entries (option_entries, null);
				opt_context.parse (ref args);
			} catch (OptionError e) {
				stdout.printf ("error: %s\n", e.message);
				if (diagnostics_mode != null) {
					stderr.printf ("error code: %" + uint32.FORMAT + "\n", e.code);					
					stderr.printf ("error domain: %" + uint32.FORMAT + "\n", e.domain);					
				}
				stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
				return 0;
			}
			
			generate_parser_internal ();
			
		}
		
		private static void generate_parser_internal () {
			// get_header ();
			
			stdout.printf ("Generating parser for grammar '%s' using template '%s'.\n", grammar, template);
			stdout.puts ("Loading grammar...\n");
			
			var grammar_file = new File.new_for_path (grammar);
			var grammarDefinition = grammar_file.get_contents ();
			var parser = new BerpGrammar.Parser();
			var ruleSet = parser.Parse(new TokenScanner(new StringReader(grammarDefinition)));

			int tokenCount = ruleSet.Count(r => r is TokenRule);
			
			stdout.printf ("The grammar was loaded with %i tokens and %i rules.\n", tokenCount, ruleSet.Count() - tokenCount);

			if (diagnostics_mode) {
				stdout.puts (ruleSet.ToString(true));
				stdout.puts ("---------------\n");
			}

			stdout.puts ("Calculating parser states...\n");
			var states = StateCalculator.CalculateStates(ruleSet);

			stdout.printf ("%i states calculated for the parser.\n", states.Count);

			if (diagnostics_mode) {
				foreach (var state in states.Values) {
					PrintStateTransitions(state);
					PrintStateBranches(state.Branches, state.Id);
				}
			}

			stdout.puts ("Generating parser class...");
			var generator = new Generator(ruleSet.GetSetting("Namespace", "ParserGen"), ruleSet.GetSetting("ClassName", "Parser"), ruleSet.GetSetting("TargetNamespace", null), ruleSet.GetSetting("TargetClassName", "Ast"));
			generator.Generate(options.Template, ruleSet, states, options.OutputFile);
		}
		
		private static void PrintStateTransitions(State state) {
			stdout.printf ("%i: %i", state.Id, state.Comment);
			foreach (var transition in state.Transitions) {
				stdout.printf ("	%i -> %i", transition.TokenType, transition.TargetState);
			}
		}

		private static void PrintStateBranches(List<Branch> branches, int state) {
			stdout.printf ("%i:", state);
			stdout.puts ("\n");
			foreach (var branch in branches.OrderBy(b => b.TokenType))
			{
				stdout.printf ("	%i", branch);
				stdout.printf ("	\t%i", branch.GetProductionsText());
			}
		}
	}
}
