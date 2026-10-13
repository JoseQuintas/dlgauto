/*
lib_hbbuilder - HarbourBuilder (FiveTechSoft) source selected by lib.prg

needs HarbourBuilder runtime as library:
   hbmk2 hbbuilderlib.hbp  (on HarbourBuilder folder)
   hbmk2 test.hbp <path>/hbbuilder.hbc
*/

#include "hbclass.ch"
#include "frm_class.ch"

#define HBB_EV_EXIT     1
#define HBB_EV_KEYDOWN  2
#define HBB_EV_DBLCLICK 3

#define HBB_VK_RETURN   13

#define HBB_TABHEADER   28  // tab caption height, controls on page are form children

#define BRW_WORKAREA    1
#define BRW_COLUMNS     2
#define BRW_RECNO       3
#define BRW_ISADO       4

THREAD STATIC aFormSize   := {} // { width, height, line spacing, line height, font normal, font small }, once per thread
THREAD STATIC lMainActive := .F.
THREAD STATIC hDlgInfo           // dialog hCpp => { "init" => block, "after" => {}, "ctrls" => {}, "done" => .F. }
THREAD STATIC hCtlInfo           // control hCpp => { "type" => ValType, "picture" => cPicture, "len" => nLen, "brw" => {} }

CREATE CLASS HBBUILDERClass

   /*--- init ---*/
   METHOD LibName()             INLINE "HBBUILDER"
   METHOD Init()                INLINE gui_Init()

   /*--- size ---*/
   METHOD AppFontName()         INLINE "verdana"
   METHOD AppFontSizeNormal()   INLINE gui_FormSize()[ 5 ]
   METHOD AppFontSizeSmall()    INLINE gui_FormSize()[ 6 ]
   METHOD AppLineHeight()       INLINE gui_FormSize()[ 4 ]
   METHOD AppLineSpacing()      INLINE gui_FormSize()[ 3 ]
   METHOD AppButtonBetween()    INLINE 3
   METHOD FormWidth()           INLINE gui_FormSize()[ 1 ]
   METHOD FormHeight()          INLINE gui_FormSize()[ 2 ]
   METHOD AppButtonSize()       INLINE ::AppLineSpacing() * 2
   METHOD AppTabWidth()         INLINE ::FormWidth() - 30
   METHOD AppTabHeight()        INLINE ::FormHeight() - ( ::AppLineSpacing() * 6 )

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

   /* browse DBF */
   METHOD BrowseDBF(...)           INLINE gui_BrowseDBF(...)
   METHOD BrowseDBFRefresh(...)    INLINE gui_BrowseRefresh(...)
   METHOD browseDBFkeydown(...)    INLINE gui_BrowseKeydown(...)
   METHOD BrowseDBFSetKeyFilter( ... ) INLINE Nil
   METHOD BrowseDBFEnter( ... )    INLINE gui_BrowseEnter( ... )

   /* browse ADO */
   METHOD BrowseADO(...)               INLINE gui_BrowseADO(...)
   METHOD BrowseADORefresh(...)        INLINE gui_BrowseRefresh(...)
   METHOD browseADOkeydown(...)        INLINE gui_BrowseKeydown(...)
   METHOD BrowseADOSetKeyFilter( ... ) INLINE Nil
   METHOD BrowseADOEnter( ... )        INLINE gui_BrowseEnter( ... )

   /* tab */
   METHOD TabCreate(...)        INLINE gui_TabCreate(...)
   METHOD TabEnd(...)           INLINE gui_TabEnd(...)
   METHOD TabPageBegin(...)     INLINE gui_TabPageBegin(...)
   METHOD TabPageEnd(...)       INLINE gui_TabPageEnd(...)
   METHOD TabNavigate(...)      INLINE gui_TabNavigate(...)
   METHOD TabSetLostFocus(...)  INLINE Nil

   /* msg */
   METHOD Msgbox(...)           INLINE gui_Msgbox(...)
   METHOD MsgYesNo(...)         INLINE gui_MsgYesNo(...)

   /* aux */
   METHOD IsCurrentFocus(...)   INLINE gui_IsCurrentFocus(...)
   METHOD SetFocus(...)         INLINE gui_SetFocus(...)
   METHOD ControlEnable(...)    INLINE gui_ControlEnable(...)
   METHOD ControlGetValue(...)  INLINE gui_ControlGetValue(...)
   METHOD ControlSetValue(...)  INLINE gui_ControlSetValue(...)
   METHOD BtnSetImageText(...)  INLINE Nil

   ENDCLASS

