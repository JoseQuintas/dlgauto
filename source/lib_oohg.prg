/*
lib_oohg - oohg source selected by lib.prg
*/

#include "frm_class.ch"

FUNCTION gui_MainMenu( oDlg, aMenuList, aAllSetup )

   LOCAL aGroupList, oMenuMain, oMenuGroup, cDBF

   WITH OBJECT oDlg := TFormMain():Define()
      :Col := 0
      :Row := 0
      :Width := 1024
      :Height := 768
      :Title := "DlgAuto"
      oMenuMain := TMenuMain():Define(,"MyMenu")
         FOR EACH aGroupList IN aMenuList
            oMenuGroup:= TMenuItem():DefinePopup( "Data" + Ltrim( Str( aGroupList:__EnumIndex ) ) )
            FOR EACH cDBF IN aGroupList
               TMenuItem():DefineItem( cDBF, { || frm_Main( cDBF, aAllSetup ) } )
            NEXT
            oMenuGroup:EndPopup()
         NEXT
         oMenuGroup := TMenuItem():DefinePopup( "Sair" )
            TMenuItem():DefineItem( "Sair", { || oDlg:Release() } )
         oMenuGroup:EndPopup()
      oMenuMain:EndMenu()
      :EndWindow()
      :Center()
      :Activate()
   ENDWITH

   RETURN Nil

FUNCTION gui_ButtonCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, cCaption, cResName, bAction )

   IF Empty( xControl )
      xControl := gui_newctlname( "BUTTON" )
   ENDIF

   IF cCaption == "Cancel"
      @ nRow, nCol BUTTON ( xControl ) ;
         PARENT ( xDlg ) ;
         CAPTION  cCaption ;
         PICTURE  cResName ;
         ACTION   Eval( bAction ) ;
         WIDTH    nWidth ;
         HEIGHT   nHeight ;
         IMAGEALIGN TOP ;
         CANCEL // abort valid
   ELSE
      @ nRow, nCol BUTTON ( xControl ) ;
         PARENT ( xDlg ) ;
         CAPTION  cCaption ;
         PICTURE  cResName ;
         ACTION   Eval( bAction ) ;
         WIDTH    nWidth ;
         HEIGHT   nHeight ;
         IMAGEALIGN TOP
   ENDIF

   RETURN Nil

FUNCTION gui_ButtonEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_Browse( xDlg, xControl, nRow, nCol, nWidth, nHeight, oTbrowse, cField, xValue, workarea )

   LOCAL aHeaderList := {}, aWidthList := {}, aFieldList := {}, aItem

   IF Empty( xControl )
      xControl := gui_newctlname( "BROWSE" )
   ENDIF
   FOR EACH aItem IN oTbrowse
      AAdd( aHeaderList, aItem[1] )
      AAdd( aFieldList, aItem[3] )
      AAdd( aWidthList, Len( Transform(FieldGet(FieldNum(aItem[3])),"")) * 10 )
   NEXT
   @ nRow, nCol BROWSE ( xControl ) ;
      OF ( xDlg ) ;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      HEADERS aHeaderList ;
      WIDTHS aWidthList ;
      WORKAREA ( workarea ) ;
      FIELDS aFieldList

   (cField);(xValue)

   RETURN Nil

FUNCTION gui_DialogActivate( xDlg, bCode )

   IF ! Empty( bCode )
      Eval( bCode )
   ENDIF
   DoMethod( xDlg, "CENTER" )
   ACTIVATE WINDOW ( xDlg )

   RETURN Nil

FUNCTION gui_DialogClose( xDlg )

   DoMethod( xDlg, "RELEASE" )

   RETURN Nil

FUNCTION gui_DialogCreate( xDlg, nRow, nCol, nWidth, nHeight, cTitle, bInit )

   IF Empty( xDlg )
      xDlg := gui_newctlname( "DIALOG" )
   ENDIF
   IF Empty( bInit )
      bInit := { || Nil }
   ENDIF

   DEFINE WINDOW ( xDlg ) ;
      AT     nCol, nRow ;
      WIDTH  nWidth ;
      HEIGHT nHeight ;
      TITLE  cTitle ;
      MODAL ;
      ON INIT Eval( bInit )
   END WINDOW

   RETURN Nil

//   WITH OBJECT ::oDlg := TForm():Define()
//      :Row := 500
//      :Col := 1000
//      :Width := ::nDlgWidth
//      :Height := ::nDlgHeight
//      :Title := ::cFileDbf
//      // :Init := ::UpdateEdit()
//   ENDWITH
//    _EndWindow()

FUNCTION gui_IsCurrentFocus( xDlg, xControl )

   // not used, solved on button using CANCEL
   RETURN GetFocus() == GetProperty( xDlg, xControl, "HWND" )

