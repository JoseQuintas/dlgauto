/*
frm_preview - preview of report
*/

#include "directry.ch"
#include "frm_class.ch"

FUNCTION frm_Preview( cFileMask )

   LOCAL aFileList, nIndex
   LOCAL oDlg, oEdit
   LOCAL cCaption

   aFileList := Directory( cFileMask )
   nIndex := 1

   oDlg := frm_Class():New()
   oDlg:oDlg := "frm_Preview"
   oDlg:cOptions := ""
   oDlg:aOptionList := { ;
      { "First",    { || Button_Click( cCaption, aFileList, @nIndex, oDlg:oDlg, oEdit ) } }, ;
      { "Previous", { || Button_Click( cCaption, aFileList, @nIndex, oDlg:oDlg, oEdit ) } }, ;
      { "Next",     { || Button_Click( cCaption, aFileList, @nIndex, oDlg:oDlg, oEdit ) } }, ;
      { "Last",     { || Button_Click( cCaption, aFileList, @nIndex, oDlg:oDlg, oEdit ) } } }

   CreateDialog( @oDlg:oDlg, 0, 0, 800, 600, "Preview", { || frm_SetText( oEdit, aFileList, nIndex, oDlg:oDlg ) } )
   frm_Buttons( oDlg, .F. )
   CreateMLTextbox( oDlg:oDlg, @oEdit, 10, 65, oDlg:nDlgWidth - 40, oDlg:nDlgHeight - 100, "" )
   ActivateDialog( oDlg:oDlg )

   RETURN Nil

STATIC FUNCTION frm_SetText( oEdit, aFileList, nIndex, xDlg )

   LOCAL cTxt

   IF Len( aFileList ) == 0
      cTxt := ""
   ELSE
      cTxt := MemoRead( aFileList[ nIndex, F_NAME ] )
   ENDIF
   UpdateTextbox( xDlg, oEdit, cTxt )

   RETURN Nil

STATIC FUNCTION Button_Click( cCaption, aFileList, nIndex, xDlg, oEdit )

   DO CASE
   CASE cCaption == "First"
      nIndex := 1
      frm_SetText( oEdit, aFileList, nIndex, xDlg )
   CASE cCaption == "Previous"
      IF nIndex > 1
         nIndex -= 1
      ENDIF
      frm_SetText( oEdit, aFileList, nIndex, xDlg )
   CASE cCaption == "Next"
      IF nIndex < Len( aFileList )
         nIndex += 1
      ENDIF
      frm_SetText( oEdit, aFileList, nIndex, xDlg )
   CASE cCaption == "Last"
      nIndex := Len( aFileList )
      frm_SetText( oEdit, aFileList, nIndex, xDlg )
   CASE cCaption == "Exit"
      CloseDlg( xDlg )
   ENDCASE

   RETURN Nil