/* tab page: controls are form children, page only gives owner and position */
CREATE CLASS HBBTabPage

   VAR oPage
   VAR nRowOffset INIT 0
   VAR nColOffset INIT 0

   METHOD New( oFolder, nPage )
   ACCESS hCpp INLINE ::oPage:hCpp

   ENDCLASS

METHOD New( oFolder, nPage ) CLASS HBBTabPage

   ::oPage      := TFolderPage():New( oFolder, nPage )
   ::nRowOffset := oFolder:nTop + HBB_TABHEADER
   ::nColOffset := oFolder:nLeft + 5

   RETURN Self

STATIC FUNCTION gui_FormSize()

   LOCAL nWidth, nHeight

   IF Empty( aFormSize )
      SetDPIAware() // before read screen size
      nWidth  := wapi_GetSystemMetrics( 16 ) // SM_CXFULLSCREEN, work area without taskbar
      nHeight := wapi_GetSystemMetrics( 17 ) // SM_CYFULLSCREEN
      aFormSize := { ;
         Int( Min( nWidth, 1920 ) * 0.95 ), ;
         Int( Min( nHeight, 1080 ) * 0.90 ) }
      AAdd( aFormSize, Int( aFormSize[ 2 ] / 35 ) )   // 3 line spacing (row size)
      AAdd( aFormSize, Int( aFormSize[ 3 ] * 0.8 ) )  // 4 line height
      AAdd( aFormSize, Int( aFormSize[ 4 ] * 0.8 ) )  // 5 font size normal, a little less than line
      AAdd( aFormSize, Int( aFormSize[ 5 ] / 1.5 ) )  // 6 font size small
   ENDIF

   RETURN aFormSize

STATIC FUNCTION gui_Init()

   gui_DlgList()

   RETURN Nil

/* lazy init, once per thread (JPA runs each module in its own thread) */
STATIC FUNCTION gui_DlgList()

   IF hDlgInfo == Nil
      hDlgInfo := { => }
      hCtlInfo := { => }
      HBB_Init() // keyboard/focus hooks of this thread
   ENDIF

   RETURN hDlgInfo

STATIC FUNCTION gui_CtlList()

   gui_DlgList()

   RETURN hCtlInfo

/* position inside tab page */
STATIC FUNCTION gui_Pos( xParent, nRow, nCol )

   IF ValType( xParent ) == "O" .AND. xParent:ClassName() == "HBBTABPAGE"
      nRow += xParent:nRowOffset
      nCol += xParent:nColOffset
   ENDIF

   RETURN Nil

/* register control to dialog, used to release events and run code after window creation */
STATIC FUNCTION gui_AddCtrl( xDlg, xControl, bAfter )

   LOCAL aInfo

   IF hb_HHasKey( gui_DlgList(), xDlg:hCpp )
      aInfo := gui_DlgList()[ xDlg:hCpp ]
      AAdd( aInfo[ "ctrls" ], xControl:hCpp )
      IF ! Empty( bAfter )
         IF aInfo[ "done" ]
            Eval( bAfter )
         ELSE
            AAdd( aInfo[ "after" ], bAfter )
         ENDIF
      ENDIF
   ENDIF

   RETURN Nil

STATIC FUNCTION gui_CtlInfo( xControl, cKey, xDefault )

   IF hb_HHasKey( gui_CtlList(), xControl:hCpp ) .AND. hb_HHasKey( gui_CtlList()[ xControl:hCpp ], cKey )
      RETURN gui_CtlList()[ xControl:hCpp ][ cKey ]
   ENDIF

   RETURN xDefault

