# JSON Lexer & parser
Written in JFLEX and CUP. Built according to the official ECMA-404 The JSON Data Interchange Standard (see json.org)

##Overview
This JSON parser will accept an input, and then check if this input is a valid JSON object according to the official JSON specification at http://json.org. It consists of two files which contain all the logic involved in identifying tokens (Scanner.jflex) and checking that these tokens are structured in the correct JSON format (Parser.cup).

##Quick start
Change current directory to ‘minimal’, build using ant and then execute Compiler.jar
cd minimal
ant jar
java -jar jar/Compiler.jar
<Type input/source file of JSON here>

##Specify input from a file
Inputs used to test this JSON parser can be found in the /tests folder which is located inside the minimal folder. Run the parser with one of these test files like this:
java -jar jar/Compiler.jar tests/Multiple_key_value_pairs.test

A list of all inputs in the tests folder with the results can be found in TestResults.pdf.

##Output – interpreting results
If the input is a valid JSON output, then nothing will be output from the console – this means the input was successfully parsed as a JSON object.

Otherwise, either an “illegal character” message will be displayed or a “Parse error” (or similar) will be thrown. This means, an invalid JSON object was inputted i.e. one that does not meet the official JSON specifications.

##How it works
###Scanner.jflex
This is where tokens are described using regular expressions. When the input is scanned and these tokens are detected, the appropriate symbol is returned which is used by Parser.cup
to define valid JSON objects.

At the top of Scanner.jflex, from Line 18 (after %eofval}), regular expressions are assigned to
macros. Macros are constructed to describe valid numbers in the JSON specification which
include 0, integers, floating point numbers and numbers using scientific notation such as
1.25e+3. A macro for a valid string is also created here which is a set of Unicode characters
except certain control characters preceded by a \ as defined by the JSON specification.
After all the appropriate macros are created, tokens are defined along with the appropriate
symbol that is returned when the token is found. First, certain enclosing or separating
symbols are scanned for such as commas, square brackets, braces and col
