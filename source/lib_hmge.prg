/*
lib_hmge - HMG Extended source selected by lib.prg
*/

#include "frm_class.ch"

MEMVAR cTxtCode

FUNCTION gui_Init()

#ifdef DLGAUTO_AS_LIB
   #ifdef HBMK_HAS_HMGE
      Init()
   #endif
#endif
   SET GETBOX FOCUS BACKCOLOR TO {255,255,0}
   SET MENUSTYLE EXTENDED
   SET NAVIGATION EXTENDED
   SET WINDOW MAIN OFF

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   gui_DialogCreate( @xDlg, 0, 0,1024, 768, cTitle )

   DEFINE MAIN MENU OF ( xDlg )
      FOR EACH aGroupList IN aMenuList
         DEFINE POPUP "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup ) ICON "ICOWINDOW"
            NEXT
         END POPUP
      NEXT
      DEFINE POPUP "Sair"
         MENUITEM "Sair" ACTION gui_DialogClose( xDlg ) ICON "ICODOOR"
      END POPUP
      DEFINE MONTHCALENDAR ( "mcal001" )
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
      xControl := gui_newctlname( "BTN" )
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
      FONTNAME    DEFAULT_FONTNAME
      FONTSIZE    9
      FONTBOLD    .T.
      FONTCOLOR   COLOR_BLACK
      VERTICAL   .T.
      BACKCOLOR  COLOR_WHITE
      FLAT       .T.
      NOXPSTYLE  .T.
   END BUTTONEX

   cTxtCode += [   DEFINE BUTTONEX ( ] + ToPRG( xControl ) + [)] + hb_Eol()
   cTxtCode += [      PARENT ( ] + ToPRG( xDlg ) + [ )] + hb_Eol()
   cTxtCode += [      ROW         ] + ToPRG( nRow ) + hb_Eol()
   cTxtCode += [      COL         ] + ToPRG( nCol ) + hb_Eol()
   cTxtCode += [      WIDTH       ] + ToPRG( nWidth ) + hb_Eol()
   cTxtCode += [      HEIGHT      ] + ToPRG( nHeight ) + hb_Eol()
   cTxtCode += [      ICON        ] + ToPRG( cResName ) + hb_Eol()
   cTxtCode += [      IMAGEWIDTH  -1] + hb_Eol()
   cTxtCode += [      IMAGEHEIGHT -1] + hb_Eol()
   cTxtCode += [      CAPTION     ] + ToPRG( cCaption ) + hb_Eol()
   cTxtCode += [      ACTION      Eval( ] + ToPrg( bAction ) + [ )] + hb_Eol()
   cTxtCode += [      FONTNAME    ] + ToPRG( DEFAULT_FONTNAME ) + hb_Eol()
   cTxtCode += [      FONTSIZE    9] + hb_Eol()
   cTxtCode += [      FONTBOLD    .T.] + hb_Eol()
   cTxtCode += [      FONTCOLOR   ] + ToPRG( COLOR_BLACK ) + hb_Eol()
   cTxtCode += [      VERTICAL   .T.] + hb_Eol()
   cTxtCode += [      BACKCOLOR  ] + ToPrg( COLOR_WHITE ) + hb_Eol()
   cTxtCode += [      FLAT       .T.] + hb_Eol()
   cTxtCode += [      NOXPSTYLE  .T.] + hb_Eol()
   cTxtCode += [   END BUTTONEX] + hb_Eol()
   cTxtCode += hb_Eol()

   RETURN Nil

FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyCodeList, aDlgKeyCodeList )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem

   IF Empty( xControl )
      xControl := gui_newctlname( "BRW" )
   ENDIF
   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, aItem[2] )
      AAdd( aWidthList, ( 1 + Max( Len( aItem[3] ), ;
         Len( Transform( ( workarea )->( FieldGet( FieldNum( aItem[ 1 ] ) ) ), "" ) ) ) ) * 13 )
   NEXT

   DEFINE BROWSE ( xControl )
      PARENT ( xParent )
      ROW nRow
      COL nCol
      WIDTH nWidth - 20
      HEIGHT nHeight - 20
      IF ValType( aKeyCodeList ) != "A"
         aKeyCodeList := {}
         ONDBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
      ENDIF
      HEADERS aHeaderList
      WIDTHS aWidthList
      WORKAREA ( workarea )
      FIELDS aFieldList
      SET BROWSESYNC ON
   END BROWSE
   FOR EACH aItem IN aKeyCodeList
      AAdd( aDlgKeyCodeList, { xControl, aItem[ 1 ], aItem[ 2 ] } )
      _DefineHotKey( xDlg, 0, aItem[ 1 ], ;
         { || gui_DlgKeyDown( xDlg, xControl, aItem[ 1 ], workarea, cField, xValue, aDlgKeyCodeList ) } )
   NEXT

   (xDlg);(cField);(xValue);(workarea);(aKeyCodeList)

   RETURN Nil

