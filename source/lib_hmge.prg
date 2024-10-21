/*
lib_hmge - HMG Extended source selected by lib.prg
*/

#include "hbclass.ch"
#include "frm_class.ch"
#include "hmg.ch"
#include "i_winuser.ch"

#ifndef DLGAUTO_AS_LIB
   MEMVAR pGenPrg, pGenName
#else
   STATIC pGenPrg := ""
#endif

THREAD STATIC nWindow := 0

#ifndef DLGAUTO_AS_LIB
THREAD STATIC oGUI

FUNCTION GUI( xValue )

   IF xValue != Nil
      oGUI := xValue
   ENDIF
   IF oGUI == Nil
      oGUI := HMGEClass():New()
   ENDIF

   RETURN oGUI
#endif

CREATE CLASS HMGEClass

   /*--- init ---*/
   METHOD LibName()             INLINE gui_LibName()
   METHOD Init()                INLINE gui_Init()

   /*--- dialog ---*/
   METHOD DialogActivate(...)   INLINE gui_DialogActivate(...)
   METHOD DialogClose(...)      INLINE gui_DialogClose(...)
   METHOD DialogCreate(...)     INLINE gui_DialogCreate(...)
   METHOD DlgSetKey(...)        INLINE gui_DlgSetKey(...)
   METHOD DlgMenu(...)          INLINE gui_DlgMenu(...)

   /*--- controls ---*/
   METHOD ButtonCreate(...)     INLINE gui_ButtonCreate(...)
   METHOD ComboCreate(...)      INLINE gui_ComboCreate(...)
   METHOD CheckboxCreate(...)   INLINE gui_CheckboxCreate(...)
   METHOD DatePickerCreate(...) INLINE gui_DatePickerCreate(...)
   METHOD SpinnerCreate(...)    INLINE gui_SpinnerCreate(...)
   METHOD LabelCreate(...)      INLINE gui_LabelCreate(...)
   METHOD MLTextCreate(...)     INLINE gui_MLTextCreate(...)
   METHOD Statusbar(...)        INLINE gui_Statusbar(...)
   METHOD TextCreate(...)       INLINE gui_TextCreate(...)

   /* browse */
   METHOD Browse(...)           INLINE gui_Browse(...)
   METHOD BrowseRefresh(...)    INLINE gui_BrowseRefresh(...)

   /* tab */
   METHOD TabCreate(...)        INLINE gui_TabCreate(...)
   METHOD TabEnd(...)           INLINE gui_TabEnd(...)
   METHOD TabPageBegin(...)     INLINE gui_TabPageBegin(...)
   METHOD TabPageEnd(...)       INLINE gui_TabPageEnd(...)
   METHOD TabNavigate(...)      INLINE gui_TabNavigate(...)

   /* msg */
   METHOD Msgbox(...)           INLINE gui_Msgbox(...)
   METHOD MsgYesNo(...)         INLINE gui_MsgYesNo(...)

   /* aux */
   METHOD IsCurrentFocus(...)   INLINE gui_IsCurrentFocus(...)
   METHOD SetFocus(...)         INLINE gui_SetFocus(...)
   METHOD ControlEnable(...)    INLINE gui_ControlEnable(...)
   METHOD ControlGetValue(...)  INLINE gui_ControlGetValue(...)
   METHOD ControlSetValue(...)  INLINE gui_ControlSetValue(...)

   ENDCLASS

STATIC FUNCTION gui_Init()

#ifdef DLGAUTO_AS_LIB
   Init()
