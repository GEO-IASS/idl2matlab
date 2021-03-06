/***************************************
  $Header: /home/amb/cxref/RCS/latex.c 1.35 2001/01/06 13:05:12 amb Exp $

  C Cross Referencing & Documentation tool. Version 1.5c.

  Writes the Latex output.
  ******************/ /******************
  Written by Andrew M. Bishop

  This file Copyright 1995,96,97,98,2001 Andrew M. Bishop
  It may be distributed under the GNU Public License, version 2, or
  any higher version.  See section COPYING of the GNU Public license
  for conditions under which this file may be redistributed.
  ***************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#ifndef min
#define min(x,y) ( (x) < (y) ? (x) : (y) )
#endif

#include "memory.h"
#include "datatype.h"
#include "cxref.h"

/*+ The name of the output tex file that includes each of the others. +*/
#define LATEX_FILE        ".tex"
#define LATEX_FILE_BACKUP ".tex~"

/*+ The name of the output tex file that contains the appendix. +*/
#define LATEX_APDX        ".apdx"

/*+ The comments are to be inserted verbatim. +*/
extern int option_verbatim_comments;

/*+ The type of LaTeX output to produce. +*/
extern int option_latex;

/*+ The name of the directory for the output. +*/
extern char* option_odir;

/*+ The base name of the file for the output. +*/
extern char* option_name;

/*+ The information about the cxref run, +*/
extern char *run_command,       /*+ the command line options. +*/
            *run_cpp_command;   /*+ the cpp command and options. +*/

extern char *latex_fonts_style,*latex_page_style,*latex_cxref_style;

static void WriteLatexFilePart(File file);
static void WriteLatexInclude(Include inc);
static void WriteLatexSubInclude(Include inc,int depth);
static void WriteLatexDefine(Define def);
static void WriteLatexTypedef(Typedef type,char* filename);
static void WriteLatexStructUnion(StructUnion su,int depth);
static void WriteLatexVariable(Variable var,char* filename);
static void WriteLatexFunction(Function func,char* filename);

static void WriteLatexDocument(char* name,int appendix);
static void WriteLatexTemplate(char* name);

static char* latex(char* c,int verbatim);

/*+ The output file for the latex. +*/
static FILE* of;

/*+ Counts the lines in a table to insert breaks. +*/
static int countlines=0;


/*++++++++++++++++++++++++++++++++++++++
  Write a Latex file for a complete File structure and all components.

  File file The File structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

void WriteLatexFile(File file)
{
 char* ofile;

 /* Write the including file. */

 WriteLatexDocument(file->name,0);

 /* Open the file */

 ofile=ConcatStrings(4,option_odir,"/",file->name,LATEX_FILE);

 of=fopen(ofile,"w");
 if(!of)
   {
    struct stat stat_buf;
    int i,ofl=strlen(ofile);

    for(i=strlen(option_odir)+1;i<ofl;i++)
       if(ofile[i]=='/')
         {
          ofile[i]=0;
          if(stat(ofile,&stat_buf))
             mkdir(ofile,S_IRUSR|S_IWUSR|S_IXUSR|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
          ofile[i]='/';
         }

    of=fopen(ofile,"w");
   }

 if(!of)
   {fprintf(stderr,"cxref: Failed to open the LaTeX output file '%s'\n",ofile);exit(1);}

 /* Write out a header. */

 fputs("% This LaTeX file generated by cxref\n",of);
 fputs("% cxref program (c) Andrew M. Bishop 1995,96,97,98,99.\n",of);
 fputs("\n",of);
 fprintf(of,"%% Cxref: %s %s\n",run_command,file->name);
 fprintf(of,"%% CPP  : %s\n",run_cpp_command);
 fputs("\n",of);

 /*+ The file structure is broken into its components and they are each written out. +*/

 WriteLatexFilePart(file);

 if(file->includes)
   {
    Include inc =file->includes;
    fprintf(of,"\n\\subsection*{Included Files}\n\n");
    do{
       if(inc!=file->includes)
          fprintf(of,"\\medskip\n");
       WriteLatexInclude(inc);
      }
    while((inc=inc->next));
   }

 if(file->defines)
   {
    Define def =file->defines;
    fprintf(of,"\n\\subsection*{Preprocessor definitions}\n\n");
    do{
       if(def!=file->defines)
          fprintf(of,"\\medskip\n");
       WriteLatexDefine(def);
      }
    while((def=def->next));
   }

 if(file->typedefs)
   {
    Typedef type=file->typedefs;
    fprintf(of,"\n\\subsection{Type definitions}\n\n");
    do{
       WriteLatexTypedef(type,file->name);
      }
    while((type=type->next));
   }

 if(file->variables)
   {
    int any_to_mention=0;
    Variable var=file->variables;

    do{
       if(var->scope&(GLOBAL|LOCAL|EXTERNAL|EXTERN_F))
          any_to_mention=1;
      }
    while((var=var->next));

    if(any_to_mention)
      {
       int first_ext=1,first_local=1;
       Variable var=file->variables;
       fprintf(of,"\n\\subsection{Variables}\n\n");
       do{
          if(var->scope&GLOBAL)
             WriteLatexVariable(var,file->name);
         }
       while((var=var->next));
       var=file->variables;
       do{
          if(var->scope&(EXTERNAL|EXTERN_F) && !(var->scope&GLOBAL))
            {
             if(first_ext)
               {fprintf(of,"\n\\subsubsection{External Variables}\n\n"); first_ext=0;}
             else
                fprintf(of,"\\medskip\n");
             WriteLatexVariable(var,file->name);
            }
         }
       while((var=var->next));
       var=file->variables;
       do{
          if(var->scope&LOCAL)
            {
             if(first_local)
               {fprintf(of,"\n\\subsubsection{Local Variables}\n\n"); first_local=0;}
             else
                fprintf(of,"\\medskip\n");
             WriteLatexVariable(var,file->name);
            }
         }
       while((var=var->next));
      }
   }

 if(file->functions)
   {
    Function func=file->functions;
    fprintf(of,"\n\\subsection{Functions}\n\n");
    do{
       if(func->scope&(GLOBAL|EXTERNAL))
          WriteLatexFunction(func,file->name);
      }
    while((func=func->next));
    func=file->functions;
    do{
       if(func->scope&LOCAL)
          WriteLatexFunction(func,file->name);
      }
    while((func=func->next));
   }

 fclose(of);

 /* Clear the memory in latex() */

 latex(NULL,0); latex(NULL,0); latex(NULL,0); latex(NULL,0);
}


