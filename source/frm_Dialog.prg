/*
frm_Dialog - create the dialog for data
*/

#include "frm_class.ch"
#include "inkey.ch"

FUNCTION frm_Dialog( Self )

   LOCAL aItem

   SELECT 0
   USE ( ::cFileDBF )
   IF hb_ASCan( ::aEditList, { | e | e[ CFG_ISKEY ] } ) != 0
      SET INDEX TO ( ::cFileDBF )
   ENDIF
   FOR EACH aItem IN ::aEditList
      IF ! Empty( aItem[ CFG_VTABLE ] )
         IF Select( aItem[ CFG_VTABLE ] ) == 0
            SELECT 0
            USE ( aItem[ CFG_VTABLE ] )
            SET INDEX TO ( aItem[ CFG_VTABLE ] )
            SET ORDER TO 1
         ENDIF
      ENDIF
   NEXT
   SELECT ( Select( ::cFileDbf ) )

   gui_DialogCreate( @::oDlg, 0, 0, ::nDlgWidth, ::nDlgHeight, ::cTitle, ;
      { || ::EditOff(), ::UpdateEdit() } )
   ::CreateControls()
   gui_DialogActivate( ::oDlg )
#ifdef HBMK_HAS_GTWVG
   DO WHILE Inkey(1) != K_ESC
   ENDDO
#endif
   CLOSE DATABASES

   RETURN Nil
