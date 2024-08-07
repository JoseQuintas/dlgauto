/*
lib_hwgui - hwgui source selected by lib.prg
*/

#include "frm_class.ch"
#include "hwgui.ch"

STATIC lDrawboard := .F.

FUNCTION IsDrawBoard( lParam )

   IF lParam != Nil
      lDrawboard := lParam
   ENDIF

   RETURN lDrawboard

FUNCTION gui_Init()

   hwg_SetColorInFocus( .T., COLOR_BLACK,COLOR_YELLOW )

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   gui_DialogCreate( @xDlg, 0, 0,1024, 768, cTitle )
   MENU OF xDlg
      FOR EACH aGroupList IN aMenuList
         MENU TITLE "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
            NEXT
         ENDMENU
      NEXT
      MENU TITLE "Exit"
         MENUITEM "&Exit" ACTION gui_DialogClose( xDlg )
      ENDMENU
   ENDMENU
   @ 400, 400 MONTHCALENDAR SIZE 250,250
   gui_DialogActivate( xDlg )

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   @ nCol, nRow BUTTON xControl ;
      CAPTION  Nil ;
      OF       xParent ;
      SIZE     nWidth, nHeight ;
      STYLE    BS_TOP ;
      ON CLICK bAction ;
      ON INIT  { || ;
         BtnSetImageText( xControl:Handle, cCaption, cResName, nWidth, nHeight ) } ;
         TOOLTIP cCaption

   ( xDlg )

   RETURN Nil

FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea, aKeyDownList, Self )

   LOCAL aItem

   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := { { VK_RETURN, { || gui_BrowseEnter( cField, @xValue, xDlg, xControl ) } } }
   ENDIF

   @ nCol, nRow BROWSE xControl DATABASE SIZE nWidth, nHeight STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL ;
   ON CLICK { |...| gui_browseenter( @cField, @xValue, @xDlg, @xControl ), .F. }
   // may be not current alias
   xControl:Alias := workarea

   FOR EACH aItem IN oTBrowse
      ADD COLUMN { || Transform( (workarea)->( FieldGet( FieldNum( aItem[2] ) ) ), aItem[3] ) } TO xControl ;
         HEADER aItem[1] ;
         LENGTH Int( 1.4 * ( 1 + Max( Len( aItem[1] ), ;
            Len( Transform( (workarea)->( FieldGet( FieldNum( aItem[2] ) ) ), aItem[3] ) ) ) ) );
         JUSTIFY LINE DT_LEFT
   NEXT
   // xControl:lInFocus := .T. // only if called from frm_browse

   //xControl:bEnter := { || hwg_MsgInfo( "teste"), gui_browseenter( @cField, @xValue, @xDlg, @xControl ), .F. }
   xControl:bKeyDown := { | o, nKey | (o), ;
      gui_browsekeydown( xControl, xDlg, nKey, cField, workarea, xvalue, aKeyDownList ) }
   //xControl:bGetFocus := { | o | o:Refresh(), hwg_SetFocus( o:Handle ), o:Refresh() }
   //xDlg:bGetFocus := { || xDlg:xControl:SetFocus() }

   (xDlg); (workarea); (xParent);(Self)

   RETURN Nil

STATIC FUNCTION gui_browsekeydown( xControl, xDlg, nKey, cField, workarea, xValue, aKeyDownList )

   LOCAL nPos

   nPos := hb_AScan( aKeyDownList, { | e | nKey == e[ 1 ] } )
   IF nPos != 0
      Eval( aKeyDownList[ nPos ][ 2 ], cField, @xValue, xDlg, xControl )
   ENDIF

   (workarea)
   // return value is used by hwgui

   RETURN .T.

STATIC FUNCTION gui_BrowseEnter( cField, xValue, xDlg )

   IF ! Empty( cField )
      xValue := FieldGet( FieldNum( cField ) )
   ENDIF
   hwg_EndDialog()

   (xDlg)

   RETURN Nil

FUNCTION gui_BrowseRefresh( xDlg, xControl )

   xControl:Refresh()

   (xDlg)

   RETURN Nil