STATIC FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL aGroupList, cDBF, oPopup

   gui_DialogCreate( Nil, @xDlg, 0, 0, gui_FormSize()[ 1 ], gui_FormSize()[ 2 ], cTitle )
   FOR EACH aGroupList IN aMenuList
      oPopup := xDlg:AddPopup( "Data" + Ltrim( Str( aGroupList:__EnumIndex ) ) )
      FOR EACH cDBF IN aGroupList
         oPopup:AddItem( cDBF, gui_MenuBlock( cDBF, aAllSetup ) )
      NEXT
   NEXT
   oPopup := xDlg:AddPopup( "NoData" )
   oPopup:AddItem( "NoData Layout 1", { || frm_DialogFree( 1 ) } )
   oPopup:AddItem( "NoData Layout 2", { || frm_DialogFree( 2 ) } )
   oPopup:AddItem( "NoData Layout 3", { || frm_DialogFree( 3 ) } )
   oPopup := xDlg:AddPopup( "Exit" )
   oPopup:AddItem( "Test Default", { || DlgAuto_ShowDefault() } )
   oPopup:AddItem( "&Exit", { || gui_DialogClose( xDlg ) } )
   TMonthCalendar():New( xDlg, 400, 400, 250, 250 )
   gui_DialogActivate( xDlg )

   RETURN Nil

STATIC FUNCTION gui_MenuBlock( cDBF, aAllSetup )

   RETURN { || frm_funcMain( cDBF, aAllSetup ) }

STATIC FUNCTION gui_ButtonCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   gui_Pos( xParent, @nRow, @nCol )
   xControl := TButton():New( xParent, cCaption, nCol, nRow, nWidth, nHeight )
   xControl:oFont := gui_Font()
   IF ! Empty( bAction )
      xControl:OnClick := bAction
   ENDIF
   gui_AddCtrl( xDlg, xControl )

   (cResName)

   RETURN Nil

STATIC FUNCTION gui_BrowseDBF( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea, aKeyDownList, oFrmClass )

   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := { { HBB_VK_RETURN, { || gui_BrowseEnter( cField, @xValue, xDlg, xControl ) } } }
   ENDIF
   gui_BrowseCreate( xDlg, xParent, @xControl, nRow, nCol, nWidth, nHeight, oTBrowse, workarea, .F. )
   HBB_OnEvent( xControl:hCpp, HBB_EV_KEYDOWN, ;
      { | nKey | gui_BrowseKeydown( xControl, xDlg, nKey, cField, workarea, xValue, aKeyDownList ) } )
   HBB_OnEvent( xControl:hCpp, HBB_EV_DBLCLICK, ;
      { || gui_BrowseKeydown( xControl, xDlg, HBB_VK_RETURN, cField, workarea, xValue, aKeyDownList ) } )

   (oFrmClass)

   RETURN Nil

STATIC FUNCTION gui_BrowseADO( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea, aKeyDownList, oFrmClass )

   IF ValType( aKeyDownList ) != "A"
      aKeyDownList := { { HBB_VK_RETURN, { || gui_BrowseEnter( cField, @xValue, xDlg, xControl ) } } }
   ENDIF
   gui_BrowseCreate( xDlg, xParent, @xControl, nRow, nCol, nWidth, nHeight, oTBrowse, workarea, .T. )
   HBB_OnEvent( xControl:hCpp, HBB_EV_KEYDOWN, ;
      { | nKey | gui_BrowseKeydown( xControl, xDlg, nKey, cField, workarea, xValue, aKeyDownList ) } )
   HBB_OnEvent( xControl:hCpp, HBB_EV_DBLCLICK, ;
      { || gui_BrowseKeydown( xControl, xDlg, HBB_VK_RETURN, cField, workarea, xValue, aKeyDownList ) } )

   (oFrmClass)

   RETURN Nil

STATIC FUNCTION gui_BrowseCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTBrowse, workarea, lADO )

   LOCAL aItem, xData

   gui_Pos( xParent, @nRow, @nCol )
   xControl := TBrowse():New( xParent, nCol, nRow, nWidth, nHeight )
   xControl:oFont := gui_Font()
   FOR EACH aItem IN oTBrowse
      xControl:AddColumn( aItem[ 1 ], 10 * ( 2 + Max( Len( aItem[ 1 ] ), ;
         iif( Len( aItem ) >= 5 .AND. ValType( aItem[ 5 ] ) == "N", aItem[ 5 ], 10 ) ) ) )
   NEXT
   IF lADO
      xData := ADOLocal()
      xData:Execute( "SELECT * FROM " + workarea )
   ELSE
      xData := workarea
   ENDIF
   gui_CtlList()[ xControl:hCpp ] := { "type" => "B", ;
      "brw" => { xData, oTBrowse, {}, lADO } }
   gui_AddCtrl( xDlg, xControl, { || HBB_BrowseNoFooter( xControl:hCpp ), gui_BrowseFill( xControl ) } )

   RETURN Nil

