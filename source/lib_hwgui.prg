/*
lib_hwgui - hwgui source selected by lib.prg
*/

#include "hbclass.ch"
#include "frm_class.ch"
#include "hwgui.ch"

THREAD STATIC oFont

#ifdef DLGAUTO_AS_LIB
   STATIC pGenPrg := ""
#else
   MEMVAR pGenName, pGenPrg
#endif

CREATE CLASS HWGUIClass

   /*--- init ---*/
   METHOD LibName()             INLINE "HWGUI"
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
   METHOD StatusCreate(...)     INLINE gui_StatusCreate(...)
   METHOD TextCreate(...)       INLINE gui_TextCreate(...)

   /* browse */
   METHOD Browse(...)           INLINE gui_Browse(...)
   METHOD BrowseRefresh(...)    INLINE gui_BrowseRefresh(...)
   METHOD browsekeydown(...)    INLINE gui_browsekeydown(...)
   METHOD BrowseEnter(...)      INLINE gui_BrowseEnter(...)

   /* tab */
   METHOD TabCreate(...)        INLINE gui_TabCreate(...)
   METHOD TabEnd(...)           INLINE gui_TabEnd(...)
   METHOD TabPageBegin(...)     INLINE gui_TabPageBegin(...)
   METHOD TabPageEnd(...)       INLINE gui_TabPageEnd(...)
   METHOD TabNavigate(...)      INLINE gui_TabNavigate(...)
   METHOD TabSetLostFocus(...)  INLINE gui_TabSetLostFocus(...)

   /* msg */
   METHOD Msgbox(...)           INLINE gui_Msgbox(...)
   METHOD MsgYesNo(...)         INLINE gui_MsgYesNo(...)

   /* aux */
   METHOD IsCurrentFocus(...)   INLINE gui_IsCurrentFocus(...)
   METHOD SetFocus(...)         INLINE gui_SetFocus(...)
   METHOD ControlEnable(...)    INLINE gui_ControlEnable(...)
   METHOD ControlGetValue(...)  INLINE gui_ControlGetValue(...)
   METHOD ControlSetValue(...)  INLINE gui_ControlSetValue(...)
   METHOD IsDrawBoard( lValue ) INLINE IsDrawBoard( lValue )
   METHOD BtnSetImageText(...)  INLINE BtnSetImageText(...)

   ENDCLASS

STATIC FUNCTION IsDrawBoard( lValue )

   STATIC lDrawBoard := .F.

   IF lValue != Nil
      lDrawboard := lValue
   ENDIF

   RETURN lDrawboard

STATIC FUNCTION gui_Init()

#ifdef DLGAUTO_AS_LIB
   hwg_InitProc()
#endif
   hwg_SetColorInFocus( .T., COLOR_BLACK,COLOR_YELLOW )
   oFont := HFont():Add( APP_FONTNAME, 0, -11 )

   RETURN Nil

STATIC FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF

   GUI():DialogCreate( Nil, @xDlg, 0, 0, APP_DLG_WIDTH, APP_DLG_HEIGHT, cTitle )
   MENU OF xDlg
      FOR EACH aGroupList IN aMenuList
         MENU TITLE "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_funcMain( cDBF, aAllSetup )
            NEXT
         ENDMENU
      NEXT
      MENU TITLE "NoData"
         MENUITEM "NoData Layout 1" ACTION frm_DialogFree(1)
         MENUITEM "NoData Layout 2" ACTION frm_DialogFree(2)
         MENUITEM "NoData Layout 3" ACTION frm_DialogFree(3)
      ENDMENU
      MENU TITLE "Exit"
         MENUITEM "Test Default" ACTION DlgAuto_ShowDefault()
         MENUITEM "&Exit" ACTION gui_DialogClose( xDlg )
      ENDMENU
   ENDMENU
   @ 400, 400 MONTHCALENDAR SIZE 250,250
   gui_DialogActivate( xDlg )

   RETURN Nil

STATIC FUNCTION gui_ButtonCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

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

STATIC FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea, aKeyDownList, oFrmClass )

   LOCAL aItem

   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := { { VK_RETURN, { || GUI():BrowseEnter( cField, @xValue, xDlg, xControl ) } } }
   ENDIF

   IF oFrmClass:lIsSQL
      @ nCol, nRow BROWSE ARRAY xControl SIZE nWidth, nHeight STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL ;
      ON CLICK { |...| GUI():browseenter( @cField, @xValue, @xDlg, @xControl ), .F. }

