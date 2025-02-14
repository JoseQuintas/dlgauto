THREAD STATIC oGUI

FUNCTION GUI()

   RETURN oGUI

PROCEDURE Main

   LOCAL nOpc := 1

   SetMode(33,100)
   CLS
   DO WHILE .T.
      @ 1, 0 PROMPT "(H)HWGUI"
      @ 2, 0 PROMPT "(3)HMG3"
      @ 3, 0 PROMPT "(E)HMGE"
      @ 4, 0 PROMPT "(O)OOHG"
      MENU TO nOpc

      DO CASE
      CASE LastKey() == 27; EXIT
      CASE nOpc == 1; hb_ThreadStart( { || Test2( "DLGAUTOHWGUI" ) } )
      CASE nOpc == 2; hb_ThreadStart( { || Test2( "DLGAUTOHMG3" ) } )
      CASE nOpc == 3; hb_ThreadStart( { || Test2( "DLGAUTOHMGE" ) } )
      CASE nOpc == 4; hb_ThreadStart( { || Test2( "DLGAUTOOOHG" ) } )
      ENDCASE
   ENDDO

   RETURN

FUNCTION Test2( xFrmName )

   hb_gtReload("WVG")
   DO CASE
   //CASE xFrmName == "DLGAUTOFIVEWIN" ; oGui := FIVEWINClass():New()
   CASE xFrmName == "DLGAUTOHWGUI" ;   oGUI := HWGUIClass():New()
   CASE xFrmName == "DLGAUTOHMGE" ;    oGUI := HMGECLASS():New()
   //CASE xFrmName == "DLGAUTOHMG3" ;    oGUI := HMG3Class():New()
   //CASE xFrmName == "DLGAUTOOOHG" ;    oGUI := OOHGClass():New()
   ENDCASE
   Do( "DLGAUTO" )

   //PostQuitMessage(0)

   RETURN Nil

FUNCTION HB_GTSYS

   REQUEST HB_GT_WVG_DEFAULT

   RETURN Nil
