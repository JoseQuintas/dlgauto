/*
frm_Class - Class for data and bypass for functions
*/

#include "hbclass.ch"
#include "frm_class.ch"

CREATE CLASS frm_Class

#ifdef DLGAUTO_AS_SQL
   VAR lIsSQL          INIT .T.
   VAR cnSQL           INIT ADOLocal()
#else
   VAR lIsSQL          INIT .F.
   VAR cnSQL
#endif
   VAR cDataTable      INIT ""
   VAR cDataField      INIT ""
   VAR cDataFilter     INIT ""
   VAR cTitle          INIT ""
   VAR aEditList       INIT {}
   // buttons/toolbar
   VAR cOptions        INIT "IED"
   VAR aOptionList     INIT {}
   VAR cSelected       INIT "NONE"
   VAR lNavigate       INIT .T.
   //
   VAR lModal          INIT .F.
   VAR nInitRecno
   VAR aInitValue1
   VAR aInitValue2
   VAR EventInitList   INIT {}

   VAR nLayout         INIT 2
   VAR lWithTab        INIT .T.

   VAR xDlg            INIT ""
   VAR aControlList    INIT {}
   VAR aAllSetup       INIT {}
   VAR aDlgKeyDown     INIT {}
   VAR xParent

   METHOD CreateControls()     INLINE frm_ButtonCreate( Self ), frm_EditCreate( Self )

   METHOD Move_Click( cMoveTo )
   METHOD View_Click()         INLINE ::Browse( "", "", ::cDataTable, Nil ), ::DataLoad()
   METHOD Print_Click()        INLINE frm_EventPrint( Self )
   METHOD Exit_Click()

   METHOD Delete_Click()
   METHOD Edit_Click()         INLINE ::cSelected := "EDIT",   ::EditKeyOn()
   METHOD Insert_Click()       INLINE ::cSelected := "INSERT", ::EditKeyOn()
   METHOD Cancel_Click()       INLINE ::cSelected := "NONE",   ::EditOff(), ::DataLoad()
   METHOD Save_Click()
   METHOD Browse( ... )               INLINE frm_DialogBrowse( Self, ... )
   METHOD Browse_Click( aItem, nKey ) INLINE frm_EventBrowseClick( Self, aItem, nKey )

   METHOD ButtonSaveOn( lSave )
   METHOD ButtonSaveOff()
   METHOD DataLoad()
   METHOD EditKeyOn()
   METHOD EditOn()
   METHOD EditOff()
   METHOD EditValidate( aItem )       INLINE frm_EditValidate( Self, aItem )

   METHOD Execute()                   INLINE frm_DialogData( Self )
   METHOD EventInit() // may be lib have oninit and onactivate

   ENDCLASS

METHOD EventInit() CLASS frm_Class

   LOCAL nPos, aItem

   // if subroutine part 1
   IF ::nInitRecno != Nil
      IF ::lIsSQL
         // key
      ELSE
         GOTO ::nInitRecno
      ENDIF
   ENDIF

   ::DataLoad()

   // if subroutine part2
   IF Empty( ::cDataTable )
      AEval( ::aControlList, { | e | ;
         iif( e[ CFG_CTLTYPE ] == TYPE_TEXT, GUI():ControlEnable( ::xDlg, e[ CFG_FCONTROL ], .T. ), Nil ) } )
   ELSE
      ::EditOff()
   ENDIF
   IF ::aInitValue1 != Nil .AND. ::aInitValue2 != Nil
      IF ( nPos := hb_AScan( ::aControlList, { | e | e[ CFG_FNAME ] == ::aInitValue1[1] } ) ) != 0
         ::aControlList[ nPos ][ CFG_VALUE ]    := ::aInitValue1[2]
         ::aControlList[ nPos ][ CFG_SAVEONLY ] := .T.
         GUI():ControlSetValue( ::xDlg, ::aControlList[ nPos ][ CFG_FCONTROL ], ::aInitValue1[2] )
      ENDIF
      IF ( nPos := hb_AScan( ::aControlList, { | e | e[ CFG_FNAME ] == ::aInitValue2[1] } ) ) != 0
         ::aControlList[ nPos ][ CFG_VALUE ] := ::aInitValue2[2]
         ::aControlList[ nPos ][ CFG_SAVEONLY ] := .T.
         GUI():ControlSetValue( ::xDlg, ::aControlList[ nPos ][ CFG_FCONTROL ], ::aInitValue2[2] )
      ENDIF
   ENDIF
   IF ! Empty( ::EventInitList )
      FOR EACH aItem IN ::EventInitList
         Eval( aItem )
      NEXT
   ENDIF

   RETURN Nil