/* window must exist to fill browse */
STATIC FUNCTION gui_BrowseFill( xControl )

   LOCAL aBrw, aItem, nRow := 0, nRecNo, xData, cAlias

   aBrw := gui_CtlInfo( xControl, "brw" )
   IF Empty( aBrw ) .OR. HBB_CtrlHwnd( xControl:hCpp ) == 0
      RETURN Nil
   ENDIF
   HBB_BrowseClear( xControl:hCpp )
   aBrw[ BRW_RECNO ] := {}
   xData := aBrw[ BRW_WORKAREA ]
   IF aBrw[ BRW_ISADO ]
      IF xData:RecordCount() > 0
         xData:MoveFirst()
         DO WHILE ! xData:Eof()
            FOR EACH aItem IN aBrw[ BRW_COLUMNS ]
               UI_BrowseSetCell( xControl:hCpp, nRow, aItem:__EnumIndex - 1, ;
                  gui_BrowseText( xData:Value( aItem[ 2 ] ), aItem[ 3 ] ) )
            NEXT
            AAdd( aBrw[ BRW_RECNO ], xData:AbsolutePosition() )
            nRow++
            xData:MoveNext()
         ENDDO
         xData:MoveFirst()
      ENDIF
   ELSE
      cAlias := xData
      nRecNo := ( cAlias )->( RecNo() )
      ( cAlias )->( dbGoTop() )
      DO WHILE ! ( cAlias )->( Eof() )
         FOR EACH aItem IN aBrw[ BRW_COLUMNS ]
            UI_BrowseSetCell( xControl:hCpp, nRow, aItem:__EnumIndex - 1, ;
               gui_BrowseText( ( cAlias )->( FieldGet( FieldNum( aItem[ 2 ] ) ) ), aItem[ 3 ] ) )
         NEXT
         AAdd( aBrw[ BRW_RECNO ], ( cAlias )->( RecNo() ) )
         nRow++
         ( cAlias )->( dbSkip() )
      ENDDO
      ( cAlias )->( dbGoto( nRecNo ) )
   ENDIF
   HBB_BrowseSetRow( xControl:hCpp, 1 )
   xControl:Refresh()

   RETURN Nil

STATIC FUNCTION gui_BrowseText( xValue, cPicture )

   IF Empty( cPicture )
      RETURN AllTrim( hb_ValToStr( xValue ) )
   ENDIF

   RETURN AllTrim( Transform( xValue, cPicture ) )

/* go to selected record before any action */
STATIC FUNCTION gui_BrowseGoSelected( xControl )

   LOCAL aBrw, nRow

   aBrw := gui_CtlInfo( xControl, "brw" )
   nRow := HBB_BrowseGetRow( xControl:hCpp )
   IF Empty( aBrw ) .OR. nRow < 1 .OR. nRow > Len( aBrw[ BRW_RECNO ] )
      RETURN .F.
   ENDIF
   IF aBrw[ BRW_ISADO ]
      aBrw[ BRW_WORKAREA ]:MoveFirst()
      aBrw[ BRW_WORKAREA ]:Move( aBrw[ BRW_RECNO ][ nRow ] - 1 )
   ELSE
      ( aBrw[ BRW_WORKAREA ] )->( dbGoto( aBrw[ BRW_RECNO ][ nRow ] ) )
   ENDIF

   RETURN .T.

