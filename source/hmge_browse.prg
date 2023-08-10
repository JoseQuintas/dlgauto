/*
hmge_browse - not in use
*/

#include 'hmg.ch'
#include "i_winuser.ch"

MEMVAR cMe, cBrowseName, cWindowName, cSearchString, cWorkArea

FUNCTION HmgeBrowse( ... )

   LOCAL nCont, aHeaders := {}, aFields := {}, aWidths := {}

   STATIC nWindow := 0
   PRIVATE cMe, cBrowseName, cWindowName, cSearchString := "", cWorkArea := Alias()

   _hmge_init()
   nWindow += 1
   cMe := "Pesquisa" + StrZero( nWindow, 4 )

   SET WINDOW MAIN OFF
   SET BROWSESYNC  ON

   IF Len( AppForms() ) > 0
      Atail( AppForms() ):GUIHide()
   ENDIF

   FOR nCont = 1 TO FCount()
      AAdd( aHeaders, FieldName( nCont ) )
      AAdd( aFields,  FieldName( nCont ) )
      AAdd( aWidths,  FieldLen( nCont ) * 10 )
   NEXT

   DEFINE WINDOW &cMe ;
         AT     0, 0 ;
         WIDTH  800 ;
         HEIGHT 605 ;
         TITLE  "Pesquisa em " + Alias() ;
         MODAL  ;
         NOSIZE ;
         ON INIT cWindowName := This.Name

      ON KEY ESCAPE ACTION thiswindow.release

      DEFINE STATUSBAR
         STATUSITEM "ENTER Seleciona"
         KEYBOARD
      END STATUSBAR

   END WINDOW

   @ 5, 5 BROWSE grid_pesquisa ;
      OF       &cMe ;
      WIDTH    795 ;
      HEIGHT   430 ;
      HEADERS  aHeaders ;
      WIDTHS   aWidths ;
      WORKAREA &cWorkArea ;
      FIELDS   aFields ;
      ; // JUSTIFY  { BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT } ;
      ON GOTFOCUS cBrowseName := This.Name

   CREATE EVENT PROCNAME BrowseKeys()

   // DoMethod( cMe, "center" )
   DoMethod( cMe, "activate" )
   IF Len( AppForms() ) > 0
      Atail( AppForms() ):GUIShow()
   ENDIF

   RETURN Nil

FUNCTION BrowseKeys( hWnd, nMsg, wParam, lParam )

   LOCAL nKey, cKey, cWindowName := cMe

   HB_SYMBOL_UNUSED( hWnd )
   HB_SYMBOL_UNUSED( wParam )

   IF nMsg != WM_NOTIFY
      RETURN Nil
   ENDIF

   IF ! _IsControlDefined( cBrowseName, cWindowName ) .OR. GetHwndFrom( lParam ) != GetProperty( cWindowName, cBrowseName, "Handle" )
      RETURN Nil
   ENDIF

   IF ! GetNotifyCode( lParam ) == LVN_KEYDOWN
      RETURN Nil
   ENDIF

   nKey := GetGridvKey( lParam )

   DO CASE
   CASE nKey == VK_UP
      _BrowseUp( cBrowseName, cWindowName )
      RETURN ClearSearch()

   CASE nKey == VK_DOWN
      _BrowseDown( cBrowseName, cWindowName )
      RETURN ClearSearch()

   CASE nKey == VK_HOME
      _BrowseHome( cBrowseName, cWindowName )
      RETURN ClearSearch()

   CASE nKey == VK_END
      _BrowseEnd( cBrowseName, cWindowName )
      RETURN ClearSearch()

   CASE nKey == VK_PRIOR
      _BrowsePrior( cBrowseName, cWindowName )
      RETURN ClearSearch()

   CASE nKey == VK_NEXT
      _BrowseNext( cBrowseName, cWindowName )
      RETURN ClearSearch()

   OTHERWISE
      cKey := Chr( nKey )
      IF IsAlpha( cKey ) .OR. IsDigit( cKey ) .OR. nKey == VK_BACK
         RETURN IncrementalSearch( cKey, nKey )
      ENDIF

   ENDCASE

   RETURN Nil

STATIC FUNCTION ClearSearch()

   cSearchString := ""
   SetProperty( cWindowName, "StatusBar", "Item", 1, "" )

   RETURN 1

STATIC FUNCTION IncrementalSearch( cKey, nKey )

   LOCAL nOldRec

   IF nKey == VK_BACK
      cSearchString := iif( Len( cSearchString ) > 1, Left( cSearchString, Len( cSearchString ) - 1 ), "" )
   ELSE
      cSearchString += cKey
   ENDIF

   nOldRec := RecNo()
   IF dbSeek( Upper( cSearchString ), .T. )
      SetProperty( cWindowName, cBrowseName, "Value", RecNo() )
   ELSE
      cSearchString := iif( Len( cSearchString ) > 1, Left( cSearchString, Len( cSearchString ) - 1 ), "" )
      SetProperty( cWindowName, cBrowseName, "Value", nOldRec )
   ENDIF

   SetProperty( cWindowName, "StatusBar", "Item", 1, "Quicksearch: " + iif( Empty( cSearchString ), "", cSearchString ) )
   DoMethod( cWindowName, cBrowseName, 'Setfocus' )

   RETURN 1
