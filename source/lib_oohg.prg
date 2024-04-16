/*
lib_oohg - oohg source selected by lib.prg
*/

#include "frm_class.ch"

FUNCTION gui_Init()

   SET MENUSTYLE EXTENDED
   SET NAVIGATION EXTENDED

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   gui_DialogCreate( @xDlg, 0, 0,1024, 768, cTitle )

   DEFINE MAIN MENU OF ( xDlg )
      FOR EACH aGroupList IN aMenuList
         DEFINE POPUP "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup ) ICON "APPICON"
            NEXT
         END POPUP
      NEXT
      DEFINE POPUP "Sair"
         MENUITEM "Sair" ACTION gui_DialogClose( xDlg ) ICON "ICODOOR"
      END POPUP
      DEFINE MONTHCALENDAR("mcal001")
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
      xControl := gui_newctlname( "BUTTON" )
   ENDIF

   IF cCaption == "Cancel"
      @ nRow, nCol BUTTON ( xControl ) ;
         PARENT ( xDlg ) ;
         CAPTION  cCaption ;
         PICTURE  cResName ;
         ACTION   Eval( bAction ) ;
         WIDTH    nWidth ;
         HEIGHT   nHeight ;
         IMAGEALIGN TOP ;
         CANCEL // abort valid
   ELSE
      @ nRow, nCol BUTTON ( xControl ) ;
         PARENT ( xDlg ) ;
         CAPTION  cCaption ;
         PICTURE  cResName ;
         ACTION   Eval( bAction ) ;
         WIDTH    nWidth ;
         HEIGHT   nHeight ;
         IMAGEALIGN TOP
   ENDIF

   RETURN Nil

FUNCTION gui_Browse( xDlg, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyCodeList, aDlgKeyCodeList )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem

   IF Empty( xControl )
      xControl := gui_newctlname( "BROWSE" )
   ENDIF
   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, { || Transform( FieldGet( FieldNum( aItem[2] ) ), aItem[3] ) } )
      AAdd( aWidthList, ( 1 + Max( Len( aItem[1] ), ;
         Len( Transform( FieldGet( FieldNum(aItem[ 1 ] ) ), aItem[ 3 ] ) ) ) ) * 13 )
   NEXT
   IF ValType( aKeyCodeList ) == "A"
      @ nRow, nCol BROWSE ( xControl ) ;
         OF ( xDlg ) ;
         WIDTH nWidth - 20 ;
         HEIGHT nHeight - 20 ;
         HEADERS aHeaderList ;
         WIDTHS aWidthList ;
         WORKAREA ( workarea ) ;
         FIELDS aFieldList
   ELSE
      @ nRow, nCol BROWSE ( xControl ) ;
         OF ( xDlg ) ;
         WIDTH nWidth - 20 ;
         HEIGHT nHeight - 20 ;
         HEADERS aHeaderList ;
         WIDTHS aWidthList ;
         WORKAREA ( workarea ) ;
         FIELDS aFieldList ;
         ON DBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
   ENDIF
   IF ! Empty( aKeyCodeList )
      FOR EACH aItem IN aKeyCodeList
         AAdd( aDlgKeyCodeList, { xControl, aItem[ 1 ], aItem[ 2 ] } )
         _DefineHotKey( xDlg, 0, aItem[ 1 ], { || gui_DlgKeyDown( xDlg, xControl, ;
            aItem[ 1 ], workarea, cField, xValue, aDlgKeyCodeList ) } )
      NEXT
   ENDIF
   (cField);(xValue)

   RETURN Nil

STATIC FUNCTION gui_DlgKeyDown( xDlg, xControl, nKey, workarea, cField, xValue, aDlgKeyCodeList )

   LOCAL nPos, cFocusedControl, lReturn := .T., cType

   nPos := hb_AScan( aDlgKeyCodeList, { | e | GetProperty( xDlg, "FOCUSEDCONTROL" ) == e[1] .AND. nKey == e[ 2 ] } )
   IF nPos != 0
      lReturn := Eval( aDlgKeyCodeList[ nPos ][ 3 ], cField, @xValue, xDlg, xControl )
   ENDIF
   IF nKey == VK_RETURN .OR. lReturn == Nil .OR. lReturn
      cFocusedControl := GetProperty( xDlg, "FOCUSEDCONTROL" )
      cType := GetControlObject( cFocusedControl, xDlg ):Type
      gui_MsgBox( cType )
      IF hb_AScan( { "NUMTEXT", "TEXT" }, { | e | e == cType } ) != 0
         _SetNextFocus()
      ENDIF
   ENDIF
   (xControl); (workarea)

   RETURN .T.

FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   LOCAL nRecNo

   IF ! Empty( cField )
      nRecNo := GetProperty( xDlg, xControl, "VALUE" )
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
      //HEIGHT nHeight // do not define height, it limits can list size to zero
      ITEMS aList
   END COMBOBOX
   ( nHeight )

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
      AT     nCol, nRow ;
      WIDTH  nWidth ;
      HEIGHT nHeight ;
      TITLE  cTitle ;
      MODAL ;
      ON INIT Eval( bInit )
      gui_Statusbar( xDlg, "" )
   END WINDOW

   RETURN Nil

//   WITH OBJECT xDlg := TForm():Define()
//      :Row := 500
//      :Col := 1000
//      :Width := ::nDlgWidth
//      :Height := ::nDlgHeight
//      :Title := ::cFileDbf
//      // :Init := ::UpdateEdit()
//   ENDWITH
//    _EndWindow()

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   // not used, solved on button using CANCEL
   RETURN GetFocus() == GetProperty( xDlg, xControl, "HWND" )

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := gui_newctlname( "LABEL" )
   ENDIF
   IF lBorder
      @ nRow, nCol LABEL ( xControl ) ;
         PARENT ( xDlg ) ;
         VALUE  xValue ;
         WIDTH  nWidth ;
         HEIGHT nHeight ;
         BORDER
   ELSE
      @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
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

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "OOHG"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_newctlname( "MLTEXT" )
   ENDIF
   //@ nRow, nCol EDITBOX (xControl) PARENT (xDlg) WIDTH nWidth HEIGHT nHeight
   //* not multiline */
   DEFINE EDITBOX ( xControl )
      PARENT ( xDlg )
      ROW      nRow
      COL      nCol
      HEIGHT   nHeight
      WIDTH    nWidth
      FONTNAME PREVIEW_FONTNAME
      VALUE     xValue
      SETBREAK  .T.
      MAXLENGTH 510000
      /* NOHSCROLLBAR .T. */
   END EDITBOX
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight); (xValue)

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

FUNCTION gui_Statusbar( xDlg, xControl )

   IF Empty( xControl )
      xControl := gui_NewCtlName( "STA" )
   ENDIF

	DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 PARENT (xDlg )
		STATUSITEM "DlgAuto" // ACTION MsgInfo('Click! 1')
		//STATUSITEM "Item 2" 	WIDTH 100 ACTION MsgInfo('Click! 2')
		//STATUSITEM 'A Car!'	WIDTH 100 ICON 'Car.Ico'
		CLOCK
		DATE
	END STATUSBAR

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
      VALUE 1

   xControl := xDlg // because they are not on tab
   (nRow); (nCol); (nWidth); (nHeight); (xDlg)

   RETURN Nil

FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, oTab, aList )

   (xDlg);(oTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, cText )

   (xDlg); (xControl); (cText)
   DEFINE PAGE cText

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
      ROW      nRow
      COL      nCol
      HEIGHT   nHeight
      WIDTH    nWidth
      FONTNAME DEFAULT_FONTNAME
      IF ValType( xValue ) == "N"
         NUMERIC .T.
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
      ELSE
         MAXLENGTH nMaxLength
      ENDIF
      VALUE     xValue
      ON LOSTFOCUS Eval( bValid )
   END TEXTBOX
   (bValid); (cPicture)

   RETURN Nil

   // not confirmed
   // WITH OBJECT aItem[ CFG_FCONTROL ] := TText():Define()
   //    :Row    := nRow2
   //    :Col    := nCol2
   //    :Width  := aItem[ CFG_FLEN ] * 12
   //    :Height := ::nLineHeight
   //    :Value  := aItem[ CFG_VALUE ]
   // ENDWITH

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_TextGetValue( xDlg, xControl )

   (xDlg)

   RETURN GetProperty( xDlg, xControl, "VALUE" )

FUNCTION gui_TextSetValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )

   RETURN Nil

STATIC FUNCTION gui_newctlname( cPrefix )

   STATIC nCount := 0

   hb_Default( @cPrefix, "ANY" )
   nCount += 1

   RETURN cPrefix  + StrZero( nCount, 10 )
