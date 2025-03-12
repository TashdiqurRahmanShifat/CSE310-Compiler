#include<bits/stdc++.h>
using namespace std;

class SymbolInfo
{
private:
    string Name;
    string Type;
    SymbolInfo* next;
public:
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
};

class ScopeTable
{
private:
    int total_buckets;
    SymbolInfo** scopetable;
    int child_count;
    ScopeTable* parentScope;
    string id;
public:
    ScopeTable(int total_buckets)
    {
        this->total_buckets=total_buckets;
        this->scopetable=new SymbolInfo*[total_buckets];
        for(int i=0; i<total_buckets; i++)
        {
            scopetable[i]=nullptr;
        }
        this->child_count=0;
        this->parentScope=nullptr;
        this->id="1";
    }

    unsigned long long sdbmhash(string str)
    {
        unsigned long long hash=0;
        long long c=str.length();
        for(long long i=0; i<c; i++)
        {
            hash=(str[i]+(hash<<6)+(hash<<16)-hash);
        }
        return hash%total_buckets;

    }

    ~ScopeTable()
    {
        for(int i=0; i<total_buckets; i++)
        {
            if(scopetable[i]!=nullptr)
            {
                SymbolInfo* obj=scopetable[i];
                while(obj!=nullptr)
                {
                    SymbolInfo* temp=obj;
                    delete temp;
                    obj=obj->getNext_pointer();
                }

            }
        }
        delete [] scopetable;
    }

    void setID(string child_no)
    {
        this->id=child_no;
    }
    string getID()
    {
        return id;
    }
    void set_child_count(int count)
    {
        child_count=child_count+count;
    }
    int getchild_count()
    {
        return child_count;
    }

    void set_parent_scope(ScopeTable* parentScope)
    {
        this->parentScope=parentScope;
    }
    ScopeTable* get_parent_scope()
    {
        return this->parentScope;
    }
    SymbolInfo* Lookup(string name)
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
                    cout<<"'"<<obj->getName()<<"'"<<" found at position <"<<index+1<<", "<<list_position+1<<"> of ScopeTable# "<<getID()<<endl;
                    return obj;

                }
                list_position++;
                obj=obj->getNext_pointer();
            }
        }

        return nullptr;
    }

    bool Insert(string name,string type)
    {
        bool flag=false;
        int temp=0;
        int list_position=0;

        long long index=sdbmhash(name);
        if(scopetable[index]!=nullptr)
        {
            SymbolInfo* obj=scopetable[index];
            while(obj!=nullptr)
            {
                if(obj->getName()==name)
                {
                    temp=1;
                }
                list_position++;
                obj=obj->getNext_pointer();
            }
        }
        if(temp==0)
        {
            SymbolInfo* obj=new SymbolInfo(name,type);
            long long index=sdbmhash(name);
            SymbolInfo* temp=scopetable[index];
            int list_position=0;
            if(temp==nullptr)
            {
                scopetable[index]=obj;
                cout<<"Inserted  at position <"<<index+1<<", "<<list_position+1<<"> of ScopeTable# "<<getID()<<endl;

                flag=true;
                return true;
            }
            else
            {
                SymbolInfo* current=nullptr;
                while(temp!=nullptr)
                {
                    current=temp;
                    temp=temp->getNext_pointer();
                    list_position++;
                }
                current->setNext_pointer(obj);
                cout<<"Inserted  at position <"<<index+1<<", "<<list_position+1<<"> of ScopeTable# "<<getID()<<endl;

                flag=true;
                return true;
            }
        }
        if(flag==false)
        {
            cout<<"'"<<name<<"'"<<" already exists in the current ScopeTable# "<<getID()<<endl;

        }
        return false;

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

                    cout<<"Deleted "<<"'"<<name<<"'" <<" from position <"<<index+1<<", "<<list_position+1<<"> of ScopeTable# "<<getID()<<endl;
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
            cout<<"Not found in the current ScopeTable# "<<getID()<<endl;

        }
        return false;
    }

    void Print()
    {
        cout<<"\t"<<"ScopeTable# "<<getID()<<endl;
        for(int i=0; i<total_buckets; i++)
        {
            cout<<"\t"<<i+1;
            SymbolInfo* temp=scopetable[i];
            while(temp!=nullptr)
            {
                cout<<" --> "<<"("<<temp->getName()<<","<<temp->getType()<<")";

                temp=temp->getNext_pointer();

            }
            cout<<endl;
        }

    }
};

class SymbolTable
{
private:
    ScopeTable* current_scopeTable;