STATIC FUNCTION gui_BrowseKeydown( xControl, xDlg, nKey, cField, workarea, xValue, aKeyDownList )

   LOCAL nPos, nSelect

   nPos := hb_AScan( aKeyDownList, { | e | nKey == e[ 1 ] } )
   IF nPos != 0 .AND. gui_BrowseGoSelected( xControl )
      nSelect := Select()
      IF ValType( workarea ) == "C"
         SELECT ( Select( workarea ) )
      ENDIF
      Eval( aKeyDownList[ nPos ][ 2 ], cField, @xValue, xDlg, xControl )
      IF nSelect != 0
         SELECT ( nSelect )
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION gui_BrowseEnter( cField, xValue, xDlg, xControl )

   LOCAL aBrw

   IF ! Empty( cField )
      aBrw := iif( Empty( xControl ), Nil, gui_CtlInfo( xControl, "brw" ) )
      IF ! Empty( aBrw ) .AND. aBrw[ BRW_ISADO ]
         xValue := aBrw[ BRW_WORKAREA ]:Value( cField )
      ELSEIF ! Empty( aBrw )
         xValue := ( aBrw[ BRW_WORKAREA ] )->( FieldGet( FieldNum( cField ) ) )
      ELSE
         xValue := FieldGet( FieldNum( cField ) )
      ENDIF
   ENDIF
   gui_DialogClose( xDlg )

   RETURN Nil

STATIC FUNCTION gui_BrowseRefresh( xDlg, xControl )

   gui_BrowseFill( xControl )

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_ComboCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, aList, xValue )

   gui_Pos( xParent, @nRow, @nCol )
   xControl := TComboBox():New( xParent, nCol, nRow, nWidth, nHeight * 8 )
   xControl:oFont := gui_Font()
   xControl:FillItems( aList )
   gui_CtlList()[ xControl:hCpp ] := { "type" => "N", "list" => aList }
   gui_AddCtrl( xDlg, xControl, { || HBB_ComboSetSel( xControl:hCpp, ;
      iif( ValType( xValue ) == "N" .AND. xValue > 0, xValue, 1 ) ) } )

   RETURN Nil

STATIC FUNCTION gui_CheckboxCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   gui_Pos( xParent, @nRow, @nCol )
   xControl := TCheckBox():New( xParent, "", nCol, nRow, nWidth, nHeight )
   xControl:oFont := gui_Font()
   gui_CtlList()[ xControl:hCpp ] := { "type" => "L" }
   gui_AddCtrl( xDlg, xControl )

   RETURN Nil

STATIC FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, dValue )

   gui_Pos( xParent, @nRow, @nCol )
   xControl := TDateTimePicker():New( xParent, nCol, nRow, nWidth, nHeight )
   xControl:oFont := gui_Font()
   gui_CtlList()[ xControl:hCpp ] := { "type" => "D", "dtp" => .T. }
   gui_AddCtrl( xDlg, xControl, { || HBB_DtpSetDate( xControl:hCpp, Dtos( dValue ) ) } )

   RETURN Nil

STATIC FUNCTION gui_DialogActivate( xDlg, bCode )

   LOCAL aInfo, lMain

   aInfo := gui_DlgList()[ xDlg:hCpp ]
   IF ! Empty( bCode )
      aInfo[ "init" ] := bCode
   ENDIF
   xDlg:OnActivate := { || gui_DialogOnActivate( xDlg ) }

   lMain := ! lMainActive
   IF lMain
      lMainActive := .T.
      xDlg:Activate()   // message loop of application
      lMainActive := .F.
   ELSE
      xDlg:ShowModal()
   ENDIF
   HBB_ReleaseEvents( aInfo[ "ctrls" ] )
   hb_HDel( gui_DlgList(), xDlg:hCpp )

   RETURN Nil

/* windows created, only once */
STATIC FUNCTION gui_DialogOnActivate( xDlg )

   LOCAL aInfo, bAfter

   IF ! hb_HHasKey( gui_DlgList(), xDlg:hCpp )
      RETURN Nil
   ENDIF
   aInfo := gui_DlgList()[ xDlg:hCpp ]
   IF aInfo[ "done" ]
      RETURN Nil
   ENDIF
   aInfo[ "done" ] := .T.
   FOR EACH bAfter IN aInfo[ "after" ]
      Eval( bAfter )
   NEXT
   aInfo[ "after" ] := {}
   IF ! Empty( aInfo[ "init" ] )
      Eval( aInfo[ "init" ] )
   ENDIF
   IF ! Empty( aInfo[ "focus" ] )
      HBB_SetFocus( aInfo[ "focus" ] )
   ENDIF

   RETURN Nil

