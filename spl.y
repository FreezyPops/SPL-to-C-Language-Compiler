%{

#include <stdio.h>
#include <stdlib.h>

/* make forward declarations to avoid compiler warnings */
int yylex (void);
void yyerror (char *);

/* 
   Some constants.
*/

  /* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

  enum ParseTreeNodeType {PROGRAM, BLOCK, IDENTIFIER_LIST, DECLARATION_BLOCK, TYPERULE,
						  STATEMENT_LIST, STATEMENT, ASSIGNMENT_STATEMENT, IF_STATEMENT,
						  DO_STATEMENT, WHILE_STATEMENT, FOR_STATEMENT, WRITE_STATEMENT,
						  READ_STATEMENT, OUTPUT_LIST, CONDITIONAL, COMPARATOR, EXPRESSION,
						  TERM, VALUE, CONSTANT, NUMBER_CONSTANT, CONSTNODE, ASSIGNSTATENODE,
						  IFSTATENODE, WHILESTATENODE, WRITESTATENODE, READSTATENODE, DOSTATENODE,
						  FORSTATENODE, INT_NUMBER_CONSTANT, REAL_NUMBER_CONSTANT,
						  NEG_INT_NUMBER_CONSTANT, NEG_REAL_NUMBER_CONSTANT} ;  
                          /* Add more types here, as more nodes
                                           added to tree */

										
char *NodeName[] = {"PROGRAM", "BLOCK", "IDENTIFIER_LIST", "DECLARATION_BLOCK", "TYPERULE",
				    "STATEMENT_LIST", "STATEMENT", "ASSIGNMENT_STATEMENT", "IF_STATEMENT",
				    "DO_STATEMENT", "WHILE_STATEMENT", "FOR_STATEMENT", "WRITE_STATEMENT",
					"READ_STATEMENT", "OUTPUT_LIST", "CONDITIONAL", "COMPARATOR", "EXPRESSION",
					"TERM", "VALUE", "CONSTANT", "INT_NUMBER_CONSTANT", "REAL_NUMBER_CONSTANT",
					"NEG_INT_NUMBER_CONSTANT", "NEG_REAL_NUMBER_CONSTANT"};
#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

/* ------------- parse tree definition --------------------------- */

struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
  };

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE *TERNARY_TREE;

/* ------------- forward declarations --------------------------- */

TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);
#ifdef DEBUG
	void PrintTree(TERNARY_TREE, int);
#endif
void GenerateCode(TERNARY_TREE);

/* ------------- symbol table definition --------------------------- */

struct symTabNode {
    char identifier[IDLENGTH];
};

typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE        *SYMTABNODEPTR;

SYMTABNODEPTR  symTab[SYMTABSIZE]; 

int currentSymTabSize = 0;

%}

/****************/
/* Start symbol */
/****************/

%start  program

/**********************/
/* Action value types */
/**********************/

%union {
    int iVal;
    TERNARY_TREE  tVal;
}

%token 		 PLUS TIMES MINUS DIVIDE EQUALS GREATERTHAN LESSTHAN NOTEQUAL LESSOREQUAL
			 GREATEROREQUAL ASSIGN NEWLINE WRITE READ DECLARATIONS ENDP CODE OF TYPE 
			 INTEGERTYPE CHARACTERTYPE LETTER REALTYPE  IFSTATE THEN ENDIF ELSE 
			 DOSTATE WHILESTATE ENDDO ENDWHILE FOR IS BY TO ENDFOR AND OR NOT BRA KET FULLSTOP COLON 
			 SEMICOLON COMMA APOST 			 

%token<iVal> IDENTIFIER INTEGERNUMBER REALNUMBER CHARACTERCONST

%type<tVal>  program block identifier_list declaration_block type statement_list 
			 statement assignment_statement if_statement do_statement while_statement 
			 for_statement write_statement read_statement output_list conditional 
			 comparator expression term value constant number_constant
%%


program		: IDENTIFIER COLON block ENDP IDENTIFIER FULLSTOP

			   { TERNARY_TREE ParseTree;	       
                 ParseTree = create_node($1, PROGRAM, $3, NULL, NULL) ;
			#ifdef DEBUG
				 PrintTree(ParseTree, 0); 
			#endif
				 GenerateCode (ParseTree);			
			   }
