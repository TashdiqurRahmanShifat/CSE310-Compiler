%{

#include<bits/stdc++.h>
#include"2005102.h"
using namespace std;

int yyparse(void) ; 
int yylex(void) ; 
 

int scope_id=1 ; 
int total_bucket=11; 
SymbolTable* symboltable = new SymbolTable(total_bucket);



extern FILE* yyin;
extern int lineNumber; 
extern int totalError; 





string name ;
string dataName;
string type;
string dataType;

struct var 
{
    string variableName ; 
    int variableSize ;
    string variableType;
}setVariableData;


struct parameter 
{
    string paramType ; 
    string paramName ; 
}setParamData;


vector<var>variableList;
vector<parameter>parameter_list; 
vector<string>argumentList; 
vector<SymbolInfo*>parseTreeChildren ; 


ofstream logFile;
ofstream errorFile; 
ofstream parseFile; 

string Upper(string token)
{
    string temp = "";
    int len  = token.length();
    for(int i=0;i<len;i++){
        temp+=toupper(token[i]);
    }
    return temp;
}


void startToEndLine(SymbolInfo* symbol,SymbolInfo* starting,SymbolInfo* ending)
{
    symbol->setStartLine(starting->getStartLine()) ; 
    symbol->setEndLine(ending->getEndLine()) ; 
} 


void parseChild(SymbolInfo* symbol,vector<SymbolInfo*>childrenList)
{
    symbol->addMultipleChildren(childrenList) ; 
    symbol->setLeaf(false) ; 
}

void addVar(string type,var varData)
{
    string str=Upper(type);
    SymbolInfo* symbol=new SymbolInfo(varData.variableName,str) ; 
    if(varData.variableType!="ARRAY")
    {
        symbol->setDataType(Upper(type)) ;
    } 
    else 
    {
        symbol->setType("ARRAY");
        symbol->setDataType(Upper(type));
    }
    symbol->setSize(varData.variableSize);
    symboltable->insert(*symbol); 
}

void addFunc(string type,string name,bool isDec,bool isDef)
{
    SymbolInfo* symbol=new SymbolInfo(name,"FUNCTION") ; 
    symbol->setDataType(type) ;  
    symbol->setDeclared(isDec) ; 
    symbol->setDefined(isDef);
    for(auto &param : parameter_list)
    {
        symbol->setParamInfo(param.paramName,param.paramType);
    }
    symboltable->insert(*symbol); 
}

void logPrint(ofstream &out,string msg)
{
    logFile<<msg<<endl; 
}

void yyerror(string err)
{
    totalError++ ; 
    errorFile<<"Line# "<<lineNumber<<": "<<err<<""<<endl ; 
    
}
 
%}
%union 
{
    SymbolInfo* symbol; 
}

%token<symbol>IF FOR DO VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE INT FLOAT ID 
%token<symbol>COMMA SEMICOLON LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD PRINTLN
%token<symbol>CONST_INT CONST_FLOAT 
%token<symbol>ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT INCOP DECOP BITOP
%type<symbol>start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements statement func_id
%type<symbol>declaration_list expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE 
%nonassoc ELSE 
%%
start : program 

        {   
            $$=new SymbolInfo("start","non-terminal");
            $$->setParseLine("start : program ");
            logPrint(logFile ,"start : program ");
            startToEndLine($$,$1,$1);  
            parseTreeChildren.clear();        
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);  
            $$->setSpaceCount(0) ; 
            $$->printParseTree(parseFile,0); 
                    
        }; 

program : program unit 
        
        {
                       
            $$=new SymbolInfo("program","non-terminal");
            $$->setParseLine("program : program unit "); 
            logPrint(logFile,"program : program unit "); 
            startToEndLine($$,$1,$2); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseChild($$,parseTreeChildren); 
                       
        }
        
        | 
        
        unit 
        
        {

            $$=new SymbolInfo("program","non-terminal");
            $$->setParseLine("program : unit "); 
            logPrint(logFile,"program : unit "); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren); 
        
        }; 

unit : var_declaration 
        
        {
            $$ = new SymbolInfo("unit","non-terminal");
            $$->setParseLine("unit : var_declaration ");           
            logPrint(logFile ,"unit : var_declaration  "); 
            startToEndLine($$,$1,$1) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);
                        
        }          
                        
        | 
        
        func_declaration 
        
        {

            $$ = new SymbolInfo("unit","non-terminal");
            $$->setParseLine("unit : func_declaration ");                    
            logPrint(logFile ,"unit : func_declaration "); 
            startToEndLine($$,$1,$1) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);
                        
        }
                        
        |
        
        func_definition
        
        {

            $$ = new SymbolInfo("unit","non-terminal");
            $$->setParseLine("unit : func_definition "); 
            logPrint(logFile ,"unit : func_definition  ");
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren) ; 
                        
        }; 

