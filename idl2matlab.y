%{

/******************************************************************************
*                                IDL2MATLAB Project
*-----------------------------------------------------------------------------
*   ILL (Institut Laue Langevin)
*
*   38000 GRENOBLE Cedex
*-----------------------------------------------------------------------------
*   Module              :       Syntax description of the IDL Language
*   Auteurs             :       Azizi Mourier Karim
                                Benzeghioua Abdeslam
                                Gardon Lucien
                                Sylvestre Nadege
*   Date                :       February 21 2002
*   Modifications       :
*
*****************************************************************************/

#include "tree.h"
%}

/* declaration des tokens */


%token DIESE2
%token IDENTIFIER
%token INTEGER
%token REAL
%token DECIMAL
%token HEXADECIMAL
%token OCTAL
%token STRING
%token End
%token Begin
%token If
%token Then
%token Of
%token Or
%token Case
%token And
%token LT
%token LE
%token GT
%token GE
%token EQ
%token NE
%token Pro
%token Not
%token SLASH
%token Mod
%token While
%token Repeat
%token For
%token Endrep
%token Endwhile
%token Endfor
%token Do
%token Until
%token Assign
%token Else
%token Endelse
%token Endif
%token Function
%token Common
%token Extra
%token Ref_Extra
%token Endcase
%token Return
%token DIESE
%token XOR
%token Catch
%token Forward_function
%token FLECHE
%token INHERITS
%token OBJECT
%token SOL_PARENT
%token SOL_TIMES
%token COMPILE_OPT

%right '=' LT  GT LE GE EQ NE 	      /* le - prioritaire */
%left Or
%left And

%left '+' '-' '<' '>'
%left '*' SLASH Mod
%left UUMINUS UUPLUS
%left '^'



%nonassoc Not '?'		/* le plus prioritaire */


%union {
	PNode uNode;
	char uChar[256];
	int uInt;
	char uReal[256];
}

%type <uChar> IDENTIFIER
%type <uChar> OBJECT
%type <uNode> catchstatement
%type <uChar> DECIMAL
%type <uChar> HEXADECIMAL
%type <uChar> OCTAL
%type <uChar> STRING
%type <uInt>  INTEGER
%type <uReal> REAL
%type <uNode> block
%type <uNode> program
%type <uNode> declaration
%type <uNode> decl_proc
%type <uNode> decl_func
%type <uNode> statement_list
%type <uNode> expression
%type <uNode> expression_fac
%type <uNode> statement
%type <uNode> assignment
%type <uNode> name
%type <uNode> ifstatement
%type <uNode> param
%type <uNode> suite_param
%type <uNode> statement_list_vide
%type <uNode> common_case
%type <uNode> procedurecall
%type <uNode> suite_call_list
%type <uNode> suite_call 
%type <uNode> fin_case
%type <uNode> case_suite
%type <uNode> case_else
%type <uNode> structure
%type <uNode> suite_cons
%type <uNode> ref_struct
%type <uNode> matrix
%type <uNode> suite_matrix
%type <uNode> param_matrix_suite
%type <uNode> param_matrix
%type <uNode> intervalle
%type <uNode> var_system
%type <uNode> integerAL
%type <uNode> suite_iden
%type <uNode> denotation
%type <uNode> casestatement
%type <uNode> repeatstatement
%type <uNode> forstatement
%type <uNode> whilestatement
%type <uNode> declarstat_list
%type <uNode> decl_stat
%type <uNode> gestion_erreur
%type <uNode> ref_struct_list
%type <uNode> functioncall_ou_ref_matrix
%type <uNode> parenthese
%type <uNode> suite_parenthese
%type <uNode> expression_times
%type <uNode> suite_if_else
%type <uNode> forward_func
%type <uNode> fin_block
%type <uNode> statement_list_case
%type <uNode> statement_list_ctrl
%type <uNode> ref_object
%type <uNode> proc_obj_call
%type <uNode> func_obj_call
%type <uNode> expression_master
%type <uNode> suite_ref_object
%type <uNode> compile_opt


%%
program : 
    block
    {root = $1;YYACCEPT;}
  ;