STATIC FUNCTION gui_DlgKeyDown( xDlg, xControl, nKey, workarea, cField, xValue, aDlgKeyCodeList )

   LOCAL nPos, cType

   nPos := hb_AScan( aDlgKeyCodeList, { | e | GetProperty( xDlg, "FOCUSEDCONTROL" ) == e[1] .AND. nKey == e[ 2 ] } )
   IF nPos != 0
      Eval( aDlgKeyCodeList[ nPos ][ 3 ], cField, @xValue, xDlg, xControl )
   ENDIF
   IF nKey == VK_RETURN .AND. hb_ASCan( aDlgKeyCodeList, { | e | e[ 2 ] == VK_RETURN } ) != 0
      cType := GetProperty( xDlg, GetProperty( xDlg, "FOCUSEDCONTROL" ), "TYPE" )
      IF hb_AScan( { "GETBOX", "MASKEDTEXT", "TEXT", "SPINNER", "DATEPICKER", "CHECKBOX" }, { | e | e == cType } ) != 0
         _SetNextFocus()
      ENDIF
   ENDIF
   (xControl); (workarea)

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
      xControl := gui_NewCtlName( "CHK" )
   ENDIF
   DEFINE CHECKBOX ( xControl )
      PARENT ( xDlg )
      Row nRow
      COL nCol
      WIDTH nWidth
      HEIGHT nHeight
      CAPTION ""
   END CHECKBOX

   cTxtCode += [   DEFINE CHECKBOX ( ] + ToPrg( xControl ) + [ )] + hb_Eol()
   cTxtCode += [      PARENT ( ] + ToPrg( xDlg ) + [ )] + hb_Eol()
   cTxtCode += [      Row ] + ToPrg( nRow ) + hb_Eol()
   cTxtCode += [      COL ] + ToPrg( nCol ) + hb_Eol()
   cTxtCode += [      WIDTH ] + ToPrg( nWidth ) + hb_Eol()
   cTxtCode += [      HEIGHT ] + ToPrg( nHeight ) + hb_Eol()
   cTxtCode += [      CAPTION ""] + hb_Eol()
   cTxtCode += [   END CHECKBOX] + hb_Eol()
   cTxtCode += hb_Eol()

   RETURN Nil

FUNCTION gui_ComboCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, aList )

   IF Empty( xControl )
      xControl := gui_newctlname( "CBO" )
   ENDIF
   DEFINE COMBOBOX ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      VALUE 1
      WIDTH nWidth
      //HEIGHT nHeight // do not define height, it can limit list size to zero
      ITEMS aList
   END COMBOBOX

   cTxtCode += [   DEFINE COMBOBOX ( ] + ToPRG( xControl ) + [ )] + hb_Eol()
   cTxtCode += [      PARENT ( ] + ToPRG( xDlg ) + [ )] + hb_Eol()
   cTxtCode += [      ROW ] + ToPRG( nRow ) + hb_Eol()
   cTxtCode += [      COL ] + ToPRG( nCol ) + hb_Eol()
   cTxtCode += [      VALUE 1] + hb_Eol()
   cTxtCode += [      WIDTH ] + ToPRG( nWidth ) + hb_Eol()
   cTxtCode += [      HEIGHT ] + ToPRG( nHeight ) + hb_Eol()
   cTxtCode += [      ITEMS ] + ToPRG( aList ) + hb_Eol()
   cTxtCode += [   END COMBOBOX] + hb_Eol()
   cTxtCode += hb_Eol()
   ( nHeight )

   RETURN Nil

FUNCTION gui_SpinnerCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, aList )

   IF Empty( xControl )
      xControl := gui_newctlname( "SPI" )
   ENDIF
   DEFINE SPINNER ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      VALUE 1
      WIDTH nWidth
      //ON GOTFOCUS  SetProperty( xDlg, xControl, "BACKCOLOR", { 255, 255, 0 } )
      //ON LOSTFOCUS SetProperty( xDlg, xControl, "BACKCOLOR", { 255, 255, 255 } )
      RANGEMIN aList[ 1 ]
      RANGEMAX aList[ 2 ]
   END SPINNER
   ( nHeight )

   RETURN Nil

