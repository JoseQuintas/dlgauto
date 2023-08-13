/*
lib_hwgui - hwgui source code included in frm_gui
*/

#include "frm_class.ch"

FUNCTION hwgui_CreateTab( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   @ nCol, nRow TAB xControl ;
      ITEMS {} ;
      OF    xDlg ;
      ID    101 ;
      SIZE  nWidth, nHeight ;
      STYLE WS_CHILD + WS_VISIBLE

   RETURN Nil

FUNCTION hwgui_CreatePanel( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   @ nCol, nRow PANEL xControl ;
      OF        xDlg ;
      SIZE      nWidth, nHeight ;
      BACKCOLOR COLOR_WHITE

   RETURN Nil

FUNCTION hwgui_ActivateDialog( xDlg )

   xDlg:Center()
   xDlg:Activate()

   RETURN Nil

FUNCTION hwgui_CreateDialog( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bAction )

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

FUNCTION hwgui_CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   LOCAL oFont := HFont():Add( "Courier New", 0, -11 )

   (xDlg)
   @ nCol, nRow EDITBOX xControl ;
      CAPTION xValue ;
      SIZE    nWidth, nHeight ;
      FONT    oFont ;
      STYLE   ES_MULTILINE + ES_AUTOVSCROLL + WS_VSCROLL + WS_HSCROLL

   RETURN Nil

FUNCTION hwgui_CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   @ nCol, nRow GET xControl VAR xValue OF xDlg ;
      SIZE      nWidth, nHeight ;
      STYLE     WS_DISABLED + iif( ValType( xValue ) $ "N,N+", ES_RIGHT, ES_LEFT ) ;
      MAXLENGTH nMaxLength ;
      PICTURE   cPicture ;
      VALID     bValid

   RETURN Nil

FUNCTION hwgui_CloseDlg( xDlg )

   RETURN xDlg:Close()

FUNCTION hwgui_SetFocusAny( xDlg, xControl )

   (xDlg)
   xControl:SetFocus()

   RETURN Nil

FUNCTION hwgui_EnableTextbox( xDlg, xControl, lEnable )

   (xDlg)
   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   RETURN Nil

FUNCTION hwgui_EnableButton( xDlg, xControl, lEnable )

   (xDlg)
   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   RETURN Nil

FUNCTION hwgui_CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   ( xDlg )
   IF lBorder
      @ nCol, nRow SAY xControl ;
         CAPTION xValue ;
         OF      xDlg ;
         SIZE    nWidth, nHeight ;
         COLOR   COLOR_BLACK ;
         STYLE   WS_BORDER ;
         TRANSPARENT
   ELSE
      @ nCol, nRow SAY xControl ;
         CAPTION xValue ;
         OF      xDlg ;
         SIZE    nWidth, nHeight ;
         COLOR   COLOR_BLACK ;
         TRANSPARENT
   ENDIF

   RETURN Nil

FUNCTION hwgui_CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

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

FUNCTION hwgui_SetTextboxValue( xDlg, xControl, xValue )

   ( xDlg )
   xControl:Value := xValue

   RETURN Nil

FUNCTION hwgui_SetLabelValue( xDlg, xControl, xValue )

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

