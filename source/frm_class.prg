/*
frm_Class - Class for data and bypass for functions
*/

#include "hbclass.ch"
#include "frm_class.ch"

CREATE CLASS frm_Class

   VAR lIsSQL          INIT .F.
   VAR cn
   VAR cDataTable      INIT ""
   VAR cDataField      INIT ""
   VAR cTitle
   VAR cFileDBF
   VAR aEditList       INIT {}
   VAR cOptions        INIT "IED"
   VAR aOptionList     INIT {}
   VAR cSelected       INIT "NONE"
   VAR lNavigate       INIT .T.
   VAR lModal          INIT .F.
   VAR nInitRecno
   VAR aInitValue1
   VAR aInitValue2
   VAR bActivate
   VAR aInitFix        INIT {}

   VAR nLayout         INIT 2
   VAR lWithTab        INIT .T.

   VAR xDlg
   VAR aControlList   INIT {}
   VAR aAllSetup      INIT {}
   VAR aDlgKeyDown    INIT {}
   VAR xParent

   METHOD First()
   METHOD Last()
   METHOD Next()
   METHOD Previous()
   METHOD CreateControls()     INLINE frm_Buttons( Self ), frm_Edit( Self )
   METHOD ButtonSaveOn( lSave )
   METHOD ButtonSaveOff()
   METHOD DataLoad()
   METHOD EditKeyOn()
   METHOD EditOn()
   METHOD EditOff()
   METHOD Print()              INLINE frm_Print( Self )
   METHOD Execute()            INLINE frm_Dialog( Self )
   METHOD View()               INLINE ::Browse( "", "", ::cFileDbf, Nil ), ::DataLoad()
   METHOD Edit()               INLINE ::cSelected := "EDIT", ::EditKeyOn()
   METHOD Delete()
   METHOD Insert()             INLINE ::cSelected := "INSERT", ::EditKeyOn()
   METHOD Exit()               INLINE gui_DialogClose( ::xDlg )
   METHOD DataSave()
   METHOD Cancel()             INLINE ::cSelected := "NONE", ::EditOff(), ::DataLoad()
   METHOD Validate( aItem )    INLINE frm_Valid( Self, aItem )
   METHOD Browse( ... )        INLINE frm_Browse( Self, ... )
   METHOD BrowseClick( aItem, nKey ) INLINE frm_BrowseClick( Self, aItem, nKey )
   METHOD DlgInit()

   ENDCLASS

METHOD DlgInit() CLASS frm_Class

   LOCAL nPos, aControl

   IF ! Empty( ::aInitFix )
      Eval( hb_ArrayToParams( ::aInitFix ) )
   ENDIF
   IF ::nInitRecno != Nil
      GOTO ::nInitRecno
   ENDIF
   ::DataLoad()
   IF Empty( ::cFileDbf )
      AEval( ::aControlList, { | e | ;
         iif( e[ CFG_CTLTYPE ] == TYPE_TEXT, gui_ControlEnable( ::xDlg, e[ CFG_FCONTROL ], .T. ), Nil ) } )
   ELSE
      ::EditOff()
   ENDIF
   IF ::aInitValue1 != Nil .AND. ::aInitValue2 != Nil
      IF ( nPos := hb_AScan( ::aControlList, { | e | e[ CFG_FNAME ] == ::aInitValue1[1] } ) ) != 0
         ::aControlList[ nPos ][ CFG_VALUE ]    := ::aInitValue1[2]
         ::aControlList[ nPos ][ CFG_SAVEONLY ] := .T.
         gui_ControlSetValue( ::xDlg, ::aControlList[ nPos ][ CFG_FCONTROL ], ::aInitValue1[2] )
      ENDIF
      IF ( nPos := hb_AScan( ::aControlList, { | e | e[ CFG_FNAME ] == ::aInitValue2[1] } ) ) != 0
         ::aControlList[ nPos ][ CFG_VALUE ] := ::aInitValue2[2]
         ::aControlList[ nPos ][ CFG_SAVEONLY ] := .T.
         gui_ControlSetValue( ::xDlg, ::aControlList[ nPos ][ CFG_FCONTROL ], ::aInitValue2[2] )
      ENDIF
   ENDIF
   // no success
   IF gui_LibName() == "FIVEWIN"
      FOR EACH aControl IN ::aControlList
         IF aControl[ CFG_FCONTROL ]:ClassName() == "TGET"
            aControl[ CFG_FCONTROL ]:nHeight := APP_LINE_HEIGHT
         ENDIF
   //      IF aControl[ CFG_CTLTYPE ] == TYPE_TAB
   //         FOR EACH cText IN aControl[ CFG_FCONTROL ]:aPrompts
   //            IF cText == "."
   //               aControl[ CFG_FCONTROL ]:aDialogs[ cText:__EnumIndex() ]:Hide()
   //            ENDIF
   //         NEXT
   //         aControl[ CFG_FCONTROL ]:Refresh()
   //      ENDIF
      NEXT

   ENDIF
   IF ! Empty( ::bActivate )
      Eval( ::bActivate )
   ENDIF

   RETURN Nil

