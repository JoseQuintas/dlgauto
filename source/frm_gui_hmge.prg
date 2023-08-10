/*
frm_gui_hmge - HMG Extended source code - included in frm_gui
*/

#include "frm_class.ch"

FUNCTION hmge_CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   (xDlg)
   (xControl)
   (nRow)
   (nCol)
   (nWidth)
   (nHeight)
   (xValue)

   RETURN Nil

FUNCTION hmge_CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   (bValid)
   DEFINE TEXTBOX ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      HEIGHT    nHeight
      WIDTH     nWidth
      FONTNAME "verdana"
      IF ValType( xValue ) == "N"
         NUMERIC .T.
         INPUTMASK cPicture
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
         DATEFORMAT cPicture
      ELSE
         MAXLENGTH nMaxLength
      ENDIF
      VALUE     xValue
      ON CHANGE Nil
   END TEXTBOX

   RETURN Nil

FUNCTION hmge_CloseDlg( xDlg )

   DoMethod( xDlg, "Release" )

   RETURN Nil

FUNCTION hmge_SetFocus( xDlg, xControl )

   (xDlg)
   (xControl)
   xControl:SetFocus()

   RETURN Nil

FUNCTION hmge_EnableTextbox( xDlg, xControl, lEnable )

   (xDlg)
   (xControl)
   (lEnable)

   RETURN Nil

FUNCTION hwgui_EnableButton( xDlg, xControl, lEnable )

   (xDlg)
   (xControl)
   (lEnable)

   RETURN Nil

FUNCTION hmge_CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   // não mostra borda
   //DEFINE LABEL ( xControl )
   //   PARENT ( xDlg )
   //   COL nCol
   //   ROW nRow
   //   WIDTH nWidth
   //   HEIGHT nHeight
   //   VALUE xValue
   //   BORDER lBorder
   //END LABEL

   IF lBorder
      @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight BORDER
   ELSE
      @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight
   ENDIF

   RETURN Nil

FUNCTION hmge_CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   DEFINE BUTTONEX ( xControl )
      PARENT ( xDlg )
      ROW         nRow
      COL         nCol
      WIDTH       nWidth
      HEIGHT      nHeight
      ICON        cResName
      IMAGEWIDTH  nWidth - 20
      IMAGEHEIGHT nHeight - 20
      CAPTION     cCaption
      ACTION      Eval( bAction )
      FONTNAME    "verdana"
      FONTSIZE    9
      FONTBOLD    .T.
      FONTCOLOR   GRAY
      VERTICAL   .T.
      BACKCOLOR  WHITE
      FLAT       .T.
      NOXPSTYLE  .T.
   END BUTTONEX

   RETURN Nil

FUNCTION hmge_UpdateTextBox( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )

   RETURN Nil

FUNCTION hmge_UpdateLabel( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil
