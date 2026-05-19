%{
#include <stdio.h>
#include <stdlib.h>

extern int yylineno;
extern int yylex(void);
void yyerror(const char *s);
%}

%token ID NUMBER PRINT IF WHILE ENDIF ENDWHILE
%token LE GE EQ NE

%left EQ NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/'

%%

program : statements
        ;

statements : /* empty */
           | statements statement
           ;

statement : assignment
          | print_stmt
          | if_stmt
          | while_stmt
          ;

assignment : ID '=' expr ';'
           | ID '=' expr
           ;

print_stmt : PRINT '(' expr ')' ';'
           | PRINT '(' expr ')'
           ;

if_stmt : IF expr ':' statements ENDIF
        ;

while_stmt : WHILE expr ':' statements ENDWHILE
           ;

expr : expr '+' expr
     | expr '-' expr
     | expr '*' expr
     | expr '/' expr
     | expr '<' expr
     | expr '>' expr
     | expr LE expr
     | expr GE expr
     | expr EQ expr
     | expr NE expr
     | '(' expr ')'
     | ID
     | NUMBER
     ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico en la linea %d\n", yylineno);
    exit(1);
}
