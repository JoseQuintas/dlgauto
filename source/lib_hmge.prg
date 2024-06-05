/*
lib_hmge - HMG Extended source selected by lib.prg
*/

#include "frm_class.ch"
#include "hmg.ch"
#include "i_winuser.ch"

STATIC nWindow := 0

FUNCTION gui_Init()

#ifdef DLGAUTO_AS_LIB
   Init()
#endif
   SET GETBOX FOCUS BACKCOLOR TO {255,255,0}
   SET MENUSTYLE EXTENDED
   SET NAVIGATION EXTENDED
   SET WINDOW MODAL PARENT HANDLE ON
   SET WINDOW MAIN OFF
   Set( _SET_DEBUG, .F. )

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   gui_DialogCreate( @xDlg, 0, 0,1024, 768, cTitle,,,.T. )

   DEFINE MAIN MENU OF ( xDlg )
      FOR EACH aGroupList IN aMenuList
         DEFINE POPUP "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup ) ICON "ICOWINDOW"
            NEXT
         END POPUP
      NEXT
      DEFINE POPUP "NoData"
         MENUITEM "NoData Layout 1" ACTION test_noDatabase(1)
         MENUITEM "NoData Layout 2" ACTION test_noDatabase(2)
         MENUITEM "NoData Layout 3" ACTION test_noDatabase(3)
      END POPUP
      DEFINE POPUP "Exit"
         MENUITEM "Exit" ACTION gui_DialogClose( xDlg ) ICON "ICODOOR"
      END POPUP
      DEFINE MONTHCALENDAR ( gui_NewName( "MON" ) )
         PARENT ( xDlg )
         COL 400
         ROW 400
         VALUE Date()
      END MONTHCALENDAR
   END MENU

   gui_DialogActivate( xDlg )

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF Empty( xControl )
      xControl := gui_NewName( "BTN" )
   ENDIF

   DEFINE BUTTONEX ( xControl )
      PARENT ( xDlg )
      ROW         nRow
      COL         nCol
      WIDTH       nWidth
      HEIGHT      nHeight
      ICON        cResName
      IMAGEWIDTH  -1
      IMAGEHEIGHT -1
      CAPTION     cCaption
      ACTION      Eval( bAction )
      FONTNAME    APP_FONTNAME
      FONTSIZE    7
      FONTBOLD    .T.
      FONTCOLOR   COLOR_BLACK
      VERTICAL   .T.
      BACKCOLOR  COLOR_WHITE
      FLAT       .T.
      NOXPSTYLE  .T.
   END BUTTONEX

   RETURN Nil

FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, ;
   nHeight, oTbrowse, cField, xValue, workarea, aKeyDownList, Self )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem, aThisKey
   LOCAL aBrowseBackColor := {}, aBrowseForeColor := {}, nPos

   IF Empty( xControl )
      xControl := gui_NewName( "BRW" )
   ENDIF

   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := {}
   ENDIF

   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, aItem[2] )
      AAdd( aWidthList, ( 1 + Max( Len( aItem[3] ), ;
         Len( Transform( ( workarea )->( FieldGet( FieldNum( aItem[ 1 ] ) ) ), "" ) ) ) ) * 13 )
      AAdd( aBrowseBackColor, { || iif( OrdKeyNo() / 2 == Int( OrdKeyNo() / 2 ), { 222,222,222 }, { 250,250,250 } ) } )
      AAdd( aBrowseForeColor, { || iif( OrdKeyNo() / 2 == Int( OrdKeyNo() / 2 ), { 0,0,0 }, { 0,0,0 } ) } )
   NEXT

   DEFINE BROWSE ( xControl )
      PARENT ( xParent )
      ROW nRow
      COL nCol
      WIDTH nWidth - 20
      HEIGHT nHeight - 20
      IF Len( aKeyDownList ) == 0
         ONDBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
      ELSEIF ( nPos := hb_AScan( aKeyDownList, { | e | e[1] == VK_RETURN } ) ) != 0
         ONDBLCLICK Eval( aKeyDownList[ nPos ][ 2 ] )
      ENDIF
      HEADERS aHeaderList
      WIDTHS aWidthList
      WORKAREA ( workarea )
      FIELDS aFieldList
      DYNAMICBACKCOLOR aBrowseBackColor
      DYNAMICFORECOLOR aBrowseForeColor
      SET BROWSESYNC ON // if remove, browse action and DLG keydown on wrong record
   END BROWSE
   /* create buttons on browse for defined keys */
   IF Len( aKeyDownList ) != 0
      FOR EACH aThisKey IN aKeyDownList
         AAdd( ::aControlList, EmptyFrmClassItem() )
         Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_BUTTON
         Atail( ::aControlList )[ CFG_FCONTROL ] := gui_NewName( "BTNBRW" )
         gui_ButtonCreate( xDlg, @Atail( ::aControlList )[ CFG_FCONTROL ], ;
         nRow - APP_LINE_SPACING, 200 + aThisKey:__EnumIndex() * APP_LINE_HEIGHT, APP_LINE_HEIGHT - 2, APP_LINE_HEIGHT - 2, "", ;
         iif( aThisKey[1] == VK_INSERT, "ICOPLUS", ;
         iif( aThisKey[1] == VK_DELETE, "ICOTRASH", ;
         iif( aThiskey[1] == VK_RETURN, "ICOEDIT", Nil ) ) ), aThisKey[2] )
      NEXT
   ENDIF
   /* redefine keys with cumulative actions */
   FOR EACH aItem IN aKeyDownList
      AAdd( ::aDlgKeyDown, { xControl, aItem[ 1 ], aItem[ 2 ] } )
   NEXT

   (xDlg);(cField);(xValue);(workarea);(aKeyDownList)

   RETURN Nil

STATIC FUNCTION gui_DlgKeyDown( xControl, nKey, Self )

   LOCAL nPos, cType, cFocusedControl

   cFocusedControl := GetProperty( ::xDlg, "FOCUSEDCONTROL" )
   nPos := hb_AScan( ::aDlgKeyDown, { | e | cFocusedControl == e[1] .AND. nKey == e[ 2 ] } )
   IF nPos != 0
      IF GetProperty( ::xDlg, cFocusedControl, "ENABLED" )
         Eval( ::aDlgKeyDown[ nPos ][ 3 ] )
      ENDIF
   ENDIF
   IF nKey == VK_RETURN .AND. hb_ASCan( ::aDlgKeyDown, { | e | e[ 2 ] == VK_RETURN } ) != 0
      cType := GetProperty( ::xDlg, cFocusedControl, "TYPE" )
      /* ENTER next focus, because a defined key can change default */
      IF hb_AScan( { "GETBOX", "MASKEDTEXT", "TEXT", "SPINNER", "DATEPICKER", "CHECKBOX" }, { | e | e == cType } ) != 0
         _SetNextFocus()
      ENDIF
   ENDIF
   (xControl)

   RETURN .T.

FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   IF ! Empty( cField )
      // without browsesync ON
      // (workarea)->( dbGoto( GetProperty( xDlg, xControl, "VALUE" ) ) )
      xValue := (workarea)->( FieldGet( FieldNum( cField ) ) )
   ENDIF
   (xControl)
   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_BrowseRefresh( xDlg, xControl )

   // on older hmge versions, need to set browse value/recno()
   SetProperty( xDlg, xControl, "VALUE", RecNo() )
   DoMethod( xDlg, xControl, "REFRESH" )
   (xDlg)

   RETURN Nil

FUNCTION gui_CheckboxCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_NewName( "CHK" )
   ENDIF

   DEFINE CHECKBOX ( xControl )
      PARENT ( xDlg )
      Row nRow
      COL nCol
      WIDTH nWidth
      HEIGHT nHeight
      CAPTION ""
   END CHECKBOX

   RETURN Nil

FUNCTION gui_ComboCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, aList )

   IF Empty( xControl )
      xControl := gui_NewName( "CBO" )
   ENDIF

   DEFINE COMBOBOX ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      VALUE 1
      WIDTH nWidth
      // do not define height, it can limit list size to zero
      // HEIGHT nHeight
      ITEMS aList
   END COMBOBOX

   ( nHeight )

   RETURN Nil

