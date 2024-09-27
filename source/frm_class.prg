/*
frm_Class - Class for data and bypass for functions
*/

#include "hbclass.ch"
#include "frm_class.ch"

CREATE CLASS frm_Class

#ifdef DLGAUTO_AS_LIB
   VAR lIsSQL          INIT .T.
   VAR cnSQL           INIT ADOLocal()
#else
   VAR lIsSQL          INIT .F.
   VAR cnSQL
#endif
   VAR cDataTable      INIT ""
   VAR cDataField      INIT ""
   VAR cTitle          INIT ""
   VAR aEditList       INIT {}
   VAR cOptions        INIT "IED"
   VAR aOptionList     INIT {}
   VAR cSelected       INIT "NONE"
   VAR lNavigate       INIT .T.
   VAR lModal          INIT .F.
   VAR nInitRecno
   VAR aInitValue1
   VAR aInitValue2
   VAR bOnFrmActivate

   VAR nLayout         INIT 2
   VAR lWithTab        INIT .T.

   VAR xDlg           INIT ""
   VAR aControlList   INIT {}
   VAR aAllSetup      INIT {}
   VAR aDlgKeyDown    INIT {}
   VAR xParent

   METHOD First_Click()
   METHOD Last_Click()
   METHOD Next_Click()
   METHOD Previous_Click()
   METHOD Insert_Click()       INLINE ::cSelected := "INSERT", ::EditKeyOn()
   METHOD Edit_Click()         INLINE ::cSelected := "EDIT", ::EditKeyOn()
   METHOD Print_Click()        INLINE frm_EventPrint( Self )
   METHOD Delete_Click()
   METHOD Cancel_Click()       INLINE ::cSelected := "NONE", ::EditOff(), ::DataLoad()
   METHOD Save_Click()
   METHOD View_Click()         INLINE ::Browse( "", "", ::cDataTable, Nil ), ::DataLoad()
   METHOD Exit_Click()

   METHOD CreateControls()     INLINE frm_Button( Self ), frm_Edit( Self )
   METHOD ButtonSaveOn( lSave )
   METHOD ButtonSaveOff()
   METHOD DataLoad()
   METHOD EditKeyOn()
   METHOD EditOn()
   METHOD EditOff()
   METHOD Execute()            INLINE frm_DialogData( Self )
   METHOD Validate( aItem )    INLINE frm_EventValid( Self, aItem )
   METHOD Browse( ... )        INLINE frm_DialogBrowse( Self, ... )
   METHOD Browse_Click( aItem, nKey ) INLINE frm_EventBrowseClick( Self, aItem, nKey )
   METHOD OnFrmInit()

   ENDCLASS

METHOD OnFrmInit() CLASS frm_Class

   LOCAL nPos
//#ifdef HBMK_HAS_FIVEWIN
   //LOCAL aControl, cText
//#endif

   IF ::nInitRecno != Nil
      GOTO ::nInitRecno
   ENDIF
   ::DataLoad()
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
   // no success
#ifdef DLGAUTO_AS_LIB
#ifdef HBMK_HAS_FIVEWIN
   //IF GUI():LibName() == "FIVEWIN"
      //IF ::xDlg:cTitle == "MENU"
      //   ::xDlg:bValid := { || gui():MsgBox( aWindowsInfo() ), .T. }
      //ENDIF
      //FOR EACH aControl IN ::aControlList
      //   IF aControl[ CFG_CTLTYPE ] == TYPE_TAB
      //      FOR EACH cText IN aControl[ CFG_FCONTROL ]:aPrompts
      //         IF cText == "." .OR. cText == "Two" .OR. cText == "Three"
      //            aControl[ CFG_FCONTROL ]:aDialogs[ cText:__EnumIndex() ]:Hide()
      //         ENDIF
      //      NEXT
      //      aControl[ CFG_FCONTROL ]:Refresh()
      //   ENDIF
      //NEXT
   //ENDIF
#endif
#endif
   IF ! Empty( ::bOnFrmActivate )
      Eval( ::bOnFrmActivate )
   ENDIF

   RETURN Nil

METHOD First_Click() CLASS frm_Class

   LOCAL aItem, xValue

   IF ::lIsSQL
      IF Empty( ::cDataField )
         RETURN Nil
      ENDIF
      ::cnSQL:Execute( "SELECT " + ::cDataField + " FROM " + ::cDataTable + " ORDER BY " + ::cDataField + " LIMIT 1" )
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
      ::cnSQL:CloseRecordset()
   ELSE
      GOTO TOP
   ENDIF
   ::DataLoad()

   RETURN Nil

METHOD Last_Click() CLASS frm_Class

   LOCAL aItem, xValue

   IF ::lIsSQL
      IF Empty( ::cDataField )
         RETURN Nil
      ENDIF
      ::cnSQL:Execute( "SELECT " + ::cDataField + " FROM " + ::cDataTable + " ORDER BY " + ::cDataField + " DESC LIMIT 1" )
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
      ::cnSQL:CloseRecordset()
   ELSE
      GOTO BOTTOM
   ENDIF
   ::DataLoad()

   RETURN Nil

METHOD Next_Click() CLASS frm_Class

   LOCAL aItem, xValue

   IF ::lIsSQL
      IF Empty( ::cDataField )
         RETURN Nil
      ENDIF
      ::cnSQL:cSQL := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " WHERE " + ::cDataField + " > "
      FOR EACH aItem IN ::aControlList
         IF aItem[ CFG_FNAME ] == ::cDataField
            ::cnSQL:cSQL += hb_ValToExp( GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] ) )
         ENDIF
      NEXT
      ::cnSQL:cSQL += " ORDER BY " + ::cDataField + " LIMIT 1"
      ::cnSQL:Execute()
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
      ::cnSQL:CloseRecordset()
   ELSE
      SKIP
      IF Eof()
         GOTO BOTTOM
      ENDIF
   ENDIF
   ::DataLoad()

   RETURN Nil