#endif
   SET GETBOX FOCUS BACKCOLOR TO N2RGB( COLOR_YELLOW )
   SET MENUSTYLE EXTENDED
   SET NAVIGATION EXTENDED
   SET WINDOW MODAL PARENT HANDLE ON

   SET WINDOW MAIN OFF
   Set( _SET_DEBUG, .F. )

   pGenPrg += [   SET GETBOX FOCUS BACKCOLOR TO N2RGB( COLOR_YELLOW )] + hb_Eol()
   pGenPrg += [   SET MENUSTYLE EXTENDED] + hb_Eol()
   pGenPrg += [   SET NAVIGATION EXTENDED] + hb_Eol()
   pGenPrg += [   SET WINDOW MAIN OFF] + hb_Eol()
   pGenPrg += [   Set( _SET_DEBUG, .F. )] + hb_Eol()
   pGenPrg += hb_Eol()

   RETURN Nil

STATIC FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   gui_DialogCreate( Nil, @xDlg, 0, 0, APP_DLG_WIDTH, APP_DLG_HEIGHT, cTitle,,,.T. )

   DEFINE MAIN MENU OF ( xDlg )
      FOR EACH aGroupList IN aMenuList
         DEFINE POPUP "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_funcMain( cDBF, aAllSetup ) ICON "ICOWINDOW"
            NEXT
         END POPUP
      NEXT
      DEFINE POPUP "NoData"
         MENUITEM "NoData Layout 1" ACTION frm_DialogFree(1)
         MENUITEM "NoData Layout 2" ACTION frm_DialogFree(2)
         MENUITEM "NoData Layout 3" ACTION frm_DialogFree(3)
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

STATIC FUNCTION gui_ButtonCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF Empty( xControl )
      xControl := gui_NewName( "BTN" )
   ENDIF

   DEFINE BUTTONEX ( xControl )
      PARENT ( xParent )
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

   pGenPrg += [   DEFINE BUTTONEX ( ] + hb_ValToExp( xControl ) + [ )] + hb_Eol()
   pGenPrg += [      PARENT      ( ] + hb_ValToExp( xParent ) + [ )] + hb_Eol()
   pGenPrg += [      ROW         ] + hb_ValToExp( nRow ) + hb_Eol()
   pGenPrg += [      COL         ] + hb_ValToExp( nCol ) + hb_Eol()
   pGenPrg += [      WIDTH       ] + hb_ValToExp( nWidth ) + hb_Eol()
   pGenPrg += [      HEIGHT      ] + hb_ValToExp( nHeight ) + hb_Eol()
   pGenPrg += [      ICON        ] + hb_ValToExp( cResName ) + hb_Eol()
   pGenPrg += [      IMAGEWIDTH  -1] + hb_Eol()
   pGenPrg += [      IMAGEHEIGHT -1] + hb_Eol()
   pGenPrg += [      CAPTION      ] + hb_ValToExp( cCaption ) + hb_Eol()
   pGenPrg += [      ACTION      Eval( ] + hb_ValToExp( bAction ) + hb_Eol()
   pGenPrg += [      FONTNAME     ] + hb_ValToExp( APP_FONTNAME ) + hb_Eol()
   pGenPrg += [      FONTSIZE     7] + hb_Eol()
   pGenPrg += [      FONTBOLD     .T.] + hb_Eol()
   pGenPrg += [      FONTCOLOR    ] + hb_ValToExp( COLOR_BLACK ) + hb_Eol()
   pGenPrg += [      VERTICAL     .T.] + hb_Eol()
   pGenPrg += [      BACKCOLOR    ] + hb_ValToExp( COLOR_WHITE ) + hb_Eol()
   pGenPrg += [      FLAT         .T.] + hb_Eol()
   pGenPrg += [      NOXPSTYLE] + hb_Eol()
   pGenPrg += [   END BUTTONEX] + hb_Eol()
   pGenPrg += hb_Eol()

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, ;
   nHeight, oTbrowse, cField, xValue, workarea, aKeyDownList, oFrmClass )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem, aThisKey
   LOCAL aBrowseBackColor := {}, aBrowseForeColor := {}, nPos, cnSQL

   IF ofrmClass:lIsSQL
      cnSQL := ADOLocal()
   ENDIF
   IF Empty( xControl )
      xControl := gui_NewName( "BRW" )
   ENDIF

   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := {}
   ENDIF

   IF oFrmClass:lIsSQL
      // TODO: SQL
   ELSE
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
   ENDIF
   /* create buttons on browse for defined keys */
   IF Len( aKeyDownList ) != 0
      FOR EACH aThisKey IN aKeyDownList
         AAdd( oFrmClass:aControlList, EmptyFrmClassItem() )
         Atail( oFrmClass:aControlList )[ CFG_CTLTYPE ] := TYPE_BUTTON_BRW
         Atail( oFrmClass:aControlList )[ CFG_FCONTROL ] := gui_NewName( "BTNBRW" )
         gui_ButtonCreate( xDlg, xParent, @Atail( oFrmClass:aControlList )[ CFG_FCONTROL ], ;
         nRow - APP_LINE_SPACING, 200 + aThisKey:__EnumIndex() * APP_LINE_HEIGHT, APP_LINE_HEIGHT - 2, APP_LINE_HEIGHT - 2, "", ;
         iif( aThisKey[1] == VK_INSERT, "ICOPLUS", ;
         iif( aThisKey[1] == VK_DELETE, "ICOTRASH", ;
         iif( aThiskey[1] == VK_RETURN, "ICOEDIT", Nil ) ) ), aThisKey[2] )
      NEXT
   ENDIF
   /* redefine keys with cumulative actions */
   FOR EACH aItem IN aKeyDownList
      AAdd( oFrmClass:aDlgKeyDown, { xControl, aItem[ 1 ], aItem[ 2 ] } )
   NEXT

   (xDlg);(cField);(xValue);(workarea);(aKeyDownList);(cnSQL)

   RETURN Nil

