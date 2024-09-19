/*
lib_fivewin- fivewin source selected by lib.prg
*/

#pragma -w1
#include "hbgtinfo.ch"
#include "hbclass.ch"
#include "frm_class.ch"
#include "fivewin.ch"
#include "calendar.ch"
#include "dtpicker.ch"

#ifdef DLGAUTO_AS_LIB
   STATIC pGenPrg := ""
#else
   MEMVAR pGenPrg, pGenName
#endif

#ifndef DLGAUTO_AS_LIB
THREAD STATIC oGUI

FUNCTION GUI( xValue )

   IF xValue != Nil
      oGUI := xValue
   ENDIF
   IF oGUI == Nil
      oGUI := FIVEWINClass():New()
   ENDIF

   RETURN oGUI
#endif

CREATE CLASS FIVEWINClass

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
   METHOD Statusbar(...)        INLINE gui_Statusbar(...)
   METHOD TextCreate(...)       INLINE gui_TextCreate(...)

   /* browse */
   METHOD Browse(...)           INLINE gui_Browse(...)
   METHOD BrowseRefresh(...)    INLINE gui_BrowseRefresh(...)
   METHOD browsekeydown(...)    INLINE gui_browsekeydown(...)

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

   //DEFINE FONT oFont NAME APP_FONTNAME SIZE 0, -APP_FONTSIZE_NORMAL
   SetGetColorFocus( COLOR_YELLOW )
   fw_SetTruePixel( .T. )

   pGenPrg += [   SetGetColorFocus( .T. )] + hb_Eol()
   //pGenPrg += [   fw_SetTruePixel( .T. )] + hb_Eol()
   pGenPrg += hb_Eol()

   RETURN Nil

STATIC FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   gui_DialogCreate( @xDlg, 0, 0, APP_DLG_WIDTH, APP_DLG_HEIGHT, cTitle )
   IF xDlg:ClassName() == "TDIALOG"
      gui_DialogActivate( xDlg, { || gui_DlgMenu2( xDlg, aMenuList, aAllSetup, cTitle ) }, .T. )
   ELSE
      gui_DlgMenu2( xDlg, aMenuList, aAllSetup, cTitle )
      gui_DialogActivate( xDlg,, .T. )
   ENDIF

   RETURN Nil

STATIC FUNCTION gui_DlgMenu2( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL oMenu, aGroupList, cDBF, dDate := Date(), oCalendar

   MENU oMenu OF xDlg
      FOR EACH aGroupList IN aMenuList
         MENUITEM "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
         MENU
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup,,xDlg )
            NEXT
         ENDMENU
      NEXT
      MENUITEM "NoData"
         MENU
         MENUITEM "NoData Layout 1" ACTION test_noDatabase(1)
         MENUITEM "NoData Layout 2" ACTION test_noDatabase(2)
         MENUITEM "NoData Layout 3" ACTION test_noDatabase(3)
         ENDMENU
      IF xDlg:ClassName() == "TMDIFRAME"
         oMenu:AddMDI()
      ENDIF
      MENUITEM "Exit"
         MENU
         MENUITEM "aWindowsInfo" ACTION gui_MsgBox( aWindowsInfo() ) ;
            MESSAGE "Show used controls"
         SEPARATOR
         MENUITEM "Exit" ACTION gui_DialogClose( xDlg )
         ENDMENU
      ENDMENU
      xDlg:SetMenu( oMenu )

      @ 400, 400 CALENDAR oCalendar VAR dDate OF xDlg PIXEL SIZE 220, 157 /* WEEKNUMBER */ DAYSTATE

   (xDlg);(aMenuList);(aAllSetup);(cTitle);(oMenu);(oCalendar)

   RETURN Nil

// ok to run, but pending proccess, and can't call modal dialog
FUNCTION ExecuteMT( bCode )

   LOCAL oFrm, oAny

   oFrm := Eval( bCode )
   WinRun( oFrm:xDlg )

   RETURN Nil

