/*
lib_gtwvg - gtwvg source selected by lib.prg

Note: Only to show on screen
*/

#include "hbclass.ch"
#include "inkey.ch"
#include "frm_class.ch"

THREAD STATIC oGUI

FUNCTION GUI( xValue )

   IF xValue != Nil
      oGUI := xValue
   ENDIF
   IF oGUI == Nil
      oGUI := GTWVGClass():New()
   ENDIF

   RETURN oGUI

CREATE CLASS GTWVGClass

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

   SetMode(30,100)
   CLS

   RETURN Nil

STATIC FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL oMainMenu, aGroupList, cDBF, oMenuGroup

   SetMode(30,100)
   CLS
   oMainMenu := wvgSetAppWindow():MenuBar()
   FOR EACH aGroupList IN aMenuList
      oMenuGroup := wvgMenu():New( oMainMenu,,.T. ):Create()
      FOR EACH cDBF IN aGroupList
         oMenuGroup:AddItem( cDBF, { || hb_ThreadStart( { | nGt | nGt := hb_gtSelect(), ;
            frm_funcMain( cDBF, aAllSetup ), ;
            hb_gtSelect( nGt ) } ) } )
      NEXT
      oMainMenu:AddItem( oMenuGroup, "Data" + Ltrim( Str( aGroupList:__EnumIndex ) ) )
   NEXT
   oMainMenu:AddItem( "Exit", { || __Quit() } )
   DO WHILE Inkey(1) != K_ESC
   ENDDO

   (xDlg);(cTitle)

   RETURN Nil

STATIC FUNCTION gui_ButtonCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   xControl := wvgPushButton():New()
   WITH OBJECT xControl
      :PointerFocus := .F.
      :Style += BS_TOP
      :Create( xParent,,{nCol,nRow},{nHeight,nWidth})
      :SetCaption( {, WVG_IMAGE_ICONRESOURCE, cResName } )
      :SetCaption( cCaption )
      :Activate := bAction
   ENDWITH

   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight); (cCaption); (cResName); (bAction)

   RETURN Nil

STATIC FUNCTION gui_CheckboxCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   xControl := wvgCheckBox():New()
   WITH OBJECT xControl
      :PointerFocus := .F.
      :Caption := "."
      :Selection := .F.
      :Create( xParent,,{nCol,nRow},{ nWidth, nHeight } )
      :setColorFG( "W+" )
      :setColorBG( "B*" )
   ENDWITH

   (nHeight);(xDlg)

   RETURN Nil

STATIC FUNCTION gui_ComboCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, aList, xValue )

   LOCAL cItem

   xControl := wvgCombobox():New()
   WITH OBJECT xControl
      :Type := WVGCOMBO_DROPDOWN
      FOR EACH cItem IN aList
         :AddItem( cItem )
      NEXT
      :Create( xParent,, { nCol, nRow }, { nWidth, nHeight }, , .T. )
      :SetColorFG("W+")
      :SetColorBG("B*")
      FOR EACH cItem IN aList
         :AddItem( cItem )
      NEXT

   ENDWITH

   (xValue);(xDlg)

   RETURN Nil

STATIC FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   gui_TextCreate( xDlg, xParent, @xControl, nRow, nCol, nWidth, nHeight, dValue )

   RETURN Nil

STATIC FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   (xDlg);(xControl);(lEnable)

   RETURN Nil

STATIC FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(OTbrowse);(cFIeld);(xValue);(workarea);(xParent)

   RETURN Nil