    int total_buckets;
public:
    SymbolTable(int total_buckets)
    {
        this->total_buckets=total_buckets;
        this->current_scopeTable=new ScopeTable(total_buckets);
        cout<<"\tScopeTable# "<<current_scopeTable->getID()<<" created"<<endl;
    }
    ~SymbolTable()
    {
        ScopeTable* obj=current_scopeTable;
        while(obj!=nullptr)
        {
            cout<<"\t"<<"ScopeTable# "<<current_scopeTable->getID()<<" deleted"<<endl;
            current_scopeTable=current_scopeTable->get_parent_scope();
            delete obj;
            obj=current_scopeTable;

        }
    }
    void Enter_scope()
    {
        ScopeTable* obj=current_scopeTable;
        string scope_id;

        if(obj!=nullptr)
        {
            scope_id=(current_scopeTable->getID()).append(".")+to_string(current_scopeTable->getchild_count()+1);
            this->current_scopeTable=new ScopeTable(total_buckets);
            this->current_scopeTable->setID(scope_id);
            this->current_scopeTable->set_parent_scope(obj);
            this->current_scopeTable->setID(scope_id);
        }
        if(obj==nullptr)
        {
            scope_id=to_string(current_scopeTable->getchild_count());

            this->current_scopeTable=new ScopeTable(total_buckets);
            this->current_scopeTable->setID(scope_id);
        }
        cout<<"ScopeTable# "<<scope_id<<" created"<<endl;

    }

    void Exit_scope()
    {
        if(current_scopeTable->getID()=="1")
            cout<<"ScopeTable# "<<current_scopeTable->getID()<<" cannot be deleted"<<endl;
        else
        {
            cout<<"ScopeTable# "<<current_scopeTable->getID()<<" deleted"<<endl;
            ScopeTable* obj=current_scopeTable;
            this->current_scopeTable=current_scopeTable->get_parent_scope();
            delete obj;
            this->current_scopeTable->set_child_count(1);

        }
    }

    bool Insert(string name,string type)
    {
        if(current_scopeTable!=nullptr)
            return current_scopeTable->Insert(name,type);
        return false;
    }
    bool Remove(string name)
    {
        if(current_scopeTable!=nullptr)
            return current_scopeTable->Delete(name);
        return false;
    }

    SymbolInfo* Look_Up(string name)
    {
        ScopeTable* obj=current_scopeTable;
        SymbolInfo* temp=nullptr;
        if(obj==nullptr)
            return nullptr;
        else
        {
            while(obj!=nullptr)
            {
                temp=obj->Lookup(name);
                if(temp!=nullptr)
                    return temp;
                else
                {
                    obj=obj->get_parent_scope();
                }
            }

        }
        cout<<"'"<<name<<"' not found in any of the ScopeTables"<<endl;
        return nullptr;
    }

    void print_current_scope_table()
    {
        if(current_scopeTable!=nullptr)
        {
            current_scopeTable->Print();
        }
    }

    void print_all_scope_table()
    {

        {
            ScopeTable* obj=current_scopeTable;
            if(obj!=nullptr)
            {
                while(obj!=nullptr)
                {
                    obj->Print();
                    obj=obj->get_parent_scope();
                }
            }
        }
    }

    /*void Quit()
    {
        while(current_scopeTable!=nullptr)
        {
            cout<<"\t"<<"ScopeTable# "<<current_scopeTable->getID()<<" deleted"<<endl;

            ScopeTable* obj=current_scopeTable;
            this->current_scopeTable=current_scopeTable->get_parent_scope();
            delete obj;

        }
    }*/


};

int simple_tokenizer(string str)
{
    stringstream ss(str);
    string word;
    int count_word=0;
    while(ss>>word)
    {
        count_word++;
    }
    return count_word;
}

