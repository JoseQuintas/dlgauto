#define CFG_FNAME      1  // frm_print       // field name
#define CFG_FTYPE      2                     // field type
#define CFG_FLEN       3                     // field len
#define CFG_FDEC       4                     // field decimals
#define CFG_ISKEY      5                     // if field is the key
#define CFG_FPICTURE   6                     // picture mask
#define CFG_CAPTION    7   // frm_print      // text description of field
#define CFG_VALID      8                     // validation
#define CFG_VTABLE     9                     // table to make seek
#define CFG_VFIELD     10                    // field of table to seek
#define CFG_VSHOW      11                    // field to show information
#define CFG_VALUE      12                    // app value for edit field
#define CFG_VLEN       13                    // app len of VSHOW
#define CFG_CTLTYPE    14                    // app current control type
#define CFG_FCONTROL   15                    // app control for input
#define CFG_CCONTROL   16                    // app control for caption
#define CFG_VCONTROL   17                    // app control for VSHOW
#define CFG_ACTION     18                    // app action for button
#define CFG_BRWTABLE   19                    // browse table
#define CFG_BRWKEYFROM 20                    // browse field from main
#define CFG_BRWIDXORD  21                    // browse index order
#define CFG_BRWKEYTO   22                    // browse field to
#define CFG_BRWKEYTO2  23                    // browse field2 to
#define CFG_BRWVALUE   24                    // browse key value
#define CFG_BRWEDIT    25                    // browse editable
#define CFG_BRWTITLE   26                    // browse title
#define CFG_COMBOLIST  26                    // array for combo
#define CFG_SPINNER    26                    // min/max for spinner

#define CFG_EMPTY { "", "C", 1, 0, .F., "", "", {}, "", "", "", Nil, 0, TYPE_NONE, Nil, Nil, Nil, Nil, Nil, Nil, 1, Nil, Nil, Nil, Nil, Nil }

#define TYPE_NONE       0
#define TYPE_BUTTON     1
#define TYPE_TEXT       2
#define TYPE_TAB        3
#define TYPE_TABPAGE    4
#define TYPE_BROWSE     5
#define TYPE_HWGUIBUG   8
#define TYPE_COMBOBOX   9
#define TYPE_CHECKBOX   10
#define TYPE_STATUSBAR  11
#define TYPE_DATEPICKER 12
#define TYPE_MLTEXT     13 // multiline
#define TYPE_SPINNER    14

#ifdef HBMK_HAS_GTWVG
   #include "gtwvg.ch"
#endif

#ifndef WIN_RGB
   #ifdef HBMK_HAS_HWGUI
      #define WIN_RGB( r, g, b ) hwg_ColorRGB2N( r, g, b )
   #else
      #define WIN_RGB( r, g, b ) ( r * 256 ) + ( b * 16 ) + c
   #endif
#endif

#define COLOR_BLACK         WIN_RGB( 0, 0, 0 )
#define COLOR_WHITE         WIN_RGB( 255, 255, 255 )
#define COLOR_YELLOW        WIN_RGB( 255, 255, 0 )
#define COLOR_GREEN         12507070
#define APP_FONTNAME        "verdana"
#define APP_FONTSIZE_NORMAL 10
#define APP_FONTSIZE_SMALL  8
#define APP_LINE_HEIGHT     20
#define APP_LINE_SPACING    25
#define APP_BUTTON_SIZE     50
#define APP_BUTTON_BETWEEN  3
#define APP_DLG_WIDTH       1024
#define APP_DLG_HEIGHT      768
#define PREVIEW_FONTNAME    "Courier New"
