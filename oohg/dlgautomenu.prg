#include "hbgtinfo.ch"
#include "directry.ch"
#include "oohg.ch"

FUNCTION DlgAutoMenu( aAllSetup )

   LOCAL aItem, cName := "", nQtd := 0, aMenuList := {}, aGrupoList, cOpcao
#ifdef HBMK_HAS_OOHG
   LOCAL oDlg, oMenuMain, oMenuGroup
#endif

   FOR EACH aItem IN aAllSetup
      IF ! cName == aItem[1]
         IF Mod( nQtd, 15 ) == 0
            AAdd( aMenuList, {} )
         ENDIF
         cName := aItem[1]
         AAdd( Atail( aMenuList ), cName )
         nQtd += 1
      ENDIF
   NEXT
   WITH OBJECT oDlg := TFormMain():Define()
      :Col := 1000
      :Row := 500
      :Width := 900
      :Height := 600
      :Title := "DlgAuto"
      oMenuMain := TMenuMain():Define(,"MyMenu")
         FOR EACH aGrupoList IN aMenuList
            oMenuGroup:= TMenuItem():DefinePopup( "Data" + Ltrim( Str( aGrupoList:__EnumIndex ) ) )
            FOR EACH cOpcao IN aGrupoList
               TMenuItem():DefineItem( cOpcao, { || DlgAutoMain( cOpcao, @aAllSetup ) } )
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