STATIC FUNCTION gui_ButtonCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF cCaption == "Cancel" .OR. cCaption == "Exit"
      @ nRow, nCol BUTTONBMP xControl PROMPT cCaption OF xParent ;
         SIZE nWidth, nHeight PIXEL RESOURCE cResName TOP ACTION Eval( bAction ) CANCEL

      pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
         [ BUTTONBMP xControl PROMPT ] + hb_ValToExp( cCaption ) + ;
         [ OF xParent ;] + hb_Eol()
      pGenPrg += [      SIZE ] + hb_ValToExp( nWidth ) + [, ] + hb_ValToExp( nHeight ) + ;
      [ PIXEL RESOURCE ] + hb_ValToExp( cResName ) + [ TOP ACTION Eval( ] + ;
      hb_ValToExp( bAction ) + [ CANCEL] + hb_Eol()
      pGenPrg += hb_Eol()

   ELSE
      @ nRow, nCol BUTTONBMP xControl PROMPT cCaption OF xParent ;
         SIZE nWidth, nHeight PIXEL RESOURCE cResName TOP ACTION Eval( bAction )

      pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
         [ BUTTONBMP xControl PROMPT ] + hb_ValToExp( cCaption ) + ;
         [ OF xParent ;] + hb_Eol()
      pGenPrg += [      SIZE ] + hb_ValToExp( nWidth ) + [, ] + hb_ValToExp( nHeight ) + ;
      [ PIXEL RESOURCE ] + hb_ValToExp( cResName ) + [ TOP ACTION Eval( ] + ;
      hb_ValToExp( bAction ) + hb_Eol()
      pGenPrg += hb_Eol()

   ENDIF

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(cCaption);(cResName);(bAction)

   RETURN Nil

STATIC FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyDownList, oFrmClass )

   LOCAL aItem, oCol, aThisKey, nPos
#ifdef DLGAUTO_AS_LIB
   LOCAL cnSQL := ADOLocal(), aDummy, aCol

   cnSQL:Execute( "SELECT * FROM " + workarea + " ORDER BY " + oTbrowse[ 1, 1 ] )
   aDummy := Array( cnSQL:RecordCount(), Len( oTBrowse ) )
   FOR EACH aCol IN aDummy
      Afill( aCol, "" )
   NEXT
   // workarea := cnSQL
#endif

   IF oFrmClass:lIsSQL
#ifdef DLGAUTO_AS_LIB
      IF Len( aKeyDownList ) == 0
         @ nRow, nCol XBROWSE xControl ;
            SIZE nWidth, nHeight PIXEL ;
            ; // LINES AUTOCOL, AUTOSORT ;
            ARRAY aDummy ;
            OF xParent ;
            ON DBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
            //LINES CELL
      ELSEIF ( nPos := hb_AScan( aKeyDownList, { | e | e[1] == VK_RETURN } ) ) != 0
         @ nRow, nCol XBROWSE xControl ;
            ; // LINES AUTOCOL, AUTOSORT ;
            SIZE nWidth, nHeight PIXEL ;
            ARRAY aDummy ;
            OF xParent ;
            ON DBLCLICK GUI():BrowseKeyDown( VK_RETURN, aKeyDownList, workarea )
            //LINES CELL
      ENDIF
      //xBrowse:aArray := aDummy
      ADD oCol TO xControl ;
         DATA { || xControl:nArrayAt } ;
         HEADER "nAT" ;
         PICTURE "999999"
      FOR EACH aItem IN oTbrowse
         ADD oCol TO xControl ;
            DATA { || cnSQL:Value( aItem[2] ) } ;
            HEADER aItem[1] ;
            // PICTURE aItem[3]
      NEXT
      xControl:bOnSkip := { | x | (x), cnSQL:Move( xControl:nArrayAt - 1, 1 ) }
      xControl:SetArray( aDummy )

#endif
   ELSE
      IF Len( aKeyDownList ) == 0
         @ nRow, nCol XBROWSE xControl ;
            SIZE nWidth, nHeight PIXEL ;
            OBJECT cnSQL ;
            OF xParent ;
            ON DBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
            //LINES CELL
      ELSEIF ( nPos := hb_AScan( aKeyDownList, { | e | e[1] == VK_RETURN } ) ) != 0
         @ nRow, nCol XBROWSE xControl ;
            SIZE nWidth, nHeight PIXEL ;
            OBJECT cnSQL ;
            OF xParent ;
            ON DBLCLICK GUI():BrowseKeyDown( VK_RETURN, aKeyDownList, workarea )
            //LINES CELL
      ENDIF
      FOR EACH aItem IN oTbrowse
         ADD oCol TO xControl ;
            DATA { || (workarea)->(FieldGet(FieldNum( aItem[2] ) ) ) } ;
            HEADER aItem[1] ;
            PICTURE aItem[3]
      NEXT
   ENDIF

   //xControl:nMoveType := 0
   xControl:CreateFromCode()
   /* create buttons on browse for defined keys */
   IF Len( aKeyDownList ) != 0
      FOR EACH aThisKey IN aKeyDownList
         AAdd( oFrmClass:aControlList, EmptyFrmClassItem() )
         Atail( oFrmClass:aControlList )[ CFG_CTLTYPE ] := TYPE_BUTTON_BRW
         gui_ButtonCreate( xDlg, xParent, @Atail( oFrmClass:aControlList )[ CFG_FCONTROL ], ;
            nRow - APP_LINE_SPACING, 200 + aThisKey:__EnumIndex() * APP_LINE_HEIGHT, ;
            APP_LINE_HEIGHT - 2, APP_LINE_HEIGHT - 2, "", ;
            iif( aThisKey[1] == VK_INSERT, "ICOPLUS", ;
            iif( aThisKey[1] == VK_DELETE, "ICOTRASH", ;
            iif( aThiskey[1] == VK_RETURN, "ICOEDIT", Nil ) ) ), aThisKey[2] )
      NEXT
      xControl:bKeyDown := { | nKey | GUI():BrowseKeyDown( nKey, aKeyDownList ) }
   ENDIF

   (xDlg);(cField);(xValue);(workarea);(aKeyDownList);(xControl);(nRow);(nCol);(nWidth)
   (nHeight);(oTBrowse);(oCol)
   (xValue)

   RETURN Nil

#ifdef DLGAUTO_AS_LIB
FUNCTION ADOSkipper( cnSQL, nSkip, nOld )

   nOld := cnSQL:AbsolutePosition()

   IF ! cnSQL:Eof()
      cnSQL:Move( nSkip )
      IF cnSQL:Eof()
         cnSQL:MoveLast()
      ENDIF
      IF cnSQL:Bof()
         cnSQL:MoveFirst()
      ENDIF
   ENDIF

   ( nOld )

   RETURN cnSQL:AbsolutePosition() - nOld
#endif


STATIC FUNCTION gui_BrowseKeyDown( nKey, aKeyDownList, workarea )

   LOCAL nPos, nSelect

   nPos := hb_AScan( aKeyDownList, { | e | e[ 1 ] == nKey } )
   IF nPos != 0
      nSelect := Select()
      SELECT ( Select( workarea ) )
      Eval( aKeyDownList[ nPos, 2 ] )
   ENDIF

   RETURN Nil

STATIC FUNCTION gui_DlgKeyDown( xControl, nKey, oFrmClass )

   (xControl);(nKey);(oFrmClass)

   RETURN Nil

STATIC FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   IF ! Empty( cField )
      xValue := (workarea)->( FieldGet( FieldNum( cField ) ) )
   ENDIF

   (xControl);(xDlg)

   RETURN Nil

STATIC FUNCTION gui_BrowseRefresh( xDlg, xControl )

   xControl:Refresh()

   (xDlg);(xControl)

   RETURN Nil

STATIC FUNCTION gui_CheckboxCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   LOCAL xValue := .F.

   @ nRow, nCol CHECKBOX xControl VAR xValue PROMPT "" PIXEL ;
      SIZE nWidth, nHeight OF xParent

   pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
      [ CHECKBOX xControl VAR xValue PROMPT "" PIXEL ;] + hb_Eol()
   pGenPrg += [      SIZE ] + hb_ValToExp( nWidth ) + [, ] + hb_ValToExp( nHeight ) + ;
      [ OF xParent] + hb_Eol()
   pGenPrg += hb_Eol()

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

STATIC FUNCTION gui_ComboCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, aList, xValue )

   @ nRow, nCol COMBOBOX xControl VAR xValue OF xParent PIXEL ;
      SIZE nWidth, nHeight ;
      ITEMS aList

   pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
      [ COMBOBOX xControl VAR xValue OF xParent PIXEL ;] + hb_Eol()
   pGenPrg += [      SIZE ] + hb_ValToExp( nWidth ) + [, ] + hb_ValToExp( nHeight ) + [ ;] + hb_Eol()
   pGenPrg += [      ITEMS ] + hb_ValToExp( aList ) + hb_Eol()
   pGenPrg += hb_Eol()

   //STYLE CBS_DROPDOWN
   //UPDATE
   //oCbx:oGet:bKeyChar = { | nKey | If( nKey == VK_RETURN,;
   //                                  ( cDia := oCbx:oGet:GetText(), Eval( oCbx:bChange() ) ),),;
   //                                    oCbx:GetKeyChar( nKey ) }

   (nHeight);(xDlg);(xControl);(nRow);(nCol);(nWidth);(aList)

   RETURN Nil