STATIC FUNCTION gui_BrowseRefresh( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_DialogActivate( xDlg, bCode )

   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_DialogClose( xDlg )

   xDlg:Destroy()

   (xDlg)

   QUIT

   RETURN Nil

STATIC FUNCTION gui_DialogCreate( oFrm, xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit )

   LOCAL oSBar, oPanel, oPanel1, oPanel2

   xDlg := wvgSetAppWindow()

   oSBar   := WvgStatusBar():new( xDlg )
   WITH OBJECT OSBar
      OSBar:create( , , , , , .T. )
      oSBar:panelClick := {| oPanel | wvg_MessageBox( , oPanel:caption ) }
      oPanel  := oSBar:getItem( 1 )
      oPanel:caption := "My Root Panel"
      oPanel1 := oSBar:addItem()
      oPanel1:caption := "Ready"
      oPanel2 := oSBar:addItem()
      oPanel2:caption := "Click on any part!"
   ENDWITH

   //xDlg := wvgCrt():New()
   //xDlg:Create(,,{0,0},{30,100})
   //xDlg:lModal := .T.
   //xDlg:Show()
   //SetColor( "W/B" )
   //CLS

   (xDlg);(nRow);(nCol);(nWidth);(nHeight);(cTitle);(bInit);(oFrm)

   RETURN Nil

STATIC FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   (xDlg);(xControl)

   RETURN .F.

STATIC FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   xControl := wvgStatic():New()
   WITH OBJECT xControl
      :Type := WVGSTATIC_TYPE_TEXT
      :Options := WVGSTATIC_TEXT_LEFT
      :Style += iif( lBorder, WS_BORDER, 0 )
      :SetColorFG( "W/B" )
      :SetColorBG( "W/B" )
      :Caption := xValue
      :SetFont( "Arial" )
      :Create( xParent,, { nCol, nRow }, { nWidth, nHeight } )
   ENDWITH

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(lBorder)

   RETURN Nil

STATIC FUNCTION gui_LibName()

   RETURN "GTWVG"

STATIC FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(xParent)

   RETURN Nil

STATIC FUNCTION gui_Msgbox( cText )

   RETURN Alert( cText )

STATIC FUNCTION gui_MsgYesNo( cText )

   Alert( cText )

   RETURN .F.

STATIC FUNCTION gui_SpinnerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, nValue, aRangeList, oFrmClass )

   gui_TextCreate( xParent, @xControl, nRow, nCol, nWidth, nHeight, ;
            0, "999", Nil, Nil, Nil, Nil )

   (nValue);(aRangeList);(oFrmClass);(xDlg)

   RETURN Nil

STATIC FUNCTION gui_TabCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xParent)

   RETURN Nil

STATIC FUNCTION gui_TabEnd()

   RETURN Nil

STATIC FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg);(xTab);(aList)

   RETURN Nil

STATIC FUNCTION gui_TabPageBegin( xDlg, xParent, xTab, xPage, nPageCount, cText )

   (xDlg);(xTab);(cText);(xPage);(nPageCount);(xParent)

   RETURN Nil

STATIC FUNCTION gui_TabPageEnd( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_ControlGetValue( xDlg, xControl )

   (xDlg);(xControl)

   RETURN ""

STATIC FUNCTION gui_TextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, oFrmClass, lPassword )
   /*
   xControl := wvgStatic():New()
   WITH OBJECT xControl
      :Type := WVGSTATIC_TYPE_TEXT
      :Options := WVGSTATIC_TEXT_LEFT
      :SetColorFG( "W/B" )
      :SetColorBG( "W/B" )
      :Caption := xValue
      :SetFont( "Arial" )
      :Create(xDlg,,{nCol,nRow},{nWidth,nHeight})
   ENDWITH
   */
   xControl := wvgSle():New()
   WITH OBJECT xControl
      :BufferLength := nMaxLength
      :Create( xParent,, { nCol, nRow }, { nWidth, nHeight } )
      :SetData( Transform( xValue, "" ) )
   ENDWITH

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(cPicture);(nMaxLength)
   (bValid);(lPassword);(oFrmClass);(aItem);(cImage);(bAction)

   RETURN Nil

STATIC FUNCTION gui_SetFocus( xDlg, xControl )

   (xDlg);(xControl)

   RETURN Nil

STATIC FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   IF xControl:ClassName == "LABEL"
      xControl:SetCaption( AllTrim( Transform( xValue, "" ) ) )
   ELSE
      xControl:SetData( xValue )
   ENDIF

   (xDlg);(xControl);(xValue)

   RETURN Nil

STATIC FUNCTION gui_DlgSetKey(...)

   RETURN Nil