METHOD First() CLASS frm_Class

   IF ::lIsSQL
      ::cn:Execute( "SELECT " + ::cDataField + " FROM " + ::cDataTable + " ORDER BY " + ::cDataField + " LIMIT 1" )
      //
      ::cn:CloseRecordset()
   ELSE
      GOTO TOP
   ENDIF
   ::DataLoad()

   RETURN Nil

METHOD Last() CLASS frm_Class

   IF ::lIsSQL
      ::cn:Execute( "SELECT " + ::cDataField + " FROM " + ::cDataTable + " ORDER BY " + ::cDataField + " DESC LIMIT 1" )
      //
      ::cn:CloseRecordset()
   ELSE
      GOTO BOTTOM
   ENDIF
   ::DataLoad()

   RETURN Nil

METHOD Next() CLASS frm_Class

   IF ::lIsSQL
      ::cn:Execute( "SELECT " + ::cDataField + " FROM " + ::cDataTable + " WHERE " + ::cDataField + ;
         " > " + ::axKeyValue + " ORDER BY " + ::cDataField + " DESC LIMIT 1" )
      //
      ::cn:CloseRecordset()
   ELSE
      SKIP
      IF Eof()
         GOTO BOTTOM
      ENDIF
   ENDIF
   ::DataLoad()

   RETURN Nil

METHOD Previous() CLASS frm_Class

   IF ::lIsSQL
      ::cn:Execute( "SELECT " + ::cDataField + " FROM " + ::cDataTable + " WHERE " + ::cDataField + ;
         " < " + ::axKeyValue + " ORDER BY " + ::cDataField + " LIMIT 1" )
      //
      ::cn:CloseRecordset()
   ELSE
      SKIP -1
      IF Bof()
         GOTO TOP
      ENDIF
      ::DataLoad()
   ENDIF

   RETURN Nil

METHOD ButtonSaveOn( lSave ) CLASS frm_Class

   LOCAL aItem

   hb_Default( @lSave, .T. )
   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON_BRW
         gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], lSave )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_CAPTION ] $ "Cancel" + iif( lSave, ",Save", "" )
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
         ELSE
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD ButtonSaveOff() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON_BRW
         gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_CAPTION ] $ "Save,Cancel"
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
         ELSE
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD EditKeyOn() CLASS frm_Class

   LOCAL aItem, oKeyEdit, lFound := .F.

   // search key field
   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUG_GET
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_TEXT .AND. aItem[ CFG_ISKEY ] .AND. ! aItem[ CFG_SAVEONLY ]
         gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
         IF ! lFound .AND. aItem[ CFG_ISKEY ]
            lFound := .T.
            oKeyEdit := aItem[ CFG_FCONTROL ]
         ENDIF
      ENDIF
   NEXT
   IF lFound // have key field
      ::ButtonSaveOn(.F.)
      gui_SetFocus( ::xDlg, oKeyEdit )
   ELSE // do not have key field
      ::EditOn()
   ENDIF

   RETURN Nil

METHOD EditOn() CLASS frm_Class

   LOCAL aItem, oFirstEdit, lFound := .F.
   LOCAL aEnableList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_COMBOBOX, TYPE_CHECKBOX, ;
      TYPE_DATEPICKER, TYPE_SPINNER, TYPE_BROWSE }

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUG_GET
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON_BRW
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF hb_AScan( aEnableList, { | e | e == aItem[ CFG_CTLTYPE ] } ) != 0
         IF aItem[ CFG_ISKEY ] .OR. aItem[ CFG_SAVEONLY ]
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
         ELSE
            gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
            IF ! lFound
               lFound := .T.
               oFirstEdit := aItem[ CFG_FCONTROL ]
            ENDIF
         ENDIF
      ENDIF
   NEXT
   ::ButtonSaveOn()
   gui_SetFocus( ::xDlg, oFirstEdit )

   RETURN Nil

