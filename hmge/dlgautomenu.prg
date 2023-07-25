#include "hbgtinfo.ch"
#include "directry.ch"
#include "hmg.ch"

FUNCTION DlgAutoMenu( aAllSetup )

   LOCAL aItem, cName := "", nQtd := 0, aMenuList := {}, aGrupoList, cOpcao

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

   RETURN Nil

