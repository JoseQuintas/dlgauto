/*
lib_hmge - HMG Extended source selected by lib.prg
*/

#include "frm_class.ch"
#include "i_winuser.ch"

FUNCTION gui_Init()

   SET NAVIGATION EXTENDED
   //SET OOP ON
   SET WINDOW MAIN OFF
   //SET WINDOW MODAL PARENT HANDLE ON

   RETURN Nil

FUNCTION gui_MainMenu( xDlg, aMenuList, aAllSetup, cTitle )

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
      DEFINE POPUP "Sair"
         MENUITEM "Sair" ACTION gui_DialogClose( xDlg )
      END POPUP
   END MENU

   gui_DialogActivate( xDlg )

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF Empty( xControl )
      xControl := gui_newctlname( "BUTTON" )
   ENDIF
   DEFINE BUTTONEX ( xControl )
      PARENT ( xDlg )
      ROW         nRow
      COL         nCol
      WIDTH       nWidth
      HEIGHT      nHeight
      ICON        cResName
      IMAGEWIDTH  nWidth - 20
      IMAGEHEIGHT nHeight - 20
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

   RETURN Nil

FUNCTION gui_ButtonEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_Browse( xDlg, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyCodeList, aDlgKeyCodeList )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem

   IF Empty( xControl )
      xControl := gui_newctlname( "BROW" )
   ENDIF
   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, aItem[2] )
      AAdd( aWidthList, ( 1 + Max( Len( aItem[3] ), ;
         Len( Transform( ( workarea )->( FieldGet( FieldNum( aItem[ 1 ] ) ) ), "" ) ) ) ) * 13 )
   NEXT

   DEFINE BROWSE ( xControl )
      PARENT ( xDlg )
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

   //@ nRow, nCol GRID ( xControl ) ;
   //   OF ( xDlg ) ;
   //   WIDTH nWidth - 20 ;
   //   HEIGHT nHeight - 20 ;
   //   ON DBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue ) ;
   //   HEADERS aHeaderList ;
   //   WIDTHS aWidthList ;
   //   ROWSOURCE ( workarea ) ;
   //   COLUMNFIELDS aFieldList

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
      IF hb_AScan( { "GETBOX", "MASKEDTEXT", "TEXT" }, { | e | e == cType } ) != 0
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

FUNCTION gui_DialogActivate( xDlg, bCode )

   //LOCAL xControl

   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   //FOR EACH xControl IN HMG_GetFormControls( xDlg, "BUTTONEX" )
   //   SetHandCursor( GetControlHandle( xControl, xDlg ) )
   //NEXT
   DoMethod( xDlg, "CENTER" )
   DoMethod( xDlg, "ACTIVATE" )

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, xOldDlg )

   IF Empty( xDlg )
      xDlg := gui_newctlname( "DIALOG" )
   ENDIF

   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF
   DEFINE WINDOW ( xDlg ) ;
      AT nCol, nRow ;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      TITLE cTitle ;
      ; // MODAL ; // bad using WINDOW MAIN OFF
      ON INIT Eval( bInit ) ;
      ON RELEASE iif( Empty( xOldDlg ), Nil, DoMethod( xOldDlg, "SETFOCUS" ) )
      IF ! Empty( xOldDlg )
         ON KEY ALT+F4 ACTION doMethod( xOldDlg, "SETFOCUS" )
      ENDIF
   END WINDOW

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      RETURN GetProperty( xDlg, "FOCUSEDCONTROL" )  == xControl

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := gui_newctlname( "LABEL" )
   ENDIF
   // não mostra borda
   DEFINE LABEL ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth
      HEIGHT nHeight
      VALUE xValue
      IF lBorder
         BORDER lBorder
      ENDIF
   END LABEL

   //IF lBorder
   //   @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
   //      VALUE xValue WIDTH nWidth HEIGHT nHeight BORDER
   //ELSE
   //   @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
   //      VALUE xValue WIDTH nWidth HEIGHT nHeight
   //ENDIF

   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "HMGE"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_newctlname( "MLTEXT" )
   ENDIF
   DEFINE EDITBOX ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth
      HEIGHT nHeight
      VALUE xValue
      FONTNAME PREVIEW_FONTNAME
      /* MAXLENGTH 510000 */
      TOOLTIP 'EditBox'
      /* NOHSCROLLBAR .T. */
   END EDITBOX

   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN Msgbox( cText )

FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

FUNCTION gui_PanelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_newctlname( "PANEL" )
   ENDIF
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION gui_SetFocus( xDlg, xControl )

   DoMethod( xDlg, xControl, "SETFOCUS" )

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_newctlname( "TAB" )
   ENDIF
   DEFINE TAB ( xControl ) ;
      PARENT ( xDlg ) ;
      AT nRow, nCol;
      WIDTH nWidth ;
      HEIGHT nHeight

   RETURN Nil

FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, oTab, aList )

   (xDlg);(oTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, cText )

   PAGE ( cText )
   (xDlg); (xControl); (cText)

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )

   END PAGE
   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   IF Empty( xControl )
      xControl := gui_newctlname( "TEXT" )
   ENDIF
   DEFINE GETBOX ( xControl )
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
      ON LOSTFOCUS Eval( bValid )
   END GETBOX
   (bValid)

   RETURN Nil

FUNCTION gui_TextEnable( xDlg, xControl, lEnable )

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
   //DoMethod( xDlg, xControl, "REFRESH" )

   RETURN Nil

STATIC FUNCTION gui_newctlname( cPrefix )

   STATIC nCount := 0

   nCount += 1
   hb_Default( @cPrefix, "ANY" )

   RETURN cPrefix + StrZero( nCount, 10 )

// notes
// HMG_GetFormControls( xDlg, "LABEL" )
