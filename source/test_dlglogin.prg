/*
test_DlgLogin - login
*/

#include "frm_class.ch"

MEMVAR lLogin, cUser, cPass

FUNCTION test_DlgLogin()

   LOCAL xDlg, aControl := Array(6), aItem

   FOR EACH aItem IN aControl
      aItem := EmptyFrmClassItem()
   NEXT

   gui_DialogCreate( @xDlg, 0, 0, 300, 200, "Login",, .T. )

   gui_LabelCreate( xDlg, @aControl[1][CFG_FNAME], APP_LINE_SPACING, 20, 80, APP_LINE_HEIGHT, "User" )
   gui_TextCreate( xDlg, @aControl[2][CFG_FNAME], APP_LINE_SPACING, 90, 170, APP_LINE_HEIGHT, cUser,,,,,,aControl[2] )
   gui_LabelCreate( xDlg, @aControl[3][CFG_FNAME], 2 * APP_LINE_SPACING, 20, 80, APP_LINE_HEIGHT, "Password" )
   gui_TextCreate( xDlg, @aControl[4][CFG_FNAME], 2 * APP_LINE_SPACING, 90, 170, APP_LINE_HEIGHT, cPass,,,,,,aControl[4],,.T. )
   gui_ButtonCreate( xDlg, @aControl[5][CFG_FNAME], 4 * APP_LINE_SPACING, 85, 50, APP_LINE_SPACING, "Login",, { || Login_Click( xDlg ) } )
   gui_ButtonCreate( xDlg, @aControl[6][CFG_FNAME], 4 * APP_LINE_SPACING, 155, 50, APP_LINE_SPACING, "Cancel",, { || Cancel_Click( xDlg ) } )
   //gui_SetFocus( xDlg, aControl[2][CFG_FNAME] )

   gui_DialogActivate( xDlg )

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
