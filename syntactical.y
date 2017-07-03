/*Header*/
%{

    #define _GNU_SOURCE
    #include <stdio.h>
    #include <string.h>

    /*Data structures for links in symbol lookahead*/
    struct symrec{
        char *name;             //Symbol name
        int type;               //Symbol type
        double value;           //Variable lookahead value
        int function;           //Function
        struct symrec *next;    //Next register pointer
    };

    typedef struct symrec symrec;

    /*Symbol table*/
    extern symrec *sym_table;

    /*Symbol table interactions*/
    symrec *putsym ();
    symrec *getsym ();

    extern int yylex(void);
    extern FILE *yyin;      //Source file to be translated
    extern char *yytext;    //Recognizes input tokens
    extern int line_number; //Line number

    FILE *yy_output;        //Object file
    
    symrec *sym_table = (symrec *)0;
    symrec *s;
    symrec *symtable_set_type;
    
    int yyerror(char *s);       //Error function

    int is_function=0;          //Is a function (flag)
    int error=0;                //Error flag
    int global = 0;             //Global var falg
    int ind = 0;                //Indentation
    int function_definition = 0;//Funcion definition flag

    /*Creates an indentation*/
    void indent(){
        int temp_ind = ind;
        while (temp_ind > 0){
            fprintf(yy_output, "\t");
            temp_ind -= 1;
        }
    }

%}

%union
{
	int type;
	double value;
	char *name;
	struct symrec *tptr;
}

/*Op and exp tokens*/
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME
%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR CONTINUE BREAK RETURN

/*Types tokens*/
%token <name> IDENTIFIER CONSTANT SIZEOF
%token <type> CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOID

/*Other*/
%type <type> type_specifier declaration_specifiers type_qualifier
%type <name> init_direct_declarator direct_declarator declarator init_declarator init_declarator_list function_definition
%type <name> parameter_type_list parameter_list parameter_declaration array_list array_declaration
%type <name> initializer initializer_list
%type <tptr> declaration

%left INC_OP DEC_OP

%nonassoc IF_AUX
%nonassoc ELSE

%start translation_unit

%%

/*If it is an identifier, saves it into the file*/
primary_expression
	: IDENTIFIER { fprintf(yy_output, "%s", yytext); }
	| CONSTANT { fprintf(yy_output, "%s", yytext); }
	| open_parenthesis expression close_parenthesis
	;

/*Tokens into the file*/
postfix_expression
	: primary_expression
	| postfix_expression open_bracket  expression close_bracket
	| postfix_expression open_parenthesis close_parenthesis
	| postfix_expression open_parenthesis argument_expression_list close_parenthesis
	| postfix_expression INC_OP { fprintf(yy_output, "+=1"); }
	| postfix_expression DEC_OP { fprintf(yy_output, "-=1"); }
	;

/*Arguments*/
argument_expression_list
	: assignment_expression
	| argument_expression_list ',' { fprintf(yy_output, ", "); } assignment_expression
	;

/*Unary expressions*/
unary_expression
	: postfix_expression
	| INC_OP { fprintf(yy_output, "+=1"); } unary_expression
	| DEC_OP { fprintf(yy_output, "-=1"); } unary_expression
	| unary_operator cast_expression
    | SIZEOF unary_expression
	;

/*Unary operators*/
unary_operator
	: '&' { fprintf(yy_output, " & "); }
	| '*' { fprintf(yy_output, " * "); }
	| '+' { fprintf(yy_output, " + "); }
	| '-' { fprintf(yy_output, " - "); }
	| '~' { fprintf(yy_output, " ~ "); }
	| '!' { fprintf(yy_output, " ! "); }
	;

/*Cast*/
cast_expression
	: unary_expression
	;

/*Multiplication, division and mod operators*/
multiplicative_expression
    : cast_expression
	| multiplicative_expression '*' mult cast_expression
    | multiplicative_expression '*'  mult error { yyerrok;}
    | multiplicative_expression '/' div cast_expression
    | multiplicative_expression '/' div error { yyerrok;}
    | multiplicative_expression '%' mod cast_expression
    | multiplicative_expression '%'  mod error { yyerrok;}
    ;

/*Addition and subtraction*/
additive_expression
	: multiplicative_expression
	| additive_expression '+' add multiplicative_expression
	| additive_expression '-' sub multiplicative_expression
    | additive_expression '+' add error { yyerrok;}
	| additive_expression '-' sub error { yyerrok;}
	;

/*Shift*/
shift_expression
	: additive_expression
	| shift_expression LEFT_OP { fprintf(yy_output, " << "); } additive_expression
	| shift_expression RIGHT_OP { fprintf(yy_output, " >> "); } additive_expression
	;

