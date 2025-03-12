#include<iostream>
#include<fstream>
#include<string>
#include<vector>
using namespace std; 

class SymbolInfo
{
    string Name;
    string Type;
    SymbolInfo* next;
    int arrSize=-1;
    string dataType;
    string parseTreePrint;
    bool isDeclar=false;
    bool isDef=false ; 
    
    struct paramInfo
    {
        string paramName; 
        string paramType;
    };


    vector<paramInfo>paramFunc;
    vector<SymbolInfo*>childrenList; 

    
    int startLine,endLine,spaceCount,childrenCount=0;
    bool leaf;
    bool startEnd=false;
    string parseLine; 

public :
    SymbolInfo(string name,string type)
    {
        this->Name=name;
        this->Type=type;
        this->next=nullptr;
    }
    ~SymbolInfo()
    {
        
    }
    void setName(string name)
    {
        this->Name=name;
    }
    void setType(string type)
    {
        this->Type=type;
    }
    void setNext_pointer(SymbolInfo* next)
    {
        this->next=next;
    }
    void setParamInfo(string name,string type)
    {
        struct paramInfo param;
        param.paramName=name;
        param.paramType=type;
        paramFunc.push_back(param);
    }
    void setSize(int size)
    {
        this->arrSize=size;
    }
    void setDataType(string dataType)
    {
        this->dataType=dataType;
        //cout<<"Set"<<dataType<<endl;;
    }
    void setDefined(bool define)
    {
        this->isDef=define;
    }
    void setDeclared(bool declare)
    {
        this->isDeclar=declare;
    }
    void setLeaf(bool leaf)
    {
        this->leaf=leaf;
    }
    void setParseLine(string line)
    {
        this->parseLine=line;
    }
    void setStartLine(int startLine)
    {
        this->startLine=startLine;
    }
    void setEndLine(int endLine)
    {
        this->endLine=endLine;
    }
    void setSpaceCount(int space)
    {
        this->spaceCount=space;
    }
    string getName()
    {
        return this->Name;
    }
    string getType()
    {
        return this->Type;
    }
    SymbolInfo* getNext_pointer()
    {
        return this->next;
    }

    int getParamCount()
    {
        return paramFunc.size();
    }
    int getSize()
    {
        return this->arrSize;
    }
    string getDataType() 
    {
        //cout<<"get"<<dataType<<endl;
        return this->dataType;
        
    }
    string getParseLine()
    {
        return this->parseLine;
    }
    int getStartLine()
    {
        return this->startLine;
    }
    int getEndLine()
    {
        return this->endLine;
    }
    int getSpaceCount()
    {
        return this->spaceCount;
    }
    int getChildrenCount()
    {
        return this->childrenCount;
    }
    bool isDefined()
    {
        return this->isDef;
    }
    bool isDeclared()
    {
        return this->isDeclar;
    }
    bool isLeaf()
    {
        return this->leaf;
    }
    bool ifStartEnd()
    {
        if(startLine==endLine)
        {
            startEnd=true;
        }
        else
        {
            startEnd=false;
        }
        return startEnd;
    }
    bool isFunction()
    {
        if(this->Type=="FUNCTION")
        {
            return true;
        }
        return false;
    }
    bool isArray()
    {
        if(this->arrSize==-1)
        {
            return false;
        }
        return true;
    }
    bool isVariable()
    {
        if(isFunction()==false&&isArray()==false)
        {
            return true;
        }
        return false;
    }
    paramInfo useParamIndex(int index)
    {
        paramInfo param=paramFunc[index];
        return param;
    }
    void addChildren(SymbolInfo* children)
    {
        children->setSpaceCount(getSpaceCount()+getChildrenCount());
        this->childrenList.push_back(children);
        this->childrenCount++;
        this->spaceCount++;
    }
    void addMultipleChildren(vector<SymbolInfo*>multipleChildren)
    {
        for(SymbolInfo* symbol:multipleChildren)
        {
            addChildren(symbol);
        }
    }


    void printParseTree(ofstream &out,int space)
    {
        int initialSpace=0;
        while(initialSpace<space)
        {
            out<<" ";
            initialSpace++;
        }
        if(isLeaf())
        {
            out<<this->getType()<<" : "<<this->getName()<<"\t<Line: "<<this->getEndLine()<<">"<<endl;
        }
        else
        {
            //start:program
            out<<this->getParseLine()<<"\t<Line: "<<this->getStartLine()<<"-"<<this->getEndLine()<<">"<<endl;
            for(SymbolInfo *symbol:childrenList)
            {
                symbol->printParseTree(out,space+1);
            }
        }
    }
};