;

block		: DECLARATIONS declaration_block CODE statement_list 

				{$$ = create_node(NOTHING, BLOCK, $2, $4, NULL);}
				
			| CODE statement_list

				{$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL);}			
;
			
identifier_list		: IDENTIFIER

						{$$ = create_node($1, IDENTIFIER_LIST, NULL, NULL, NULL);}

					| IDENTIFIER COMMA identifier_list
					
						{$$ = create_node($1, IDENTIFIER_LIST, $3, NULL, NULL);}
;

declaration_block	: identifier_list OF TYPE type SEMICOLON

						{$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL);}

					| identifier_list OF TYPE type SEMICOLON declaration_block
					
						{$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6);}
;
   
type	: INTEGERTYPE

			{$$ = create_node(INTEGERTYPE, TYPERULE, NULL, NULL, NULL);}

		| CHARACTERTYPE
		
			{$$ = create_node(CHARACTERTYPE, TYPERULE, NULL, NULL, NULL);}
		
		| REALTYPE
		
			{$$ = create_node(REALTYPE, TYPERULE, NULL, NULL, NULL);}
;

statement_list 		: statement

						{$$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL);}

					| statement SEMICOLON statement_list
					
						{$$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL);}
;

statement	: assignment_statement

				{$$ = create_node(ASSIGNSTATENODE, STATEMENT, $1, NULL, NULL);}

			| if_statement
			
				{$$ = create_node(IFSTATENODE, STATEMENT, $1, NULL, NULL);}
			
			| do_statement
			
				{$$ = create_node(DOSTATENODE, STATEMENT, $1, NULL, NULL);}
			
			| while_statement
			
				{$$ = create_node(WHILESTATENODE, STATEMENT, $1, NULL, NULL);}
			
			| for_statement
			
				{$$ = create_node(FORSTATENODE, STATEMENT, $1, NULL, NULL);}
			
			| write_statement
			
				{$$ = create_node(WRITESTATENODE, STATEMENT, $1, NULL, NULL);}
			
			| read_statement
			
			{$$ = create_node(READSTATENODE, STATEMENT, $1, NULL, NULL);}			
;

assignment_statement	: expression ASSIGN IDENTIFIER

							{$$ = create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL);}

;
if_statement	: IFSTATE conditional THEN statement_list ENDIF

					{$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL);}

				| IFSTATE conditional THEN statement_list ELSE statement_list ENDIF
				
					{$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6);}				
;

do_statement	: DOSTATE statement_list WHILESTATE conditional ENDDO

					{$$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL);}
;

while_statement	: WHILESTATE conditional DOSTATE statement_list ENDWHILE

					{$$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL);}
;

for_statement	: FOR IDENTIFIER IS expression BY expression TO expression DOSTATE statement_list ENDFOR

					{$$ = create_node($2, FOR_STATEMENT, create_node($2, FOR_STATEMENT, $4, $6, $8), $10, NULL);}
;

write_statement	: WRITE BRA output_list KET

					{$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);}

				| NEWLINE
				
					{$$ = create_node(NEWLINE, WRITE_STATEMENT, NULL, NULL, NULL);}
;

read_statement	: READ BRA IDENTIFIER KET

					{$$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL);}
;

output_list		: value

					{$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL);}

				| value COMMA output_list
				
					{$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL);}
;

conditional		: expression comparator expression

					{$$ = create_node(NOTHING, CONDITIONAL, $1, $2, $3);}

				| expression comparator expression AND conditional
				
					{$$ = create_node(AND, CONDITIONAL, create_node(AND, CONDITIONAL, $1, $2, $3), $5, NULL);}
				
				| expression comparator expression OR conditional
				
					{$$ = create_node(OR, CONDITIONAL, create_node(OR, CONDITIONAL, $1, $2, $3), $5, NULL);}
				
				| NOT conditional
				
					{$$ = create_node(NOT, CONDITIONAL, $2, NULL, NULL);}
;