STATIC FUNCTION gui_DlgKeyDown( xControl, nKey, oFrmClass )

   LOCAL nPos, cType, cFocusedControl

   cFocusedControl := GetProperty( oFrmClass:xDlg, "FOCUSEDCONTROL" )
   nPos := hb_AScan( oFrmClass:aDlgKeyDown, { | e | cFocusedControl == e[1] .AND. nKey == e[ 2 ] } )
   IF nPos != 0
      IF GetProperty( oFrmClass:xDlg, cFocusedControl, "ENABLED" )
         Eval( oFrmClass:aDlgKeyDown[ nPos ][ 3 ] )
      ENDIF
   ENDIF
   IF nKey == VK_RETURN .AND. hb_ASCan( oFrmClass:aDlgKeyDown, { | e | e[ 2 ] == VK_RETURN } ) != 0
      cType := GetProperty( oFrmClass:xDlg, cFocusedControl, "TYPE" )
      /* ENTER next focus, because a defined key can change default */
      IF hb_AScan( { "GETBOX", "MASKEDTEXT", "TEXT", "SPINNER", "DATEPICKER", "CHECKBOX" }, { | e | e == cType } ) != 0
         _SetNextFocus()
      ENDIF
   ENDIF
   (xControl)

   RETURN .T.

STATIC FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   IF ! Empty( cField )
      // without browsesync ON
      // (workarea)->( dbGoto( GetProperty( xDlg, xControl, "VALUE" ) ) )
      xValue := (workarea)->( FieldGet( FieldNum( cField ) ) )
   ENDIF
   (xControl)
   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

