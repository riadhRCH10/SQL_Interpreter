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
%token EQ NE LT LE GT GE LIKE IN BETWEEN STRING_VALUE AND OR NOT STAR DECIMAL CONSTRAINT
%token SELECT ORDER_BY GROUP_BY ASC DESC LIMIT AVG COUNT FIRST LAST MAX MIN SUM 
%token UPDATE SET AS UNIQUE FOREIGN_KEY REFERENCES ON_DELETE ON_UPDATE CASCADE SET_NULL SET_DEFAULT

%%

query_statement: delete_statement
                | create_statement
                | select_statement
                | update_statement
                ;

/* update_statement */

update_statement: UPDATE IDENTIFIER SET operation_list WHERE condition_list { printf("la requête UPDATE est valide\n"); }
                | UPDATE IDENTIFIER error operation_list WHERE condition_list { printf("lexème 'SET' manquant\n"); }
                | UPDATE error SET operation_list WHERE condition_list { printf("Un nom de table est requis après le lexème 'UPDATE'\n"); }

operation_list: IDENTIFIER op value
              | IDENTIFIER IN value_list
              | IDENTIFIER op value COMMA operation_list
              | IDENTIFIER IN value_list COMMA operation_list

/* select_statement */

select_statement: SELECT select_list FROM table_list where_clause groupby_clause orderby_clause limit_clause {
                    printf("la requête SELECT est valide. Nombre de champs sélectionnés: %d\n", selected_field_count);
                    selected_field_count = 0;
                }
                | SELECT select_list error table_list where_clause groupby_clause orderby_clause limit_clause { printf("lexème 'FROM' manquant\n"); return 0; } 

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
                | function_call AS IDENTIFIER
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
             | AVG LPAREN args error { printf("parenthèse manquante\n"); return 0; } 
             | COUNT LPAREN args error { printf("parenthèse manquante\n"); return 0; }
             | SUM LPAREN args error { printf("parenthèse manquante\n"); return 0; }
             | FIRST LPAREN args error { printf("parenthèse manquante\n"); return 0; }
             | LAST LPAREN args error { printf("parenthèse manquante\n"); return 0; }
             | MIN LPAREN args error { printf("parenthèse manquante\n"); return 0; }
             | MAX LPAREN args error { printf("parenthèse manquante\n"); return 0; }
             ;

args: IDENTIFIER
    | STAR
    ;


/* delete_statement */

delete_statement: DELETE delete_list FROM table_list WHERE condition_list { printf("la requête DELETE est valide\n"); }
                ;

delete_list:  %empty 
            | IDENTIFIER
            | IDENTIFIER COMMA delete_list

condition_list: condition { }
               | condition_list OR condition { }
               | condition_list AND condition { }
               ;

condition: IDENTIFIER op value { }
          | IDENTIFIER IN value_list { }
          | IDENTIFIER BETWEEN value AND value
          | LPAREN condition RPAREN { }
          | LPAREN condition error { printf("parenthèse manquante\n"); return 0; }
          | NOT condition { }
          ;

op: EQ { }
  | NE { }
  | LT { }
  | LE { }
  | GT { }
  | GE { }
  | LIKE { }
  ;

value_list: LPAREN string_list RPAREN { }
          | LPAREN number_list RPAREN { }
          | LPAREN number_list error { printf("parenthèse manquante\n"); return 0; }
          | LPAREN string_list error { printf("parenthèse manquante\n"); return 0; }
          ;

value: STRING_VALUE { }
     | NUMBER { }
     ;

string_list: STRING_VALUE { }
           | STRING_VALUE COMMA string_list { }
           ;

number_list: NUMBER { }
           | NUMBER COMMA number_list { }
           ;

table_list: IDENTIFIER
          | IDENTIFIER IDENTIFIER
          | IDENTIFIER COMMA table_list
          | IDENTIFIER IDENTIFIER COMMA table_list
          | error { printf("Un nom de table est requis\n"); return 0; }

/* create_statement */

create_statement: CREATE TABLE IDENTIFIER LPAREN column_def_list RPAREN { printf("la requête CREATE est valide\n"); }
                | CREATE TABLE IDENTIFIER LPAREN column_def_list error { printf("parenthèse manquante\n"); return 0; }
                | CREATE TABLE error LPAREN column_def_list RPAREN { printf("Un nom de table est requis\n"); return 0; }
                ;

column_def_list: column_def { }
               | column_def_list COMMA column_def { }
               ;

column_def:   IDENTIFIER data_type { }
            | IDENTIFIER data_type PRIMARY_KEY { }
            | IDENTIFIER data_type REFERENCES IDENTIFIER LPAREN IDENTIFIER RPAREN { }
            | IDENTIFIER data_type REFERENCES IDENTIFIER LPAREN IDENTIFIER error { printf("parenthèse manquante\n"); return 0; }
            | primary_key_constraint { }
            | unique_constraint { }
            | foreign_key_constraint { }
            ;

primary_key_constraint: CONSTRAINT IDENTIFIER PRIMARY_KEY LPAREN IDENTIFIER RPAREN { }
                      | CONSTRAINT IDENTIFIER PRIMARY_KEY LPAREN IDENTIFIER error { printf("parenthèse manquante\n"); return 0; }
                      ;

unique_constraint: CONSTRAINT IDENTIFIER UNIQUE LPAREN IDENTIFIER RPAREN {}
                  | CONSTRAINT IDENTIFIER UNIQUE LPAREN IDENTIFIER error { printf("parenthèse manquante\n"); return 0; }
                 ;

foreign_key_constraint: CONSTRAINT IDENTIFIER FOREIGN_KEY IDENTIFIER REFERENCES IDENTIFIER LPAREN IDENTIFIER RPAREN   { }
                      | CONSTRAINT IDENTIFIER FOREIGN_KEY IDENTIFIER REFERENCES IDENTIFIER LPAREN IDENTIFIER error   { printf("parenthèse manquante\n"); return 0; }
                      ;

data_type: DATATYPE {}
        | DATATYPE LPAREN NUMBER RPAREN {}
        | DECIMAL LPAREN NUMBER COMMA NUMBER RPAREN {}
        | DATATYPE LPAREN NUMBER error { printf("parenthèse manquante\n"); return 0; }
        | DECIMAL LPAREN NUMBER COMMA NUMBER error { printf("parenthèse manquante\n"); return 0; }

%%

void yyerror(const char* s) {
    fprintf(stderr, "Syntax error on line %d \n", yylineno);
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
