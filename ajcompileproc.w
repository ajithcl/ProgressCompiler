
/*------------------------------------------------------------------------
    File        : ajcompile.p
    Purpose     : wrapper program for invoking ajcompile.cls

    Syntax      :

    Description : 

    Author(s)   : achandranlalit
    Created     : Fri Apr 13 11:49:04 CEST 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE VARIABLE cmplForm AS ajCompile NO-UNDO.



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/*
 * Set the custom propath here, from where programs needs to search
propath = "C:/SetupForPropath/,D:\DEVELOPMENT\," + propath.
*/

cmplForm = NEW ajCompile().
cmplForm:ProWinHandle:parent = CURRENT-WINDOW.
cmplForm:Show().
WAIT-FOR System.Windows.Forms.Application:Run(cmplForm).
DELETE OBJECT cmplForm.
IF program-name(2) = ? THEN QUIT. /*this will clear the default progress editor window and release the prowin32 process*/