STATIC FUNCTION gui_BrowseRefresh( xDlg, xControl )

   // on older hmge versions, need to set browse value/recno()
   SetProperty( xDlg, xControl, "VALUE", RecNo() )
   DoMethod( xDlg, xControl, "REFRESH" )
   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_CheckboxCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_NewName( "CHK" )
   ENDIF

   DEFINE CHECKBOX ( xControl )
      PARENT ( xParent )
      Row nRow
      COL nCol
      WIDTH nWidth
      HEIGHT nHeight
      CAPTION ""
   END CHECKBOX

   pGenPrg += [   DEFINE CHECKBOX ( ] + hb_ValToExp( xControl ) + [ )] + hb_Eol()
   pGenPrg += [      PARENT     ( ] + hb_ValToExp( xParent ) + [ )] + hb_Eol()
   pGenPrg += [      ROW        ] + hb_ValToExp( nRow ) + hb_Eol()
   pGenPrg += [      COL        ] + hb_ValToExp( nCol ) + hb_Eol()
   pGenPrg += [      WIDTH      ] + hb_ValToExp( nWidth ) + hb_Eol()
   pGenPrg += [      HEIGHT     ] + hb_ValToExp( nHeight ) + hb_Eol()
   pGenPrg += [      CAPTION    ""] + hb_Eol()
   pGenPrg += [   END CHECKBOX] + hb_Eol()
   pGenPrg += hb_Eol()

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_ComboCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, aList, xValue )

   IF Empty( xControl )
      xControl := gui_NewName( "CBO" )
   ENDIF

   DEFINE COMBOBOX ( xControl )
      PARENT ( xParent )
      ROW nRow
      COL nCol
      VALUE xValue
      WIDTH nWidth
      // do not define height, it can limit list size to zero
      // HEIGHT nHeight
      ITEMS aList
   END COMBOBOX

   (nHeight); (xDlg)

   RETURN Nil

STATIC FUNCTION gui_SpinnerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, nValue, aList, oFrmClass )

   IF Empty( xControl )
      xControl := gui_NewName( "SPI" )
   ENDIF

   DEFINE SPINNER ( xControl )
      PARENT ( xParent )
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

   ( nHeight );(oFrmClass);(xDlg)

   RETURN Nil

STATIC FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   IF Empty( xControl )
      xControl := gui_NewName( "DTP" )
   ENDIF

   DEFINE DATEPICKER ( xControl )
      PARENT ( xParent )
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

   (nWidth);(nHeight);(xDlg)

   RETURN Nil

STATIC FUNCTION gui_DialogActivate( xDlg, bCode )

   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   DoMethod( xDlg, "CENTER" )
   DoMethod( xDlg, "ACTIVATE" )

   RETURN Nil

STATIC FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

STATIC FUNCTION gui_DialogCreate( oFrm, xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal )

   //nWindow += 1

   IF Empty( xDlg )
      xDlg := gui_NewName( "DLG" )
   ENDIF

   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF

   hb_Default( @lModal, .T. )
   cTitle := cTitle + " (" + GUI():LibName() + ")"

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

   (oFrm)

   RETURN Nil

STATIC FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   LOCAL lOk

   IF PCount() == 1
      lOk := ( GetActiveWindow() == GetProperty( XDlg, "HANDLE" ) )
   ELSE
      lOk := ( GetProperty( xDlg, "FOCUSEDCONTROL" )  == xControl )
   ENDIF

   RETURN lOk

