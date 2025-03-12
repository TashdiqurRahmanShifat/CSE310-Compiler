%option noyywrap
%x CURRENT_STRING_STATE
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT

%{
#include<bits/stdc++.h>
#include "2005102.h"
#include "y.tab.h"
using namespace std;


int totalBuckets=10;
int lineNumber=1;
int totalError=0;
int textLine=0;
int multiLine=0;
int warningCount=0;
int startingLine=0;


string comment;
string stringText;
string tokenStr;


//SymbolTable *symboltable;

//ofstream tokenFile;
extern ofstream logFile;
extern ofstream errorFile;


int spaceCount=0;
int tabCount=0;
bool flag=true;
int tabNeeded=0;


/*void checkIndentation() 
{
    if(spaceCount!=0)
    {
        warningCount++;
        logFile<<"Line# "<<lineNumber<<": Warning, tab requrired but got space."<<endl;
    }
    else if(tabCount!=tabNeeded)
    {
        warningCount++;
        logFile<<"Line# "<<lineNumber<<": warning, "<<tabNeeded<<" of tabs needed but got "<<tabCount<<" tabs."<<endl;
    }
    flag=false;
}*/

char conversion_to_special_char(string str)
{
    if(str=="\\n") return '\n';
    else if(str=="\\a") return '\a';
    else if(str=="\\t") return '\t';
    else if(str=="\\v") return '\v';
    else if(str=="\\\\") return '\\';
    else if(str=="\\f") return '\f';
    else if(str=="\\r") return '\r';
    else if(str=="\\b") return '\b';
    else if(str=="\\\'") return '\'';
    else if(str=="\\\"") return '\"';
    return '0';
}

string makeUpper(string token){
    string temp = "";
    int len  = token.length();
    for(int i=0;i<len;i++){
        temp+=toupper(token[i]);
    }
    return temp;
}

void operationPrint(string token)
{
    //tokenFile<<"<"<<token<<", "<<yytext<<">"<<endl;

    logFile<<"Line# "<<lineNumber<<": Token <"<<token<<"> Lexeme "<<yytext<<" found"<<endl;
}

void setStringEmpty()
{
    stringText="";
    tokenStr="";
}



/*void charPrint()
{
    char c=yytext[1];
    string str="";
    char temp;

    str=str+c;
    if(c=='\\')
    {
        temp=yytext[2];
        str+=temp;
        c=conversion_to_special_char(str);
    }

    if(c!='0')
    {
        tokenFile<<"<CONST_CHAR, "<<c<<">"<<endl;
        logFile<<"Line# "<<lineNumber<<": Token <CONST_CHAR> Lexeme "<<c<<" found"<<endl;
    }
    else
    {
        totalError++;
        logFile<<"Error at line# "<<lineNumber<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
        //tokenFile<<"<CONST_CHAR, "<<str<<">"<<endl;
        //logFile<<"Line# "<<lineNumber<<": Token <CONST_CHAR> Lexeme "<<str<<" found"<<endl;
    }

}


void insertKey()
{
    string key=yytext;
    //tokenFile<<"<"<<makeUpper(key)<<", "<<yytext<<">"<<endl;
    logFile<<"Line# "<<lineNumber<<": Token <"<<makeUpper(key)<<"> Lexeme "<<yytext<<" found"<<endl;
}

void insertID()
{
    tokenFile<<"<ID, "<<yytext<<">"<<endl;
    logFile<<"Line# "<<lineNumber<<": Token <ID> Lexeme "<<yytext<<" found"<<endl;
    bool insertFlag=symboltable->Insert(yytext,"ID");
    if(insertFlag)symboltable->print_all_scope_table(logFile);
    else logFile<<"\t"<<yytext<<" already exists in the current ScopeTable"<<endl;

}
*/
/*void stringPrint()
{
    if(multiLine==0)
    {
    //tokenFile<<"<SINGLE LINE STRING, "<<tokenStr<<">"<<endl;
    logFile<<"Line# "<<lineNumber<<": Token <SINGLE LINE STRING> Lexeme "<<stringText<<" found"<<endl;
    }
    else if(multiLine>=1)
    {
        //tokenFile<<"<MULTI LINE STRING, "<<tokenStr<<">"<<endl;
        logFile<<"Line# "<<lineNumber-multiLine<<": Token <MULTI LINE STRING> Lexeme "<<stringText<<" found"<<endl;
    }
    multiLine=0;
}*/

void numberPrint(string token)
{
    //tokenFile<<"<"<<token<<", "<<yytext<<">"<<endl;
    logFile<<"Line# "<<lineNumber<<": Token <"<<token<<"> Lexeme "<<yytext<<" found"<<endl;
}

void setParseTree(int lineNumber,bool leaf)
{
    //union er kaj kor age
    yylval.symbol->setStartLine(lineNumber);
    yylval.symbol->setEndLine(lineNumber);
    yylval.symbol->ifStartEnd();
    yylval.symbol->setLeaf(leaf);
}
void printInLog(string name,string type)
{
    logFile<<"Line# "<<lineNumber<<": Token <"<<type<<"> Lexeme "<<name<<" found"<<endl;
}

%}

