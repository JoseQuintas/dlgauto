/*
lib_oohg - oohg source code included in frm_gui
*/

#include "frm_class.ch"

FUNCTION gui_PageEnd( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_PageBegin( xDlg, xControl, cText )

   (xDlg); (xControl); (cText)

   RETURN Nil

FUNCTION gui_MsgGeneric( cText )

   RETURN Msgbox( cText )

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      (xDlg); (xControl)

      RETURN .F.

FUNCTION gui_GetTextValue( xDlg, xControl )

   (xDlg)

   RETURN GetProperty( xDlg, xControl, "VALUE" )

FUNCTION gui_CreateTab( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_newctlname()
   ENDIF
   // no tab
   xControl := xDlg
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION gui_CreatePanel( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_newctlname()
   ENDIF
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION gui_ActivateDialog( xDlg )

   DoMethod( xDlg, "CENTER" )
   ACTIVATE WINDOW ( xDlg )

   RETURN Nil

FUNCTION gui_CreateDialog( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bAction )

   IF Empty( xDlg )
      xDlg := gui_newctlname()
   ENDIF

   DEFINE WINDOW ( xDlg ) ;
      AT     nCol, nRow ;
      WIDTH  nWidth ;
      HEIGHT nHeight ;
      TITLE  cTitle ;
      MODAL ;
      ON INIT Eval( bAction )
   END WINDOW

   RETURN Nil

//   WITH OBJECT ::oDlg := TForm():Define()
//      :Row := 500
//      :Col := 1000
//      :Width := ::nDlgWidth
//      :Height := ::nDlgHeight
//      :Title := ::cFileDbf
//      // :Init := ::UpdateEdit()
//   ENDWITH
//    _EndWindow()

FUNCTION gui_CreateMLText( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_newctlname()
   ENDIF
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight); (xValue)

   RETURN Nil

FUNCTION gui_CreateText( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   IF Empty( xControl )
      xControl := gui_newctlname()
   ENDIF
   (bValid)
   (cPicture)
   DEFINE TEXTBOX ( xControl )
      PARENT ( xDlg )
      ROW      nRow
      COL      nCol
      HEIGHT   nHeight
      WIDTH    nWidth
      FONTNAME DEFAULT_FONTNAME
      IF ValType( xValue ) == "N"
         NUMERIC .T.
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
      ELSE
         MAXLENGTH nMaxLength
      ENDIF
      VALUE     xValue
      ON LOSTFOCUS Eval( bValid )
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

FUNCTION gui_CloseDialog( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_SetFocus( xDlg, xControl )

   DoMethod( xDlg, xControl, "SETFOCUS" )

   RETURN Nil

FUNCTION gui_EnableText( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_EnableButton( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := gui_newctlname()
   ENDIF
   (xDlg)
   (lBorder)
   IF lBorder
      @ nRow, nCol LABEL ( xControl ) ;
         PARENT ( xDlg ) ;
         VALUE  xValue ;
         WIDTH  nWidth ;
         HEIGHT nHeight ;
         BORDER
   ELSE
      @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight
   ENDIF
   //WITH OBJECT xControl := TLabel():Define()
   //   :Parent := xDlg
   //   :Row := nRow
   //   :Col := nCol
   //   :Value := xValue
   //   :AutoSize := .T.
   //   :Width := nWidth
   //   :Height := nHeight
   //   //:Border := lBorder
   //ENDWITH

   RETURN Nil

FUNCTION gui_CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF Empty( xControl )
      xControl := gui_newctlname()
   ENDIF

   @ nRow, nCol BUTTON ( xControl ) ;
      PARENT ( xDlg ) ;
      CAPTION  cCaption ;
      PICTURE  cResName ;
      ACTION   Eval( bAction ) ;
      WIDTH    nWidth ;
      HEIGHT   nHeight ;
      IMAGEALIGN TOP

   RETURN Nil

FUNCTION gui_SetTextValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )

   RETURN Nil

FUNCTION gui_SetLabelValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

FUNCTION gui_Browse( xDlg, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem

   IF Empty( xControl )
      xControl := gui_newctlname()
   ENDIF
   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, aItem[3] )
      AAdd( aWidthList, Len( Transform(FieldGet(FieldNum(aItem[3])),"")) * 10 )
   NEXT
   @ nRow, nCol BROWSE ( xControl ) ;
      OF ( xDlg ) ;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      HEADERS aHeaderList ;
      WIDTHS aWidthList ;
      WORKAREA ( workarea ) ;
      FIELDS aFieldList

   (cField);(xValue)

   RETURN Nil

STATIC FUNCTION gui_newctlname()

   STATIC nCount := 0

   nCount += 1

   RETURN "CTL" + StrZero( nCount, 10 )
