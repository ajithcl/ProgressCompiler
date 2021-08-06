 
/*------------------------------------------------------------------------
   File        : ajstoredata
   Purpose     : Class implementation for storing the compiled data in temp-table.
   Syntax      : 
   Description : 
   Author(s)   : achandranlalit
   Created     : Tue Apr 17 11:19:04 CEST 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

CLASS ajstoredata: 
  DEFINE PROPERTY RecordCount AS INTEGER 
    GET.
    PRIVATE SET.
  
  DEFINE PRIVATE STATIC TEMP-TABLE ttComments
    FIELD Comments AS CHARACTER 
    FIELD ttNum    AS INTEGER
    INDEX idx ttNum.
      
  METHOD PUBLIC VOID storeData
    (INPUT cComments AS CHARACTER):
    RecordCount = RecordCount + 1.
    CREATE ttComments.
    ASSIGN 
      ttComments.ttNum    = RecordCount
      ttComments.Comments = cComments.
  END METHOD.
  
  METHOD PUBLIC STATIC HANDLE getTempTableHandle():
    RETURN TEMP-TABLE ttComments:HANDLE.
  END METHOD.
  
  METHOD PUBLIC VOID InitData():
    RecordCount = 0.
    EMPTY TEMP-TABLE ttComments.
  END METHOD.
  
  DESTRUCTOR PUBLIC  ajstoredata():
    InitData().
  END DESTRUCTOR.

END CLASS.