/*Relation operators*/
relational_expression
	: shift_expression
    | relational_expression '<' l_op shift_expression
	| relational_expression '>' g_op shift_expression
	| relational_expression '<' l_op error {yyerrok;}
	| relational_expression '>' g_op error {yyerrok;}
	| relational_expression LE_OP le_op shift_expression
	| relational_expression GE_OP ge_op shift_expression
	;

/*Equal amd not equal*/
equality_expression
	: relational_expression
    | equality_expression EQ_OP eq_op relational_expression
	| equality_expression NE_OP ne_op relational_expression
	| equality_expression EQ_OP eq_op error {yyerrok;}
	| equality_expression NE_OP ne_op error {yyerrok;}
    ;

/*'AND' operator*/
and_expression
	: equality_expression
	| and_expression '&' { fprintf(yy_output, " & "); } equality_expression
	;

/*'XOR' operator*/
exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' { fprintf(yy_output, " ^ "); } and_expression
	;

/*'OR' operator*/
inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' { fprintf(yy_output, " | "); } exclusive_or_expression
	;

/*'Logic AND' operator*/
logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP { fprintf(yy_output, " && "); } inclusive_or_expression
	| logical_and_expression AND_OP { fprintf(yy_output, " && "); } error {yyerrok;}
    ;

/*'Logic OR' operator*/
logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP { fprintf(yy_output, " || "); } logical_and_expression
    | logical_or_expression OR_OP { fprintf(yy_output, " || "); } error {yyerrok;}
    ;

/*Conditional expression*/
conditional_expression
	: logical_or_expression
	| logical_or_expression '?' { fprintf(yy_output, " ? "); } expression ':' { fprintf(yy_output, " : "); } conditional_expression
	;

/*Assignment expression*/
assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
    | error assignment_operator assignment_expression {yyerrok;}
	;

/*Assignment operators*/
assignment_operator
	: '=' { fprintf(yy_output, " = "); }
	| MUL_ASSIGN { fprintf(yy_output, " *= "); }
	| DIV_ASSIGN { fprintf(yy_output, " /= "); }
	| MOD_ASSIGN { fprintf(yy_output, " %%= "); }
	| ADD_ASSIGN { fprintf(yy_output, " += "); }
	| SUB_ASSIGN { fprintf(yy_output, " -= "); }
	| LEFT_ASSIGN { fprintf(yy_output, " <<= "); }
	| RIGHT_ASSIGN { fprintf(yy_output, " >>= "); }
	| AND_ASSIGN { fprintf(yy_output, " &= "); }
	| XOR_ASSIGN { fprintf(yy_output, " ^= "); }
	| OR_ASSIGN { fprintf(yy_output, " |= "); }
	;

/*Expressions*/
expression
	: assignment_expression
	| expression ',' { fprintf(yy_output, ", "); } assignment_expression
	;

/*Constant expression*/
constant_expression
	: conditional_expression
	;

/*Declaration*/
declaration
    : declaration_specifiers init_declarator_list ';'
    {
        for(symtable_set_type=sym_table; symtable_set_type!=(symrec *)0; symtable_set_type=(symrec *)symtable_set_type->next)
			if(symtable_set_type->type==-1) symtable_set_type->type=$1;
	}
	| declaration_specifiers init_declarator_list error { yyerror("A \";\" (semicolon) is missing"); yyerrok; }
	;

/*Specifiers*/
declaration_specifiers
	: type_specifier
	| type_specifier declaration_specifiers
	| type_qualifier
	| type_qualifier declaration_specifiers
	;

/*Declarations*/
init_declarator_list
	: init_declarator
    {
        s = getsym($1);
    	if(s==(symrec *)0) s = putsym($1);
        else {
    		yyerror("Variable previously declared");
    		yyerrok;
    	}
    }
	| init_declarator_list ',' init_declarator { fprintf(yy_output, "\n"); indent(); }
    {
        s = getsym($3);
        if(s==(symrec *)0) s = putsym($3);
        else {
            yyerror("Variable previously declared");
            yyerrok;
        }
    }
    | init_declarator_list ',' error { yyerror("Error. An extra ',' is received"); }
	;

/*Declarations*/
init_declarator
	: declarator
	| init_direct_declarator '=' initializer { fprintf(yy_output, "%s", $3); }
	;

/*Types*/
type_specifier
	: CHAR
	| INT
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| VOID
	;

/*Declarator*/
declarator
	: direct_declarator
	;

