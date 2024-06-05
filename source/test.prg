/*
test - main program
*/
REQUEST DBFCDX
REQUEST HB_CODEPAGE_PT850

#include "hbclass.ch"
#include "directry.ch"
#include "dbstruct.ch"
#include "frm_class.ch"

MEMVAR lLogin, cUser, cPass

#ifdef DLGAUTO_AS_LIB
   PROCEDURE DlgAuto()
#else
   PROCEDURE Main()
#endif

   LOCAL aKeyList := {}, aSeekList := {}, aBrowseList := {}, aTypeList := {}
   LOCAL aAllSetup, aList, aFile, aField, aStru, cFile, aItem, aDBF, nKeyPos, nSeekPos
   LOCAL cFieldName, aBrowse, nPos, aSetup, lMakeLogin, aAddOptionList, aButton
   PRIVATE lLogin := .F., cUser := "", cPass := ""

   SET CONFIRM OFF
   SET CENTURY ON
   SET DATE    BRITISH
   SET DELETED ON
   SET EPOCH TO Year( Date() ) - 90
   SET EXCLUSIVE OFF
   SET FILECASE LOWER
   SET DIRCASE  LOWER
   Set( _SET_CODEPAGE, "PT850" )
   gui_Init()
   RddSetDefault( "DBFCDX" )

   /* create dbfs */
   test_DBF()

   /* setup */

   IF ! File( "dlgauto.json" )
      hb_MemoWrit( "dlgauto.json", test_Setup() )
   ENDIF
   aSetup := hb_JsonDecode( MemoRead( "dlgauto.json" ) )
   IF ValType( aSetup ) == "A" // test if valid setup
      FOR EACH aItem IN aSetup
         DO CASE
         CASE ValType( aItem ) != "A"         // test if valid setup
         CASE Len( aItem ) != 2               // test if valid setup
         CASE ValType( aItem[ 2 ] ) != "A"    // test if valid setup
         CASE aItem[ 1 ] == "KEYLIST";        aKeyList        := aItem[ 2 ]
         CASE aItem[ 1 ] == "SEEKLIST";       aSeekList       := aItem[ 2 ]
         CASE aItem[ 1 ] == "BROWSELIST";     aBrowseList     := aItem[ 2 ]
         CASE aItem[ 1 ] == "TYPELIST";       aTypeList       := aItem[ 2 ]
         CASE aItem[ 1 ] == "LOGIN";          lMakeLogin      := aItem[ 2 ][ 1 ]
         ENDCASE
      NEXT
   ENDIF
   hb_Default( @lMakeLogin, .F. )

   /* another setup with codeblock, can't be on json */
   aAddOptionList := { ;
      { "DBCLIENT", "History",  { || gui_MsgBox( "History of changes, not available" ) } } }

   IF lMakeLogin
      Test_DlgLogin()
      IF ! lLogin
         RETURN
      ENDIF
   ENDIF

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
         /* TypeList */
         IF ( nPos := hb_Ascan( aTypeList, { | e | e[1] == cFile .AND. e[2] == cFieldName } ) ) != 0
            DO CASE
            CASE aTypeList[ nPos, 3 ] == "COMBOBOX"
               aItem[ CFG_COMBOLIST ] := AClone( aTypeList[ nPos, 4 ] )
               aItem[ CFG_CTLTYPE ] := TYPE_COMBOBOX
            CASE aTypeList[ nPos, 3 ] == "CHECKBOX"
               aItem[ CFG_CTLTYPE ] := TYPE_CHECKBOX
            CASE aTypeList[ nPos, 3 ] == "DATEPICKER"
               aItem[ CFG_CTLTYPE ] := TYPE_DATEPICKER
            CASE aTypeList[ nPos, 3 ] == "SPINNER"
               aItem[ CFG_SPINNER ] := AClone( aTypeList[ nPos, 4 ] )
               aItem[ CFG_CTLTYPE ] := TYPE_SPINNER
            ENDCASE
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
      /* extra button */
      FOR EACH aButton IN aAddOptionList
         IF aButton[1] == cFile
            aItem := EmptyFrmClassItem()
            aItem[ CFG_CTLTYPE ] := TYPE_ADDBUTTON
            aItem[ CFG_CAPTION ] := aButton[2]
            aItem[ CFG_ACTION ]  := aButton[3]
            AAdd( Atail( aAllSetup )[ 2 ], aItem )
         ENDIF
      NEXT
      /* browse order for key */
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

#ifdef HBMK_HAS_GTWVG

PROCEDURE HB_GTSYS

   REQUEST HB_GT_WVG_DEFAULT
   REQUEST HB_GT_WVG

   RETURN
#endif
