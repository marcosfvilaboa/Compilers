import java_cup.runtime.Symbol;

%%
%{
    public int getLine() {
        return yyline;
    }
%}
%cup
%full
%class circuit
%line
%ignorecase


%state COMMENT, STRING

blank=[\n\t\r ]

digit=[0-9]
hexadigit=[0-9a-fA-F]

number={digit}+
hexanumber=0[Xx]{hexadigit}+

identifier=[A-Za-z][A-Za-z0-9_-]*

%%

<YYINITIAL>{blank}+	{ /* Do nothing */ }
<YYINITIAL>circuit	{ parser.correct_reserved_words++; return new Symbol (sym.CIRCUIT);}
<YYINITIAL>signal	{ parser.correct_reserved_words++; return new Symbol (sym.SIGNAL);}
<YYINITIAL>size		{ parser.correct_reserved_words++; return new Symbol (sym.SIZE);}
<YYINITIAL>equals	{ parser.correct_reserved_words++; return new Symbol (sym.EQUALS);}
<YYINITIAL>block	{ parser.correct_reserved_words++; return new Symbol (sym.BLOCK);}
<YYINITIAL>description	{ parser.correct_reserved_words++; return new Symbol (sym.DESCRIPTION);}
<YYINITIAL>input	{ parser.correct_reserved_words++; return new Symbol (sym.INPUT); }
<YYINITIAL>output	{ parser.correct_reserved_words++; return new Symbol (sym.OUTPUT);}
<YYINITIAL>begin	{ parser.correct_reserved_words++; return new Symbol (sym.BEGIN); }
<YYINITIAL>end		{ parser.correct_reserved_words++; return new Symbol (sym.END);  }
<YYINITIAL>local	{ parser.correct_reserved_words++; return new Symbol (sym.LOCAL); }
<YYINITIAL>and		{ parser.correct_reserved_words++; return new Symbol (sym.AND); }
<YYINITIAL>or		{ parser.correct_reserved_words++; return new Symbol (sym.OR); }
<YYINITIAL>not		{ parser.correct_reserved_words++; return new Symbol (sym.NOT); }
<YYINITIAL>{number} 	{ return new Symbol (sym.NUMBER); }
<YYINITIAL>{hexanumber} { return new Symbol (sym.HEXANUMBER); }
<YYINITIAL>{identifier} { parser.correct_identifiers++; return new Symbol (sym.ID);}
<YYINITIAL>\" 		{ yybegin(STRING); }
<YYINITIAL>// 		{ yybegin(COMMENT); }
<YYINITIAL>=		{ return new Symbol (sym.EQUALSIGN); }
<YYINITIAL>;		{ return new Symbol (sym.SEMICOLON); }
<YYINITIAL>\(		{ return new Symbol (sym.OPEN_BRK); }
<YYINITIAL>\)		{ return new Symbol (sym.CLSE_BRK); }
<YYINITIAL>.		{ System.out.println("Error at line " + (yyline+1) + ": Unrecognized character"); }

<STRING>[a-zA-Z0-9]+ 	{ /* Do nothing, parsing a string */ }
<STRING>[\t ]+		{ /* Do nothing, parsing a string */ }
<STRING>\" 		{ parser.correct_strings++;  yybegin(YYINITIAL); return new Symbol (sym.STRING);}
<STRING>[\n\r]		{ System.out.println("Error at line " + (yyline+1) +": new line character found"); yybegin(YYINITIAL); return new Symbol (sym.STRING); }
<STRING>.		{ System.out.println("Error at line " + (yyline+1) +": Unrecognized character"); }

<COMMENT>[\n\r]		{ yybegin(YYINITIAL); }
<COMMENT>.		{ /* Do nothing */ }