#ifdef DLGAUTO_AS_SQL
      xControl:AArray := ADOLocal()
      xControl:bSkip  := { | o, nSkip | ADOSkipper( o:aArray, nSkip ) }
      xControl:bGotop := { | o | o:aArray:MoveFirst() }
      xControl:bGobot := { | o | o:aArray:MoveLast() }
      xControl:bEof   := { | o | o:nCurrent > o:aArray:RecordCount() }
      xControl:bBof   := { | o | o:nCurrent == 0 }
      xControl:bRcou  := { | o | o:aArray:RecordCount() }
      xControl:bRecno := { | o | o:aArray:AbsolutePosition() }
      xControl:bRecnoLog := xControl:bRecno
      xControl:bGoTo  := { | o, n | (o), o:aArray:Move( n - 1, 1 ) }
      xControl:AArray:Execute( "SELECT * FROM " + workarea )
      FOR EACH aItem IN oTBrowse
         ADD COLUMN { || Transform( xControl:AArray:Value( aItem[2] ), aItem[3] ) } TO xControl ;
            HEADER aItem[1] ;
            LENGTH Int( 1.4 * ( 1 + Max( Len( aItem[1] ), ;
               Len( Transform( xControl:AArray:Value( aItem[2] ), aItem[3] ) ) ) ) );
            JUSTIFY LINE DT_LEFT
      NEXT
#endif
   ELSE
      @ nCol, nRow BROWSE xControl DATABASE SIZE nWidth, nHeight STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL ;
      ON CLICK { |...| GUI():browseenter( @cField, @xValue, @xDlg, @xControl ), .F. }
      // may be not current alias
      xControl:Alias := workarea

      FOR EACH aItem IN oTBrowse
         ADD COLUMN { || Transform( (workarea)->( FieldGet( FieldNum( aItem[2] ) ) ), aItem[3] ) } TO xControl ;
            HEADER aItem[1] ;
            LENGTH Int( 1.4 * ( 1 + Max( Len( aItem[1] ), ;
               Len( Transform( (workarea)->( FieldGet( FieldNum( aItem[2] ) ) ), aItem[3] ) ) ) ) );
            JUSTIFY LINE DT_LEFT
      NEXT
   ENDIF
   // xControl:lInFocus := .T. // only if called from frm_browse

   //xControl:bEnter := { || hwg_MsgInfo( "teste"), GUI():browseenter( @cField, @xValue, @xDlg, @xControl ), .F. }
   xControl:bKeyDown := { | o, nKey | (o), ;
      GUI():browsekeydown( xControl, xDlg, nKey, cField, workarea, xvalue, aKeyDownList ) }
   //xControl:bGetFocus := { | o | o:Refresh(), hwg_SetFocus( o:Handle ), o:Refresh() }
   //xDlg:bGetFocus := { || xDlg:xControl:SetFocus() }

   (xDlg); (workarea); (xParent);(oFrmClass)

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

STATIC FUNCTION gui_BrowseRefresh( xDlg, xControl )

   xControl:Refresh()

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_ComboCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, aList, xValue )

   @ nCol, nRow GET COMBOBOX xControl VAR xValue ITEMS aList OF xParent STYLE WS_TABSTOP SIZE nWidth, nHeight

   (xDlg); (xValue)

   RETURN Nil

STATIC FUNCTION gui_CheckboxCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   @ nCol, nRow CHECKBOX xControl CAPTION "" OF xParent STYLE WS_TABSTOP SIZE nWidth, nHeight

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   @ nCol, nRow DATESELECT xControl ;
      OF xParent ;
      SIZE nWidth, nHeight FONT oFont ;
      INIT dValue

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_SpinnerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, nValue, aList, oFrmClass )

   @ nCol, nRow GET UPDOWN xControl VAR nValue ;
      RANGE aList[1], aList[2] OF xParent SIZE nWidth, nHeight WIDTH 15 FONT oFont
   //gui_TextCreate( xDlg, xParent, @xControl, nRow, nCol, nWidth, nHeight, @nValue )

   (aList);(oFrmClass);(xDlg)

   RETURN Nil

STATIC FUNCTION gui_DialogActivate( xDlg, bCode )

   IF Empty( bCode )
      ACTIVATE DIALOG xDLG CENTER
   ELSE
      ACTIVATE DIALOG xDlg CENTER ON ACTIVATE bCode
   ENDIF

   RETURN Nil

STATIC FUNCTION gui_DialogClose( xDlg )

   RETURN xDlg:Close()

