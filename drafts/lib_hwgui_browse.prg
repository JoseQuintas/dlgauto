/*
lib_hwgui_browse - browse hwgui not in use
*/

#include "inkey.ch"
#include "frm_class.ch"

#define BUTTON_SIZE  50
#define TEXT_SIZE    20
#define BUTTON_SPACE 3
#define STYLE_BACK               15790720
#define STYLE_BTN_NORMAL         HStyle():New( { STYLE_BACK }, 1 )
#define STYLE_BTN_CLICK          HStyle():New( { STYLE_BACK }, 1,, 3, 0 )
#define STYLE_BTN_OVER           HStyle():New( { 16759929, 16771062 }, 1,, 2, 12164479 )
#define STYLE_BTN_ALL            { STYLE_BTN_NORMAL, STYLE_BTN_CLICK, STYLE_BTN_OVER }

#ifndef HBMK_HAS_HWGUI
   FUNCTION frm_Browse( ... )

   RETURN Nil
#else
FUNCTION frm_Browse( Self, cModule, cTitle, ... )

   LOCAL cnSQL := ADOLocal(), oTBrowse, cCampoKeyboard := "CODIGO", xValue

   hb_Default( @cTitle, "PESQUISA DE CIDADES" )
   hb_Default( @cModule, "test" )
   WITH OBJECT cnSQL
      :Execute( "SELECT CINOME, CIUF, CIIBGE, IDCIDADE" + ;
         " FROM JPCIDADE" + ;
         " ORDER BY CINOME" )
      oTBrowse := { ;
         { "NOME", { || :String( "CINOME", 40 ) } }, ;
         { "UF",   { || :String( "CIUF", 2 ) } }, ;
         { "IBGE", { || :String( "CIIBGE", 7 ) } }, ;
         { "ID",   { || Str( :Number( "IDCIDADE" ), 6 ) } } }
      xValue := MakeBrowse( Self, cTitle, cnSQL, oTBrowse, "CINOME", ;
         iif( cCampoKeyboard == "CODIGO", { || Str( :Number( "IDCIDADE" ), 6 ) }, { || :String( "CINOME", Len( GetActive():VarGet ) ) } ) )
      IF xValue != Nil
         hwg_MsgInfo( Transform( xValue, "" ) )
      ENDIF
      :CloseRecordset()
   ENDWITH
   ( cModule )

   RETURN Nil

FUNCTION MakeBrowse( Self, cTitle, cnSQL, oBrowseList, cFilterList, bCode )

   LOCAL xDlg, oBrowse, cFilter := "", lSelected := .F., xValue := Nil, oBtnList := {}

   hb_Default( @cFilter, "" )

   INIT DIALOG xDlg ;
      AT 0, 0 SIZE APP_DLG_WIDTH, APP_DLG_HEIGHT ;
      TITLE cTitle ;
      STYLE WS_DLGFRAME + WS_SYSMENU ;
      BACKCOLOR STYLE_BACK

   @ 11, 101 BROWSE ARRAY oBrowse ;
      SIZE xDlg:nWidth - 20, xDlg:nHeight - 140 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL + DS_CENTER ;
      ON CLICK { || lSelected := .T., xDlg:Close() } ;
      ON KEYDOWN { | oBrw, nkey | oBrowseKey( xDlg, oBrw, nkey, @cFilter, lSelected, cFilterList ) }
   oBrowse:aArray := cnSQL
   BrowseSet( oBrowse, oBrowseList )
   CreateButtons( Self, xDlg, oBrowse, @oBtnList )

   ACTIVATE DIALOG xDlg CENTER

   IF lSelected .AND. bCode != Nil
      xValue := Eval( bCode )
   ENDIF
   ( cFilterList )

   RETURN xValue

FUNCTION BrowseSet( oBrowse, oBrowseList )

   LOCAL oElement

   oBrowse:bSkip  := { | o, nSkip | ADOSkipper( o:aArray, nSkip ) }
   oBrowse:bGotop := { | o | o:aArray:MoveFirst() }
   oBrowse:bGobot := { | o | o:aArray:MoveLast() }
   oBrowse:bEof   := { | o | o:nCurrent > o:aArray:RecordCount() }
   oBrowse:bBof   := { | o | o:nCurrent == 0 }
   oBrowse:bRcou  := { | o | o:aArray:RecordCount() }
   oBrowse:bRecno := { | o | o:aArray:AbsolutePosition() }
   oBrowse:bRecnoLog := oBrowse:bRecno
   oBrowse:bGOTO  := { | o, n | (o), o:aArray:Move( n - 1, 1 ) }

   FOR EACH oElement IN oBrowseList
      ADD COLUMN oElement[ 2 ] TO oBrowse HEADER oElement[ 1 ] LENGTH Int( Len( Transform( Eval( oElement[ 2 ] ), "" ) ) * 1.2 ) + 1
   NEXT

   RETURN Nil

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

