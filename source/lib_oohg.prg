/*
lib_oohg - oohg source selected by lib.prg

Note: Or use name or object, but can't mix on this source code
*/

#include "hbclass.ch"
#include "frm_class.ch"
#include "oohg.ch"
#include "i_altsyntax.ch"

#ifdef DLGAUTO_AS_LIB
   STATIC pGenPrg := ""
#else
   MEMVAR pGenPrg, pGenName
#endif

#ifndef DLGAUTO_AS_LIB
THREAD STATIC oGUI

FUNCTION GUI( xValue )

   IF xValue != Nil
      oGUI := xValue
   ENDIF
   IF oGUI == Nil
      oGUI := OOHGClass():New()
   ENDIF

   RETURN oGUI
#endif

CREATE CLASS OOHGClass

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

   SET MENUSTYLE EXTENDED
   SET NAVIGATION EXTENDED

   RETURN Nil

STATIC FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   gui_DialogCreate( @xDlg, 0, 0, APP_DLG_WIDTH, APP_DLG_HEIGHT, cTitle )

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
      DEFINE MONTHCALENDAR( gui_NewName( "CAL" ) )
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
      xControl := gui_NewName( "BUTTON" )
   ENDIF

   IF cCaption == "Cancel"
      @ nRow, nCol BUTTON ( xControl ) ;
         PARENT ( xParent ) ;
         CAPTION  cCaption ;
         PICTURE  cResName ;
         ACTION   Eval( bAction ) ;
         WIDTH    nWidth ;
         HEIGHT   nHeight ;
         IMAGEALIGN TOP ;
         CANCEL // abort valid
   ELSE
      @ nRow, nCol BUTTON ( xControl ) ;
         PARENT ( xParent ) ;
         CAPTION  cCaption ;
         PICTURE  cResName ;
         ACTION   Eval( bAction ) ;
         WIDTH    nWidth ;
         HEIGHT   nHeight ;
         IMAGEALIGN TOP
   ENDIF

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, ;
   nHeight, oTbrowse, cField, xValue, workarea, aKeyDownList, oFrmClass )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem, aThisKey

   IF Empty( xControl )
      xControl := gui_NewName( "BROWSE" )
   ENDIF

   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := {}
   ENDIF

   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, { || Transform( FieldGet( FieldNum( aItem[2] ) ), aItem[3] ) } )
      AAdd( aWidthList, ( 1 + Max( Len( aItem[1] ), ;
         Len( Transform( FieldGet( FieldNum(aItem[ 1 ] ) ), aItem[ 3 ] ) ) ) ) * 13 )
   NEXT
   IF Len( aKeyDownList ) != 0
      @ nRow, nCol BROWSE ( xControl ) ;
         OF ( xParent ) ;
         WIDTH nWidth - 20 ;
         HEIGHT nHeight - 20 ;
         HEADERS aHeaderList ;
         WIDTHS aWidthList ;
         WORKAREA ( workarea ) ;
         FIELDS aFieldList
   ELSE
      @ nRow, nCol BROWSE ( xControl ) ;
         OF ( xParent ) ;
         WIDTH nWidth - 20 ;
         HEIGHT nHeight - 20 ;
         HEADERS aHeaderList ;
         WIDTHS aWidthList ;
         WORKAREA ( workarea ) ;
         FIELDS aFieldList ;
         ON DBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
   ENDIF
   IF Len( aKeyDownList ) != 0
      FOR EACH aThisKey IN aKeyDownList
         AAdd( oFrmClass:aControlList, EmptyFrmClassItem() )
         Atail( oFrmClass:aControlList )[ CFG_CTLTYPE ] := TYPE_BUTTON_BRW
         Atail( oFrmClass:aControlList )[ CFG_FCONTROL ] := gui_NewName( "BTNBRW" )
         gui_ButtonCreate( xDlg, xParent, @Atail( oFrmClass:aControlList )[ CFG_FCONTROL ], ;
            nRow - APP_LINE_SPACING, 200 + aThisKey:__EnumIndex() * APP_LINE_HEIGHT, ;
            APP_LINE_HEIGHT - 2, APP_LINE_HEIGHT - 2, "", ;
            iif( aThisKey[1] == VK_INSERT, "ICOPLUS", ;
            iif( aThisKey[1] == VK_DELETE, "ICOTRASH", ;
            iif( aThiskey[1] == VK_RETURN, "ICOEDIT", Nil ) ) ), aThisKey[2] )
      NEXT
      FOR EACH aItem IN aKeyDownList
         AAdd( oFrmClass:aDlgKeyDown, { xControl, aItem[ 1 ], aItem[ 2 ] } )
      NEXT
   ENDIF

   (cField);(xValue)

   RETURN Nil