STATIC FUNCTION gui_DialogCreate( oFrm, xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal )

   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF
   INIT DIALOG xDlg ;
      CLIPPER ;
      FONT oFont ;
      NOEXIT ;
      TITLE     cTitle + " (" + GUI():LibName() + ")"  ;
      AT        nRow, nCol ;
      SIZE      nWidth, nHeight ;
      BACKCOLOR COLOR_WHITE ;
      ON INIT bInit

   (xDlg);(lModal);(oFrm)

   RETURN Nil

STATIC FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   LOCAL xFocus, lOk

   xFocus := hwg_GetFocus()
   IF PCount() == 1
      lOk := xFocus == xDlg:Handle
   ELSE
      lOk := xFocus == xControl:Handle
   ENDIF

   RETURN lOk

STATIC FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

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

//STATIC FUNCTION LabelPaint( o, h, lBorder )

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

STATIC FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   LOCAL oFont := HFont():Add( PREVIEW_FONTNAME, 0, -11 )

   @ nCol, nRow EDITBOX xControl ;
      CAPTION xValue ;
      SIZE    nWidth, nHeight ;
      FONT    oFont ;
      STYLE   ES_MULTILINE + ES_AUTOVSCROLL + WS_VSCROLL + WS_HSCROLL

   (xDlg); (xParent)

   RETURN Nil

STATIC FUNCTION gui_Msgbox( cText )

   RETURN hwg_MsgInfo( cText )

STATIC FUNCTION gui_MsgYesNo( cText )

   RETURN hwg_MsgYesNo( cText )

STATIC FUNCTION gui_SetFocus( xDlg, xControl )

   IF Empty( xControl )
      //xDlg:SetFocus()
   ELSE
      xControl:SetFocus()
   ENDIF

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_StatusCreate( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_TabCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   @ nCol, nRow TAB xControl ;
      ITEMS {} ;
      OF    xParent ;
      ; // ID    101 ;
      SIZE  nWidth, nHeight ;
      STYLE WS_CHILD + WS_VISIBLE

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabEnd()

   RETURN Nil

STATIC FUNCTION gui_TabPageBegin( xDlg, xParent, xTab, xPage, nPageCount, cText )

   BEGIN PAGE cText OF xTab
   xPage := xTab

   (xDlg);(nPageCount);(xDlg);(xParent)

   RETURN Nil

STATIC FUNCTION gui_TabPageEnd( xDlg, xControl )

   END PAGE OF xControl

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   LOCAL nTab, nPageNext

   IF Len( aList ) == 0
      RETURN Nil
   ENDIF
   FOR nTab = 1 TO Len( aList )
      nPageNext  := iif( nTab == Len( aList ), 1, nTab + 1 )
      GUI():TabSetLostFocus( aList[ nTab, Len( aList[ nTab ] ) ], xTab, nPageNext, aList[ nPageNext, 1 ] )
   NEXT

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabSetLostFocus( oTextbox, oTab, nPageNext, oTextboxNext )

   oTextbox:bLostFocus := { || oTab:ChangePage( nPageNext ), oTab:SetTab( nPageNext ), gui_SetFocus( Nil, oTextboxNext ), .T. }

   RETURN Nil

STATIC FUNCTION gui_TextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, oFrmClass, lPassword )

   @ nCol, nRow GET xControl ;
      VAR       xValue ;
      OF        xParent ;
      SIZE      nWidth, nHeight ;
      STYLE     WS_DISABLED + iif( ValType( xValue ) $ "N,N+", ES_RIGHT, ES_LEFT ) ;
      ; // MAXLENGTH nMaxLength ;
      PICTURE   iif( Empty( cPicture ), Nil, cPicture ) ;
      VALID     bValid

   (nMaxLength);(bAction);(cImage);(aItem);(oFrmClass);(lPassword);(xDlg)

   RETURN Nil

STATIC FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_ControlGetValue( xDlg, xControl )

   (xDlg)

   RETURN xControl:Value

STATIC FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

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

STATIC FUNCTION gui_DlgSetKey( oFrmClass )

   LOCAL aItem

   FOR EACH aItem IN oFrmClass:aDlgKeyDown
   NEXT

   RETURN Nil

#ifdef DLGAUTO_AS_SQL
FUNCTION ADOSkipper( cnSQL, nSkip )

   LOCAL nRec := cnSQL:AbsolutePosition()

   IF ! cnSQL:Eof()
      cnSQL:Move( nSkip )
      IF cnSQL:Eof()
         cnSQL:MoveLast()
      ENDIF
      IF cnSQL:Bof()
         cnSQL:MoveFirst()
      ENDIF
   ENDIF

   RETURN cnSQL:AbsolutePosition() - nRec
#endif
