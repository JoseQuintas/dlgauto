/*
frm_main - dialog for each data and main use of class
*/

#include "hbclass.ch"
#include "directry.ch"
#include "frm_class.ch"
#include "inkey.ch"

FUNCTION frm_main( cDBF, aAllSetup, lModal )

   LOCAL oFrm, nPos

   hb_Default( @lModal, .F. )
#ifdef HBMK_HAS_GTWVG
   hb_gtReload( "WVG" )  // do not use WGU
   SetMode(30,100)
   SetColor("W/B")
   CLS
#endif

   oFrm := frm_Class():New()
   oFrm:cFileDBF   := cDBF
#ifdef HBMK_HAS_GTWVG
   oFrm:xDlg := wvgSetAppWindow()
#endif
   oFrm:cTitle     := gui_LibName() + " - " + cDBF
   oFrm:cOptions   := "IEDP"
   oFrm:aAllSetup  := aAllSetup
   oFrm:lModal     := lModal
   //AAdd( oFrm:aOptionList, { "Mail", { || Nil } } ) // example of aditional button
   //AAdd( oFrm:aOptionList, { "client", { || frm_Main( "DBCLIENT", ( oFrm:aAllSetup ), .T. ) } } )

   nPos := hb_ASCan( aAllSetup, { | e | e[ 1 ] == cDBF } )

   oFrm:aEditList := aAllSetup[ nPos, 2 ]
   oFrm:Execute()

   RETURN Nil