int main()
{
    freopen("input.txt","r",stdin);
    freopen("output.txt","w",stdout);
    int total_buckets;
    char operation;
    string first_data,second_data;
    cin>>total_buckets;
    SymbolTable st(total_buckets);
    int input_parameter_count;
    string input_data;
    int command_count=0;
    while(cin>>operation)
    {
        switch(operation)
        {
        case 'I':
        {
            getline(cin,input_data);
            input_parameter_count=simple_tokenizer(input_data);
            string arr[input_parameter_count];
            int i=0;
            {
                stringstream ss(input_data);
                string word;
                while(ss>>word)
                {
                    arr[i]=word;
                    i++;
                }
            }
            if(input_parameter_count==2)
            {
                first_data=arr[0];
                second_data=arr[1];

                command_count++;
                cout<<"Cmd "<<command_count<<": "<<operation<<" "<<first_data<<" "<<second_data<<endl;
                cout<<"\t";

                st.Insert(first_data,second_data);
            }
            else
            {
                command_count++;
                cout<<"Cmd "<<command_count<<": "<<operation<<" ";

                for(int i=0; i<input_parameter_count; i++)
                {
                    cout<<arr[i];
                    if(i!=input_parameter_count-1)
                        cout<<" ";
                }

                cout<<endl;
                cout<<"\t";
                cout<<"Wrong number of arguments for the command "<<operation<<endl;
            }
            break;
        }
        case 'L':
        {
            getline(cin,input_data);
            input_parameter_count=simple_tokenizer(input_data);
            string arr[input_parameter_count];
            int i=0;
            {
                stringstream ss(input_data);
                string word;
                while(ss>>word)
                {
                    arr[i]=word;
                    i++;
                }
            }

            if(input_parameter_count==1)
            {
                first_data=arr[0];
                command_count++;
                cout<<"Cmd "<<command_count<<": "<<operation<<" "<<first_data<<endl;
                cout<<"\t";
                st.Look_Up(first_data);
            }
            else
            {
                command_count++;
                cout<<"Cmd "<<command_count<<": "<<operation<<" ";
                for(int i=0; i<input_parameter_count; i++)
                {
                    cout<<arr[i];
                    if(i!=input_parameter_count-1)
                        cout<<" ";
                }

                cout<<endl;
                cout<<"\t";
                cout<<"Wrong number of arguments for the command "<<operation<<endl;
            }
            break;
        }
        case 'P':
        {
            getline(cin,input_data);
            input_parameter_count=simple_tokenizer(input_data);
            string arr[input_parameter_count];
            int i=0;
            {
                stringstream ss(input_data);
                string word;
                while(ss>>word)
                {
                    arr[i]=word;
                    i++;
                }
            }

            if(input_parameter_count==1)
            {
                first_data=arr[0];
                command_count++;
                cout<<"Cmd "<<command_count<<": "<<operation<<" "<<first_data<<endl;

                if(first_data=="C")
                    st.print_current_scope_table();
                else if(first_data=="A")
                    st.print_all_scope_table();
                else
                {
                    cout<<"\t";
                    cout<<"Invalid argument for the command "<<operation<<endl;
                }
            }

            else
            {
                command_count++;
                cout<<"Cmd "<<command_count<<": "<<operation<<" ";
                for(int i=0; i<input_parameter_count; i++)
                {
                    cout<<arr[i];
                    if(i!=input_parameter_count-1)
                        cout<<" ";
                }
                cout<<endl;
                cout<<"\t";
                cout<<"Wrong number of arguments for the command "<<operation<<endl;
            }
            break;
        }
        case 'D':
        {
            getline(cin,input_data);
            input_parameter_count=simple_tokenizer(input_data);
            string arr[input_parameter_count];
            int i=0;
            {
                stringstream ss(input_data);
                string word;
                while(ss>>word)
                {
                    arr[i]=word;
                    i++;
                }
            }

            if(input_parameter_count==1)
            {
                first_data=arr[0];
                command_count++;
                cout<<"Cmd "<<command_count<<": "<<operation<<" "<<first_data<<endl;
                cout<<"\t";
                st.Remove(first_data);
            }
            else
            {
                command_count++;
                if(input_parameter_count==0)
                    cout<<"Cmd "<<command_count<<": "<<operation;
                else
                    cout<<"Cmd "<<command_count<<": "<<operation<<" ";
                for(int i=0; i<input_parameter_count; i++)
                {
                    cout<<arr[i];
                    if(i!=input_parameter_count-1)
                        cout<<" ";
                }
                cout<<endl;
                cout<<"\t";
                cout<<"Wrong number of arguments for the command "<<operation<<endl;
            }
            break;
        }
        case 'S':
            command_count++;
            cout<<"Cmd "<<command_count<<": "<<operation<<endl;
            cout<<"\t";
            st.Enter_scope();
            break;
        case 'E':
            command_count++;
            cout<<"Cmd "<<command_count<<": "<<operation<<endl;
            cout<<"\t";
            st.Exit_scope();
            break;
        case 'Q':
            command_count++;
            cout<<"Cmd "<<command_count<<": "<<operation<<endl;
            st.~SymbolTable();
            return 0;
            break;
        default:
            cout<<"The operation is not valid"<<endl;
            break;
        }
    }

}