whitespace [ \r\v\f]
tab [\t]
digit [0-9]
id [_A-Za-z][0-9_A-Za-z]*
newline (\r)?(\n)
letter [A-Za-z]
excludeNewline [^{newline}]
integer {digit}+
exponent [Ee][+-]?{digit}+
float {digit}*(\.{digit}+)?{exponent}?
character ((\\{excludeNewline})|([^\\'(\r\n)]))
slash_char ([\'])({character})([\'])
empty_char ('')
too_many_decimal_points_error {digit}*(\.{digit}*){2,}+[Ee]?({digit}*)
ill_formed_numbers_error {digit}*[Ee][+-]?{digit}*(\.{digit}*)+
invalid_suffix_prefix_error {digit}+{id}+
multiple_char_error \'({character}){2,}\'
special_char [\"\'nfratbv0\\]
unfinished_char_error '(([ -~]{-}['\\])){1}|('(\\{special_char})*)
invalid_exponent_error {digit}*(\.{digit}+)?[Ee][+-]?{letter}*{digit}*?{letter}*?{digit}*?



ADDOP [+-]
MULOP [*/%]
INCOP ("++")
DECOP ("--")
RELOP ("<"|"<="|">"|">="|"=="|"!=")
ASSIGNOP [=]
LOGICOP ("&&"|"||")
BITOP ("&"|"|"|"^"|"<<"|">>")
NOT [!]
LPAREN [(]
RPAREN [)]
LCURL [{]

RCURL [}]

LTHIRD ("[")
RTHIRD ("]")
COMMA [,]
SEMICOLON [;]

%%


"if" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"IF");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"IF");
    setParseTree(lineNumber,true);
    return IF;//check
    }
"for" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"FOR");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"FOR");
    setParseTree(lineNumber,true);
    return FOR;
}
"do" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"DO");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"DO");
    setParseTree(lineNumber,true);
    return DO;
}
"int" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"INT");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"INT");
    setParseTree(lineNumber,true);
    return INT;
}
"float" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"FLOAT");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"FLOAT");
    setParseTree(lineNumber,true);
    return FLOAT;
}
"void" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"VOID");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"VOID");
    setParseTree(lineNumber,true);
    return VOID;
}
"switch" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"SWITCH");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"SWITCH");
    setParseTree(lineNumber,true);
    return SWITCH;
}
"default" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"DEFAULT");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"DEFAULT");
    setParseTree(lineNumber,true);
    return DEFAULT;
}
"else" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"ELSE");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"ELSE");
    setParseTree(lineNumber,true);
    return ELSE;
}
"println" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"PRINTLN");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"PRINTLN");
    setParseTree(lineNumber,true);
    return PRINTLN;
}
"while" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"WHILE");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"WHILE");
    setParseTree(lineNumber,true);
    return WHILE;
}
"break" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"BREAK");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"BREAK");
    setParseTree(lineNumber,true);
    return BREAK;
}
"char" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"CHAR");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"CHAR");
    setParseTree(lineNumber,true);
    return CHAR;
}
"double" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"DOUBLE");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"DOUBLE");
    setParseTree(lineNumber,true);
    return DOUBLE;
}
"return" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"RETURN");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"RETURN");
    setParseTree(lineNumber,true);
    return RETURN;
}
"case" {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"CASE");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"CASE");
    setParseTree(lineNumber,true);
    return CASE;
}
"continue" {//if(flag)checkIndentation();
//insertKey();
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"CONTINUE");
    yylval.symbol=symbolinfo;
    printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return CONTINUE;
}


