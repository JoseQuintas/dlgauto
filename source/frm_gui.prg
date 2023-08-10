/*
frm_gui - wrapper for lib functions, and #include lib source code
*/

#ifdef HBMK_HAS_HWGUI

#include "frm_gui_hwgui.prg"

FUNCTION CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )
   RETURN hwgui_CreateMLTextbox( xDlg, @xControl, nRow, nCol, nWidth, nHeight, @xValue )

FUNCTION CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )
   RETURN hwgui_CreateTextbox( xDlg, @xControl, nRow, nCol, nWidth, nHeight, ;
            @xValue, cPicture, nMaxLength, bValid )

FUNCTION CloseDlg( xDlg )

   RETURN hwgui_CloseDlg( xDlg )

FUNCTION SetFocusAny( xDlg, xControl )

   RETURN hwgui_SetFocus( xDlg, xControl )

FUNCTION EnableTextbox( xDlg, xControl, lEnable )

   RETURN hwgui_EnableTextbox( xDlg, xControl, lEnable )

FUNCTION EnableButton( xDlg, xControl, lEnable )

   RETURN hwgui_EnableButton( xDlg, xControl, lEnable )

FUNCTION CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   hb_Default( @lBorder, .F. )

   RETURN hwgui_CreateLabel( xDlg, @xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

FUNCTION CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
         cCaption, cIcon, bAction )

   RETURN hwgui_CreateButton( xDlg, @xControl, nRow, nCol, nWidth, nHeight, ;
         cCaption, cIcon, bAction )

FUNCTION UpdateTextbox( xDlg, xControl, xValue )

   RETURN hwgui_UpdateTextbox( xDlg, xControl, xValue )

FUNCTION UpdateLabel( xDlg, xControl, xValue )

   RETURN hwgui_UpdateLabel( xDlg, xControl, xValue )

#endif
#ifdef HBMK_HAS_HMGE

#include "frm_gui_hmge.prg"

FUNCTION CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )
   RETURN hmge_CreateMLTextbox( xDlg, @xControl, nRow, nCol, nWidth, nHeight, @xValue )

FUNCTION CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )
   RETURN hmge_CreateTextbox( xDlg, @xControl, nRow, nCol, nWidth, nHeight, ;
            @xValue, cPicture, nMaxLength, bValid )

FUNCTION CloseDlg( xDlg )

   RETURN hmge_CloseDlg( xDlg )

FUNCTION SetFocusAny( xDlg, xControl )

   RETURN hmge_SetFocus( xDlg, xControl )

FUNCTION EnableTextbox( xDlg, xControl, lEnable )

   (xDlg)
   (xControl)
   (lEnable)

   RETURN Nil

FUNCTION EnableButton( xDlg, xControl, lEnable )

   (xDlg)
   (xControl)
   (lEnable)

   RETURN Nil

FUNCTION CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   hb_Default( @lBorder, .F. )

   RETURN hmge_CreateLabel( xDlg, @xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

FUNCTION CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
         cCaption, cIcon, bAction )

   RETURN hmge_CreateButton( xDlg, @xControl, nRow, nCol, nWidth, nHeight, ;
         cCaption, cIcon, bAction )

FUNCTION UpdateTextbox( xDlg, xControl, xValue )

   RETURN hmge_UpdateTextBox( xDlg, xControl, xValue )

FUNCTION UpdateLabel( xDlg, xControl, xValue )

   RETURN hmge_UpdateLabel( xDlg, xControl, xValue )

#endif

#ifdef HBMK_HAS_OOHG

#include "frm_gui_oohg.prg"

FUNCTION CreateMLTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )
   RETURN oohg_CreateMLTextbox( xDlg, @xControl, nRow, nCol, nWidth, nHeight, @xValue )

FUNCTION CreateTextbox( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )
   RETURN oohg_CreateTextbox( xDlg, @xControl, nRow, nCol, nWidth, nHeight, ;
            @xValue, cPicture, nMaxLength, bValid )

FUNCTION CloseDlg( xDlg )

   RETURN oohg_CloseDlg( xDlg )

FUNCTION SetFocusAny( xDlg, xControl )

   RETURN oohg_SetFocus( xDlg, xControl )

FUNCTION EnableTextbox( xDlg, xControl, lEnable )

   (xDlg)
   (xControl)
   (lEnable)

   RETURN Nil

FUNCTION EnableButton( xDlg, xControl, lEnable )

   (xDlg)
   (xControl)
   (lEnable)

   RETURN Nil

FUNCTION CreateLabel( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   hb_Default( @lBorder, .F. )

   RETURN oohg_CreateLabel( xDlg, @xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

FUNCTION CreateButton( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
         cCaption, cIcon, bAction )

   RETURN oohg_CreateButton( xDlg, @xControl, nRow, nCol, nWidth, nHeight, ;
         cCaption, cIcon, bAction )

FUNCTION UpdateTextbox( xDlg, xControl, xValue )

   oohg_UpdateTextbox( xDlg, xControl, xValue )

   RETURN Nil

FUNCTION UpdateLabel( xDlg, xControl, xValue )

   RETURN oohg_UpdateLabel( xDlg, xControl, xValue )

#endif