comparator		: EQUALS

					{$$ = create_node(EQUALS, COMPARATOR, NULL, NULL, NULL);}

				| GREATERTHAN
						
					{$$ = create_node(GREATERTHAN, COMPARATOR, NULL, NULL, NULL);}
				
				| LESSTHAN
				
					{$$ = create_node(LESSTHAN, COMPARATOR, NULL, NULL, NULL);}
				
				| NOTEQUAL
				
					{$$ = create_node(NOTEQUAL, COMPARATOR, NULL, NULL, NULL);}
				
				| LESSOREQUAL
				
					{$$ = create_node(LESSOREQUAL, COMPARATOR, NULL, NULL, NULL);}
				
				| GREATEROREQUAL
				
					{$$ = create_node(GREATEROREQUAL, COMPARATOR, NULL, NULL, NULL);}				
;

expression		: term

					{$$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL);}

				| term PLUS expression
				
					{$$ = create_node(PLUS, EXPRESSION, $1, $3, NULL);}
				
				| term MINUS expression
				
					{$$ = create_node(MINUS, EXPRESSION, $1, $3, NULL);}
;

term	: value

			{$$ = create_node(NOTHING, TERM, $1, NULL, NULL);}

		| value TIMES term
		
			{$$ = create_node(TIMES, TERM, $1, $3, NULL);}
		
		| value DIVIDE term
		
			{$$ = create_node(DIVIDE, TERM, $1, $3, NULL);}
;

value	: IDENTIFIER

			{$$ = create_node($1, VALUE, NULL, NULL, NULL);}
 
		| constant
		
			{$$ = create_node(CONSTNODE, VALUE, $1, NULL, NULL);}
		
		| BRA expression KET
			
			{$$ = create_node(NOTHING, VALUE, $2, NULL, NULL);}
;

constant	: number_constant

				{$$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL);}

			| CHARACTERCONST
			
				{$$ = create_node($1, CONSTANT, NULL, NULL, NULL);}
;

number_constant	: INTEGERNUMBER

					{$$ = create_node($1, INT_NUMBER_CONSTANT, NULL, NULL, NULL);}

				| REALNUMBER
				
					{$$ = create_node($1, REAL_NUMBER_CONSTANT, NULL, NULL, NULL);}
				
				| MINUS INTEGERNUMBER
				
					{$$ = create_node($2, NEG_INT_NUMBER_CONSTANT, NULL, NULL, NULL);}
				
				| MINUS REALNUMBER			
				
					{$$ = create_node($2, NEG_REAL_NUMBER_CONSTANT, NULL, NULL, NULL);}					
;
	
%%
	
TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    return (t);
}