block	: 	  
    declarstat_list End block
    {$$ = creerNode(BLOCK,$1,$3);}
    | declarstat_list End
    {$$ = creerNode(BLOCK,$1,getNull());}
    | declarstat_list
    {$$ = creerNode(BLOCK,$1,getNull());}
    | Begin block End
    {$$=$2;}
  ;

declarstat_list :   	 
    decl_stat
    {$$=$1;}
    | declarstat_list decl_stat
    {$$ = creerNode(DECLARATION_LIST, $1, $2);}
  ;

decl_stat : 
    declaration
    {$$=$1;}
    | statement
    {$$=creerNode(STATEMENT_LIST, getNull(), $1);}
  ;

declaration :		
    decl_proc
    {$$=$1;}
    | decl_func
    {$$=$1;}
  ;

decl_proc :
    Pro IDENTIFIER suite_param statement_list_vide End
    {$$ = creerNodeString(DECLARATION_PROC, $3, $4, $2);}
    | Pro IDENTIFIER statement_list_vide End
    {$$ = creerNodeString(DECLARATION_PROC, getNull(), $3, $2);}
    | Pro IDENTIFIER ':' ':' IDENTIFIER suite_param statement_list_vide End
    {$$ = creerNodeString(DECL_PROC_OBJ, 
      	creerNodeString(DECLARATION_PROC, $6, $7, $5),getNull(), $2);}
    | Pro IDENTIFIER ':' ':' IDENTIFIER statement_list_vide End
    {$$ = creerNodeString(DECL_PROC_OBJ, 
      	creerNodeString(DECLARATION_PROC, getNull(), $6, $5),getNull(), $2);}
  ;

decl_func :	
    Function IDENTIFIER suite_param statement_list_vide End
    {$$ = creerNodeString(DECLARATION_FUNC, $3, $4, $2);}
    | Function IDENTIFIER statement_list_vide End
    {$$ = creerNodeString(DECLARATION_FUNC, getNull(), $3, $2);}
    | Function IDENTIFIER ':' ':' IDENTIFIER suite_param statement_list_vide End
    {$$ = creerNodeString(DECL_FUNC_OBJ, 
      	creerNodeString(DECLARATION_FUNC, $6, $7, $5),getNull(), $2);}
    | Function IDENTIFIER ':' ':' IDENTIFIER statement_list_vide End
    {$$ = creerNodeString(DECL_FUNC_OBJ, 
      	creerNodeString(DECLARATION_FUNC, getNull(), $6, $5),getNull(), $2);}
  ;

forward_func : 
    Forward_function suite_iden
    {$$ = creerNode(FORWARD_FUNCTION, getNull(), $2);}
  ;

compile_opt : 
    COMPILE_OPT suite_iden
    {$$ = creerNode(COMPILE_OPT, getNull(), $2);}
  ;

common_case :	  
    Common suite_iden
    {$$ = creerNode(COMMON_CASE, getNull(), $2);}
    | Common ',' suite_iden
    {$$ = creerNode(COMMON_CASE, $3, getNull());}
    ;

suite_iden :	  
    IDENTIFIER
    {$$=creerNodeString(IDENTIFIER, getNull(), getNull(), $1);}
    | IDENTIFIER ',' suite_iden
    {$$=creerNode(SUITE_IDENT, creerNodeString(IDENTIFIER, getNull(), getNull(),$1), $3);}
    ;

suite_param :	 
    ',' param
    {$$=$2;}
    | suite_param ',' param
    {$$=creerNode(SUITE_PARAM, $1, $3);}
    ;

param :    
    IDENTIFIER
    {$$=creerNode(PARAM, creerNodeString(IDENTIFIER, getNull(), getNull(), $1), getNull());}
    | IDENTIFIER '=' IDENTIFIER
    {$$=creerNode(PARAM, creerNodeString(IDENTIFIER, getNull(), getNull(), $1),
      creerNodeString(IDENTIFIER, getNull(), getNull(), $3));}
    | Extra '=' IDENTIFIER
    {$$=creerNode(PARAM, creerNodeString(IDENTIFIER, getNull(), getNull(), "I2M_EXTRA"),
      creerNodeString(IDENTIFIER, getNull(), getNull(), $3));}
    | Ref_Extra '=' IDENTIFIER
    {$$=creerNode(PARAM, creerNodeString(IDENTIFIER, getNull(), getNull(), "I2M_REF_EXTRA"),
      creerNodeString(IDENTIFIER, getNull(), getNull(), $3));}
    | Return '=' IDENTIFIER
    {$$=creerNode(PARAM, creerNodeString(IDENTIFIER, getNull(), getNull(), "RETURN"),
      creerNodeString(IDENTIFIER, getNull(), getNull(), $3));}
    ;

