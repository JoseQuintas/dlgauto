/*
lib_hmg3 - HMG3 source selected by lib.prg
*/

#include "hbclass.ch"
#include "frm_class.ch"
#include "hmg.ch"
#include "i_altsyntax.ch"

MEMVAR _HMG_SYSDATA
MEMVAR _HMG_MainWindowFirst

#ifdef DLGAUTO_AS_LIB
   STATIC pGenPrg := ""
#else
   MEMVAR pGenPrg
#endif

CREATE CLASS HMG3Class

   /*--- init ---*/
   METHOD LibName()             INLINE "HMG3"
   METHOD Init()                INLINE gui_Init()

   /*--- dialog ---*/
   METHOD DialogActivate(...)   INLINE gui_DialogActivate(...)
   METHOD DialogClose(...)      INLINE gui_DialogClose(...)
   METHOD DialogCreate(...)     INLINE gui_DialogCreate(...)
   METHOD DlgSetKey(...)        INLINE gui_DlgSetKey(...)
   METHOD DlgMenu(...)          INLINE gui_DlgMenu(...)
   METHOD DlgKeyDown(...)       INLINE gui_DlgKeyDown(...)

   /*--- controls ---*/
   METHOD ButtonCreate(...)     INLINE gui_ButtonCreate(...)
   METHOD ComboCreate(...)      INLINE gui_ComboCreate(...)
   METHOD CheckboxCreate(...)   INLINE gui_CheckboxCreate(...)
   METHOD DatePickerCreate(...) INLINE gui_DatePickerCreate(...)
   METHOD SpinnerCreate(...)    INLINE gui_SpinnerCreate(...)
   METHOD LabelCreate(...)      INLINE gui_LabelCreate(...)
   METHOD MLTextCreate(...)     INLINE gui_MLTextCreate(...)
   METHOD StatusCreate(...)     INLINE gui_StatusCreate(...)
   METHOD TextCreate(...)       INLINE gui_TextCreate(...)

   /* browse */
   METHOD Browse(...)           INLINE gui_Browse(...)
   METHOD BrowseRefresh(...)    INLINE gui_BrowseRefresh(...)
   METHOD browsekeydown(...)    INLINE gui_browsekeydown(...)
   METHOD SetBrowseKeyFilter(...) INLINE Nil

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
   METHOD NewName(...)          INLINE gui_NewName(...)

   ENDCLASS

STATIC FUNCTION gui_Init()

#ifdef DLGAUTO_AS_LIB
   Init()
#endif
   SET WINDOW MAIN OFF
   SET NAVIGATION EXTENDED
   SET BROWSESYNC ON

   RETURN Nil

STATIC FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   GUI():DialogCreate( Nil, @xDlg, 0, 0, 1024, 768, cTitle, , .T. )

   DEFINE MAIN MENU OF ( xDlg )
      FOR EACH aGroupList IN aMenuList
         DEFINE POPUP "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_funcMain( cDBF, aAllSetup )
            NEXT
         END POPUP
      NEXT
      DEFINE POPUP "NoData"
         MENUITEM "NoData Layout 1" ACTION frm_DialogFree(1)
         MENUITEM "NoData Layout 2" ACTION frm_DialogFree(2)
         MENUITEM "NoData Layout 3" ACTION frm_DialogFree(3)
      END POPUP
      DEFINE POPUP "Exit"
         MENUITEM "Exit" ACTION GUI():DialogClose( xDlg )
      END POPUP
      DEFINE MONTHCALENDAR ( GUI():NewName( "CAL" ) )
         PARENT ( xDlg )
         COL 400
         ROW 400
         VALUE Date()
      END MONTHCALENDAR
   END MENU

   GUI():DialogActivate( xDlg )

   RETURN Nil

STATIC FUNCTION gui_ButtonCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF Empty( xControl )
      xControl := GUI():NewName( "BUTTON" )
   ENDIF

   DEFINE BUTTON ( xControl )
      PARENT ( xParent )
      ROW           nRow
      COL           nCol
      WIDTH         nWidth
      HEIGHT        nHeight
      CAPTION       cCaption
      // do not show ico ??
      PICTURE       cResName
      // default // PICTALIGNMENT TOP
      ACTION         Eval( bAction )
   END BUTTON

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(cCaption);(cResName);(bAction)

   RETURN Nil

