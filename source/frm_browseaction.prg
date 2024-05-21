/*
frm_browseaction - action for browse
*/

#include "frm_class.ch"
#ifndef VK_INSERT
   #define VK_INSERT  45
   #define VK_DELETE  46
   #define VK_RETURN  13
#endif

FUNCTION frm_BrowseAction( aItemOld, nKey, oFrmOld )

   LOCAL oFrm, nPos, nSelect

   nSelect := Select()
   oFrm := frm_Class():New()
   WITH OBJECT oFrm
      :cFileDbf    := aItemOld[ CFG_BRWTABLE ]
      :cTitle      := gui_LibName() + " - BROWSE " + :cFileDbf
      :cOptions    := "S"
      :lNavigate   := .F.
      :lModal      := .T.
      :nLayout     := oFrmOld:nLayout
      :aAllSetup   := AClone( oFrmOld:aAllSetup )

      nPos := hb_ASCan( :aAllSetup, { | e | e[ 1 ] == aItemOld[ CFG_BRWTABLE ] } )
      :aEditList   := :aAllSetup[ nPos, 2 ]
      :nInitRecno  := RecNo()
      :aInitValue1 := { aItemOld[ CFG_BRWKEYTO ],  ( oFrmOld:cFileDbf )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYFROM ] ) ) ) }
      :aInitValue2 := { aItemOld[ CFG_BRWKEYTO2 ], ( nSelect )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYTO2 ] ) ) ) }
      DO CASE
      CASE nKey == VK_INSERT; :bActivate := { || :Insert() }
      CASE nKey == VK_DELETE; :bActivate := { || :Delete() }
      CASE nKey == VK_RETURN; :bActivate := { || :Edit() }
      ENDCASE
      :Execute()
   ENDWITH
   SELECT ( nSelect )
   gui_SetFocus( oFrmOld:xDlg )

   RETURN Nil

// CFG_BRWKEYTO   CFG_SAVEONLY for related key fields - setup initial value
// CFG_BRWKEYTO2  INCREMENTAL
