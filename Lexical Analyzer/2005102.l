%option noyywrap
%x CURRENT_STRING_STATE
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT

%{
#include<bits/stdc++.h>
#include "2005102.h"
using namespace std;


int totalBuckets=10;
int lineNumber=1;
int totalError=0;
int textLine=0;
int multiLine=0;
int warningCount=0;


string comment;
string stringText;
string tokenStr;


SymbolTable *symboltable;

ofstream tokenFile;
ofstream logFile;

int spaceCount=0;
int tabCount=0;
bool flag=true;
int tabNeeded=0;

void checkIndentation() 
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
}

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
    tokenFile<<"<"<<token<<", "<<yytext<<">"<<endl;

    logFile<<"Line# "<<lineNumber<<": Token <"<<token<<"> Lexeme "<<yytext<<" found"<<endl;
}

void setStringEmpty()
{
    stringText="";
    tokenStr="";
}



void charPrint()
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
    tokenFile<<"<"<<makeUpper(key)<<", "<<yytext<<">"<<endl;
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

void stringPrint()
{
    if(multiLine==0)
    {
    tokenFile<<"<SINGLE LINE STRING, "<<tokenStr<<">"<<endl;
    logFile<<"Line# "<<lineNumber<<": Token <SINGLE LINE STRING> Lexeme "<<stringText<<" found"<<endl;
    }
    else if(multiLine>=1)
    {
        tokenFile<<"<MULTI LINE STRING, "<<tokenStr<<">"<<endl;
        logFile<<"Line# "<<lineNumber-multiLine<<": Token <MULTI LINE STRING> Lexeme "<<stringText<<" found"<<endl;
    }
    multiLine=0;
}

void numberPrint(string token)
{
    tokenFile<<"<"<<token<<", "<<yytext<<">"<<endl;
    logFile<<"Line# "<<lineNumber<<": Token <"<<token<<"> Lexeme "<<yytext<<" found"<<endl;
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
INCOP ("++"|"--")
RELOP ("<"|"<="|">"|">="|"=="|"!=")
ASSIGNOP [=]
LOGICOP ("&&"|"||")
BITOP ("&"|"|"|"^"|"<<"|">>")
NOT [!]
LPAREN [(]
RPAREN [)]
LCURL [{]

RCURL [}]

LSQUARE ("[")
RSQUARE ("]")
COMMA [,]
SEMICOLON [;]

%%


"if"        |
"for"       |
"do"        |
"int"       |
"float"     |
"void"      |
"switch"    |
"default"   |
"else"      |
"while"     |
"break"     |
"char"      |
"double"    |
"return"    |
"case"      |
"continue" {if(flag)checkIndentation();insertKey();}


{ADDOP} {if(flag)checkIndentation();operationPrint("ADDOP");}
{MULOP} {if(flag)checkIndentation();operationPrint("MULOP");}
{INCOP} {if(flag)checkIndentation();operationPrint("INCOP");}
{RELOP} {if(flag)checkIndentation();operationPrint("RELOP");}
{ASSIGNOP} {if(flag)checkIndentation();operationPrint("ASSIGNOP");}
{LOGICOP} {if(flag)checkIndentation();operationPrint("LOGICOP");}
{BITOP} {if(flag)checkIndentation();operationPrint("BITOP");}
{NOT} {if(flag)checkIndentation();operationPrint("NOT");}
{LPAREN} {if(flag)checkIndentation();operationPrint("LPAREN");}
{RPAREN} {if(flag)checkIndentation();operationPrint("RPAREN");}
{LCURL} {if(flag)checkIndentation();operationPrint("LCURL");symboltable->Enter_scope();tabNeeded++;}
{RCURL} {tabNeeded--;if(flag)checkIndentation();operationPrint("RCURL");symboltable->Exit_scope();}
{LSQUARE} {if(flag)checkIndentation();operationPrint("LSQUARE");}
{RSQUARE} {if(flag)checkIndentation();operationPrint("RSQUARE");}
{COMMA} {if(flag)checkIndentation();operationPrint("COMMA");}
{SEMICOLON} {if(flag)checkIndentation();operationPrint("SEMICOLON");}

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
    if(flag)
        checkIndentation();
    insertID();}
{integer} {
    if(flag)
        checkIndentation();
    numberPrint("CONST_INT");}
{float} {
    if(flag)
        checkIndentation();
    numberPrint("CONST_FLOAT");}

{slash_char} {if(flag) checkIndentation();charPrint();}



\" {
    if(flag)
    {
        checkIndentation();
    }

    setStringEmpty();

    stringText.append(yytext);
    textLine=lineNumber;
    BEGIN CURRENT_STRING_STATE;
}
<CURRENT_STRING_STATE>\" {
    stringText.append(yytext);

    stringPrint();
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
    if(flag)
    checkIndentation();
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
    if(flag)
    {
        checkIndentation();
    }
    textLine=lineNumber;
    comment="/*";
    BEGIN MULTI_LINE_COMMENT;
}

{too_many_decimal_points_error} {
    if(flag)
    {
        checkIndentation();
    }
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
}

{ill_formed_numbers_error} {
    if(flag)
    {
        checkIndentation();
    }
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": ILLFORMED_NUMBER "<<yytext<<endl;
}

{invalid_suffix_prefix_error} {
    if(flag)
    {
        checkIndentation();
    }
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
}

{multiple_char_error} {
    if(flag)
    {
        checkIndentation();
    }
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": MULTICHAR_CONST_CHAR "<<yytext<<endl;
}


{unfinished_char_error} {
    if(flag)
    {
        checkIndentation();
    }
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": UNFINISHED_CONST_CHAR "<<yytext<<endl;
}

{empty_char} {
    if(flag)
    {
        checkIndentation();
    }
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": EMPTY_CONST_CHAR "<<yytext<<endl;
}

{invalid_exponent_error} {
    if(flag)
    {
        checkIndentation();
    }
    
    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": INVALID_EXPONENT "<<yytext<<endl;
}

. {
    if(flag)
    {
        checkIndentation();
    }

    totalError++;
    logFile<<"Error at line# "<<lineNumber<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
}

%%



int main(int argc,char *argv[])
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
}
