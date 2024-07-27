/*
lib_fivewin- fivewin source selected by lib.prg

Can't be used on current simulator.
Basic screen only
*/

#pragma -w1
#include "frm_class.ch"
#include "fivewin.ch"
#include "calendar.ch"
#include "dtpicker.ch"

#define ISDIALOG .T.

//STATIC oFont

FUNCTION gui_Init()

   //DEFINE FONT oFont NAME APP_FONTNAME SIZE 0, - APP_FONTSIZE_NORMAL
   SetGetColorFocus( RGB( 255,255,0 ) )

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   gui_DialogCreate( @xDlg, 0, 0,1024, 768, cTitle )
   IF ISDIALOG
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

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF cCaption == "Cancel" .OR. cCaption == "Exit"
      @ ToDialog( nRow ), ToDialog( nCol ) BUTTONBMP xControl PROMPT cCaption OF xDlg SIZE ToDialog( nWidth ), ToDialog( nHeight ) PIXEL RESOURCE cResName TOP ACTION Eval( bAction ) CANCEL
   ELSE
      @ ToDialog( nRow ), ToDialog( nCol ) BUTTONBMP xControl PROMPT cCaption OF xDlg SIZE ToDialog( nWidth ), ToDialog( nHeight ) PIXEL RESOURCE cResName TOP ACTION Eval( bAction )
   ENDIF

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(cCaption);(cResName);(bAction)

   RETURN Nil

FUNCTION gui_Browse( xDlg, xParent, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyDownList, Self )

   LOCAL aItem, oCol

   @ ToDialog( nRow ), ToDialog( nCol ) XBROWSE xControl ;
      SIZE ToDialog( nWidth ), ToDialog( nHeight ) PIXEL ;
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

FUNCTION gui_DlgKeyDown( xControl, nKey, Self )

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

FUNCTION gui_CheckboxCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   LOCAL xValue := .F.

   @ ToDialog( nRow ), ToDialog( nCol ) CHECKBOX xControl VAR xValue PROMPT "" PIXEL SIZE ToDialog( nWidth ), ToDialog( nHeight ) OF xDlg

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_ComboCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, aList )

   LOCAL cAny

   @ ToDialog( nRow ), ToDialog( nCol  )COMBOBOX xControl VAR cAny OF xDlg PIXEL SIZE ToDialog( nWidth ), ToDialog( nHeight ) ;
      ITEMS aList ;
      STYLE CBS_DROPDOWN // ON CHANGE QueDia( cDia )

   //oCbx:oGet:bKeyChar = { | nKey | If( nKey == VK_RETURN,;
   //                                  ( cDia := oCbx:oGet:GetText(), Eval( oCbx:bChange() ) ),),;
   //                                    oCbx:GetKeyChar( nKey ) }

   (nHeight);(xDlg);(xControl);(nRow);(nCol);(nWidth);(aList)

   RETURN Nil

FUNCTION gui_DatePickerCreate( xDlg, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )

   @ ToDialog( nRow ), ToDialog( nCol ) DTPICKER xControl VAR dValue ;
      OF xDlg SIZE ToDialog( nWidth ), ToDialog( nHeight ) PIXEL

   (nWidth);(nHeight);(xDlg);(xControl);(nRow);(nCol);(dValue)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode, lModal )

   hb_Default( @lModal, .T. )

   IF ISDIALOG
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

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, lModal )

   // truepixel causes irregular metric
   hb_Default( @lModal, .F. )
   IF ISDIALOG
      DEFINE DIALOG xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth ;
         PIXEL /* TRUEPIXEL */ TITLE cTitle ICON "ICOWINDOW" ;
         // FONT oFont
   ELSE
      DEFINE WINDOW xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth ;
         PIXEL /* TRUEPIXEL */ TITLE cTitle ICON "ICOWINDOW" ;
         // FONT oFont
   ENDIF

   (xDlg);(nRow);(nCol);(nWidth);(nHeight);(cTitle);(bInit)

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      (xDlg);(xControl)

      RETURN .T.

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   hb_Default( @lBorder, .F. )
   IF lBorder
      @ ToDialog( nRow ), ToDialog( nCol ) GET xControl VAR xValue OF xDlg PIXEL SIZE ToDialog( nWidth ), ToDialog( nHeight ) READONLY
      //@ ToDialog( nRow ), ToDialog( nCol ) SAY xControl VAR xValue OF xDlg PIXEL SIZE ToDialog( nWidth ), ToDialog( nHeight ) COLOR CLR_BLUE TRANSPARENT BORDER
   ELSE
      @ ToDialog( nRow ), ToDialog( nCol ) SAY xControl VAR xValue OF xDlg PIXEL SIZE ToDialog( nWidth ), ToDialog( nHeight ) COLOR CLR_BLUE TRANSPARENT
   ENDIF

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(lBorder)

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "FIVEWIN"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   @ ToDialog( nRow ), ToDialog( nCol ) GET xControl VAR xValue MEMO OF xDlg PIXEL SIZE ToDialog( nWidth ), ToDialog( nHeight )

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