METHOD EditOff() CLASS frm_Class

   LOCAL aItem
   LOCAL aDisableList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_COMBOBOX, ;
      TYPE_CHECKBOX, TYPE_DATEPICKER, TYPE_SPINNER, TYPE_BROWSE, ;
      TYPE_BUG_GET, TYPE_BUTTON_BRW }

   FOR EACH aItem IN ::aControlList
      IF hb_AScan( aDisableList, { | e | e == aItem[ CFG_CTLTYPE ] } ) != 0
         gui_ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
      ENDIF
   NEXT
   ::ButtonSaveOff()

   RETURN Nil

METHOD Delete() CLASS frm_Class

   LOCAL aFile, cSearch, nSelect, aItem

   nSelect := Select()
   // check if code is in use, from validate setup
   // do not use hb_Scan(), because can exists more than one field to same dbf
   FOR EACH aFile IN ::aAllSetup
      FOR EACH aItem IN aFile[ 2 ]
         IF aItem[ CFG_VTABLE ] == ::cFileDbf
            SELECT Select( aFile[ 1 ] )
            cSearch := aItem[ CFG_FNAME ] + [=("] + ::cFileDbf + [")->] + aItem[ CFG_VFIELD ]
            LOCATE FOR &cSearch
            IF ! Eof()
               gui_MsgBox( "Code in use on " + aFile[ 1 ] )
               SELECT ( nSelect )
               RETURN Nil
            ENDIF
         ENDIF
      NEXT
   NEXT
   SELECT ( nSelect )

   IF gui_MsgYesNo( "Delete" )
      IF ::lIsSQL
         ::cn:ExecuteNoReturn( "DELETE FROM " + ::cDataTable + " WHERE " + ::cDataField + "=" + "NONE" )
      ELSE
         IF rLock()
            DELETE
            SKIP 0
            UNLOCK
         ENDIF
      ENDIF
   ENDIF

   RETURN Nil

METHOD DataLoad() CLASS frm_Class

   LOCAL aItem, nSelect, xValue, cText, xScope, nLenScope, xValueControl
   LOCAL aCommonList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_DATEPICKER, TYPE_SPINNER }

   FOR EACH aItem IN ::aControlList
      DO CASE
      CASE aItem[ CFG_CTLTYPE ] == TYPE_BROWSE
         SELECT  ( Select( aItem[ CFG_BRWTABLE ] ) )
         SET ORDER TO ( aItem[ CFG_BRWIDXORD ] )
         xScope := ( ::cFileDbf )->( FieldGet( FieldNum( aItem[ CFG_BRWKEYFROM ] ) ) )
         nLenScope := ( ::cFileDbf )->( FieldLen( aItem[ CFG_BRWKEYFROM ] ) )
         IF ValType( xScope ) == "C"
            SET SCOPE TO xScope
         ELSE
            SET SCOPE TO Str( xScope, nLenScope )
         ENDIF
         GOTO TOP
         gui_BrowseRefresh( ::xDlg, aItem[ CFG_FCONTROL ] )
         SELECT ( Select( ::cFileDbf ) ) // not all libraries need this
      CASE Empty( aItem[ CFG_FNAME ] ) // not a field
      CASE aItem[ CFG_SAVEONLY ]
      CASE hb_AScan( aCommonList, aItem[ CFG_CTLTYPE ] ) != 0
         IF ! aItem[ CFG_SAVEONLY ]
            xValue := ( ::cFileDbf )->( FieldGet( FieldNum( aItem[ CFG_FNAME ] ) ) )
         ENDIF
         gui_ControlSetValue( ::xDlg, aItem[ CFG_FCONTROL ], xValue )
         IF ! Empty( aItem[ CFG_VTABLE ] ) .AND. ! Empty( aItem[ CFG_VSHOW ] )
            nSelect := Select()
            SELECT ( Select( aItem[ CFG_VTABLE ] ) )
            SEEK xValue
            cText := ( aItem[ CFG_VTABLE ] )->( FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) ) )
            SELECT ( nSelect )
            gui_ControlSetValue( ::xDlg, aItem[ CFG_VCONTROL ], cText )
         ENDIF

      CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
         xValue := FieldGet( FieldNum( aItem[ CFG_FNAME ] ) )
         DO CASE
         CASE aItem[ CFG_FTYPE ] == "L"
         CASE aItem[ CFG_FTYPE ] == "N"
            xValue := ( xValue == 1 )
         CASE aItem[ CFG_FTYPE ] == "C"
            xValue := ( xValue == "Y" )
         ENDCASE
         gui_ControlSetValue( ::xDlg, aItem[ CFG_FCONTROL ], xValue )

      CASE ! Empty( aItem[ CFG_FNAME ] ) .AND. aItem[ CFG_CTLTYPE ] == TYPE_COMBOBOX
         xValue := FieldGet( FieldNum( aItem[ CFG_FNAME ] ) )
         IF gui_LibName() == "FIVEWIN"
            xValueControl := xValue
         ELSE
            xValueControl := hb_AScan( aItem[ CFG_COMBOLIST ], { | e | e == xValue } )
         ENDIF
         gui_ControlSetValue( ::xDLg, aItem[ CFG_FCONTROL ], xValueControl )

      ENDCASE
   NEXT
   (cText)

   RETURN Nil