FUNCTION gui_DatePickerCreate( xDlg, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   IF Empty( xControl )
      xControl := gui_newctlname( "DTP" )
   ENDIF
   DEFINE DATEPICKER (xControl)
      PARENT ( xDlg )
      ROW	nRow
      COL	nCol
      VALUE dValue
      //ON GOTFOCUS SetProperty( xDlg, xControl, "BACKCOLOR", COLOR_YELLOW )
      //ON LOSTFOCUS SetProperty( xDlg, xControl, "BACKCOLOR", COLOR_WHITE )
      //DATEFORMAT "99/99/99"
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

   cTxtCode += [   DoMethod( ] + ToPrg( xDlg ) + [, "CENTER" )] + hb_Eol()
   cTxtCode += [   DoMethod( ] + ToPrg( xDlg ) + [, "ACTIVATE" )] + hb_Eol()
   cTxtCode += hb_Eol()


   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, xOldDlg )

   IF Empty( xDlg )
      xDlg := gui_newctlname( "DLG" )
   ENDIF

   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF
   DEFINE WINDOW ( xDlg ) ;
      AT nCol, nRow ;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      TITLE cTitle ;
      ICON "APPICON" ;
      ; // MODAL ; // bad using WINDOW MAIN OFF
      ON INIT Eval( bInit ) ;
      ON RELEASE iif( Empty( xOldDlg ), Nil, DoMethod( xOldDlg, "SETFOCUS" ) )
      IF ! Empty( xOldDlg )
         ON KEY ALT+F4 ACTION doMethod( xOldDlg, "SETFOCUS" )
      ENDIF
      gui_Statusbar( xDlg, "" )
   END WINDOW

   cTxtCode += [   DEFINE WINDOW ( ] + ToPrg( xDlg ) + [ ) ;] + hb_Eol()
   cTxtCode += [      AT ] + ToPrg( nCol ) + [, ] + ToPrg( nRow ) + [;] + hb_Eol()
   cTxtCode += [      WIDTH ] + ToPrg( nWidth ) + [;] + hb_Eol()
   cTxtCode += [      HEIGHT ] + ToPrg( nHeight ) + [ ;] + hb_Eol()
   cTxtCode += [      TITLE ] + ToPrg( cTitle ) + [;] + hb_Eol()
   cTxtCode += [      ICON "APPICON" ;] + hb_Eol()
   cTxtCode += [      ON INIT Eval( ] + ToPrg( bInit ) + [ ) ;] + hb_Eol()
   cTxtCode += [   END WINDOW] + hb_Eol()
   cTxtCode += hb_Eol()

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      RETURN GetProperty( xDlg, "FOCUSEDCONTROL" )  == xControl

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := gui_newctlname( "LBL" )
   ENDIF
   //nHeight := Round( nHeight, 0 )
   // não mostra borda
   DEFINE LABEL ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth
      HEIGHT nHeight
      VALUE xValue
      //FONTNAME "Times New Roman"
      //FONTSIZE nHeight - 6
      IF lBorder
         BORDER lBorder
         BACKCOLOR HMG_n2RGB( COLOR_GREEN )
      ENDIF
   END LABEL

   cTxtCode += [   DEFINE LABEL ( ] + ToPrg( xControl ) + [ )] + hb_Eol()
   cTxtCode += [      PARENT ( ] + ToPrg( xDlg ) + [ )] + hb_Eol()
   cTxtCode += [      COL ] + ToPrg( nCol ) + hb_Eol()
   cTxtCode += [      ROW ] + ToPrg( nRow ) + hb_Eol()
   cTxtCode += [      WIDTH ] + ToPrg( nWidth ) + hb_Eol()
   cTxtCode += [      HEIGHT ] + ToPrg( nHeight ) + hb_Eol()
   cTxtCode += [      VALUE ] + ToPrg( xValue ) + hb_Eol()
   IF lBorder
      cTxtCode += [      BORDER ] + ToPrg( lBorder ) + hb_Eol()
      cTxtCode += [      BACKCOLOR ] + ToPrg( COLOR_GREEN ) + hb_Eol()
   ENDIF
   cTxtCode += [   END LABEL] + hb_Eol()
   cTxtCode += hb_Eol()

   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "HMGE"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_newctlname( "MLTXT" )
   ENDIF
   DEFINE EDITBOX ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth
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

   DoMethod( xDlg, xControl, "SETFOCUS" )

   RETURN Nil