STATIC FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyDownList, oFrmClass )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem, aThisKey, nPos

   IF Empty( xControl )
      xControl := GUI():NewName( "BRW" )
   ENDIF
   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := {}
   ENDIF
   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, aItem[2] )
      AAdd( aWidthList, ( 1 + Max( Len( aItem[3] ), Len( Transform(FieldGet(FieldNum(aItem[1] ) ), "" ) ) ) ) * 13 )
   NEXT
   DEFINE GRID ( xControl )
      ROW          nRow
      COL          nCol
      WIDTH        nWidth - 40
      HEIGHT       nHeight - 40
      PARENT ( xParent )
      IF Len( aKeyDownList ) == 0
         ONDBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
      ELSEIF ( nPos := hb_AScan( aKeyDownList, { | e | e[1] == VK_RETURN } ) ) != 0
         ONDBLCLICK Eval( aKeyDownList[ nPos ][ 2 ] )
      ENDIF
      HEADERS      aHeaderList
      WIDTHS       aWidthList
      ROWSOURCE    ( workarea )
      COLUMNFIELDS aFieldList
      // VIRTUAL
   END GRID
   IF Len( aKeyDownList ) != 0
      FOR EACH aThisKey IN aKeyDownList
         AAdd( oFrmClass:aControlList, EmptyFrmClassItem() )
         Atail( oFrmClass:aControlList )[ CFG_CTLTYPE ] := TYPE_BUTTON_BRW
         Atail( oFrmClass:aControlList )[ CFG_FCONTROL ] := GUI():NewName( "BTNBRW" )
         GUI():ButtonCreate( xDlg, xParent, @Atail( oFrmClass:aControlList )[ CFG_FCONTROL ], ;
         nRow - APP_LINE_SPACING, 200 + aThisKey:__EnumIndex() * APP_LINE_HEIGHT, APP_LINE_HEIGHT - 2, APP_LINE_HEIGHT - 2, "", ;
         iif( aThisKey[1] == VK_INSERT, "ICOPLUS", ;
         iif( aThisKey[1] == VK_DELETE, "ICOTRASH", ;
         iif( aThiskey[1] == VK_RETURN, "ICOEDIT", Nil ) ) ), aThisKey[2] )
      NEXT
   ENDIF
   FOR EACH aItem IN aKeyDownList
      AAdd( oFrmClass:aDlgKeyDown, { xControl, aItem[ 1 ], aItem[ 2 ] } )
   NEXT

   (xDlg);(cField);(xValue);(workarea);(xParent)

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
      IF ! Empty( cFocusedControl )
         cType := GetProperty( oFrmClass:xDlg, cFocusedControl, "TYPE" )
         IF hb_AScan( { "GETBOX", "MASKEDTEXT", "TEXT" }, { | e | e == cType } ) != 0
            _SetNextFocus()
         ENDIF
      ENDIF
   ENDIF

   (xControl)

   RETURN .T.

STATIC FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   LOCAL nRecNo

   IF ! Empty( cField )
      nRecNo := GetProperty( xDlg, xControl, "RECNO" )
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
      xControl := GUI():NewName( "CHK" )
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

   hb_Default( @xValue, 1 )
   IF Empty( xControl )
      xControl := GUI():NewName( "CBO" )
   ENDIF
   DEFINE COMBOBOX ( xControl )
      PARENT ( xParent )
      ROW nRow
      COL nCol
      VALUE xValue
      WIDTH nWidth
      HEIGHT nHeight
      ITEMS aList
   END COMBOBOX

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_SpinnerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, nValue, aList, oFrmClass )

   IF Empty( xControl )
      xControl := GUI():NewName( "SPI" )
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

   ( nHeight ); (oFrmClass); (xDlg)

   RETURN Nil

STATIC FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   IF Empty( xControl )
      xControl := GUI():NewName( "DTP" )
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
   END DATEPICKER

   (nWidth);(nHeight); (xDlg)

   RETURN Nil

STATIC FUNCTION gui_DialogActivate( xDlg, bCode )

   DoMethod( xDlg, "CENTER" )
   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   ACTIVATE WINDOW ( xDlg )

   RETURN Nil

STATIC FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