{ADDOP} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"ADDOP");
    yylval.symbol=symbolinfo;
    operationPrint("ADDOP");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return ADDOP;
    //operationPrint("ADDOP");
    }
{MULOP} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"MULOP");
    yylval.symbol=symbolinfo;
    operationPrint("MULOP");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return MULOP;
    }
{INCOP} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"INCOP");
    yylval.symbol=symbolinfo;
    operationPrint("INCOP");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return INCOP;
    }
{DECOP} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"DECOP");
    yylval.symbol=symbolinfo;
    operationPrint("DECOP");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return DECOP;
    }
{RELOP} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"RELOP");
    yylval.symbol=symbolinfo;
    operationPrint("RELOP");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return RELOP;
    }
{ASSIGNOP} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"ASSIGNOP");
    yylval.symbol=symbolinfo;
    operationPrint("ASSIGNOP");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return ASSIGNOP;
    }
{LOGICOP} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"LOGICOP");
    yylval.symbol=symbolinfo;
    operationPrint("LOGICOP");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return LOGICOP;
    }
{BITOP} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"BITOP");
    yylval.symbol=symbolinfo;
    operationPrint("BITOP");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return BITOP;
    }
{NOT} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"NOT");
    yylval.symbol=symbolinfo;
    operationPrint("NOT");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return NOT;
    }
{LPAREN} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"LPAREN");
    yylval.symbol=symbolinfo;
    operationPrint("LPAREN");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return LPAREN;
    }
{RPAREN} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"RPAREN");
    yylval.symbol=symbolinfo;
    operationPrint("RPAREN");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return RPAREN;
    }
{LCURL} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"LCURL");
    yylval.symbol=symbolinfo;
    operationPrint("LCURL");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return LCURL;
    }
{RCURL} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"RCURL");
    yylval.symbol=symbolinfo;
    operationPrint("RCURL");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return RCURL;
    }
{LTHIRD} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"LSQUARE");
    yylval.symbol=symbolinfo;
    operationPrint("LSQUARE");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return LTHIRD;
    }
{RTHIRD} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"RSQUARE");
    yylval.symbol=symbolinfo;
    operationPrint("RSQUARE");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return RTHIRD;
    }
{COMMA} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"COMMA");
    yylval.symbol=symbolinfo;
    operationPrint("COMMA");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return COMMA;
    }
{SEMICOLON} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"SEMICOLON");
    yylval.symbol=symbolinfo;
    operationPrint("SEMICOLON");
    //printInLog(yytext,"CONTINUE");
    setParseTree(lineNumber,true);
    return SEMICOLON;
    }

{tab} {
    if(flag)
    {
        tabCount++;
    }
}
{whitespace} {
    if(flag)
    {
        spaceCount++;
    }
}

{newline} {
    spaceCount=0;
    tabCount=0;
    flag=true;
    lineNumber++;
}

{id} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"ID");
    yylval.symbol=symbolinfo;
    //printInLog(yytext,"CASE");
    numberPrint("ID");
    setParseTree(lineNumber,true);
    return ID;
    //insertID();
    }
{integer} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"CONST_INT");
    yylval.symbol=symbolinfo;
    //printInLog(yytext,"CASE");
    numberPrint("CONST_INT");
    setParseTree(lineNumber,true);
    return CONST_INT;
    }
{float} {
    SymbolInfo *symbolinfo=new SymbolInfo(yytext,"CONST_FLOAT");
    yylval.symbol=symbolinfo;
    //printInLog(yytext,"CASE");
    numberPrint("CONST_FLOAT");
    setParseTree(lineNumber,true);
    return CONST_FLOAT;
    }

{slash_char} {
//charPrint();
}



\" {


    setStringEmpty();

    stringText.append(yytext);
    textLine=lineNumber;
    BEGIN CURRENT_STRING_STATE;
}
<CURRENT_STRING_STATE>\" {
    stringText.append(yytext);

   // stringPrint();
    setStringEmpty();
    BEGIN INITIAL;
}


<CURRENT_STRING_STATE>(\\)[\r]?\n {
    lineNumber++;
    stringText.append("\\\n");

    multiLine++;
}
<CURRENT_STRING_STATE>{newline} {
    
    logFile<<"Error at line# "<<lineNumber<<": UNFINISHED_STRING "<<stringText<<endl;
    lineNumber++;
    totalError++;
    setStringEmpty();
    BEGIN INITIAL;
}
<CURRENT_STRING_STATE>(\\.) {
    tokenStr+=conversion_to_special_char(yytext);
    stringText.append(yytext);

}



