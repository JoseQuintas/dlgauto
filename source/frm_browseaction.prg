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

   LOCAL oFrm, nPos, aItem, nSelect

   nSelect := Select()
   oFrm := frm_Class():New()
   WITH OBJECT oFrm
      :cFileDbf    := aItemOld[ CFG_BRWTABLE ]
      :cTitle      := gui_LibName() + " - BROWSE " + :cFileDbf + "KEY:" + Ltrim( Str( nkey ) )
      :cOptions    := "S"
      :lNavigate   := .F.
      :lSingleEdit := .T.
      :lModal      := .T.
      :nLayout     := oFrmOld:nLayout
      :aAllSetup   := AClone( oFrmOld:aAllSetup )

       nPos := hb_ASCan( :aAllSetup, { | e | e[ 1 ] == aItemOld[ CFG_BRWTABLE ] } )
      :aEditList := :aAllSetup[ nPos, 2 ]
      FOR EACH aItem IN oFrm:aEditList
         DO CASE
         CASE aItem[ CFG_FNAME ] == aItemOld[ CFG_BRWKEYTO ]
            aItem[ CFG_SAVEONLY ] := .T.
            aItem[ CFG_VALUE ] := ( nSelect )->( FieldGet( FieldNum( aItemOld[ CFG_BRWKEYFROM ] ) ) )
         CASE aItem[ CFG_FNAME ] == aItemOld[ CFG_BRWKEYTO2 ]
            aItem[ CFG_SAVEONLY ] := .T.
            aItem[ CFG_VALUE ] := FieldGet( FieldNum( aItem[ CFG_FNAME ] ) )
          ENDCASE
      NEXT
      :Execute()
   ENDWITH
   SELECT ( nSelect )

   RETURN Nil

// CFG_BRWKEYTO   CFG_SAVEONLY for related key fields - setup initial value
// CFG_BRWKEYTO2  INCREMENTAL