STATIC FUNCTION gui_DialogClose( xDlg )

   HBB_FormPostClose( xDlg:hCpp )

   RETURN Nil

STATIC FUNCTION gui_DialogCreate( oFrm, xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal )

   xDlg := TForm():New( cTitle + " (" + GUI():LibName() + ")", nWidth, nHeight )
   xDlg:cFontName := "Verdana"
   xDlg:nFontSize := gui_FontSize()
   xDlg:nClrPane  := COLOR_WHITE
   gui_DlgList()[ xDlg:hCpp ] := { "init" => bInit, "after" => {}, "ctrls" => {}, ;
      "done" => .F., "focus" => Nil }

   (nRow); (nCol); (oFrm); (lModal)

   RETURN Nil

/* font height in pixels, edit needs space for border */
STATIC FUNCTION gui_FontSize()

   RETURN Max( 6, Int( ( gui_FormSize()[ 4 ] - 8 ) * 72 / HBB_ScreenDpi() ) )

STATIC FUNCTION gui_Font()

   RETURN "Verdana," + hb_ntos( gui_FontSize() )

STATIC FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   IF PCount() == 1
      RETURN HBB_IsFocus( xDlg:hCpp )
   ENDIF

   RETURN HBB_IsFocus( xControl:hCpp )

STATIC FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   hb_Default( @lBorder, .F. )
   gui_Pos( xParent, @nRow, @nCol )
   xControl := TLabel():New( xParent, xValue, nCol, nRow, nWidth, nHeight )
   xControl:oFont := gui_Font()
   xControl:nClrText := COLOR_BLACK
   IF lBorder
      xControl:nClrPane := COLOR_GREEN
   ELSE
      xControl:lTransparent := .T.
   ENDIF
   gui_CtlList()[ xControl:hCpp ] := { "type" => "C" }
   gui_AddCtrl( xDlg, xControl )

   RETURN Nil

STATIC FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   gui_Pos( xParent, @nRow, @nCol )
   xControl := TMemo():New( xParent, iif( ValType( xValue ) == "C", xValue, "" ), nCol, nRow, nWidth, nHeight )
   xControl:oFont := PREVIEW_FONTNAME + ",10"
   gui_CtlList()[ xControl:hCpp ] := { "type" => "C", "memo" => .T. }
   gui_AddCtrl( xDlg, xControl )

   RETURN Nil

STATIC FUNCTION gui_Msgbox( cText )

   RETURN UI_MsgBox( hb_ValToStr( cText ), "Message" )

STATIC FUNCTION gui_MsgYesNo( cText )

   RETURN UI_MsgYesNo( hb_ValToStr( cText ), "Confirm" )

STATIC FUNCTION gui_SetFocus( xDlg, xControl )

   LOCAL aInfo

   IF Empty( xControl )
      IF ! Empty( xDlg )
         HBB_SetFocus( xDlg:hCpp )
      ENDIF
      RETURN Nil
   ENDIF
   IF HBB_CtrlHwnd( xControl:hCpp ) != 0
      HBB_SetFocus( xControl:hCpp )
   ELSEIF ! Empty( xDlg ) .AND. hb_HHasKey( gui_DlgList(), xDlg:hCpp )
      // window not created yet
      aInfo := gui_DlgList()[ xDlg:hCpp ]
      aInfo[ "focus" ] := xControl:hCpp
   ENDIF

   RETURN Nil

STATIC FUNCTION gui_SpinnerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, nValue, aList, oFrmClass )

   gui_TextCreate( xDlg, xParent, @xControl, nRow, nCol, nWidth, nHeight, nValue )

   (aList); (oFrmClass)

   RETURN Nil

