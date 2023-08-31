/*
frm_mainmenu - menu of DBF files
*/

#include "hbgtinfo.ch"
#include "directry.ch"
#include "frm_class.ch"
#include "inkey.ch"

FUNCTION frm_MainMenu( aAllSetup )

   LOCAL aItem, cName := "", nQtd := 0, aMenuList := {}, aGroupList, cDBF, oDlg := "Main"
#ifdef HBMK_HAS_OOHG
   LOCAL oMenuMain, oMenuGroup
#endif
#ifdef HBMK_HAS_GTWVG
   LOCAL oMainMenu, oMenuGroup
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

#ifdef HBMK_HAS_HWGUI
   INIT WINDOW oDlg TITLE "Example" AT 0, 0 SIZE 1024, 768
   MENU OF oDlg
      FOR EACH aGroupList IN aMenuList
         MENU TITLE "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
            FOR EACH cDBF IN aGroupList
               MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
            NEXT
         ENDMENU
      NEXT
      MENU TITLE "Exit"
         MENUITEM "&Exit" ACTION gui_DialogClose( oDlg )
      ENDMENU
   ENDMENU
   gui_DialogActivate( oDlg )
#endif

#ifdef HBMK_HAS_HMGE
   DEFINE WINDOW ( oDlg ) ;
      AT 0, 0 ;
      WIDTH 1024 ;
      HEIGHT 768 ;
      TITLE "Example" ;
      WINDOWTYPE MAIN

      DEFINE MAIN MENU OF ( oDlg )
         FOR EACH aGroupList IN aMenuList
            DEFINE POPUP "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
               FOR EACH cDBF IN aGroupList
                  MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
               NEXT
            END POPUP
         NEXT
         DEFINE POPUP "Sair"
            MENUITEM "Sair" ACTION gui_DialogClose( oDlg )
         END POPUP
      END MENU
   END WINDOW

   gui_DialogActivate( oDlg )
#endif

#ifdef HBMK_HAS_HMG3
   DEFINE WINDOW ( oDlg ) ;
      AT 0, 0 ;
      WIDTH 1024 ;
      HEIGHT 768 ;
      TITLE "Example" ;
      WINDOWTYPE MAIN

      DEFINE MAIN MENU OF ( oDlg )
         FOR EACH aGroupList IN aMenuList
            DEFINE POPUP "Data" + Ltrim( Str( aGroupList:__EnumIndex ) )
               FOR EACH cDBF IN aGroupList
                  MENUITEM cDBF ACTION frm_Main( cDBF, aAllSetup )
               NEXT
            END POPUP
         NEXT
         DEFINE POPUP "Sair"
            MENUITEM "Sair" ACTION gui_DialogClose( oDlg )
         END POPUP
      END MENU
   END WINDOW

   gui_DialogActivate( oDlg )
#endif

#ifdef HBMK_HAS_OOHG
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
#endif

#ifdef HBMK_HAS_GTWVG
   (oDlg)
   SetMode(30,100)
   CLS
   oMainMenu := wvgSetAppWindow():MenuBar()
   FOR EACH aGroupList IN aMenuList
      oMenuGroup := wvgMenu():New( oMainMenu,,.T. ):Create()
      FOR EACH cDBF IN aGroupList
         oMenuGroup:AddItem( cDBF, { || hb_ThreadStart( { | nGt | nGt := hb_gtSelect(), ;
            frm_Main( cDBF, aAllSetup ), ;
            hb_gtSelect( nGt ) } ) } )
      NEXT
      oMainMenu:AddItem( oMenuGroup, "Data" + Ltrim( Str( aGroupList:__EnumIndex ) ) )
   NEXT
   oMainMenu:AddItem( "Sair", { || __Quit() } )
   DO WHILE Inkey(1) != K_ESC
   ENDDO
#endif

   RETURN Nil
