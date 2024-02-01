%{
#include <vslc.h>

#define NODE_INIT(node, type, data, n_children, ...) \
  node_init(node = malloc(sizeof(node_t)), type, data, n_children, __VA_ARGS__)

/* State variables from the flex generated scanner */
extern int yylineno; // The line currently being read
extern char yytext[]; // The text of the last consumed lexeme
/* The main flex driver function used by the parser */
int yylex ( void );
/* The function called by the parser when errors occur */
int yyerror ( const char *error )
{
    fprintf ( stderr, "%s on line %d\n", error, yylineno );
    fprintf(stderr, "%s\n", yytext);
    exit ( EXIT_FAILURE );
}

%}

%define api.value.type {node_t*}

%left '+' '-'
%left '*' '/'
%right UMINUS

%token FUNC PRINT RETURN BREAK IF THEN ELSE WHILE FOR IN DO OPENBLOCK CLOSEBLOCK
%token VAR NUMBER IDENTIFIER STRING

%%
program:
      global_list {
        NODE_INIT(root, PROGRAM, NULL, 1, $1);
      }
    ;

global_list:
      global {                                          // global_list -> global
        NODE_INIT($$, GLOBAL_LIST, NULL, 1, $1);       // $1 = GLOBAL
      }
    | global_list global {                              // global_list -> global_list global
        NODE_INIT($$, GLOBAL_LIST, NULL, 2, $1, $2);
      }
    ;

/*
    TODO:
    Include the remaining modified VSL grammar as specified in PS2 - starting with `global`

    HINT:
    Recall that 'node_init' takes any number of arguments where:
    1. Node to initialize.
    2. Node type (see "include/nodetypes.h").
    3. Data (so far, no nodes need any data, but consider e.g. the NUMBER_DATA or IDENTIFIER_DATA node types - what data should these contain?).
    4. Number of node children.
    5->. Children - Note that these are constructed by other semantic actions (e.g. `program` has one child that is constructed by the `global_list semantic action).
    This should be a pretty large file when you are done.

    HINT (OPTIONAL):
    Note that mallocing and initializing of nodes happens a lot.
    You may want to create C macros to reduce redundancy.
*/

global: 
      function {}
    | declaration {}
    | array_declaration {}
    ;

declaration:
      VAR variable_list {}
      ;

variable_list:
      identifier
    | variable_list ',' identifier {}
    ;

array_declaration:
      VAR array_indexing {}
    ;

array_indexing:
      identifier '[' expression ']' {}
      ;

function:
      FUNC identifier '(' parameter_list ')' statement {}

parameter_list:
      /* Empty */
      | variable_list {}
      ;

statement:
      assignment_statement {}
      | return_statement {}
      | print_statement {}
      | if_statement {}
      | while_statement {}
      | for_statement {}
      | break_statement {}
      | block {}
      ;

block:
  OPENBLOCK declaration_list statement_list CLOSEBLOCK {}
  | OPENBLOCK statement_list CLOSEBLOCK {}
  ;

declaration_list:
  declaration {}
  | declaration_list declaration {}
  ;

statement_list:
  statement {}
  | statement_list statement {}
  ;

assignment_statement:
  identifier ':' '=' expression {}
  | array_indexing ':' '=' expression {}
  ;

return_statement:
  RETURN expression {}
  ;

print_statement:
  PRINT print_list {}
  ;

print_list:
  print_item {}
  | print_list ',' print_item {}
  ;

print_item:
  expression {}
  | string {}
  ;

break_statement:
  BREAK {}
  ;

if_statement:
  IF relation THEN statement {}
  | IF relation THEN statement ELSE statement {}
  ;

while_statement:
  WHILE relation DO statement {}
  ;

relation:
  expression '=' expression {}
  | expression '!' '=' expression {}
  | expression '<' expression {}
  | expression '>' expression {}
  ;

for_statement:
      FOR identifier IN expression '.' '.' expression DO statement {
          $$ = malloc (sizeof(node_t));                 // $$ = FOR_STATEMENT
          node_init ($$, FOR_STATEMENT, NULL, 4, $2, $4, $7, $9); // $2 = IDENTIFIER_DATA, etc.
      }
    ;

expression:
  expression '+' expression {}
  | expression '-' expression {}
  | expression '*' expression {}
  | expression '/' expression {}
  | '-' expression {}
  | '(' expression ')' {}
  | number {}
  | identifier {}
  | array_indexing {}
  | identifier '(' argument_list ')' {}
  ;

expression_list:
  expression {}
  | expression_list ',' expression {}
  ;

argument_list:
    /* Empty */
    | expression_list {}
    ;

identifier:
  IDENTIFIER {
    NODE_INIT($$, IDENTIFIER_DATA, strdup(yytext), 0, NULL);
  }
  ;

number:
  NUMBER {}
  ;

string:
  STRING {}
  ;

%%