STATIC FUNCTION gui_DialogCreate( oFrm, xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal )

   IF Empty( xDlg )
      xDlg := GUI():NewName( "DIALOG" )
   ENDIF

   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF
   hb_Default( @lModal, .F. )
   lModal := iif( lModal, .T., .T. )

   IF lModal
      DEFINE WINDOW ( xDlg ) ;
         AT nCol, nRow ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE cTitle + " (" + GUI():LibName() + ")" ;
         ICON "ICOWINDOW" ;
         MODAL ;
         ON INIT Eval( bInit )
         GUI():StatusCreate( xDlg, "" )
      END WINDOW
   ELSE
      DEFINE WINDOW ( xDlg ) ;
         AT nCol, nRow ;
         WIDTH nWidth ;
         HEIGHT nHeight ;
         TITLE cTitle + " (" + gui():LibName() + ")" ;
         ICON "ICOWINDOW" ;
         ON INIT Eval( bInit )
         GUI():StatusCreate( xDlg, "" )
      END WINDOW
   ENDIF

   (oFrm)

   RETURN Nil

STATIC FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      RETURN _GetFocusedControl( xDlg ) == xControl

STATIC FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := GUI():NewName( "LABEL" )
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
      @ nRow, nCol LABEL ( xControl ) PARENT ( xParent ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight BORDER
   ELSE
      @ nRow, nCol LABEL ( xControl ) PARENT ( xParent ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight
   ENDIF

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := GUI():NewName( "MLTEXT" )
   ENDIF
   DEFINE EDITBOX ( xControl )
      PARENT ( xParent )
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

STATIC FUNCTION gui_StatusCreate( xDlg, xControl )

   IF Empty( xControl )
      xControl := GUI():NewName( "STA" )
   ENDIF

	DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 PARENT ( xDlg )
		STATUSITEM "DlgAuto" // ACTION MsgInfo('Click! 1')
		//STATUSITEM "Item 2" 	WIDTH 100 ACTION MsgInfo('Click! 2')
		//STATUSITEM 'A Car!'	WIDTH 100 ICON 'Car.Ico'
		CLOCK
		DATE
	END STATUSBAR

   RETURN Nil

STATIC FUNCTION gui_TabCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := GUI():NewName( "TAB" )
   ENDIF
   DEFINE TAB ( xControl ) ;
      PARENT ( xParent ) ;
      AT nRow, nCol;
      WIDTH nWidth ;
      HEIGHT nHeight

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

STATIC FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg);(xTab);(aList)

   RETURN Nil

STATIC FUNCTION gui_TabPageBegin( xDlg, xParent, xTab, xPage, nPageCount, cText )

   PAGE ( cText )
   xPage := xTab

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
      xControl := GUI():NewName( "TEXT" )
   ENDIF

   hb_Default( @lPassword, .F. )
   DEFINE TEXTBOX ( xControl )
      PARENT ( xParent )
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
      IF lPassword
         PASSWORD .T.
         UPPERCASE .T.
      ENDIF
   END TEXTBOX
   IF aItem[ CFG_ISKEY ] .OR. ! Empty( aItem[ CFG_VTABLE ] )
      AAdd( oFrmClass:aDlgKeyDown, { xControl, VK_F9, ;
         { || oFrmClass:Browse( xDlg, xControl, iif( aItem[ CFG_ISKEY ], oFrmClass:cDataTable, aItem[ CFG_VTABLE ] ) ) } } )
   ENDIF

   (bValid); (xDlg); (cImage); (bAction)

   RETURN Nil

STATIC FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

STATIC FUNCTION gui_ControlGetValue( xDlg, xControl )

   (xDlg)

   RETURN GetProperty( xDlg, xControl, "VALUE" )

STATIC FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

STATIC FUNCTION gui_DlgSetKey( oFrmClass )

   LOCAL aItem

   FOR EACH aItem IN oFrmClass:aDlgKeyDown
         _DefineHotKey( oFrmClass:xDlg, 0, aItem[ 2 ], { || GUI():DlgKeyDown( aItem[1], ;
            aItem[ 2 ], oFrmClass ) } )
   NEXT

   RETURN Nil

STATIC FUNCTION gui_BrowseKeyDown()
   RETURN Nil

FUNCTION gui_NewName( cPrefix )

   STATIC nCount := 0

   nCount += 1
   hb_Default( @cPrefix, "ANY" )

   RETURN cPrefix + StrZero( nCount, 10 )

