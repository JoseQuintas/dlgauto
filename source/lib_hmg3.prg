/*
lib_hmg3 - HMG3 source selected by lib.prg
*/

#include "frm_class.ch"

MEMVAR _HMG_SYSDATA
MEMVAR _HMG_MainWindowFirst

FUNCTION gui_Init()

   SET WINDOW MAIN OFF
   SET NAVIGATION EXTENDED
   SET BROWSESYNC ON

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupLIst, cDBF

   DEFINE WINDOW ( xDlg ) ;
      AT 0, 0 ;
      WIDTH 1024 ;
      HEIGHT 768 ;
      TITLE cTitle ;
      WINDOWTYPE MAIN

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
   END WINDOW

   gui_DialogActivate( xDlg )

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF Empty( xControl )
      xControl := gui_newctlname( "BUTTON" )
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
      AAdd( aWidthList, ( 1 + Max( Len( aItem[3] ), Len( Transform(FieldGet(FieldNum(aItem[1] ) ), "" ) ) ) ) * 13 )
   NEXT
   IF ValType( aKeyCodeList ) == "A"
      @ nRow, nCol GRID ( xControl ) ;
         OF ( xDlg ) ;
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
   IF ! Empty( aKeyCodeList )
      FOR EACH aItem IN aKeyCodeList
         AAdd( aDlgKeyCodeList, { xControl, aItem[ 1 ], aItem[ 2 ] } )
         _DefineHotKey( xDlg, 0, aItem[ 1 ], ;
            { || gui_DlgKeyDown( xDlg, xControl, aItem[ 1 ], workarea, cField, xValue, aDlgKeyCodeList ) } )
      NEXT
   ENDIF

   (xDlg);(cField);(xValue);(workarea)

   RETURN Nil

STATIC FUNCTION gui_DlgKeyDown( xDlg, xControl, nKey, workarea, cField, xValue, aDlgKeyCodeList )

   LOCAL nPos, cType, cFocusedControl

   nPos := hb_AScan( aDlgKeyCodeList, { | e | GetProperty( xDlg, "FOCUSEDCONTROL" ) == e[1] .AND. nKey == e[ 2 ] } )
   IF nPos != 0
      Eval( aDlgKeyCodeList[ nPos ][ 3 ], cField, @xValue, xDlg, xControl )
   ENDIF
   IF nKey == VK_RETURN .AND. hb_ASCan( aDlgKeyCodeList, { | e | e[ 2 ] == VK_RETURN } ) != 0
      cFocusedControl := GetProperty( xDlg, "FOCUSEDCONTROL" )
      IF ! Empty( cFocusedControl )
         cType := GetProperty( xDlg, cFocusedControl, "TYPE" )
         IF hb_AScan( { "GETBOX", "MASKEDTEXT", "TEXT" }, { | e | e == cType } ) != 0
            _SetNextFocus()
         ENDIF
      ENDIF
   ENDIF
   (xControl); (workarea)

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
      HEIGHT nHeight
      ITEMS aList
   END COMBOBOX

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode )

   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   DoMethod( xDlg, "CENTER" )
   ACTIVATE WINDOW ( xDlg )

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit )

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
      MODAL ;
      ON INIT Eval( bInit )
   END WINDOW

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      RETURN _GetFocusedControl( xDlg ) == xControl

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := gui_newctlname( "LABEL" )
   ENDIF
   // não mostra borda
   //DEFINE LABEL ( xControl )
   //   PARENT ( xDlg )
   //   COL nCol
   //   ROW nRow
   //   WIDTH nWidth
   //   HEIGHT nHeight
   //   VALUE xValue
   //   BORDER lBorder
   //END LABEL

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
      TOOLTIP 'EditBox'
      /* NOHSCROLLBAR .T. */
   END EDITBOX
   (xDlg)

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
   (xDlg)

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
   DEFINE TEXTBOX ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      HEIGHT    nHeight
      WIDTH     nWidth
      FONTNAME DEFAULT_FONTNAME
      IF ValType( xValue ) == "N"
         NUMERIC .T.
         INPUTMASK cPicture
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
      ELSE
         MAXLENGTH nMaxLength
      ENDIF
      VALUE     xValue
      ON LOSTFOCUS Eval( bValid )
   END TEXTBOX
   (bValid); (xDlg)

   RETURN Nil

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_TextGetValue( xDlg, xControl )

   (xDlg)

   RETURN GetProperty( xDlg, xControl, "VALUE" )

FUNCTION gui_TextSetValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

STATIC FUNCTION gui_newctlname( cPrefix )

   STATIC nCount := 0

   nCount += 1
   hb_Default( @cPrefix, "ANY" )

   RETURN cPrefix + StrZero( nCount, 10 )
