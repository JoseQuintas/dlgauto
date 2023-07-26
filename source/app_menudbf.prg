#include "hbgtinfo.ch"
#include "directry.ch"
#include "dlgauto.ch"

FUNCTION DlgAutoMenu( aAllSetup )

   LOCAL aItem, cName := "", nQtd := 0, aMenuList := {}, aGrupoList, cOpcao
#ifdef HBMK_HAS_HWGUI
   LOCAL oDlg
#endif
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

#ifdef HBMK_HAS_HWGUI
   INIT WINDOW oDlg TITLE "Example" ;
     AT 0, 0 SIZE 512, 384

   MENU OF oDlg
      FOR EACH aGrupoList IN aMenuList
         MENU TITLE "Data" + Ltrim( Str( aGrupoList:__EnumIndex ) )
            FOR EACH cOpcao IN aGrupoList
               MENUITEM cOpcao ACTION DlgAutoMain( cOpcao, @aAllSetup )
            NEXT
         ENDMENU
      NEXT
      MENU TITLE "Exit"
         MENUITEM "&Exit" ACTION oDlg:Close()
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oDlg CENTER
#endif

#ifdef HBMK_HAS_HMGE
   DEFINE WINDOW Form_Main ;
      AT 1000, 500 ;
      WIDTH 512 ;
      HEIGHT 384 ;
      WINDOWTYPE MAIN

      DEFINE MAIN MENU OF Form_Main

         FOR EACH aGrupoList IN aMenuList
            DEFINE POPUP "Data" + Ltrim( Str( aGrupoList:__EnumIndex ) )
               FOR EACH cOpcao IN aGrupoList
                  MENUITEM cOpcao ACTION DlgAutoMain( cOpcao, @aAllSetup )
               NEXT
            END POPUP
         NEXT
         DEFINE POPUP "Sair"
            MENUITEM "Sair" ACTION Form_Main.Release
         END POPUP
      END MENU
   END WINDOW

   form_Main.CENTER
   form_Main.ACTIVATE
#endif

#ifdef HBMK_HAS_OOHG
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
#endif
   RETURN Nil
