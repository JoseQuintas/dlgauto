/*
lib_gtwvg - gtwvg source selected by lib.prg

Note: Only to show on screen
*/

#include "inkey.ch"
#include "frm_class.ch"

FUNCTION gui_Init()

   SetMode(30,100)
   CLS

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL oMainMenu, aGroupList, cDBF, oMenuGroup

   SetMode(30,100)
   CLS
   oMainMenu := wvgSetAppWindow():MenuBar()
   FOR EACH aGroupList IN aMenuList
      oMenuGroup := wvgMenu():New( oMainMenu,,.T. ):Create()
      FOR EACH cDBF IN aGroupList
         oMenuGroup:AddItem( cDBF, { || hb_ThreadStart( { | nGt | nGt := hb_gtSelect(), ;
            frm_Main( cDBF, aAllSetup ), ;
            hb_gtSelect( nGt ) } ) } )
      NEXT
      oMainMenu:AddItem( oMenuGroup, "Data" + Ltrim( Str( aGroupList:__EnumIndex ) ) )
   NEXT
   oMainMenu:AddItem( "Sair", { || __Quit() } )
   DO WHILE Inkey(1) != K_ESC
   ENDDO
   (xDlg);(cTitle)

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   xControl := wvgPushButton():New()
   WITH OBJECT xControl
      :PointerFocus := .F.
      :Style += BS_TOP
      :Create( xDlg,,{nCol,nRow},{nHeight,nWidth})
      :SetCaption( {, WVG_IMAGE_ICONRESOURCE, cResName } )
      :SetCaption( cCaption )
      :Activate := bAction
   ENDWITH
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight); (cCaption); (cResName); (bAction)

   RETURN Nil

FUNCTION gui_CheckboxCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   xControl := wvgCheckBox():New()
   WITH OBJECT xControl
      :PointerFocus := .F.
      :Caption := "."
      :Selection := .F.
      :Create( xDlg,,{nCol,nRow},{ nWidth, nHeight } )
      :setColorFG( "W+" )
      :setColorBG( "B*" )
   ENDWITH
   (nHeight)

   RETURN Nil

FUNCTION gui_ComboCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, aList )

   LOCAL cItem

   xControl := wvgCombobox():New()
   WITH OBJECT xControl
      :Type := WVGCOMBO_DROPDOWN
      FOR EACH cItem IN aList
         :AddItem( cItem )
      NEXT
      :Create( xDlg,,{nCol,nRow},{nWidth,nHeight}, , .T. )
      :SetColorFG("W+")
      :SetColorBG("B*")
      FOR EACH cItem IN aList
         :AddItem( cItem )
      NEXT

   ENDWITH

   RETURN Nil

FUNCTION gui_DatePickerCreate( xDlg, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   gui_TextCreate( xDlg, @xControl, nRow, nCol, nWidth, nHeight, dValue )

   RETURN Nil

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF
   (xDlg);(xControl);(lEnable)

   RETURN Nil

FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(OTbrowse);(cFIeld);(xValue);(workarea);(xParent)

   RETURN Nil

FUNCTION gui_BrowseRefresh( xDlg, xControl )
   (xDlg)
   (xControl)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode )

   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   (xDlg)

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   xDlg:Destroy()
   (xDlg)
   QUIT

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit )

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
   (xDlg);(nRow);(nCol);(nWidth);(nHeight);(cTitle);(bInit)

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   (xDlg);(xControl)

   RETURN .F.

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   xControl := wvgStatic():New()
   WITH OBJECT xControl
      :Type := WVGSTATIC_TYPE_TEXT
      :Options := WVGSTATIC_TEXT_LEFT
      :Style += iif( lBorder, WS_BORDER, 0 )
      :SetColorFG( "W/B" )
      :SetColorBG( "W/B" )
      :Caption := xValue
      :SetFont( "Arial" )
      :Create(xDlg,,{nCol,nRow},{nWidth,nHeight})
   ENDWITH
   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(lBorder)

   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   xControl:SetCaption( AllTrim( Transform( xValue, "" ) ) )
   (xDlg);(xControl);(xValue)

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "GTWVG"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue)

   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN Alert( cText )

FUNCTION gui_MsgYesNo( cText )

   Alert( cText )

   RETURN .F.

FUNCTION gui_SpinnerCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, nValue, aRangeList )

   gui_TextCreate( xDlg, @xControl, nRow, nCol, nWidth, nHeight, ;
            0, "999", Nil, Nil, Nil, Nil )
   (nValue);(aRangeList)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_TabEnd()

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   (xDlg);(xTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, xPage, nPageCount, cText )

   (xDlg);(xControl);(cText);(xPage);(nPageCount)

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TextGetValue( xDlg, xControl )

   (xDlg);(xControl)

   RETURN ""

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

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
      :Create( xDlg,,{nCol,nRow},{nWidth,nHeight})
      :SetData( Transform( xValue, "" ) )
   ENDWITH
   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(cPicture);(nMaxLength);(bValid)

   RETURN Nil

FUNCTION gui_SetFocus( xDlg, xControl )

   (xDlg);(xControl)

   RETURN Nil

FUNCTION gui_TextEnable( xDlg, xControl, lEnable )

   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF
   (xDlg);(xControl);(lEnable)

   RETURN Nil

FUNCTION gui_TextSetValue( xDlg, xControl, xValue )

   xControl:SetData( xValue )
   (xDlg);(xControl);(xValue)

   RETURN Nil
