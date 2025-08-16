
%{
    #include <bits/stdc++.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    using namespace std;
    void yyerror( string );
    int yylex(void);
    extern char* yytext;
    extern int yylineno;
    map<string, int> arrsize;
    map<string, string> list_str;
    map<string,int> mp;
    vector<string> bssvec;
    vector<string> datavec;
    vector<string> textvec;
    map<string,int> func_params;
    vector<int> params;
    int print_count=0;
    int param_count=0;
    int local_size=0;
    int flag=0,post=0;
    string rel="";
    int t1,t2;
    int ret_val;
%}

%union
{
    char* str;
    int val;
}

%token GLOBAL GOTO IF RETURN CALL MAIN LOCAL ABS BAS
%token ADD SUB MUL DIV EQ NE LT LE GT GE EQEQ OP CP OB CB
%token<str> PARAM LABEL GOTO_LABEL TEMPORARY F_IDENTIFIER IDENTIFIER STR C_CHAR
%token<val> NUMBER RETVAL
%type<val> expression relational_expression arithmetic_expression



%%

start: program
    {
        // cout << "MiniC Program Parsed Successfully!!\n";
    }
;

program: {bssvec.push_back("\t.bss");}globals {datavec.push_back("\t.data");textvec.push_back("\t.text");}functions main{
        //printf("program parsed");
    }
;

globals: globaldecl globals{
        // printf("global decl parsed");
    }|{
        //printf("global decl parsed");
    }
;

globaldecl: GLOBAL IDENTIFIER{
        // cout<<"wehffihwfi"<<endl;
        arrsize[$2] = 4;
        string s1= std::string($2) + ":\t.space\t4";
        bssvec.push_back(s1);
        // cout<<$2<<":\t"<<".space\t"<<4<<endl;
    }| GLOBAL IDENTIFIER OB TEMPORARY CB{
        //cout<<"wehffihwfi"<<endl;
        int size = arrsize[$4];
        arrsize[$2] = size;
        string s1= std::string($2) + ":\t.space\t" + to_string(size);
        bssvec.push_back(s1);
        // cout<<$2<<":\t"<<".space\t"<<size<<endl;
    }| TEMPORARY EQ NUMBER{
        //cout<<"wehffihwfi"<<endl;
        arrsize[$1] = $3;
    }
;

functions: function functions{
        //printf("function parsed");
    }|{
        //printf("function parsed");
    }
;

function: F_IDENTIFIER {string s2=std::string($1),s1="\n\t.globl\t" + s2;
        s1.pop_back();
        textvec.push_back(s1);
        textvec.push_back(s2);
        textvec.push_back("\tpushl\t%ebp");
        textvec.push_back("\tmovl\t%esp, %ebp");
        } decls RETURN{
        //printf("function parsed");
        // textvec.push_back("\tmovl\t$0, %eax\t\t\t\t\t#error_prone_line");
        textvec.push_back("\tleave");
        textvec.push_back("\tret");
    }
;

main: MAIN{textvec.push_back("\n\t.globl\tmain");
        textvec.push_back("main:");
        textvec.push_back("\tpushl\t%ebp");
        textvec.push_back("\tmovl\t%esp,\t%ebp");
        } decls RETURN{
        //printf("main parsed");
        // string s1="\tmovl\t"+to_string(ret_val) +"(ebp),\t%eax";
        // textvec.push_back(s1);
        textvec.push_back("\tleave");
        textvec.push_back("\tret");
    }

decls: paramdecls localdecls fundecls {
        //printf("decls parsed");
        local_size=0;
        func_params.clear();
    }
;

paramdecls: paramdecl paramdecls{
        //printf("paramdecls parsed");
    }|{
        //printf("paramdecls parsed");
    }
;

paramdecl:ABS IDENTIFIER EQ PARAM{
        //printf("paramdecl parsed");
        string str=std::string($4).substr(5,strlen($4)-5);
        // cerr<<($2)<<" "<<str<<endl;
        int index=atoi(str.c_str());
        // string s1="\tpushl\t"+ to_string(4*index+4)+"(%ebp)";
        // func_params.push_back(s1);
        func_params[$2]=4*index+4;
    }
;

localdecls: localdecl localdecls{
        //printf("localdecls parsed");
    }|{
        //printf("localdecls parsed");
    }
;

localdecl: LOCAL IDENTIFIER{
        //printf("localdecl parsed");
        local_size+=4;
        textvec.push_back("\tsubl\t$4, %esp");
        func_params[$2]=(-1)*local_size;
        // cout<<$2<<" "<<local_size<<"\t\t\t\t#printcheck"<<endl;
    }| BAS LOCAL IDENTIFIER TEMPORARY{
        int x=mp[$3];
        local_size+=x;
        textvec.push_back("\tsubl\t$" + to_string(x) + ", %esp");
    }
;

fundecls: fundecl fundecls{
        //printf("fundecls parsed");
    }|fundecl{
        //printf("fundecls parsed");
    }
;

fundecl: assignmt{
        //printf("fundecl parsed");
    }|func_call{
        //printf("fundecl parsed");
    }|if_statement{
        //printf("fundecl parsed");
    }|GOTO GOTO_LABEL{
        //printf("fundecl parsed");
        string s1= "\tjmp\t\t"+std::string($2);
        textvec.push_back(s1);
    }|LABEL{
        //printf("fundecl parsed");
        // string s = $1;
        textvec.push_back($1);
    }
;

assignmt: direct{
        //printf("assignmt parsed");
    }|indirect{
        //printf("assignmt parsed");
    }
;

