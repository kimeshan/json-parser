# JSON Lexer & Parser 🌐
 ![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)
 ![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)
 
Written in JFLEX and CUP. Built according to the official ECMA-404 The JSON Data Interchange Standard (see http://json.org)

## Overview
This JSON parser will accept an input, and then check if this input is a valid JSON object according to the official JSON specification at http://json.org. It consists of two files which contain all the logic involved in identifying tokens (Scanner.jflex) and checking that these tokens are structured in the correct JSON format (Parser.cup).

## Requirements
You need to install Java and Ant in order to run JSONParser.

## Quick start
Clone this repository. Build using ant and then execute Compiler.jar using the following commands:

```
ant jar
java -jar jar/Compiler.jar
<Type input/source file of JSON here>

```

## Specify input from a file
Inputs used to test this JSON parser can be found in the /tests folder. Run the parser with one of these test files like this:

```
java -jar jar/Compiler.jar tests/Multiple_key_value_pairs.test

```

A list of all inputs in the tests folder with the results can be found in TestResults.pdf.

## Output – interpreting results
If the input is a valid JSON output, then nothing will be output from the console – this means the input was successfully parsed as a JSON object.

Otherwise, either an “illegal character” message will be displayed or a “Parse error” (or similar) will be thrown. This means, an invalid JSON object was inputted i.e. one that does not meet the official JSON specifications.

## Building a JSON Lexer and Parser: How it works
### Scanner.jflex (inside Scanner folder)
This is where tokens are described using regular expressions. When the input is scanned and these tokens are detected, the appropriate symbol is returned which is used by Parser.cup (inside Parser folder) to define valid JSON objects.

```
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

//Accept any unicode character except certain control characters
string = [^(\\)(\")(\/)(\b)(\f)(\n)(\r)(\t)(\u)]+
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
```

In the above code, regular expressions are assigned to macros. Macros are constructed to describe valid numbers in the JSON specification which include 0, integers, floating point numbers and numbers using scientific notation such as 1.25e+3. A macro for a valid string is also created here which is a set of Unicode characters except certain control characters preceded by a \ as defined by the JSON specification. After all the appropriate macros are created, tokens are defined along with the appropriate symbol that is returned when the token is found. First, certain enclosing or separating symbols are scanned for such as commas, square brackets, braces and colons. These symbols form the skeleton of a JSON object and form its structure.

Scanning is then done for the various possible JSON values (often using the {macros}) which are:
* Strings
* Boolean (true/false) values
* Null, {} values
* Numbers: 0, integer, real numbers, scientific notation

Lastly, white space tokens are ignored and no symbol is returned when a whitespace such asa new line or tab is detected when scanning.

### Parser.cup (inside Parser folder)
The following terminals are declared based on the symbols return from Scanner.jflex:
* COMMA, COLON, LSQBRACKET, RSQBRACKET, LBRACE, RBRACE
* NUMBER (Integer)
* STRING (String)
* BOOLEAN (Boolean)
* NULL.

```
//Terminals declared for commas, colon, square brackets and braces
terminal COMMA, COLON, LSQBRACKET, RSQBRACKET, LBRACE, RBRACE;

//Integer, String and Boolean terminals declared
terminal Integer NUMBER;
terminal String STRING;
terminal Boolean BOOLEAN;

//terminal declared for null
terminal NULL;
```
The following non-terminals are include:
• object
• pair_list
• pair
• json_value
• array
• value_list

```
//non terminals declared
non terminal object, pair_list, pair, json_value, array, value_list;

//A valid JSON object can be {} or a { list of pairs } where pair is key:value pair
object::= LBRACE RBRACE | LBRACE pair_list RBRACE;

//A valid pair list can be one pair(key:value) or a list of comma separated pairs (e.g. {}"name":bob, "age":2})
pair_list::= pair_list COMMA pair| pair;

//A valid key-value pair is in the format of STRING:value
pair::= STRING COLON json_value;

//One type of JSON value is an array which is a value list enclosed in square brackets
array ::= LSQBRACKET value_list RSQBRACKET;

//Avalue list is either one value or multiple values separted by commas
value_list ::= value_list COMMA json_value | json_value;

//A valid value in JSON is a string("hello"), number(5.45), boolean(true), null, array([1,2]) or object ({"age":20})
json_value::= STRING | NUMBER | BOOLEAN | NULL | array | object;
```
First, a high level JSON object is defined: { } or { pair_list }, a set of braces either empty or containing a list of key_value pairs.

A pair_list is then defined as a single key value pair or multiple key-value pairs separated by
commas.

A key-value pair is defined as a STRING: json_value, where a json_value is defined as one of
the following:
* STRING
* NUMBER BOOLEAN
* NULL
* Array
* Object (recursive)

Lastly, an array is defined as a value_list enclosed by square brackets where a value_list is
finally defined as either a single json_value or multiple, comma-separated json_value’s.
Ultimately, these terminals and non-terminals allow the parser to determine if the input
contains tokens that are structured according to the JSON specification.