STATIC FUNCTION gui_DlgKeyDown( xControl, nKey, oFrmClass )

   LOCAL nPos, cFocusedControl, lReturn := .T., cType

   nPos := hb_AScan( oFrmClass:aDlgKeyDown, { | e | GetProperty( oFrmClass:xDlg, "FOCUSEDCONTROL" ) == e[1] .AND. nKey == e[ 2 ] } )
   IF nPos != 0
      lReturn := Eval( oFrmClass:aDlgKeyDown[ nPos ][ 3 ] )
   ENDIF
   IF nKey == VK_RETURN .OR. lReturn == Nil .OR. lReturn
      cFocusedControl := GetProperty( oFrmClass:xDlg, "FOCUSEDCONTROL" )
      cType := GetControlObject( cFocusedControl, oFrmClass:xDlg ):Type
      IF hb_AScan( { "NUMTEXT", "TEXT" }, { | e | e == cType } ) != 0
         _SetNextFocus()
      ENDIF
   ENDIF

   (xControl)

   RETURN .T.

STATIC FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   LOCAL nRecNo

   IF ! Empty( cField )
      nRecNo := GetProperty( xDlg, xControl, "VALUE" )
      GOTO ( nRecNo )
      xValue := (workarea)->( FieldGet( FieldNum( cField ) ) )
   ENDIF
   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

STATIC FUNCTION gui_BrowseRefresh( xDlg, xControl )

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
      //HEIGHT nHeight // do not define height, it limits can list size to zero
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
      RANGEMIN aList[ 1 ]
      RANGEMAX aList[ 2 ]
   END SPINNER

   (nHeight); (oFrmClass); (xDlg)

   RETURN Nil

STATIC FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   IF Empty( xControl )
      xControl := gui_NewName( "DTP" )
   ENDIF

   DEFINE DATEPICKER (xControl)
      PARENT ( xParent )
      ROW	nRow
      COL	nCol
      VALUE dValue
      //DATEFORMAT "99/99/99"
      TOOLTIP 'DatePicker Control'
      SHOWNONE .F.
      TITLEBACKCOLOR BLACK
      TITLEFONTCOLOR YELLOW
      TRAILINGFONTCOLOR PURPLE
   END DATEPICKER

   (nWidth);(nHeight); (xDlg)

   RETURN Nil

STATIC FUNCTION gui_DialogActivate( xDlg, bCode )

   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   DoMethod( xDlg, "CENTER" )
   ACTIVATE WINDOW ( xDlg )

   RETURN Nil

STATIC FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

STATIC FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal )

   IF Empty( xDlg )
      xDlg := gui_NewName( "DIALOG" )
   ENDIF
   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF

   hb_Default( @lModal, .F. )
   IF lModal
      DEFINE WINDOW ( xDlg ) ;
         AT     nCol, nRow ;
         WIDTH  nWidth ;
         HEIGHT nHeight ;
         TITLE  cTitle + " (" + GUI():LibName() + ")"  ;
         ICON "ICOWINDOW" ;
         MODAL ;
         ON INIT Eval( bInit )
         gui_Statusbar( xDlg, "" )
      END WINDOW
   ELSE
      DEFINE WINDOW ( xDlg ) ;
         AT     nCol, nRow ;
         WIDTH  nWidth ;
         HEIGHT nHeight ;
         TITLE  cTitle + " )" + GUI():LibName() + ")" ;
         ICON "ICOWINDOW" ;
         ON INIT Eval( bInit )
         gui_Statusbar( xDlg, "" )
      END WINDOW
   ENDIF

   RETURN Nil

//   WITH OBJECT xDlg := TForm():Define()
//      :Row := 500
//      :Col := 1000
//      :Width := APP_DLG_WIDTH
//      :Height := APP_DLG_HEIGHT
//      :Title := oFrmClass:cDataTable
//      // :Init := oFrmClass:DataLoad()
//   ENDWITH
//    _EndWindow()

STATIC FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   LOCAL lOk

   IF PCount() == 1
      lOk := ( GetActiveWindow() == GetProperty( XDlg, "HANDLE" ) )
   ELSE
      // not used, solved on button using CANCEL
      lOk := GetFocus() == GetProperty( xDlg, xControl, "HWND" )
   ENDIF

   RETURN lOk

