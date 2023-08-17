/*
lib_hmge - HMG Extended source code - included in frm_gui
*/

#include "frm_class.ch"

STATIC nNumControl := 1

FUNCTION gui_MsgGeneric( cText )

   RETURN Msgbox( cText )

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      (xDlg); (xControl)

      RETURN .F.

FUNCTION gui_GetTextBoxValue( xDlg, xControl )

   (xDlg)

   RETURN GetProperty( xDlg, xControl, "VALUE" )

FUNCTION gui_CreateTab( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := "Control" + StrZero(nNumControl,10)
      nNumControl += 1
   ENDIF
   // no tab
   xControl := xDlg
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION gui_CreatePanel( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := "Control" + StrZero(nNumControl,10)
      nNumControl += 1
   ENDIF
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION gui_ActivateDialog( xDlg )

   DoMethod( xDlg, "CENTER" )
   ACTIVATE WINDOW ( xDlg )

   RETURN Nil

FUNCTION gui_CreateDialog( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bAction )

   IF Empty( xDlg )
      xDlg := "Control" + StrZero(nNumControl,10)
      nNumControl += 1
   ENDIF

   DEFINE WINDOW ( xDlg ) ;
      AT nCol, nRow ;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      TITLE cTitle ;
      MODAL ;
      ON INIT Eval( bAction )
   END WINDOW

   RETURN Nil

FUNCTION gui_CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := "Control" + StrZero(nNumControl,10)
      nNumControl += 1
   ENDIF
   DEFINE EDITBOX ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth
      HEIGHT nHeight
      VALUE xValue
      TOOLTIP 'EditBox'
      NOHSCROLLBAR .T.
   END EDITBOX

   RETURN Nil

FUNCTION gui_CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   IF Empty( xControl )
      xControl := "Control" + StrZero(nNumControl,10)
      nNumControl += 1
   ENDIF
   (bValid)
   DEFINE TEXTBOX ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      HEIGHT    nHeight
      WIDTH     nWidth
      FONTNAME DEFAULT_FONTNAME
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
      ON LOSTFOCUS Eval( bValid )
   END TEXTBOX

   RETURN Nil

FUNCTION gui_CloseDialog( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_SetFocus( xDlg, xControl )

   DoMethod( xDlg, xControl, "SETFOCUS" )

   RETURN Nil

FUNCTION gui_EnableTextbox( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_EnableButton( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := "Control" + StrZero(nNumControl,10)
      nNumControl += 1
   ENDIF
   // n�o mostra borda
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

FUNCTION gui_CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF Empty( xControl )
      xControl := "Control" + StrZero(nNumControl,10)
      nNumControl += 1
   ENDIF
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
      FONTNAME    DEFAULT_FONTNAME
      FONTSIZE    9
      FONTBOLD    .T.
      FONTCOLOR   COLOR_BLACK
      VERTICAL   .T.
      BACKCOLOR  COLOR_WHITE
      FLAT       .T.
      NOXPSTYLE  .T.
   END BUTTONEX

   RETURN Nil

FUNCTION gui_SetTextboxValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )

   RETURN Nil

FUNCTION gui_SetLabelValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

FUNCTION gui_Browse( nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue )

   (nRow);(nCol);(nWidth);(nHeight);(oTBrowse);(cField);(xValue)

   RETURN Nil