func_declaration : type_specifier func_id setfinaldata LPAREN parameter_list RPAREN declared SEMICOLON 
        
        { 
            $$=new SymbolInfo("func_declaration","non-terminal");
            $$->setParseLine("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "); 
            logPrint(logFile ,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "); 
            startToEndLine($$,$1,$8) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($4);
            parseTreeChildren.push_back($5);
            parseTreeChildren.push_back($6);
            parseTreeChildren.push_back($8);
            parseChild($$,parseTreeChildren);
            parameter_list.clear() ; 

        }
            
        |
        
        type_specifier func_id setfinaldata LPAREN RPAREN declared SEMICOLON 
        
        {
            $$ = new SymbolInfo($1->getName()+""+$2->getName()+$4->getName()+$5->getName()+$7->getName(),"FUNC_DECLARATION"); 
            $$->setParseLine("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON ");
            logPrint(logFile ,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "); 
            startToEndLine($$,$1,$7) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($4);
            parseTreeChildren.push_back($5);
            parseTreeChildren.push_back($7);
            parseChild($$,parseTreeChildren) ;

            parameter_list.clear() ; 
                        
        }; 

func_definition : type_specifier func_id setfinaldata LPAREN parameter_list RPAREN defined compound_statement
        
        {
            $$=new SymbolInfo("func_definition","non-terminal");
            $$->setParseLine("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "); 
            logPrint(logFile ,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement ");    
            startToEndLine($$,$1,$8) ; 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($4);
            parseTreeChildren.push_back($5);
            parseTreeChildren.push_back($6);
            parseTreeChildren.push_back($8);
            parseChild($$,parseTreeChildren);

        }
                        
        |
        
        type_specifier func_id setfinaldata LPAREN RPAREN defined compound_statement
                        
        {
            $$=new SymbolInfo("func_definition","non-terminal");
            $$->setParseLine("func_definition : type_specifier ID LPAREN RPAREN compound_statement ");
            logPrint(logFile ,"func_definition : type_specifier ID LPAREN RPAREN compound_statement");    
            startToEndLine($$,$1,$7); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($4);
            parseTreeChildren.push_back($5);
            parseTreeChildren.push_back($7);
            parseChild($$ , parseTreeChildren);
                        
        };


setfinaldata:
    
    {   
        dataType=type; 
        dataName=name;
    };

parameter_list : parameter_list COMMA type_specifier ID
        
        { 
            $$=new SymbolInfo("parameter_list","non-terminal");
            $$->setParseLine("parameter_list : parameter_list COMMA type_specifier ID ");
            logPrint(logFile ,"parameter_list  : parameter_list COMMA type_specifier ID");    
            for(auto &param : parameter_list)
            {
                if(param.paramName == $4->getName())
                {
                    string errmsg="Redefinition of parameter '"+$4->getName()+"'";
                    yyerror(errmsg);
                }
            }
            setParamData.paramType = $3->getType(); 
            setParamData.paramName = $4->getName(); 
            parameter_list.push_back(setParamData); 
            startToEndLine($$,$1,$4); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($4);
            parseChild($$ , parseTreeChildren) ;
                        
        }
                        
        |
        
        parameter_list COMMA type_specifier
                        
        { 
            $$=new SymbolInfo("parameter_list","non-terminal"); 
            $$->setParseLine("parameter_list : parameter_list COMMA type_specifier ");
            logPrint(logFile,"parameter_list  : parameter_list COMMA type_specifier ");    
            setParamData.paramType=$3->getType(); 
            setParamData.paramName="";  
            parameter_list.push_back(setParamData); 
            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$ , parseTreeChildren) ;
                         
        }
                        
        |
        
        type_specifier ID 
                        
        {
            $$=new SymbolInfo("parameter_list","non-terminal");
            $$->setParseLine("parameter_list : type_specifier ID ");  
            logPrint(logFile ,"parameter_list  : type_specifier ID");   
            setParamData.paramType = $1->getType();  
            setParamData.paramName = $2->getName(); 
            parameter_list.push_back(setParamData); 
            startToEndLine($$,$1,$2) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseChild($$ , parseTreeChildren) ;
                        
        }
        
        |
        
        type_specifier 
        
        {
            $$=new SymbolInfo($1->getName(),"non-terminal");
            logPrint(logFile ,"parameter_list : type_specifier ");    
            setParamData.paramType = $1->getType(); 
            setParamData.paramName =""; 
            parameter_list.push_back(setParamData);           
            $$->setParseLine("parameter_list : type_specifier ");                
            startToEndLine($$,$1,$1); 
            vector<SymbolInfo*> parseTreeChildren; 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);
        }; 
    
compound_statement : LCURL new_scope statements RCURL
        
        {
            $$=new SymbolInfo("compound_statement","non-terminal"); 
            $$->setParseLine("compound_statement : LCURL statements RCURL ");
            logPrint(logFile ,"compound_statement : LCURL statements RCURL  ");   
            symboltable->print_all_scope_table(logFile); 
            symboltable->Exit_scope(logFile); 
            startToEndLine($$,$1,$4);
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1); 
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($4);
            parseChild($$ , parseTreeChildren);
                                
        }
                        
        |
        
        LCURL new_scope RCURL
                        
        {
            $$=new SymbolInfo("compound_statement","non-terminal");
            $$->setParseLine("compound_statement : LCURL  RCURL ");
            logPrint(logFile ,"compound_statement : LCURL  RCURL ");   
            symboltable->print_all_scope_table(logFile); 
            symboltable->Exit_scope(logFile); 
            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($3);
            parseChild($$ , parseTreeChildren);
                        
        };

