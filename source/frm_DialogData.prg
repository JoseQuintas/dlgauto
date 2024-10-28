/*
frm_DialogData - create the dialog for data
part of frm_class
*/

#include "frm_class.ch"
#include "inkey.ch"

FUNCTION frm_DialogData( Self )

   LOCAL aItem

   IF ! ::lIsSQL()
      frm_DialogOpenDbf( Self )
   ENDIF
   FOR EACH aItem IN ::aEditList
      IF aItem[ CFG_CTLTYPE ] == TYPE_ADDBUTTON
         AAdd( ::aOptionList, { aItem[ CFG_CAPTION ], aItem[ CFG_ACTION ] } )
      ENDIF
   NEXT

   GUI():DialogCreate( Self, @::xDlg, 0, 0, APP_DLG_WIDTH, APP_DLG_HEIGHT, ::cTitle, { || ::EventInit() }, ::lModal, ::xParent )
   ::CreateControls()
   GUI():DialogActivate( ::xDlg, { || ::EventInit() }, ::lModal )

#ifndef DLGAUTO_AS_LIB
   IF GUI():Libname() == "GTWVG"
      DO WHILE Inkey(1) != K_ESC
      ENDDO
   ENDIF
#endif
   // nested dialogs can't close databases
   // CLOSE DATABASES

   RETURN Nil

FUNCTION frm_DialogOpenDbf( Self )

   LOCAL aFile, aItem

   SELECT ( Select( ::cDataTable ) )
   USE
   IF ! Empty( ::cDataTable )
      USE ( ::cDataTable )
   ENDIF
   IF hb_ASCan( ::aEditList, { | e | e[ CFG_ISKEY ] } ) != 0
      SET INDEX TO ( ::cDataTable )
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
         IF aItem[ CFG_VTABLE ] == ::cDataTable .AND. Select( aFile[ 1 ] ) == 0
            SELECT ( Select( aFile[ 1 ] ) )
            USE
            USE ( aFile[ 1 ] )
            SET INDEX TO ( aFile[ 1 ] )
            SET ORDER TO 1
         ENDIF
      NEXT
   NEXT
   IF ! Empty( ::cDataTable )
      SELECT ( Select( ::cDataTable ) )
   ENDIF

   RETURN Nil