STATIC FUNCTION gui_StatusCreate( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_TabCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   gui_Pos( xParent, @nRow, @nCol )
   xControl := TFolder():New( xParent, nCol, nRow, nWidth, nHeight )
   xControl:oFont := gui_Font()
   gui_CtlList()[ xControl:hCpp ] := { "type" => "T", "prompts" => {} }
   // page visibility is applied only on tab change
   gui_AddCtrl( xDlg, xControl, { || UI_TabControlSetSel( xControl:hCpp, 0 ) } )

   RETURN Nil

STATIC FUNCTION gui_TabEnd( xDlg, xTab )

   xTab:SetPrompts( gui_CtlInfo( xTab, "prompts", {} ) )

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabPageBegin( xDlg, xParent, xTab, xPage, nPageCount, cText )

   AAdd( gui_CtlInfo( xTab, "prompts", {} ), AllTrim( cText ) )
   xPage := HBBTabPage():New( xTab, nPageCount - 1 )

   (xDlg); (xParent)

   RETURN Nil

STATIC FUNCTION gui_TabPageEnd( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg); (xTab); (aList)

   RETURN Nil

STATIC FUNCTION gui_TextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, oFrmClass, lPassword )

   gui_Pos( xParent, @nRow, @nCol )
   xControl := TEdit():New( xParent, gui_ValueToText( xValue, cPicture ), nCol, nRow, nWidth, nHeight )
   xControl:oFont := gui_Font()
   gui_CtlList()[ xControl:hCpp ] := { "type" => ValType( xValue ), "picture" => cPicture, ;
      "len" => iif( ValType( xValue ) == "C", Len( xValue ), nMaxLength ) }
   IF ! Empty( bValid )
      HBB_OnEvent( xControl:hCpp, HBB_EV_EXIT, { || Eval( bValid ) } )
   ENDIF
   gui_AddCtrl( xDlg, xControl )

   (bAction); (cImage); (aItem); (oFrmClass); (lPassword)

   RETURN Nil

STATIC FUNCTION gui_ValueToText( xValue, cPicture )

   DO CASE
   CASE ValType( xValue ) == "C" .AND. Empty( cPicture ); RETURN xValue
   CASE ValType( xValue ) == "D" .AND. Empty( cPicture ); RETURN Dtoc( xValue )
   CASE ValType( xValue ) == "L";                          RETURN iif( xValue, "Y", "N" )
   CASE xValue == Nil;                                     RETURN ""
   CASE Empty( cPicture );                                 RETURN hb_ValToStr( xValue )
   ENDCASE

   RETURN Transform( xValue, cPicture )

STATIC FUNCTION gui_TextToValue( cText, cType, nLen )

   DO CASE
   CASE cType == "N"; RETURN Val( StrTran( StrTran( cText, ".", "" ), ",", "." ) )
   CASE cType == "D"; RETURN Ctod( cText )
   CASE cType == "L"; RETURN Upper( AllTrim( cText ) ) $ "Y,S,T,.T."
   CASE cType == "C" .AND. ValType( nLen ) == "N" .AND. nLen > 0; RETURN Pad( cText, nLen )
   ENDCASE

   RETURN cText

STATIC FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   xControl:lEnabled := lEnable

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_ControlGetValue( xDlg, xControl )

   LOCAL cType

   cType := gui_CtlInfo( xControl, "type", "C" )
   DO CASE
   CASE xControl:ClassName() == "TCHECKBOX";       RETURN HBB_GetCheck( xControl:hCpp )
   CASE xControl:ClassName() == "TCOMBOBOX";       RETURN HBB_ComboGetSel( xControl:hCpp )
   CASE xControl:ClassName() == "TDATETIMEPICKER"; RETURN Stod( HBB_DtpGetDate( xControl:hCpp ) )
   ENDCASE

   (xDlg)

   RETURN gui_TextToValue( HBB_GetText( xControl:hCpp ), cType, gui_CtlInfo( xControl, "len" ) )

STATIC FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   DO CASE
   CASE xControl:ClassName() == "TCHECKBOX"
      HBB_SetCheck( xControl:hCpp, ValType( xValue ) == "L" .AND. xValue )
   CASE xControl:ClassName() == "TCOMBOBOX"
      HBB_ComboSetSel( xControl:hCpp, xValue )
   CASE xControl:ClassName() == "TDATETIMEPICKER"
      HBB_DtpSetDate( xControl:hCpp, Dtos( xValue ) )
   CASE xControl:ClassName() == "TLABEL"
      xControl:cText := hb_ValToStr( xValue )
   OTHERWISE
      xControl:cText := gui_ValueToText( xValue, gui_CtlInfo( xControl, "picture" ) )
   ENDCASE

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_DlgSetKey( oFrmClass )

   (oFrmClass)

   RETURN Nil