FUNCTION gui_Statusbar( xDlg, xControl )

   IF Empty( xControl )
      xControl := "STATUSBAR" // gui_NewCtlName( "STA" )
   ENDIF

	DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 PARENT ( xDlg )
		STATUSITEM "DlgAuto/FiveLibs" // ACTION MsgInfo('Click! 1')
		//STATUSITEM "Item 2" 	WIDTH 100 ACTION MsgInfo('Click! 2')
		//STATUSITEM 'A Car!'	WIDTH 100 ICON 'Car.Ico'
		CLOCK
		DATE
	END STATUSBAR
   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_newctlname( "TAB" )
   ENDIF
   DEFINE TAB ( xControl ) ;
      PARENT ( xDlg ) ;
      AT nRow, nCol;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      HOTTRACK

   cTxtCode += [   DEFINE TAB ( ] + ToPrg( xControl ) + [) ;] + hb_Eol()
   cTxtCode += [      PARENT ( ] + ToPrg( xDlg ) + [) ;] + hb_Eol()
   cTxtCode += [      AT ] + ToPRG( nRow ) + [, ] + ToPrg( nCol ) + [;] + hb_Eol()
   cTxtCode += [      WIDTH ] + ToPrg( nWidth ) + [ ;] + hb_Eol()
   cTxtCode += [      HEIGHT ] + ToPRG( nHeight ) + [ ;] + hb_Eol()
   cTxtCode += [      HOTTRACK] + hb_Eol()
   cTxtCode += hb_Eol()

   RETURN Nil

FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg);(xTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, xPage, nPageCount, cText )

   PAGE ( cText ) IMAGE "bmpfolder"

   cTxtCode += [   PAGE ( ] + ToPRG( cText ) + [ ) IMAGE "bmpfolder"] + hb_Eol()
   cTxtCode += hb_Eol()
   xPage := xControl
   // BACKCOLOR { 50, 50, 50 }
   (xDlg); (xControl); (cText); (nPageCount)

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )

   END PAGE

   cTxtCode += [   END PAGE] + hb_Eol()
   cTxtCode += hb_Eol()
   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage  )

   IF Empty( xControl )
      xControl := gui_newctlname( "TXT" )
   ENDIF
   //IF ! Empty( cImage )
      //DEFINE BTNTEXTBOX ( xControl )
   //ELSE
      DEFINE GETBOX ( xControl )
   //ENDIF
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      HEIGHT nHeight
      WIDTH nWidth
      FONTNAME DEFAULT_FONTNAME
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
      //ON LOSTFOCUS Eval( bValid )
      VALID bValid
   //IF ! Empty( cImage )
      //END BTNTEXTBOX
   //ELSE
      END GETBOX
   //ENDIF
   (bValid)

   RETURN Nil

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_TextGetValue( xDlg, xControl )

   LOCAL xValue

   xValue := GetProperty( xDlg, xControl, "VALUE" )
   (xDlg)

   RETURN xValue

FUNCTION gui_TextSetValue( xDlg, xControl, xValue )

   // NOTE: textbox string value, except if declared different on textbox creation
   // getbox????
   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

STATIC FUNCTION gui_newctlname( cPrefix )

   STATIC nCount := 0

   nCount += 1
   hb_Default( @cPrefix, "ANY" )

   RETURN cPrefix + StrZero( nCount, 10 )

STATIC FUNCTION ToPRG( xValue )

   DO CASE
   CASE ValType( xValue ) == "N"
      xValue := Ltrim( Str( xValue ) )
   CASE ValType( xValue ) == "C"
      xValue := ["] + xValue + ["]
   CASE ValType( xValue ) == "D"
      xValue := [Stod( ] + ToPRG( Dtos( Date() ) ) + [ )]
   CASE ValType( xValue ) == "L"
      xValue := iif( xValue, ".T.", ".F." )
   CASE ValType( xValue ) == "A"
      xValue := hb_ValToExp( xValue )
   CASE ValType( xValue ) == "B"
      xValue := [{ || Nil } /] + [* can't translate *] + [/]
   ENDCASE

   RETURN xValue
