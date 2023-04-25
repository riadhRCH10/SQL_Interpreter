%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
extern int yylex();
extern int yylineno;

void yyerror(const char* s);
int yyparse();

int valid_create = 1;
%}

%union {
    char* strval;
}

%token <strval> IDENTIFIER
%token CREATE TABLE LPAREN RPAREN COMMA SEMICOLON INT VARCHAR DELETE FROM WHERE UPDATE PRIMARY_KEY DATATYPE NUMBER
%token EQ NE LT LE GT GE LIKE IN BETWEEN STRING_VALUE AND OR NOT

%%

query_statement: delete_statement
                | create_statement

/* delete_statement */

delete_statement: DELETE FROM IDENTIFIER WHERE condition_list { printf("delete query valid\n"); }
                ;

condition_list: condition { }
               | condition_list OR condition { }
               | condition_list AND condition { }
               ;

condition: IDENTIFIER op value { }
          | LPAREN condition RPAREN { }
          | NOT condition { }
          ;

op: EQ { }
  | NE { }
  | LT { }
  | LE { }
  | GT { }
  | GE { }
  | LIKE { }
  | IN { }
  | BETWEEN { }
  ;

value: STRING_VALUE { }
     | NUMBER { }
     | IDENTIFIER { }
     | LPAREN value_list RPAREN { }
     ;

value_list: value { }
           | value COMMA value_list { }
           ;

/* create_statement */

create_statement: CREATE TABLE IDENTIFIER LPAREN column_def_list RPAREN { printf("create query valid\n"); }
                ;

column_def_list: column_def { }
               | column_def_list COMMA column_def { }
               ;

column_def: IDENTIFIER DATATYPE { }
            | IDENTIFIER DATATYPE PRIMARY_KEY { }
          ;


%%

void yyerror(const char* s) {
    fprintf(stderr, "Syntax error on line %d: %s\n", yylineno, s);
}

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        printf("Error opening input file: %s\n", argv[1]);
        return 1;
    }

    yyparse();

    if (valid_create) {
        //printf("CREATE query is valid!\n");
    } else {
        //printf("CREATE query is invalid!\n");
    }

    fclose(yyin);
    return 0;
}