FUNCTION gui_LabelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue, lBorder )

   IF Empty( xControl )
      xControl := gui_newctlname( "LABEL" )
   ENDIF
   (xDlg)
   (lBorder)
   IF lBorder
      @ nRow, nCol LABEL ( xControl ) ;
         PARENT ( xDlg ) ;
         VALUE  xValue ;
         WIDTH  nWidth ;
         HEIGHT nHeight ;
         BORDER
   ELSE
      @ nRow, nCol LABEL ( xControl ) PARENT ( xDlg ) ;
         VALUE xValue WIDTH nWidth HEIGHT nHeight
   ENDIF
   //WITH OBJECT xControl := TLabel():Define()
   //   :Parent := xDlg
   //   :Row := nRow
   //   :Col := nCol
   //   :Value := xValue
   //   :AutoSize := .T.
   //   :Width := nWidth
   //   :Height := nHeight
   //   //:Border := lBorder
   //ENDWITH

   RETURN Nil

FUNCTION gui_LabelSetValue( xDlg, xControl, xValue )

   SetProperty( xDlg, xControl, "VALUE", xValue )

   RETURN Nil

FUNCTION gui_MLTextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, xValue )

   IF Empty( xControl )
      xControl := gui_newctlname( "MLTEXT" )
   ENDIF
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight); (xValue)

   RETURN Nil

FUNCTION gui_Msgbox( cText )

   RETURN Msgbox( cText )

FUNCTION gui_MsgYesNo( cText )

   RETURN MsgYesNo( cText )

FUNCTION gui_PanelCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_newctlname( "PANEL" )
   ENDIF
   (xDlg); (xControl); (nRow); (nCol); (nWidth); (nHeight)

   RETURN Nil

FUNCTION gui_SetFocus( xDlg, xControl )

   DoMethod( xDlg, xControl, "SETFOCUS" )

   RETURN Nil

FUNCTION gui_TabCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight )

   IF Empty( xControl )
      xControl := gui_newctlname( "TAB" )
   ENDIF
   DEFINE TAB ( xControl ) ;
      PARENT ( xDlg ) ;
      AT nRow, nCol;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      VALUE 1

   xControl := xDlg // because they are not on tab
   (nRow);(nCol);(nWidth);(nHeight);(xDlg)

   RETURN Nil

FUNCTION gui_TabEnd()

   END TAB

   RETURN Nil

FUNCTION gui_TabNavigate( xDlg, oTab, aList )

   (xDlg);(oTab);(aList)

   RETURN Nil

FUNCTION gui_TabPageBegin( xDlg, xControl, cText )

   (xDlg); (xControl); (cText)
   DEFINE PAGE cText

   RETURN Nil

FUNCTION gui_TabPageEnd( xDlg, xControl )

   (xDlg); (xControl)
   END PAGE

   RETURN Nil

FUNCTION gui_TextCreate( xDlg, xControl, nRow, nCol, nWidth, nHeight, ;
            xValue, cPicture, nMaxLength, bValid )

   IF Empty( xControl )
      xControl := gui_newctlname( "TEXT" )
   ENDIF
   (bValid)
   (cPicture)
   DEFINE TEXTBOX ( xControl )
      PARENT ( xDlg )
      ROW      nRow
      COL      nCol
      HEIGHT   nHeight
      WIDTH    nWidth
      FONTNAME DEFAULT_FONTNAME
      IF ValType( xValue ) == "N"
         NUMERIC .T.
      ELSEIF ValType( xValue ) == "D"
         DATE .T.
      ELSE
         MAXLENGTH nMaxLength
      ENDIF
      VALUE     xValue
      ON LOSTFOCUS Eval( bValid )
   END TEXTBOX

   RETURN Nil

   // not confirmed
   // WITH OBJECT aItem[ CFG_FCONTROL ] := TText():Define()
   //    :Row    := nRow2
   //    :Col    := nCol2
   //    :Width  := aItem[ CFG_FLEN ] * 12
   //    :Height := ::nLineHeight
   //    :Value  := aItem[ CFG_VALUE ]
   // ENDWITH

FUNCTION gui_TextEnable( xDlg, xControl, lEnable )

   SetProperty( xDlg, xControl, "ENABLED", lEnable )

   RETURN Nil

FUNCTION gui_TextGetValue( xDlg, xControl )

   (xDlg)

   RETURN GetProperty( xDlg, xControl, "VALUE" )

FUNCTION gui_TextSetValue( xDlg, xControl, xValue )

   // NOTE: string value, except if declared different on textbox creation
   SetProperty( xDlg, xControl, "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )

   RETURN Nil

STATIC FUNCTION gui_newctlname( cPrefix )

   STATIC nCount := 0

   hb_Default( @cPrefix, "ANY" )
   nCount += 1

   RETURN cPrefix  + StrZero( nCount, 10 )
