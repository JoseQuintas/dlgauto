/*
frm_browse - browse
*/

#include "frm_class.ch"

FUNCTION frm_Browse( Self, xDlg, xControl, cTable )

   LOCAL oTBrowse := {}, aField, xValue, cField, nSelect, nPos, oThisFrm

   nSelect := Select()
   SELECT ( cTable )

   nPos := hb_Ascan( ::aAllSetup, { | e | e[1] == cTable } )
   FOR EACH aField IN ::aAllSetup[ nPos, 2 ]
      AAdd( oTBrowse, { aField[ CFG_CAPTION ], { || Transform( FieldGet(FieldNum(aField[ CFG_FNAME ])), aField[ CFG_FPICTURE ] ) } } )
      IF aField[ CFG_ISKEY ]
         cField := aField[ CFG_FNAME ]
      ENDIF
   NEXT

   oThisFrm := frm_Class():New()
   oThisFrm:cOptions := ""
   gui_CreateDialog( @oThisFrm:oDlg, 0, 0, ::nDlgWidth, ::nDlgHeight, cTable, { || Nil } )
   frm_Buttons( oThisFrm, .F. )

   gui_Browse( 70, 5, oThisFrm:nDlgWidth - 10, oThisFrm:nDlgHeight - 80, oTbrowse, cField, @xValue )

   gui_ActivateDialog( oThisFrm:oDlg )

   IF ! Empty( xValue ) .AND. ! Empty( xControl )
      gui_SetTextboxValue( xDlg, xControl, xValue )
   ENDIF

   SELECT ( nSelect )
   (xDlg)

   RETURN Nil
