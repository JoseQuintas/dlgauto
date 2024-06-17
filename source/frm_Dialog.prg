/*
frm_Dialog - create the dialog for data
*/

#include "frm_class.ch"
#include "inkey.ch"

FUNCTION frm_Dialog( Self )

   LOCAL aItem, aFile

   SELECT ( Select( ::cFileDbf ) )
   USE
   IF ! Empty( ::cFileDbf )
      USE ( ::cFileDBF )
   ENDIF
   IF hb_ASCan( ::aEditList, { | e | e[ CFG_ISKEY ] } ) != 0
      SET INDEX TO ( ::cFileDBF )
   ENDIF
   FOR EACH aItem IN ::aEditList
      IF ! Empty( aItem[ CFG_VTABLE ] ) .AND. Select( aItem[ CFG_VTABLE ] ) == 0
         // dbfs for code validation
         SELECT ( Select( aItem[ CFG_VTABLE ] ) )
         USE
         USE ( aItem[ CFG_VTABLE ] )
         SET INDEX TO ( aItem[ CFG_VTABLE ] )
         SET ORDER TO 1
      ENDIF
      IF ! Empty( aItem[ CFG_BRWTABLE ] ) .AND. Select( aItem[ CFG_BRWTABLE ] ) == 0
         // dbfs for browse
         SELECT ( Select( aItem[ CFG_BRWTABLE ] ) )
         USE
         USE ( aItem[ CFG_BRWTABLE ] )
         SET INDEX TO ( aItem[ CFG_BRWTABLE ] )
         SET ORDER TO 1
      ENDIF
   NEXT
   // dbfs for code in use validation
   FOR EACH aFile IN ::aAllSetup
      FOR EACH aItem IN aFile[ 2 ]
         IF aItem[ CFG_VTABLE ] == ::cFileDBF .AND. Select( aFile[ 1 ] ) == 0
            SELECT ( Select( aFile[ 1 ] ) )
            USE
            USE ( aFile[ 1 ] )
            SET INDEX TO ( aFile[ 1 ] )
            SET ORDER TO 1
         ENDIF
      NEXT
   NEXT
   IF ! Empty( ::cFileDbf )
      SELECT ( Select( ::cFileDbf ) )
   ENDIF
   FOR EACH aItem IN ::aEditList
      IF aItem[ CFG_CTLTYPE ] == TYPE_ADDBUTTON
         AAdd( ::aOptionList, { aItem[ CFG_CAPTION ], aItem[ CFG_ACTION ] } )
      ENDIF
   NEXT

   gui_DialogCreate( @::xDlg, 0, 0, APP_DLG_WIDTH, APP_DLG_HEIGHT, ::cTitle,, ::lModal, { || ::DlgInit() } )
   ::CreateControls()
   gui_DialogActivate( ::xDlg, { || ::DlgInit() } )

#ifdef HBMK_HAS_GTWVG
   DO WHILE Inkey(1) != K_ESC
   ENDDO
#endif
   // nested calls can't close databases
   // IF gui_LibName() != "FIVEWIN"
   //    CLOSE DATABASES
   // ENDIF

   RETURN Nil
