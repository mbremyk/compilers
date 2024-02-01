%{
#include <vslc.h>
// The tokens defined in parser.y
#include "y.tab.h"
%}
%option noyywrap
%option array
%option yylineno

WHITESPACE [\ \t\v\r\n]
COMMENT \/\/[^\n]+
QUOTED \"([^\"\n]|\\\")*\"
%%
{WHITESPACE}+           { /* Eliminate whitespace */ }
{COMMENT}               { /* Eliminate comments */ }
{QUOTED}                { return STRING; }
func                    { return FUNC; }
begin|\{                { return OPENBLOCK; }
end|\}                  { return CLOSEBLOCK; }
return                  { return RETURN; }
print                   { return PRINT; }
break                   { return BREAK; }
if                      { return IF; }
then                    { return THEN; }
else                    { return ELSE; }
while                   { return WHILE; }
do                      { return DO; }
for                     { return FOR; }
in                      { return IN; }
var                     { return VAR; }
[\d]+                   { return NUMBER; }
[a-zA-Z][\w]*           { return IDENTIFIER; }
.                       { return yytext[0]; }
%%