new_scope: 
    {
        scope_id++;
        symboltable->Enter_scope(scope_id,total_bucket); 
        if(parameter_list.size()==1 && parameter_list[0].paramType=="void"){}
        else 
        {
            for (auto &param : parameter_list)
            {
                setVariableData.variableName=param.paramName;
                setVariableData.variableSize=-1;    
                addVar(param.paramType, setVariableData);
            }
        }
        parameter_list.clear();

    }
var_declaration : type_specifier declaration_list SEMICOLON
        
        {
            $$=new SymbolInfo("var_declaration","non-terminal");
            $$->setParseLine("var_declaration : type_specifier declaration_list SEMICOLON ");
            logPrint(logFile ,"var_declaration : type_specifier declaration_list SEMICOLON  ");  
            if($1->getName()=="void")
            { 
                string errmsg="Variable or field '"+$2->getName()+"' declared void";
                yyerror(errmsg);
            }
            else 
            {
                string sname=$1->getName(); 
                for(int i=0;i<variableList.size();i++)
                    addVar(sname, variableList[i]); 
            }                        
                        
            variableList.clear() ;    
            startToEndLine($$,$1,$3) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$ , parseTreeChildren);
        }; 

type_specifier : INT

        {
            type="INT";
            $$=new SymbolInfo($1->getName(), $1->getType());
            $$->setParseLine("type_specifier : INT "); 
            logPrint(logFile ,"type_specifier	: INT ");  
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);
        
        }    
                
        |
        
        FLOAT
        
        {
                    
            type ="FLOAT";
            $$ = new SymbolInfo($1->getName(), $1->getType());
            $$->setParseLine("type_specifier : FLOAT ");       
            logPrint(logFile ,"type_specifier	: FLOAT ");  
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);

        }
                
        |
        
        VOID
                
        {
            type="VOID";
            $$=new SymbolInfo($1->getName(),$1->getType());
            $$->setParseLine("type_specifier : VOID ");        
            logPrint(logFile ,"type_specifier	: VOID"); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);
        
        };

func_id: ID 
        {

            $$ = new SymbolInfo($1->getName(),$1->getType());
            name = $1->getName(); 
            string msg="ID : "+name; 
            $$->setParseLine(msg); 
            startToEndLine($$,$1,$1);  
            $$->setLeaf(true);
        
        }

declaration_list : declaration_list COMMA ID 
        
        { 
            $$=new SymbolInfo($1->getName() + $2->getName()+$3->getName(),"non-terminal");
            $$->setParseLine("declaration_list : declaration_list COMMA ID ");
            logPrint(logFile ,"declaration_list : declaration_list COMMA ID  "); 
            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$,parseTreeChildren); 
            setVariableData.variableName=$3->getName(); 
            setVariableData.variableSize=-1;  
            variableList.push_back(setVariableData); 
            SymbolInfo* symbol=symboltable->LookUp($3->getName());
            if(symbol!=nullptr)
            {
                if(symboltable->getscopeID(symbol->getName(),logFile)==symboltable->currScopeID())
                {
                    string errmsg = "Conflicting types for'"+$3->getName()+"'" ; 
                    yyerror(errmsg) ;
                }
            }

            for(int i=0;i<variableList.size()-1;i++)
            {
                if($3->getName()==variableList[i].variableName)
                {
                    string errmsg = "Redefination of variable name '"+$3->getName()+"'";
                    yyerror(errmsg) ;
                }                 
                            
            }
                        
        }
                        
        |
        
        declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
        
        {
            $$=new SymbolInfo($1->getName() + $2->getName() +$3->getName() + $4->getName()+ $5->getName() + $6->getName(),"non-terminal");
            $$->setParseLine("declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE ");
            logPrint(logFile ,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE ");
                        
                        
            setVariableData.variableName = $3->getName() ; 
            setVariableData.variableType = "ARRAY"; 
            setVariableData.variableSize=stoi($5->getName()); 
            variableList.push_back(setVariableData); 
            setVariableData.variableType="";
            SymbolInfo* symbol=symboltable->LookUp($3->getName());
            if(symbol!=nullptr)
            {
                if(symboltable->getscopeID(symbol->getName(),logFile)==symboltable->currScopeID())
                {
                    string errmsg="Conflicting types for'"+$3->getName()+"'"; 
                    yyerror(errmsg);
                }
            }

            for(int i=0;i<variableList.size()-1;i++)
            {
                if($3->getName()==variableList[i].variableName)
                {
                    string errmsg = "Redefination of variable name '"+$3->getName()+"'";
                    yyerror(errmsg) ;
                }                 
                            
            }
            startToEndLine($$,$1,$6) ; 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($4);
            parseTreeChildren.push_back($5);
            parseTreeChildren.push_back($6);
            parseChild($$ , parseTreeChildren);

        }
                        
        |
        
        ID
        
        {
            $$=new SymbolInfo($1->getName(),"non-terminal");
            logPrint(logFile ,"declaration_list : ID "); 
                    
            setVariableData.variableName=$1->getName(); 
            setVariableData.variableSize=-1; 
            variableList.push_back(setVariableData); 

            SymbolInfo* symbol = symboltable->LookUp($1->getName());
            if(symbol!=nullptr)
            {
                if(symboltable->getscopeID(symbol->getName() , logFile) == symboltable->currScopeID())
                {
                    string errmsg = "Conflicting types for'"+$1->getName()+"'"; 
                    yyerror(errmsg) ;
                }
            }
            for(int i=0;i<variableList.size()-1;i++)
            {
                if($1->getName()==variableList[i].variableName)
                {
                    string errmsg = "Redefination of variable name '"+$1->getName()+"'";
                    yyerror(errmsg);
                }                 
                            
            }

            $$->setParseLine("declaration_list : ID ");   
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);

        }
                        
        |
        
        ID LTHIRD CONST_INT RTHIRD
        
        {
            $$=new SymbolInfo($1->getName()+ $2->getName()+$3->getName()+ $4->getName(),"non-terminal");
            logPrint(logFile ,"declaration_list : ID LSQUARE CONST_INT RSQUARE ") ; 
                       
            setVariableData.variableName=$1->getName() ; 
            setVariableData.variableType="ARRAY"; 
            setVariableData.variableSize=stoi($3->getName());  
            variableList.push_back(setVariableData); 
            setVariableData.variableType="";
            SymbolInfo* symbol=symboltable->LookUp($1->getName());
            if(symbol!=nullptr)
            {
                if(symboltable->getscopeID(symbol->getName(),logFile)==symboltable->currScopeID())
                {
                    string errmsg = "Conflicting types for'"+$1->getName()+"'"; 
                    yyerror(errmsg) ;
                }
            }
            for(int i=0;i<variableList.size()-1;i++)
            {

                if($1->getName()==variableList[i].variableName)
                { 
                    string errmsg="Redefination of variable name '"+$1->getName()+"'";
                    yyerror(errmsg);
                }
            }
            $$->setParseLine("declaration_list : ID LSQUARE CONST_INT RSQUARE ");   
            startToEndLine($$,$1,$4) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($4);
            parseChild($$ , parseTreeChildren);
                        
        }; 

