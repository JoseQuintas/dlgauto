/*
test_LoadSetup - load all setup
*/

#include "frm_class.ch"
#include "dbstruct.ch"
#include "directry.ch"

FUNCTION Test_LoadSetup( lMakeLogin )

   LOCAL aKeyList := {}, aSeekList := {}, aBrowseList := {}, aTypeList := {}
   LOCAL aAllSetup, aList, aFile, aField, aStru, cFile, aItem, aDBF, nKeyPos, nSeekPos
   LOCAL cFieldName, aBrowse, nPos, aSetup, aAddOptionList, aButton

#ifdef DLGAUTO_AS_LIB
   LOCAL cTable, cnSQL := ADOLocal(), aFieldList, cField, xValue
#endif

#ifndef DLGAUTO_AS_LIB
   /* create dbfs */

   test_DBF()
#endif

   /* retrieve structure */

   aAllSetup := {}
   aList := Directory( "*.dbf" )
   FOR EACH aFile IN aList
      aFile[ F_NAME ] := Upper( hb_FNameName( aFile[ F_NAME ] ) )
      cFile := Upper( aFile[ F_NAME ] )
      AAdd( aAllSetup, { cFile, {}, Nil } )
      USE ( cFile )
      aStru := dbStruct()
      FOR EACH aField IN aStru
         aItem := EmptyFrmClassItem()
         aItem[ CFG_CTLTYPE ]  := TYPE_TEXT
         aItem[ CFG_FNAME ]    := Upper( aField[ DBS_NAME ] )
         aItem[ CFG_FTYPE ]    := aField[ DBS_TYPE ]
         aItem[ CFG_FLEN ]     := aField[ DBS_LEN ]
         aItem[ CFG_FDEC ]     := aField[ DBS_DEC ]
         aItem[ CFG_VALUE ]    := FieldGet( aField:__EnumIndex )
         aItem[ CFG_CAPTION ]  := aItem[ CFG_FNAME ]
         aItem[ CFG_FPICTURE ] := PictureFromValue( aItem )
         AAdd( Atail( aAllSetup )[ 2 ], aItem )
      NEXT
   NEXT

#ifdef DLGAUTO_AS_LIB

   WITH OBJECT cnSQL
      FOR EACH cTable IN :TableList()
         cTable := Upper( cTable )
         IF "XML" $ Upper( cTable )
            LOOP
         ENDIF
         AAdd( aAllSetup, { cTable, {}, Nil } )
         aFieldList := :FieldList( cTable )
         :Execute( "SELECT * FROM " + cTable + " LIMIT 1" )
         FOR EACH cField IN aFieldList
            aStru := :FStru( cField )
            aItem := EmptyFrmClassItem()
            aItem[ CFG_CTLTYPE ]  := TYPE_TEXT
            aItem[ CFG_FNAME ]    := Upper( aStru[ 1 ] )
            aItem[ CFG_FTYPE ]    := aStru[ 2 ]
            aItem[ CFG_FLEN ]     := aStru[ 3 ]
            aItem[ CFG_FDEC ]     := aStru[ 4 ]
            xValue := ""
            DO CASE
            CASE aItem[ CFG_FTYPE ] == "M"; xValue := Space(150)
            CASE aItem[ CFG_FTYPE ] == "N"; xValue := Val( "0" + iif( aItem[ CFG_FDEC ] == 0, "", "." + Replicate( "0", aItem[ CFG_FDEC ] ) ) )
            CASE aItem[ CFG_FTYPE ] == "C"; xValue := Space( aItem[ CFG_FLEN ] )
            CASE aItem[ CFG_FTYPE ] == "D"; xValue := Ctod("")
            ENDCASE
            aItem[ CFG_VALUE ] := xValue
            aItem[ CFG_CAPTION ]  := aStru[ 1 ]
            aItem[ CFG_FPICTURE ] := PictureFromValue( aItem )
            AAdd( Atail( aAllSetup )[ 2 ], aItem )
         NEXT
         cnSQL:CloseRecordset()
      NEXT
   ENDWITH
#endif

   /* load setup */
#ifdef DLGAUTO_AS_LIB
   aSetup := hb_JsonDecode( test_Setup() )
#else
   IF ! File( "dlgauto.json" )
      hb_MemoWrit( "dlgauto.json", test_Setup() )
   ENDIF
   aSetup := hb_JsonDecode( MemoRead( "dlgauto.json" ) )
#endif
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
      { "DBCLIENT", "History",  { || GUI():MsgBox( "History of changes, not available" ) } } }

   /* apply setup */

   FOR EACH aFile IN aAllSetup
      cFile := aFile[ 1 ]
      FOR EACH aItem IN aFile[ 2 ]
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
            // AAdd( Atail( aAllSetup )[ 2 ], aItem )
            AAdd( aFile[ 2 ], aItem )
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
            //AAdd( Atail( aAllSetup )[ 2 ], aItem )
            AAdd( aFile[ 2 ], aItem )
         ENDIF
      NEXT
      /* browse order for key */
      nPos := hb_AScan( aKeyList, { | e | e[1] == cFile } )
      IF nPos != 0
         IF Len( aKeyList[ nPos ] ) > 2
            //Atail( aAllSetup )[ 3 ] := aKeyList[ nPos, 3 ]
            aFile[ 3 ] := aKeyList[ nPos, 3 ]
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
#ifdef DLGAUTO_AS_LIB
   //hb_MemoWrit( "test.json", hb_JsonEncode( aAllSetup, .T. ) )
#endif

   RETURN aAllSetup

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