STATIC FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder, nFontSize )

   IF Empty( xControl )
      xControl := gui_NewName( "LBL" )
   ENDIF

   hb_Default( @lBorder, .F. )
   hb_Default( @nFontSize, APP_FONTSIZE_SMALL )

   DEFINE LABEL ( xControl )
      PARENT ( xParent )
      COL nCol
      ROW nRow
      WIDTH nWidth
      HEIGHT nHeight
      VALUE xValue
      FONTNAME APP_FONTNAME
      FONTSIZE nFontSize
      IF lBorder
         BORDER lBorder
         BACKCOLOR N2RGB( COLOR_GREEN )
      ENDIF
   END LABEL

   pGenPrg += [   DEFINE LABEL ( ] + hb_ValToExp( xControl ) + [ )] + hb_Eol()
   pGenPrg += [      PARENT ( ] + hb_ValToExp( xParent ) + [ )] + hb_Eol()
   pGenPrg += [      COL ] + hb_ValToExp( nCol ) + hb_Eol()
   pGenPrg += [      ROW ] + hb_ValToExp( nRow ) + hb_Eol()
   pGenPrg += [      WIDTH ] + hb_ValToExp( nWidth ) + hb_Eol()
   pGenPrg += [      HEIGHT ] + hb_ValToExp( nHeight ) + hb_Eol()
   pGenPrg += [      VALUE ] + hb_ValToExp( xValue ) + hb_Eol()
   pGenPrg += [      FONTNAME APP_FONT_NAME ] + hb_Eol()
   pGenPrg += [      FONTSIZE ] + hb_ValToExp( nFontSize ) + hb_Eol()
   IF lBorder
      pGenPrg += [      BORDER ] + hb_ValToExp( lBorder ) + hb_Eol()
      pGenPrg += [      BACKCOLOR N2RGB( COLOR_GREEN )] + hb_Eol()
   ENDIF
   pGenPrg += [   END LABEL] + hb_Eol()
   pGenPrg += hb_Eol()

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_LibName()

   RETURN "HMGE"

STATIC FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_NewName( "MLTXT" )
   ENDIF

   DEFINE EDITBOX ( xControl )
      PARENT ( xParent )
      COL nCol
      ROW nRow
      WIDTH nWidth - 30 /* scrollbar */
      HEIGHT nHeight
      VALUE xValue
      FONTNAME PREVIEW_FONTNAME
      FONTSIZE APP_FONTSIZE_SMALL
      TOOLTIP 'EditBox'
   END EDITBOX

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_Msgbox( cText )

   RETURN Msgbox( cText )

STATIC FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

STATIC FUNCTION gui_SetFocus( xDlg, xControl )

   IF Empty( xControl )
      DoMethod( xDlg, "SETFOCUS" )
   ELSE
      DoMethod( xDlg, xControl, "SETFOCUS" )
   ENDIF

   RETURN Nil

STATIC FUNCTION gui_Statusbar( xDlg, xControl )

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

STATIC FUNCTION gui_TabCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_NewName( "TAB" )
   ENDIF

   DEFINE TAB ( xControl ) ;
      PARENT ( xParent ) ;
      AT nRow, nCol;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      HOTTRACK
      // BACKCOLOR { 226, 220, 213 }

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

STATIC FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg);(xTab);(aList)

   RETURN Nil

STATIC FUNCTION gui_TabPageBegin( xDlg, xParent, xTab, xPage, nPageCount, cText )

   PAGE ( cText ) IMAGE "bmpfolder"

   xPage := xDlg
   // BACKCOLOR { 50, 50, 50 }
   (xDlg); (xTab); (cText); (nPageCount); (xParent)

   RETURN Nil