statements : statement 

        {
            $$=new SymbolInfo("statements","non-terminal");
            $$->setParseLine("statements : statement ");
            logPrint(logFile ,"statements : statement  ");
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);
        
        }
                        
        | 
        
        statements statement 
        
        { 
            $$=new SymbolInfo("statements","non-terminal");
            $$->setParseLine("statements : statements statement ");
            logPrint(logFile ,"statements : statements statement  "); 
            startToEndLine($$,$1,$2) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseChild($$,parseTreeChildren);

        }

statement : var_declaration
 
        {  
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : var_declaration ");
            logPrint(logFile ,"statement : var_declaration "); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);

        }
                        
        |
        
        expression_statement 
        
        {
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : expression_statement ");
            logPrint(logFile ,"statement : expression_statement  "); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);

        } 
                        
        |
        
        compound_statement 
        
        { 
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : compound_statement ");
            logPrint(logFile ,"statement : compound_statement "); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);
        
        }
        
        |
        
        FOR LPAREN expression_statement to_data_type void_data expression_statement to_data_type void_data expression to_data_type void_data RPAREN statement
        
        {
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement ");
            logPrint(logFile ,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");  
            startToEndLine($$,$1,$13); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($6);
            parseTreeChildren.push_back($9);
            parseTreeChildren.push_back($12);
            parseTreeChildren.push_back($13);
            parseChild($$ , parseTreeChildren);
                        
                          
        }
                        
        |
        
        IF LPAREN expression to_data_type RPAREN void_data statement %prec LOWER_THAN_ELSE
                        
        {
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : IF LPAREN expression RPAREN statement ");
            logPrint(logFile ,"statement : IF LPAREN expression RPAREN statement %prec THEN"); 
            startToEndLine($$,$1,$7); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($5);
            parseTreeChildren.push_back($7);
            parseChild($$ , parseTreeChildren);  
                        
        }
                        
        |
        
        IF LPAREN expression to_data_type RPAREN void_data statement ELSE statement
        
        { 
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : IF LPAREN expression RPAREN statement ELSE statement ");
            logPrint(logFile ,"statement : IF LPAREN expression RPAREN statement ELSE statement ");   
            startToEndLine($$,$1,$9); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($5);
            parseTreeChildren.push_back($7);
            parseTreeChildren.push_back($8);
            parseTreeChildren.push_back($9);
            parseChild($$ , parseTreeChildren); 
        
        }
                        
        |
        
        WHILE LPAREN expression to_data_type RPAREN  void_data statement
        
        {
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : WHILE LPAREN expression RPAREN statement ");
            logPrint(logFile ,"statement : WHILE LPAREN expression RPAREN statement");   
            startToEndLine($$,$1,$7); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($5);
            parseTreeChildren.push_back($7);
            parseChild($$ , parseTreeChildren); 
        
        }
                        
        |
        
        PRINTLN LPAREN ID RPAREN SEMICOLON
        
        {
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : PRINTLN LPAREN ID RPAREN SEMICOLON ");
            logPrint(logFile ,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON ") ;  
            startToEndLine($$,$1,$5) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($4);
            parseTreeChildren.push_back($5);
            parseChild($$ , parseTreeChildren) ;
        }
        
        |
        
        RETURN expression SEMICOLON
        
        {
            $$=new SymbolInfo("statement","non-terminal");
            $$->setParseLine("statement : RETURN expression SEMICOLON ");
            logPrint(logFile ,"statement : RETURN expression SEMICOLON") ; 
            startToEndLine($$,$1,$3) ; 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$ , parseTreeChildren) ; 
            if($2->getType()=="VOID") 
            {
                string errmsg = "Void cannot be used in expression " ;
                yyerror(errmsg) ; 
            }   
        };

to_data_type:
        
        {
            dataType=type; 
        }

expression_statement : SEMICOLON 
        
        {
            
            $$=new SymbolInfo($1->getName(),$1->getType());
            $$->setParseLine("expression_statement : SEMICOLON ");
            logPrint(logFile ,"	expression_statement : SEMICOLON		");    
            $$->setDataType($1->getDataType()); 
            type=$1->getDataType();
            startToEndLine($$,$1,$1); 
            vector<SymbolInfo*> parseTreeChildren; 
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);  

        }
            
        |
        
        expression SEMICOLON 
            
        {
            $$=new SymbolInfo("expression_statement","non-terminal");
            $$->setParseLine("expression_statement : expression SEMICOLON ");
            logPrint(logFile ,"expression_statement : expression SEMICOLON 		 ");    
            $$->setType($1->getType());
            type = $1->getType();
            startToEndLine($$,$1,$2); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseChild($$,parseTreeChildren);
            
        }; 

