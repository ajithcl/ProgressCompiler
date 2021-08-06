/*------------------------------------------------------------------------
   File        : viewgrid
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : achandranlalit
   Created     : Mon Apr 16 09:42:43 CEST 2018
   Notes       : 
 ----------------------------------------------------------------------*/
USING Progress.Windows.Form.
USING System.Windows.Forms.*.
  

CLASS viewgrid INHERITS Form : 

  DEFINE PRIVATE VARIABLE bindingSource1                    AS Progress.Data.BindingSource                    NO-UNDO.
  DEFINE PRIVATE VARIABLE commentsDataGridViewTextBoxColumn AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
  DEFINE PRIVATE VARIABLE components                        AS System.ComponentModel.IContainer               NO-UNDO.
  DEFINE PRIVATE VARIABLE dataGridView1                     AS System.Windows.Forms.DataGridView              NO-UNDO.
  DEFINE PRIVATE VARIABLE ttNum                             AS System.Windows.Forms.DataGridViewTextBoxColumn NO-UNDO.
  DEFINE         VARIABLE ttHdl                             AS HANDLE                                         NO-UNDO.
  DEFINE         VARIABLE bh                                AS HANDLE                                         NO-UNDO.
  DEFINE         VARIABLE qh                                AS HANDLE                                         NO-UNDO.
  
  DEFINE TEMP-TABLE ttComments
    FIELD Comments AS CHARACTER  
    FIELD ttNum    AS INTEGER
    INDEX idx ttNum.
    
  CONSTRUCTOR PUBLIC viewgrid( ):
	
    SUPER().
    InitializeComponent ( ).
    loadData().
    
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.		

  END CONSTRUCTOR.

  DESTRUCTOR PUBLIC viewgrid( ):
    DELETE OBJECT qh.
    DELETE OBJECT bh.
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
  METHOD PRIVATE VOID CellFormattingEvent( INPUT sender AS System.Object, INPUT e AS System.Windows.Forms.DataGridViewCellFormattingEventArgs ):
    IF INDEX (e:VALUE:ToString() , "WHOLE-INDEX") > 0 THEN
      e:CellStyle:ForeColor = System.Drawing.Color:Red.
    RETURN.

  END METHOD.


  METHOD PRIVATE VOID okButton_Click (sender AS System.Object, e AS System.EventArgs):
    THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Ok.
    THIS-OBJECT:Close ( ). 
  END METHOD.

  METHOD PRIVATE VOID cancelButton_Click (sender AS System.Object, e AS System.EventArgs):
    THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    THIS-OBJECT:Close ( ).
  END METHOD.
    
  METHOD PRIVATE VOID InitializeComponent ( ):

    /* NOTE: The following method is automatically generated.
		   
       We strongly suggest that the contents of this method only be modified using the 
       Visual Designer to avoid any incompatible modifications.
		   
       Modifying the contents of this method using a code editor will invalidate any support for this file. */
		
    THIS-OBJECT:components = NEW System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    DEFINE VARIABLE tableDesc1 AS Progress.Data.TableDesc NO-UNDO.
    tableDesc1 = NEW Progress.Data.TableDesc("ttComments").
    THIS-OBJECT:bindingSource1 = NEW Progress.Data.BindingSource(THIS-OBJECT:components).
    THIS-OBJECT:dataGridView1 = NEW System.Windows.Forms.DataGridView().
    THIS-OBJECT:ttNum = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
    THIS-OBJECT:commentsDataGridViewTextBoxColumn = NEW System.Windows.Forms.DataGridViewTextBoxColumn().
    CAST(THIS-OBJECT:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
    CAST(THIS-OBJECT:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
    THIS-OBJECT:SuspendLayout().
    /*  */
    /* bindingSource1 */
    /*  */
    THIS-OBJECT:bindingSource1:MaxDataGuess = 0.
    THIS-OBJECT:bindingSource1:NoLOBs = FALSE.
    THIS-OBJECT:bindingSource1:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar0 AS "Progress.Data.TableDesc[]" NO-UNDO.
    arrayvar0 = NEW "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar1 AS Progress.Data.ColumnPropDesc EXTENT 2 NO-UNDO.
    arrayvar1[1] = NEW Progress.Data.ColumnPropDesc("ttNum", "No.", Progress.Data.DataType:INTEGER).
    arrayvar1[2] = NEW Progress.Data.ColumnPropDesc("Comments", "Comments", Progress.Data.DataType:CHARACTER).
    tableDesc1:Columns = arrayvar1.
    THIS-OBJECT:bindingSource1:TableSchema = tableDesc1.
    /*  */
    /* dataGridView1 */
    /*  */
    THIS-OBJECT:dataGridView1:AllowUserToAddRows = FALSE.
    THIS-OBJECT:dataGridView1:AllowUserToDeleteRows = FALSE.
    THIS-OBJECT:dataGridView1:AutoGenerateColumns = FALSE.
    THIS-OBJECT:dataGridView1:BackgroundColor = System.Drawing.SystemColors:ActiveCaptionText.
    THIS-OBJECT:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar2 AS System.Windows.Forms.DataGridViewColumn EXTENT 2 NO-UNDO.
    arrayvar2[1] = THIS-OBJECT:ttNum.
    arrayvar2[2] = THIS-OBJECT:commentsDataGridViewTextBoxColumn.
    THIS-OBJECT:dataGridView1:Columns:AddRange(arrayvar2).
    THIS-OBJECT:dataGridView1:DataSource = THIS-OBJECT:bindingSource1.
    THIS-OBJECT:dataGridView1:Dock = System.Windows.Forms.DockStyle:Fill.
    THIS-OBJECT:dataGridView1:GridColor = System.Drawing.SystemColors:ActiveCaption.
    THIS-OBJECT:dataGridView1:Location = NEW System.Drawing.Point(0, 0).
    THIS-OBJECT:dataGridView1:Name = "dataGridView1".
    THIS-OBJECT:dataGridView1:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:CellSelect.
    THIS-OBJECT:dataGridView1:Size = NEW System.Drawing.Size(602, 145).
    THIS-OBJECT:dataGridView1:TabIndex = 2.
    THIS-OBJECT:dataGridView1:CellFormatting:Subscribe(THIS-OBJECT:CellFormattingEvent).
    /*  */
    /* ttNum */
    /*  */
    THIS-OBJECT:ttNum:DataPropertyName = "ttNum".
    THIS-OBJECT:ttNum:HeaderText = "Num".
    THIS-OBJECT:ttNum:Name = "ttNum".
    THIS-OBJECT:ttNum:Width = 50.
    /*  */
    /* commentsDataGridViewTextBoxColumn */
    /*  */
    THIS-OBJECT:commentsDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
    THIS-OBJECT:commentsDataGridViewTextBoxColumn:DataPropertyName = "Comments".
    THIS-OBJECT:commentsDataGridViewTextBoxColumn:HeaderText = "Comments".
    THIS-OBJECT:commentsDataGridViewTextBoxColumn:MinimumWidth = 10.
    THIS-OBJECT:commentsDataGridViewTextBoxColumn:Name = "commentsDataGridViewTextBoxColumn".
    /*  */
    /* viewgrid */
    /*  */
    THIS-OBJECT:ClientSize = NEW System.Drawing.Size(602, 145).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:dataGridView1).
    THIS-OBJECT:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
    THIS-OBJECT:Name = "viewgrid".
    THIS-OBJECT:ShowInTaskbar = FALSE.
    THIS-OBJECT:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
    THIS-OBJECT:Text = "Results".
    CAST(THIS-OBJECT:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
    CAST(THIS-OBJECT:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
    THIS-OBJECT:ResumeLayout(FALSE).
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.
  END METHOD. 
 
  METHOD PUBLIC VOID ShowModalDialog(  ):
		
    WAIT-FOR THIS-OBJECT:ShowDialog().

  END METHOD.
  
  METHOD PRIVATE VOID loadData():
    /*    ttHdl = TEMP-TABLE ttComments:HANDLE.*/

    ttHdl = ajstoredata:getTempTableHandle().
    
    bh = ttHdl:DEFAULT-BUFFER-HANDLE.

    CREATE QUERY qh.
    qh:SET-BUFFERS (bh).
    qh:QUERY-PREPARE ("for each ttComments ").
    /*Assign the query handle to Datagrid*/
    bindingSource1:HANDLE = qh.
     
  END METHOD.
 
END CLASS.