#ifdef DEBUG
void PrintTree(TERNARY_TREE t, int indent)
{	
	int i;
	if (t == NULL) return;
	for (i=indent; i; i--) printf(" ");		
	if (t->nodeIdentifier == INT_NUMBER_CONSTANT)
	{
		printf("Number: %d", t->item);
		printf("\n");
	}
	else if (t->nodeIdentifier == NEG_INT_NUMBER_CONSTANT)
	{
		printf("Negative Number: - ");
		printf("%d", t->item);
		printf("\n");
	}
	else if (t->nodeIdentifier == REAL_NUMBER_CONSTANT)	
	{
		printf("Real Number: %s", symTab[t->item]->identifier);
		printf("\n");
	}
	else if (t->nodeIdentifier == NEG_REAL_NUMBER_CONSTANT)
	{
		printf("Negative Real Number: - ");
		printf("%s", symTab[t->item]->identifier);
		printf("\n");
	}
	else if (t->nodeIdentifier == VALUE && t->first != NULL)
		{
			if (t->item >= 0 && t->item < SYMTABSIZE)
			{			
				printf("Identifier: %c ",symTab[t->item]->identifier);
			}
			else 
			{
				printf("Unknown Identifier: %d",t->item);	
			}				
		}	
	else if(t->nodeIdentifier == CONSTANT && t->first == NULL)
		{
			printf("Character Constant: %c ",t->item);						
		}
	else if(t->item != NOTHING)
	{
		printf("Item: %d ", t->item);			
	}
	if(t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
	{
		printf("Unknown nodeIdentifier: %d\n", t->nodeIdentifier);
	}
	else
	{
		printf("%s\n",NodeName[t->nodeIdentifier]);	
	}
	
	PrintTree(t->first, indent+3);	
	PrintTree(t->second, indent+3);	
	PrintTree(t->third, indent+3);
		
	
		
}	
#endif

void GenerateCode(TERNARY_TREE t)
{
	
	if (t == NULL)return;    
	switch(t->nodeIdentifier)
	{
		case(PROGRAM) :				
			
			printf("#include <stdio.h>\n");
			printf("int main(void) {\n");
			GenerateCode(t->first); /*BLOCK*/
			printf("}\n");
			return;
			
		case(BLOCK) :		
			
			if(t->second != NULL)
			{
			GenerateCode(t->first); /*DECLARATION_BLOCK*/
			GenerateCode(t->second); /*STATEMENT_LIST*/
			return;
			}
			else
			{				
			GenerateCode(t->first); /*STATEMENT_LIST*/
			return;
			}
						
		case(DECLARATION_BLOCK) :		
						
			GenerateCode(t->second); /*TYPERULE*/
			GenerateCode(t->first); /*IDENTIFIER_LIST*/
			if(t->third != NULL)
			{
				GenerateCode(t->third); /*DECLARATION_BLOCK*/
			}
			return;	

		case(STATEMENT_LIST) :
					
			GenerateCode(t->first);   /*STATEMENT*/
			if(t->second != NULL)
			{
				GenerateCode(t->second);   /*STATEMENT_LIST*/
				return;
			}
			else
			{
				return;
			}
			
		case(STATEMENT) :
					
			GenerateCode(t->first);   /*Goes to which ever statement node attaches to current node*/
			return;	
			
		case(WRITE_STATEMENT) : 			
			
			if (t->item == NEWLINE)
			{
				printf("printf(\"\\n\");\n");
				return;
			}					
			printf("printf(\"");
			GenerateCode(t->first);   /*OUTPUT_LIST*/
			printf("\");\n");				
			return;	

		case(READ_STATEMENT) :		
			
			printf("scanf(\"");
			printf("%%");			
			printf("s\", ");
			printf("%s",symTab[t->item]->identifier);
			printf(");\n");
			return;
		
		case(IF_STATEMENT) :
		
			printf("if(");
			GenerateCode(t->first);   /*CONDITIONAL*/			
			printf(")\n{\n");
			GenerateCode(t->second);   /*STATEMENT_LIST*/
			if(t->third != NULL)
			{
				printf("}\n");
				printf("else\n{\n");
				GenerateCode(t->third);   /*STATEMENT_LIST*/
				printf("}\n");
				return;
			}
			printf("}\n");
			return;
			
		case(ASSIGNMENT_STATEMENT) :
		
			printf("%s", symTab[t->item]->identifier);
			printf(" = ");
			GenerateCode(t->first);   /*EXPRESSION*/	
			printf(";\n");
			return;
			
		case(FOR_STATEMENT) :
				    
			printf("for(");	
			printf("%s", symTab[t->item]->identifier);
			printf("=");
			GenerateCode(t->first->first);   /*EXPRESSION*/
			printf("; ");
			printf("%s", symTab[t->item]->identifier);			
			printf("<");
			GenerateCode(t->first->third);   /*EXPRESSION*/
			printf("; ");
			printf("%s", symTab[t->item]->identifier);
			printf("+=");
			GenerateCode(t->first->second);   /*EXPRESSION*/
			printf(")\n{\n");
			GenerateCode(t->second);   /*STATEMENT_LIST*/
			printf("\n}\n");
			return;
			
		case(WHILE_STATEMENT) :
		
			printf("while(");
			GenerateCode(t->first);   /*CONDITIONAL*/
			printf(")\n{\n");
			GenerateCode(t->second);   /*STATEMENT_LIST*/
			printf("\n}\n");
			return;
			
		case(DO_STATEMENT) :
		
			printf("do{\n");
			GenerateCode(t->first);   /*STATEMENT_LIST*/
			printf("} while(");
			GenerateCode(t->second);   /*CONDITIONAL*/
			printf(");\n");
			return;			
			
		case(CONDITIONAL) :
						
			if(t->item == NOT) 
			{
				printf("!(");				
				GenerateCode(t->first);   /*CONDITIONAL*/
				printf(")");
				return;
			}
			else if(t->item != NOTHING)
			{									
				GenerateCode(t->first->first);   /*EXPRESSION*/							
				GenerateCode(t->first->second);   /*COMPARATOR*/				
				GenerateCode(t->first->third);   /*EXPRESSION*/			
				
				if(t->item == AND) printf(" && ");
				else if(t->item == OR) printf(" || ");				
				GenerateCode(t->second);   /*CONDITIONAL*/				
				return;
			}
			else if(t->item == NOTHING)
			{					
				GenerateCode(t->first);   /*EXPRESSION*/
				GenerateCode(t->second);   /*COMPARATOR*/
				GenerateCode(t->third);   /*EXPRESSION*/			
			}	
			return;

		case(COMPARATOR) :
					
			if(t->item == EQUALS)
			{
				printf(" == ");
				return;
			}
			else if(t->item == NOTEQUAL) 
			{
				printf(" != ");
				return;
			}
			else if(t->item == LESSTHAN)
			{
				printf(" < ");
				return;
			}
			else if(t->item == GREATERTHAN)
			{
				printf(" > ");
				return;
			}
			else if(t->item == LESSOREQUAL)
			{
				printf(" <= ");
				return;
			}
			else if(t->item == GREATEROREQUAL)
			{
				printf(" >= ");
				return;
			}
			return;	

		case(EXPRESSION) :			
						
			GenerateCode(t->first);   /*TERM*/
			if(t->second == NULL)
			{				
				return;
			}
			else if(t->item == PLUS)
			{			
				printf("+ ");
				GenerateCode(t->second);   /*EXPRESSION*/			
				return;
			}
			else if(t->item == MINUS) 
			{	
				printf("- ");
				GenerateCode(t->second);   /*EXPRESSION*/		
				return;
			}			
			return;
			
		case(TERM) :		
						
			GenerateCode(t->first);   /*VALUE*/
			if(t->second == NULL) return;
			if(t->item == TIMES) printf("* ");
			else if(t->item == DIVIDE) printf("/ ");
			GenerateCode(t->second);   /*TERM*/
			return;
			
		case(VALUE) :
					
			if(t-> item != NOTHING && t->item != CONSTNODE)
			{
				printf("%s", symTab[t->item]->identifier);				
				return;
			}
			else if(t->item == CONSTNODE)
			{				
				GenerateCode(t->first);   /*CONSTANT*/
				return;
			}
			else
			{
				printf("(");
				GenerateCode(t->first);   /*EXPRESSION*/
				printf(")");
				return;
			}	
			return;
			
		case(TYPERULE) :
						
			if(t->item == INTEGERTYPE)
			{
				printf("int ");
				return;
			}
			
			else if(t->item == CHARACTERTYPE)
			{
				printf("char ");
				return;
			}
			
			else if(t->item == REALTYPE)
			{
				printf("float ");
				return;
			}
			return;
			
		case(IDENTIFIER_LIST) :			
			
			printf("%s",symTab[t->item]->identifier);						
			if(t->first != NULL)
			{
				printf(", ");
				GenerateCode(t->first); /*IDENTIFIER_LIST*/	
				return;
			}
			else
			{
				printf(";\n");
				return;
			}	
			return;
			
		case(CONSTANT) :			
			
			if(t->item != NOTHING)
			{					
				printf("%c", t->item);
				return;
			}
			else 
			{
				GenerateCode(t->first);   /*NUMBER_CONSTANT*/
				return;
			}
			return;

		case(INT_NUMBER_CONSTANT) :				
		
			printf("%d", t->item);
			return;
			
		case(NEG_INT_NUMBER_CONSTANT) :				
		
			printf("-");
			printf("%d", t->item);
			return;
			
		case(REAL_NUMBER_CONSTANT) :				
		
			printf("%s", symTab[t->item]->identifier);
			return;
			
		case(NEG_REAL_NUMBER_CONSTANT) :				
		
			printf("-");
			printf("%s", symTab[t->item]->identifier);
			return;
			
		default :			
				
			GenerateCode(t->first);
			GenerateCode(t->second);
			GenerateCode(t->third);				
    }
}

#include "lex.yy.c"
