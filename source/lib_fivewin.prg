/*
lib_fivewin- fivewin source selected by lib.prg

Can't be used on current simulator.
Basic screen only
*/

#pragma -w1
#include "frm_class.ch"
#include "fivewin.ch"
#include "calendar.ch"

FUNCTION gui_Init()

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL oMenu, aGroupList, cDBF, dDate := Date(), oCalendar

   gui_DialogCreate( @xDlg, 0, 0,1024, 768, cTitle )

   MENU oMenu OF xDlg
      FOR EACH aGroupList IN aMenuList
         MENUITEM "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
         MENU
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
            NEXT
         ENDMENU
      NEXT
      MENUITEM "Sair"
         MENU
         MENUITEM "Sair" ACTION gui_DialogClose( xDlg )
         ENDMENU
      ENDMENU
      xDlg:SetMenu( oMenu )

      @ 400, 400 CALENDAR oCalendar VAR dDate OF xDlg PIXEL SIZE 220, 157 WEEKNUMBER DAYSTATE

   gui_DialogActivate( xDlg )

   (xDlg);(aMenuList);(aAllSetup);(cTitle);(oMenu);(oCalendar)

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   @ nRow, nCol BUTTONBMP xControl PROMPT cCaption OF xDlg SIZE nWidth, nHeight PIXEL RESOURCE cResName TOP ACTION Eval( bAction )
   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(cCaption);(cResName);(bAction)

   RETURN Nil

FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyDownList, Self )

   LOCAL aItem, oCol

   @ nRow, nCol XBROWSE xControl ;
      SIZE nWidth, nHeight PIXEL ;
      DATASOURCE workarea ;
      OF xParent
      //LINES CELL

   FOR EACH aItem IN oTbrowse
      ADD oCol TO xControl ;
         DATA FieldBlock( aItem[2] ) ;
         HEADER aItem[1] ;
         PICTURE aItem[3]
   NEXT

   xControl:nMoveType := 0
   xControl:CreateFromCode()

   (xDlg);(cField);(xValue);(workarea);(aKeyDownList);(xControl);(nRow);(nCol);(nWidth)
   (nHeight);(oTBrowse);(oCol)
   (xValue)

   RETURN Nil

/*
STATIC FUNCTION gui_DlgKeyDown( xDlg, xControl, nKey, workarea, cField, xValue, aDlgKeyDownList )
   RETURN Nil
   */

FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   IF ! Empty( cField )
      xValue := (workarea)->( FieldGet( FieldNum( cField ) ) )
   ENDIF
   (xControl);(xDlg)

   RETURN Nil

FUNCTION gui_BrowseRefresh( xDlg, xControl )

   (xDlg);(xControl)

   RETURN Nil

FUNCTION gui_CheckboxCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   LOCAL xValue := .F.

   @ nRow, nCol CHECKBOX xControl VAR xValue PROMPT "" PIXEL SIZE nWidth, nHeight OF xDlg

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_ComboCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, aList )

   LOCAL cAny

   @ nRow, nCol COMBOBOX xControl VAR cAny OF xDlg PIXEL SIZE nWidth, nHeight ;
      ITEMS aList ;
      STYLE CBS_DROPDOWN // ON CHANGE QueDia( cDia )

   //oCbx:oGet:bKeyChar = { | nKey | If( nKey == VK_RETURN,;
   //                                  ( cDia := oCbx:oGet:GetText(), Eval( oCbx:bChange() ) ),),;
   //                                    oCbx:GetKeyChar( nKey ) }

   (nHeight);(xDlg);(xControl);(nRow);(nCol);(nWidth);(aList)

   RETURN Nil

FUNCTION gui_DatePickerCreate( xDlg, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )
   gui_TextCreate( xDlg, @xControl, nRow, nCol, nWidth, nHeight, dValue )
   (nWidth);(nHeight);(xDlg);(xControl);(nRow);(nCol);(dValue)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode )

   IF ! Empty( bCode )
      EVAL( bCode )
   ENDIF
   ACTIVATE WINDOW xDlg CENTERED
   (bCode)

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   xDlg:End()
   (xDlg)

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, xOldDlg )

   DEFINE WINDOW xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth PIXEL TITLE cTitle ICON "ICOWINDOW"

   gui_StatusBar( xDlg, "" )
   (xDlg);(nRow);(nCol);(nWidth);(nHeight);(cTitle);(bInit);(xOldDlg)

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      (xDlg);(xControl)
      RETURN .F.

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   hb_Default( @lBorder, .F. )
   IF lBorder
      @ nRow, nCol SAY xControl VAR xValue OF xDlg PIXEL SIZE nWidth, nHeight COLOR CLR_BLUE TRANSPARENT BORDER
   ELSE
      @ nRow, nCol SAY xControl VAR xValue OF xDlg PIXEL SIZE nWidth, nHeight COLOR CLR_BLUE TRANSPARENT
   ENDIF

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(lBorder)

   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   xControl:SetText( xValue )
   (xDlg);(xControl);(xValue)

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "FIVEWIN"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   @ nRow, nCol GET xControl VAR xValue MEMO OF xDlg PIXEL SIZE nWidth, nHeight

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue)

   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN MsgInfo( cText )

FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

FUNCTION gui_SetFocus( xDlg, xControl )

   (xDlg);(xControl)

   RETURN Nil

FUNCTION gui_SpinnerCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, nValue, aRangeList )

   gui_TextCreate( xDlg, @xControl, nRow, nCol, nWidth, nHeight, ;
            0, "999", Nil, Nil, Nil, Nil )

   RETURN Nil

FUNCTION gui_Statusbar( xDlg, xControl )

   DEFINE STATUSBAR xControl PROMPT "DlgAuto/FiveLibs" OF xDlg ;
      SIZES 150, 200, 240
   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   @ nRow, nCol FOLDER xControl PIXEL ;
      PROMPT "Page 1" ;
      ;//BITMAPS "bmpfolder" ; // folderex
      OF xDlg SIZE nWidth, nHeight

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_TabEnd( xTab, nPageCount )

   (xTab);(nPageCount)

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   xTab:aDialogs[1]:SetFocus()
   (xDlg);(xTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, xPage, nPageCount, cText )

   IF nPageCount == 1
      xControl:aPrompts[ 1 ] := cText
   ELSE
      xControl:AddItem( cText )
   ENDIF
   xPage := Atail( xControl:aDialogs )

   (xDlg); (xControl); (cText); (xPage); (nPageCount)

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )
   /*
   END PAGE
   */
   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage  )

   IF Empty( bAction )
      @ nRow, nCol GET xControl VAR xValue OF xDlg PIXEL SIZE nWidth, nHeight PICTURE cPicture VALID iif( Empty( bValid ), .T., Eval( bValid ) )
   ELSE
      @ nRow, nCol GET xControl VAR xValue OF xDlg PIXEL SIZE nWidth, nHeight PICTURE cPicture VALID iif( Empty( bValid ), .T., Eval( bValid ) ) ;
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

FUNCTION gui_TextGetValue( xDlg, xControl )

   LOCAL xValue

   xValue := xControl:GetText()
   (xDlg);(xControl)

   RETURN xValue

FUNCTION gui_TextSetValue( xDlg, xControl, xValue )

   xControl:SetText( xValue )
   (xDlg);(xControl);(xValue)

   RETURN Nil
