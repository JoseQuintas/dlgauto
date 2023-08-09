/*
frm_preview - preview of report
*/

#include "directry.ch"
#include "frm_class.ch"

FUNCTION frm_Preview( cFileMask )

   LOCAL aFileList, nIndex
   LOCAL oDlg, oEdit
   LOCAL cCaption
#ifdef CODE_HWGUI
   LOCAL oFont
#endif

   aFileList := Directory( cFileMask )
   nIndex := 1

   oDlg := frm_Class():New()
   oDlg:oDlg := "frm_Preview"
   oDlg:cOptions := ""
   oDlg:aOptionList := { ;
      { "First",    { || Button_Click( cCaption, aFileList, @nIndex, oDlg, oEdit ) } }, ;
      { "Previous", { || Button_Click( cCaption, aFileList, @nIndex, oDlg, oEdit ) } }, ;
      { "Next",     { || Button_Click( cCaption, aFileList, @nIndex, oDlg, oEdit ) } }, ;
      { "Last",     { || Button_Click( cCaption, aFileList, @nIndex, oDlg, oEdit ) } } }

#ifdef CODE_HWGUI
   oFont := HFont():Add( "Courier New", 0, -13 )
   INIT DIALOG oDlg:oDlg CLIPPER TITLE "Preview"  ;
      AT 0,0  SIZE 800, 600 ;
      ON INIT { || frm_SetText( oEdit, aFileList, nIndex ) }
#endif
#ifdef CODE_HMGE_OR_OOHG
   DEFINE WINDOW ( oDlg:oDlg ) ;
      AT 0, 0 ;
      WIDTH 800 ;
      HEIGHT 600 ;
      TITLE "Preview" ;
      MODAL
#endif
   frm_Buttons( oDlg, .F. )
#ifdef CODE_HWGUI
   @ 10, 65 EDITBOX oEdit CAPTION "" SIZE oDlg:nDlgWidth - 40, oDlg:nDlgHeight - 100 FONT oFont ;
       STYLE ES_MULTILINE + ES_AUTOVSCROLL + WS_VSCROLL + WS_HSCROLL

   ACTIVATE DIALOG oDlg:oDlg
#endif
#ifdef CODE_HMGE_OR_OOHG
   END WINDOW
   ( oDlg:oDlg ).CENTER
   ( oDlg:oDlg ).ACTIVATE
#endif

   RETURN Nil

STATIC FUNCTION frm_SetText( oEdit, aFileList, nIndex )

   LOCAL cTxt

   IF Len( aFileList ) == 0
      cTxt := ""
   ELSE
      cTxt := MemoRead( aFileList[ nIndex, F_NAME ] )
   ENDIF
   oEdit:Value := cTxt
   oEdit:Refresh()

   RETURN Nil

STATIC FUNCTION Button_Click( cCaption, aFileList, nIndex, oDlg, oEdit )

   DO CASE
   CASE cCaption == "First"
      nIndex := 1
      frm_SetText( oEdit, aFileList, nIndex )
   CASE cCaption == "Previous"
      IF nIndex > 1
         nIndex -= 1
      ENDIF
      frm_SetText( oEdit, aFileList, nIndex )
   CASE cCaption == "Next"
      IF nIndex < Len( aFileList )
         nIndex += 1
      ENDIF
      frm_SetText( oEdit, aFileList, nIndex )
   CASE cCaption == "Last"
      nIndex := Len( aFileList )
      frm_SetText( oEdit, aFileList, nIndex )
   CASE cCaption == "Exit"
#ifdef CODE_HWGUI
      oDlg:Close()
#endif
#ifdef CODE_HMGE_OR_OOHG
      DoMethod( "frmPreview", "Release" )
#endif
   ENDCASE

   ( oDlg )

   RETURN Nil