/*Functions and arrays*/
direct_declarator
    : IDENTIFIER { if (is_function) /*fprintf(yy_output, "", $1); else */is_function = 0; }
    | IDENTIFIER '[' ']' { if (!is_function) fprintf(yy_output, " %s = [] \n", $1); else is_function = 0; }
	| IDENTIFIER array_list { if (!is_function) fprintf(yy_output, "%s = [%s] \n", $1, $2); else is_function = 0; indent();}
    | IDENTIFIER '[' CONSTANT ']' {fprintf(yy_output, "%s = Array.new(%s) \n",$1,$3);	indent();}
    | IDENTIFIER '(' ')' { if (!is_function) fprintf(yy_output, "def %s()", $1); else is_function = 0; }
	| IDENTIFIER '(' parameter_type_list ')' { if (!is_function) fprintf(yy_output, "def %s(%s)", $1, $3); else is_function = 0; }
    ;

/*Arrays*/
init_direct_declarator
	: IDENTIFIER { if (!is_function) fprintf(yy_output, "%s = ", $1); else is_function = 0; }
	| IDENTIFIER array_declaration { if (!is_function) fprintf(yy_output, "%s = ", $1); else is_function = 0;	indent(); }
	| IDENTIFIER array_list { if (!is_function) fprintf(yy_output, "%s = ", $1); else is_function = 0; }
	;

/*Arrays list*/
array_list
	: array_declaration
	| array_list array_declaration { asprintf(&$$, "%s,%s", $1, $2); }
	;

/*Arrays declaration*/
array_declaration
	: '[' ']' { asprintf(&$$, "[] "); indent(); }
	| '[' CONSTANT ']' { asprintf(&$$, "[%s] ",$2); indent(); }
	;

/*Parameter type*/
parameter_type_list
	: parameter_list
	;

/*Parameter list*/
parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration { asprintf(&$$, "%s, %s", $1, $3); }
	;

/*Parameter declaration*/
parameter_declaration
	: { is_function = 1; } declaration_specifiers declarator { $$ = $3; }
	;

/*Parameter initializer*/
initializer_list
	: initializer
	| initializer_list ',' initializer { asprintf(&$$, "%s, %s", $1, $3); }
	;

/*Exp initializer*/
initializer
	: IDENTIFIER
	| CONSTANT
	| '{' initializer_list '}' { asprintf(&$$, "[%s] \n", $2); }
	;

/*Type qualifier*/
type_qualifier
	: CONST { fprintf(yy_output, "const "); }
	;

/*Statements*/
statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

/*Labeled statements*/
labeled_statement
	: CASE { fprintf(yy_output, "case "); } constant_expression ':' { fprintf(yy_output, ": "); } statement
	| DEFAULT { fprintf(yy_output, "default "); } ':' { fprintf(yy_output, ": "); } statement
	;

/*Open scope*/
open_curly
    : '{'
    {
  		fprintf(yy_output,"\n");
  		ind += 1; indent();
  		function_definition = 0;
  	}
  	;

/*Close scope*/
close_curly
    : '}'
    {
  		fprintf(yy_output,"\n");
  		ind -= 1; indent();
  	}
  	;

/*Semicolon*/
semi_colon
    : ';' { fprintf(yy_output,"\n"); indent(); }
    ;

/*Open parenthesis*/
open_parenthesis
    : '(' { fprintf(yy_output,"("); }
  	;

/*Close parenthesis*/
close_parenthesis
    : ')' { fprintf(yy_output,")"); }
  	;

/*Open bracket*/
open_bracket
    : '[' { fprintf(yy_output, "["); }
  	;

/*Close bracket*/
close_bracket
    : ']' { fprintf(yy_output, "]"); }
  	;

/*Mod*/
mod
    : { fprintf(yy_output," %% "); }
  	;

/*Multiplication*/
mult
    : { fprintf(yy_output," * "); }
  	;

/*Division*/
div
    : { fprintf(yy_output," / "); }
  	;

/*Addition*/
add
    : { fprintf(yy_output," + "); }
  	;

/*Subtraction*/
sub
    : { fprintf(yy_output," - "); }
  	;

/*'Lower than'*/
l_op
    : { fprintf(yy_output," < "); }
  	;

/*'Greater than'*/
g_op
    : { fprintf(yy_output," > "); }
  	;

/*'Lower or equal than'*/
le_op
    : { fprintf(yy_output," <= "); }
  	;

/*'Greater or equal than'*/
ge_op
    : { fprintf(yy_output," >= "); }
  	;

/*Equal*/
eq_op
    : { fprintf(yy_output," == "); }
  	;

/*Not equal*/
ne_op
    : { fprintf(yy_output," != "); }
  	;

/*Compound statements*/
compound_statement
    : open_curly close_curly
    | open_curly statement_list close_curly
    | open_curly declaration_list close_curly
    | open_curly declaration_list statement_list close_curly
    | '{' error { yyerror("A \"}\" (close curly) is missing"); yyerrok; }
    ;

/*Declarations*/
declaration_list
	: declaration
	| declaration_list declaration
	;

/*Statements*/
statement_list
	: statement
	| statement_list statement
	;

