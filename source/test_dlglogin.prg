/*
test_DlgLogin - login
*/

#include "frm_class.ch"

MEMVAR lLogin, cUser, cPass

FUNCTION test_DlgLogin()

   LOCAL oFrm, aItem

   oFrm := Frm_Class():New()

   WITH OBJECT oFrm

      :aControlList := Array( 6 )
      FOR EACH aItem IN :aControlList
         aItem := EmptyFrmClassItem()
      NEXT

      gui_DialogCreate( @:xDlg, 0, 0, 300, 200, "Login",, .T. )

      gui_LabelCreate(  :xDlg, :xDlg, @:aControlList[1][ CFG_FCONTROL ], APP_LINE_SPACING, 20, 80, APP_LINE_HEIGHT, "User" )
      gui_TextCreate(   :xDlg, :xDlg, @:aControlList[2][ CFG_FCONTROL ], APP_LINE_SPACING, 90, 170, APP_LINE_HEIGHT, cUser,,,,,, :aControlList[2] )
      gui_LabelCreate(  :xDlg, :xDlg, @:aControlList[3][ CFG_FCONTROL ], 2 * APP_LINE_SPACING, 20, 80, APP_LINE_HEIGHT, "Password" )
      gui_TextCreate(   :xDlg, :xDlg, @:aControlList[4][ CFG_FCONTROL ], 2 * APP_LINE_SPACING, 90, 170, APP_LINE_HEIGHT, cPass,,,,,, :aControlList[4],,.T. )
      gui_ButtonCreate( :xDlg, :xDlg, @:aControlList[5][ CFG_FCONTROL ], 4 * APP_LINE_SPACING, 85, 50, APP_LINE_SPACING, "Login",, { || Login_Click( :xDlg ) } )
      gui_ButtonCreate( :xDlg, :xDlg, @:aControlList[6][ CFG_FCONTROL ], 4 * APP_LINE_SPACING, 155, 50, APP_LINE_SPACING, "Cancel",, { || Cancel_Click( :xDlg ) } )
      gui_SetFocus( :xDlg, :aControlList[ 2 ][ CFG_FCONTROL ] )

      gui_DialogActivate( :xDlg )

   ENDWITH

   (cUser);(cPass)

   RETURN Nil

STATIC FUNCTION Login_Click( xDlg )

   lLogin := .T.
   gui_DialogClose( xDlg )

   RETURN Nil

STATIC FUNCTION Cancel_Click( xDlg )

   IF gui_MsgYesNo( "Exit?" )
      lLogin := .F.
      gui_DialogClose( xDlg )
   ENDIF

   RETURN Nil
