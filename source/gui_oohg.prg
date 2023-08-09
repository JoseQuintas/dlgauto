#include "frm_class.ch"

FUNCTION oohg_CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   (xDlg)
   (xControl)
   (nRow)
   (nCol)
   (nWidth)
   (nHeight)
   (xValue)

   RETURN Nil

FUNCTION oohg_CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   (bValid)
   (cPicture)
   DEFINE TEXTBOX ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      HEIGHT    nHeight
      WIDTH     nWidth
      FONTNAME "verdana"
      IF ValType( xValue ) == "N"
         NUMERIC .T.
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
      ELSE
         MAXLENGTH nMaxLength
      ENDIF
      VALUE     xValue
      ON CHANGE Nil
   END TEXTBOX

   RETURN Nil

   // not confirmed
   // WITH OBJECT aItem[ CFG_FCONTROL ] := TText():Define()
   //    :Row    := nRow2
   //    :Col    := nCol2
   //    :Width  := aItem[ CFG_FLEN ] * 12
   //    :Height := ::nLineHeight
   //    :Value  := aItem[ CFG_VALUE ]
   // ENDWITH

FUNCTION oohg_CloseDlg( xDlg )

   DoMethod( xDlg, "Release" )

   RETURN Nil

FUNCTION oohg_SetFocus( xDlg, xControl )

   (xDlg)
   (xControl)
   xControl:SetFocus()

   RETURN Nil

FUNCTION oohg_EnableTextbox( xDlg, xControl, lEnable )

   (xDlg)
   (xControl)
   (lEnable)

   RETURN Nil

FUNCTION oohg_EnableButton( xDlg, xControl, lEnable )

   (xDlg)
   (xControl)
   (lEnable)

   RETURN Nil

FUNCTION oohg_CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   (xDlg)
   (lBorder)
   WITH OBJECT xControl := TLabel():Define()
      :Row := nRow
      :Col := nCol
      :Value := xValue
      :AutoSize := .T.
      :Width := nWidth
      :Height := nHeight
      //:Border := lBorder
   ENDWITH

   RETURN Nil

FUNCTION oohg_CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   ( xDlg )

   @ nRow, nCol BUTTON ( xControl ) ;
      CAPTION  cCaption ;
      PICTURE  cResName ;
      ACTION   Eval( bAction ) ;
      WIDTH    nWidth ;
      HEIGHT   nHeight ;
      WINDRAW

   RETURN Nil

FUNCTION oohg_UpdateTextBox( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )

   RETURN Nil

FUNCTION oohg_UpdateLabel( xDlg, xControl, xValue )

   IF .F.
      SetProperty( xDlg, xControl, "VALUE", xValue )
   ENDIF

   RETURN Nil