/*Expression statement*/
expression_statement
	: semi_colon
	| expression semi_colon
    | expression error { yyerror("A \";\" (semicolon) is missing into the statement");yyerrok; }
	;

/*'Else' statement*/
else_statement
	: ELSE { fprintf(yy_output, "else"); }  statement
	| %prec IF_AUX
	;

/*'If' statement*/
if
    : IF { fprintf(yy_output,"if"); }
	;

/*Switch*/
selection_statement
	: if open_parenthesis expression close_parenthesis statement  else_statement {fprintf(yy_output,"end\n"); indent(); }
    | if error expression close_parenthesis statement { yyerror("A \"(\" (open parenthesis) is missing after the 'if' statement");yyerrok; }
	| SWITCH { fprintf(yy_output, "switch"); } open_parenthesis expression close_parenthesis statement { fprintf(yy_output,"end\n"); indent(); }
	;

/*While*/
while
    : WHILE { fprintf(yy_output,"while "); }
  	;
/*Iterations*/
iteration_statement
    : while '('  expression ')' { fprintf(yy_output," do"); } statement { fprintf(yy_output,"end\n"); indent(); }
    | while error expression ')' statement { yyerror("A \"(\" (open parenthesis) is missing");yyerrok; }
    | DO statement WHILE open_parenthesis expression close_parenthesis semi_colon
    | FOR open_parenthesis expression_statement expression_statement close_parenthesis statement
    | FOR open_parenthesis expression_statement expression_statement expression close_parenthesis statement
	;

/*Jumps*/
jump_statement
	: CONTINUE { fprintf(yy_output, "continue"); } semi_colon
	| BREAK { fprintf(yy_output, "break"); } semi_colon
	| RETURN { fprintf(yy_output, "return"); } semi_colon
	| RETURN { fprintf(yy_output, "return "); } expression semi_colon
	| CONTINUE error { yyerror("A \";\" (semicolon) is missing after 'continue'"); yyerrok; }
	| BREAK error { yyerror("A \";\" (semicolon) is missing after 'brak'"); yyerrok;}
	;

/*Declarations*/
external_declaration
	: function_definition
	| declaration
	;

/*Functions*/
function_definition
	: declaration_specifiers declarator compound_statement { fprintf(yy_output,"end\n"); indent(); }
	{
		s = getsym($2);
		if(s==(symrec *)0) s = putsym($2,$1,1);
		else {
			printf("Function already declared.");
			yyerrok;
		}
	}
	| declarator declaration_list compound_statement { fprintf(yy_output,"end\n"); indent(); }
  	| declarator compound_statement { fprintf(yy_output,"end\n"); indent(); }
	;

/*Translation*/
translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

%%

#include <stdio.h>

/*Error function*/
int yyerror(s)
    char *s;
    {
        error=1;
        printf("Error in the line number %d near \"%s\": (%s)\n", line_number, yylval.name, s);
    }

/*Symbol put*/
symrec * putsym(sym_name, sym_type, b_function)
	char *sym_name;
	int sym_type;
	int b_function;
    {
        symrec *ptr;
        ptr = (symrec *) malloc(sizeof(symrec));
        ptr->name = (char *) malloc(strlen(sym_name) + 1);
        strcpy(ptr->name, sym_name);
        ptr->type = sym_type;
        ptr->value = 0;
        ptr->function = b_function;
        ptr->next =(struct symrec *) sym_table;
        sym_table = ptr;
        return ptr;
    }

/*Symbol get*/
symrec * getsym(sym_name)
	char *sym_name;
    {
        symrec *ptr;
        for(ptr = sym_table; ptr != (symrec*)0; ptr = (symrec *)ptr->next)
            if(strcmp(ptr->name, sym_name) == 0) return ptr;
        return 0;
    }

/*Main function*/
int main(int argc,char **argv){
    
	/*Args error*/
	if (argc<3){
		printf("There is missings parameters\n Example of use: %s code.c code.rb\n", argv[0]);
		return 0;
	}
    
    /*File error*/
	if ((yyin = fopen(argv[1],"rt")) == NULL){
		printf("The file could not be opened.\n");
        return 0;
	}
    
    /*File error*/
	if ((yy_output=fopen(argv[2], "w")) == NULL){
		printf("The file could not be opened.\n");
        return 0;
	}

	/*Init translation*/
	yyparse();

	/*Close files adding 'main' at the bottom*/
    fprintf(yy_output, "\nmain()\n");
	fclose(yyin);
	fclose(yy_output);

    /*Translation finished: messages*/
	if(error)   printf("ERROR in the translation: %s\n", argv[1]);
	else        printf("SUCCESS translating %s\nTranslated file: %s\n", argv[1], argv[2]);

	return 0;
    
}
