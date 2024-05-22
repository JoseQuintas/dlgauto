/*
lib_hmg3 - HMG3 source selected by lib.prg
*/

#include "frm_class.ch"
#include "hmg.ch"
#include "i_altsyntax.ch"

MEMVAR _HMG_SYSDATA
MEMVAR _HMG_MainWindowFirst

FUNCTION gui_Init()

   SET WINDOW MAIN OFF
   SET NAVIGATION EXTENDED
   SET BROWSESYNC ON

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   gui_DialogCreate( @xDlg, 0, 0,1024, 768, cTitle )

   DEFINE MAIN MENU OF ( xDlg )
      FOR EACH aGroupList IN aMenuList
         DEFINE POPUP "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
            NEXT
         END POPUP
      NEXT
      DEFINE POPUP "Exit"
         MENUITEM "Exit" ACTION gui_DialogClose( xDlg )
      END POPUP
      DEFINE MONTHCALENDAR ( gui_NewName( "CAL" ) )
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
      xControl := gui_NewName( "BUTTON" )
   ENDIF

   DEFINE BUTTON ( xControl )
      PARENT ( xDlg )
      ROW           nRow
      COL           nCol
      WIDTH         nWidth
      HEIGHT        nHeight
      CAPTION       cCaption
      // do not show ico ??
      PICTURE       cResName
      PICTALIGNMENT TOP
      ACTION         Eval( bAction )
   END BUTTON

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(cCaption);(cResName);(bAction)

   RETURN Nil

FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyDownList, Self )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem, aThisKey

   IF Empty( xControl )
      xControl := gui_NewName( "BRW" )
   ENDIF
   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := {}
   ENDIF
   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, aItem[2] )
      AAdd( aWidthList, ( 1 + Max( Len( aItem[3] ), Len( Transform(FieldGet(FieldNum(aItem[1] ) ), "" ) ) ) ) * 13 )
   NEXT
   IF Len( aKeyDownList ) != 0
      @ nRow, nCol GRID ( xControl ) ;
         OF ( xParent ) ;
         WIDTH nWidth - 40 ;
         HEIGHT nHeight - 40 ;
         HEADERS aHeaderList ;
         WIDTHS aWidthList ;
         VIRTUAL ;
         ROWSOURCE ( workarea ) ;
         COLUMNFIELDS aFieldList
   ELSE
      @ nRow, nCol GRID ( xControl ) ;
         OF ( xDlg ) ;
         WIDTH nWidth - 40 ;
         HEIGHT nHeight - 40 ;
         ON DBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue ) ;
         HEADERS aHeaderList ;
         WIDTHS aWidthList ;
         VIRTUAL ;
         ROWSOURCE ( workarea ) ;
         COLUMNFIELDS aFieldList
   ENDIF
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
      // some buttons
   ENDIF
   FOR EACH aItem IN aKeyDownList
      AAdd( ::aDlgKeyDown, { xControl, aItem[ 1 ], aItem[ 2 ] } )
   NEXT

   (xDlg);(cField);(xValue);(workarea);(xParent)

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
      IF ! Empty( cFocusedControl )
         cType := GetProperty( ::xDlg, cFocusedControl, "TYPE" )
         IF hb_AScan( { "GETBOX", "MASKEDTEXT", "TEXT" }, { | e | e == cType } ) != 0
            _SetNextFocus()
         ENDIF
      ENDIF
   ENDIF
   (xControl)

   RETURN .T.

FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   LOCAL nRecNo

   IF ! Empty( cField )
      nRecNo := GetProperty( xDlg, xControl, "RECNO" )
      GOTO ( nRecNo )
      xValue := (workarea)->( FieldGet( FieldNum( cField ) ) )
   ENDIF
   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_BrowseRefresh( xDlg, xControl )

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
      HEIGHT nHeight
      ITEMS aList
   END COMBOBOX

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
   DEFINE DATEPICKER (xControl)
      PARENT ( xDlg )
      ROW	nRow
      COL	nCol
      VALUE dValue
      //DATEFORMAT "99/99/99"
      TOOLTIP 'DatePicker Control'
      SHOWNONE .F.
      TITLEBACKCOLOR BLACK
      TITLEFONTCOLOR YELLOW
   END DATEPICKER

   (nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode )

   DoMethod( xDlg, "CENTER" )
   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   ACTIVATE WINDOW ( xDlg )

   RETURN Nil

