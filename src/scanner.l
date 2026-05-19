%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
%}

%option yylineno
%option noyywrap

%%

"print"             { return PRINT; }
"if"                { return IF; }
"while"             { return WHILE; }
"endif"             { return ENDIF; }
"endwhile"          { return ENDWHILE; }

[a-zA-Z_][a-zA-Z0-9_]*  { return ID; }
[0-9]+(\.[0-9]+)?       { return NUMBER; }

"="                 { return '='; }
"+"                 { return '+'; }
"-"                 { return '-'; }
"*"                 { return '*'; }
"/"                 { return '/'; }
"("                 { return '('; }
")"                 { return ')'; }
":"                 { return ':'; }
";"                 { return ';'; }

"#[^\n]*"           { /* Ignore Python-style comments */ }
[ \t\r]+            { /* Ignore whitespace and carriage returns */ }
\n                  { /* Ignore newline. yylineno increments automatically */ }

.                   {
                        fprintf(stderr, "Error sintactico en la linea %d\n", yylineno);
                        exit(1);
                    }

%%
