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
   LOCAL aKeyList, aSeekList, aBrowseList, aBrowse, nPos

   SET CONFIRM OFF
   SET DATE    BRITISH
   SET DELETED ON
   SET EPOCH TO Year( Date() ) - 90
   SET EXCLUSIVE OFF
   SET FILECASE LOWER
   SET DIRCASE  LOWER
#ifdef DLGAUTO_AS_LIB
   #ifdef HBMK_HAS_HMGE
      Init()
   #endif
#endif
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
      { "DBCLIENT",  "CLSTATE",   "DBSTATE",   "IDSTATE",   "" }, ;
      { "DBPRODUCT", "IEUNIT",    "DBUNIT",    "IDUNIT",    "UNNAME" }, ;
      { "DBSTOCK",   "STCLIENT",  "DBCLIENT",  "IDCLIENT",  "CLNAME" }, ;
      { "DBSTOCK",   "STPRODUCT", "DBPRODUCT", "IDPRODUCT", "PRNAME" }, ;
      { "DBSTOCK",   "STGROUP",   "DBGROUP",   "IDGROUP",   "GRNAME" }, ;
      { "DBFINANC",  "FICLIENT",  "DBCLIENT",  "IDCLIENT",  "CLNAME" }, ;
      { "DBFINANC",  "FIBANK",    "DBBANK",    "IDBANK",    "BANAME" } }

   /* Related browse */
   aBrowseList := { ;
      { "DBTICKET", "IDTICKET", "DBTICKETPRO", 2, "TPTICKET", "IDTICKEDPRO", .F. }, ;
      { "DBDBF",    "NAME",     "DBFIELDS",    2, "DBF",  "IDFIELD", .F. } , ;
      { "DBCLIENT", "IDCLIENT", "DBSTOCK",     2, "STCLIENT", "IDSTOCK", .F. }, ;
      { "DBCLIENT", "IDCLIENT", "DBFINANC",    2, "FICLIENT", "IDFINANC", .T. }, ;
      { "DBCLIENT", "IDCLIENT", "DBTICKET",    2, "TICLIENT", "IDTICKET", .F. } }

   aAllSetup := {}
   aList := Directory( "*.dbf" )
   FOR EACH aFile IN aList
      aFile[ F_NAME ] := Upper( hb_FNameName( aFile[ F_NAME ] ) )
      cFile := aFile[ F_NAME ]
      AAdd( aAllSetup, { cFile, {}, Nil } )
      USE ( cFile )
      aStru := dbStruct()
      FOR EACH aField IN aStru
         aItem := CFG_EMPTY
         aItem[ CFG_FNAME ]    := aField[ DBS_NAME ]
         aItem[ CFG_FTYPE ]    := aField[ DBS_TYPE ]
         aItem[ CFG_FLEN ]     := aField[ DBS_LEN ]
         aItem[ CFG_FDEC ]     := aField[ DBS_DEC ]
         aItem[ CFG_VALUE ]    := aField[ DBS_NAME ]
         aItem[ CFG_CAPTION ]  := aField[ DBS_NAME ]
         aItem[ CFG_FPICTURE ] := PictureFromValue( aItem )
         /* is key */
         IF hb_ASCan( aKeyList, { | e | e[1] == cFile .AND. e[2] == aItem[ CFG_FNAME ] } ) != 0
            aItem[ CFG_ISKEY ] := .T.
         ENDIF
         /* to search */
         IF ( nSeekPos := hb_ASCan( aSeekList, { | e | e[1] == cFile .AND. e[2] == aItem[ CFG_FNAME ] } ) ) != 0
            aItem[ CFG_VTABLE ] := aSeekList[ nSeekPos, 3 ]
            aItem[ CFG_VFIELD ] := aSeekList[ nSeekPos, 4 ]
            aItem[ CFG_VSHOW ]  := aSeekList[ nSeekPos, 5 ]
         ENDIF
         AAdd( Atail( aAllSetup )[ 2 ], aItem )
      NEXT
      /* in browse */
      FOR EACH aBrowse IN aBrowseList
         IF aBrowse[ 1 ] == cFile
            aItem := CFG_EMPTY
            aItem[ CFG_CTLTYPE ]   := TYPE_BROWSE
            aItem[ CFG_BKEYFROM ]  := aBrowse[ 2 ]
            aItem[ CFG_BTABLE ]    := aBrowse[ 3 ]
            aItem[ CFG_BINDEXORD ] := aBrowse[ 4 ]
            aItem[ CFG_BKEYTO ]    := aBrowse[ 5 ]
            aItem[ CFG_BKEYTO2 ]   := aBrowse[ 6 ]
            aItem[ CFG_BVALUE ]    := FieldGet( FieldNum( aItem[ CFG_BKEYFROM  ] ) )
            aItem[ CFG_BEDIT ]     := aBrowse[ 7 ]
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
   frm_MainMenu( @aAllSetup )

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