variable : ID 
            
        {
            name = $1->getName(); 
            $$ = new SymbolInfo($1->getName(),"ID");
            $$->setParseLine("variable : ID ");
            logPrint(logFile ,"variable : ID 	 "); 
            startToEndLine($$,$1,$1) ; 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);

            SymbolInfo* symbol=symboltable->LookUp($1->getName()); 
            if(symbol==nullptr) 
            {
                string errmsg="Undeclared variable '"+$1->getName()+"'"; 
                yyerror(errmsg); 
            }
            else 
            {
                if(symbol->getDataType()!="VOID") $$->setDataType(symbol->getDataType()) ;
            }
        }
        
        |
        
        ID LTHIRD expression RTHIRD
            
        {

            $$ = new SymbolInfo($1->getName()+$2->getName()+$3->getName()+$4->getName(),"ARRAY");
            $$->setParseLine("variable : ID LSQUARE expression RSQUARE ");
            logPrint(logFile ,"variable : ID LSQUARE expression RSQUARE  	 "); 
            SymbolInfo* symbol=symboltable->LookUp($1->getName());
            if(symbol==nullptr)
            {
                string errmsg  = "Undeclared variable '"+$1->getName()+"'"; 
                yyerror(errmsg) ; 
            }
            else 
            {
                if(symbol->isArray()) 
                {   
                    if(symbol->getDataType()!="VOID") 
                    {
                        $$->setDataType(symbol->getDataType());
                    } 
                }
                else 
                {
                    string errmsg="'"+$1->getName()+"' is not an array"; 
                    yyerror(errmsg);   
                } 
            } 
            if($3->getDataType()!="INT"&&$3->getDataType()!="CONST_INT")
            {
                string errmsg="Array subscript is not an integer" ;  
                yyerror(errmsg) ;  
            }
            
            startToEndLine($$,$1,$4) ; 
            vector<SymbolInfo*> parseTreeChildren ; 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($4);
            parseChild($$ , parseTreeChildren) ;
            
            
        }; 

void_data :
        {
            if(dataType=="VOID")
            {
                string errmsg="Void cannot be used in expression ";
                yyerror(errmsg); 
            }
        }

expression : logic_expression 
        
        {
            $$=new SymbolInfo("expression","non-terminal");
            $$->setDataType($1->getDataType()); 
            $$->setParseLine("expression : logic_expression ");
            logPrint(logFile ,"expression 	: logic_expression	 "); 
            type=$1->getDataType(); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);
        }

        |
        
        variable ASSIGNOP logic_expression
            
        {
            $$ = new SymbolInfo($1->getName()+$2->getName()+$3->getName(),$3->getType());
            $$->setParseLine("expression : variable ASSIGNOP logic_expression ");
            logPrint(logFile ,"expression 	: variable ASSIGNOP logic_expression 		 "); 
            if($1->getDataType()=="INT"&&$3->getDataType()=="FLOAT") 
            {
                string errmsg ="Warning: possible loss of data in assignment of "+ $3->getDataType() + " to " + $1->getDataType();
                yyerror(errmsg) ;
            }

            if($3->getDataType()=="VOID")
            {
                string errmsg = "Void cannot be used in expression " ;
                yyerror(errmsg) ; 
            }
            startToEndLine($$,$1,$3) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$ , parseTreeChildren) ;
            $$->setDataType($1->getDataType()) ; 
            type = $1->getDataType() ; 
        
        }; 

