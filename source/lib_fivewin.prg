/*
lib_fivewin- fivewin source selected by lib.prg
*/

#pragma -w1
#include "frm_class.ch"
#include "fivewin.ch"
#include "calendar.ch"
#include "dtpicker.ch"

THREAD STATIC MyWindowList := {}

FUNCTION gui_Init()

   //DEFINE FONT oFont NAME APP_FONTNAME SIZE 0, - APP_FONTSIZE_NORMAL
   SetGetColorFocus( RGB( 255,255,0 ) )
   fw_SetTruePixel( .T. )

   RETURN Nil

//FUNCTION GetAllWin()
//
//   RETURN MyWindowList

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   gui_DialogCreate( @xDlg, 0, 0,1024, 768, cTitle )
   IF xDlg:ClassName() == "TDIALOG"
      gui_DialogActivate( xDlg, { || gui_DlgMenu2( xDlg, aMenuList, aAllSetup, cTitle ) } )
   ELSE
      gui_DlgMenu2( xDlg, aMenuList, aAllSetup, cTitle )
      gui_DialogActivate( xDlg )
   ENDIF

   RETURN Nil

FUNCTION gui_DlgMenu2( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL oMenu, aGroupList, cDBF, dDate := Date(), oCalendar

   MENU oMenu OF xDlg
      FOR EACH aGroupList IN aMenuList
         MENUITEM "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
         MENU
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
            NEXT
         ENDMENU
      NEXT
      MENUITEM "Exit"
         MENU
         MENUITEM "Exit" ACTION gui_DialogClose( xDlg )
         ENDMENU
      ENDMENU
      xDlg:SetMenu( oMenu )

      @ 400, 400 CALENDAR oCalendar VAR dDate OF xDlg PIXEL SIZE 220, 157 /* WEEKNUMBER */ DAYSTATE

   (xDlg);(aMenuList);(aAllSetup);(cTitle);(oMenu);(oCalendar)

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF cCaption == "Cancel" .OR. cCaption == "Exit"
      @ nRow, nCol BUTTONBMP xControl PROMPT cCaption OF xParent ;
         SIZE nWidth, nHeight PIXEL RESOURCE cResName TOP ACTION Eval( bAction ) CANCEL
   ELSE
      @ nRow, nCol BUTTONBMP xControl PROMPT cCaption OF xParent ;
         SIZE nWidth, nHeight PIXEL RESOURCE cResName TOP ACTION Eval( bAction )
   ENDIF

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(cCaption);(cResName);(bAction)

   RETURN Nil

FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyDownList, Self )

   LOCAL aItem, oCol, aThisKey, nPos

   IF Len( aKeyDownList ) == 0
      @ nRow, nCol XBROWSE xControl ;
         SIZE nWidth, nHeight PIXEL ;
         DATASOURCE workarea ;
         OF xParent ;
         ON DBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
         //LINES CELL
   ELSEIF ( nPos := hb_AScan( aKeyDownList, { | e | e[1] == VK_RETURN } ) ) != 0
      @ nRow, nCol XBROWSE xControl ;
         SIZE nWidth, nHeight PIXEL ;
         DATASOURCE workarea ;
         OF xParent ;
         ON DBLCLICK BrowseKeyDown( VK_RETURN, aKeyDownList, workarea )
         //LINES CELL
   ENDIF

   FOR EACH aItem IN oTbrowse
      ADD oCol TO xControl ;
         DATA FieldBlock( aItem[2] ) ;
         HEADER aItem[1] ;
         PICTURE aItem[3]
   NEXT

   xControl:nMoveType := 0
   xControl:CreateFromCode()
   /* create buttons on browse for defined keys */
   IF Len( aKeyDownList ) != 0
      FOR EACH aThisKey IN aKeyDownList
         AAdd( ::aControlList, EmptyFrmClassItem() )
         Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_BUTTON_BRW
         gui_ButtonCreate( xDlg, xParent, @Atail( ::aControlList )[ CFG_FCONTROL ], ;
            nRow - APP_LINE_SPACING, 200 + aThisKey:__EnumIndex() * APP_LINE_HEIGHT, ;
            APP_LINE_HEIGHT - 2, APP_LINE_HEIGHT - 2, "", ;
            iif( aThisKey[1] == VK_INSERT, "ICOPLUS", ;
            iif( aThisKey[1] == VK_DELETE, "ICOTRASH", ;
            iif( aThiskey[1] == VK_RETURN, "ICOEDIT", Nil ) ) ), aThisKey[2] )
      NEXT
      xControl:bKeyDown := { | nKey | BrowseKeyDown( nKey, aKeyDownList ) }
   ENDIF

   (xDlg);(cField);(xValue);(workarea);(aKeyDownList);(xControl);(nRow);(nCol);(nWidth)
   (nHeight);(oTBrowse);(oCol)
   (xValue)

   RETURN Nil

