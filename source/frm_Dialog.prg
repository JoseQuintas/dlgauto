/*
frm_Dialog - create the dialog for data
*/

#include "frm_class.ch"

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

   ::oDlg := "FRM" + ::cFileDBF
   CreateDialog( @::oDlg, 0, 0, ::nDlgWidth, ::nDlgHeight, ::cTitle, { || ::UpdateEdit() } )
   ::CreateControls()
   ActivateDialog( ::oDlg )
   CLOSE DATABASES

   RETURN Nil