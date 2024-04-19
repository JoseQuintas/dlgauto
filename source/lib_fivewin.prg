/*
lib_fivewin- fivewin source selected by lib.prg
*/

#pragma -w0
#include "frm_class.ch"

FUNCTION gui_Init()

   RETURN Nil

FUNCTION gui_DlgMenu( xDlg, aMenuList, aAllSetup, cTitle )

   LOCAL oMenu, aGroupList, cDBF

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
      //DEFINE MONTHCALENDAR("mcal001")
      //   PARENT ( xDlg )
      //   COL 400
      //   ROW 400
      //   VALUE Date()
      //END MONTHCALENDAR

   gui_DialogActivate( xDlg )

   (xDlg);(aMenuList);(aAllSetup);(cTitle);(oMenu)

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )


   @ ToRow( nRow ), ToCol( nCol ) BUTTON cCaption OF xDlg SIZE nWidth, nHeight ACTION Eval( bAction )
   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(cCaption);(cResName);(bAction)

   RETURN Nil

FUNCTION gui_Browse( xDlg, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, ;
   cField, xValue, workarea, aKeyCodeList, aDlgKeyCodeList )
/*
   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem

   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, aItem[2] )
      AAdd( aWidthList, ( 1 + Max( Len( aItem[3] ), ;
         Len( Transform( ( workarea )->( FieldGet( FieldNum( aItem[ 1 ] ) ) ), "" ) ) ) ) * 13 )
   NEXT

   DEFINE BROWSE ( xControl )
      PARENT ( xDlg )
      ROW nRow
      COL nCol
      WIDTH nWidth - 20
      HEIGHT nHeight - 20
      IF ValType( aKeyCodeList ) != "A"
         aKeyCodeList := {}
         ONDBLCLICK gui_BrowseDblClick( xDlg, xControl, workarea, cField, @xValue )
      ENDIF
      HEADERS aHeaderList
      WIDTHS aWidthList
      WORKAREA ( workarea )
      FIELDS aFieldList
      SET BROWSESYNC ON
   END BROWSE
   FOR EACH aItem IN aKeyCodeList
      AAdd( aDlgKeyCodeList, { xControl, aItem[ 1 ], aItem[ 2 ] } )
      _DefineHotKey( xDlg, 0, aItem[ 1 ], ;
         { || gui_DlgKeyDown( xDlg, xControl, aItem[ 1 ], workarea, cField, xValue, aDlgKeyCodeList ) } )
   NEXT
*/
   (xDlg);(cField);(xValue);(workarea);(aKeyCodeList);(xControl);(nRow);(nCol);(nWidth)
   (nHeight);(oTBrowse);(aDlgKeyCodeList)
   (xValue)

   RETURN Nil

/*
STATIC FUNCTION gui_DlgKeyDown( xDlg, xControl, nKey, workarea, cField, xValue, aDlgKeyCodeList )
   LOCAL nPos, cType

   nPos := hb_AScan( aDlgKeyCodeList, { | e | GetProperty( xDlg, "FOCUSEDCONTROL" ) == e[1] .AND. nKey == e[ 2 ] } )
   IF nPos != 0
      Eval( aDlgKeyCodeList[ nPos ][ 3 ], cField, @xValue, xDlg, xControl )
   ENDIF
   IF nKey == VK_RETURN .AND. hb_ASCan( aDlgKeyCodeList, { | e | e[ 2 ] == VK_RETURN } ) != 0
      cType := GetProperty( xDlg, GetProperty( xDlg, "FOCUSEDCONTROL" ), "TYPE" )
      IF hb_AScan( { "GETBOX", "MASKEDTEXT", "TEXT" }, { | e | e == cType } ) != 0
         _SetNextFocus()
      ENDIF
   ENDIF
   (xControl); (workarea); (xDlg);(nKey);(xValue);(cField);(aDlgKeyCodeList)

   RETURN .T.
   */

FUNCTION gui_BrowseDblClick( xDlg, xControl, workarea, cField, xValue )

   IF ! Empty( cField )
      xValue := (workarea)->( FieldGet( FieldNum( cField ) ) )
   ENDIF
   (xControl);(xDlg)
   //DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_BrowseRefresh( xDlg, xControl )

   //SetProperty( xDlg, xControl, "VALUE", RecNo() )
   //DoMethod( xDlg, xControl, "REFRESH" )
   (xDlg);(xControl)

   RETURN Nil

FUNCTION gui_CheckboxCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   LOCAL xValue := .F.

   @ ToRow( nRow ), ToCol( nCol ) CHECKBOX xValue PROMPT "" SIZE nWidth, nHeight PIXEL OF xDlg

   (xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)

   RETURN Nil

