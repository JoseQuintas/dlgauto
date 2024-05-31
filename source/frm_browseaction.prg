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

   LOCAL oFrm, nPos, nSelect, nRecNo

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
      IF nKey == VK_INSERT
         SELECT ( Select( aItemOld[ CFG_BRWTABLE ] ) )
         nRecNo := RecNo()
         GOTO BOTTOM // fail, SET SCOPE is activated
         :aInitValue2 := { aItemOld[ CFG_BRWKEYTO2 ], ( aItemOld[ CFG_BRWTABLE ] )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYTO2 ] ) ) ) + 1 }
         GOTO ( nRecNo )
         SELECT ( nSelect )
         gui_MsgBox( :aInitValue2[ 2 ] )
      ELSE
         :aInitValue2 := { aItemOld[ CFG_BRWKEYTO2 ], ( aItemOld[ CFG_BRWTABLE ] )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYTO2 ] ) ) ) }
      ENDIF
      DO CASE
      CASE nKey == VK_INSERT; :cOptions := "IS" ; :bActivate := { || :Insert() }
      CASE nKey == VK_DELETE; :cOptions := "D" // :bActivate := { || :Delete() }
      CASE nKey == VK_RETURN; :cOptions := "ES"; :bActivate := { || :Edit() }
      ENDCASE
      :Execute()
   ENDWITH
   SELECT ( nSelect )
   GOTO ( nRecNo )
   gui_SetFocus( oFrmOld:xDlg )

   RETURN Nil

// CFG_BRWKEYTO   CFG_SAVEONLY for related key fields - setup initial value
// CFG_BRWKEYTO2  INCREMENTAL
