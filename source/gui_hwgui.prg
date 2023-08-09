#include "frm_class.ch"

FUNCTION hwgui_CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   @ nCol, nRow GET xControl VAR xValue OF xDlg ;
            SIZE nWidth, nHeight ;
            STYLE WS_DISABLED + iif( ValType( xValue ) $ "N,N+", ES_RIGHT, ES_LEFT ) ;
            MAXLENGTH nMaxLength ;
            PICTURE cPicture ;
            VALID bValid

   RETURN Nil

FUNCTION hwgui_CloseDlg( xDlg )

   RETURN xDlg:Close()

FUNCTION hwgui_SetFocus( xDlg, xControl )

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
      @ nCol, nRow SAY xControl CAPTION xValue OF xDlg SIZE nWidth, nHeight COLOR COLOR_FORE STYLE WS_BORDER TRANSPARENT
   ELSE
      @ nCol, nRow SAY xControl CAPTION xValue OF xDlg SIZE nWidth, nHeight COLOR COLOR_FORE TRANSPARENT
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

FUNCTION hwgui_UpdateTextBox( xDlg, xControl, xValue )

   ( xDlg )
   xControl:Value := xValue

   RETURN Nil

FUNCTION hwgui_UpdateLabel( xDlg, xControl, xValue )

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

