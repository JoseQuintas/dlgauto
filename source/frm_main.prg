/*
frm_main - dialog for each data and main use of class
*/

#include "hbclass.ch"
#include "directry.ch"
#include "frm_class.ch"

FUNCTION frm_main( cDBF, aAllSetup )

   LOCAL oFrm, nPos

   oFrm := ThisDlg():New()
   oFrm:cFileDBF   := cDBF
   oFrm:cTitle     := "test of " + cDBF
   oFrm:cOptions   := "IEDP"
   oFrm:lWithTab   := .F.
   oFrm:nEditStyle := 1 // from 1 to 3
   AAdd( oFrm:aOptionList, { "Mail", { || Nil } } )
   AAdd( oFrm:aOptionList, { "CtlList",  { || oFrm:ShowCtlList() } } )

   nPos := hb_ASCan( aAllSetup, { | e | e[ 1 ] == cDBF } )

   oFrm:aEditList := aAllSetup[ nPos, 2 ]
   oFrm:Execute()

   RETURN Nil

CREATE CLASS ThisDlg INHERIT frm_Class

   METHOD ShowCtlList()

   ENDCLASS

METHOD ShowCtlList() CLASS ThisDlg

#ifdef HBMK_HAS_HWGUI
   LOCAL oControl, cTxt := "", cTxtTmp := ""

   FOR EACH oControl IN ::oDlg:aControlList
      IF Len( cTxtTmp ) > 500
         cTxt += cTxtTmp + hb_Eol()
         cTxtTmp := ""
      ENDIF
      cTxtTmp += oControl[ CFG_FCONTROL ]:winClass + " " // static não tem id // Ltrim( Str( oControl[2]:id ) ) + " "
   NEXT
   cTxt += cTxtTmp
   hwg_MsgInfo( cTxt )
#endif

   RETURN Nil