FUNCTION BrowseKeyDown( nKey, aKeyDownList, workarea )

   LOCAL nPos, nSelect

   nPos := hb_AScan( aKeyDownList, { | e | e[ 1 ] == nKey } )
   IF nPos != 0
      nSelect := Select()
      SELECT ( Select( workarea ) )
      Eval( aKeyDownList[ nPos, 2 ] )
   ENDIF

   RETURN Nil

FUNCTION gui_DlgKeyDown( xControl, nKey, Self )

   (xControl);(nKey);(Self)

   RETURN Nil

FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   IF ! Empty( cField )
      xValue := (workarea)->( FieldGet( FieldNum( cField ) ) )
   ENDIF

   (xControl);(xDlg)

   RETURN Nil

FUNCTION gui_BrowseRefresh( xDlg, xControl )

   xControl:Refresh()

   (xDlg);(xControl)

   RETURN Nil

FUNCTION gui_CheckboxCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   LOCAL xValue := .F.

   @ nRow, nCol CHECKBOX xControl VAR xValue PROMPT "" PIXEL ;
      SIZE nWidth, nHeight OF xParent

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_ComboCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, aList, xValue )

   @ nRow, nCol COMBOBOX xControl VAR xValue OF xParent PIXEL ;
      SIZE nWidth, nHeight ;
      ITEMS aList ;
      //STYLE CBS_DROPDOWN
      //UPDATE
   //oCbx:oGet:bKeyChar = { | nKey | If( nKey == VK_RETURN,;
   //                                  ( cDia := oCbx:oGet:GetText(), Eval( oCbx:bChange() ) ),),;
   //                                    oCbx:GetKeyChar( nKey ) }

   (nHeight);(xDlg);(xControl);(nRow);(nCol);(nWidth);(aList)

   RETURN Nil

FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   LOCAL nMult := iif( xDlg:ClassName() == "TDIALOG", 1, 1 )

   @ nRow, nCol DTPICKER xControl VAR dValue ;
      OF xParent SIZE nWidth, nHeight PIXEL

   (nWidth);(nHeight);(xDlg);(xControl);(nRow);(nCol);(dValue)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode, lModal )

   hb_Default( @lModal, .T. )

   IF xDlg:ClassName() == "TDIALOG"
      IF lModal
         IF ! Empty( bCode )
            ACTIVATE DIALOG xDlg CENTERED ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )
         ELSE
            ACTIVATE DIALOG xDlg CENTERED ON INIT gui_StatusBar( xDlg, "" )
         ENDIF
      ELSE
         IF ! Empty( bCode )
            ACTIVATE DIALOG xDlg CENTERED NOMODAL ;
               ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )
         ELSE
            ACTIVATE DIALOG xDlg CENTERED NOMODAL ON INIT gui_StatusBar( xDlg, "" )
         ENDIF
      ENDIF
   ELSE
      IF ! Empty( bCode )
         ACTIVATE WINDOW xDlg CENTERED ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )
      ELSE
         ACTIVATE WINDOW xDlg CENTERED ON INIT gui_StatusBar( xDlg, "" )
      ENDIF
   ENDIF

   (bCode)

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   xDlg:End()

   (xDlg)

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal, xParent )

   hb_Default( @lModal, .F. )

   //IF lModal // only DIALOG is modal
      DEFINE DIALOG xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth ;
         PIXEL OF xParent TITLE cTitle + " (" + gui_LibName() + ")" ICON "ICOWINDOW"
   //ELSE
   //   DEFINE WINDOW xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth ;
   //      PIXEL TITLE cTitle + " (WINDOW)" ICON "ICOWINDOW"
   //ENDIF

   (xDlg);(nRow);(nCol);(nWidth);(nHeight);(cTitle);(bInit)

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   IF PCount() < 2
      RETURN xDlg:hWnd == GetFocus()
   ENDIF

   (xDlg);(xControl)

   RETURN xControl:hWnd == GetFocus()

FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   LOCAL nMult := iif( xDlg:ClassName() == "TDIALOG", 1, 1 )

   hb_Default( @lBorder, .F. )
   IF lBorder
      //@ nRow, nCol GET xControl VAR xValue OF xParent PIXEL ;
      //   SIZE nWidth, nHeight READONLY
      @ nRow, nCol SAY xControl VAR xValue OF xParent PIXEL ;
         SIZE nWidth, nHeight COLOR CLR_BLUE TRANSPARENT BORDER
   ELSE
      @ nRow, nCol SAY xControl VAR xValue OF xParent PIXEL ;
         SIZE nWidth, nHeight COLOR CLR_BLUE TRANSPARENT
   ENDIF

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(lBorder)

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "FIVEWIN"

FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   LOCAL nMult := iif( xDlg:ClassName() == "TDIALOG", 1, 1 )

   @ nRow, nCol GET xControl VAR xValue MEMO OF xParent PIXEL ;
      SIZE nWidth, nHeight

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue)

   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN MsgInfo( cText )

FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

FUNCTION gui_SetFocus( xDlg, xControl )

   IF PCount() < 2
      xDlg:SetFocus()
   ELSE
      xControl:SetFocus()
   ENDIF

   (xDlg);(xControl)

   RETURN Nil

FUNCTION gui_SpinnerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, nValue, aRangeList, Self )

   LOCAL nMult := iif( xDlg:ClassName() == "TDIALOG", 1, 1 )

   @ nRow, nCol GET xControl VAR nValue OF xParent ;
      SIZE nWidth, nHeight PIXEL ;
      PICTURE "999999" ; // cPicture ;
      SPINNER MIN aRangeList[1] MAX aRangeList[2]
      // VALID iif( Empty( bValid ), .T., Eval( bValid ) )
   //AAdd( ::aInitFix, { || xControl:nHeight := nHeight } )

   RETURN Nil

FUNCTION gui_Statusbar( xDlg, xControl )

   DEFINE STATUSBAR xControl PROMPT "DlgAuto/FiveLibs" OF xDlg ;
      SIZES 150, 200, 240

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   LOCAL nMult := iif( xDlg:ClassName() == "TDIALOG", 1, 1 )

   // on dialog need create with all tabpages
   IF xDlg:ClassName() == "TDIALOG"
      @ nRow, nCol FOLDEREX xControl PIXEL ;
         PAGES ".", ".", ".", ".", ".", ".", ".", ".", ".", "."  ;
         ; //BITMAPS "bmpfolder" ; // folderex
         OF xParent SIZE nWidth, nHeight
   ELSE
      @ nRow, nCol FOLDEREX xControl PIXEL ;
         PAGES "." ;
         ; //BITMAPS "bmpfolder" ; // folderex
         OF xParent SIZE nWidth, nHeight
   ENDIF

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_TabEnd( xDlg, xTab, nPageCount )

   LOCAL aItem

   IF xDlg:ClassName() == "TDIALOG"
      FOR EACH aItem IN xTab:aDialogs
         IF aItem:__EnumIndex > nPageCount
            aItem:Hide()
         ENDIF
      NEXT
      xDlg:Refresh()
   ENDIF

   (xTab);(nPageCount)
   RETURN Nil


FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   xTab:aDialogs[1]:SetFocus()

   (xDlg);(xTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xParent, xControl, xPage, nPageCount, cText )

   IF nPageCount <= Len( xControl:aDialogs )
      xControl:aPrompts[ nPageCount ] := cText
   ELSE
      xControl:AddItem( cText )
   ENDIF
   xPage := xControl:aDialogs[ nPageCount ]
   xControl:Refresh()

   (xDlg); (xControl); (cText); (xPage); (nPageCount)

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )

   /*
   END PAGE
   */

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, Self, lPassword )

   LOCAL nMult := iif( xDlg:ClassName() == "TDIALOG", 1, 1 )

// EDIT for dialog
   IF Empty( bAction )
      @ nRow, nCol GET xControl VAR xValue OF xParent PIXEL ;
         SIZE nWidth, nHeight PICTURE cPicture ;
         VALID iif( Empty( bValid ), .T., Eval( bValid ) )
   ELSE
      @ nRow, nCol GET xControl VAR xValue OF xParent PIXEL ;
         SIZE nWidth, nHeight PICTURE cPicture ;
         VALID iif( Empty( bValid ), .T., Eval( bValid ) ) ;
         ACTION Eval( bAction ) BITMAP cImage
   ENDIF

   (bValid);(xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(cPicture);(nMaxLength);(bAction);(cImage)

   RETURN Nil

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   (xDlg);(xControl);(lEnable)

   RETURN Nil

FUNCTION gui_ControlGetValue( xDlg, xControl )

   LOCAL xValue

   xValue := Eval( xControl:bSetGet )
   //DO CASE
   //CASE xControl:ClassName == "TSAY";       xValue := xControl:GetText()
   //CASE xControl:ClassName == "TCOMBOBOX" ; xValue := xControl:VarGet()
   //CASE xControl:ClassName == "TCHECKBOX";  xValue := xControl:lchecked()
   //CASE xControl:ClassName == "TGET";       xValue := xControl:Value()
   //CASE xControl:ClassName == "TMULTIGET";  xValue := xControl:GetText()
   //CASE xControl:ClassName == "TDATEPICK";  xValue := xControl:Value()
   //CASE xControl:ClassName == "TRADIO";     xValue := xControl:nOption()
   //OTHERWISE // GetText() ??
   //   gui_MsgBox( "SetValue for " + xControl:ClassName )
   //ENDCASE

   (xDlg);(xControl)

   RETURN xValue

FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   Eval( xControl:bSetGet, xValue )
   //DO CASE
   //CASE xControl:ClassName == "TSAY";       xControl:VarPut( xValue )
   //CASE xControl:ClassName == "TCOMBOBOX" ; (xValue) // xControl:VarPut( xValue )
   //CASE xControl:ClassName == "TCHECKBOX";  xControl:SetCheck( xValue )
   //CASE xControl:ClassName == "TGET";       xControl:cText( xValue )
   //CASE xControl:ClassName == "TMULTIGET";  xControl:cText( xValue )
   //CASE xControl:ClassName == "TDATEPICK";  xControl:cText( xValue )
   //CASE xControl:ClassName == "TRADIO";     xControl:SetOption( xValue )
   //OTHERWISE // cText(x) ??
   //   gui_MsgBox( "SetValue for " + xControl:ClassName )
   //ENDCASE
   xControl:Refresh()

   (xDlg)

   RETURN Nil

FUNCTION gui_DlgSetKey( Self )

   LOCAL aItem

   FOR EACH aItem IN ::aDlgKeyDown
   NEXT

   RETURN Nil

FUNCTION DoNothing(...)

   RETURN Nil


// Notes: lWRunning(), GetWndApp(), SetWndApp(), nWindows(), nDlgCount