FUNCTION gui_SpinnerCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, nValue, aRangeList )

   @ ToDialog( nRow ), ToDialog( nCol ) GET xControl VAR nValue OF xDlg ;
      SIZE ToDialog( nWidth ), ToDialog( nHeight ) PIXEL ;
      PICTURE "999999" ; // cPicture ;
      SPINNER MIN aRangeList[1] MAX aRangeList[2]
      // VALID iif( Empty( bValid ), .T., Eval( bValid ) )

   RETURN Nil

FUNCTION gui_Statusbar( xDlg, xControl )

   DEFINE STATUSBAR xControl PROMPT "DlgAuto/FiveLibs" OF xDlg ;
      SIZES 150, 200, 240

   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   // on dialog need create with all tabpages

   @ ToDialog( nRow ), ToDialog( nCol ) FOLDER xControl PIXEL ;
      PROMPT ".", ".", ".", ".", ".", ".", ".", ".", ".", "."  ;
      ; //BITMAPS "bmpfolder" ; // folderex
      OF xDlg SIZE ToDialog( nWidth ), ToDialog( nHeight )

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_TabEnd( xDlg, xTab, nPageCount )

   LOCAL aItem

   IF ! ISDIALOG
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

FUNCTION gui_TabPageBegin( xDlg, xControl, xPage, nPageCount, cText )

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

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid, bAction, cImage, ;
            aItem, Self, lPassword )

// EDIT for dialog
   IF Empty( bAction )
      @ ToDialog( nRow ), ToDialog( nCol ) GET xControl VAR xValue OF xDlg PIXEL ;
         SIZE ToDialog( nWidth ), ToDialog( nHeight ) PICTURE cPicture ;
         VALID iif( Empty( bValid ), .T., Eval( bValid ) )
   ELSE
      @ ToDialog( nRow ), ToDialog( nCol ) GET xControl VAR xValue OF xDlg PIXEL ;
         SIZE ToDialog( nWidth ), ToDialog( nHeight ) PICTURE cPicture ;
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

   DO CASE
   CASE xControl:ClassName == "TSAY";       xValue := xControl:GetText()
   CASE xControl:ClassName == "TCOMBOBOX" ; xValue := xControl:VarGet()
   CASE xControl:ClassName == "TCHECKBOX";  xValue := xControl:lchecked()
   CASE xControl:ClassName == "TGET";       xValue := xControl:Value()
   CASE xControl:ClassName == "TMULTIGET";  xValue := xControl:GetText()
   CASE xControl:ClassName == "TDATEPICK";  xValue := xControl:Value()
   CASE xControl:ClassName == "TRADIO";     xValue := xControl:nOption()
   OTHERWISE // GetText() ??
      gui_MsgBox( "SetValue for " + xControl:ClassName )
   ENDCASE

   xValue := xControl:Value() // GetText()

   (xDlg);(xControl)

   RETURN xValue

FUNCTION gui_ControlSetValue( xDlg, xControl, xValue )

   DO CASE
   CASE xControl:ClassName == "TSAY";       xControl:SetText( xValue )
   CASE xControl:ClassName == "TCOMBOBOX" ; xControl:Set( xValue )
   CASE xControl:ClassName == "TCHECKBOX";  xControl:SetCheck( xValue )
   CASE xControl:ClassName == "TGET";       xControl:cText( xValue )
   CASE xControl:ClassName == "TMULTIGET";  xControl:cText( xValue )
   CASE xControl:ClassName == "TDATEPICK";  xControl:cText( xValue )
   CASE xControl:ClassName == "TRADIO";     xControl:SetOption( xValue )
   OTHERWISE // cText(x) ??
      gui_MsgBox( "SetValue for " + xControl:ClassName )
   ENDCASE
   xControl:Refresh()

   (xDlg)

   RETURN Nil

FUNCTION gui_DlgSetKey( Self )

   LOCAL aItem

   FOR EACH aItem IN ::aDlgKeyDown
   NEXT

   RETURN Nil

FUNCTION ToDialog( x )

   RETURN iif( ISDIALOG, x / 2, x )

FUNCTION DoNothing(...)

   RETURN Nil
