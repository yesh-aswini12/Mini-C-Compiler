%{
   #include "a3.tab.h"
   #include <bits/stdc++.h>
   #include <stdlib.h>
   using namespace std;
   void yyerror( string c);
   extern int l_count;
%}

%%
"$@"                        {return ABS;}
"@$"                        {return BAS;}
"retval"                    {return RETVAL;}
"global"                    {return GLOBAL;}
"goto"                      {return GOTO;}
"if"                        {return IF;}
"return"                    {return RETURN;}
"call"                      {return CALL;}
"local"                     {return LOCAL;}
"main:"                     {return MAIN;}
param[0-9]+                 {yylval.str = strdup(yytext);return PARAM;}
L[0-9]+:                    {yylval.str = strdup(yytext);return LABEL;}
L[0-9]+                     {yylval.str = strdup(yytext);return GOTO_LABEL;}
t[0-9]+                     {yylval.str = strdup(yytext);return TEMPORARY;}
[a-zA-Z_][a-zA-Z_0-9]*:     {yylval.str = strdup(yytext);return F_IDENTIFIER;}
[a-zA-Z_][a-zA-Z_0-9]*      {yylval.str = strdup(yytext);return IDENTIFIER;}
[0-9]+                      {yylval.val = atoi(yytext);return NUMBER;}
"+"                         {return ADD;}
"-"                         {return SUB;}
"*"                         {return MUL;}
"/"                         {return DIV;}
"("                         {return OP;}
")"                         {return CP;}
"["                         {return OB;}
"]"                         {return CB;}
">"                         {return GT;}
"<"                         {return LT;}
"="                         {return EQ;}
"!="                        {return NE;}
">="                        {return GE;}
"<="                        {return LE;}
"=="                        {return EQEQ;}
\"([^\"]|\\\")*\"           { yylval.str = strdup(yytext); return STR; }
\'([^\']|\\\'|\\0|\\\\|\\n)\'  { yylval.str = strdup(yytext); return C_CHAR; }
[\ \t]                      {}
[\n]                        {yylineno++;}
.                           {yyerror(strdup("Unknown Character"));}

%%

int yywrap(void){
   return 1;
}