METHOD Move_Click( cMoveTo ) CLASS frm_Class

   LOCAL aItem, xValue

   IF ::lIsSQL
      IF Empty( ::cDataField )
         RETURN Nil
      ENDIF
      DO CASE
      CASE cMoveTo == "FIRST"
         ::cnSQL:cSQL := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " ORDER BY " + ::cDataField + " LIMIT 1"
      CASE cMoveTo == "LAST"
         ::cnSQL:cSQL := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " ORDER BY " + ::cDataField + " DESC LIMIT 1"
      CASE cMoveTo == "NEXT"
         ::cnSQL:cSQL := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " WHERE " + ::cDataField + " > "
         FOR EACH aItem IN ::aControlList
            IF aItem[ CFG_FNAME ] == ::cDataField
               ::cnSQL:cSQL += hb_ValToExp( GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] ) )
            ENDIF
         NEXT
         ::cnSQL:cSQL += " ORDER BY " + ::cDataField + " LIMIT 1"
      CASE cMoveTo == "PREV"
         ::cnSQL:cSQL := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " WHERE " + ::cDataField + " < "
         FOR EACH aItem IN ::aControlList
            IF aItem[ CFG_FNAME ] == ::cDataField
               ::cnSQL:cSQL += hb_ValToExp( GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] ) )
            ENDIF
         NEXT
         ::cnSQL:cSQL += " ORDER BY " + ::cDataField + " DESC LIMIT 1"
      ENDCASE
      ::cnSQL:Execute()
      IF ::cnSQL:Eof()
         GUI():MsgBox( "No record found" )
      ELSE
         FOR EACH aItem IN ::aControlList
            IF aItem[ CFG_FNAME ] == ::cDataField
               DO CASE
               CASE aItem[ CFG_FTYPE ] == "C"; xValue := ::cnSQL:String( ::cDataField, aItem[ CFG_FLEN ] )
               CASE aItem[ CFG_FTYPE ] == "N"; xValue := ::cnSQL:Number( ::cDataField )
               CASE aItem[ CFG_FTYPE ] == "D"; xValue := ::cnSQL:Date( ::cDataField )
               CASE aItem[ CFG_FTYPE ] == "M"; xValue := ::cnSQL:String( ::cDataField )
               ENDCASE
               GUI():ControlSetValue( ::xDlg, aItem[ CFG_FCONTROL ], xValue )
               EXIT
            ENDIF
         NEXT
      ENDIF
      ::cnSQL:CloseRecordset()
   ELSE
      DO CASE
      CASE cMoveTo == "FIRST"
         GOTO TOP
      CASE cMoveTo == "LAST"
         GOTO BOTTOM
      CASE cMoveTo == "NEXT"
         SKIP
         IF Eof()
            GOTO BOTTOM
         ENDIF
     CASE cMoveTo == "PREV"
         SKIP -1
         IF Bof()
            GOTO TOP
         ENDIF
     ENDCASE
   ENDIF
   ::DataLoad()

   RETURN Nil