METHOD DataSave() CLASS frm_Class

   LOCAL aItem, xValue
   LOCAL aCommonList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_DATEPICKER, TYPE_SPINNER }

   ::EditOff()
   IF RLock()
      FOR EACH aItem IN ::aControlList
         DO CASE
         CASE Empty( aItem[ CFG_FNAME ] ) // not a field
         CASE aItem[ CFG_CTLTYPE ] == TYPE_COMBOBOX
            xValue := gui_ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
            IF ValType( xValue ) == "N"
               IF xValue == 0 .OR. xValue > Len( aItem[ CFG_COMBOLIST ] )
                  xValue := Space( aItem[ CFG_FLEN ] )
               ELSE
                  xValue := aItem[ CFG_COMBOLIST ][ xValue ]
               ENDIF
            ENDIF
            fieldput( FieldNum( aItem[ CFG_FNAME ] ), xValue )
         CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
            xValue := gui_ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
            DO CASE
            CASE aItem[ CFG_FTYPE ] == "L"
            CASE aItem[ CFG_FTYPE ] == "N"; xValue := iif( xValue, 1, 0 )
            CASE aItem[ CFG_FTYPE ] == "C"; xValue := iif( xValue, "Y", "N" )
            ENDCASE
            FieldPut( FieldNum( aItem[ CFG_FNAME ] ), xValue )
         CASE hb_AScan( aCommonList, { | e | e == aItem[ CFG_CTLTYPE ] } ) == 0 // not "value"
         CASE aItem[ CFG_ISKEY ]
         OTHERWISE
            xValue := gui_ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
            FieldPut( FieldNum( aItem[ CFG_FNAME ] ), xValue )
         ENDCASE
      NEXT
      SKIP 0
      UNLOCK
   ENDIF
   ::cSelected := "NONE"

   RETURN Nil

FUNCTION EmptyFrmClassItem()

   LOCAL aItem := Array(29)

   aItem[ CFG_FNAME ]       := ""
   aItem[ CFG_FTYPE ]       := "C"
   aItem[ CFG_FLEN ]        := 1
   aItem[ CFG_FDEC ]        := 0
   aItem[ CFG_ISKEY ]       := .F.
   aItem[ CFG_FPICTURE ]    := ""
   aItem[ CFG_CAPTION ]     := ""
   aItem[ CFG_VALID ]       := {}
   aItem[ CFG_VTABLE ]      := ""
   aItem[ CFG_VFIELD ]      := ""
   aItem[ CFG_VSHOW ]       := ""
   aItem[ CFG_VLEN ]        := 0
   aItem[ CFG_CTLTYPE ]     := TYPE_NONE
   aItem[ CFG_SAVEONLY ]    := .F.
   // default
   //aItem[ CFG_VALUE ]      := Nil
   //aItem[ CFG_FCONTROL ]   := Nil
   //aItem[ CFG_CCONTROL ]   := Nil
   //aItem[ CFG_VCONTROL ]   := Nil
   //aItem[ CFG_ACTION ]     := Nil
   //aItem[ CFG_BRWTABLE ]   := Nil
   //aItem[ CFG_BRWKEYFROM ] := Nil
   //aItem[ CFG_BRWIDXORD ]  := Nil
   //aItem[ CFG_BRWKEYTO ]   := Nil
   //aItem[ CFG_BRWKEYTO2 ]  := Nil
   //aItem[ CFG_BRWVALUE ]   := Nil
   //aItem[ CFG_BRWEDIT ]    := Nil
   //aItem[ CFG_BRWTITLE ]   := Nil
   //aItem[ CFG_COMBOLIST ]  := Nil
   //aItem[ CFG_VALUE ]      := Nil
   //aItem[ CFG_SPINNER ]    := Nil

   RETURN aItem