class ScopeTable
{
private:
    int total_buckets ;
    SymbolInfo** scopetable ;
    int num_buckets ;
    ScopeTable* parentScope ;

public :
    ScopeTable(int totalBuckets)
    {
        this->num_buckets=totalBuckets;
        this->scopetable=new SymbolInfo*[num_buckets];
        for(int i =0;i<num_buckets;i++)
             scopetable[i]=nullptr;
    }
    ScopeTable(int ID,int num_buckets,ScopeTable *parent)
    {
        this->total_buckets = ID ;
        this->num_buckets = num_buckets ;
        this->parentScope = parent ;
        scopetable = new SymbolInfo*[num_buckets] ;
        for(int i =0 ; i<num_buckets ; i++)
            scopetable[i] = NULL ;

    }
    int getID(){return total_buckets;}

    ScopeTable* getparent()
    {
        return this->parentScope ;
    }

    unsigned long long int sdbmhash(string str)
    {
         unsigned long long int hash=0 ;
         long long int c=str.length() ;
        for( long long int i=0;i<c;i++)
        {
            hash=(str[i]+(hash<<6)+(hash<<16)-hash);

        }
        return hash%num_buckets;
    }
    bool Insert(SymbolInfo &symbol)
    {

        int hashval = this->sdbmhash(symbol.getName());
        SymbolInfo* curr=scopetable[hashval];
        while(curr!=nullptr)
        {
            if(curr->getName()==symbol.getName())
                {
                    return false;
                }
            curr = curr->getNext_pointer() ;
        }

        hashval=this->sdbmhash(symbol.getName()) ;
        curr=scopetable[hashval] ;

        int temp=1;
        if(curr==nullptr)
        {
            scopetable[hashval]=&symbol ;
            symbol.setNext_pointer(nullptr) ;
        }
        else
        {
            temp++ ;
            while (curr->getNext_pointer()!=nullptr)
            {
                curr = curr->getNext_pointer();
                temp++;
            }
            curr->setNext_pointer(&symbol);
            symbol.setNext_pointer(nullptr);
        }
        return true;

    }
    ScopeTable* get_parentScope()
    {
        return this->parentScope;
    }
    SymbolInfo* LookUp(string name)
    {
        long long index=sdbmhash(name);
        int list_position=0;
        if(scopetable[index]!=nullptr)
        {
            SymbolInfo* obj=scopetable[index];
            while(obj!=nullptr)
            {
                if(obj->getName()==name)
                {
                    /*cout<<"'"<<obj->getName()<<"'"<<" found at position <"<<index+1<<", "<<list_position+1<<"> of ScopeTable# "<<getID()<<endl;*/
                    return obj;

                }
                list_position++;
                obj=obj->getNext_pointer();
            }
        }

        return nullptr;
    }
    bool Delete(string name)
    {
        bool flag=false;
        {
            long long index=sdbmhash(name);
            SymbolInfo* temp=scopetable[index];
            int list_position=0;
            SymbolInfo* current=nullptr;
            while(temp!=nullptr)
            {
                if(temp->getName()==name)
                {
                    if(current==nullptr)
                    {
                        scopetable[index]=temp->getNext_pointer();
                    }
                    else if(current!=nullptr)
                    {
                        current->setNext_pointer(temp->getNext_pointer());
                    }

                    /*cout<<"Deleted "<<"'"<<name<<"'" <<" from position <"<<index+1<<", "<<list_position+1<<"> of ScopeTable# "<<getID()<<endl;*/
                    delete temp;
                    flag=true;
                    return true;
                }
                current=temp;
                temp=temp->getNext_pointer();
                list_position++;
            }
        }

        if(flag==false)
        {
            /*cout<<"Not found in the current ScopeTable# "<<getID()<<endl;*/

        }
        return false;



    }
    void print(ofstream &out)
    {
        out<<"\tScopeTable# "<<total_buckets<<endl ;

        for (int i = 0; i < num_buckets; i++) 
        {
            SymbolInfo* currpos = scopetable[i];
            int temp = 1;

            while (currpos != nullptr) 
            {
                if (currpos->isFunction()) 
                {
                    if (currpos->isDeclared())
                    {
                        if (temp) 
                        {
                            out << "\t" << i + 1 << "--> ";
                            temp = 0;
                        }
                    out << "<" << currpos->getName() << "," << currpos->getType() << "," << currpos->getDataType() << "> ";
                    }
                } 
                else if (currpos->isArray())
                {
                    if (temp) 
                    {
                        out << "\t" << i + 1 << "--> ";
                        temp = 0;
                    }
                    out << "<" << currpos->getName() << "," << currpos->getType() << "> ";
                }
                else 
                {
                    if (temp) 
                    {
                        out << "\t" << i + 1 << "--> ";
                        temp = 0;
                    }
                    out << "<" << currpos->getName() << "," << currpos->getType() << "> ";
                }
                currpos = currpos->getNext_pointer();
            }

            if (!temp) 
            {
                out << endl;
            }
        }



        for(int i=0;i<num_buckets;i++)
        {
            SymbolInfo* currpos = scopetable[i];

            while(currpos!=nullptr)
            {
  
                if(!currpos->isDeclared()&&currpos->isDefined())currpos->setDeclared(true);
                    //out<<currpos->getName()<<","<<currpos->getType()<<","<<currpos->getDataType()<<"> "; 
            
                currpos = currpos->getNext_pointer();

            }
        }

    }
    ~ScopeTable()
    {
        delete[] scopetable;
    }



};



