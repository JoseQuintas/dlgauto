/*
test - main program
*/
REQUEST DBFCDX

#include "directry.ch"
#include "dbstruct.ch"
#include "frm_class.ch"

// not in use, only a note: #ifdef CODE_HMGE || ! USER_ROUTINE

PROCEDURE Main()

   LOCAL aAllSetup, aList, aFile, aField, aStru, cFile, aItem, aDBF, nPos1, nPos2

   SET EXCLUSIVE OFF
   SET EPOCH TO Year( Date() ) - 90
#ifdef CODE_HMGE
   SET OOP ON
   SET WINDOW MAIN OFF
#endif
   RddSetDefault( "DBFCDX" )
   frm_DBF()

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
         aItem[ CFG_FNAME ]    := aField[ DBS_NAME ]
         aItem[ CFG_FTYPE ]    := aField[ DBS_TYPE ]
         aItem[ CFG_FLEN ]     := aField[ DBS_LEN ]
         aItem[ CFG_FDEC ]     := aField[ DBS_DEC ]
         aItem[ CFG_VALUE ]    := aField[ DBS_NAME ]
         aItem[ CFG_CAPTION ]  := aField[ DBS_NAME ]
         aItem[ CFG_FPICTURE ] := PictureFromValue( aItem )
         /* above retrieve value from related dbf */
         DO CASE
         CASE cFile == "PRODUCT" .AND. aField[ DBS_NAME ] == "IDPRODUCT"
            aItem[ CFG_ISKEY ] := .T.
         CASE cFile == "PEOPLE" .AND. aField[ DBS_NAME ] == "IDPEOPLE"
            aItem[ CFG_ISKEY ] := .T.
         CASE ! cFile == "ACCOUNT"
         CASE aField[ DBS_NAME ] == "IDACCOUNT"
            aItem[ CFG_ISKEY ] := .T.
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
               nPos2 := hb_AScan( aAllSetup[ nPos1, 2 ], { | e | e[ CFG_FNAME ] == aItem[ CFG_VSHOW ] } )
               IF nPos2 != 0
                  aItem[ CFG_VLEN ] := aAllSetup[ nPos1, 2, nPos2, CFG_FLEN ]
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

FUNCTION AppVersaoExe(); RETURN ""
FUNCTION AppUserName(); RETURN ""
