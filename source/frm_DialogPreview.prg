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
   oFrm:lNavigate := .F.
   oFrm:aOptionList := { ;
      { "First",    { || Button_Click( "First",    aFileList, @nIndex, oFrm:xDlg, oEdit ) } }, ;
      { "Previous", { || Button_Click( "Previous", aFileList, @nIndex, oFrm:xDlg, oEdit ) } }, ;
      { "Next",     { || Button_Click( "Next",     aFileList, @nIndex, oFrm:xDlg, oEdit ) } }, ;
      { "Last",     { || Button_Click( "Last",     aFileList, @nIndex, oFrm:xDlg, oEdit ) } } }

   GUI():DialogCreate( oFrm, @oFrm:xDlg, 0, 0, GUI():FormWidth(), GUI():FormHeight(), "Preview", { || frm_SetText( oEdit, aFileList, nIndex, oFrm:xDlg ) } )
   frm_ButtonCreate( oFrm )
   GUI():MLTextCreate( oFrm:xDlg, oFrm:xDlg, @oEdit, 65, 10, GUI():FormWidth() - 40, GUI():FormHeight() - 120, "" )
   GUI():DialogActivate( oFrm:xDlg, { || frm_SetText( oEdit, aFileList, nIndex, oFrm:xDlg ) } )

   RETURN Nil

STATIC FUNCTION frm_SetText( oEdit, aFileList, nIndex, xDlg )

   LOCAL cTxt

   IF Len( aFileList ) == 0
      cTxt := ""
   ELSE
      cTxt := MemoRead( aFileList[ nIndex, F_NAME ] )
   ENDIF
   GUI():ControlSetValue( xDlg, oEdit, cTxt )

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
      GUI():DialogClose( xDlg )
   ENDCASE

   RETURN Nil
