/*
frm_funcMain - dialog for each data and main use of class
*/

#include "hbclass.ch"
#include "directry.ch"
#include "frm_class.ch"
#include "inkey.ch"

FUNCTION frm_funcMain( cDBF, aAllSetup, lModal, xParent )

   LOCAL oFrm, nPos

   hb_Default( @lModal, .F. )

#ifndef DLGAUTO_AS_LIB
#ifdef HBMK_HAS_GTWVG
   SetMode(30,100)
   SetColor("W/B")
   CLS
#endif
#endif

   oFrm := frm_Class():New()
   oFrm:cDataTable := cDBF
   oFrm:xParent    := xParent
#ifndef DLGAUTO_AS_LIB
#ifdef HBMK_HAS_GTWVG
   oFrm:xDlg := wvgSetAppWindow()
#endif
#endif
   oFrm:cTitle     := cDBF
   oFrm:cOptions   := "IEDP"
   oFrm:aAllSetup  := aAllSetup
   oFrm:lModal     := lModal

   nPos := hb_ASCan( aAllSetup, { | e | e[ 1 ] == cDBF } )

   oFrm:aEditList := aAllSetup[ nPos, 2 ]
   oFrm:Execute()

   RETURN oFrm