STATIC FUNCTION oBrowseKey( xDlg, oBrowse, nKey, cFilter, lSelected, cFilterList )

   nKey := hb_KeyStd( nKey )
   DO CASE
   CASE nKey == K_ENTER .OR. nKey == K_ESC
      IF nKey == K_ENTER
         lSelected := .T.
      ENDIF
      xDlg:Close()
      RETURN .F.
   CASE IsAscChar( nKey )
      IF nKey == K_BS
         IF Len( cFilter ) > 0
            cFilter := Left( cFilter, Len( cFilter ) - 1 )
         ENDIF
      ELSE
         cFilter += Upper( Chr( nKey ) )
      ENDIF
      oBrowse:aArray:Filter( iif( Empty( cFilter ), "", cFilterList + " LIKE '%" + cFilter + "%'" ) )
      IF oBrowse:aArray:Eof() .AND. Len( cFilter ) > 0
         cFilter := Substr( cFilter, 1, Len( cFilter ) - 1 )
         oBrowse:aArray:Filter( iif( Empty( cFilter ), "", cFilterList + " LIKE '%" + cFilter + "%'" ) )
      ENDIF
      oBrowse:Refresh()
   ENDCASE

   RETURN .T.

STATIC FUNCTION IsAscChar( nKey )

   DO CASE
   CASE nKey == VK_BACK
   CASE nKey >= Asc( "A" ) .AND. nKey <= Asc( "Z" )
   CASE nKey >= Asc( "a" ) .AND. nKey <= Asc( "z" )
   CASE nKey >= Asc( "0" ) .AND. nKey <= Asc( "9" )
   CASE hb_AScan( { " " }, { | e | nKey == Asc( e ) } ) != 0
   OTHERWISE
      RETURN .F.
   ENDCASE

   RETURN .T.

STATIC FUNCTION CreateButtons( Self, xDlg, oBrowse, oBtnList )

   LOCAL nRow, nCol, oBtn, nRowLine := 1
   LOCAL acOptions := { ;
      { "First",      "icoGoTop",    { || oBrowse:Top() } }, ;
      { "PrevPage",   "icoGoPgUp",   { || oBrowse:PageUp() } }, ;
      { "Previous",   "icoGoUp",     { || oBrowse:LineUp() } }, ;
      { "Next",       "icoGoDown",   { || oBrowse:LineDown() } }, ;
      { "NextPage",   "icoGoPgDn",   { || oBrowse:PageDown() } }, ;
      { "Last",       "icoGoBottom", { || oBrowse:Bottom() } }, ;
      { "Filter",     "icoFilter",   { || Nil } }, ;
      { "Exit",       "icoDoor",     { || xDlg:Close() } } }

   nCol := 10
   nRow := 10
   oBtnList := {}
   FOR EACH oBtn IN acOptions
      @ nCol, nRow OWNERBUTTON oBtn OF xDlg SIZE BUTTON_SIZE, BUTTON_SIZE ;
         ON CLICK oBtn[ 3 ] ;
         BITMAP ;
         HICON():AddResource( oBtn[ 2 ], BUTTON_SIZE - TEXT_SIZE, BUTTON_SIZE - TEXT_SIZE ) COORDINATES 1, 1, BUTTON_SIZE - TEXT_SIZE, BUTTON_SIZE - TEXT_SIZE ;
         TEXT oBtn[ 1 ] COORDINATES 5, BUTTON_SIZE - TEXT_SIZE, BUTTON_SIZE - 5, TEXT_SIZE ;
         Tooltip oBtn[ 1 ]
      oBtn:aStyle := STYLE_BTN_ALL
      IF nCol > APP_DLG_WIDTH - 10 - BUTTON_SIZE - BUTTON_SPACE
         nRowLine += 1
         nRow += BUTTON_SIZE + BUTTON_SPACE
         nCol := APP_DLG_WIDTH - BUTTON_SIZE - BUTTON_SPACE
      ENDIF
      AAdd( oBtnList, oBtn )
      nCol += iif( nRowLine == 1, 1, -1 ) * ( BUTTON_SIZE + BUTTON_SPACE )
   NEXT

   RETURN Nil

FUNCTION ADOLocal()

   RETURN Nil
#endif
