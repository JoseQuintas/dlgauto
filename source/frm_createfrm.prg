#include "frm_class.ch"

FUNCTION frm_CreateFrm( Self )

   LOCAL aItem

   SELECT 0
   USE ( ::cFileDBF )
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

#ifdef THIS_HWGUI
   INIT DIALOG ::oDlg CLIPPER NOEXIT TITLE ::cTitle ;
      AT 0, 0 SIZE ::nDlgWidth, ::nDlgHeight ;
      BACKCOLOR COLOR_BACK ;
      ON EXIT hwg_EndDialog() ;
      ON INIT { || ::UpdateEdit() }
   ::CreateControls()
   ACTIVATE DIALOG ::oDlg CENTER
#endif
#ifdef THIS_HMGE_OR_OOHG
   ::oDlg := "FRM" + ::cFileDBF
   DEFINE WINDOW ( ::oDlg ) ;
      AT 1000, 500 ;
      WIDTH ::nDlgWidth ;
      HEIGHT ::nDlgHeight ;
      TITLE ::cFileDBF ;
      MODAL ;
      ON INIT ::UpdateEdit()

      ::CreateControls()

   END WINDOW
   ( ::oDlg ).CENTER
   ( ::oDlg ).ACTIVATE
#endif
#ifdef THIS_OOHG_OOP
   WITH OBJECT ::oDlg := TForm():Define()
      :Row := 500
      :Col := 1000
      :Width := ::nDlgWidth
      :Height := ::nDlgHeight
      :Title := ::cFileDbf
      // :Init := ::UpdateEdit()
   ENDWITH
    _EndWindow()
      ::CreateControls()
   ::oDlg:Center()
   ::oDlg:Activate()
#endif
   CLOSE DATABASES

   RETURN Nil