STATIC FUNCTION gui_DatePickerCreate( xDlg, xParent, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   @ nRow, nCol DTPICKER xControl VAR dValue ;
      OF xParent SIZE nWidth, nHeight PIXEL

   (nWidth);(nHeight);(xDlg);(xControl);(nRow);(nCol);(dValue)

   RETURN Nil

STATIC FUNCTION gui_DialogActivate( xDlg, bCode, lModal )

   hb_Default( @lModal, .F. )

   IF xDlg:ClassName() == "TDIALOG"
      IF lModal
         IF ! Empty( bCode )
            ACTIVATE DIALOG xDlg CENTERED ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )

            pGenPrg += [   ACTIVATE DIALOG xDlg CENTERED ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )] + hb_Eol()
            pGenPrg += hb_Eol()

         ELSE
            ACTIVATE DIALOG xDlg CENTERED ON INIT gui_StatusBar( xDlg, "" )

            pGenPrg += [   ACTIVATE DIALOG xDlg CENTERED ON INIT gui_StatusBar( xDlg, "" ) ] + hb_Eol()
            pGenPrg += hb_Eol()

         ENDIF
      ELSE
         IF ! Empty( bCode )
            ACTIVATE DIALOG xDlg CENTERED NOMODAL ;
               ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )

            pGenPrg += [   ACTIVATE DIALOG xDlg CENTERED NOMODAL ;] + hb_Eol()
            pGenPrg += [      ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )] + hb_Eol()
            pGenPrg += hb_Eol()

         ELSE
            ACTIVATE DIALOG xDlg CENTERED NOMODAL ON INIT gui_StatusBar( xDlg, "" )

            pGenPrg += [   ACTIVATE DIALOG xDlg CENTERED NOMODAL ON INIT gui_StatusBar( xDlg, "" )] + hb_Eol()
            pGenPrg += hb_Eol()

         ENDIF
      ENDIF
   ELSE
      IF ! Empty( bCode )
         ACTIVATE WINDOW xDlg CENTERED ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )

         pGenPrg += [   ACTIVATE WINDOW xDlg CENTERED ON INIT DoNothing( Eval( bCode ), gui_StatusBar( xDlg, "" ) )] + hb_Eol()
         pGenPrg += hb_Eol()

      ELSE
         ACTIVATE WINDOW xDlg CENTERED ON INIT gui_StatusBar( xDlg, "" )

         pGenPrg += [   ACTIVATE WINDOW xDlg CENTERED ON INIT gui_StatusBar( xDlg, "" )] + hb_Eol()
         pGenPrg += hb_Eol()

      ENDIF
      // VALID MsgYesNo( "Exit?" )
   ENDIF

   (bCode)

   RETURN Nil