STATIC FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := gui_NewName( "LABEL" )
   ENDIF
   hb_Default( @lBorder, .F. )
   IF lBorder
      @ nRow, nCol LABEL ( xControl ) ;
         PARENT ( xParent ) ;
         VALUE  xValue ;
         WIDTH  nWidth ;
         HEIGHT nHeight ;
         BORDER
   ELSE
      @ nRow, nCol LABEL ( xControl ) PARENT ( xParent ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight
   ENDIF
   //WITH OBJECT xControl := TLabel():Define()
   //   :Parent := xDlg
   //   :Row := nRow
   //   :Col := nCol
   //   :Value := xValue
   //   :AutoSize := .T.
   //   :Width := nWidth
   //   :Height := nHeight
   //   //:Border := lBorder
   //ENDWITH

   (xDlg); (lBorder)

   RETURN Nil

STATIC FUNCTION gui_LibName()

   RETURN "OOHG"

STATIC FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_NewName( "MLTEXT" )
   ENDIF

   DEFINE EDITBOX ( xControl )
      PARENT ( xParent )
      ROW      nRow
      COL      nCol
      HEIGHT   nHeight
      WIDTH    nWidth - 30 /* scrollbar */
      FONTNAME PREVIEW_FONTNAME
      VALUE     xValue
      SETBREAK  .T.
      MAXLENGTH 510000
      /* NOHSCROLLBAR .T. */
   END EDITBOX

   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight); (xValue)

   RETURN Nil

STATIC FUNCTION gui_Msgbox( cText )

   RETURN Msgbox( cText )

STATIC FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

STATIC FUNCTION gui_SetFocus( xDlg, xControl )

   IF PCount() == 1
      DoMethod( xDlg, "SETFOCUS" )
   ELSE
      DoMethod( xDlg, xControl, "SETFOCUS" )
   ENDIF

   RETURN Nil

STATIC FUNCTION gui_Statusbar( xDlg, xControl )

   IF Empty( xControl )
      xControl := gui_NewName( "STA" )
   ENDIF

	DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 PARENT (xDlg )
		STATUSITEM "DlgAuto/FiveLibs" // ACTION MsgInfo('Click! 1')
		//STATUSITEM "Item 2" 	WIDTH 100 ACTION MsgInfo('Click! 2')
		//STATUSITEM 'A Car!'	WIDTH 100 ICON 'Car.Ico'
		CLOCK
		DATE
	END STATUSBAR

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
      VALUE 1

   xControl := xDlg // because they are not on tab

   (nRow); (nCol); (nWidth); (nHeight); (xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

STATIC FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg);(xTab);(aList)

   RETURN Nil

STATIC FUNCTION gui_TabPageBegin( xDlg, xParent, xControl, xPage, nPageCount, cText )

   DEFINE PAGE cText
   xPage := xControl

   (xDlg); (xControl); (cText); (nPageCount); (xParent)

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

   DEFINE TEXTBOX ( xControl )
      PARENT ( xParent )
      ROW      nRow
      COL      nCol
      HEIGHT   nHeight
      WIDTH    nWidth
      FONTNAME APP_FONTNAME
      IF ValType( xValue ) == "N"
         NUMERIC .T.
         //INPUTMASK cPicture
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
         //DATEFORMAT cPicture
      ELSE
         MAXLENGTH nMaxLength
      ENDIF
      VALUE     xValue
      IF ! Empty( bValid )
         ON LOSTFOCUS Eval( bValid )
      ENDIF
      IF lPassword
         PASSWORD .T.
         UPPERCASE .T.
      ENDIF
   END TEXTBOX

   (bAction);(cImage);(cPicture);(aItem);(oFrmClass);(xDlg)

   RETURN Nil

   // not confirmed
   // WITH OBJECT aItem[ CFG_FCONTROL ] := TText():Define()
   //    :Row    := nRow2
   //    :Col    := nCol2
   //    :Width  := aItem[ CFG_FLEN ] * 12
   //    :Height := oFrmClass:nLineHeight
   //    :Value  := aItem[ CFG_VALUE ]
   // ENDWITH

STATIC FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

STATIC FUNCTION gui_ControlGetValue( xDlg, xControl )

   (xDlg)

   RETURN GetProperty( xDlg, xControl, "VALUE" )

STATIC FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )

   RETURN Nil

STATIC FUNCTION gui_DlgSetKey( oFrmClass )

   LOCAL aItem

   FOR EACH aItem IN oFrmClass:aDlgKeyDown
         _DefineHotKey( oFrmClass:xDlg, 0, aItem[ 2 ], { || gui_DlgKeyDown( aItem[1], ;
            aItem[ 2 ], oFrmClass ) } )
   NEXT

   RETURN Nil

FUNCTION gui_NewName( cPrefix )

   STATIC nCount := 0

   hb_Default( @cPrefix, "ANY" )
   nCount += 1

   RETURN cPrefix  + StrZero( nCount, 10 )