FUNCTION gui_ComboCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, aList, xValue )

   @ nCol, nRow GET COMBOBOX xControl VAR xValue ITEMS aList OF xParent STYLE WS_TABSTOP SIZE nWidth, nHeight

   (xDlg); (xValue)

   RETURN Nil

FUNCTION gui_CheckboxCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   @ nCol, nRow CHECKBOX xControl CAPTION "" OF xParent STYLE WS_TABSTOP SIZE nWidth, nHeight

   (xDlg)

   RETURN Nil

FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   LOCAL oFont := HFont():Add( "MS Sans Serif", 0, 10 )

   @ nCol, nRow DATESELECT xControl ;
      OF xParent ;
      SIZE nWidth / 3, nHeight FONT oFont ;
      INIT dValue

   (xDlg)

   RETURN Nil

FUNCTION gui_SpinnerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, nValue, aList, Self )

   LOCAL oFont := HFont():Add( "MS Sans Serif", 0, 10 )

   @ nCol, nRow GET UPDOWN xControl VAR nValue ;
      RANGE aList[1], aList[2] OF xParent SIZE nWidth, nHeight WIDTH 15 FONT oFont
   //gui_TextCreate( xDlg, xParent, @xControl, nRow, nCol, nWidth, nHeight, @nValue )

   (aList);(Self);(xDlg)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode )

   IF Empty( bCode )
      ACTIVATE DIALOG xDLG CENTER
   ELSE
      ACTIVATE DIALOG xDlg CENTER ON ACTIVATE bCode
   ENDIF

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   RETURN xDlg:Close()

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal )

   LOCAL oFont

   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF
   oFont := HFont():Add( APP_FONTNAME, 0, -11 )
   INIT DIALOG xDlg ;
      CLIPPER ;
      FONT oFont ;
      NOEXIT ;
      TITLE     cTitle + " (" + gui_LibName() + ")"  ;
      AT        nRow, nCol ;
      SIZE      nWidth, nHeight ;
      BACKCOLOR COLOR_WHITE ;
      ON INIT bInit

   (xDlg);(lModal)

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   LOCAL lOk

   IF PCount() == 1
      lOk := hwg_SelfFocus( xDlg:Handle )
   ELSE
      lOk := hwg_SelfFocus( xControl:Handle )
   ENDIF

   RETURN lOk

FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   hb_Default( @lBorder, .F. )
   IF lBorder
      @ nCol, nRow SAY xControl ;
         CAPTION xValue ;
         OF      xParent ;
         SIZE    nWidth, nHeight ;
         STYLE   WS_BORDER ;
         COLOR COLOR_BLACK ;
         BACKCOLOR COLOR_GREEN // TRANSPARENT // DO NOT USE TRANSPARENT WITH BORDER
   ELSE
      @ nCol, nRow SAY xControl ;
         CAPTION xValue ;
         OF      xParent ;
         SIZE    nWidth, nHeight ;
         COLOR   COLOR_BLACK ;
         TRANSPARENT
   ENDIF

   (xDlg); (lBorder)

   RETURN Nil

//   @ nCol, nRow BOARD xControl SIZE nWidth, nHeight ON PAINT { | o, h | LabelPaint( o, h, lBorder ) }
//   xControl:Title := xValue

//   RETURN Nil

//FUNCTION LabelPaint( o, h, lBorder )

//   IF o:oFont != Nil
//      hwg_SelectObject( h, o:oFont:Handle )
//   ENDIF
//   IF o:TColor != Nil
//      hwg_SetTextColor( h, o:TColor )
//   ENDIF
//   IF ! Empty( lBorder ) .AND. lBorder
//      hwg_Rectangle( h, 0, 0, o:nWidth - 1, o:nHeight - 1 )
//   ENDIF
//   hwg_SetTransparentMode( h, .T. )
//   hwg_DrawText( h, o:Title, 2, 2, o:nWidth - 2, o:nHeight - 2 )
//   hwg_SetTransparentMode( h, .F. )

//   RETURN Nil

FUNCTION gui_LibName()

   RETURN "HWGUI"

FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   LOCAL oFont := HFont():Add( PREVIEW_FONTNAME, 0, -11 )

   @ nCol, nRow EDITBOX xControl ;
      CAPTION xValue ;
      SIZE    nWidth, nHeight ;
      FONT    oFont ;
      STYLE   ES_MULTILINE + ES_AUTOVSCROLL + WS_VSCROLL + WS_HSCROLL

   (xDlg); (xParent)

   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN hwg_MsgInfo( cText )

FUNCTION gui_MsgYesNo( cText )

   RETURN hwg_MsgYesNo( cText )

FUNCTION gui_SetFocus( xDlg, xControl )

   IF Empty( xControl )
      //xDlg:SetFocus()
   ELSE
      xControl:SetFocus()
   ENDIF

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_Statusbar( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   @ nCol, nRow TAB xControl ;
      ITEMS {} ;
      OF    xParent ;
      ; // ID    101 ;
      SIZE  nWidth, nHeight ;
      STYLE WS_CHILD + WS_VISIBLE

   (xDlg)

   RETURN Nil

FUNCTION gui_TabEnd()

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   LOCAL nTab, nPageNext

   IF Len( aList ) == 0
      RETURN Nil
   ENDIF
   FOR nTab = 1 TO Len( aList ) - 1
      nPageNext  := iif( nTab == Len( aList ), 1, nTab + 1 )
      gui_TabSetLostFocus( aList[ nTab, Len( aList[ nTab ] ) ], xTab, nPageNext, aList[ nPageNext, 1 ] )
   NEXT

   (xDlg)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xParent, xControl, xPage, nPageCount, cText )

   BEGIN PAGE cText OF xControl
   xPage := xControl

   (xDlg);(nPageCount);(xDlg);(xParent)

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )

   END PAGE OF xControl

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabSetLostFocus( oEdit, oTab, nPageNext, oEditNext )

   oEdit:bLostFocus := { || oTab:ChangePage( nPageNext ), oTab:SetTab( nPageNext ), gui_SetFocus( Nil, oEditNext ), .T. }

   RETURN Nil

FUNCTION gui_TextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, Self, lPassword )

   @ nCol, nRow GET xControl ;
      VAR       xValue ;
      OF        xParent ;
      SIZE      nWidth, nHeight ;
      STYLE     WS_DISABLED + iif( ValType( xValue ) $ "N,N+", ES_RIGHT, ES_LEFT ) ;
      ; // MAXLENGTH nMaxLength ;
      PICTURE   iif( Empty( cPicture ), Nil, cPicture ) ;
      VALID     bValid

   (nMaxLength);(bAction);(cImage);(aItem);(Self);(lPassword);(xDlg)

   RETURN Nil

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   (xDlg)

   RETURN Nil

FUNCTION gui_ControlGetValue( xDlg, xControl )

   (xDlg)

   RETURN xControl:Value

FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   DO CASE
   CASE xControl:WinClass $ "STATIC,BUTTON"; xControl:SetText( xValue )
   CASE xControl:WinClass $ "EDIT,COMBOBOX,HBOARD"; xControl:Value := xValue
   OTHERWISE
      gui_MsgBox( "no ControlSetValue to " + hb_ValToExp( xControl:WinClass ) )
   ENDCASE
 ; xControl:Refresh()

  (xDlg)

   RETURN Nil

STATIC FUNCTION BtnSetImageText( hHandle, cCaption, cResName, nWidth, nHeight )

   LOCAL oIcon, hIcon

   oIcon := HICON():AddResource( cResName, Int( nWidth / 2.5 ), Int( nHeight / 2.5 ) )
   IF ValType( oIcon ) == "O"
      hIcon := oIcon:Handle
   ENDIF
   hwg_SendMessage( hHandle, BM_SETIMAGE, IMAGE_ICON, hIcon )
   hwg_SendMessage( hHandle, WM_SETTEXT, 0, cCaption )

   RETURN Nil

FUNCTION gui_DlgSetKey( Self )

   LOCAL aItem

   FOR EACH aItem IN ::aDlgKeyDown
   NEXT

   RETURN Nil
