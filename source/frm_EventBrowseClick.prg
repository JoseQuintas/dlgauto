/*
frm_EventBrowseClick - action for browse
part of frm_class
*/

#include "frm_class.ch"
#ifndef VK_INSERT
   #define VK_INSERT  45
   #define VK_DELETE  46
   #define VK_RETURN  13
#endif

FUNCTION frm_EventBrowseClick( oFrmOld, aItemOld, nKey )

   LOCAL oFrm, nPos, cAliasAnt, aOrdScope

   oFrm := frm_Class():New()
   WITH OBJECT oFrm
      :cDataTable  := aItemOld[ CFG_BRWTABLE ]
      :cTitle      := "BROWSE " + :cDataTable
      :cOptions    := "S"
      :lNavigate   := .F.
      :lModal      := .T.
      :nLayout     := oFrmOld:nLayout
      :aAllSetup   := AClone( oFrmOld:aAllSetup )
      :lIsSQL      := oFrmOld:lIsSQL
      IF ! :lIsSQL
         cAliasAnt := Alias()
         SELECT ( Select( aItemOld[ CFG_BRWTABLE ] ) )
         aOrdScope := { OrdScope( 0 ), OrdScope( 1 ) }
      ENDIF

      nPos := hb_ASCan( :aAllSetup, { | e | e[ 1 ] == aItemOld[ CFG_BRWTABLE ] } )
      :aEditList   := :aAllSetup[ nPos, 2 ]
      IF ! :lIsSQL
         :nInitRecno  := ( aItemOld[ CFG_BRWTABLE ] )->( RecNo() )
         :aInitValue1 := { aItemOld[ CFG_BRWKEYTO ],  ( oFrmOld:cDataTable )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYFROM ] ) ) ) }
      ENDIF
      IF nKey == VK_INSERT
         IF ! :lIsSQL
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
         ENDIF
      ELSE
         :aInitValue2 := { aItemOld[ CFG_BRWKEYTO2 ], ( aItemOld[ CFG_BRWTABLE ] )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYTO2 ] ) ) ) }
      ENDIF
      DO CASE
      CASE nKey == VK_INSERT; :cOptions := "IS" ; AAdd( :EventInitList, { || :Insert_Click() } )
      CASE nKey == VK_DELETE; :cOptions := "D" // AAdd( :EventInitList, { || :Delete_Click() } )
      CASE nKey == VK_RETURN; :cOptions := "ES"; AAdd( :EventInitList, { || :Edit_Click() } )
      ENDCASE
      :Execute()
   ENDWITH
   IF ! oFrm:lIsSQL
      // return old position
      SELECT ( Select( aItemOld[ CFG_BRWTABLE ] ) )
      SET ORDER TO ( aItemOld[ CFG_BRWIDXORD ] )
      OrdScope( 0, aOrdScope[1] )
      OrdScope( 1, aOrdScope[2] )
      // return old alias
      SELECT ( Select( cAliasAnt ) )
   ENDIF
   GUI():SetFocus( oFrmOld:xDlg )

   RETURN Nil

// CFG_BRWKEYTO   CFG_SAVEONLY for related key fields - setup initial value
// CFG_BRWKEYTO2  INCREMENTAL
