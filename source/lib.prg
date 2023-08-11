/*
lib - wrapper for lib functions, and #include lib source code
*/

#ifdef HBMK_HAS_HWGUI

#include "lib_hwgui.prg"
FUNCTION CreateTab( ... ); RETURN hwgui_CreateTab( ... )
FUNCTION CreatePanel( ... ); RETURN hwgui_CreatePanel( ... )
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

#include "lib_hmge.prg"
FUNCTION CreateTab( ... ); RETURN hmge_CreateTab( ... )
FUNCTION CreatePanel( ... ); RETURN hmge_CreatePanel( ... )
FUNCTION ActivateDialog( ... ); RETURN hmge_ActivateDialog( ... )
FUNCTION CreateDialog( ... ); RETURN hmge_CreateDialog( ... )
FUNCTION CreateMLTextbox( ... ); RETURN hmge_CreateMLTextbox( ... )
FUNCTION CreateTextbox( ... ); RETURN hmge_CreateTextbox( ... )
FUNCTION CloseDlg( ... ); RETURN hmge_CloseDlg( ... )
FUNCTION SetFocusAny( ... ); RETURN hmge_SetFocus( ... )

FUNCTION EnableTextbox( ... ); RETURN hmge_EnableTextbox( ... )
FUNCTION EnableButton( ... ); RETURN hmge_EnableButton( ... )

FUNCTION CreateLabel( ... ); RETURN hmge_CreateLabel( ... )
FUNCTION CreateButton( ... ); RETURN hmge_CreateButton( ... )
FUNCTION UpdateTextbox( ... ); RETURN hmge_UpdateTextBox( ... )
FUNCTION UpdateLabel( ... ); RETURN hmge_UpdateLabel( ... )

#endif

#ifdef HBMK_HAS_OOHG

#include "lib_oohg.prg"
FUNCTION CreateTab( ... ); RETURN oohg_CreateTab( ... )
FUNCTION CreatePanel( ... ); RETURN oohg_CreatePanel( ... )
FUNCTION ActivateDialog( ... ); RETURN oohg_ActivateDialog( ... )
FUNCTION CreateDialog( ... ); RETURN oohg_CreateDialog( ... )
FUNCTION CreateMLTextbox( ... ); RETURN oohg_CreateMLTextbox( ... )
FUNCTION CreateTextbox( ... ); RETURN oohg_CreateTextbox( ... )
FUNCTION CloseDlg( ... ); RETURN oohg_CloseDlg( ... )
FUNCTION SetFocusAny( ... ); RETURN oohg_SetFocus( ... )

FUNCTION EnableTextbox( ... ); RETURN oohg_EnableTextbox( ... )
FUNCTION EnableButton( ... ); RETURN oohg_EnableButton( ... )

FUNCTION CreateLabel( ... ); RETURN oohg_CreateLabel( ... )
FUNCTION CreateButton( ... ); RETURN oohg_CreateButton( ... )
FUNCTION UpdateTextbox( ... ); RETURN oohg_UpdateTextbox( ... )
FUNCTION UpdateLabel( ... ); RETURN oohg_UpdateLabel( ... )

#endif