METHOD Previous_Click() CLASS frm_Class

   LOCAL aItem, xValue

   IF ::lIsSQL
      IF Empty( ::cDataField )
         RETURN Nil
      ENDIF
      ::cnSQL:cSQL := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " WHERE " + ::cDataField + " < "
      FOR EACH aItem IN ::aControlList
         IF aItem[ CFG_FNAME ] == ::cDataField
            ::cnSQL:cSQL += hb_ValToExp( GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] ) )
         ENDIF
      NEXT
      ::cnSQL:cSQL += " ORDER BY " + ::cDataField + " DESC LIMIT 1"
      ::cnSQL:Execute()
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
      ::cnSQL:CloseRecordset()
   ELSE
      SKIP -1
      IF Bof()
         GOTO TOP
      ENDIF
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

   LOCAL aItem, oKeyEdit, lFound := .F.

   // search key field
   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUG_GET
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_TEXT .AND. aItem[ CFG_ISKEY ] .AND. ! aItem[ CFG_SAVEONLY ]
         GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
         IF ! lFound .AND. aItem[ CFG_ISKEY ]
            lFound := .T.
            oKeyEdit := aItem[ CFG_FCONTROL ]
         ENDIF
      ENDIF
   NEXT
   IF lFound // have key field
      ::ButtonSaveOn(.F.)
      GUI():SetFocus( ::xDlg, oKeyEdit )
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
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON_BRW
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
      ELSEIF hb_AScan( aEnableList, { | e | e == aItem[ CFG_CTLTYPE ] } ) != 0
         IF aItem[ CFG_ISKEY ] .OR. aItem[ CFG_SAVEONLY ]
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .F. )
         ELSE
            GUI():ControlEnable( ::xDlg, aItem[ CFG_FCONTROL ], .T. )
            IF ! lFound
               lFound := .T.
               oFirstEdit := aItem[ CFG_FCONTROL ]
            ENDIF
         ENDIF
      ENDIF
   NEXT
   ::ButtonSaveOn()
   GUI():SetFocus( ::xDlg, oFirstEdit )

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

   LOCAL aItem, nSelect, xValue, cText, xScope, nLenScope, xValueControl, aControl
   LOCAL aCommonList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_DATEPICKER, TYPE_SPINNER }

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
#ifdef DLGAUTO_AS_LIB
            WITH OBJECT aItem[ CFG_FCONTROL ]
               :oRs:CloseRecordset()
               :oRs:cSQL := "SELECT * FROM " + aItem[ CFG_BRWTABLE ] + ;
                  " WHERE " + aItem[ CFG_BRWKEYTO ] + ;
                  " = "
               FOR EACH aControl IN ::aControlList
                  IF aControl[ CFG_FNAME ] == aItem[ CFG_BRWKEYFROM ]
                     :oRs:cSQL += hb_ValToExp( gui():ControlGetValue( ::xDlg, aControl[ CFG_FCONTROL ] ) )
                     EXIT
                  ENDIF
               NEXT
               :oRs:Execute()
               :aArrayData := Array( :oRs:RecordCount() )
               GUI():BrowseRefresh( ::xDlg, aItem[ CFG_FCONTROL ] )
            ENDWITH
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

   LOCAL aItem, xValue
   LOCAL aCommonList := { TYPE_TEXT, TYPE_MLTEXT, TYPE_DATEPICKER, TYPE_SPINNER }

   IF Empty( ::cDataTable ) // no data source
      RETURN Nil
   ENDIF
   ::EditOff()
   IF RLock()
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
            fieldput( FieldNum( aItem[ CFG_FNAME ] ), xValue )
         CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
            xValue := GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
            DO CASE
            CASE aItem[ CFG_FTYPE ] == "L"
            CASE aItem[ CFG_FTYPE ] == "N"; xValue := iif( xValue, 1, 0 )
            CASE aItem[ CFG_FTYPE ] == "C"; xValue := iif( xValue, "Y", "N" )
            ENDCASE
            FieldPut( FieldNum( aItem[ CFG_FNAME ] ), xValue )
         CASE hb_AScan( aCommonList, { | e | e == aItem[ CFG_CTLTYPE ] } ) == 0 // not "value"
         CASE aItem[ CFG_ISKEY ]
         OTHERWISE
            xValue := GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
            FieldPut( FieldNum( aItem[ CFG_FNAME ] ), xValue )
         ENDCASE
      NEXT
      SKIP 0
      UNLOCK
   ENDIF
   ::cSelected := "NONE"

   RETURN Nil

METHOD Exit_Click() CLASS frm_Class

   LOCAL aItem

   IF ::lIsSQL
      FOR EACH aItem IN ::aControlList
         IF aItem[ CFG_CTLTYPE ] == TYPE_BROWSE
            aItem[ CFG_FCONTROL ]:oRs:CloseRecordset()
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

#ifndef DLGAUTO_AS_LIB

FUNCTION ADOLocal()

   RETURN Nil

FUNCTION NumberSQL( x )

   RETURN hb_ValToExp( x )

FUNCTION DateSQL( x )

   RETURN StringSQL( hb_Dtoc( x, "YYYY-MM-DD" ) )

FUNCTION StringSQL( x )

   x := StrTran( x, ['], [\'] )

   RETURN ['] + x + [']

#endif
