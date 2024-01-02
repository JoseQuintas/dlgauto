/*
frm_preview - preview of report
*/

#include "directry.ch"
#include "frm_class.ch"

FUNCTION frm_Preview( cFileMask )

   LOCAL aFileList, nIndex
   LOCAL oFrm, oEdit := "EditPreview"

   aFileList := Directory( cFileMask )
   nIndex := 1

   oFrm := frm_Class():New()
   oFrm:cOptions := ""
   oFrm:aOptionList := { ;
      { "First",    { || Button_Click( "First",    aFileList, @nIndex, oFrm:xDlg, oEdit ) } }, ;
      { "Previous", { || Button_Click( "Previous", aFileList, @nIndex, oFrm:xDlg, oEdit ) } }, ;
      { "Next",     { || Button_Click( "Next",     aFileList, @nIndex, oFrm:xDlg, oEdit ) } }, ;
      { "Last",     { || Button_Click( "Last",     aFileList, @nIndex, oFrm:xDlg, oEdit ) } } }

   gui_DialogCreate( @oFrm:xDlg, 0, 0, oFrm:nDlgWidth, oFrm:nDlgHeight, "Preview", { || frm_SetText( oEdit, aFileList, nIndex, oFrm:xDlg ) } )
   frm_Buttons( oFrm, .F. )
   gui_MLTextCreate( oFrm:xDlg, @oEdit, 65, 10, oFrm:nDlgWidth - 40, oFrm:nDlgHeight - 120, "" )
   gui_DialogActivate( oFrm:xDlg )

   RETURN Nil

STATIC FUNCTION frm_SetText( oEdit, aFileList, nIndex, xDlg )

   LOCAL cTxt

   IF Len( aFileList ) == 0
      cTxt := ""
   ELSE
      cTxt := MemoRead( aFileList[ nIndex, F_NAME ] )
   ENDIF
   gui_TextSetValue( xDlg, oEdit, cTxt )

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
      gui_DialogClose( xDlg )
   ENDCASE

   RETURN Nil