STATIC FUNCTION gui_DialogClose( xDlg )

   xDlg:End()

   (xDlg)

   RETURN Nil

STATIC FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal, xParent )

   LOCAL nType := 1

   hb_Default( @lModal, .F. )

   //DO CASE
   //CASE cTitle == "MENU"
   //   DEFINE WINDOW xDlg MDI FROM nRow, nCol TO nRow + nHeight, nCol + nWidth ;
   //      PIXEL TITLE cTitle + " (" + GUI():LibName() + ")" ICON "ICOWINDOW" ;
   //      COLOR "W/B"
   //   SET MESSAGE OF xDlg TO "This is a message" NOINSET CLOCK DATE KEYBOARD
   //CASE lModal
      DEFINE DIALOG xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth ;
         PIXEL OF xParent /* FONT oFont */ TITLE cTitle + " (" + GUI():LibName() + ")" ICON "ICOWINDOW" ;
         COLOR COLOR_LIGHTGRAY

      pGenPrg += [   DEFINE DIALOG xDlg FROM ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
         [ TO ] + hb_ValToExp( nRow + nHeight ) + [, ] + hb_ValToExp( nCol + nWidth ) +  [ ;] + hb_Eol()
      pGenPrg += [      PIXEL OF xParent /* FONT oFont */ TITLE ] + hb_ValToExp( cTitle + " (" + GUI():LibName() ) + ;
         [ ")" ICON "ICOWINDOW" ;] + hb_Eol()
      pGenPrg += [      COLOR COLOR_LIGHTGRAY] + hb_Eol()
      pGenPrg += hb_Eol()

   //CASE nType == nType
   //   DEFINE WINDOW xDlg MDICHILD OF xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth ;
   //      PIXEL TITLE cTitle + " (" + GUI():LibName() + ")" ICON "ICOWINDOW" ;
   //      VSCROLL HSCROLL COLOR COLOR_LIGHTGRAY
   //CASE nType == 2
   //   DEFINE WINDOW xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth ;
   //      PIXEL TITLE cTitle + " (" + GUI():LibName() + ")" ICON "ICOWINDOW" ;
   //      COLOR LIGHT_GRAY
   //ENDCASE

   (xDlg);(nRow);(nCol);(nWidth);(nHeight);(cTitle);(bInit)

   RETURN Nil

STATIC FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   IF PCount() < 2
      RETURN xDlg:hWnd == GetFocus()
   ENDIF

   (xDlg);(xControl)

   RETURN xControl:hWnd == GetFocus()

STATIC FUNCTION gui_LabelCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   hb_Default( @lBorder, .F. )
   IF lBorder
      @ nRow, nCol SAY xControl VAR xValue OF xParent PIXEL ;
         SIZE nWidth, nHeight COLOR CLR_BLUE TRANSPARENT BORDER

      pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
         [ SAY xControl VAR xValue OF xParent PIXEL ;] + hb_Eol()
      pGenPrg += [      SIZE ] + hb_ValToExp( nWidth) + [, ] + hb_ValToExp( nHeight ) + ;
         [ COLOR CLR_BLUE TRANSPARENT BORDER] + hb_Eol()
      pGenPrg += hb_Eol()

   ELSE
      @ nRow, nCol SAY xControl VAR xValue OF xParent PIXEL ;
         SIZE nWidth, nHeight COLOR CLR_BLUE TRANSPARENT

      pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
         [ SAY xControl VAR xValue OF xParent PIXEL ;] + hb_Eol()
      pGenPrg += [      SIZE ] + hb_ValToExp( nWidth) + [, ] + hb_ValToExp( nHeight ) + ;
         [ COLOR CLR_BLUE TRANSPARENT] + hb_Eol()
      pGenPrg += hb_Eol()

   ENDIF

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(lBorder)

   RETURN Nil

STATIC FUNCTION gui_LibName()

   RETURN "FIVEWIN"

STATIC FUNCTION gui_MLTextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, xValue )

   @ nRow, nCol GET xControl VAR xValue MEMO OF xParent PIXEL ;
      SIZE nWidth, nHeight

   pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
      [ GET xControl VAR xValue MEMO OF xParent PIXEL ;] + hb_Eol()
   pGenPrg += [      SIZE ] + hb_ValToExp( nWidth ) + [, ] + hb_ValToExp( nHeight ) + hb_Eol()
   pGenPrg += hb_Eol()

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue)

   RETURN Nil

