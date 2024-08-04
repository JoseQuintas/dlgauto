/*
frm_browseClick - action for browse
called from frm_class
*/

#include "frm_class.ch"
#ifndef VK_INSERT
   #define VK_INSERT  45
   #define VK_DELETE  46
   #define VK_RETURN  13
#endif

FUNCTION frm_BrowseClick( oFrmOld, aItemOld, nKey )

   LOCAL oFrm, nPos, cAliasAnt, aOrdScope

   cAliasAnt := Alias()
   SELECT ( Select( aItemOld[ CFG_BRWTABLE ] ) )
   aOrdScope := { OrdScope( 0 ), OrdScope( 1 ) }
   oFrm := frm_Class():New()
   WITH OBJECT oFrm
      :cFileDbf    := aItemOld[ CFG_BRWTABLE ]
      :cTitle      := "BROWSE " + :cFileDbf
      :cOptions    := "S"
      :lNavigate   := .F.
      :lModal      := .T.
      :nLayout     := oFrmOld:nLayout
      :aAllSetup   := AClone( oFrmOld:aAllSetup )

      nPos := hb_ASCan( :aAllSetup, { | e | e[ 1 ] == aItemOld[ CFG_BRWTABLE ] } )
      :aEditList   := :aAllSetup[ nPos, 2 ]
      :nInitRecno  := ( aItemOld[ CFG_BRWTABLE ] )->( RecNo() )
      :aInitValue1 := { aItemOld[ CFG_BRWKEYTO ],  ( oFrmOld:cFileDbf )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYFROM ] ) ) ) }
      IF nKey == VK_INSERT
         SELECT ( Select( aItemOld[ CFG_BRWTABLE ] ) )
         aOrdScope := { OrdScope( 0 ), OrdScope( 1 ) }
         SET SCOPE TO
         SET ORDER TO 1
         GOTO BOTTOM // fail, SET SCOPE is activated
         :aInitValue2 := { aItemOld[ CFG_BRWKEYTO2 ], ( aItemOld[ CFG_BRWTABLE ] )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYTO2 ] ) ) ) + 1 }
         SET ORDER TO ( aItemOld[ CFG_BRWIDXORD ] )
         OrdScope( 0, aOrdScope[1] )
         OrdScope( 1, aOrdScope[2] )
         GOTO ( LastRec() + 1 )
         SELECT ( Select( cAliasAnt ) )
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
   // return old position
   SELECT ( Select( aItemOld[ CFG_BRWTABLE ] ) )
   SET ORDER TO ( aItemOld[ CFG_BRWIDXORD ] )
   OrdScope( 0, aOrdScope[1] )
   OrdScope( 1, aOrdScope[2] )
   // return old alias
   SELECT ( Select( cAliasAnt ) )
   gui_SetFocus( oFrmOld:xDlg )

   RETURN Nil

// CFG_BRWKEYTO   CFG_SAVEONLY for related key fields - setup initial value
// CFG_BRWKEYTO2  INCREMENTAL
