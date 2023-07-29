#define CFG_CTLTYPE   1
#define CFG_TOBJ      2
#define CFG_NAME      3  // defined on dlg_print
#define CFG_ACTION    4
#define CFG_VALTYPE   4
#define CFG_LEN       5
#define CFG_DEC       6
#define CFG_CAPTION   7   // defined on dlg_print
#define CFG_VALUE     8
#define CFG_VALID     9
#define CFG_ISKEY     10
#define CFG_VTABLE    11
#define CFG_VFIELD    12
#define CFG_VSHOW     13
#define CFG_VOBJ      14
#define CFG_VVALUE    15
#define CFG_CTLNAME   16
#define CFG_VCTLNAME  17

#define CFG_EDITEMPTY { TYPE_EDIT, Nil, "", "C", 1, 0, "", "", "", .F., "", "", "", Nil, "", "", "" }

#define TYPE_BUTTON   1
#define TYPE_EDIT     2
#define TYPE_TAB      3
#define TYPE_TABPAGE  4
#define TYPE_PANEL    5

#ifndef WIN_RGB
   #define WIN_RGB( r, g, b ) ( r * 256 ) + ( b * 16 ) + c
#endif
#define COLOR_BACK    WIN_RGB( 13, 16, 51 )
#define COLOR_FORE    WIN_RGB( 255, 255, 255 )

#ifdef HBMK_HAS_HWGUI
   #include "hwgui.ch"
#endif
#ifdef HBMK_HAS_HMGE
   #include "hmg.ch"
#endif
#ifdef HBMK_HAS_OOHG
   #include "oohg.ch"
#endif