FUNCTION gui_SpinnerCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, nValue, aList )

   IF Empty( xControl )
      xControl := gui_NewName( "SPI" )
   ENDIF

   DEFINE SPINNER ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      VALUE nValue
      WIDTH nWidth
      // Depending Windows version ?, do not accepts to change color
      // ON GOTFOCUS  SetProperty( xDlg, xControl, "BACKCOLOR", COLOR_YELLOW )
      // ON LOSTFOCUS SetProperty( xDlg, xControl, "BACKCOLOR", COLOR_WHITE )
      RANGEMIN aList[ 1 ]
      RANGEMAX aList[ 2 ]
   END SPINNER
   ( nHeight )

   RETURN Nil

FUNCTION gui_DatePickerCreate( xDlg, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   IF Empty( xControl )
      xControl := gui_NewName( "DTP" )
   ENDIF

   DEFINE DATEPICKER ( xControl )
      PARENT ( xDlg )
      ROW	nRow
      COL	nCol
      VALUE dValue
      // Depending Windows version ?, do not accepts to change color
      // ON GOTFOCUS SetProperty( xDlg, xControl, "BACKCOLOR", COLOR_YELLOW )
      // ON LOSTFOCUS SetProperty( xDlg, xControl, "BACKCOLOR", COLOR_WHITE )
      // DATEFORMAT "99/99/9999"
      TOOLTIP 'DatePicker Control'
      SHOWNONE .F.
      TITLEBACKCOLOR BLACK
      TITLEFONTCOLOR YELLOW
      TRAILINGFONTCOLOR PURPLE
   END DATEPICKER

   (nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode )

   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   DoMethod( xDlg, "CENTER" )
   DoMethod( xDlg, "ACTIVATE" )

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal )

   //nWindow += 1

   IF Empty( xDlg )
      xDlg := gui_NewName( "DLG" )
   ENDIF

   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF

   hb_Default( @lModal, .T. )

   IF nWindow == 1
      DEFINE WINDOW ( xDlg ) ;
         AT nCol, nRow ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE cTitle ;
         ICON "APPICON" ;
         FONT APP_FONTNAME SIZE APP_FONTSIZE_NORMAL ;
         MAIN ;
         ON INIT Eval( bInit )
         gui_Statusbar( xDlg, "" )
      END WINDOW
   ELSEIF lModal
      DEFINE WINDOW ( xDlg ) ;
         AT nCol, nRow ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE cTitle ;
         ICON "APPICON" ;
         FONT APP_FONTNAME SIZE APP_FONTSIZE_NORMAL ;
         MODAL ;
         ON INIT Eval( bInit )
         gui_Statusbar( xDlg, "" )
      END WINDOW
   ELSE
      DEFINE WINDOW ( xDlg ) ;
         AT nCol, nRow ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE cTitle ;
         ICON "APPICON" ;
         FONT APP_FONTNAME SIZE APP_FONTSIZE_NORMAL ;
         ON INIT Eval( bInit )
         // BACKCOLOR { 226, 220, 213 } ;
         // MODAL ; // bad using WINDOW MAIN OFF
         // ON RELEASE iif( Empty( xOldDlg ), Nil, DoMethod( xOldDlg, "SETFOCUS" ) )
         // IF ! Empty( xOldDlg )
         //    ON KEY ALT+F4 ACTION doMethod( xOldDlg, "SETFOCUS" )
         // ENDIF
         gui_Statusbar( xDlg, "" )
      END WINDOW
   ENDIF

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      RETURN GetProperty( xDlg, "FOCUSEDCONTROL" )  == xControl

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder, nFontSize )

   IF Empty( xControl )
      xControl := gui_NewName( "LBL" )
   ENDIF

   hb_Default( @lBorder, .F. )
   hb_Default( @nFontSize, APP_FONTSIZE_NORMAL )

   DEFINE LABEL ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth
      HEIGHT nHeight
      VALUE xValue
      FONTNAME "Arial"
      FONTSIZE nFontSize
      IF lBorder
         BORDER lBorder
         BACKCOLOR HMG_n2RGB( COLOR_GREEN )
      ENDIF
   END LABEL

   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "HMGE"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_NewName( "MLTXT" )
   ENDIF

   DEFINE EDITBOX ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth - 30 /* scrollbar */
      HEIGHT nHeight
      VALUE xValue
      FONTNAME PREVIEW_FONTNAME
      TOOLTIP 'EditBox'
   END EDITBOX

   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN Msgbox( cText )

FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

FUNCTION gui_SetFocus( xDlg, xControl )

   IF Empty( xControl )
      DoMethod( xDlg, "SETFOCUS" )
   ELSE
      DoMethod( xDlg, xControl, "SETFOCUS" )
   ENDIF

   RETURN Nil

FUNCTION gui_Statusbar( xDlg, xControl )

   IF Empty( xControl )
      xControl := gui_NewName( "STA" )
   ENDIF

	DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 PARENT ( xDlg )
		STATUSITEM "DlgAuto/FiveLibs" // ACTION MsgInfo( "Click! 1" )
		CLOCK
		DATE
	END STATUSBAR
   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_NewName( "TAB" )
   ENDIF

   DEFINE TAB ( xControl ) ;
      PARENT ( xDlg ) ;
      AT nRow, nCol;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      HOTTRACK
      // BACKCOLOR { 226, 220, 213 }

   RETURN Nil

FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg);(xTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, xPage, nPageCount, cText )

   PAGE ( cText ) IMAGE "bmpfolder"

   xPage := xDlg
   // BACKCOLOR { 50, 50, 50 }
   (xDlg); (xControl); (cText); (nPageCount)

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )

   END PAGE

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, Self, lPassword )

   IF Empty( xControl )
      xControl := gui_NewName( "TEXT" )
   ENDIF

   hb_Default( @lPassword, .F. )

   DEFINE GETBOX ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      HEIGHT nHeight
      WIDTH nWidth
      FONTNAME APP_FONTNAME
      FONTSIZE APP_FONTSIZE_NORMAL
      IF ValType( xValue ) == "N"
         NUMERIC .T.
         INPUTMASK cPicture
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
         DATEFORMAT cPicture
      ELSEIF ValType( xValue ) == "L" // workaround to do not get error
         xValue := " "
      ELSEIF ValType( xValue ) == "C"
         MAXLENGTH nMaxLength
      ENDIF
      VALUE xValue
      IF ! Empty( bAction )
         ACTION Eval( bAction )
      ENDIF
      IF ! Empty( cImage )
         IMAGE cImage
      ENDIF
      IF ! Empty( bValid )
         ON LOSTFOCUS Eval( bValid )
      ENDIF
      /* when call a dialog from bvalid, valid on next dialog does not works */
      // VALID bValid
      IF lPassword
         PASSWORD .T.
         UPPERCASE .T.
      ENDIF
   END GETBOX
   /* F9 on key fields will make a browse but click on button does the same */
   IF aItem[ CFG_ISKEY ] .OR. ! Empty( aItem[ CFG_VTABLE ] )
      AAdd( ::aDlgKeyDown, { xControl, VK_F9, ;
         { || ::Browse( xDlg, xControl, iif( aItem[ CFG_ISKEY ], ::cFileDbf, aItem[ CFG_VTABLE ] ) ) } } )
   ENDIF
   (bValid)

   RETURN Nil

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_ControlGetValue( xDlg, xControl )

   LOCAL xValue

   xValue := GetProperty( xDlg, xControl, "VALUE" )
   (xDlg)

   RETURN xValue

FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   /* textbox string value, but depends textbox creation */
   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

STATIC FUNCTION gui_NewName( cPrefix )

   STATIC nCount := 0

   nCount += 1
   hb_Default( @cPrefix, "ANY" )

   RETURN cPrefix + StrZero( nCount, 10 )

FUNCTION gui_DlgSetKey( Self )

   LOCAL aItem

   FOR EACH aItem IN ::aDlgKeyDown
         _DefineHotKey( ::xDlg, 0, aItem[ 2 ], { || gui_DlgKeyDown( aItem[1], ;
            aItem[ 2 ], Self ) } )
   NEXT

   RETURN Nil
