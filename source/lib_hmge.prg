/*
lib_hmge - HMG Extended source code - included in frm_gui
*/

#include "frm_class.ch"

FUNCTION hmge_CreateTab( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   // no tab
   xControl := xDlg
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION hmge_CreatePanel( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION hmge_ActivateDialog( xDlg )

   DoMethod( xDlg, "CENTER" )
   ACTIVATE WINDOW ( xDlg )

   RETURN Nil

FUNCTION hmge_CreateDialog( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bAction )

   DEFINE WINDOW ( xDlg ) ;
      AT nCol, nRow ;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      TITLE cTitle ;
      MODAL ;
      ON INIT Eval( bAction )
   END WINDOW

   RETURN Nil

FUNCTION hmge_CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

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

FUNCTION hmge_CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

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

FUNCTION hmge_CloseDlg( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION hmge_SetFocusAny( xDlg, xControl )

   DoMethod( xDlg, xControl, "SETFOCUS" )

   RETURN Nil

FUNCTION hmge_EnableTextbox( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION hmge_EnableButton( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

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

FUNCTION hmge_SetTextboxValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )

   RETURN Nil

FUNCTION hmge_SetLabelValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil
