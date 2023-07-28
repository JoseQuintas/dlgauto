REQUEST DBFCDX

#include "directry.ch"
#include "dbstruct.ch"
#include "dlgauto.ch"

// not in use, only a note: #ifdef HBMK_HAS_HMGE || ! USER_ROUTINE

PROCEDURE Main()

   LOCAL aAllSetup, aList, aFile, aField, aStru, cFile, aItem, aDBF, nPos1, nPos2

   SET EXCLUSIVE OFF
#ifdef HBMK_HAS_HMGE
   SET OOP ON
#endif
   RddSetDefault( "DBFCDX" )
   DlgAutoDBF( @aAllSetup )

   aAllSetup := {}
   aList := Directory( "*.dbf" )
   FOR EACH aFile IN aList
      aFile[ F_NAME ] := Upper( hb_FNameName( aFile[ F_NAME ] ) )
      cFile := aFile[ F_NAME ]
      AAdd( aAllSetup, { cFile, {} } )
      USE ( cFile )
      aStru := dbStruct()
      FOR EACH aField IN aStru
         aItem := CFG_EDITEMPTY
         aItem[ CFG_NAME ]    := aField[ DBS_NAME ]
         aItem[ CFG_VALTYPE ] := aField[ DBS_TYPE ]
         aItem[ CFG_LEN ]     := aField[ DBS_LEN ]
         aItem[ CFG_DEC ]     := aField[ DBS_DEC ]
         aItem[ CFG_VALUE ]   := aField[ DBS_NAME ]
         aItem[ CFG_CAPTION ] := aField[ DBS_NAME ]
         /* above retrieve value from related dbf */
         DO CASE
         CASE cFile == "PRODUCT" .AND. aField[ DBS_NAME ] == "IDPRODUCT"
            aItem[ CFG_KEY ] := .T.
         CASE cFile == "PEOPLE" .AND. aField[ DBS_NAME ] == "IDPEOPLE"
            aItem[ CFG_KEY ] := .T.
         CASE ! cFile == "ACCOUNT"
         CASE aField[ DBS_NAME ] == "IDACCOUNT"
            aItem[ CFG_KEY ] := .T.
         CASE aField[ DBS_NAME ] == "IDPRODUCT"
            aItem[ CFG_VTABLE ] := "PRODUCT"
            aItem[ CFG_VFIELD ] := "IDPRODUCT"
            aItem[ CFG_VSHOW ]  := "NAME"
         CASE aField[ DBS_NAME ] == "IDPEOPLE"
            aItem[ CFG_VTABLE ] := "PEOPLE"
            aItem[ CFG_VFIELD ] := "IDPEOPLE"
            aItem[ CFG_VSHOW ]  := "NAME"
         ENDCASE
         AAdd( Atail( aAllSetup )[ 2 ], aItem )
      NEXT
      USE
   NEXT
   FOR EACH aDBF IN aAllSetup
      FOR EACH aItem IN aDBF[ 2 ]
         IF ! Empty( aItem[ CFG_VTABLE ] )
            IF ( nPos1 := hb_AScan( aAllSetup, { | e | e[ 1 ] == aItem[ CFG_VTABLE ] } ) ) != 0
               nPos2 := hb_AScan( aAllSetup[ nPos1, 2 ], { | e | e[ CFG_NAME ] == aItem[ CFG_VSHOW ] } )
               IF nPos2 != 0
                  aItem[ CFG_VVALUE ] := Space( aAllSetup[ nPos1, 2, nPos2, CFG_LEN ] )
               ENDIF
            ENDIF
         ENDIF
      NEXT
   NEXT
   DlgAutoMenu( @aAllSetup )

   RETURN

FUNCTION AppVersaoExe(); RETURN ""
FUNCTION AppUserName(); RETURN ""
