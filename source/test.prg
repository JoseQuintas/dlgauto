/*
test - main program
*/
REQUEST DBFCDX

#include "hbclass.ch"
#include "directry.ch"
#include "dbstruct.ch"
#include "frm_class.ch"

#ifdef DLGAUTO_AS_LIB
   PROCEDURE DlgAuto()
#else
   PROCEDURE Main()
#endif

   LOCAL aAllSetup, aList, aFile, aField, aStru, cFile, aItem, aDBF, nKeyPos, nSeekPos
   LOCAL aKeyList, aSeekList, aBrowseList, aBrowse, nPos, aComboList, aCheckList
   LOCAL aDatePickerList, aSpinnerList, cFieldName

   SET CONFIRM OFF
   SET CENTURY ON
   SET DATE    BRITISH
   SET DELETED ON
   SET EPOCH TO Year( Date() ) - 90
   SET EXCLUSIVE OFF
   SET FILECASE LOWER
   SET DIRCASE  LOWER
   gui_Init()
   RddSetDefault( "DBFCDX" )
   test_DBF()
   /* table, key, browse index */
   aKeyList := { ;
      { "DBCLIENT",    "IDCLIENT", 2 }, ;
      { "DBPRODUCT",   "IDPRODUCT", 2 }, ;
      { "DBUNIT",      "IDUNIT", 2 }, ;
      { "DBSELLER",    "IDSELLER", 2 }, ;
      { "DBBANK",      "IDBANK", 2 }, ;
      { "DBGROUP",     "IDGROUP", 2 }, ;
      { "DBSTOCK",     "IDSTOCK" }, ;
      { "DBFINANC",    "IDFINANC" }, ;
      { "DBSTATE",     "IDSTATE", 2 }, ;
      { "DBTICKET",    "IDTICKET" }, ;
      { "DBTICKETPRO", "IDTICKETPRO" }, ;
      { "DBDBF",       "IDDBF", 2 }, ;
      { "DBFIELDS",    "IDFIELD", 2 } }

   /* table, field, table to search, key field, field to show */
   aSeekList := { ;
      { "DBCLIENT",  "CLSELLER",  "DBSELLER",  "IDSELLER",  "SENAME" }, ;
      { "DBCLIENT",  "CLBANK",    "DBBANK",    "IDBANK",    "BANAME" }, ;
      { "DBTICKET",  "TICLIENT",  "DBCLIENT",  "IDCLIENT",  "CLNAME" }, ;
      { "DBCLIENT",  "CLSTATE",   "DBSTATE",   "IDSTATE",   "STNAME" }, ;
      { "DBPRODUCT", "IEUNIT",    "DBUNIT",    "IDUNIT",    "UNNAME" }, ;
      { "DBSTOCK",   "STCLIENT",  "DBCLIENT",  "IDCLIENT",  "CLNAME" }, ;
      { "DBSTOCK",   "STPRODUCT", "DBPRODUCT", "IDPRODUCT", "PRNAME" }, ;
      { "DBSTOCK",   "STGROUP",   "DBGROUP",   "IDGROUP",   "GRNAME" }, ;
      { "DBFINANC",  "FICLIENT",  "DBCLIENT",  "IDCLIENT",  "CLNAME" }, ;
      { "DBFINANC",  "FIBANK",    "DBBANK",    "IDBANK",    "BANAME" } }

   /* Related browse */
   aBrowseList := { ;
      { "DBTICKET", "IDTICKET", "DBTICKETPRO", 2, "TPTICKET", "IDTICKEDPRO", .F., "PROD LIST" }, ;
      { "DBDBF",    "NAME",     "DBFIELDS",    2, "DBF",  "IDFIELD", .F., "DBF LIST" } , ;
      { "DBCLIENT", "IDCLIENT", "DBFINANC",    2, "FICLIENT", "IDFINANC", .T., "FINANC LIST" }, ;
      { "DBCLIENT", "IDCLIENT", "DBSTOCK",     2, "STCLIENT", "IDSTOCK", .F., "STOCK LIST" }, ;
      { "DBCLIENT", "IDCLIENT", "DBTICKET",    2, "TICLIENT", "IDTICKET", .F., "TICKET LIST" } }

   /* Combotext */
   aComboList := { ;
      { "DBCLIENT", "CLSTATE", { "AC", "RS", "SP", "RJ", "PR", "RN" } } }

   /* checkbox */
   aCheckList := { ;
      { "DBCLIENT", "CLSTATUS" } }

   /* datepicker */
   aDatePickerList := { ;
      { "DBCLIENT", "CLDATE" }, ;
      { "DBFINANC", "FIDATTOPAY" } }

   /* spinner */
   aSpinnerList := { ;
      { "DBCLIENT", "CLPAYTERM", { 0, 120 } } }

   aAllSetup := {}
   aList := Directory( "*.dbf" )
   FOR EACH aFile IN aList
      aFile[ F_NAME ] := Upper( hb_FNameName( aFile[ F_NAME ] ) )
      cFile := aFile[ F_NAME ]
      AAdd( aAllSetup, { cFile, {}, Nil } )
      USE ( cFile )
      aStru := dbStruct()
      FOR EACH aField IN aStru
         aItem := EmptyFrmClassItem()
         aItem[ CFG_CTLTYPE ]  := TYPE_TEXT
         aItem[ CFG_FNAME ]    := aField[ DBS_NAME ]
         aItem[ CFG_FTYPE ]    := aField[ DBS_TYPE ]
         aItem[ CFG_FLEN ]     := aField[ DBS_LEN ]
         aItem[ CFG_FDEC ]     := aField[ DBS_DEC ]
         aItem[ CFG_VALUE ]    := FieldGet( aField:__EnumIndex )
         aItem[ CFG_CAPTION ]  := aField[ DBS_NAME ]
         aItem[ CFG_FPICTURE ] := PictureFromValue( aItem )
         cFieldName := aItem[ CFG_FNAME ]
         /* is key */
         IF hb_ASCan( aKeyList, { | e | e[1] == cFile .AND. e[2] == cFieldName } ) != 0
            aItem[ CFG_ISKEY ] := .T.
         ENDIF
         /* to search */
         IF ( nPos := hb_ASCan( aSeekList, { | e | e[1] == cFile .AND. e[2] == cFieldName } ) ) != 0
            aItem[ CFG_VTABLE ] := aSeekList[ nPos, 3 ]
            aItem[ CFG_VFIELD ] := aSeekList[ nPos, 4 ]
            aItem[ CFG_VSHOW ]  := aSeekList[ nPos, 5 ]
         ENDIF
         /* combotext */
         IF ( nPos := hb_Ascan( aComboList, { | e | e[1] == cFile .AND. e[2] == cFieldName } ) ) != 0
            aItem[ CFG_COMBOLIST ] := aComboList[ nPos, 3 ]
            aItem[ CFG_CTLTYPE ] := TYPE_COMBOBOX
         ENDIF
         /* checkbox */
         IF hb_Ascan( aCheckList, { | e | e[1] == cFile .AND. e[2] == aItem[ CFG_FNAME ] } ) != 0
            aItem[ CFG_CTLTYPE ] := TYPE_CHECKBOX
         ENDIF
         /* datepicker */
         IF hb_Ascan( aDatePickerList, { | e | e[1] == cFile .AND. e[2] == cFieldName } ) != 0
            aItem[ CFG_CTLTYPE ] := TYPE_DATEPICKER
         ENDIF
         /* spinner */
         IF ( nPos := hb_Ascan( aSpinnerList, { | e | e[1] == cFile .AND. e[2] == cFieldName } ) ) != 0
            aItem[ CFG_SPINNER ] := aSpinnerList[ nPos, 3 ]
            aItem[ CFG_CTLTYPE ] := TYPE_SPINNER
         ENDIF

         AAdd( Atail( aAllSetup )[ 2 ], aItem )
      NEXT
      /* in browse */
      FOR EACH aBrowse IN aBrowseList
         IF aBrowse[ 1 ] == cFile
            aItem := EmptyFrmClassItem()
            aItem[ CFG_CTLTYPE ]    := TYPE_BROWSE
            aItem[ CFG_BRWKEYFROM ] := aBrowse[ 2 ]
            aItem[ CFG_BRWTABLE ]   := aBrowse[ 3 ]
            aItem[ CFG_BRWIDXORD ]  := aBrowse[ 4 ]
            aItem[ CFG_BRWKEYTO ]   := aBrowse[ 5 ]
            aItem[ CFG_BRWKEYTO2 ]  := aBrowse[ 6 ]
            aItem[ CFG_BRWVALUE ]   := FieldGet( FieldNum( aItem[ CFG_BRWKEYFROM  ] ) )
            aItem[ CFG_BRWEDIT ]    := aBrowse[ 7 ]
            IF Len( aBrowse) > 7
               aItem[ CFG_BRWTITLE ] := aBrowse[ 8 ]
            ELSE
               aItem[ CFG_BRWTITLE ] := aItem[ CFG_BRWTABLE ] + " LIST"
            ENDIF
            AAdd( Atail( aAllSetup )[ 2 ], aItem )
         ENDIF
      NEXT
      USE
      nPos := hb_AScan( aKeyList, { | e | e[1] == cFile } )
      IF nPos != 0
         IF Len( aKeyList[ nPos ] ) > 2
            Atail( aAllSetup )[ 3 ] := aKeyList[ nPos, 3 ]
         ENDIF
      ENDIF
   NEXT
   /* retrieve size of VSHOW */
   FOR EACH aDBF IN aAllSetup
      FOR EACH aItem IN aDBF[ 2 ]
         IF ! Empty( aItem[ CFG_VTABLE ] )
            IF ( nKeyPos := hb_AScan( aAllSetup, { | e | e[ 1 ] == aItem[ CFG_VTABLE ] } ) ) != 0
               IF ( nSeekPos := hb_AScan( aAllSetup[ nKeyPos, 2 ], { | e | e[ CFG_FNAME ] == aItem[ CFG_VSHOW ] } ) ) != 0
                  aItem[ CFG_VLEN ] := aAllSetup[ nKeyPos, 2, nSeekPos, CFG_FLEN ]
               ENDIF
            ENDIF
         ENDIF
      NEXT
   NEXT

   test_DlgMenu( @aAllSetup )

   RETURN

