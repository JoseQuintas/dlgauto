#include "hbgtinfo.ch"
#include "directry.ch"
#include "frm_class.ch"

FUNCTION frm_MainMenu( aAllSetup )

   LOCAL aItem, cName := "", nQtd := 0, aMenuList := {}, aGrupoList, cDBF
#ifdef THIS_HWGUI
   LOCAL oDlg
#endif
#ifdef THIS_OOHG
   LOCAL oDlg, oMenuMain, oMenuGroup
#endif

   FOR EACH aItem IN aAllSetup
      IF ! cName == aItem[1]
         IF Mod( nQtd, 15 ) == 0
            AAdd( aMenuList, {} )
         ENDIF
         cDBF := aItem[1]
         AAdd( Atail( aMenuList ), cDBF )
         nQtd += 1
      ENDIF
   NEXT

#ifdef THIS_HWGUI
   INIT WINDOW oDlg TITLE "Example" AT 0, 0 SIZE 512, 384
   MENU OF oDlg
      FOR EACH aGrupoList IN aMenuList
         MENU TITLE "Data" + Ltrim( Str( aGrupoList:__EnumIndex ) )
            FOR EACH cDBF IN aGrupoList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
            NEXT
         ENDMENU
      NEXT
      MENU TITLE "Exit"
         MENUITEM "&Exit" ACTION oDlg:Close()
      ENDMENU
   ENDMENU
   ACTIVATE WINDOW oDlg CENTER
#endif

#ifdef THIS_HMGE
   DEFINE WINDOW ("Main") ;
      AT 1000, 500 ;
      WIDTH 512 ;
      HEIGHT 384 ;
      TITLE "Example" ;
      WINDOWTYPE MAIN

      DEFINE MAIN MENU OF ("Main")
         FOR EACH aGrupoList IN aMenuList
            DEFINE POPUP "Data" + Ltrim( Str( aGrupoList:__EnumIndex ) )
               FOR EACH cDBF IN aGrupoList
                  MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
               NEXT
            END POPUP
         NEXT
         DEFINE POPUP "Sair"
            MENUITEM "Sair" ACTION ("Main").Release
         END POPUP
      END MENU
   END WINDOW

   ("Main").CENTER
   ("Main").ACTIVATE
#endif

#ifdef THIS_OOHG
   WITH OBJECT oDlg := TFormMain():Define()
      :Col := 1000
      :Row := 500
      :Width := 900
      :Height := 600
      :Title := "DlgAuto"
      oMenuMain := TMenuMain():Define(,"MyMenu")
         FOR EACH aGrupoList IN aMenuList
            oMenuGroup:= TMenuItem():DefinePopup( "Data" + Ltrim( Str( aGrupoList:__EnumIndex ) ) )
            FOR EACH cDBF IN aGrupoList
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
#endif

   RETURN Nil