statement_list_ctrl : 
    Begin statement_list_vide fin_block
    {$$ = $2;}
    | statement
    {$$ = creerNode(STATEMENT_LIST, getNull(), $1);}
  ;

statement_list_vide : 	  
    statement_list
    {$$ = $1;}
    |
    {$$ = creerNode(STATEMENT_LIST, getNull(), getNull());}
    | Begin statement_list_vide fin_block
    {$$ = $2;}
  ;

statement_list :	  
    statement
    {$$ = creerNode(STATEMENT_LIST, getNull(), $1);}
    | statement_list statement
    {$$ = creerNode(STATEMENT_LIST, $1, $2);}
  ;

expression_master :
    expression_master '?' expression_master ':' expression_master
    {$$ = creerNode(INTERRO, creerNode(INTERRO, $1, $3), $5);}
    | expression
    {$$ = $1;}
  ;

parent :
    '('
    | SOL_PARENT
  ;

times :
    '*'
    | SOL_TIMES
  ;

expression : 
    expression Or expression
    {$$=creerNode(Or, $1, $3);}
    | expression And expression
    {$$=creerNode(And, $1, $3);}
    | expression LT expression
    {$$=creerNode(LT, $1, $3);}
    | expression GT expression
    {$$=creerNode(GT, $1, $3);}
    | expression LE expression
    {$$=creerNode(LE, $1, $3);}
    | expression GE expression
    {$$=creerNode(GE, $1, $3);}
    | expression EQ expression
    {$$=creerNode(EQ, $1, $3);}
    | expression NE expression
    {$$=creerNode(NE, $1, $3);}
    | expression '+' expression
    {$$=creerNode(PLUS, $1, $3);}
    | expression '-' expression
    {$$=creerNode(MINUS, $1, $3);}
    | expression '^' expression
    {$$=creerNode(PUISS, $1, $3);}
    | expression '*' expression
    {$$=creerNode(TIMES, $1, $3);}
    | expression SLASH expression
    {$$=creerNode(SLASH, $1, $3);}
    | expression Mod expression
    {$$=creerNode(Mod, $1, $3);}
    | expression DIESE expression
    {$$=creerNode(DIESE, $1, $3);}
    | expression DIESE2 expression
    {$$=creerNode(DIESE2, $1, $3);}
    | expression '<' expression
    {$$=creerNode(INF, $1, $3);}
    | expression '>' expression
    {$$=creerNode(SUP, $1, $3);}
    | expression XOR expression
    {$$=creerNode(XOR, $1, $3);}
    | Not expression
    {$$=creerNode(Not, $2, getNull());}
    | '-' expression %prec UUMINUS
    {$$=creerNode(UMINUS, $2, getNull());}
    | '+' expression %prec UUPLUS
    {$$=creerNode(UPLUS, $2, getNull());}
    | denotation
    {$$=$1;}
    | name FLECHE functioncall_ou_ref_matrix
    {$$ = creerNode(FLECHE, $1, $3);}    
    | name FLECHE func_obj_call
    {$$ = creerNode(FLECHE, $1, $3);}    
    | parenthese
    {$$=$1;}
    | functioncall_ou_ref_matrix
    {$$=$1;}
    | var_system
    {$$=$1;}
    | structure
    {$$=$1;}
    | matrix
    {$$=$1;}
    | integerAL
    {$$=$1;}
    | assignment
    {$$=$1;}
    | ref_struct_list
    {$$=$1;}
    | ref_object
    {$$=$1;}
  ;

