%{
#include "sql_parser.tab.h"
#undef yywrap
int yywrap(void);

%}

%option noyywrap
%option case-insensitive


%%
"DELETE"    	{ printf("%s DELETE\n", yytext); return DELETE; }
"UPDATE"    	{ printf("%s UPDATE\n", yytext); return UPDATE; }
"CREATE"    	{ printf("%s CREATE\n", yytext); return CREATE; }
"TABLE"     	{ printf("%s TABLE\n", yytext);  return TABLE; }
"FROM"     	    { printf("%s FROM\n", yytext);  return FROM; }
"WHERE"     	{ printf("%s WHERE\n", yytext);  return WHERE; }
"PRIMARY KEY" 	{ printf("%s PRIMARY_KEY\n", yytext); return PRIMARY_KEY; }
"VARCHAR"		{ printf("%s DATATYPE\n", yytext); return DATATYPE; }
"DATE"			{ printf("%s DATATYPE\n", yytext); return DATATYPE; }
"INT"			{ printf("%s DATATYPE\n", yytext); return DATATYPE; }
"AND"           { printf("%s AND\n", yytext); return AND; }
"NOT"           { printf("%s NOT\n", yytext); return NOT; }
"OR"            { printf("%s OR\n", yytext); return OR; }
"="             { printf("%s EQ\n", yytext); return EQ; }
"!="            { printf("%s NE\n", yytext); return NE; }
"<"             { printf("%s LT\n", yytext); return LT; }
"<="            { printf("%s LE\n", yytext); return LE; }
">"             { printf("%s GT\n", yytext); return GT; }
">="            { printf("%s GE\n", yytext); return GE; }
"LIKE"          { printf("%s LIKE\n", yytext); return LIKE; }
"IN"            { printf("%s IN\n", yytext); return IN; }
"BETWEEN"       { printf("%s BETWEEN\n", yytext); return BETWEEN; }
","      		{ printf("%s COMMA\n", yytext); return COMMA; }
"("      		{ printf("%s LPAREN\n", yytext); return LPAREN; }
")"      		{ printf("%s RPAREN\n", yytext); return RPAREN; }
[0-9]+      	{ printf("%s NUMBER\n", yytext); return NUMBER; }
\"([^\\\n]|(\\.))*\" { yylval.strval = strdup(yytext); return STRING_VALUE; }
\'([^\\\n]|(\\.))*\' { yylval.strval = strdup(yytext); return STRING_VALUE; }
[A-Za-z_][A-Za-z0-9_]* 	{ yylval.strval = strdup(yytext); printf("%s IDENTIFIER\n", yytext); return IDENTIFIER; }
[ \t\n]     	{ /* ignore whitespace */ }
.           	{ printf("%s %s\n", yytext, yytext); }
%%


int yywrap() { return 1; }

