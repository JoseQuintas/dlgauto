/*
test - main program
*/
REQUEST DBFCDX
REQUEST HB_CODEPAGE_PTISO

#include "hbclass.ch"
#include "directry.ch"
#include "dbstruct.ch"
#include "frm_class.ch"
#include "hbgtinfo.ch"

MEMVAR lLogin, cUser, cPass
MEMVAR pGenPrg, pGenName

#ifdef DLGAUTO_AS_LIB
   PROCEDURE DlgAuto
#else
   PROCEDURE Main
#endif

   LOCAL aAllSetup, lMakeLogin

   PRIVATE lLogin := .F., cUser := "", cPass := "", pGenPrg := "", pGenName := "code"

   SET CONFIRM ON
   SET CENTURY ON
   SET DATE    BRITISH
   SET DELETED ON
   SET EPOCH TO Year( Date() ) - 90
   SET EXCLUSIVE OFF
   SET FILECASE LOWER
   SET DIRCASE  LOWER
   Set( _SET_CODEPAGE, "PTISO" )

   //GUI():MsgBox( hb_gtInfo( HB_GTI_VERSION ) )

   GUI():Init()
   RddSetDefault( "DBFCDX" )

   aAllSetup := test_LoadSetup( @lMakeLogin )

   IF lMakeLogin
      Test_DlgLogin()
      IF ! lLogin
         RETURN
      ENDIF
   ENDIF

   test_DlgMenu( @aAllSetup )

#ifndef DLGAUTO_AS_LIB
   hb_MemoWrit( pGenName + ".txt", pGenPrg )
#endif

   RETURN

FUNCTION gui_MsgDebug( ... )

   LOCAL aList, cText := "", xValue

   aList := hb_AParams()
   FOR EACH xValue IN aList
      cText += hb_ValToExp( xValue ) + iif( xValue:__EnumIsLast(), "", hb_Eol() )
   NEXT

   RETURN GUI():Msgbox( cText )

FUNCTION RGB2N( r, g, b )

   IF ValType( r ) == "A"
      g := r[ 2 ]
      b := r[ 3 ]
      r := r[ 1 ]
   ENDIF

   RETURN r + ( g * 256 ) + ( b * 256 * 256 )

FUNCTION N2RGB( n )

   LOCAL r, g, b

   r := n % 256
   g := int( n / 256 ) % 256
   b := int( n / 256 / 256 )

   RETURN { r, g, b }

#ifndef DLGAUTO_AS_LIB
#ifdef HBMK_HAS_GTWVG

PROCEDURE HB_GTSYS

   REQUEST HB_GT_WVG_DEFAULT
   REQUEST HB_GT_WVG

   RETURN
#endif
#endif
