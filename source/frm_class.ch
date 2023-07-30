#define CFG_CTLTYPE   1
#define CFG_TOBJ      2
#define CFG_FNAME     3  // defined on frm_print
#define CFG_FTYPE     4
#define CFG_FLEN      5
#define CFG_FDEC      6
#define CFG_ISKEY     7
#define CFG_CAPTION   8   // defined on frm_print
#define CFG_VALUE     9
#define CFG_VALID     10
#define CFG_VTABLE    11
#define CFG_VFIELD    12
#define CFG_VSHOW     13
#define CFG_VOBJ      14
#define CFG_VLEN      15
#define CFG_ACTION    16

#define CFG_EDITEMPTY { TYPE_EDIT, Nil, "", "C", 1, 0, .F., "", "", .F., "", "", "", Nil, 0, Nil }

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
   #define THIS_HWGUI
#endif
#ifdef HBMK_HAS_HMGE
   #include "hmg.ch"
   #define THIS_HMGE
#endif
#ifdef HBMK_HAS_OOHG
   #include "oohg.ch"
   #define THIS_OOHG
#endif