STATIC FUNCTION PictureFromValue( oValue )

   LOCAL cPicture, cType, nLen, nDec

   cType := oValue[ CFG_FTYPE ]
   nLen  := oValue[ CFG_FLEN ]
   nDec  := oValue[ CFG_FDEC ]
   DO CASE
   CASE cType == "D"
      cPicture := "@D"
   CASE cType == "N"
      cPicture := Replicate( "9", nLen - nDec )
      IF nDec != 0
         cPicture += "." + Replicate( "9", nDec )
      ENDIF
   CASE cType == "M"
      cPicture := "@S100"
   CASE cType == "C"
      cPicture := iif( nLen > 100, "@S100", "@X" )
   ENDCASE

   RETURN cPicture

FUNCTION AppVersaoExe(); RETURN ""
FUNCTION AppUserName(); RETURN ""

/* above functions not in use, for tests purpose */

/*
FUNCTION AppVersaoExe(); RETURN ""
FUNCTION AppUserName(); RETURN ""

FUNCTION AppConexao()

   STATIC cnConexao

   IF Empty( cnConexao )
      cnConexao := win_OleCreateObject( "ADODB.Connection" )
   ENDIF

   RETURN cnConexao

FUNCTION ADOLocal()

   LOCAL cnSQL

   cnSQL := ADOClass():New()
   cnSQL:cn := AppConexao()

   RETURN cnSQL

CREATE CLASS ADOClass
   VAR  cn
   VAR rs
   METHOD Open() INLINE Nil
   METHOD CloseRecordset() INLINE Nil
   METHOD CloseConnection() INLINE Nil
   METHOD Execute() INLINE Nil
   METHOD ExecuteNoReturn() INLINE Nil
   METHOD QueryCreate() INLINE Nil
   METHOD QueryAdd() INLINE Nil
   METHOD QueryExecuteInsert() INLINE Nil
   METHOD QueryExecuteUpdate() INLINE Nil
   ENDCLASS
*/

#ifdef HBMK_HAS_GTWVG

PROCEDURE HB_GTSYS

   REQUEST HB_GT_WVG_DEFAULT
   REQUEST HB_GT_WVG

   RETURN
#endif
