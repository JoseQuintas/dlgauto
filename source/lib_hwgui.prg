/*
lib_hwgui - hwgui source code included in frm_gui
*/

#include "frm_class.ch"

FUNCTION gui_MsgGeneric( cText )

   RETURN hwg_MsgInfo( cText )

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      (xDlg)
      RETURN hwg_SelfFocus( xControl:Handle )

FUNCTION gui_GetTextBoxValue( xDlg, xControl )

   (xDlg)
   RETURN xControl:Value

FUNCTION gui_CreateTab( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   @ nCol, nRow TAB xControl ;
      ITEMS {} ;
      OF    xDlg ;
      ID    101 ;
      SIZE  nWidth, nHeight ;
      STYLE WS_CHILD + WS_VISIBLE

   RETURN Nil

FUNCTION gui_CreatePanel( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   @ nCol, nRow PANEL xControl ;
      OF        xDlg ;
      SIZE      nWidth, nHeight ;
      BACKCOLOR COLOR_WHITE

   RETURN Nil

FUNCTION gui_ActivateDialog( xDlg )

   xDlg:Center()
   xDlg:Activate()

   RETURN Nil

FUNCTION gui_CreateDialog( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bAction )

   LOCAL oFont

   oFont := HFont():Add( DEFAULT_FONTNAME, 0, -11 )
   INIT DIALOG xDlg ;
      CLIPPER ;
      FONT oFont ;
      NOEXIT ;
      TITLE     cTitle ;
      AT        nRow, nCol ;
      SIZE      nWidth, nHeight ;
      BACKCOLOR COLOR_WHITE ;
      ON INIT   bAction
   hwg_SetColorInFocus(.T., , COLOR_YELLOW )

   RETURN Nil

FUNCTION gui_CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   LOCAL oFont := HFont():Add( "Courier New", 0, -11 )

   (xDlg)
   @ nCol, nRow EDITBOX xControl ;
      CAPTION xValue ;
      SIZE    nWidth, nHeight ;
      FONT    oFont ;
      STYLE   ES_MULTILINE + ES_AUTOVSCROLL + WS_VSCROLL + WS_HSCROLL

   RETURN Nil

FUNCTION gui_CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   @ nCol, nRow GET xControl VAR xValue OF xDlg ;
      SIZE      nWidth, nHeight ;
      STYLE     WS_DISABLED + iif( ValType( xValue ) $ "N,N+", ES_RIGHT, ES_LEFT ) ;
      MAXLENGTH nMaxLength ;
      PICTURE   cPicture ;
      VALID     bValid

   RETURN Nil

FUNCTION gui_CloseDialog( xDlg )

   RETURN xDlg:Close()

FUNCTION gui_SetFocus( xDlg, xControl )

   (xDlg)
   xControl:SetFocus()

   RETURN Nil

FUNCTION gui_EnableTextbox( xDlg, xControl, lEnable )

   (xDlg)
   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   RETURN Nil

FUNCTION gui_EnableButton( xDlg, xControl, lEnable )

   (xDlg)
   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   RETURN Nil

FUNCTION gui_CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   ( xDlg )
   IF lBorder
      @ nCol, nRow SAY xControl ;
         CAPTION xValue ;
         OF      xDlg ;
         SIZE    nWidth, nHeight ;
         STYLE   WS_BORDER ;
         COLOR COLOR_BLACK ;
         BACKCOLOR COLOR_GREEN // TRANSPARENT // DO NOT USE TRANSPARENT WITH BORDER
   ELSE
      @ nCol, nRow SAY xControl ;
         CAPTION xValue ;
         OF      xDlg ;
         SIZE    nWidth, nHeight ;
         COLOR   COLOR_BLACK ;
         TRANSPARENT
   ENDIF

   RETURN Nil

FUNCTION gui_CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   ( xDlg )

   @ nCol, nRow BUTTON xControl ;
      CAPTION  Nil ;
      OF       xDlg ;
      SIZE     nWidth, nHeight ;
      STYLE    BS_TOP ;
      ON CLICK bAction ;
      ON INIT  { || ;
         BtnSetImageText( xControl:Handle, cCaption, cResName, nWidth, nHeight ) } ;
         TOOLTIP cCaption

   RETURN Nil

FUNCTION gui_SetTextboxValue( xDlg, xControl, xValue )

   ( xDlg )
   xControl:Value := xValue

   RETURN Nil

FUNCTION gui_SetLabelValue( xDlg, xControl, xValue )

   (xDlg)
   xControl:SetText( xValue )

   RETURN Nil

STATIC FUNCTION BtnSetImageText( hHandle, cCaption, cResName, nWidth, nHeight )

   LOCAL oIcon, hIcon

   oIcon := HICON():AddResource( cResName, nWidth - 20, nHeight - 20 )
   IF ValType( oIcon ) == "O"
      hIcon := oIcon:Handle
   ENDIF
   hwg_SendMessage( hHandle, BM_SETIMAGE, IMAGE_ICON, hIcon )
   hwg_SendMessage( hHandle, WM_SETTEXT, 0, cCaption )

   RETURN Nil

FUNCTION gui_Browse( xDlg, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue )

   LOCAL aItem

   @ nCol, nRow BROWSE xControl DATABASE SIZE nWidth, nHeight STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   xControl:bOther := { |xControl, msg, wParam, lParam| fKeyDown( xControl, msg, wParam, lParam, cField, @xValue ) }

   FOR EACH aItem IN oTBrowse
      ADD COLUMN aItem[2] TO xControl HEADER aItem[1] LENGTH Len( Eval( aItem[2] ) ) JUSTIFY LINE DT_LEFT
   NEXT
   (xDlg)

   RETURN Nil

STATIC FUNCTION fKeyDown( xControl, msg, wParam, lParam, cField, xValue )

   LOCAL nKEY

   IF msg == WM_KEYDOWN
      nKey := hwg_PtrToUlong( wParam ) //wParam
      IF nKey = VK_RETURN
         IF ! Empty( cField )
            xValue := FieldGet( FieldNum( cField, xValue ) )
         ENDIF
         hwg_EndDialog()
      ENDIF
   ENDIF
   (xControl)
   (lParam)

   RETURN .T.
