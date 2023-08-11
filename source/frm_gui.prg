/*
frm_gui - wrapper for lib functions, and #include lib source code
*/

#ifdef HBMK_HAS_HWGUI

#include "frm_gui_hwgui.prg"
FUNCTION ActivateDialog( ... ); RETURN hwgui_ActivateDialog( ... )
FUNCTION CreateDialog( ... ); RETURN hwgui_CreateDialog( ... )
FUNCTION CreateMLTextbox( ... ); RETURN hwgui_CreateMLTextbox( ... )
FUNCTION CreateTextbox( ... ); RETURN hwgui_CreateTextbox( ... )
FUNCTION CloseDlg( ... ); RETURN hwgui_CloseDlg( ... )
FUNCTION SetFocusAny( ... ); RETURN hwgui_SetFocus( ... )
FUNCTION EnableTextbox( ... ); RETURN hwgui_EnableTextbox( ... )
FUNCTION EnableButton( ... ); RETURN hwgui_EnableButton( ... )
FUNCTION CreateLabel( ... ); RETURN hwgui_CreateLabel( ... )
FUNCTION CreateButton( ... ); RETURN hwgui_CreateButton( ... )
FUNCTION UpdateTextbox( ... ); RETURN hwgui_UpdateTextbox( ... )
FUNCTION UpdateLabel( ... ); RETURN hwgui_UpdateLabel( ... )
#endif

#ifdef HBMK_HAS_HMGE

#include "frm_gui_hmge.prg"
FUNCTION ActivateDialog( ... ); RETURN hmge_ActivateDialog( ... )
FUNCTION CreateDialog( ... ); RETURN hmge_CreateDialog( ... )
FUNCTION CreateMLTextbox( ... ); RETURN hmge_CreateMLTextbox( ... )
FUNCTION CreateTextbox( ... ); RETURN hmge_CreateTextbox( ... )
FUNCTION CloseDlg( ... ); RETURN hmge_CloseDlg( ... )
FUNCTION SetFocusAny( ... ); RETURN hmge_SetFocus( ... )

FUNCTION EnableTextbox( ... ); RETURN Nil
FUNCTION EnableButton( ... ); RETURN Nil

FUNCTION CreateLabel( ... ); RETURN hmge_CreateLabel( ... )
FUNCTION CreateButton( ... ); RETURN hmge_CreateButton( ... )
FUNCTION UpdateTextbox( ... ); RETURN hmge_UpdateTextBox( ... )
FUNCTION UpdateLabel( ... ); RETURN hmge_UpdateLabel( ... )

#endif

#ifdef HBMK_HAS_OOHG

#include "frm_gui_oohg.prg"
FUNCTION ActivateDialog( ... ); RETURN oohg_ActivateDialog( ... )
FUNCTION CreateDialog( ... ); RETURN oohg_CreateDialog( ... )
FUNCTION CreateMLTextbox( ... ); RETURN oohg_CreateMLTextbox( ... )
FUNCTION CreateTextbox( ... ); RETURN oohg_CreateTextbox( ... )
FUNCTION CloseDlg( ... ); RETURN oohg_CloseDlg( ... )
FUNCTION SetFocusAny( ... ); RETURN oohg_SetFocus( ... )

FUNCTION EnableTextbox( ... ); RETURN Nil
FUNCTION EnableButton( ... ); RETURN Nil

FUNCTION CreateLabel( ... ); RETURN oohg_CreateLabel( ... )
FUNCTION CreateButton( ... ); RETURN oohg_CreateButton( ... )
FUNCTION UpdateTextbox( ... ); RETURN oohg_UpdateTextbox( ... )
FUNCTION UpdateLabel( ... ); RETURN oohg_UpdateLabel( ... )

#endif
