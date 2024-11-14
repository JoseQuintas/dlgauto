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
#include "set.ch"

MEMVAR lLogin, cUser, cPass
MEMVAR pGenPrg

#ifdef DLGAUTO_AS_LIB
   PROCEDURE DlgAuto
#else
   PROCEDURE Main
#endif

   LOCAL aAllSetup, lMakeLogin

   PRIVATE lLogin := .F., cUser := "", cPass := ""
   PUBLIC pGenPrg := ""

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
      frm_DialogLogin()
      IF ! lLogin
         RETURN
      ENDIF
   ENDIF

   frm_DialogMenu( @aAllSetup )

   IF .F.
      hb_MemoWrit( "code.txt", pGenPrg )
   ENDIF

   RETURN

FUNCTION gui_MsgDebug( ... )

   LOCAL aList, cText := "", xValue, nCont, nCont2

   aList := hb_AParams()
   FOR EACH xValue IN aList
      cText += hb_ValToExp( xValue ) + iif( xValue:__EnumIsLast(), "", hb_Eol() )
   NEXT
   cText += hb_Eol()
   nCont  := 1
   nCont2 := 0
   DO WHILE nCont2 < 5
      IF Empty( ProcName( nCont ) )
         nCont2++
      ELSE
         cText += "Called from " + Trim( ProcName( nCont ) ) + "(" + Ltrim( Str( ProcLine( nCont ) ) ) + ")" + hb_Eol()
      ENDIF
      nCont++
   ENDDO

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

FUNCTION DlgAuto_ShowDefault()

   LOCAL cText := ""

   cText += "date:" + hb_ValToExp( Set( _SET_DATEFORMAT ) ) + hb_Eol()
   cText += "cpd:" + hb_ValToExp( Set( _SET_CODEPAGE ) ) + hb_Eol()
   cText += "decimals: " + hb_ValToExp( Set( _SET_DECIMALS ) ) + hb_Eol()
   GUI():MsgBox( cText )

   RETURN Nil