logic_expression : rel_expression 
        
        {
            $$ = new SymbolInfo($1->getName() ,"");
            $$->setParseLine("logic_expression : rel_expression ");
            logPrint(logFile ,"logic_expression : rel_expression 	 "); 
            $$->setDataType($1->getDataType()); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);
            
        }
            
        |
        
        rel_expression LOGICOP rel_expression
            
        {
            $$ = new SymbolInfo($1->getName()+$2->getName()+$3->getName(),""); 
            $$->setParseLine("logic_expression : rel_expression LOGICOP rel_expression ");
            logPrint(logFile ,"logic_expression : rel_expression LOGICOP rel_expression 	 	 ");  
            $$->setDataType($1->getType()); 
            if($1->getDataType()=="VOID") 
            {
                string errmsg="Void cannot be used in expression ";
                yyerror(errmsg); 
            }

            if($3->getDataType()=="VOID") 
            {
                string errmsg="Void cannot be used in expression ";
                yyerror(errmsg);
            }
            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$ , parseTreeChildren);
        }; 

rel_expression : simple_expression
        
        {
            $$=new SymbolInfo("rel_expression","non-terminal");
            $$->setParseLine("rel_expression : simple_expression ");
            logPrint(logFile ,"rel_expression	: simple_expression "); 
            $$->setDataType($1->getDataType()); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);
        
        }
            
        |
        
        simple_expression RELOP simple_expression
        
        {
            $$=new SymbolInfo("rel_expression","non-terminal");
            $$->setParseLine("rel_expression : simple_expression RELOP simple_expression ");
            logPrint(logFile ,"rel_expression	: simple_expression RELOP simple_expression	  ");   
            $$->setDataType($1->getDataType());  
            if($1->getDataType()=="VOID") 
            {
                string errmsg = "Void cannot be used in expression ";
                yyerror(errmsg);
            }

            if($3->getDataType()=="VOID") 
            {
                string errmsg = "Void cannot be used in expression ";
                yyerror(errmsg);
            }

            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$ , parseTreeChildren);
            
        }; 


declared: 
    
    {
        SymbolInfo* symbol=symboltable->LookUp(dataName); 
        if(symbol==nullptr)
        {
            addFunc(dataType,dataName,true,false);
        }
        else 
        {
            if(symbol->isFunction())
            {
                string errmsg="Multiple Declaration of function "+dataName;
                yyerror(errmsg) ; 
            }
            else 
            {
                string errmsg ="'"+dataName+"' redeclared as different kind of symbol"; 
                yyerror(errmsg) ;
            }
        }
    }; 

simple_expression : term 
        
        {
            $$=new SymbolInfo("simple_expression","non-terminal");
            $$->setParseLine("simple_expression : term ");
            logPrint(logFile ,"simple_expression : term ");  
            $$->setDataType($1->getDataType()); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);
        
        }
        
        |
        
        simple_expression ADDOP term
            
        {
            $$=new SymbolInfo("simple_expression","non-terminal");
            logPrint(logFile ,"simple_expression : simple_expression ADDOP term  ");
            if($1->getDataType()=="VOID")
            {
                string errmsg = "Void cannot be used in expression ";
                yyerror(errmsg);
            }
            if($3->getDataType()=="VOID")
            {
                string errmsg = "Void cannot be used in expression ";
                yyerror(errmsg);
            }
            else 
            {
                $$->setDataType($1->getDataType());
            }

            $$->setParseLine("simple_expression : simple_expression ADDOP term ");
            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$,parseTreeChildren);
            
        };