statement :
    Begin statement_list_vide End
    {$$=$2;}   
    | catchstatement
    {$$=$1;}
    | ifstatement
    {$$=$1;}
    | casestatement
    {$$=$1;}
    | whilestatement
    {$$=$1;}
    | repeatstatement
    {$$=$1;}
    | forstatement
    {$$=$1;}
    | assignment
    {$$=$1;}
    | procedurecall
    {$$=$1;}
    | forward_func
    {$$=$1;}
    | compile_opt
    {$$=$1;}
    | common_case
    {$$=$1;}
    | gestion_erreur
    {$$=$1;}
    | Return ',' expression_master
    {$$ = creerNode(RETURN, $3, getNull());}
    | Return
    {$$ = creerNode(RETURN, getNull(), getNull());}
    | name FLECHE procedurecall
    {$$ = creerNode(FLECHE, $1, $3);}    
    | name FLECHE proc_obj_call
    {$$ = creerNode(FLECHE, $1, $3);}    
  ;

integerAL :	  
    DECIMAL
    {$$=creerNodeString(DECIMAL, getNull(), getNull(), $1);}
    | HEXADECIMAL
    {$$=creerNodeString(HEXADECIMAL, getNull(), getNull(), $1);}
    | OCTAL
    {$$=creerNodeString(OCTAL, getNull(), getNull(), $1);}
  ;

denotation :	 
    INTEGER
    {$$=creerNodeInt(INTEGER, getNull(), getNull(), $1);}
    | REAL
    {$$=creerNodeDouble(REAL, getNull(), getNull(), $1);}
    |IDENTIFIER
    {$$=creerNodeString(IDENTIFIER, getNull(), getNull(), $1);}
    | STRING
    {$$=creerNodeNormalString(STRING, getNull(), getNull(), $1);}
  ;

catchstatement : 
    Catch ',' suite_call
    {$$=creerNode(Catch,$3,getNull());}
  ;

proc_obj_call :
    IDENTIFIER ':' ':' procedurecall
    {$$=creerNodeString(METHODE_CALL, $4, getNull(), $1);}
  ;
  
func_obj_call :
    IDENTIFIER ':' ':' functioncall_ou_ref_matrix
    {$$=creerNodeString(METHODE_CALL, $4, getNull(), $1);}
  ;

procedurecall :	 
    IDENTIFIER ',' suite_call_list
    {$$=creerNodeString(PROCEDURE_CALL,$3,getNull(),$1);}
    |IDENTIFIER
    {$$=creerNodeString(PROCEDURE_CALL,getNull(),getNull(),$1);}
  ;

parenthese : 
    parent expression_master ')' suite_parenthese
    {$$=creerNode(PARENTHESE,$2,$4);}
  ;

suite_parenthese : 
    '(' suite_call_list ')'
    {$$=creerNode(PARENTHESE,$2,getNull());}
    | '[' suite_call_list ']'
    {$$=creerNode(PARENTHESE,$2,getNull());}
    | '.' '(' suite_call_list ')'
    {$$=creerNode(REF_STRUCT,$3,getNull());}
    |
    {$$=getNull();}
  ;

functioncall_ou_ref_matrix : 
    IDENTIFIER '(' suite_call_list ')' 
    {$$=creerNodeString(FUNCTION_CALL_OU_REF_MATRIX,$3,getNull(),$1);}
    |IDENTIFIER '[' suite_call_list ']' 
    {$$=creerNodeString(FUNCTION_CALL_OU_REF_MATRIX,$3,getNull(),$1);}
    |IDENTIFIER '(' ')'
    {$$=creerNodeString(FUNCTION_CALL,getNull(),getNull(),$1);}    
  ;


suite_call_list  :  
    suite_call
    {$$=$1;}
    | suite_call ',' suite_call_list
    {$$=creerNode(SUITE_CALL_LIST,$1,$3);}
  ;

suite_call :	  
    expression_master
    {$$=$1;}
    | IDENTIFIER '=' expression_master
    {$$=creerNodeString(IDENTIFIER,$3,getNull(),$1);}
    | Extra '=' expression_master
    {$$=creerNodeString(IDENTIFIER,$3,getNull(),"I2M_EXTRA");}
    | Ref_Extra '=' expression_master
    {$$=creerNodeString(IDENTIFIER,$3,getNull(),"I2M_REF_EXTRA");}
    | '*'
    {$$=creerNode(PARAM_MATRIX_ETOILE,getNull(),getNull());}
    | SLASH IDENTIFIER
    {$$=creerNodeString(SUITE_CALL,getNull(),getNull(),$2);}
    | SLASH Return
    {$$=creerNodeString(SUITE_CALL,getNull(),getNull(),"RETURN");}
    | intervalle
    {$$=$1;}
  ;

