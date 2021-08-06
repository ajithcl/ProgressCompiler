/*------------------------------------------------------------------------
   File        : ajCompile
   Purpose     : 
   Syntax      : 
   Description : Custom program for compiling  and executing XREFs,DEBUG-LIST etc.
   Author(s)   : achandranlalit
   Created     : Fri Apr 13 09:10:43 CEST 2018
   Notes       : 
 ----------------------------------------------------------------------*/
USING Progress.Windows.Form.
  

CLASS ajCompile INHERITS Form   : 

  DEFINE PRIVATE VARIABLE btnDir               AS System.Windows.Forms.Button              NO-UNDO.
  DEFINE PRIVATE VARIABLE btnLocalCopy         AS System.Windows.Forms.Button              NO-UNDO.
  DEFINE PRIVATE VARIABLE btnWholeIndex        AS System.Windows.Forms.Button              NO-UNDO.
  DEFINE PRIVATE VARIABLE button1              AS System.Windows.Forms.Button              NO-UNDO.
  DEFINE PRIVATE VARIABLE buttonCompile        AS System.Windows.Forms.Button              NO-UNDO.
  DEFINE PRIVATE VARIABLE cbRCode              AS System.Windows.Forms.CheckBox            NO-UNDO.
  DEFINE PRIVATE VARIABLE cbXref               AS System.Windows.Forms.CheckBox            NO-UNDO.
  DEFINE PRIVATE VARIABLE cbListing            AS System.Windows.Forms.CheckBox            NO-UNDO.
  DEFINE PRIVATE VARIABLE cbDebugList          AS System.Windows.Forms.CheckBox            NO-UNDO.
  DEFINE PRIVATE VARIABLE components           AS System.ComponentModel.IContainer         NO-UNDO.
  DEFINE PRIVATE VARIABLE errorProvider1       AS System.Windows.Forms.ErrorProvider       NO-UNDO.
  DEFINE PRIVATE VARIABLE folderBrowserDialog1 AS System.Windows.Forms.FolderBrowserDialog NO-UNDO.
  DEFINE PRIVATE VARIABLE label2               AS System.Windows.Forms.Label               NO-UNDO.
  DEFINE PRIVATE VARIABLE label3 AS System.Windows.Forms.Label NO-UNDO.
  DEFINE PRIVATE VARIABLE lblDbCount AS System.Windows.Forms.Label NO-UNDO.
  DEFINE PRIVATE VARIABLE textBox1             AS System.Windows.Forms.TextBox             NO-UNDO.
  DEFINE PRIVATE VARIABLE label1               AS System.Windows.Forms.Label               NO-UNDO.
  DEFINE PRIVATE VARIABLE textBox2             AS System.Windows.Forms.TextBox             NO-UNDO.
  
  DEFINE PRIVATE VARIABLE cProgName            AS CHARACTER                                NO-UNDO.
  DEFINE PRIVATE VARIABLE lXref                AS LOGICAL                                  NO-UNDO.
  DEFINE PRIVATE VARIABLE lDebugList           AS LOGICAL                                  NO-UNDO.
  DEFINE PRIVATE VARIABLE lListing             AS LOGICAL                                  NO-UNDO.
  DEFINE PRIVATE VARIABLE lRCode               AS LOGICAL                                  NO-UNDO.
  DEFINE PRIVATE VARIABLE cDir                 AS CHARACTER                                NO-UNDO.
  DEFINE PRIVATE VARIABLE cString              AS CHARACTER                                NO-UNDO. 
  
  DEFINE         VARIABLE objStoredata         AS ajstoredata                              NO-UNDO.
  DEFINE         VARIABLE objViewGrid          AS viewgrid                                 NO-UNDO.
  
  DEFINE STREAM stream1.
    
  CONSTRUCTOR PUBLIC ajCompile( ):
	
    SUPER().
    /*hardcoded output directory*/
    cDir = "C:\Ajith\output\".
    objStoredata = NEW ajstoredata().
    InitializeComponent ( ).
    lblDbCount:Text = STRING(NUM-DBS).
    IF NUM-DBS = 0 THEN lblDbCount:BackColor = System.Drawing.Color:Red.
    ELSE lblDbCount:backColor = System.Drawing.Color:Green.
    
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.		

  END CONSTRUCTOR.

  DESTRUCTOR PUBLIC ajCompile( ):
    
    IF VALID-OBJECT (objStoredata) THEN 
      DELETE OBJECT objStoredata.

    IF VALID-OBJECT(components) THEN 
    DO:
      CAST(components, System.IDisposable):Dispose().
    END.

  END DESTRUCTOR.	

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID ajCompile_Load( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
    RETURN.

  END METHOD.

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID btnDir_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    OS-COMMAND NO-WAIT VALUE ("start " + cDir).
    RETURN.

  END METHOD.

  /*------------------------------------------------------------------------------
      Purpose: Copy the files from source directory to local directory. 																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID btnLocalCopy_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    IF textbox2:TEXT > "":U THEN 
    DO:
      /*TODO : Enter the target directory for pasting the programs*/  
      OS-COPY VALUE (textbox2:TEXT) 'c:/'.
      IF OS-ERROR <> 0 THEN MESSAGE "Error number: " OS-ERROR VIEW-AS ALERT-BOX ERROR TITLE "Error".
      ELSE MESSAGE "File copied." VIEW-AS ALERT-BOX TITLE "Success".
    END.
    RETURN.

  END METHOD.

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID button1_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    DEFINE VARIABLE cDir           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iSlashPosition AS INTEGER   NO-UNDO.
    
    IF cString > "":U THEN 
    DO: 
      iSlashPosition = R-INDEX (cString , "\":U).
      IF iSlashPosition = 0 THEN 
        iSlashPosition = R-INDEX (cString, "/":U).
      IF iSlashPosition > 0 THEN 
      DO:
        cDir = SUBSTRING (cString, 1, iSlashPosition - 1).
        OS-COMMAND VALUE ("start " + cDir) NO-WAIT NO-CONSOLE.
      END.
    END. 
    RETURN.

  END METHOD.

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID cbXref_CheckedChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
		RETURN.

	END METHOD.

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID doIndexScan( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    DEFINE VARIABLE cFile       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLineData   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFilterData AS CHARACTER NO-UNDO.
            
    cFile = cDir + cProgName + "xrf".
    IF SEARCH (cFile) = ? THEN 
    DO:
      System.Windows.Forms.MessageBox:Show
        ("Unable to find XREF file",
        "Error",
        System.Windows.Forms.MessageBoxButtons:OK,
        System.Windows.Forms.MessageBoxIcon:Error).
      RETURN.
    END.
    ELSE 
    DO :
      objStoredata:InitData().
      INPUT STREAM stream1 FROM VALUE (cFile).
      REPEAT:
        IMPORT STREAM stream1 UNFORMATTED 
          cLineData.
        IF LOOKUP ("SEARCH":U, cLineData, " ":U) >0 THEN 
        DO:
          objStoredata:storeData (cLineData).
        END. 
      END.
      INPUT STREAM stream1 CLOSE.
      objViewGrid = NEW viewgrid().
      objViewGrid:ShowModalDialog().
      DELETE OBJECT objViewGrid.
    END.
    RETURN.

  END METHOD.

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID LeaveProgram( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    cProgName = textBox1:TEXT.
    cString = SEARCH (cProgName).
    IF cString = ? THEN 
    DO:
      errorProvider1:SetError(textBox1,"Invalid Program,").
      textBox2:TEXT = "".
      THIS-OBJECT:textBox1:Focus().
    END.
    ELSE 
    DO:
      errorProvider1:Clear().
      textBox2:TEXT = cString.
    END.
  END METHOD.

  METHOD PRIVATE VOID okButton_Click (sender AS System.Object, e AS System.EventArgs):
    ASSIGN 
      lDebugList = cbDebugList:CHECKED
      lListing   = cbListing:CHECKED
      lXref      = cbXref:CHECKED
      lRCode     = cbRCode:CHECKED.
    LeaveProgram(?,?).
    IF errorProvider1:GetError(textBox1) = "" THEN 
    DO:
      SESSION:SET-WAIT-STATE ("busy").
      doCompile().
      SESSION:SET-WAIT-STATE ("").
      btnWholeIndex:ENABLED = TRUE.
    END.
  /*    THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Ok.*/
  /*    THIS-OBJECT:Close ( ).*/
  END METHOD.

  METHOD PRIVATE VOID cancelButton_Click (sender AS System.Object, e AS System.EventArgs):
    THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    THIS-OBJECT:Close ( ).
  END METHOD.
  
  METHOD PRIVATE VOID doCompile(): 
    IF lDebugList AND lXref AND lListing AND lRCode THEN 
      COMPILE VALUE (cProgName) 
        DEBUG-LIST VALUE (cDir + cProgName + "dbg")
        XREF       VALUE (cDir + cProgName + "xrf")
        LISTING    VALUE (cDir + cProgName + "lst")
        SAVE INTO VALUE (cDir)
        .
    ELSE IF lDebugList AND lXref AND lListing THEN 
        COMPILE VALUE (cProgName) 
          DEBUG-LIST VALUE (cDir + cProgName + "dbg")
          XREF       VALUE (cDir + cProgName + "xrf")
          LISTING    VALUE (cDir + cProgName + "lst")
          .
      ELSE IF lDebugList AND lListing THEN 
          COMPILE VALUE (cProgName) 
            DEBUG-LIST VALUE (cDir + cProgName + "dbg")
            LISTING    VALUE (cDir + cProgName + "lst")
            .
        ELSE IF lDebugList AND lXref THEN 
            COMPILE VALUE (cProgName) 
              DEBUG-LIST VALUE (cDir + cProgName + "dbg")
              XREF       VALUE (cDir + cProgName + "xrf")
              . 
          ELSE IF lDebugList THEN COMPILE VALUE (cProgName) DEBUG-LIST VALUE (cDir + cProgName + "dbg") .
            ELSE IF lXref THEN COMPILE VALUE (cProgName) XREF VALUE (cDir + cProgName + "xrf") .
              ELSE IF lListing THEN COMPILE VALUE (cProgName) LISTING VALUE (cDir + cProgName + "lst") .
                ELSE IF lRCode THEN COMPILE VALUE (cProgName) SAVE INTO VALUE (cDir) .
                  ELSE COMPILE VALUE (cProgName).
  END METHOD.
    
  METHOD PRIVATE VOID InitializeComponent ( ):

    /* NOTE: The following method is automatically generated.
		   
       We strongly suggest that the contents of this method only be modified using the 
       Visual Designer to avoid any incompatible modifications.
		   
       Modifying the contents of this method using a code editor will invalidate any support for this file. */
		
        THIS-OBJECT:components = NEW System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        DEFINE VARIABLE resources AS Progress.Util.ResourceManager NO-UNDO.
        resources = NEW Progress.Util.ResourceManager("ajCompile").
        THIS-OBJECT:buttonCompile = NEW System.Windows.Forms.Button().
        THIS-OBJECT:label1 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:textBox1 = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:cbDebugList = NEW System.Windows.Forms.CheckBox().
        THIS-OBJECT:cbXref = NEW System.Windows.Forms.CheckBox().
        THIS-OBJECT:cbListing = NEW System.Windows.Forms.CheckBox().
        THIS-OBJECT:btnDir = NEW System.Windows.Forms.Button().
        THIS-OBJECT:label2 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:textBox2 = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:errorProvider1 = NEW System.Windows.Forms.ErrorProvider(THIS-OBJECT:components).
        THIS-OBJECT:folderBrowserDialog1 = NEW System.Windows.Forms.FolderBrowserDialog().
        THIS-OBJECT:cbRCode = NEW System.Windows.Forms.CheckBox().
        THIS-OBJECT:btnWholeIndex = NEW System.Windows.Forms.Button().
        THIS-OBJECT:button1 = NEW System.Windows.Forms.Button().
        THIS-OBJECT:btnLocalCopy = NEW System.Windows.Forms.Button().
        THIS-OBJECT:label3 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:lblDbCount = NEW System.Windows.Forms.Label().
        CAST(THIS-OBJECT:errorProvider1, System.ComponentModel.ISupportInitialize):BeginInit().
        THIS-OBJECT:SuspendLayout().
        /*  */
        /* buttonCompile */
        /*  */
        DEFINE VARIABLE nestedvar0 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar0 = CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Bottom, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:buttonCompile:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:buttonCompile:AutoSize = TRUE.
        THIS-OBJECT:buttonCompile:BackColor = System.Drawing.Color:LimeGreen.
        THIS-OBJECT:buttonCompile:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:buttonCompile:Location = NEW System.Drawing.Point(245, 170).
        THIS-OBJECT:buttonCompile:Name = "buttonCompile".
        THIS-OBJECT:buttonCompile:Size = NEW System.Drawing.Size(104, 29).
        THIS-OBJECT:buttonCompile:TabIndex = 0.
        THIS-OBJECT:buttonCompile:Text = "Compile".
        THIS-OBJECT:buttonCompile:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:buttonCompile:UseVisualStyleBackColor = FALSE.
        THIS-OBJECT:buttonCompile:Click:Subscribe(THIS-OBJECT:okButton_Click).
        /*  */
        /* label1 */
        /*  */
        THIS-OBJECT:label1:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:label1:Location = NEW System.Drawing.Point(12, 9).
        THIS-OBJECT:label1:Name = "label1".
        THIS-OBJECT:label1:Size = NEW System.Drawing.Size(100, 23).
        THIS-OBJECT:label1:TabIndex = 2.
        THIS-OBJECT:label1:Text = "Program name : ".
        THIS-OBJECT:label1:UseCompatibleTextRendering = TRUE.
        /*  */
        /* textBox1 */
        /*  */
        THIS-OBJECT:textBox1:Font = NEW System.Drawing.Font("Courier New", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:textBox1:ForeColor = System.Drawing.SystemColors:ActiveCaption.
        THIS-OBJECT:textBox1:Location = NEW System.Drawing.Point(118, 6).
        THIS-OBJECT:textBox1:Name = "textBox1".
        THIS-OBJECT:textBox1:Size = NEW System.Drawing.Size(308, 30).
        THIS-OBJECT:textBox1:TabIndex = 3.
        THIS-OBJECT:textBox1:Leave:Subscribe(THIS-OBJECT:LeaveProgram).
        /*  */
        /* cbDebugList */
        /*  */
        THIS-OBJECT:cbDebugList:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:cbDebugList:Location = NEW System.Drawing.Point(12, 79).
        THIS-OBJECT:cbDebugList:Name = "cbDebugList".
        THIS-OBJECT:cbDebugList:Size = NEW System.Drawing.Size(104, 24).
        THIS-OBJECT:cbDebugList:TabIndex = 4.
        THIS-OBJECT:cbDebugList:Text = "Debug-List".
        THIS-OBJECT:cbDebugList:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:cbDebugList:UseVisualStyleBackColor = TRUE.
        /*  */
        /* cbXref */
        /*  */
        THIS-OBJECT:cbXref:Location = NEW System.Drawing.Point(119, 79).
        THIS-OBJECT:cbXref:Name = "cbXref".
        THIS-OBJECT:cbXref:Size = NEW System.Drawing.Size(104, 24).
        THIS-OBJECT:cbXref:TabIndex = 5.
        THIS-OBJECT:cbXref:Text = "XREF".
        THIS-OBJECT:cbXref:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:cbXref:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:cbXref:CheckedChanged:Subscribe(THIS-OBJECT:cbXref_CheckedChanged).
        /*  */
        /* cbListing */
        /*  */
        THIS-OBJECT:cbListing:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:cbListing:Location = NEW System.Drawing.Point(230, 79).
        THIS-OBJECT:cbListing:Name = "cbListing".
        THIS-OBJECT:cbListing:Size = NEW System.Drawing.Size(81, 24).
        THIS-OBJECT:cbListing:TabIndex = 6.
        THIS-OBJECT:cbListing:Text = "Listing".
        THIS-OBJECT:cbListing:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:cbListing:UseVisualStyleBackColor = TRUE.
        /*  */
        /* btnDir */
        /*  */
        DEFINE VARIABLE nestedvar1 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar1 = CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Bottom, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:btnDir:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:btnDir:AutoSize = TRUE.
        THIS-OBJECT:btnDir:BackColor = System.Drawing.Color:LightBlue.
        THIS-OBJECT:btnDir:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:btnDir:Location = NEW System.Drawing.Point(355, 170).
        THIS-OBJECT:btnDir:Name = "btnDir".
        THIS-OBJECT:btnDir:Size = NEW System.Drawing.Size(86, 29).
        THIS-OBJECT:btnDir:TabIndex = 7.
        THIS-OBJECT:btnDir:Text = "Output".
        THIS-OBJECT:btnDir:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnDir:UseVisualStyleBackColor = FALSE.
        THIS-OBJECT:btnDir:Click:Subscribe(THIS-OBJECT:btnDir_Click).
        /*  */
        /* label2 */
        /*  */
        THIS-OBJECT:label2:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:label2:Location = NEW System.Drawing.Point(12, 37).
        THIS-OBJECT:label2:Name = "label2".
        THIS-OBJECT:label2:Size = NEW System.Drawing.Size(100, 39).
        THIS-OBJECT:label2:TabIndex = 8.
        THIS-OBJECT:label2:Text = "Propath File : ".
        THIS-OBJECT:label2:UseCompatibleTextRendering = TRUE.
        /*  */
        /* textBox2 */
        /*  */
        THIS-OBJECT:textBox2:BackColor = System.Drawing.SystemColors:ControlLight.
        THIS-OBJECT:textBox2:BorderStyle = System.Windows.Forms.BorderStyle:None.
        THIS-OBJECT:textBox2:Location = NEW System.Drawing.Point(118, 39).
        THIS-OBJECT:textBox2:Name = "textBox2".
        THIS-OBJECT:textBox2:ReadOnly = TRUE.
        THIS-OBJECT:textBox2:Size = NEW System.Drawing.Size(308, 15).
        THIS-OBJECT:textBox2:TabIndex = 9.
        THIS-OBJECT:textBox2:TextChanged:Subscribe(THIS-OBJECT:textBox2_TextChanged).
        /*  */
        /* errorProvider1 */
        /*  */
        THIS-OBJECT:errorProvider1:ContainerControl = THIS-OBJECT.
        /*  */
        /* folderBrowserDialog1 */
        /*  */
        THIS-OBJECT:folderBrowserDialog1:Description = "Output folder".
        THIS-OBJECT:folderBrowserDialog1:SelectedPath = "C:\Users\achandranlalit\Ajith\output".
        THIS-OBJECT:folderBrowserDialog1:ShowNewFolderButton = FALSE.
        /*  */
        /* cbRCode */
        /*  */
        THIS-OBJECT:cbRCode:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:cbRCode:Location = NEW System.Drawing.Point(319, 79).
        THIS-OBJECT:cbRCode:Name = "cbRCode".
        THIS-OBJECT:cbRCode:Size = NEW System.Drawing.Size(90, 24).
        THIS-OBJECT:cbRCode:TabIndex = 10.
        THIS-OBJECT:cbRCode:Text = "R-Code".
        THIS-OBJECT:cbRCode:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:cbRCode:UseVisualStyleBackColor = TRUE.
        /*  */
        /* btnWholeIndex */
        /*  */
        DEFINE VARIABLE nestedvar2 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar2 = CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Bottom, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:btnWholeIndex:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:btnWholeIndex:AutoSize = TRUE.
        THIS-OBJECT:btnWholeIndex:BackColor = System.Drawing.Color:LightBlue.
        THIS-OBJECT:btnWholeIndex:Enabled = FALSE.
        THIS-OBJECT:btnWholeIndex:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:btnWholeIndex:Location = NEW System.Drawing.Point(447, 170).
        THIS-OBJECT:btnWholeIndex:Name = "btnWholeIndex".
        THIS-OBJECT:btnWholeIndex:Size = NEW System.Drawing.Size(118, 29).
        THIS-OBJECT:btnWholeIndex:TabIndex = 11.
        THIS-OBJECT:btnWholeIndex:Text = "INDEX-SCAN".
        THIS-OBJECT:btnWholeIndex:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnWholeIndex:UseVisualStyleBackColor = FALSE.
        THIS-OBJECT:btnWholeIndex:Click:Subscribe(THIS-OBJECT:doIndexScan).
        /*  */
        /* button1 */
        /*  */
        DEFINE VARIABLE nestedvar3 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar3 = CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Bottom, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:button1:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar3, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:button1:AutoSize = TRUE.
        THIS-OBJECT:button1:BackColor = System.Drawing.SystemColors:GradientActiveCaption.
        THIS-OBJECT:button1:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:button1:Location = NEW System.Drawing.Point(12, 170).
        THIS-OBJECT:button1:Name = "button1".
        THIS-OBJECT:button1:Size = NEW System.Drawing.Size(104, 29).
        THIS-OBJECT:button1:TabIndex = 12.
        THIS-OBJECT:button1:Text = "SourceDir".
        THIS-OBJECT:button1:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:button1:UseVisualStyleBackColor = FALSE.
        THIS-OBJECT:button1:Click:Subscribe(THIS-OBJECT:button1_Click).
        /*  */
        /* btnLocalCopy */
        /*  */
        DEFINE VARIABLE nestedvar4 AS System.Windows.Forms.AnchorStyles NO-UNDO.
        nestedvar4 = CAST(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Bottom, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:btnLocalCopy:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar4, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        THIS-OBJECT:btnLocalCopy:AutoSize = TRUE.
        THIS-OBJECT:btnLocalCopy:BackColor = System.Drawing.SystemColors:GradientActiveCaption.
        THIS-OBJECT:btnLocalCopy:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:btnLocalCopy:Location = NEW System.Drawing.Point(122, 170).
        THIS-OBJECT:btnLocalCopy:Name = "btnLocalCopy".
        THIS-OBJECT:btnLocalCopy:Size = NEW System.Drawing.Size(117, 29).
        THIS-OBJECT:btnLocalCopy:TabIndex = 13.
        THIS-OBJECT:btnLocalCopy:Text = "Local Copy".
        THIS-OBJECT:btnLocalCopy:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:btnLocalCopy:UseVisualStyleBackColor = FALSE.
        THIS-OBJECT:btnLocalCopy:Click:Subscribe(THIS-OBJECT:btnLocalCopy_Click).
        /*  */
        /* label3 */
        /*  */
        THIS-OBJECT:label3:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:label3:Location = NEW System.Drawing.Point(12, 111).
        THIS-OBJECT:label3:Name = "label3".
        THIS-OBJECT:label3:Size = NEW System.Drawing.Size(118, 39).
        THIS-OBJECT:label3:TabIndex = 14.
        THIS-OBJECT:label3:Text = "Connected DBs : ".
        THIS-OBJECT:label3:UseCompatibleTextRendering = TRUE.
        /*  */
        /* lblDbCount */
        /*  */
        THIS-OBJECT:lblDbCount:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:lblDbCount:Location = NEW System.Drawing.Point(119, 127).
        THIS-OBJECT:lblDbCount:Name = "lblDbCount".
        THIS-OBJECT:lblDbCount:Size = NEW System.Drawing.Size(45, 23).
        THIS-OBJECT:lblDbCount:TabIndex = 15.
        THIS-OBJECT:lblDbCount:UseCompatibleTextRendering = TRUE.
        /*  */
        /* ajCompile */
        /*  */
        THIS-OBJECT:AcceptButton = THIS-OBJECT:buttonCompile.
        THIS-OBJECT:AutoSize = TRUE.
        THIS-OBJECT:AutoSizeMode = System.Windows.Forms.AutoSizeMode:GrowAndShrink.
        THIS-OBJECT:BackColor = System.Drawing.SystemColors:ControlLight.
        THIS-OBJECT:ClientSize = NEW System.Drawing.Size(572, 211).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:lblDbCount).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label3).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:btnLocalCopy).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:button1).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:btnWholeIndex).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:cbRCode).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:textBox2).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label2).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:btnDir).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:cbListing).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:cbXref).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:cbDebugList).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:textBox1).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label1).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonCompile).
        THIS-OBJECT:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
        THIS-OBJECT:Icon = CAST(resources:GetObject("$this.Icon"), System.Drawing.Icon).
        THIS-OBJECT:MaximizeBox = FALSE.
        THIS-OBJECT:Name = "ajCompile".
        THIS-OBJECT:StartPosition = System.Windows.Forms.FormStartPosition:CenterScreen.
        THIS-OBJECT:Text = "Program Source Manager".
        THIS-OBJECT:Load:Subscribe(THIS-OBJECT:ajCompile_Load).
        CAST(THIS-OBJECT:errorProvider1, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:ResumeLayout(FALSE).
        THIS-OBJECT:PerformLayout().
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
  END METHOD. 
 
  METHOD PUBLIC VOID ShowModalDialog(  ):
		
    WAIT-FOR THIS-OBJECT:ShowDialog() .

  END METHOD.

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  METHOD PRIVATE VOID textBox2_TextChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
    RETURN.

  END METHOD.
 
END CLASS.