direct: IDENTIFIER EQ TEMPORARY{
        // printf("direct parsed");
        // cout<<"iden = temp"<<endl;
        if(mp.find($3) != mp.end()){
            mp[$1] = mp[$3];
        }
        if(arrsize.find($1) == arrsize.end()){
            string s1= "\tmovl\t" + to_string(func_params[$3]) + "(%ebp), %eax";
            textvec.push_back(s1);
            textvec.push_back("\tmovl\t%eax, " + to_string(func_params[$1]) + "(%ebp)");
        }else{
            string s1= "\tmovl\t" + to_string(func_params[$3]) + "(%ebp), %eax";
            textvec.push_back(s1);
            s1= "\tmovl\t%eax,\t" + std::string($1);
            textvec.push_back(s1);
        }
    }|TEMPORARY EQ TEMPORARY{
        // printf("direct parsed");
        // cout<<"temp = temp"<<endl;
        if(list_str.find($3) != list_str.end()){
            string s = list_str[$3];
            list_str[$1] = s;
        }else if(mp.find($3) != mp.end()){
            mp[$1]=mp[$3];
        }
        if(func_params.find($3) != func_params.end()){
            if(func_params.find($1) == func_params.end()){
                local_size+=4;
                textvec.push_back("\tsubl\t$4, %esp");
                func_params[$1]=(-1)*local_size;
            }
            string s1= "\tmovl\t" + to_string(func_params[$3]) + "(%ebp), %eax";
            textvec.push_back(s1);
            s1= "\tmovl\t%eax, " + to_string(func_params[$1]) + "(%ebp)";
            textvec.push_back(s1);
        }
    }|TEMPORARY EQ ADD TEMPORARY{
        // printf("direct parsed");
        // cout<<"temp = temp"<<endl;
        if(mp.find($4) != mp.end()){
            mp[$1]=mp[$4];
        }
        if(func_params.find($4) != func_params.end()){
            if(func_params.find($1) == func_params.end()){
                local_size+=4;
                textvec.push_back("\tsubl\t$4, %esp");
                func_params[$1]=(-1)*local_size;
            }
            string s1= "\tmovl\t" + to_string(func_params[$4]) + "(%ebp), %eax";
            textvec.push_back(s1);
            s1= "\tmovl\t%eax, " + to_string(func_params[$1]) + "(%ebp)";
            textvec.push_back(s1);
        }
    }|TEMPORARY EQ SUB TEMPORARY{
        // printf("direct parsed");
        // cout<<"temp = temp"<<endl;
        if(mp.find($4) != mp.end()){
            mp[$1]= (-1)*mp[$4];
        }
        if(func_params.find($4) != func_params.end()){
            if(func_params.find($1) == func_params.end()){
                local_size+=4;
                textvec.push_back("\tsubl\t$4, %esp");
                func_params[$1]=(-1)*local_size;
            }
            string s1= "\tmovl\t" + to_string(func_params[$4]) + "(%ebp), %eax";
            textvec.push_back(s1);
            s1="\timull\t$-1,\t%eax";
            textvec.push_back(s1);
            s1= "\tmovl\t%eax, " + to_string(func_params[$1]) + "(%ebp)";
            textvec.push_back(s1);
        }
    }|TEMPORARY EQ NUMBER{
        //printf("direct parsed");
        // cout<<"temp = num"<<endl;
        mp[$1]=$3;
        if(func_params.find($1) == func_params.end()){
            local_size+=4;
            textvec.push_back("\tsubl\t$4, %esp");
            func_params[$1]=(-1)*local_size;
        }
        string s1="\tmovl\t$" + to_string($3)+",\t"+ to_string(func_params[$1]) +"(%ebp)";
        textvec.push_back(s1);
        // cout<<$1<<" "<<$3<<endl;
    }|TEMPORARY EQ IDENTIFIER{
        //printf("direct parsed");
        // cout<<"temp = iden"<<endl;
        if(func_params.find($1) == func_params.end()){
            local_size+=4;
            textvec.push_back("\tsubl\t$4, %esp\t\t\t\t#error prone");
            func_params[$1]=(-1)*local_size;
            // cerr<<$1 <<" "<<$3<<" "<<func_params[$1]<<endl;
        }
        if(mp.find($3)!=mp.end()){
            mp[$1]=mp[$3];
        }
        if(arrsize.find($3) != arrsize.end()){
            string s1="\tmovl\t" + std::string($3)+",\t%eax";
            textvec.push_back(s1);
            // string s2="\tmovl\t(%eax),\t" + std::string("%ebx");
            // textvec.push_back(s2);
            string s3="\tmovl\t%eax,\t" + to_string(func_params[$1]) + "(%ebp)";
            textvec.push_back(s3);
        }else{
            string s1="\tmovl\t" + to_string(func_params[$3]) + "(%ebp),\t%eax";
            textvec.push_back(s1);
            string s2="\tmovl\t%eax,\t" + to_string(func_params[$1]) + "(%ebp)";
            textvec.push_back(s2);
        }
        // movl $a, (%eax)
        // movl %eax, -4(%ebp)
        // func_params[$1]=func_params[$3];
    }|TEMPORARY EQ STR{
        //printf("direct parsed");
        // cout<<"temp = str"<<endl;
        if(func_params.find($1) == func_params.end()){
            local_size+=4;
            textvec.push_back("\tsubl\t$4, %esp");
            func_params[$1]=(-1)*local_size;
        }
        print_count++;
        string s1="fmt" + to_string(print_count) + ":\t.asciz\t" + std::string($3);
        datavec.push_back(s1);
        list_str[$1] = $3;
    }|TEMPORARY EQ C_CHAR{
        //printf("direct parsed");
        // cout<<"temp = char"<<endl;
    }|TEMPORARY EQ RETVAL{
        //printf("direct parsed");
        // cout<<"temp = ret"<<endl;
        mp[$1]=$3;
        if(func_params.find($1) == func_params.end()){
            local_size+=4;
            textvec.push_back("\tsubl\t$4, %esp");
            func_params[$1]=(-1)*local_size;
        }
        string s1= std::string("\tmovl\t") + "%eax,\t" + to_string(func_params[$1]) + "(%ebp)";
        textvec.push_back(s1);
    }|RETVAL EQ TEMPORARY{
        //printf("direct parsed");
        // cout<<"ret = temp"<<endl;
        $1=mp[$3];
        string s1="\tmovl\t" + to_string(func_params[$3]) + "(%ebp),\t%eax";
        textvec.push_back(s1);
    }
