# idl2matlab
an IDL to Matlab/Scilab translator

version 1.5 (21 jan 2009)

(c) Institut Laue-Langevin, Grenoble, France.
--------------------------------------------------------------------------------
This is IDL2Matlab / IDL2Scilab translator
Initial Release 0.0 (28 jan 2003) dev (alpha)
        Release 1.0 (31 jul 2003) dev (alpha)
        Release 1.1 (17 Nov 2003) dev (alpha)
        Release 1.2 (11 Mar 2004) dev (alpha)
        Release 1.3 (20 Mar 2006) dev (alpha)
        Release 1.4 (13 Jun 2007) beta
        Release 1.5 (21 jan 2009) final

This project was designed by the Institut Laue-Langevin <http://www.ill.fr>.
This version may be redistributed as long as you also give this README file.

/*******************************************************************************
*
* IDL2Matlab and Scilab translator
*   Computing for Science group
*   Institut Laue langevin, BP 156
*   F-38042 Grenoble cedex 9, FRANCE
*
* Documentation: README
*
* %Identification
* Written by: EF, DR
* Date: 2003-2009
* Origin: ILL
*******************************************************************************/

This project was designed by the Institut Laue-Langevin <http://www.ill.fr>.
This version may be redistributed as long as you give the source code and
also include this README file. 
See the COPYING file for the terms of the GPL2 license.

IDL2Matlab comes with ABSOLUTELY NO WARRANTY
  Commercial use is STRICTLY forbidden.
  You are allowed to redistribute this software but should then contact us,
  distribute its source code and cite all the authors.

SCOPE:
------

  This is IDL2Matlab / IDL2Scilab translator, version 1.5 (21 January 2009).

  This tool translates automatically an IDL code into Matlab or Scilab code.

  Contact: richard@ill.fr or farhi@ill.fr for more informations

  Restrictions:
    Graphic functions (plot, surf, widgets) are incomplete.
    Translated code is not guaranteed to work.
    Objects are not translated.

	Usage : idl2matlab [-options] inputFile [outputDirectory]

	Options :
		-s for script files translation
		-S for string translation
		-q to hide messages
		-w to stop warnings writing
		-t to print the abstract tree
		-V to get idl2Matlab version
		-Tx to get x spaces for a tabulation x<10
		-f to translate only one function
		-C to translate in Scilab (default : Matlab)

	Examples :
		idl2matlab -qw essai.pro outDir/
		idl2matlab -t essai.pro outDir/ > out
		idl2matlab -S "print,'IDL2Matlab'"
		idl2matlab -T4 essai.pro outDir/ > out
		idl2matlab -f essai.pro functionName outDir/ > out
		
	See the idl2matlab man page or HTML page in the IDL2MATLAB/doc library.

LINUX INSTALLATION: 
-------------------
Requirements: Linux system, C compiler (and optionally bison, flex)

	1- If you have super user permissions

		# unzip idl2matlab-X.Y.zip
		# cd idl2matlab-X.Y
		# ./configure
		# make
		# make install

	This will install the library in /usr/local/lib/idl2matlab, 
	and binary 'idl2matlab' in /usr/local/bin/

	2- If you are NOT superuser (using $HOME=~):
		$ unzip idl2matlab-X.Y.zip
		$ cd idl2matlab-X.Y
		$ ./configure --prefix=$HOME
		$ make
		$ make install
	 then
		$tcsh: setenv IDL2MATLAB ~/lib/idl2matlab/
	 or
		$bash: export IDL2MATLAB=~/lib/idl2matlab/
	 to define the user based library location. This command should be set each time
	 you wish to use idl2matlab. It may be added to your environment scripts.
	 Executable is then located in ~/bin

WINDOWS INSTALLATION:
---------------------
Requirements: Windows system, C compiler, administrator permissions.

	1- install a C compiler, such as the free Dev-Cpp <http://www.bloodshed.net/dev/devcpp.html>
	2- extract the idl2matlab-X.Y.zip
	3- open the idl2matlab-X.Y folder
	4- double click on the install.bat script in the package source.

	This will install the library in C:\IDL2MATLAB, 
	and binary 'idl2matlab' in C:\IDL2MATLAB\BIN

MATLAB USAGE:
--------------------
Requirements: Matlab, idl2matlab executable and library installed

We provide an 'idl2matlab.m' function for Matlab, which calls the executable. 
It is then required to have idl2matlab properly installed (see previous sections).

>> idl2matlab('file.pro');

will convert the file from IDL to Matlab code and load the IDL compatibility library.


USAGE as a command (does not require IDL nor Matlab):
------------------

You may use idl2matlab with

# idl2matlab examples/test.pro

will generate the test.m Matlab function.

In order to load the IDL compatibility library
within Matlab, type at the prompt (from distribution directory):

>>  p=pwd;
>>  cd /usr/local/lib/idl2matlab/ % (or your local '~/lib/idl2matlab')
>>  i2m_init;
>>  cd(p);

Within Scilab, type at the prompt (from distribution directory):

>  chdir('/usr/local/lib/idl2matlab') # (or your local '~/lib/idl2matlab')
>  exec('i2s_init',-1);

These may be automatically executed when starting Matlab/Scilab. Refer to startup scripts
for these languages.


The step-by-step procedure for compilation is something like:
  bison -v -d idl2matlab.y --output-file=idl2matlab.c
  flex -i idl2matlab.l
  gcc -c -g -O2 idl2matlab.c
  gcc -c -g -O2 main.c
  gcc -c -g -O2 tree.c
  gcc -c -g -O2 code.c
  gcc -c -g -O2 rename.c
  gcc -c -g -O2 lib.c
  gcc -c -g -O2 hashtable.c
  gcc -c -g -O2 table_symb.c
  gcc -c -g -O2 lex.yy.c
  gcc -g -O2 main.o idl2matlab.o tree.o hashtable.o table_symb.o rename.o lex.yy.o lib.o code.o -o idl2matlab

--------------------------------------------------------------------------------
Please visit the URL <http://sourceforge.net/projects/idl2matlab>