STATIC FUNCTION gui_TabPageEnd( xDlg, xControl )

   END PAGE

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_TextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, oFrmClass, lPassword )

   IF Empty( xControl )
      xControl := gui_NewName( "TEXT" )
   ENDIF

   hb_Default( @lPassword, .F. )

   DEFINE GETBOX ( xControl )
      PARENT ( xParent )
      ROW nRow
      COL nCol
      HEIGHT nHeight
      WIDTH nWidth
      FONTNAME APP_FONTNAME
      FONTSIZE APP_FONTSIZE_NORMAL - 3
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
         /* when call a dialog from bvalid, valid on next dialog does not works */
         // VALID bValid
      ENDIF
      IF lPassword
         PASSWORD .T.
         UPPERCASE .T.
      ENDIF
   END GETBOX
   /* F9 on key fields will make a browse but click on button does the same */
   IF aItem[ CFG_ISKEY ] .OR. ! Empty( aItem[ CFG_VTABLE ] )
      AAdd( oFrmClass:aDlgKeyDown, { xControl, VK_F9, ;
         { || oFrmClass:Browse( xDlg, xControl, iif( aItem[ CFG_ISKEY ], oFrmClass:cDataTable, aItem[ CFG_VTABLE ] ) ) } } )
   ENDIF

   pGenPrg += [   DEFINE GETBOX ( ] + hb_ValToExp( xControl ) + [ )] + hb_Eol()
   pGenPrg += [      PARENT    ( ] + hb_ValToExp( xParent ) + [ )] + hb_Eol()
   pGenPrg += [      ROW       ] + hb_ValToExp( nRow ) + hb_Eol()
   pGenPrg += [      COL       ] + hb_ValToExp( nCol ) + hb_Eol()
   pGenPrg += [      HEIGHT    ] + hb_ValToExp( nHeight ) + hb_Eol()
   pGenPrg += [      WIDTH     ] + hb_ValToExp( nWidth ) + hb_Eol()
   pGenPrg += [      FONTNAME  ] + hb_ValToExp( APP_FONTNAME ) + hb_Eol()
   pGenPrg += [      FONTSIZE  ] + hb_ValToExp( APP_FONTSIZE_NORMAL - 3 ) + hb_Eol()
   IF ValType( xValue ) == "N"
      pGenPrg += [      NUMERIC   .T.] + hb_Eol()
      pGenPrg += [      INPUTMASK ] + hb_ValToExp( cPicture ) + hb_Eol()
   ELSEIF ValType( xValue ) == "D"
      pGenPrg += [      DATE      .T.] + hb_Eol()
      pGenPrg += [      DATEFORMAT ] + hb_ValToExp( cPicture ) + hb_Eol()
   ELSEIF ValType( xValue ) == "L" // workaround to do not get error
      xValue := " "
   ELSEIF ValType( xValue ) == "C"
      pGenPrg += [      MAXLENGTH ] + hb_ValToExp( nMaxLength ) + hb_Eol()
   ENDIF
   pGenPrg += [      VALUE ] + hb_ValToExp( xValue ) + hb_Eol()
   IF ! Empty( bAction )
      pGenPrg += [      ACTION Eval( ] + hb_ValToExp( bAction ) + [ )] + hb_Eol()
   ENDIF
   IF ! Empty( cImage )
     pGenPrg += [      IMAGE    ] + hb_ValToExp( cImage ) + hb_Eol()
   ENDIF
   IF ! Empty( bValid )
      pGenPrg += [      ON LOSTFOCUS Eval( ] + hb_ValToExp( bValid ) + [ )] + hb_Eol()
      /* when call a dialog from bvalid, valid on next dialog does not works */
      // VALID bValid
   ENDIF
   IF lPassword
      pGenPrg += [      PASSWORD .T.] + hb_Eol()
      pGenPrg += [      UPPERCASE .T.] + hb_Eol()
   ENDIF
   pGenPrg += [   END GETBOX] + hb_Eol()
   pGenPrg += hb_Eol()

   (bValid)

   RETURN Nil

STATIC FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

STATIC FUNCTION gui_ControlGetValue( xDlg, xControl )

   LOCAL xValue

   xValue := GetProperty( xDlg, xControl, "VALUE" )
   (xDlg)

   RETURN xValue

STATIC FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   /* textbox string value, but depends textbox creation */
   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

STATIC FUNCTION gui_DlgSetKey( oFrmClass )

   LOCAL aItem

   FOR EACH aItem IN oFrmClass:aDlgKeyDown
         _DefineHotKey( oFrmClass:xDlg, 0, aItem[ 2 ], { || gui_DlgKeyDown( aItem[1], ;
            aItem[ 2 ], oFrmClass ) } )
   NEXT

   RETURN Nil

/* unique names on multithread too */

FUNCTION gui_NewName( cPrefix )

   STATIC nCount := 0

   nCount += 1
   hb_Default( @cPrefix, "ANY" )

   RETURN cPrefix + hb_ValToExp( nCount )