FUNCTION gui_ComboCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, aList )

   LOCAL cAny

   @ ToRow( nRow), ToCol( nCol ) COMBOBOX xControl VAR cAny OF xDlg SIZE nWidth, nHeight ;
      ITEMS aList ;
      STYLE CBS_DROPDOWN // ON CHANGE QueDia( cDia )

   //oCbx:oGet:bKeyChar = { | nKey | If( nKey == VK_RETURN,;
   //                                  ( cDia := oCbx:oGet:GetText(), Eval( oCbx:bChange() ) ),),;
   //                                    oCbx:GetKeyChar( nKey ) }

   (nHeight);(xDlg);(xControl);(nRow);(nCol);(nWidth);(aList)

   RETURN Nil

FUNCTION gui_DatePickerCreate( xDlg, xControl, ;
            nRow, nCol, nWidth, nHeight, dValue )
/*
   DEFINE DATEPICKER (xControl)
      PARENT ( xDlg )
      ROW	nRow
      COL	nCol
      VALUE dValue
      TOOLTIP 'DatePicker Control'
      SHOWNONE .F.
      TITLEBACKCOLOR BLACK
      TITLEFONTCOLOR YELLOW
      TRAILINGFONTCOLOR PURPLE
   END DATEPICKER
*/
   (nWidth);(nHeight);(xDlg);(xControl);(nRow);(nCol);(dValue)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode )

   ACTIVATE WINDOW xDlg CENTERED
   (bCode)

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   xDlg:End()
   (xDlg)

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit, xOldDlg )

   DEFINE WINDOW xDlg FROM nRow, nCol TO nRow + nHeight, nCol + nWidth PIXEL TITLE cTitle ICON "AppIcon"

   (xDlg);(nRow);(nCol);(nWidth);(nHeight);(cTitle);(bInit);(xOldDlg)

   RETURN Nil

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

      (xDlg);(xControl)
      RETURN .F. // GetProperty( xDlg, "FOCUSEDCONTROL" )  == xControl

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   @ nRow, nCol SAY xControl VAR xValue OF xDlg SIZE nWidth, nHeight COLOR CLR_BLUE PIXEL TRANSPARENT

/*
   DEFINE LABEL ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth
      HEIGHT nHeight
      VALUE xValue
      IF lBorder
         BORDER lBorder
      ENDIF
   END LABEL
*/
(xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(lBorder)
   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   //SetProperty( xDlg, xControl, "VALUE", xValue )
   (xDlg);(xControl);(xValue)

   RETURN Nil

FUNCTION gui_LibName()

   RETURN "FIVEWIN"

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )
/*
   DEFINE EDITBOX ( xControl )
      PARENT ( xDlg )
      COL nCol
      ROW nRow
      WIDTH nWidth
      HEIGHT nHeight
      VALUE xValue
      FONTNAME PREVIEW_FONTNAME
      TOOLTIP 'EditBox'
   END EDITBOX
*/
(xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue)
   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN MsgInfo( cText )

FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

FUNCTION gui_PanelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION gui_SetFocus( xDlg, xControl )

   //DoMethod( xDlg, xControl, "SETFOCUS" )
   (xDlg);(xControl)

   RETURN Nil

FUNCTION gui_Statusbar( xDlg, xControl )
/*
	DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 PARENT ( xDlg )
		STATUSITEM "DlgAuto"
		CLOCK
		DATE
	END STATUSBAR
   */
   (xDlg); (xControl)

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )
/*
   DEFINE TAB ( xControl ) ;
      PARENT ( xDlg ) ;
      AT nRow, nCol;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      HOTTRACK
*/
(xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight)
   RETURN Nil

FUNCTION gui_TabEnd()
/*
   END TAB
*/
   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, oTab, aList )

   (xDlg);(oTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, cText )
/*
   PAGE ( cText ) IMAGE "bmpfolder"
*/
   (xDlg); (xControl); (cText)

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
      @ ToRow( nRow ), ToCol( nCol ) GET xControl VAR xValue SIZE nWidth, nHeight PICTURE cPicture VALID iif( Empty( bValid ), .T., Eval( bValid ) )
   ELSE
      @ ToRow( nRow ), ToCol( nCol ) GET xControl VAR xValue SIZE nWidth, nHeight PICTURE cPicture VALID iif( Empty( bValid ), .T., Eval( bValid ) ) ;
      ACTION Eval( bAction ) BITMAP cImage
   ENDIF
   (bValid);(xDlg);(xControl);(nRow);(nCol);(nWidth);(nHeight);(xValue);(cPicture);(nMaxLength);(bAction);(cImage)

   RETURN Nil

FUNCTION gui_ControlEnable( xDlg, xControl, lEnable )

   xControl:Enable( lEnable )
   (xDlg);(xControl);(lEnable)

   RETURN Nil

FUNCTION gui_TextGetValue( xDlg, xControl )

   LOCAL xValue

   xValue := xControl:Value
   (xDlg);(xControl)

   RETURN xValue

FUNCTION gui_TextSetValue( xDlg, xControl, xValue )

   xControl:Value := xValue
   (xDlg);(xControl);(xValue)

   RETURN Nil

FUNCTION ToRow( nRow )

   RETURN nRow / 13

FUNCTION ToCol( nCol )

   RETURN nCol / 7