METHOD ButtonSaveOn( lSave ) CLASS frm_Class

   LOCAL aItem

   hb_Default( @lSave, .T. )
   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON_BRW
         GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], lSave )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_CAPTION ] $ "Cancel" + iif( lSave, ",Save", "" )
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
         ELSE
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD ButtonSaveOff() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON_BRW
         GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_CAPTION ] $ "Save,Cancel"
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
         ELSE
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD EditKeyOn() CLASS frm_Class

   LOCAL aItem, oKeyEdit, lFoundEdit := .F.

   // search key field
   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUG_GET
         GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_TEXT .AND. aItem[ CFG_ISKEY ] .AND. ! aItem[ CFG_SAVEONLY ]
         GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
         IF ! lFoundEdit .AND. aItem[ CFG_ISKEY ]
            lFoundEdit := .T.
            oKeyEdit := aItem[ CFG_FCONTROL ]
         ENDIF
      ENDIF
   NEXT
   IF lFoundEdit // have key field
      ::ButtonSaveOn(.F.)
      GUI():SetFocus( ::xDlg, oKeyEdit )
   ELSE // do not have key field
      ::EditOn()
   ENDIF

   RETURN Nil

METHOD EditOn() CLASS frm_Class

   LOCAL aItem, oFirstEdit, lFoundEdit := .F.
   LOCAL aEnableList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_COMBOBOX, TYPE_CHECKBOX, ;
      TYPE_DATEPICKER, TYPE_SPINNER, TYPE_BROWSE }

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUG_GET
         GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON_BRW
         GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF hb_AScan( aEnableList, { | e | e == aItem[ CFG_CTLTYPE ] } ) != 0
         IF aItem[ CFG_ISKEY ] .OR. aItem[ CFG_SAVEONLY ]
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
         ELSE
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
            IF ! lFoundEdit
               lFoundEdit := .T.
               oFirstEdit := aItem[ CFG_FCONTROL ]
            ENDIF
         ENDIF
      ENDIF
   NEXT
   ::ButtonSaveOn()
   IF ! Empty( oFirstEdit )
      GUI():SetFocus( ::xDlg, oFirstEdit )
   ENDIF

   RETURN Nil

METHOD EditOff() CLASS frm_Class

   LOCAL aItem
   LOCAL aDisableList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_COMBOBOX, ;
      TYPE_CHECKBOX, TYPE_DATEPICKER, TYPE_SPINNER, TYPE_BROWSE, ;
      TYPE_BUG_GET, TYPE_BUTTON_BRW }

   FOR EACH aItem IN ::aControlList
      IF hb_AScan( aDisableList, { | e | e == aItem[ CFG_CTLTYPE ] } ) != 0
         GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
      ENDIF
   NEXT
   ::ButtonSaveOff()
   GUI():SetFocus( ::xDlg )

   RETURN Nil

METHOD Delete_Click() CLASS frm_Class

   LOCAL aFile, cSearch, nSelect, aItem

   nSelect := Select()
   // check if code is in use, from validate setup
   // do not use hb_Scan(), because can exists more than one field to same dbf
   FOR EACH aFile IN ::aAllSetup
      FOR EACH aItem IN aFile[ 2 ]
         IF aItem[ CFG_VTABLE ] == ::cDataTable
            SELECT Select( aFile[ 1 ] )
            cSearch := aItem[ CFG_FNAME ] + [=("] + ::cDataTable + [")->] + aItem[ CFG_VFIELD ]
            LOCATE FOR &cSearch
            IF ! Eof()
               GUI():MsgBox( "Code in use on " + aFile[ 1 ] )
               SELECT ( nSelect )
               RETURN Nil
            ENDIF
         ENDIF
      NEXT
   NEXT
   SELECT ( nSelect )

   IF GUI():MsgYesNo( "Delete" )
      IF ::lIsSQL
         // Disabled
         ::cnSQL:ExecuteNoReturn( "DELETE FROM " + ::cDataTable + " WHERE " + ::cDataField + "=" + "NONE" )
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
#ifdef DLGAUTO_AS_SQL
   LOCAL aControl
