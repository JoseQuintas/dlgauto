/*
frm_main - dialog for each data and main use of class
*/

#include "hbclass.ch"
#include "directry.ch"
#include "frm_class.ch"

FUNCTION frm_main( cDBF, aAllSetup )

   LOCAL oFrm, nPos

   oFrm := frm_Class():New()
   oFrm:cFileDBF   := cDBF
   oFrm:cTitle     := "test of " + cDBF
   oFrm:cOptions   := "IEDP"
   oFrm:lWithTab   := .F.
   oFrm:nEditStyle := 3 // from 1 to 3
   oFrm:aAllSetup  := aAllSetup
   AAdd( oFrm:aOptionList, { "Mail", { || Nil } } )

   nPos := hb_ASCan( aAllSetup, { | e | e[ 1 ] == cDBF } )

   oFrm:aEditList := aAllSetup[ nPos, 2 ]
   oFrm:Execute()

   RETURN Nil
