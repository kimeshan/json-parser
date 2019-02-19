package Example;

import java_cup.runtime.SymbolFactory;
%%
%cup
%class Scanner
%{
	public Scanner(java.io.InputStream r, SymbolFactory sf){
		this(r);
		this.sf=sf;
	}
	private SymbolFactory sf;
%}
%eofval{
    return sf.newSymbol("EOF",sym.EOF);
%eofval}

//Let's build a regular expression for any real number
digit = [0-9]
non_zero_digit = [1-9]
integer = -?(0|{non_zero_digit}{digit}*)

//Include real numbers (floating point) and scientific notation
dot = ["."]
exp = (e|E)("+"|-)
frac = {dot}{digit}+
scientific_notation = {exp}{digit}+
any_number = {integer}{frac}?{scientific_notation}?

// Accept zero (empty string) or more valid characters (i.e. any UNICODE
// character except for unescaped quotation marks ("), backslashes (\), or
// control characters /u0000 through to /u001f) or valid escape sequences
string = ([^\u0000-\u001F\"\\]|(\\([\"\\/bfnrt]|(u([0-9a-fA-F]{4})))))*

%%

//Scan for commas, square brackets, braces and colons
"," { return sf.newSymbol("Comma",sym.COMMA); }
"[" { return sf.newSymbol("Left Square Bracket",sym.LSQBRACKET); }
"]" { return sf.newSymbol("Right Square Bracket",sym.RSQBRACKET); }
"{" { return sf.newSymbol("Left Brace", sym.LBRACE);}
"}" { return sf.newSymbol("Right Brace", sym.RBRACE);}
":" { return sf.newSymbol("Colon", sym.COLON);}

//Scan for unicode strings: letters, numbers, symbols
\"{string}\" { return sf.newSymbol("Unicode String", sym.STRING, new String(yytext()));}

//Scan for boolean strings
"true"|"false" { return sf.newSymbol("Boolean True", sym.BOOLEAN, new Boolean(yytext()));}

Scan for null strings
"null" { return sf.newSymbol("Null Symbol", sym.NULL);}

//Scan for numbers: 0, integers or real numbers (floating point)
{any_number} { return sf.newSymbol("Integral Number",sym.NUMBER, new Double(yytext())); }
[ \t\r\n\f] { /* ignore white space. */ }
. { System.err.println("Illegal character: "+yytext()); }
