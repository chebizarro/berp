
namespace Berp
{
    public class TokenType : Gee.Comparable<TokenType>, Object {
        public static TokenType EOF = new TokenType("EOF");
        public static TokenType Other = new TokenType("Other");

        public string Name { get; private set; }

        public TokenType(string name)
        {
            Name = name;
        }

        public int CompareTo(TokenType other)
        {
            //return String.Compare(Name, other.Name, StringComparison.Ordinal);
			return strcmp (Name, other.Name);
        }

        public string ToString()
        {
            return Name;
        }

        public int compare_to(TokenType other)
        {
            return strcmp (Name, other.Name);
        }

        public int Equals(Object obj)
        {
            //if (ReferenceEquals(null, obj)) return false;
            //if (ReferenceEquals(this, obj)) return true;
            //if (obj.GetType() != GetType()) return false;
            return compare_to ((TokenType) obj);
        }

        public uint GetHashCode()
        {
            return Name.hash ();
        }
    }
}