STATIC FUNCTION gui_Msgbox( cText )

   RETURN MsgInfo( cText )

STATIC FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

STATIC FUNCTION gui_SetFocus( xDlg, xControl )

   IF PCount() < 2
      xDlg:SetFocus()
   ELSE
      xControl:SetFocus()
   ENDIF

   (xDlg);(xControl)

   RETURN Nil

STATIC FUNCTION gui_SpinnerCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, nValue, aRangeList, oFrmClass )

   @ nRow, nCol GET xControl VAR nValue OF xParent ;
      SIZE nWidth, nHeight PIXEL ;
      PICTURE "999999" ; // cPicture ;
      SPINNER MIN aRangeList[1] MAX aRangeList[2]
      // VALID iif( Empty( bValid ), .T., Eval( bValid ) )

   RETURN Nil

STATIC FUNCTION gui_Statusbar( xDlg, xControl )

   DEFINE STATUSBAR xControl PROMPT "DlgAuto/FiveLibs" OF xDlg ;
      SIZES 150, 200, 240

   pGenPrg += [   DEFINE STATUSBAR xControl PROMPT "DlgAuto/FiveLibs" OF xDlg ;] + hb_Eol()
   pGenPrg += [      SIZES 150, 200, 240] + hb_Eol()
   pGenPrg += hb_Eol()

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_TabCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight )

   // dialog/window hell - need create with all pages
   // tab/folder/folderex hell

   @ nRow, nCol FOLDEREX xControl PIXEL ;
      PROMPTS "Page 1", "Page 2", "Page 3", "Page 4", "Page 5" ;
      ; //BITMAPS "bmpfolder" ; // folderex
      OF xParent SIZE nWidth, nHeight ;
      COLOR { COLOR_LIGHTGRAY, COLOR_LIGHTGRAY }
   //oFld:SetColor( ::nTextColorR, ::nBackColorR )

   pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
      [ FOLDEREX xControl PIXEL ;] + hb_Eol()
   pGenPrg += [      PROMPTS "Page 1", "Page 2", "Page 3", "Page 4", "Page 5" ;] + hb_Eol()
   pGenPrg += [      OF xParent SIZE ] + hb_ValToExp( nWidth ) + [, ] + hb_ValToExp( nHeight ) + [ ;] + hb_Eol()
   pGenPrg += [      COLOR { COLOR_LIGHTGRAY, COLOR_LIGHTGRAY }] + hb_Eol()
   pGenPrg += hb_Eol()

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

