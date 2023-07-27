#include "hbclass.ch"
#include "directry.ch"
#include "dlgauto.ch"

PROCEDURE DlgAutoMain( cDBF, aAllSetup )

   Execute( cDBF, aAllSetup )

   RETURN

FUNCTION Execute( cDBF, aAllSetup )

   LOCAL oDlg, nPos

   oDlg := ThisDlg():New()
   oDlg:cFileDBF   := cDBF
   oDlg:cTitle     := "test of " + cDBF
   oDlg:cOptions   := "IEDP"
   oDlg:lWithTab   := .F.
   oDlg:nEditStyle := 3 // from 1 to 3
   AAdd( oDlg:aOptionList, { "Mail", { || Nil } } )
   AAdd( oDlg:aOptionList, { "CtlList",  { || oDlg:ShowCtlList() } } )
   AAdd( oDlg:aOptionList, { "ThisDlg", { || oDlg:ShowDlgName() } } )

   nPos := hb_ASCan( aAllSetup, { | e | e[ 1 ] == cDBF } )

   oDlg:aEditList := aAllSetup[ nPos, 2 ]
   oDlg:Execute()

   RETURN Nil

CREATE CLASS ThisDlg INHERIT DlgAutoData

   METHOD ShowCtlList()
   METHOD ShowDlgName()

   ENDCLASS

METHOD ShowCtlList() CLASS ThisDlg

#ifdef HBMK_HAS_HWGUI
   LOCAL oControl, cTxt := "", cTxtTmp := ""

   FOR EACH oControl IN ::oDlg:aControlList
      IF Len( cTxtTmp ) > 500
         cTxt += cTxtTmp + hb_Eol()
         cTxtTmp := ""
      ENDIF
      cTxtTmp += oControl[ CFG_OBJ ]:winClass + " " // static n�o tem id // Ltrim( Str( oControl[2]:id ) ) + " "
   NEXT
   cTxt += cTxtTmp
   hwg_MsgInfo( cTxt )
#endif

   RETURN Nil

METHOD ShowDlgName() CLASS ThisDlg

   RETURN Nil