#endif

   IF Empty( ::cDataTable ) // no data source
      RETURN Nil
   ENDIF
   IF ::lIsSQL
      ::cnSQL:cSQL := "SELECT * FROM " + ::cDataTable
      IF ! Empty( ::cDataField )
         ::cnSQL:cSQL += " WHERE " + ::cDataField + " = "
         FOR EACH aItem IN ::aControlList
            IF aItem[ CFG_FNAME ] == ::cDataField
               xValue := GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
               DO CASE
               CASE aItem[ CFG_FTYPE ] == "N" ; ::cnSQL:cSQL += NumberSQL( xValue )
               CASE aItem[ CFG_FTYPE ] == "D" ; ::cnSQL:cSQL += DateSQL( xValue )
               OTHERWISE ;                      ::cnSQL:cSQL += StringSQL( xValue )
               ENDCASE
            ENDIF
         NEXT
      ENDIF
      ::cnSQL:cSQL += " LIMIT 1"
      ::cnSQL:Execute()
   ENDIF
   // data from current database
   FOR EACH aItem IN ::aControlList
      DO CASE
      CASE aItem[ CFG_CTLTYPE ] == TYPE_BROWSE
      CASE Empty( aItem[ CFG_FNAME ] ) // not a field
      CASE aItem[ CFG_SAVEONLY ]
      CASE hb_AScan( aCommonList, aItem[ CFG_CTLTYPE ] ) != 0
         IF ::lIsSQL
            DO CASE
            CASE aItem[ CFG_FTYPE ] == "N"; xValue := ::cnSQL:Number( aItem[ CFG_FNAME ] )
            CASE aItem[ CFG_FTYPE ] == "D"; xValue := ::cnSQL:Date( aItem[ CFG_FNAME ] )
            OTHERWISE ; xValue := ::cnSQL:String( aItem[ CFG_FNAME ], aItem[ CFG_FLEN ] )
            ENDCASE
         ELSE
            xValue := ( ::cDataTable )->( FieldGet( FieldNum( aItem[ CFG_FNAME ] ) ) )
         ENDIF
         GUI():ControlSetValue( ::xDlg, aItem[ CFG_FCONTROL ], xValue )

      CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
         xValue := FieldGet( FieldNum( aItem[ CFG_FNAME ] ) )
         DO CASE
         CASE aItem[ CFG_FTYPE ] == "L"
         CASE aItem[ CFG_FTYPE ] == "N"
            xValue := ( xValue == 1 )
         CASE aItem[ CFG_FTYPE ] == "C"
            xValue := ( xValue == "Y" )
         ENDCASE
         GUI():ControlSetValue( ::xDlg, aItem[ CFG_FCONTROL ], xValue )

      CASE ! Empty( aItem[ CFG_FNAME ] ) .AND. aItem[ CFG_CTLTYPE ] == TYPE_COMBOBOX
         xValue := FieldGet( FieldNum( aItem[ CFG_FNAME ] ) )
         IF GUI():LibName() == "FIVEWIN"
            xValueControl := hb_Ascan( aItem[ CFG_COMBOLIST ], { |e | e == xValue } )
         ELSE
            xValueControl := hb_AScan( aItem[ CFG_COMBOLIST ], { | e | e == xValue } )
         ENDIF
         GUI():ControlSetValue( ::xDLg, aItem[ CFG_FCONTROL ], xValueControl )

      ENDCASE
   NEXT
   IF ::lIsSQL
      ::cnSQL:CloseRecordset()
   ENDIF
   // other data
   FOR EACH aItem IN ::aControlList
      DO CASE
      CASE aItem[ CFG_CTLTYPE ] == TYPE_BROWSE
         IF ::lIsSQL