structure :    
    '{' suite_cons '}'
    {$$=creerNode(STRUCTURE,$2,getNull());}
    |'{' IDENTIFIER ',' suite_cons '}'
    {$$=creerNodeString(NAMED_STRUCTURE,$4,getNull(),$2);}
    |'{' IDENTIFIER ',' suite_call_list '}'
    {$$=creerNodeString(NAMED_STRUCTURE,$4,getNull(),$2);}
    | '{' IDENTIFIER '}'
    {$$=creerNodeString(STRUCTURE,getNull(),getNull(), $2);}
  ;

suite_cons :	  
    IDENTIFIER ':' expression_master
    {$$=creerNodeString(SUITE_CONS,$3,getNull(),$1);}
    | INHERITS  IDENTIFIER
    {$$=creerNodeString(SUITE_CONS,getNull(),getNull(),$2);}
    | IDENTIFIER ':' expression_master ',' suite_cons
    {$$=creerNodeString(SUITE_CONS,$3,$5,$1);}
    | INHERITS  IDENTIFIER ',' suite_cons
    {$$=creerNodeString(SUITE_CONS,getNull(),$4,$2);}
  ;

ref_object :
    times IDENTIFIER suite_ref_object
    {$$=creerNodeString(OBJECT,$3,getNull(),$2);}
    | parent '*' IDENTIFIER suite_parenthese ')' suite_ref_object
    {$$=creerNodeString(OBJECT,$6, $4,$3);}
    | parent ref_object ')'
    {$$=$2;}
    | times ref_object suite_ref_object
    {$$=creerNode(OBJECT,$2,getNull());}
    | parent '*' ref_object suite_parenthese ')' suite_ref_object
    {$$=creerNode(OBJECT,creerNode(OBJECT,$3, $6), $4);}
  ;    

suite_ref_object :
    '.' ref_struct
    {$$=$2;}
    | suite_parenthese
    {$$=$1;}
    | '.' ref_struct_list
    {$$=$2;}
    |
    {$$=getNull();}

ref_struct_list :  
    ref_struct '.'  ref_struct_list
    {$$=creerNode(REF_STRUCT_LIST,$1,$3);}
    | ref_struct '.'  ref_struct
    {$$=creerNode(REF_STRUCT,$1,$3);}
    | ref_struct '.'  '(' expression_master ')'
    {$$=creerNode(REF_STRUCT_PARENTHESE,$1,$4);}
  ;

ref_struct :    
    IDENTIFIER '(' suite_call_list ')'
    {$$=creerNodeString(IDENTIFIER_PARENTHESE,$3,getNull(),$1);}
    | IDENTIFIER '[' suite_call_list ']'
    {$$=creerNodeString(IDENTIFIER_PARENTHESE,$3,getNull(),$1);}
    | IDENTIFIER
    {$$=creerNodeString(IDENTIFIER,getNull(),getNull(),$1);}
    | parenthese
    {$$=$1;}

matrix		: 
    '[' suite_matrix ']'
    {$$=creerNode(MATRIX,$2,getNull());}
  ;

suite_matrix	:  
    expression_master
    {$$=$1;}
    | expression_master  ',' suite_matrix
    {$$=creerNode(SUITE_MATRIX,$1,$3);}
  ;

param_matrix_suite : 
    param_matrix
    {$$=$1;}
    | param_matrix ',' param_matrix_suite
    {$$=creerNode(PARAM_MATRIX_SUITE,$1,$3);}
  ;
  
param_matrix    : 
    expression_master
    {$$=$1;}
    | '*'
    {$$=creerNode(PARAM_MATRIX_ETOILE,getNull(),getNull());}
    | intervalle
    {$$=$1;}
  ;

intervalle	: 
    expression_master ':' expression_times
    {$$=creerNode(INTERVALLE,$1,$3);}
  ;

