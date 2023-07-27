REQUEST DBFCDX

#include "directry.ch"
#include "dbstruct.ch"
#include "dlgauto.ch"

PROCEDURE Main()

   LOCAL aAllSetup, aList, aFile, aField, aStru, cFile, aItem, aDBF

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
         AAdd( Atail( aAllSetup )[ 2 ], CFG_EDITEMPTY )
         Atail( Atail( aAllSetup )[ 2 ] )[ CFG_NAME ] := aField[ DBS_NAME ]
         Atail( Atail( aAllSetup )[ 2 ] )[ CFG_VALTYPE ] := aField[ DBS_TYPE ]
         Atail( Atail( aAllSetup )[ 2 ] )[ CFG_LEN ] := aField[ DBS_LEN ]
         Atail( Atail( aAllSetup )[ 2 ] )[ CFG_DEC ] := aField[ DBS_DEC ]
         Atail( Atail( aAllSetup )[ 2 ] )[ CFG_CAPTION ] := aField[ DBS_NAME ]
         DO CASE
         CASE ! cFile == "ACCOUNT"
         CASE aField[ DBS_NAME ] == "IDPRODUCT"
            ATail( Atail( aAllSetup )[ 2 ] )[ CFG_VTABLE ] := "PRODUCT"
            ATail( Atail( aAllSetup )[ 2 ] )[ CFG_VFIELD ] := "IDPRODUCT"
            ATail( Atail( aAllSetup )[ 2 ] )[ CFG_VSHOW ] := "NAME"
         CASE aField[ DBS_NAME ] == "IDPEOPLE"
            ATail( Atail( aAllSetup )[ 2 ] )[ CFG_VTABLE ] := "PEOPLE"
            ATail( Atail( aAllSetup )[ 2 ] )[ CFG_VFIELD ] := "IDPEOPLE"
            ATail( Atail( aAllSetup )[ 2 ] )[ CFG_VSHOW ] := "NAME"
         ENDCASE
      NEXT
      USE
   NEXT
   FOR EACH aDBF IN aAllSetup
      FOR EACH aItem IN aDBF[ 2 ]
         IF ! Empty( aItem[ CFG_VTABLE ] )
            USE ( aDBF[ 1 ] )
            aItem[ CFG_VVALUE ] := Space( FieldLen( aItem[ CFG_VSHOW ] ) )
            USE
         ENDIF
      NEXT
   NEXT
   DlgAutoMenu( @aAllSetup )

   RETURN

FUNCTION AppVersaoExe(); RETURN ""
FUNCTION AppUserName(); RETURN ""