#ifdef DLGAUTO_AS_SQL
            IF GUI():LibName() == "FIVEWIN"
               WITH OBJECT aItem[ CFG_FCONTROL ]
                  :xUserData:CloseRecordset()
                  :xUserData:cSQL := "SELECT * FROM " + aItem[ CFG_BRWTABLE ] + ;
                     " WHERE " + aItem[ CFG_BRWKEYTO ] + ;
                     " = "
                  FOR EACH aControl IN ::aControlList
                     IF aControl[ CFG_FNAME ] == aItem[ CFG_BRWKEYFROM ]
                        :xUserData:cSQL += hb_ValToExp( gui():ControlGetValue( ::xDlg, aControl[ CFG_FCONTROL ] ) )
                        EXIT
                     ENDIF
                  NEXT
                  :xUserData:Execute()
                  :SetArray( Array( :xUserData:RecordCount() ) )
                  GUI():BrowseRefresh( ::xDlg, aItem[ CFG_FCONTROL ] )
               ENDWITH
            ENDIF
            IF GUI():LibName() == "HWGUI"
               WITH OBJECT aItem[ CFG_FCONTROL ]
                  :aArray:CloseRecordset()
                  :aArray:cSQL := "SELECT * FROM " + aItem[ CFG_BRWTABLE ] + ;
                     " WHERE " + aItem[ CFG_BRWKEYTO ] + ;
                     " = "
                  FOR EACH aControl IN ::aControlList
                     IF aControl[ CFG_FNAME ] == aItem[ CFG_BRWKEYFROM ]
                        :aArray:cSQL += hb_ValToExp( gui():ControlGetValue( ::xDlg, aControl[ CFG_FCONTROL ] ) )
                        EXIT
                     ENDIF
                  NEXT
                  :aArray:Execute()
                  GUI():BrowseRefresh( ::xDlg, aItem[ CFG_FCONTROL ] )
               ENDWITH
            ENDIF
#endif
         ELSE
            SELECT  ( Select( aItem[ CFG_BRWTABLE ] ) )
            SET ORDER TO ( aItem[ CFG_BRWIDXORD ] )
            xScope := ( ::cDataTable )->( FieldGet( FieldNum( aItem[ CFG_BRWKEYFROM ] ) ) )
            nLenScope := ( ::cDataTable )->( FieldLen( aItem[ CFG_BRWKEYFROM ] ) )
            IF ValType( xScope ) == "C"
               SET SCOPE TO xScope
            ELSE
               SET SCOPE TO Str( xScope, nLenScope )
            ENDIF
            GOTO TOP
            GUI():BrowseRefresh( ::xDlg, aItem[ CFG_FCONTROL ] )
            SELECT ( Select( ::cDataTable ) ) // not all libraries need this
         ENDIF
      CASE aItem[ CFG_SAVEONLY ]
      CASE ! Empty( aItem[ CFG_VTABLE ] ) .AND. ! Empty( aItem[ CFG_VSHOW ] )
         xValue := GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
         IF ::lIsSQL
            ::cnSQL:cSQL := "SELECT " + aItem[ CFG_VSHOW ] + ;
               " FROM " + aItem[ CFG_VTABLE ] + ;
               " WHERE " + aItem[ CFG_VFIELD ] + "="
            DO CASE
            CASE aItem[ CFG_FTYPE ] == "N"; ::cnSQL:cSQL += NumberSQL( xValue )
            CASE aItem[ CFG_FTYPE ] == "D"; ::cnSQL:cSQL += DateSQL( xValue )
            OTHERWISE;                      ::cnSQL:cSQL += StringSQL( xValue )
            ENDCASE
            ::cnSQL:Execute()
            cText := ::cnSQL:Value( aItem[ CFG_VSHOW ] )
            ::cnSQL:CloseRecordset()
         ELSE
            nSelect := Select()
            SELECT ( Select( aItem[ CFG_VTABLE ] ) )
            SEEK xValue
            cText := ( aItem[ CFG_VTABLE ] )->( FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) ) )
            SELECT ( nSelect )
         ENDIF
         GUI():ControlSetValue( ::xDlg, aItem[ CFG_VCONTROL ], cText )
      ENDCASE
   NEXT
   (cText)

   RETURN Nil

METHOD Save_Click() CLASS frm_Class

   LOCAL aItem, xValue, aQueryList := {}, aReplace
   LOCAL aCommonList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_DATEPICKER, TYPE_SPINNER }
   //LOCAL cTxt := ""

