%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
extern int yylex();
extern int yylineno;

void yyerror(const char* s);
int yyparse();

//int valid_create = 1;
int selected_field_count = 0;
%}

%union {
    char* strval;
}

%token <strval> IDENTIFIER
%token CREATE TABLE LPAREN RPAREN COMMA SEMICOLON INT VARCHAR DELETE FROM WHERE PRIMARY_KEY DATATYPE NUMBER
%token EQ NE LT LE GT GE LIKE IN BETWEEN STRING_VALUE AND OR NOT STAR 
%token SELECT ORDER_BY GROUP_BY ASC DESC LIMIT AVG COUNT FIRST LAST MAX MIN SUM 
%token UPDATE SET

%%

query_statement: delete_statement
                | create_statement
                | select_statement
                | update_statement
                ;

/* update_statement */

update_statement: UPDATE IDENTIFIER SET operation_list WHERE condition_list { printf("update query valid\n"); }

operation_list: IDENTIFIER operation value
              | IDENTIFIER operation value COMMA operation_list

operation: EQ 
         | STAR

/* select_statement */

select_statement: SELECT select_list FROM IDENTIFIER where_clause groupby_clause orderby_clause limit_clause {
                    printf("select request valid. Selected field count: %d\n", selected_field_count);
                    selected_field_count = 0;
                }

where_clause: %empty | WHERE condition_list
    ;

groupby_clause: %empty | GROUP_BY identifier_list
    ;

orderby_clause: %empty | ORDER_BY identifier_list order_direction
    ;

order_direction: %empty | ASC | DESC
    ;

limit_clause: %empty | LIMIT NUMBER
    ;

select_list_item: IDENTIFIER
                {
                    selected_field_count++;
                }
                | IDENTIFIER '.' IDENTIFIER
                {
                    selected_field_count++;
                }
                | function_call
                ;

select_list: STAR
           | select_list_item
           | select_list COMMA select_list_item
           ;

identifier_list: IDENTIFIER
                | STAR
                | function_call
                | IDENTIFIER COMMA identifier_list
                ;

function_call: AVG LPAREN args RPAREN
             | COUNT LPAREN args RPAREN
             | SUM LPAREN args RPAREN
             | FIRST LPAREN args RPAREN
             | LAST LPAREN args RPAREN
             | MIN LPAREN args RPAREN
             | MAX LPAREN args RPAREN
             ;

args: args COMMA NUMBER
    | NUMBER
    | STAR
    ;


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

    //if (valid_create) {
        //printf("CREATE query is valid!\n");
    //} else {
        //printf("CREATE query is invalid!\n");
    //}

    fclose(yyin);
    return 0;
}
