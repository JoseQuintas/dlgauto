#define CFG_FNAME      1     // field name
#define CFG_FTYPE      2     // field type
#define CFG_FLEN       3     // field len
#define CFG_FDEC       4     // field decimals
#define CFG_ISKEY      5     // if field is the key
#define CFG_FPICTURE   6     // picture mask
#define CFG_CAPTION    7     // text description of field
#define CFG_VALID      8     // validation
#define CFG_VTABLE     9     // table to make seek
#define CFG_VFIELD     10    // field of table to seek
#define CFG_VSHOW      11    // field to show information
#define CFG_VALUE      12    // app value for edit field
#define CFG_VLEN       13    // app len of VSHOW
#define CFG_CTLTYPE    14    // app current main control type
#define CFG_FCONTROL   15    // control for input (textbox)
#define CFG_CCONTROL   16    // control for caption (label)
#define CFG_VCONTROL   17    // control for VSHOW (label with border)
#define CFG_ACTION     18    // action for button/textbox with button
#define CFG_BRWTABLE   19    // browse table
#define CFG_BRWKEYFROM 20    // browse field source/from
#define CFG_BRWIDXORD  21    // browse index order
#define CFG_BRWKEYTO   22    // browse field target/to
#define CFG_BRWKEYTO2  23    // browse field2 target/to
#define CFG_BRWVALUE   24    // browse key value
#define CFG_BRWEDIT    25    // browse editable
#define CFG_BRWTITLE   26    // browse title
#define CFG_COMBOLIST  27    // array for combobox
#define CFG_SPINNER    28    // min/max for spinner
#define CFG_SAVEONLY   29    // not load from database
// note: EmptyfrmClassItem() creates the empty array

#define TYPE_NONE       0
#define TYPE_BROWSE     1
#define TYPE_BUTTON     2
#define TYPE_BUTTON_BRW 3
#define TYPE_CHECKBOX   4
#define TYPE_COMBOBOX   5
#define TYPE_DATEPICKER 6
#define TYPE_MLTEXT     7 // multiline
#define TYPE_TEXT       8
#define TYPE_TAB        9
#define TYPE_TABPAGE    10
#define TYPE_SPINNER    11
#define TYPE_STATUSBAR  12
#define TYPE_ADDBUTTON  13
#define TYPE_BUG_GET    14

#ifndef DLGAUTO_AS_LIB
#ifdef HBMK_HAS_GTWVG
   #include "gtwvg.ch"
#endif
#endif

#define COLOR_BLACK         RGB2N( 0, 0, 0 )
#define COLOR_WHITE         RGB2N( 255, 255, 255 )
#define COLOR_YELLOW        RGB2N( 255, 255, 0 )
#define COLOR_LIGHTGRAY     RGB2N( 250, 250, 250 )
#define COLOR_GREEN         12507070
#define COLOR_ICE           RGB2N( 224, 222, 207 )
#define APP_FONTNAME        "verdana"
#define APP_FONTSIZE_NORMAL 12
#define APP_FONTSIZE_SMALL  10
#define APP_LINE_HEIGHT     20
#define APP_LINE_SPACING    25
#define APP_BUTTON_BETWEEN  3
#define APP_DLG_WIDTH       1024
#define APP_DLG_HEIGHT      700 // 768
#define PREVIEW_FONTNAME    "Courier New"
#define APP_BUTTON_SIZE     ( APP_LINE_SPACING * 2 )
#define APP_TAB_WIDTH       ( APP_DLG_WIDTH - 30 )
#define APP_TAB_HEIGHT      ( APP_DLG_HEIGHT - ( APP_LINE_SPACING * 6 ) )
