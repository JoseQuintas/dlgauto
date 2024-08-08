/*
frm_main - dialog for each data and main use of class
*/

#include "hbclass.ch"
#include "directry.ch"
#include "frm_class.ch"
#include "inkey.ch"

FUNCTION frm_main( cDBF, aAllSetup, lModal, xParent )

   LOCAL oFrm, nPos

   hb_Default( @lModal, .F. )

#ifdef HBMK_HAS_GTWVG
   SetMode(30,100)
   SetColor("W/B")
   CLS
#endif

   oFrm := frm_Class():New()
   oFrm:cFileDBF   := cDBF
   oFrm:xParent    := xParent
#ifdef HBMK_HAS_GTWVG
   oFrm:xDlg := wvgSetAppWindow()
#endif
   oFrm:cTitle     := cDBF
   oFrm:cOptions   := "IEDP"
   oFrm:aAllSetup  := aAllSetup
   oFrm:lModal     := lModal

   nPos := hb_ASCan( aAllSetup, { | e | e[ 1 ] == cDBF } )

   oFrm:aEditList := aAllSetup[ nPos, 2 ]
   oFrm:Execute()

   RETURN Nil