;

indirect: TEMPORARY EQ expression{
        //printf("indirect parsed");
        // cout<<"temp = exp"<<endl;
        if(post==1){
            if(func_params.find($1) == func_params.end()){
                local_size+=4;
                textvec.push_back("\tsubl\t$4,\t%esp");
                func_params[$1]=(-1)*local_size;
            }
            mp[$1]=$3;
            int x=$3;
            // string s1="\tmovl\t$" + to_string(x) + ",\t%eax";
            // textvec.push_back(s1);
            string s1="\tmovl\t%eax,\t" + to_string(func_params[$1]) + "(%ebp)";
            textvec.push_back(s1);
        }
        post=0;
    }
;

expression: arithmetic_expression{
        //printf("expression parsed");
        $$=$1;
        post=1;
    }|relational_expression{
        //printf("expression parsed");
        $$=$1;
    }
;

arithmetic_expression: TEMPORARY ADD TEMPORARY{
        //printf("arithmetic_expression_tail parsed");
        $$=mp[$1] + mp[$3];
        string s1="\tmovl\t" + to_string(func_params[$1]) + "(%ebp),\t%eax";
        textvec.push_back(s1);
        s1="\taddl\t" + to_string(func_params[$3]) + "(%ebp),\t%eax";
        textvec.push_back(s1);
        // s1="\tmovl\t%eax,\t" + to_string(func_params[$1]) + "(%ebp)\t\t\t\t#error_prone_line";
        // textvec.push_back(s1);
    }|TEMPORARY SUB TEMPORARY{
        //printf("arithmetic_expression_tail parsed");
        $$=mp[$1] - mp[$3];
        string s1="\tmovl\t" + to_string(func_params[$1]) + "(%ebp),\t%eax";
        textvec.push_back(s1);
        s1="\tsubl\t" + to_string(func_params[$3]) + "(%ebp),\t%eax";
        textvec.push_back(s1);
    }|TEMPORARY MUL TEMPORARY{
        //printf("arithmetic_expression_tail parsed");
        $$=mp[$1] * mp[$3];
        string s1="\tmovl\t" + to_string(func_params[$1]) + "(%ebp),\t%eax";
        textvec.push_back(s1);
        s1="\timull\t" + to_string(func_params[$3]) + "(%ebp),\t%eax";
        textvec.push_back(s1);
    }|TEMPORARY DIV TEMPORARY{
        //printf("arithmetic_expression_tail parsed");
        // cerr<<mp[$1]<<" "<<mp[$3]<<endl;
        if(mp[$3]!=0){
            $$=mp[$1] / mp[$3];
        }else{
            int x= INT_MAX;
            $$=x;
        }
        string s1="\tmovl\t" + to_string(func_params[$1]) + "(%ebp),\t%eax";
        textvec.push_back(s1);
        s1="\tmovl\t" + to_string(func_params[$3]) + "(%ebp),\t%ebx";
        textvec.push_back(s1);
        textvec.push_back("\tcdq\t");
        s1= std::string("\tidivl\t") + "%ebx";
        textvec.push_back(s1);
    }
;