<CURRENT_STRING_STATE>. {
    stringText.append(yytext);

    tokenStr.append(yytext);
}

<CURRENT_STRING_STATE><<EOF>> {
    logFile<<"Error at line# "<<lineNumber<<": UNFINISHED_STRING "<<stringText<<endl;
    totalError++;
    stringText="";
    BEGIN INITIAL;
    return 0;
}

<MULTI_LINE_COMMENT>"*/" {
    textLine++;
    logFile<<"Line# "<<lineNumber<<": Token <MULTI LINE COMMENT> Lexeme ";
    lineNumber=textLine;
    comment.append(yytext);
    lineNumber--;

    logFile<<comment<<" found"<<endl;
    textLine=0;
    comment="";
    BEGIN INITIAL;
}

<MULTI_LINE_COMMENT>(\r\n) {
    textLine++;
    comment.append(yytext);
}

<MULTI_LINE_COMMENT><<EOF>> {

    lineNumber=textLine;
    logFile<<"Error at line# "<<lineNumber<<": UNFINISHED_COMMENT "<<comment<<endl;
    totalError++;
    BEGIN INITIAL;
    return 0;
}

<MULTI_LINE_COMMENT>. {
    comment.append(yytext);
}

\/\/ {

    setStringEmpty();
    comment.append(yytext);

    logFile<<"Line# "<<lineNumber<<": Token <SINGLE LINE COMMENT> Lexeme ";
    BEGIN SINGLE_LINE_COMMENT;
}

<SINGLE_LINE_COMMENT>. {comment.append(yytext); }

<SINGLE_LINE_COMMENT>((\\)){newline} {
    comment.append(yytext);

    lineNumber++;
}

<SINGLE_LINE_COMMENT><<EOF>> {
    lineNumber++;
    logFile<<comment<<" found"<<endl;

    comment="";
    BEGIN INITIAL;
}

<SINGLE_LINE_COMMENT>{newline} {
    lineNumber++;
    logFile<<comment<<" found"<<endl;

    comment="";
    BEGIN INITIAL;
}

"/*" {

    textLine=lineNumber;
    comment="/*";
    BEGIN MULTI_LINE_COMMENT;
}

{too_many_decimal_points_error} {

    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
    errorFile<<"Error at line# "<<lineNumber<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
}

{ill_formed_numbers_error} {
 
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": ILLFORMED_NUMBER "<<yytext<<endl;
    errorFile<<"Error at line# "<<lineNumber<<": ILLFORMED_NUMBER "<<yytext<<endl;
}

{invalid_suffix_prefix_error} {

    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
    errorFile<<"Error at line# "<<lineNumber<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
}

{multiple_char_error} {
  
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": MULTICHAR_CONST_CHAR "<<yytext<<endl;
    errorFile<<"Error at line# "<<lineNumber<<": MULTICHAR_CONST_CHAR "<<yytext<<endl;
}


{unfinished_char_error} {
  
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": UNFINISHED_CONST_CHAR "<<yytext<<endl;
    errorFile<<"Error at line# "<<lineNumber<<": UNFINISHED_CONST_CHAR "<<yytext<<endl;
}

{empty_char} {
  
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": EMPTY_CONST_CHAR "<<yytext<<endl;
    errorFile<<"Error at line# "<<lineNumber<<": EMPTY_CONST_CHAR "<<yytext<<endl;
}

{invalid_exponent_error} {
   
    
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": INVALID_EXPONENT "<<yytext<<endl;
    errorFile<<"Error at line# "<<lineNumber<<": INVALID_EXPONENT "<<yytext<<endl;
}

. {


    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
    errorFile<<"Error at line# "<<lineNumber<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
}

%%



/*int main(int argc,char *argv[])
{
    symboltable=new SymbolTable(totalBuckets);
    if(argc!=2)
    {
        cout<<"Insert input file name"<<endl;
        return 0;
    }

    FILE *f=fopen(argv[1],"r");
    if(f==NULL)
    {
        cout<<"Can not open specified file"<<endl;
        return 0;
    }

    logFile.open("2005102_log.txt");
    tokenFile.open("2005102_token.txt");
    yyin=f;
    yylex();
    symboltable->print_all_scope_table(logFile);
    logFile<<"Total lines: "<<lineNumber<<endl;
    logFile<<"Total errors: "<<totalError<<endl;
    logFile<<"Total warnings: "<<warningCount<<endl;
    fclose(yyin);
    logFile.close();
    tokenFile.close();
    return 0;
}*/