FUNCTION gui_DialogShow( xDlg )

   DoMethod( xDlg, "SHOW" )

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit )

   IF Empty( xDlg )
      xDlg := gui_NewName( "DIALOG" )
   ENDIF

   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF
   DEFINE WINDOW ( xDlg ) ;
      AT nCol, nRow ;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      TITLE cTitle ;
      ICON "ICOWINDOW" ;
      MODAL ;
      ON INIT Eval( bInit )
      gui_Statusbar( xDlg, "" )
   END WINDOW

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      RETURN _GetFocusedControl( xDlg ) == xControl

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := gui_NewName( "LABEL" )
   ENDIF
   // do not show border
   //DEFINE LABEL ( xControl )
   //   PARENT ( xDlg )
   //   COL nCol
   //   ROW nRow
   //   WIDTH nWidth
   //   HEIGHT nHeight
   //   VALUE xValue
   //   BORDER lBorder
   //END LABEL
   hb_Default( @lBorder, .F. )
   IF lBorder
      @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight BORDER
   ELSE
      @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight
   ENDIF
   (xDlg)

   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "HMG3"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_NewName( "MLTEXT" )
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
      /* NOHSCROLLBAR .T. */
   END EDITBOX
   (xDlg)

   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN Msgbox( cText )

FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

FUNCTION gui_SetFocus( xDlg, xControl )

   DoMethod( xDlg, xControl, "SETFOCUS" )

   RETURN Nil

FUNCTION gui_Statusbar( xDlg, xControl )

   IF Empty( xControl )
      xControl := gui_NewName( "STA" )
   ENDIF

	DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 PARENT ( xDlg )
		STATUSITEM "DlgAuto" // ACTION MsgInfo('Click! 1')
		//STATUSITEM "Item 2" 	WIDTH 100 ACTION MsgInfo('Click! 2')
		//STATUSITEM 'A Car!'	WIDTH 100 ICON 'Car.Ico'
		CLOCK
		DATE
	END STATUSBAR

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_NewName( "TAB" )
   ENDIF
   DEFINE TAB ( xControl ) ;
      PARENT ( xDlg ) ;
      AT nRow, nCol;
      WIDTH nWidth ;
      HEIGHT nHeight
   (xDlg)

   RETURN Nil

FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg);(xTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, xPage, nPageCount, cText )

   PAGE ( cText )
   xPage := xControl
   (xDlg); (xControl); (cText); (nPageCount)

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )

   END PAGE
   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, Self )

   IF Empty( xControl )
      xControl := gui_NewName( "TEXT" )
   ENDIF
   DEFINE TEXTBOX ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      HEIGHT    nHeight
      WIDTH     nWidth
      FONTNAME APP_FONTNAME
      IF ValType( xValue ) == "N"
         NUMERIC .T.
         INPUTMASK cPicture
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
      ELSE
         MAXLENGTH nMaxLength
      ENDIF
      VALUE     xValue
      IF ! Empty( bValid )
         ON LOSTFOCUS Eval( bValid )
      ENDIF
   END TEXTBOX
   IF aItem[ CFG_ISKEY ] .OR. ! Empty( aItem[ CFG_VTABLE ] )
      AAdd( ::aDlgKeyDown, { xControl, VK_F9, ;
         { || ::Browse( xDlg, xControl, iif( aItem[ CFG_ISKEY ], ::cFileDbf, aItem[ CFG_VTABLE ] ) ) } } )
   ENDIF
   (bValid); (xDlg); (cImage); (bAction)

   RETURN Nil

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_ControlGetValue( xDlg, xControl )

   (xDlg)

   RETURN GetProperty( xDlg, xControl, "VALUE" )

FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
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