STATIC FUNCTION gui_TabEnd( xDlg, xTab, nPageCount )

   LOCAL xPage

   // dialog/window hell - works for dialog
   IF xDlg:ClassName() == "TDIALOG"
      ASize( xTab:aPrompts, nPageCount )
   ENDIF

   pGenPrg += [   ASize( xTab:aPrompts, ] + hb_ValToExp( nPageCount ) + [ )] + hb_Eol()
   pGenPrg += hb_Eol()

   (xDlg);(xTab);(nPageCount)

   RETURN Nil

STATIC FUNCTION gui_TabNavigate( xDlg, xTab, aList )

   xTab:aDialogs[1]:SetFocus()

   (xDlg);(xTab);(aList)

   RETURN Nil

STATIC FUNCTION gui_TabPageBegin( xDlg, xParent, xControl, xPage, nPageCount, cText )

   // dialog/window hell
   IF nPageCount <= Len( xControl:aPrompts )
      xControl:aPrompts[ nPageCount ] := cText

      pGenPrg += [   xControl:aPrompts] + "[" + hb_ValToExp( nPageCount ) + "]" + [ := ] + hb_ValToExp( cText ) + hb_Eol()

   ELSE
      xControl:AddItem( cText )

      pGenPrg += [   xControl:AddItem( ] + hb_ValToExp( cText ) + [ )] + hb_Eol()
      pGenPrg += hb_Eol()

   ENDIF
   xPage := xControl:aDialogs[ nPageCount ]
   xControl:Refresh()

   pGenPrg += [   xPage := xControl:aDialogs] + "[ " + hb_ValToExp( nPageCount ) + " ]" + hb_Eol()
   pGenPrg += [   xControl:Refresh()] + hb_Eol()
   pGenPrg += hb_Eol()


   (xDlg); (xControl); (cText); (xPage); (nPageCount)

   RETURN Nil