defined :   
    
    {
        SymbolInfo* symbol=symboltable->LookUp(dataName); 
        if(symbol==nullptr)
        {
            addFunc(dataType,dataName,false,true); 
        }
        else if(symbol->isFunction())
        {
            if(symbol->isDeclared()&&!symbol->isDefined())  
            {
                if(symbol->getDataType()==dataType) 
                {
                    if(symbol->getParamCount()==parameter_list.size())
                    {  
                        if(symbol->getParamCount()==0)
                        {
                            addFunc(dataType,dataName,true,true);
                        } 
                        else 
                        {
                            int err=0;
                            for(int i=0 ; i<parameter_list.size(); i++)
                            { 
                                if((symbol->useParamIndex(i)).paramType!=parameter_list[i].paramType)
                                {
                                    err=1;
                                }
                            }

                            if(err)
                            {
                                string errmsg="Conflicting types for '"+dataName+"'";
                                yyerror(errmsg); 
                            }
                            if(err==0) 
                            {
                                addFunc(dataType,dataName,true,true);
                            } 
                        }
                    
                    }
                    else 
                    {    
                        string errmsg="Conflicting types for '"+dataName+"'";
                        yyerror(errmsg); 
                    }
                }
                else 
                { 
                    string errmsg="Conflicting types for '"+dataName+"'"; 
                    yyerror(errmsg) ; 
                }
            }
            else if(symbol->isDefined())  
            {
                string errmsg = "Redifinition of function '"+dataName+"'"; 
                yyerror(errmsg); 
            }
        }
        else 
        {
            string errmsg ="'" + dataName + "' redeclared as different kind of symbol";
            yyerror(errmsg);
        }
    };

 term : unary_expression
        
        {
            $$=new SymbolInfo("term","non-terminal");
            logPrint(logFile ,"term :	unary_expression ");   
            $$->setDataType($1->getDataType());

            $$->setParseLine("term : unary_expression ");
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);
        }
            
        | 
        
        term MULOP unary_expression
            
        {
            $$=new SymbolInfo("term","non-terminal");
            $$->setParseLine("term : term MULOP unary_expression ");
            logPrint(logFile ,"term :	term MULOP unary_expression ");
            if($1->getDataType()=="VOID")
            {
                string errmsg = "Void cannot be used in expression ";
                yyerror(errmsg);
            }
            if($3->getDataType()=="VOID")
            {
                string errmsg="Void cannot be used in expression ";
                yyerror(errmsg);
            }
            
            if( $2->getName() =="%" &&($1->getDataType()!="INT" || $3->getDataType()!="INT"))   
            { 
                string errmsg="Operands of modulus must be integers "; 
                yyerror(errmsg); 
                $$->setDataType("INT");

            } 

            else { $$->setDataType($1->getDataType());}
            if($3->getName()=="0"&&($2->getName()=="/"||$2->getName()=="%")) 
            {
                string errmsg="Warning: division by zero i=0f=1Const=0";
                yyerror(errmsg); 
            }
            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$ , parseTreeChildren);
        
        };

unary_expression : ADDOP unary_expression 
        
        {
            $$=new SymbolInfo("unary_expression","non-terminal");
            logPrint(logFile ,"unary_expression : ADDOP unary_expression ");
            if($2->getDataType()=="VOID")
            {
                string errmsg = "Void cannot be used in expression ";
                yyerror(errmsg); 
            }
            else $$->setDataType($2->getDataType());
            $$->setParseLine("unary_expression : ADDOP unary_expression ");
            startToEndLine($$,$1,$2); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseChild($$ , parseTreeChildren);
            
        }

        |
        
        NOT unary_expression
        
        {
            $$=new SymbolInfo("unary_expression","non-terminal");
            $$->setParseLine("unary_expression : NOT unary_expression ");
            logPrint(logFile ,"unary_expression : NOT unary_expression  ");
            if($2->getDataType()=="VOID")
            {
                string errmsg="Void cannot be used in expression " ;
                yyerror(errmsg); 
            }
            $$->setDataType("INT"); 
            startToEndLine($$,$1,$2); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseChild($$,parseTreeChildren);
        }

        |
        
        factor
        
        {
                
            $$=new SymbolInfo($1->getName() ,"UNARY_EXPRESSION");
            logPrint(logFile ,"unary_expression : factor ");
            $$->setDataType($1->getDataType());
            $$->setParseLine("unary_expression : factor ");
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);
        };

