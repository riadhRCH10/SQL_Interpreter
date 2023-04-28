%{
#include "sql_parser.tab.h"
#undef yywrap
int yywrap(void);


extern int yylineno;

int yylex(void);
void yyerror(const char*);

%}

%option noyywrap
%option case-insensitive


%%
"DELETE"    	{ printf("%s DELETE\n", yytext); return DELETE; } 
"SELECT"    	{ printf("%s SELECT\n", yytext); return SELECT; }
"UPDATE"    	{ printf("%s UPDATE\n", yytext); return UPDATE; }
"CREATE"    	{ printf("%s CREATE\n", yytext); return CREATE; }
"TABLE"     	{ printf("%s TABLE\n", yytext);  return TABLE; }
"LIMIT"     	{ printf("%s LIMIT\n", yytext);  return LIMIT; }
"FROM"     	    { printf("%s FROM\n", yytext);  return FROM; }
"UPDATE"     	{ printf("%s UPDATE\n", yytext);  return UPDATE; } 
"SET"     	    { printf("%s SET\n", yytext);  return SET; } 
"WHERE"     	{ printf("%s WHERE\n", yytext);  return WHERE; }
"ORDER BY"     	{ printf("%s ORDER-BY\n", yytext);  return ORDER_BY; }
"GROUP BY"     	{ printf("%s GROUP-BY\n", yytext);  return GROUP_BY; }
"AVG"     	    { printf("%s AVG\n", yytext);  return AVG; }
"COUNT"     	{ printf("%s COUNT\n", yytext);  return COUNT; }
"FIRST"     	{ printf("%s FIRST\n", yytext);  return FIRST; }
"LAST"      	{ printf("%s LAST\n", yytext);  return LAST; }
"MAX"       	{ printf("%s MAX\n", yytext);  return MAX; }
"MIN"     	    { printf("%s MIN\n", yytext);  return MIN; }
"SUM"     	    { printf("%s SUM\n", yytext);  return SUM; }
"UNIQUE"     	{ printf("%s UNIQUE\n", yytext);  return UNIQUE; }
"FOREIGN KEY"   { printf("%s FOREIGN KEY\n", yytext);  return FOREIGN_KEY; }
"REFERENCES"    { printf("%s REFERENCES\n", yytext);  return REFERENCES; }
"ON DELETE"     { printf("%s ON DELETE\n", yytext);  return ON_DELETE; }
"ON UPDATE"     { printf("%s ON UPDATE\n", yytext);  return ON_UPDATE; }
"CASCADE"     	{ printf("%s CASCADE\n", yytext);  return CASCADE; }
"SET NULL"     	{ printf("%s SET NULL\n", yytext);  return SET_NULL; }
"SET DEFAULT"   { printf("%s SET DEFAULT\n", yytext);  return SET_DEFAULT; }
"ASC"     	    { printf("%s ASC\n", yytext);  return ASC; }
"DESC"     	    { printf("%s DESC\n", yytext);  return DESC; }
"PRIMARY KEY" 	{ printf("%s PRIMARY_KEY\n", yytext); return PRIMARY_KEY; }
"VARCHAR"		{ printf("%s DATATYPE\n", yytext); return DATATYPE; }
"DECIMAL"		{ printf("%s DECIMAL\n", yytext); return DECIMAL; }
"INTEGER"		{ printf("%s DATATYPE\n", yytext); return DATATYPE; }
"DATE"			{ printf("%s DATATYPE\n", yytext); return DATATYPE; }
"INT"			{ printf("%s DATATYPE\n", yytext); return DATATYPE; }
"AND"           { printf("%s AND\n", yytext); return AND; }
"NOT"           { printf("%s NOT\n", yytext); return NOT; }
"OR"            { printf("%s OR\n", yytext); return OR; }
"AS"            { printf("%s AS\n", yytext); return AS; }
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
"*"      		{ printf("%s STAR\n", yytext); return STAR; }
"("      		{ printf("%s LPAREN\n", yytext); return LPAREN; }
")"      		{ printf("%s RPAREN\n", yytext); return RPAREN; }
[0-9]+      	{ printf("%s NUMBER\n", yytext); return NUMBER; }
\"[^\"]*\"      { printf("%s STRING\n", yytext); yylval.strval = strdup(yytext); return STRING_VALUE; }
\'[^\']*\'      { printf("%s STRING\n", yytext); yylval.strval = strdup(yytext); return STRING_VALUE; }
[A-Za-z_][A-Za-z0-9_]* 	{ yylval.strval = strdup(yytext); printf("%s IDENTIFIER\n", yytext); return IDENTIFIER; }
\n        { yylineno++; }
[ \t\n]     	{ /* ignore whitespace */ }
.           	{ printf("%s %s\n", yytext, yytext); }
%%


int yywrap() { return 1; }