expression_times : 
    expression_master
    {$$=$1;}
    | '*'
    {$$=creerNode(PARAM_MATRIX_ETOILE,getNull(),getNull());}
  ;


var_system	: 
    '!' IDENTIFIER
    {$$=creerNodeString(VAR_SYSTEM,getNull(),getNull(),$2);}
    | '!' ref_struct_list
    {$$=creerNode(VAR_SYSTEM,$2,getNull());}
  ;


ifstatement	: 
    If expression_master Then statement_list_ctrl
    {$$=creerNode(If,$2,creerNode(Then,$4,getNull()));}
    |If expression_master Then statement_list_ctrl suite_if_else
    {$$=creerNode(If,$2,creerNode(Then,$4,creerNode(Else,$5,getNull())));}
  ;

suite_if_else : 
    Else statement_list_ctrl
    {$$=$2;}
    | Else ':' statement_list_case
    {$$=creerNode(CASE_ELSE,$3,getNull());}
  ;

casestatement 	: 
    Case expression_master Of case_suite case_else fin_case
    {$$=creerNode(CASE_STATEMENT,$2,creerNode(CASE_STATEMENT_SUITE,$4,$5));}
  ;

fin_case	: 
    Endcase
    {$$=getNull();}
    | End
    {$$=getNull();}
  ;

case_suite	:
    expression_master ':' case_suite
    {$$=creerNode(CASE_SUITE,$3, creerNode(CASE,$1,
      	  creerNode(STATEMENT_LIST, getNull(), getNull())));}
    | expression_master ':' statement_list_case case_suite
    {$$=creerNode(CASE_SUITE,$4, creerNode(CASE,$1,$3));}
    | expression_master ':' statement_list_case
    {$$=creerNode(CASE,$1,$3);}
  ;

statement_list_case : 

    {$$ = creerNode(STATEMENT_LIST, getNull(), getNull());}
    | Begin statement_list_vide fin_block
    {$$ = $2;}
    | statement
    {$$ = creerNode(STATEMENT_LIST, getNull(), $1);}
  ;

case_else	: 
    Else ':' statement_list_case
    {$$=creerNode(CASE_ELSE,$3,getNull());}
    |
    {$$=creerNode(CASE_ELSE,getNull(),getNull());}
  ;

whilestatement	: 
    While expression_master Do statement_list_ctrl
    {$$=creerNode(WHILE,$2,$4);}
  ;

repeatstatement : 
    Repeat statement_list_vide Until expression_master
    {$$=creerNode(REPEAT_STATEMENT,$2,$4);}
  ;

forstatement :	  
    For IDENTIFIER '=' expression_master ',' expression_master expression_fac Do statement_list_ctrl
    {$$=creerNode(FOR,creerNode(FOR_COND,
      creerNodeString(FOR_COND,$4,$6,$2),$7),$9);}
  ;

fin_block :  
    Endrep
    {$$=getNull();}
    |Endcase
    {$$=getNull();}
    |Endwhile
    {$$=getNull();}
    |Endelse
    {$$=getNull();}
    |Endif
    {$$=getNull();}
    | Endfor
    {$$=getNull();}
    | End
    {$$=getNull();}
  ;

expression_fac : 
    ',' expression_master
    {$$=$2;}
    |
    {$$=getNull();}
  ;

assignment :	  
    name '=' expression_master
    {$$=creerNode(ASSIGNMENT,$1,$3);}
    ;

name :	  
    IDENTIFIER
    {$$=creerNodeString(IDENTIFIER,getNull(),getNull(),$1);}
    | functioncall_ou_ref_matrix
    {$$=$1;}
    | ref_struct_list
    {$$=$1;}
    | var_system
    {$$=$1;}
    | ref_object
    {$$=$1;}
    | parenthese
    {$$=$1;}
  ;

gestion_erreur : 
    IDENTIFIER ':'
    {$$=creerNodeString(GESTION_ERREUR,getNull(),getNull(),$1);}
  ;


%%

/* les fonctions de construction de l'arbre abstrait */

extern Node *creerNode();
extern Node *creerNodeInt();
extern Node *creerNodeDouble();
extern Node *creerNodeString();
extern Node *getNull();
extern Node *creerNodeNormalString();