STATIC FUNCTION gui_TabPageEnd( xDlg, xControl )

   (xDlg); (xControl)

   RETURN Nil

STATIC FUNCTION gui_TextCreate( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, oFrmClass, lPassword )

// EDIT for dialog
   IF Empty( bAction )
      @ nRow, nCol GET xControl VAR xValue OF xParent PIXEL ;
         SIZE nWidth, nHeight PICTURE cPicture ;
         VALID iif( Empty( bValid ), .T., Eval( bValid ) )

      pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
         [ GET xControl VAR xValue OF xParent PIXEL ;] + hb_Eol()
      pGenPrg += [      SIZE ] + hb_ValToExp( nWidth ) + [ , ] + hb_ValToExp( nHeight ) + ;
         [ PICTURE ] + hb_ValToExp( cPicture ) + [ ;] + hb_Eol()
      pGenPrg += [      VALID ] + iif( Empty( bValid ), [ .T.], [ Eval( bValid ) ] ) + hb_Eol()
      pGenPrg += hb_Eol()

   ELSE
      @ nRow, nCol GET xControl VAR xValue OF xParent PIXEL ;
         SIZE nWidth, nHeight PICTURE cPicture ;
         VALID iif( Empty( bValid ), .T., Eval( bValid ) ) ;
         ACTION Eval( bAction ) BITMAP cImage

      pGenPrg += [   @ ] + hb_ValToExp( nRow ) + [, ] + hb_ValToExp( nCol ) + ;
         [ GET xControl VAR xValue OF xParent PIXEL ;] + hb_Eol()
      pGenPrg += [      SIZE ] + hb_ValToExp( nWidth ) + [, ] + hb_ValToExp( nHeight ) + ;
         [ PICTURE ] + hb_ValToExp( cPicture ) + [ ;] + hb_Eol()
      pGenPrg += [      VALID ] + iif( Empty( bValid ), [ .T.], [ Eval( bValid ) ] ) + [ ;] + hb_Eol()
      pGenPrg += [      ACTION Eval( bAction ) BITMAP ] + hb_ValToExp( cImage ) + hb_Eol()
      pGenPrg += hb_Eol()

   ENDIF

   (bValid);(xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(cPicture);(nMaxLength);(bAction);(cImage)

   RETURN Nil

STATIC FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   IF lEnable
      xControl:Enable()
   ELSE
      xControl:Disable()
   ENDIF

   (xDlg);(xControl);(lEnable)

   RETURN Nil

STATIC FUNCTION gui_ControlGetValue( xDlg, xControl )

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

STATIC FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

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

STATIC FUNCTION gui_DlgSetKey( oFrmClass )

   LOCAL aItem

   FOR EACH aItem IN oFrmClass:aDlgKeyDown
   NEXT

   RETURN Nil

STATIC FUNCTION DoNothing(...)

   RETURN Nil

FUNCTION aWindowsInfo()

   LOCAL cInfo := "", nCont, oDlg
   LOCAL aHide := { ;
      "TBTNBMP", ;
      "TBUTTONBMP", ;
      "TCALENDAR", ;
      "TCHECKBOX", ;
      "TCOMBOBOX", ;
      "TDATEPICK", ;
      "TFOLDEREX", ;
      "TGET", ;
      "TMULTIGET", ;
      "TSAY", ;
      "TSTATUSBAR", ;
      "TXBROWSE" }

   FOR nCont = 1 TO nWindows()
      IF ValType( GetAllWin()[ nCont ] ) != "N"
         oDlg = GetAllWin()[ nCont ]
         IF hb_AScan( aHide, { | e | e == oDlg:ClassName() } ) == 0
            cInfo += Str( nCont ) + "--> " + ;
                     oDlg:ClassName() + " *** " + ;
                     If( oDlg:Cargo != nil, oDlg:Cargo, "" ) + " ### " + ;
                     If( oDlg:oWnd != nil, oDlg:oWnd:ClassName, "" ) + ;
                     hb_Eol()
         ENDIF
      ENDIF
   NEXT

   RETURN cInfo

// Notes: lWRunning(), GetWndApp(), SetWndApp(), nWindows(), nDlgCount
