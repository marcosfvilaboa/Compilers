import java.io.*;
import java.util.*;

// class for constructor and getter of symbol table elements
class circuitTableElem {
	private String elem;
	private String elemType;
	private Integer freq;

	public circuitTableElem (String E, String T) {
		elem = new String(E);
		elemType = new String(T);
		freq = new Integer(1);
	}

	public String getElemType() {
		return this.elemType;
	}
	public Integer getFreq() {
		return this.freq;
	}
	public void incFreq() {
		this.freq++;
	}
}

// class to process the symbol table 
class CircuitTable extends Hashtable<String, circuitTableElem> { 
	
	public void add(String E, String T) {
		String key = new String(E);
		if (this.containsKey(key))
			this.get(key).incFreq();
		else
			this.put(key, new circuitTableElem(key,T));
		
	}

	// Show stats
	public void showStats() {
		Enumeration en;
		circuitTableElem el;

		// Counters by type
		Integer stringsNum = 0;
		Integer wordsNum = 0;
		Integer identifiersNum = 0;
		Integer semicolonNum = 0;
		Integer equalNum = 0;
		Integer openBrNum = 0;
		Integer closeBrnNum = 0;		
		Integer decimalsNum = 0;
		Integer hexadsNum = 0;
	
		for (en=this.elements();en.hasMoreElements();) {
			el = (circuitTableElem)en.nextElement();

			// Increment frequnecy. For exercise only use Strings, Words and Id. We choose 'switch'
			// instead of 'if' for future improvements. 
			// So, we need all types in it to avoid jump to default.
			switch (el.getElemType()) {
				case "TYPE_STR":					
					stringsNum = stringsNum + el.getFreq();					
					break;
				case "TYPE_WRD":
					wordsNum = wordsNum + el.getFreq();
					break;
				case "TYPE_ID":
					identifiersNum = identifiersNum + el.getFreq();
					break;
				case "SEMICOLON":
					semicolonNum = semicolonNum + el.getFreq();
					break;
				case "EQUAL":
					equalNum = equalNum + el.getFreq();
					break;
				case "OPEN_BRK":
					openBrNum = openBrNum + el.getFreq();
					break;
				case "CLSE_BRK":
					closeBrnNum = closeBrnNum + el.getFreq();
					break;
				case "NUM_DEC":
					decimalsNum = decimalsNum + el.getFreq();
					break;
				case "NUM_HEX":
					hexadsNum = hexadsNum + el.getFreq();
					break;			
				default:
					throw new IllegalArgumentException("Invalid type: " + el.getElemType());
			}
		}

		System.out.println ("\nStats");
		System.out.println ("------");
		System.out.println ("Strings: " + stringsNum);
		System.out.println ("Reserved words: " + wordsNum);
		System.out.println ("Identifiers: " + identifiersNum);
	}
}
%%
%{
	static CircuitTable table = new CircuitTable();

	public static void main (String argv[]) throws java.io.IOException {

		// Control of the parameters
		// catch number of arguments		
		if (argv.length != 1) {
			System.out.println ("ERROR: Incorrect number of parameters!");
			System.out.println ("\r\nUsage: \r\n java circuit FILENAME.EXT");
			return;
		} else { 
			// Control of the filename extension
			String fileName = argv[0].toUpperCase();
			if (!fileName.endsWith(".CIR")){
				System.out.println ("Input file extension must be \".CIR\"");
				return;
			}
		}
				
		// Read the tokens using new name of Yylex class --> 'circuit' 
		circuit yy = new circuit(new FileInputStream (argv[0]));
		while (yy.yylex() != -1);
		
		// show statistics
		table.showStats();
	}
%}
%integer
%ignorecase
%line
%class circuit

%state typeSTR
%%

<YYINITIAL>[\t\n\r\b ]+		{ /* - */ }

<YYINITIAL>CIRCUIT|SIGNAL|SIZE|EQUALS|BLOCK|DESCRIPTION|INPUT|OUTPUT|BEGIN|END|LOCAL|AND|OR|NOT {
							  table.add(yytext().toUpperCase(),"TYPE_WRD");	
							}
<YYINITIAL>;				{ table.add(yytext(),"SEMICOLON"); }
<YYINITIAL>=				{ table.add(yytext(),"EQUAL"); }
<YYINITIAL>\(				{ table.add(yytext(),"OPEN_BRK"); }
<YYINITIAL>\)				{ table.add(yytext(),"CLSE_BRK"); }
<YYINITIAL>[a-z][a-z0-9_-]*	{ table.add(yytext(),"TYPE_ID"); }
<YYINITIAL>(0[0-9]*)|[0-9]+	{ table.add(yytext(),"NUM_DEC"); }
<YYINITIAL>0x[0-9a-f]+		{ table.add(yytext(),"NUM_HEX"); }
<YYINITIAL>\"				{ yybegin(typeSTR); }
<YYINITIAL>//.+				{ /* - */ }

<typeSTR>[a-z0-9\t ]+		{ table.add(yytext(),"TYPE_STR"); }

<typeSTR>\"					{ yybegin(YYINITIAL); }
<typeSTR>[a-z0-9\t ]+[\n\r]	{	
							 System.out.println ("Error at line " + (yyline+1) + ": new line character found");
							 yybegin(YYINITIAL);
							}
<typeSTR>.					{ System.out.println ("Error at line " + (yyline+1) + ": Unrecognized character");}

<YYINITIAL>.				{ System.out.println ("Error at line " + (yyline+1) + ": Unrecognized character");}