class SymbolTable
{
    ScopeTable* current_scopeTable;
    int total_buckets;
    public:
    SymbolTable(int total_buckets)
    {
        this->total_buckets=total_buckets;
        this->current_scopeTable=new ScopeTable(total_buckets);
        /*cout<<"\tScopeTable# "<<current_scopeTable->getID()<<" created"<<endl;*/
    }

    ~SymbolTable()
    {
        /*ScopeTable* obj=current_scopeTable;
        while(obj!=nullptr)
        {
            /*cout<<"\t"<<"ScopeTable# "<<current_scopeTable->getID()<<" deleted"<<endl;*/
            /*obj=current_scopeTable;
            current_scopeTable=current_scopeTable->get_parentScope();
            delete obj;
            

        }*/
    }
    void Enter_scope(int id , int sz)
    {
        ScopeTable* ncurr = new ScopeTable(id , sz , current_scopeTable) ;
        current_scopeTable = ncurr ;


    }

    void Exit_scope(ofstream &out)
    {
        if(current_scopeTable->getID()==1)
        {
            return ;
        }
        else
        {
            ScopeTable* obj=current_scopeTable;
            this->current_scopeTable=current_scopeTable->get_parentScope();
            delete obj;
        }

    }
    bool insert(SymbolInfo &symbol)
    {
        if(current_scopeTable!=nullptr)
            return current_scopeTable->Insert(symbol);
        return false;

    }
    bool Remove(string name)
    {
        if(current_scopeTable!=nullptr)
            return current_scopeTable->Delete(name);
        return false;
    }
    SymbolInfo* LookUp(string name)
    {
        ScopeTable* obj=current_scopeTable;
        SymbolInfo* temp=nullptr;
        if(obj==nullptr)
            return nullptr;
        else
        {
            while(obj!=nullptr)
            {
                temp=obj->LookUp(name);
                if(temp!=nullptr)
                    return temp;
                else
                {
                    obj=obj->get_parentScope();
                }
            }

        }
        /*cout<<"'"<<name<<"' not found in any of the ScopeTables"<<endl;*/
        return nullptr;



    }


    int currScopeID()
    {
        return current_scopeTable->getID() ;
    }
    /*void print_current_scope_table()
    {
        if(current_scopeTable!=nullptr)
        {
            current_scopeTable->Print();
        }
    }*/
    void print_all_scope_table(  ofstream &out)
    {
        current_scopeTable->print(out) ;
        ScopeTable* ptable = current_scopeTable->getparent()  ;
        while (ptable != NULL && ptable->getID()!=0)

        {
            ptable->print(out)  ;
            //out<<endl ;
            ptable = ptable->getparent() ;
        }

        return ;

    }

    int getscopeID(string name,ofstream &out)
    {
        if(current_scopeTable->getID()==1)return 1;
        ScopeTable *obj=current_scopeTable ;
        while(obj!=nullptr)
        {
            SymbolInfo* temp =obj->LookUp(name) ;
            if(temp==nullptr) obj=obj->getparent() ;
            else
            {
                return obj->getID() ;
            }
        }
        return 0 ; 
    }


};