relational_expression:TEMPORARY EQEQ TEMPORARY{
        //printf("relational_expression_tail parsed");
        if(mp[$1]==mp[$3]){
            $$=1;
        }else{
            $$=0;
        }
        rel="e";
        t1=func_params[$1];
        t2=func_params[$3];
    }|TEMPORARY NE TEMPORARY{
        //printf("relational_expression_tail parsed");
        if(mp[$1]!=mp[$3]){
            $$=1;
        }else{
            $$=0;
        }
        rel="ne";
        t1=func_params[$1];
        t2=func_params[$3];
    }|TEMPORARY LT TEMPORARY{
        //printf("relational_expression_tail parsed");
        if(mp[$1]<mp[$3]){
            $$=1;
        }else{
            $$=0;
        }
        rel="l";
        t1=func_params[$1];
        t2=func_params[$3];
    }|TEMPORARY LE TEMPORARY{
        //printf("relational_expression_tail parsed");
        if(mp[$1]<=mp[$3]){
            $$=1;
        }else{
            $$=0;
        }
        rel="le";
        t1=func_params[$1];
        t2=func_params[$3];
    }|TEMPORARY GT TEMPORARY{
        //printf("relational_expression_tail parsed");
        if(mp[$1]>mp[$3]){
            $$=1;
        }else{
            $$=0;
        }
        rel="g";
        t1=func_params[$1];
        t2=func_params[$3];
    }|TEMPORARY GE TEMPORARY{
        //printf("relational_expression_tail parsed");
        if(mp[$1]>=mp[$3]){
            $$=1;
        }else{
            $$=0;
        }
        rel="ge";
        t1=func_params[$1];
        t2=func_params[$3];
    }
;

if_statement: IF OP TEMPORARY CP GOTO GOTO_LABEL
{
        //printf("if_statement parsed");
        string s1;
        s1="\tmovl\t" + to_string(t1) + "(%ebp),\t%eax";
        textvec.push_back(s1);
        s1= "\tcmpl\t"+ to_string(t2) + "(%ebp),\t%eax" ;
        textvec.push_back(s1);
        s1= "\tj"+rel+"\t\t"+std::string($6);
        textvec.push_back(s1);
        rel="";
    }
;

func_call: func_params {
            for(int i=0;i<param_count;i++){
                int y= *params.rbegin();
                string s1="\tmovl\t" + to_string(y) + "(%ebp),\t%eax";
                textvec.push_back(s1);
                s1 = std::string("\tpushl\t") + "%eax";
                textvec.push_back(s1);
                params.pop_back();
            }
            if(flag==1){
                textvec.push_back("\tmovl\t$fmt" + to_string(print_count) + ",\t%eax");
                string s1 = std::string("\tpushl\t") + "%eax";
                textvec.push_back(s1);
            }
            // flag=0;
            // param_count=0;
        } CALL IDENTIFIER{
        //printf("func_call parsed");
        textvec.push_back("\tcall\t" + std::string($4));
        int x=4*param_count;
        if(flag==1){
            x+=4;
        }
        string s1 = "\taddl\t$" + std::to_string(x) + ", %esp";
        textvec.push_back(s1);
        flag=0;
        param_count=0;
    }
;

func_params: func_param func_params{
        //printf("func_params parsed");
    }|{
        //printf("func_params parsed");
    }
;

func_param: PARAM EQ TEMPORARY{
        //printf("func_param parsed");
        // params.push_back(mp[$3]);
        if(list_str.find($3) != list_str.end()){
            string s = list_str[$3];
            param_count--;
            flag=1;
        }
        params.push_back(func_params[$3]);
        param_count++;
    }|PARAM EQ IDENTIFIER{
        //printf("func_param parsed");
        // params.push_back(mp[$3]);
        param_count++;
    }
;


%%

void yyerror( string s) {
    cerr<<s<<" "<<yylineno<<endl;
}

int main(void) {
    yyparse();
    for(auto i:bssvec){
        cout<<i<<endl;
    }
    cout<<endl;
    for(auto i:datavec){
        cout<<i<<endl;
    }
    cout<<endl;
    for(auto i:textvec){
        cout<<i<<endl;
    }
    cout<<endl;
    return 0;
}
