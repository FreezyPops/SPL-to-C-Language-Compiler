%{
#ifdef PRINT
#define TOKEN(t) printf("Token: " #t "\n");
#define NUMBER_TOKEN(t) printf("Number %d Token: " #t "\n",atoi(yytext));
#define REAL_TOKEN(t) printf("Real Number %f Token: " #t "\n",atof(yytext));
#define ID_TOKEN(t) printf("ID %s Token: " #t "\n", yytext);
#define CHARACTER_TOKEN(t) printf("Character %s Token: " #t "\n", yytext);
#else
#define TOKEN(t) return (t);
#define NUMBER_TOKEN(t) yylval.iVal = atoi(yytext); return (t);
#define ID_TOKEN(t) yylval.iVal = installId(yytext); return (t);
#define REAL_TOKEN(t) yylval.iVal = installId(yytext); return (t);
#define CHARACTER_TOKEN(t) yylval.iVal = yytext[1]; return (t);


#include <string.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;
int installId(char *);

#endif
%}

delim           [ \t\r\n]
ws              {delim}+
digit           [0-9]
number          {digit}+
point           \.
minus			-
real			{number}{point}{number}
letter          [a-zA-Z]
apost           '
id 				{letter}({letter}|{digit})*
characterConstant {apost}{letter}{apost}
 
%%
{ws}            ; /*Do Nothing */


"+"           TOKEN(PLUS);
"*"           TOKEN(TIMES);
"-"           TOKEN(MINUS);
"/"           TOKEN(DIVIDE);
"("           TOKEN(BRA);
")"           TOKEN(KET);
"="           TOKEN(EQUALS);
">"           TOKEN(GREATERTHAN);
"<"           TOKEN(LESSTHAN);
"<>"          TOKEN(NOTEQUAL);
"<="          TOKEN(LESSOREQUAL);
">="          TOKEN(GREATEROREQUAL);
"->"          TOKEN(ASSIGN);
"."           TOKEN(FULLSTOP);
":"           TOKEN(COLON);
";"           TOKEN(SEMICOLON);
","           TOKEN(COMMA);
"'"           TOKEN(APOST);

NEWLINE       TOKEN(NEWLINE);
WRITE         TOKEN(WRITE);
READ          TOKEN(READ);
DECLARATIONS  TOKEN(DECLARATIONS);
ENDP          TOKEN(ENDP);
CODE          TOKEN(CODE);
OF            TOKEN(OF);
TYPE          TOKEN(TYPE);
INTEGER       TOKEN(INTEGERTYPE);
CHARACTER     TOKEN(CHARACTERTYPE);
REAL          TOKEN(REALTYPE);
IF            TOKEN(IFSTATE);
THEN          TOKEN(THEN);
ENDIF         TOKEN(ENDIF);
ELSE          TOKEN(ELSE);
DO            TOKEN(DOSTATE);
WHILE         TOKEN(WHILESTATE);
ENDDO         TOKEN(ENDDO);
ENDWHILE      TOKEN(ENDWHILE);
FOR           TOKEN(FOR);
IS            TOKEN(IS);
BY            TOKEN(BY);
TO            TOKEN(TO);
ENDFOR        TOKEN(ENDFOR);
AND           TOKEN(AND);
OR            TOKEN(OR);
NOT           TOKEN(NOT);

{number}      {          
				NUMBER_TOKEN(INTEGERNUMBER);				  
              }			

				
{id}		  {
				ID_TOKEN(IDENTIFIER);
			  }			
			
			
{characterConstant}		{
							CHARACTER_TOKEN(CHARACTERCONST);
						}

{real}		  {
				REAL_TOKEN(REALNUMBER);
			  }						
	
%%		

#ifndef PRINT 

SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);			
        }
    }
    return (-1);    
}

/* Look up an identifier in the symbol table, if its there return
   its index.  If its not there, put it in the end position,
   as long as the table isn't full, and return its index.
*/

int installId(char *id) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
        return (index);		
    }
    else 
       if (currentSymTabSize >= SYMTABSIZE) 
          /* SYMTAB is full */
          return (NOTHING) ;
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
       return(currentSymTabSize++);
    }
}	

#endif