factor: variable 
        
        {
            $$=new SymbolInfo("factor","non-terminal");
            logPrint(logFile ,"factor	: variable "); 
            $$->setDataType($1->getDataType());
            $$->setParseLine("factor : variable ");
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);

        }
                 
        |
        
        ID LPAREN argument_list RPAREN
        
        {
            $$=new SymbolInfo("factor","non-terminal");
            $$->setParseLine("factor : ID LPAREN argument_list RPAREN ");
            logPrint(logFile ,"factor	: ID LPAREN argument_list RPAREN  ") ;
            SymbolInfo* symbol=symboltable->LookUp($1->getName()); 
            if(symbol==nullptr)
            {
                string errmsg = "Undeclared function '"+$1->getName()+"'"; 
                yyerror(errmsg) ; 
                        
            }
            else if(symbol->isDefined()!=true)
            { 
                string errmsg="Undefined function '"+$1->getName()+"'";
                yyerror(errmsg); 
            } 
            else if(symbol->isDefined()!=true)
            { 
                string errmsg = "Undefined function '"+$1->getName()+"'"; 
                yyerror(errmsg) ; 
            } 
            else 
            {
                if(symbol->getParamCount()!=argumentList.size())
                {
                    if(symbol->getParamCount()>argumentList.size())
                    {
                        string errmsg ="Too few arguments to function '"+$1->getName()+"'";
                        yyerror(errmsg); 
                    }
                    else if(symbol->getParamCount()<argumentList.size())
                    {
                        string errmsg ="Too many arguments to function '"+$1->getName()+"'";
                        yyerror(errmsg); 
                    }
                }
                else 
                {
                    vector<int>v; 
                    int tem=0;
                    int i = 0;
                    for(auto &argument : argumentList)
                    {
                        string str = "";
                        if (argument == "CONST_INT")
                            str = "INT";
                        else if (argument == "CONST_FLOAT")
                            str = "FLOAT";
                        else
                            str = argument;

                        if (Upper(symbol->useParamIndex(i).paramType) != str)
                        {
                            v.push_back(i+1);
                            tem++;
                        }
                        i++;
                    }

                    for(int i=0;i<tem;i++)
                    {
                        string errmsg = "Type mismatch for argument "+to_string(v[i])+" of '"+$1->getName()+"'" ;
                        yyerror(errmsg) ; 
                    }
                    $$->setDataType(symbol->getDataType());
                }
            }
            argumentList.clear(); 

            startToEndLine($$,$1,$4) ; 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseTreeChildren.push_back($4);
            parseChild($$,parseTreeChildren);
                
        }
        
        |
        
        LPAREN expression RPAREN
        
        {
            $$=new SymbolInfo("factor","non-terminal");
            $$->setParseLine("factor : LPAREN expression RPAREN ");
            logPrint(logFile ,"factor	: LPAREN expression RPAREN   ");
            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$,parseTreeChildren);
            if($2->getDataType()=="VOID")
            {
                string errmsg="Void cannot be used in expression ";
                yyerror(errmsg); 
            }

        }
        
        |
        
        CONST_INT
        
        {

            $$=new SymbolInfo($1->getName() ,"CONST_INT");
            $$->setParseLine("factor : CONST_INT ");
            logPrint(logFile ,"factor	: CONST_INT   "); 
            $$->setDataType("INT"); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren) ;
        }
                
        |
        
        CONST_FLOAT
        
        {
            $$ = new SymbolInfo($1->getName() ,"CONST_FLOAT");
            $$->setParseLine("factor : CONST_FLOAT ");
            logPrint(logFile ,"factor	: CONST_FLOAT   "); 
            $$->setDataType("FLOAT");
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseChild($$,parseTreeChildren);
        
        }
                
        |
        
        variable INCOP
        
        {
            $$=new SymbolInfo("factor","non-terminal");
            $$->setDataType($1->getDataType());
            $$->setParseLine("factor : variable INCOP "); 
            logPrint(logFile ,"factor	: variable INCOP   ");
            startToEndLine($$,$1,$2);  
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseChild($$ , parseTreeChildren);
        }
                
        |
        
        variable DECOP
        
        {
            $$=new SymbolInfo("factor","non-terminal");
            $$->setParseLine("factor : variable DECOP "); 
            logPrint(logFile ,"factor	: variable DECOP   ");
            $$->setDataType($1->getDataType()); 
            startToEndLine($$,$1,$2) ; 
            parseTreeChildren.clear();
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseChild($$ , parseTreeChildren); 
        
        };

argument_list : arguments 
        
        {
            $$=new SymbolInfo("argument_list","non-terminal");
            $$->setParseLine("argument_list : arguments ");
            logPrint(logFile ,"argument_list : arguments  "); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren);
        }
        
        |
                
        {
            $$=new SymbolInfo("argument_list","non-terminal");
            logPrint(logFile ,"argument_list :");
        };

arguments : arguments COMMA logic_expression
        
        {
            $$=new SymbolInfo("arguments","non-terminal");
            $$->setParseLine("arguments : arguments COMMA logic_expression ");
            logPrint(logFile,"arguments : arguments COMMA logic_expression ");
            startToEndLine($$,$1,$3); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseTreeChildren.push_back($2);
            parseTreeChildren.push_back($3);
            parseChild($$,parseTreeChildren);
            if($3->getDataType()=="VOID")
            {
                string errmsg = "Void cannot be used in expression ";
                yyerror(errmsg); 
            }
            else 
            {
                $1->setDataType($3->getDataType()) ; 
            }
            argumentList.push_back($1->getDataType());   
        }
                
        |
        
        logic_expression
                
        {
            $$ = new SymbolInfo($1->getName(),$1->getType());
            $$->setParseLine("arguments : logic_expression ");
            logPrint(logFile ,"arguments : logic_expression"); 
            startToEndLine($$,$1,$1); 
            parseTreeChildren.clear(); 
            parseTreeChildren.push_back($1);
            parseChild($$ , parseTreeChildren) ;

            if($1->getDataType()=="VOID")
            {
                string errmsg = "Void cannot be used in expression ";
                yyerror(errmsg); 
            }
            else 
            {
                $1->setDataType($1->getDataType()); 
            }
            argumentList.push_back($1->getDataType());


        };

%%

int main(int argc,char* argv[])
{ 
    if(argc!=2)
    {
        cout<<"Insert input file name"<<endl;
        return 0;
    }

    int scope_id=1;
    int total_bucket=11;
    logFile.open("log.txt") ; 
    errorFile.open("error.txt") ;
    parseFile.open("parsetree.txt");

    symboltable->Enter_scope(scope_id++,total_bucket);
    yyin=nullptr; 
    yyin=fopen(argv[1],"r"); 
    if(yyin==nullptr) 
    {
        cout<<"Can not open specified file"<<endl;
        return 0;
    }
    yyparse(); 
    fclose(yyin); 
    logFile<<"Total Lines: "<<lineNumber<<endl; 
    logFile<<"Total Errors: "<<totalError<<endl;
    logFile.close(); 
    errorFile.close(); 
    parseFile.close(); 
    delete symboltable;
    return 0; 
}