#ifdef DLGAUTO_AS_SQL
   LOCAL cSQL := "", cWhere := ""
   LOCAL cnSQL := ADOLocal()
#endif
   IF Empty( ::cDataTable ) // no data source
      RETURN Nil
   ENDIF
   ::EditOff()
   FOR EACH aItem IN ::aControlList
      DO CASE
      CASE Empty( aItem[ CFG_FNAME ] ) // not a field
      CASE aItem[ CFG_CTLTYPE ] == TYPE_COMBOBOX
         xValue := GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
         IF ValType( xValue ) == "N"
            IF xValue == 0 .OR. xValue > Len( aItem[ CFG_COMBOLIST ] )
               xValue := Space( aItem[ CFG_FLEN ] )
            ELSE
               xValue := aItem[ CFG_COMBOLIST ][ xValue ]
            ENDIF
         ENDIF
         AAdd( aQueryList, { aItem[ CFG_FNAME ], xValue } )
      CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
         xValue := GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
         DO CASE
         CASE aItem[ CFG_FTYPE ] == "L"
         CASE aItem[ CFG_FTYPE ] == "N"; xValue := iif( xValue, 1, 0 )
         CASE aItem[ CFG_FTYPE ] == "C"; xValue := iif( xValue, "Y", "N" )
         ENDCASE
         AAdd( aQueryList, { aItem[ CFG_FNAME ], xValue } )
      CASE hb_AScan( aCommonList, { | e | e == aItem[ CFG_CTLTYPE ] } ) == 0 // not "value"
      CASE aItem[ CFG_ISKEY ]
#ifdef DLGAUTO_AS_SQL
         cWhere += iif( Empty( cWhere ), "", " AND " ) + ;
            aItem[ CFG_FNAME ] + "=" + hb_ValToExp( GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] ) )
#endif
      OTHERWISE
         xValue := GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
         AAdd( aQueryList, { aItem[ CFG_FNAME ], xValue } )
      ENDCASE
   NEXT
#ifdef DLGAUTO_AS_SQL
   IF ! Empty( cWhere )
      FOR EACH aReplace IN aQueryList
         xValue := aReplace[2]
         DO CASE
         CASE ValType( xValue ) == "N"; xValue := hb_ValToExp( xValue )
         CASE ValType( xValue ) == "D"; xValue := iif( Empty( xValue ), "NULL", hb_ValToExp( hb_Dtoc( xValue, "YYYY-MM-DD" ) ) )
         OTHERWISE                    ; xValue := hb_ValToExp( AllTrim( xValue ) )
         ENDCASE
         cSQL += iif( Len( cSql ) == 0, "", ", " ) + aReplace[ 1 ] + "=" + xValue
      NEXT
      cSQL := "UPDATE " + ::cDataTable + " SET " + cSQL
      cSQL += " WHERE " + cWhere
      cnSQL:Execute( cSQL )
   ENDIF
#else
   IF RLock()
      FOR EACH aReplace IN aQueryList
         FieldPut( FieldNum( aReplace[ 1 ] ), aReplace[ 2 ] )
      NEXT
      SKIP 0
      UNLOCK
   ENDIF
#endif
   ::cSelected := "NONE"

   RETURN Nil

METHOD Exit_Click() CLASS frm_Class

   LOCAL aItem

   IF ::lIsSQL
      FOR EACH aItem IN ::aControlList
         IF aItem[ CFG_CTLTYPE ] == TYPE_BROWSE
            IF GUI():LibName() == "FIVEWIN"
               aItem[ CFG_FCONTROL ]:xUserData:CloseRecordset()
            ELSE
               aItem[ CFG_FCONTROL ]:aArray:CloseRecordset()
            ENDIF
         ENDIF
      NEXT
      ::cnSQL:CloseRecordset()
   ENDIF
   GUI():DialogClose( ::xDlg )

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