/*++++++++++++++++++++++++++++++++++++++
  Write a File structure out.

  File file The File to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexFilePart(File file)
{
 int i;

 fprintf(of,"\\markboth{File %s}{File %s}\n",latex(file->name,0),latex(file->name,0));
 fprintf(of,"\\section{File %s}\n",latex(file->name,0));
 fprintf(of,"\\label{file_%s}\n\n",file->name);

 if(file->comment)
   {
    if(option_verbatim_comments)
       fprintf(of,"\\begin{verbatim}\n%s\n\\end{verbatim}\n\n",latex(file->comment,1));
    else
      {
       char *rcs1=strstr(file->comment,"$Header"),*rcs2=NULL;
       if(rcs1)
         {
          rcs2=strstr(&rcs1[1],"$");
          if(rcs2)
            {
             rcs2[0]=0;
             fprintf(of,"{\\bf RCS %s}\n\n",latex(&rcs1[1],0));
             fprintf(of,"\\smallskip\n");
             rcs2[0]='$';
            }
         }
       if(rcs2)
          fprintf(of,"%s\n\n",latex(&rcs2[2],0));
       else
          fprintf(of,"%s\n\n",latex(file->comment,0));
      }
   }

 if(file->inc_in->n)
   {
    int i;

    if(file->comment)
       fprintf(of,"\\medskip\n");
    fprintf(of,"\\begin{cxreftabii}\nIncluded in:");
    for(i=0;i<file->inc_in->n;i++)
      {/* Allow a break in every 8 (or so) items to allow the table to break over the page. */
       if(min(i,file->inc_in->n-i)%8 == 4)
          fprintf(of,"\\cxreftabbreak{cxreftabii}\n");
       fprintf(of,"\\ & %s & \\cxreffile{%s}\\\\\n",latex(file->inc_in->s[i],0),file->inc_in->s[i]);
      }
    fprintf(of,"\\end{cxreftabii}\n\n");
   }

 if(file->f_refs->n || file->v_refs->n)
   {
    int tabcount=0;
    fprintf(of,"\\smallskip\n");
    fprintf(of,"\\begin{cxreftabiii}\n");

    if(file->f_refs->n)
      {
       int others=0;

       fprintf(of,"Refs Func:");

       for(i=0;i<file->f_refs->n;i++)
          if(file->f_refs->s2[i])
            {
             fprintf(of,"\\ & %s() & %s & \\cxreffunc{%s}{%s}\\\\\n",latex(file->f_refs->s1[i],0),latex(file->f_refs->s2[i],0),file->f_refs->s1[i],file->f_refs->s2[i]);
             if(++tabcount%8 == 4)
                fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
            }
          else
             others++;

       if(others)
         {
          fprintf(of,"\\ & \\cxreftabiiispan{");
          for(i=0;i<file->f_refs->n;i++)
             if(!file->f_refs->s2[i])
                fprintf(of,--others?"%s(), ":"%s()",latex(file->f_refs->s1[i],0));
          fprintf(of,"} &\\\\\n");
         }
      }

    if(file->v_refs->n)
      {
       int others=0;

       fprintf(of,"Refs Var:");

       for(i=0;i<file->v_refs->n;i++)
          if(file->v_refs->s2[i])
            {
             fprintf(of,"\\ & %s & %s & \\cxrefvar{%s}{%s}\\\\\n",latex(file->v_refs->s1[i],0),latex(file->v_refs->s2[i],0),file->v_refs->s1[i],file->v_refs->s2[i]);
             if(++tabcount%8 == 4)
                fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
            }
          else
             others++;

       if(others)
         {
          fprintf(of,"\\ & \\cxreftabiiispan{");
          for(i=0;i<file->v_refs->n;i++)
             if(!file->v_refs->s2[i])
                fprintf(of,--others?" %s,":" %s",latex(file->v_refs->s1[i],0));
          fprintf(of,"} &\\\\\n");
         }
      }

    fprintf(of,"\\end{cxreftabiii}\n\n");
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Write an Include structure out.

  Include inc The Include structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexInclude(Include inc)
{
 if(inc->comment)
    fprintf(of,"%s\n\n\\smallskip\n",latex(inc->comment,0));

 fprintf(of,"\\begin{cxreftabi}\n"); countlines=1;

 if(inc->scope==LOCAL)
    fprintf(of,"{\\stt \\#include \"%s\"} &\\cxreffile{%s}\\\\\n",latex(inc->name,0),inc->name);
 else
    fprintf(of,"{\\stt \\#include <%s>} &\\\\\n",latex(inc->name,0));

 if(inc->includes)
    WriteLatexSubInclude(inc->includes,1);

 fprintf(of,"\\end{cxreftabi}\n\n");
}


/*++++++++++++++++++++++++++++++++++++++
  Write an Sub Include structure out. (An include structure that is included from another file.)

  Include inc The Include structure to output.

  int depth The depth of the include hierarchy.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexSubInclude(Include inc,int depth)
{
 while(inc)
   {
    if(countlines++%8==4)
       fprintf(of,"\\cxreftabbreak{cxreftabi}\n");

    fprintf(of,"\\hspace*{%3.1fin}",0.2*depth);

    if(inc->scope==LOCAL)
       fprintf(of,"{\\stt \\#include \"%s\"} &\\cxreffile{%s}\\\\\n",latex(inc->name,0),inc->name);
    else
       fprintf(of,"{\\stt \\#include <%s>} &\\\\\n",latex(inc->name,0));

    if(inc->includes)
       WriteLatexSubInclude(inc->includes,depth+1);

    inc=inc->next;
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Write a Define structure out.

  Define def The Define structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexDefine(Define def)
{
 int i;
 int pargs=0;

 if(def->comment)
    fprintf(of,"%s\n\n\\smallskip\n",latex(def->comment,0));

 fprintf(of,"{\\stt \\#define %s",latex(def->name,0));

 if(def->value)
    fprintf(of," %s",latex(def->value,0));

 if(def->args->n)
   {
    fprintf(of,"( ");
    for(i=0;i<def->args->n;i++)
       fprintf(of,i?", %s":"%s",latex(def->args->s1[i],0));
    fprintf(of," )");
   }
 fprintf(of,"}\n\n");

 for(i=0;i<def->args->n;i++)
    if(def->args->s2[i])
       pargs=1;

 if(pargs)
   {
    fprintf(of,"\\smallskip\n");
    fprintf(of,"\\begin{cxrefarglist}\n");
    for(i=0;i<def->args->n;i++)
       fprintf(of,"\\cxrefargitem{%s} %s\n",latex(def->args->s1[i],0),def->args->s2[i]?latex(def->args->s2[i],0):"\\ ");
    fprintf(of,"\\end{cxrefarglist}\n\n");
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Write a Typedef structure out.

  Typedef type The Typedef structure to output.

  char* filename The name of the file that is being processed (required for the cross reference label).
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexTypedef(Typedef type,char* filename)
{
 if(type->type)
    fprintf(of,"\n\\subsubsection{Typedef %s}\n",latex(type->name,0));
 else
    fprintf(of,"\n\\subsubsection{Type %s}\n",latex(type->name,0));

 if(!strncmp("enum",type->name,4))
    fprintf(of,"\\label{type_enum_%s_%s}\n\n",&type->name[5],filename);
 else
    if(!strncmp("union",type->name,5))
       fprintf(of,"\\label{type_union_%s_%s}\n\n",&type->name[6],filename);
    else
       if(!strncmp("struct",type->name,6))
          fprintf(of,"\\label{type_struct_%s_%s}\n\n",&type->name[7],filename);
       else
          fprintf(of,"\\label{type_%s_%s}\n\n",type->name,filename);

 if(type->comment)
    fprintf(of,"%s\n\n\\smallskip\n",latex(type->comment,0));

 if(type->type)
    fprintf(of,"{\\stt typedef %s}\n\n",latex(type->type,0));

 if(type->sutype)
   {
    fprintf(of,"\\smallskip\n");
    fprintf(of,"\\begin{cxreftabiia}\n"); countlines=0;
    WriteLatexStructUnion(type->sutype,0);
    fprintf(of,"\\end{cxreftabiia}\n\n");
   }
 else
    if(type->typexref)
      {
       fprintf(of,"\\smallskip\n");
       fprintf(of,"\\begin{cxreftabii}\n");
       if(type->typexref->type)
          fprintf(of,"See:& Typedef %s & \\cxreftype{%s}{%s}\\\\\n",latex(type->typexref->name,0),type->typexref->name,filename);
       else
          if(!strncmp("enum",type->typexref->name,4))
             fprintf(of,"See:& Type %s & \\cxreftype{enum_%s}{%s}\\\\\n",latex(type->typexref->name,0),&type->typexref->name[5],filename);
          else
             if(!strncmp("union",type->typexref->name,5))
                fprintf(of,"See:& Type %s & \\cxreftype{union_%s}{%s}\\\\\n",latex(type->typexref->name,0),&type->typexref->name[6],filename);
             else
                if(!strncmp("struct",type->typexref->name,6))
                   fprintf(of,"See:& Type %s & \\cxreftype{struct_%s}{%s}\\\\\n",latex(type->typexref->name,0),&type->typexref->name[7],filename);
       fprintf(of,"\\end{cxreftabii}\n\n");
      }
}


/*++++++++++++++++++++++++++++++++++++++
  Write a structure / union structure out.

  StructUnion su The structure / union to write.

  int depth The current depth within the structure.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexStructUnion(StructUnion su, int depth)
{
 int i;
 char* splitsu=NULL;

 splitsu=strstr(su->name,"{...}");
 if(splitsu) splitsu[-1]=0;

 if(countlines++%8==4)
    fprintf(of,"\\cxreftabbreak{cxreftabiia}\n");
 fprintf(of,"\\hspace*{%3.1fin}",0.2*depth);

 if(depth && su->comment && !su->comps)
    fprintf(of,"{\\stt %s;} & %s \\\\\n",latex(su->name,0),latex(su->comment,0));
 else if(!depth || su->comps)
    fprintf(of,"{\\stt %s} &\\\\\n",latex(su->name,0));
 else
    fprintf(of,"{\\stt %s;} &\\\\\n",latex(su->name,0));

 if(!depth || su->comps)
   {
    fprintf(of,"\\hspace*{%3.1fin}",0.1+0.2*depth);
    fprintf(of,"{\\stt \\{} &\\\\\n");

    for(i=0;i<su->n_comp;i++)
       WriteLatexStructUnion(su->comps[i],depth+1);

    fprintf(of,"\\hspace*{%3.1fin}",0.1+0.2*depth);
    fprintf(of,"{\\stt \\}} &\\\\\n");
    if(splitsu)
      {
       fprintf(of,"\\hspace*{%3.1fin}",0.1+0.2*depth);
       if(depth && su->comment)
          fprintf(of,"{\\stt %s;} & %s \\\\\n",splitsu[5]?latex(&splitsu[6],0):"",latex(su->comment,0));
       else
          fprintf(of,"{\\stt %s;} &\\\\\n",splitsu[5]?latex(&splitsu[6],0):"");
      }
   }

 if(splitsu) splitsu[-1]=' ';
}


/*++++++++++++++++++++++++++++++++++++++
  Write a Variable structure out.

  Variable var The Variable structure to output.

  char* filename The name of the file that is being processed (required for the cross reference label).
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexVariable(Variable var,char* filename)
{
 int i;

 if(var->scope&GLOBAL)
    fprintf(of,"\n\\subsubsection{Variable %s}\n",latex(var->name,0));
 else
    fprintf(of,"{\\bf %s}\n",latex(var->name,0));

 fprintf(of,"\\label{var_%s_%s}\n\n",var->name,filename);

 if(var->comment)
    fprintf(of,"%s\n\n\\smallskip\n",latex(var->comment,0));

 fprintf(of,"{\\stt ");

 if(var->scope&LOCAL)
    fprintf(of,"static ");
 else
    if(!(var->scope&GLOBAL) && var->scope&(EXTERNAL|EXTERN_F))
       fprintf(of,"extern ");

 fprintf(of,"%s}\n\n",latex(var->type,0));

 if(var->scope&(GLOBAL|LOCAL))
   {
    if(var->incfrom || var->used->n || var->visible->n)
      {
       fprintf(of,"\\smallskip\n");
       fprintf(of,"\\begin{cxreftabiii}\n");

       if(var->incfrom)
          fprintf(of,"Inc. from:& %s & \\ & \\cxrefvar{%s}{%s}\\\\\n",latex(var->incfrom,0),var->name,var->incfrom);

       for(i=0;i<var->visible->n;i++)
         {
          if(min(i,var->visible->n+var->used->n-i)%8 == 4)
             fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
          if(i==0) fprintf(of,"Visible in:");
          if(var->visible->s1[i][0]=='$' && !var->visible->s1[i][1])
             fprintf(of,"\\ & %s & \\ & \\cxreffile{%s}\\\\\n",latex(var->visible->s2[i],0),var->visible->s2[i]);
          else
             fprintf(of,"\\ & %s() & %s & \\cxreffunc{%s}{%s}\\\\\n",latex(var->visible->s1[i],0),latex(var->visible->s2[i],0),var->visible->s1[i],var->visible->s2[i]);
         }

       for(i=0;i<var->used->n;i++)
         {
          if(min(i,var->visible->n+var->used->n-i)%8 == 4)
             fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
          if(i==0) fprintf(of,"Used in:");
          if(var->used->s1[i][0]=='$' && !var->used->s1[i][1])
             fprintf(of,"\\ & %s & \\ & \\cxreffile{%s}\\\\\n",latex(var->used->s2[i],0),var->used->s2[i]);
          else
             if(var->scope&LOCAL)
                fprintf(of,"\\ & %s() & \\ & \\cxreffunc{%s}{%s}\\\\\n",latex(var->used->s1[i],0),var->used->s1[i],var->used->s2[i]);
             else
                fprintf(of,"\\ & %s() & %s & \\cxreffunc{%s}{%s}\\\\\n",latex(var->used->s1[i],0),latex(var->used->s2[i],0),var->used->s1[i],var->used->s2[i]);
         }

       fprintf(of,"\\end{cxreftabiii}\n\n");
      }
   }
 else
    if(var->scope&(EXTERNAL|EXTERN_F) && var->defined)
      {
       fprintf(of,"\\smallskip\n");
       fprintf(of,"\\begin{cxreftabiii}\n");
       fprintf(of,"Defined in:& %s & \\ & \\cxrefvar{%s}{%s}\\\\\n",latex(var->defined,0),var->name,var->defined);
       fprintf(of,"\\end{cxreftabiii}\n\n");
      }
}


/*++++++++++++++++++++++++++++++++++++++
  Write a Function structure out.

  Function func The Function structure to output.

  char* filename The name of the file that is being processed (required for the cross reference label).
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexFunction(Function func,char* filename)
{
 int i,pret,pargs;
 char* comment2=NULL,*type;

 if(func->scope&GLOBAL)
    fprintf(of,"\n\\subsubsection{Global Function %s()}\n",latex(func->name,0));
 else
    fprintf(of,"\n\\subsubsection{Local Function %s()}\n",latex(func->name,0));
 fprintf(of,"\\label{func_%s_%s}\n\n",func->name,filename);

 if(func->comment)
   {
    if(option_verbatim_comments)
       fprintf(of,"\\begin{verbatim}\n%s\n\\end{verbatim}\n\n",latex(func->comment,1));
    else
      {
       comment2=strstr(func->comment,"\n\n");
       if(comment2)
          comment2[0]=0;
       fprintf(of,"%s\n\n",latex(func->comment,0));
       fprintf(of,"\\smallskip\n");
      }
   }

 fprintf(of,"{\\stt ");

 if(func->scope&LOCAL)
    fprintf(of,"static ");
 if(func->scope&INLINED)
   fprintf(of,"inline ");

 if((type=strstr(func->type,"()")))
    type[0]=0;
 fprintf(of,"%s ( ",latex(func->type,0));

 for(i=0;i<func->args->n;i++)
    fprintf(of,i?", %s":"%s",latex(func->args->s1[i],0));

 if(type)
   {fprintf(of," %s}\n\n",&type[1]);type[0]='(';}
 else
    fprintf(of," )}\n\n");

 pret =strncmp("void ",func->type,5) && func->cret;
 for(pargs=0,i=0;i<func->args->n;i++)
    pargs = pargs || ( strcmp("void",func->args->s1[i]) && func->args->s2[i] );

 if(pret || pargs)
   {
    fprintf(of,"\\smallskip\n");
    fprintf(of,"\\begin{cxrefarglist}\n");
    if(pret)
       fprintf(of,"\\cxrefargitem{%s} %s\n",latex(func->type,0),func->cret?latex(func->cret,0):"\\ ");
    if(pargs)
       for(i=0;i<func->args->n;i++)
          fprintf(of,"\\cxrefargitem{%s} %s\n",latex(func->args->s1[i],0),func->args->s2[i]?latex(func->args->s2[i],0):"\\ ");
    fprintf(of,"\\end{cxrefarglist}\n\n");
   }

 if(comment2)
   {
    fprintf(of,"\\smallskip\n");
    fprintf(of,"%s\n\n",latex(&comment2[2],0));
    comment2[0]='\n';
   }

 if(func->protofile || func->incfrom || func->calls->n || func->called->n || func->used->n || func->f_refs->n || func->v_refs->n)
   {
    int tabcount=func->protofile?1:0;
    fprintf(of,"\\smallskip\n");
    fprintf(of,"\\begin{cxreftabiii}\n");

    if(func->protofile)
       fprintf(of,"Prototype:& %s & \\ & \\cxreffile{%s}\\\\\n",latex(func->protofile,0),func->protofile);

    if(func->incfrom)
       fprintf(of,"Inc. from:& %s & \\ & \\cxreffunc{%s}{%s}\\\\\n",latex(func->incfrom,0),func->name,func->incfrom);

    if(func->calls->n)
      {
       int others=0;

       fprintf(of,"Calls:");

       for(i=0;i<func->calls->n;i++)
          if(func->calls->s2[i])
            {
             fprintf(of,"\\ & %s() & %s & \\cxreffunc{%s}{%s}\\\\\n",latex(func->calls->s1[i],0),latex(func->calls->s2[i],0),func->calls->s1[i],func->calls->s2[i]);
             if(++tabcount%8 == 4)
                fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
            }
          else
             others++;

       if(others)
         {
          fprintf(of,"\\ & \\cxreftabiiispan{");
          for(i=0;i<func->calls->n;i++)
             if(!func->calls->s2[i])
                fprintf(of,--others?" %s(),":" %s()",latex(func->calls->s1[i],0));
          fprintf(of,"} &\\\\\n");
         }
      }

    if(func->called->n)
      {
       fprintf(of,"Called by:");

       for(i=0;i<func->called->n;i++)
         {
          fprintf(of,"\\ & %s() & %s & \\cxreffunc{%s}{%s}\\\\\n",latex(func->called->s1[i],0),latex(func->called->s2[i],0),func->called->s1[i],func->called->s2[i]);
          if(++tabcount%8 == 4)
             fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
         }
      }

    if(func->used->n)
      {
       fprintf(of,"Used in:");

       for(i=0;i<func->used->n;i++)
         {
          if(func->used->s1[i][0]=='$' && !func->used->s1[i][1])
             fprintf(of,"\\ & %s & \\ & \\cxreffile{%s}\\\\\n",latex(func->used->s2[i],0),func->used->s2[i]);
          else
             fprintf(of,"\\ & %s() & %s & \\cxreffunc{%s}{%s}\\\\\n",latex(func->used->s1[i],0),latex(func->used->s2[i],0),func->used->s1[i],func->used->s2[i]);
          if(++tabcount%8 == 4)
             fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
         }
      }

    if(func->f_refs->n)
      {
       int others=0;

       fprintf(of,"Refs Func:");

       for(i=0;i<func->f_refs->n;i++)
          if(func->f_refs->s2[i])
            {
             fprintf(of,"\\ & %s() & %s & \\cxreffunc{%s}{%s}\\\\\n",latex(func->f_refs->s1[i],0),latex(func->f_refs->s2[i],0),func->f_refs->s1[i],func->f_refs->s2[i]);
             if(++tabcount%8 == 4)
                fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
            }
          else
             others++;

       if(others)
         {
          fprintf(of,"\\ & \\cxreftabiiispan{");
          for(i=0;i<func->f_refs->n;i++)
             if(!func->f_refs->s2[i])
                fprintf(of,--others?" %s(),":" %s()",latex(func->f_refs->s1[i],0));
          fprintf(of,"} &\\\\\n");
         }
      }

    if(func->v_refs->n)
      {
       int others=0;

       fprintf(of,"Refs Var:");

       for(i=0;i<func->v_refs->n;i++)
          if(func->v_refs->s2[i])
            {
             fprintf(of,"\\ & %s & %s & \\cxrefvar{%s}{%s}\\\\\n",latex(func->v_refs->s1[i],0),latex(func->v_refs->s2[i],0),func->v_refs->s1[i],func->v_refs->s2[i]);
             if(++tabcount%8 == 4)
                fprintf(of,"\\cxreftabbreak{cxreftabiii}\n");
            }
          else
             others++;

       if(others)
         {
          fprintf(of,"\\ & \\cxreftabiiispan{");
          for(i=0;i<func->v_refs->n;i++)
             if(!func->v_refs->s2[i])
                fprintf(of,--others?" %s,":" %s",latex(func->v_refs->s1[i],0));
          fprintf(of,"} &\\\\\n");
         }
      }

    fprintf(of,"\\end{cxreftabiii}\n\n");
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Write out a file that will include the current information.

  char* name The name of the file (without the LaTeX extension).

  int appendix set to non-zero if the appendix file is to be added, else a normal source file.  
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexDocument(char* name,int appendix)
{
 FILE *in,*out;
 char line[256];
 int seen=0;
 char *inc_file,*ofile,*ifile;

 inc_file=ConcatStrings(4,"\\input{",name,LATEX_FILE,"}\n");
 ifile=ConcatStrings(4,option_odir,"/",option_name,LATEX_FILE);
 ofile=ConcatStrings(4,option_odir,"/",option_name,LATEX_FILE_BACKUP);

 in =fopen(ifile,"r");
 if(!in)
   {
    WriteLatexTemplate(ifile);
    in =fopen(ifile,"r");
   }

 out=fopen(ofile,"w");

 if(!out)
   {fprintf(stderr,"cxref: Failed to open the main LaTeX output file '%s'\n",ofile);exit(1);}

 while(fgets(line,256,in))
   {
    if(!strcmp(inc_file,line) ||
       (line[0]=='%' && !strcmp(inc_file,line+1)) ||
       (line[0]=='%' && line[1]==' ' && !strcmp(inc_file,line+2)))
       {seen=1;break;}
    if(line[0]=='%' && !strcmp("% End-Of-Source-Files\n",line))
      {
       if(appendix)
         {
          fputs(line,out);
          fputs("\n",out);
          fputs("% Appendix\n",out);
          fputs("\n",out);
          fputs("\\appendix\n",out);
          fputs("\\markboth{Appendix}{Appendix}\n",out);
          fputs(inc_file,out);
         }
       else
         {
          fputs(inc_file,out);
          fputs("\n",out);
          fputs(line,out);
         }
      }
    else
       fputs(line,out);
   }

 fclose(in);
 fclose(out);

 if(!seen)
   {
    unlink(ifile);
    rename(ofile,ifile);
   }
 else
    unlink(ofile);
}


/*++++++++++++++++++++++++++++++++++++++
  Write out the standard template for the main LaTeX file.
  This sets up the page styles, and includes markers for the start and end of included source code.

  char* name The name of the file to write the template to.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteLatexTemplate(char* name)
{
 FILE *template;
 struct stat stat_buf;
 char* fname;
 
 template=fopen(name,"w");

 if(!template)
   {fprintf(stderr,"cxref: Failed to open the main LaTeX output file '%s'\n",name);exit(1);}

 fputs("% This LaTeX file generated by cxref\n",template);
 fputs("% cxref program (c) Andrew M. Bishop 1995,96,97,98,99.\n",template);
 fputs("\n",template);
 if(option_latex==1)
    fputs("\\documentstyle[fonts,page,cxref]{report}\n",template);
 else
   {
    fputs("\\documentclass{report}\n",template);
    fputs("\\usepackage{fonts,page,cxref}\n",template);
   }
 fputs("\\pagestyle{myheadings}\n",template);
 fputs("\n",template);
 fputs("\\begin{document}\n",template);
 fputs("\n",template);
 fputs("% Contents (Optional, either here or at end)\n",template);
 fputs("\n",template);
 fputs("%\\markboth{Contents}{Contents}\n",template);
 fputs("%\\tableofcontents\n",template);
 fputs("\n",template);
 fputs("\\chapter{Source Files}\n",template);
 fputs("\n",template);
 fputs("% Begin-Of-Source-Files\n",template);
 fputs("\n",template);
 fputs("% End-Of-Source-Files\n",template);
 fputs("\n",template);
 fputs("% Contents (Optional, either here or at beginning)\n",template);
 fputs("\n",template);
 fputs("\\markboth{Contents}{Contents}\n",template);
 fputs("\\tableofcontents\n",template);
 fputs("\n",template);
 fputs("\\end{document}\n",template);

 fclose(template);

 fname=ConcatStrings(2,option_odir,"/fonts.sty");
 if(stat(fname,&stat_buf))
   {
    FILE* file=fopen(fname,"w");
    if(!file)
      {fprintf(stderr,"cxref: Cannot write the LaTeX style file '%s'\n",fname);exit(1);}
    fputs(latex_fonts_style,file);
    fclose(file);
   }

 fname=ConcatStrings(2,option_odir,"/page.sty");
 if(stat(fname,&stat_buf))
   {
    FILE* file=fopen(fname,"w");
    if(!file)
      {fprintf(stderr,"cxref: Cannot write the LaTeX style file '%s'\n",fname);exit(1);}
    fputs(latex_page_style,file);
    fclose(file);
   }

 fname=ConcatStrings(2,option_odir,"/cxref.sty");
 if(stat(fname,&stat_buf))
   {
    FILE* file=fopen(fname,"w");
    if(!file)
      {fprintf(stderr,"cxref: Cannot write the LaTeX style file '%s'\n",fname);exit(1);}
    fputs(latex_cxref_style,file);
    fclose(file);
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Write out the appendix information.

  StringList files The list of files to write.

  StringList2 funcs The list of functions to write.

  StringList2 vars The list of variables to write.

  StringList2 types The list of types to write.
  ++++++++++++++++++++++++++++++++++++++*/

void WriteLatexAppendix(StringList files,StringList2 funcs,StringList2 vars,StringList2 types)
{
 char* ofile;
 int i;

 /* Write the bits to the including file. */

 WriteLatexDocument(ConcatStrings(2,option_name,LATEX_APDX),1);

 /* Open the file */

 ofile=ConcatStrings(5,option_odir,"/",option_name,LATEX_APDX,LATEX_FILE);

 of=fopen(ofile,"w");

 if(!of)
   {fprintf(stderr,"cxref: Failed to open the LaTeX appendix file '%s'\n",ofile);exit(1);}

 /* Write out a header. */

 fputs("% This LaTeX file generated by cxref\n",of);
 fputs("% cxref program (c) Andrew M. Bishop 1995,96,97,98,99.\n",of);
 fputs("\n",of);
 fprintf(of,"%% Cxref: %s\n",run_command);
 fprintf(of,"%% CPP  : %s\n",run_cpp_command);
 fputs("\n",of);

 /* Write the file structure out */

 fprintf(of,"\\chapter{Cross References}\n");

 /* Write out the appendix of files. */

 if(files->n)
   {
    fprintf(of,"\n\\section{Files}\n");
    fprintf(of,"\\label{appendix_file}\n\n");
    fprintf(of,"\\begin{cxreftabiib}\n");
    for(i=0;i<files->n;i++)
      {
       if(min(i,files->n-i)%8 == 4)
          fprintf(of,"\\cxreftabbreak{cxreftabiib}\n");
       fprintf(of,"%s & \\ & \\cxreffile{%s}\\\\\n",latex(files->s[i],0),files->s[i]);
      }
    fprintf(of,"\\end{cxreftabiib}\n\n");
   }

 /* Write out the appendix of functions. */

 if(funcs->n)
   {
    fprintf(of,"\n\\section{Global Functions}\n");
    fprintf(of,"\\label{appendix_func}\n\n");
    fprintf(of,"\\begin{cxreftabiib}\n");
    for(i=0;i<funcs->n;i++)
      {
       if(min(i,funcs->n-i)%8 == 4)
          fprintf(of,"\\cxreftabbreak{cxreftabiib}\n");
       fprintf(of,"%s & %s & \\cxreffunc{%s}{%s}\\\\\n",latex(funcs->s1[i],0),latex(funcs->s2[i],0),funcs->s1[i],funcs->s2[i]);
      }
    fprintf(of,"\\end{cxreftabiib}\n\n");
   }

 /* Write out the appendix of variables. */

 if(vars->n)
   {
    fprintf(of,"\n\\section{Global Variables}\n");
    fprintf(of,"\\label{appendix_var}\n\n");
    fprintf(of,"\\begin{cxreftabiib}\n");
    for(i=0;i<vars->n;i++)
      {
       if(min(i,vars->n-i)%8 == 4)
          fprintf(of,"\\cxreftabbreak{cxreftabiib}\n");
       fprintf(of,"%s & %s & \\cxrefvar{%s}{%s}\\\\\n",latex(vars->s1[i],0),latex(vars->s2[i],0),vars->s1[i],vars->s2[i]);
      }
    fprintf(of,"\\end{cxreftabiib}\n\n");
   }

 /* Write out the appendix of types. */

 if(types->n)
   {
    fprintf(of,"\n\\section{Defined Types}\n");
    fprintf(of,"\\label{appendix_type}\n\n");
    fprintf(of,"\\begin{cxreftabiib}\n");
    for(i=0;i<types->n;i++)
      {
       if(min(i,types->n-i)%8 == 4)
          fprintf(of,"\\cxreftabbreak{cxreftabiib}\n");
       if(!strncmp("enum",types->s1[i],4))
          fprintf(of,"%s & %s & \\cxreftype{enum_%s}{%s}\\\\\n",latex(types->s1[i],0),latex(types->s2[i],0),&types->s1[i][5],types->s2[i]);
       else
          if(!strncmp("union",types->s1[i],5))
             fprintf(of,"%s & %s & \\cxreftype{union_%s}{%s}\\\\\n",latex(types->s1[i],0),latex(types->s2[i],0),&types->s1[i][6],types->s2[i]);
          else
             if(!strncmp("struct",types->s1[i],6))
                fprintf(of,"%s & %s & \\cxreftype{struct_%s}{%s}\\\\\n",latex(types->s1[i],0),latex(types->s2[i],0),&types->s1[i][7],types->s2[i]);
             else
                fprintf(of,"%s & %s & \\cxreftype{%s}{%s}\\\\\n",latex(types->s1[i],0),latex(types->s2[i],0),types->s1[i],types->s2[i]);
      }
    fprintf(of,"\\end{cxreftabiib}\n\n");
   }

 fclose(of);

 /* Clear the memory in latex(,0) */

 latex(NULL,0); latex(NULL,0); latex(NULL,0); latex(NULL,0);
}


/*++++++++++++++++++++++++++++++++++++++
  Delete the latex file and main file reference that belong to the named file.

  char *name The name of the file to delete.
  ++++++++++++++++++++++++++++++++++++++*/

void WriteLatexFileDelete(char *name)
{
 FILE *in,*out;
 char line[256];
 int seen=0;
 char *inc_file,*ofile,*ifile;

 ofile=ConcatStrings(4,option_odir,"/",name,LATEX_FILE);
 unlink(ofile);

 inc_file=ConcatStrings(4,"\\input{",name,LATEX_FILE,"}\n");
 ifile=ConcatStrings(4,option_odir,"/",option_name,LATEX_FILE);
 ofile=ConcatStrings(4,option_odir,"/",option_name,LATEX_FILE_BACKUP);

 in =fopen(ifile,"r");
 out=fopen(ofile,"w");

 if(in && !out)
   {fprintf(stderr,"cxref: Failed to open the main LaTeX output file '%s'\n",ofile);fclose(in);}
 else if(in)
   {
    while(fgets(line,256,in))
      {
       if(!strcmp(inc_file,line) ||
          (line[0]=='%' && !strcmp(inc_file,line+1)) ||
          (line[0]=='%' && line[1]==' ' && !strcmp(inc_file,line+2)))
          seen=1;
       else
          fputs(line,out);
      }

    fclose(in);
    fclose(out);

    if(seen)
      {
       unlink(ifile);
       rename(ofile,ifile);
      }
    else
       unlink(ofile);
   }
 else if(out)
   {
    fclose(out);
    unlink(ofile);
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Make the input string safe to output as LaTeX ( not #, $, %, &, \, ^, _, {, }, <, > or ~ ).

  char* latex Returns a safe LaTeX string.

  char* c A non-safe LaTeX string.

  int verbatim Set to true inside a verbatim environment.

  The function can only be called four times in each fprintf() since it returns one of only four static strings.
  ++++++++++++++++++++++++++++++++++++++*/

static char* latex(char* c,int verbatim)
{
 static char safe[4][256],*malloced[4]={NULL,NULL,NULL,NULL};
 static int which=0;
 int copy=0,skip=0;
 int i=0,j=0,delta=13,len=256-delta;
 char* ret;

 which=(which+1)%4;
 ret=safe[which];

 safe[which][0]=0;

 if(malloced[which])
   {Free(malloced[which]);malloced[which]=NULL;}

 if(c)
   {
    i=CopyOrSkip(c,"latex",&copy,&skip);

    while(1)
       {
       for(;j<len && c[i];i++)
         {
          if(copy)
            {ret[j++]=c[i]; if(c[i]=='\n') copy=0;}
          else if(skip)
            {               if(c[i]=='\n') skip=0;}
          else if(verbatim)
             ret[j++]=c[i];
          else
             switch(c[i])
               {
               case '<':
               case '>':
                ret[j++]='$';
                ret[j++]=c[i];
                ret[j++]='$';
                break;
               case '\\':
                strcpy(&ret[j],"$\\backslash$");j+=12;
                break;
               case '~':
                strcpy(&ret[j],"$\\sim$");j+=6;
                break;
               case '^':
                strcpy(&ret[j],"$\\wedge$");j+=8;
                break;
               case '#':
               case '$':
               case '%':
               case '&':
               case '_':
               case '{':
               case '}':
                ret[j++]='\\';
                ret[j++]=c[i];
                break;
               default:
                ret[j++]=c[i];
               }
          if(c[i]=='\n')
             i+=CopyOrSkip(c+i,"latex",&copy,&skip);
         }

       if(c[i])                 /* Not finished */
         {
          if(malloced[which])
             malloced[which]=Realloc(malloced[which],len+delta+256);
          else
            {malloced[which]=Malloc(len+delta+256); strncpy(malloced[which],ret,(unsigned)j);}
          ret=malloced[which];
          len+=256;
         }
       else
         {ret[j]=0; break;}
      }
   }

 return(ret);
}
