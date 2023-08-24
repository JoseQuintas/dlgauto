/*
lib_gtwvg - gtwvg source selected by lib.prg
*/

#include "frm_class.ch"

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   ( xDlg );(xControl);(nRow);(nCol);(nWidth);(nHeight);(cCaption);(cResName);(bAction)
   xControl := wvgPushButton():New()
   WITH OBJECT xControl
      :PointerFocus := .F.
      :Style += BS_TOP
      :Create( xDlg,,{nCol,nRow},{nHeight,nWidth})
      :SetCaption( {, WVG_IMAGE_ICONRESOURCE, cResName } )
      :SetCaption( cCaption )
   ENDWITH

   RETURN Nil

FUNCTION gui_ButtonEnable( xDlg, xControl, lEnable )

   (xDlg);(xControl);(lEnable)

   RETURN Nil

FUNCTION gui_Browse( xDlg, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(OTbrowse);(cFIeld);(xValue);(workarea)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg )

   (xDlg)

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   (xDlg)
   xDlg:Destroy()
   QUIT

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bAction )

   xDlg := wvgSetAppWindow()
   //xDlg := wvgCrt():New()
   //xDlg:Create(,,{0,0},{30,100})
   //xDlg:lModal := .T.
   //xDlg:Show()
   //SetColor( "W/B" )
   //CLS
   (xDlg);(nRow);(nCol);(nWidth);(nHeight);(cTitle);(bAction)

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   (xDlg);(xControl)

   RETURN .F.

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(lBorder)
   xControl := wvgStatic():New()
   WITH OBJECT xControl
      :Type := WVGSTATIC_TYPE_TEXT
      :Options := WVGSTATIC_TEXT_LEFT
      :Style += iif( lBorder, WS_BORDER, 0 )
      :SetColorFG( "W/B" )
      :SetColorBG( "W/B" )
      :Caption := xValue
      :SetFont( "Arial" )
      :Create(xDlg,,{nCol,nRow},{nWidth,nHeight})
   ENDWITH

   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   (xDlg);(xControl);(xValue)

   RETURN Nil

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue)

   RETURN Nil

FUNCTION gui_MsgGeneric( cText )

   RETURN Alert( cText )

FUNCTION gui_PageBegin( xDlg, xControl, cText )

   (xDlg);(xControl);(cText)

   RETURN Nil

FUNCTION gui_PageEnd( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_PanelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_TabEnd()

   RETURN Nil

FUNCTION gui_TextGetValue( xDlg, xControl )

   (xDlg);(xControl)

   RETURN ""

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(cPicture);(nMaxLength);(bValid)
   xControl := wvgSle():New()
   WITH OBJECT xControl
      :Create( xDlg,,{nCol,nRow},{nWidth,nHeight})
      :SetData( Transform( xValue, "" ) )
   ENDWITH

   RETURN Nil

FUNCTION gui_SetFocus( xDlg, xControl )

   (xDlg);(xControl)

   RETURN Nil

FUNCTION gui_TextEnable( xDlg, xControl, lEnable )

   (xDlg);(xControl);(lEnable)

   RETURN Nil

FUNCTION gui_TextSetValue( xDlg, xControl, xValue )

   (xDlg);(xControl);(xValue)
   xControl:SetValue( xValue )

   RETURN Nil

PROCEDURE HB_GTSYS

   REQUEST HB_GT_WVG_DEFAULT
   REQUEST HB_GT_WVG

   RETURN