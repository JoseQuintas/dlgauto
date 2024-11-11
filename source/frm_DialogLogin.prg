/*
frm_DialogLogin - login
*/

#include "frm_class.ch"
#ifdef HBMK_HAS_HMGE
#include "hmg.ch"
#endif

MEMVAR lLogin, cUser, cPass

FUNCTION frm_DialogLogin()

   LOCAL oFrm, aItem

#ifdef HBMK_HAS_HMGE
   SET WINDOW MAIN OFF
#endif
   oFrm := Frm_Class():New()

   WITH OBJECT oFrm

      :aControlList := Array( 6 )
      FOR EACH aItem IN :aControlList
         aItem := EmptyFrmClassItem()
      NEXT

      GUI():DialogCreate( Nil, @:xDlg, 0, 0, 300, 200, "Login",, .T. )

      GUI():LabelCreate(  :xDlg, :xDlg, @:aControlList[1][ CFG_FCONTROL ], APP_LINE_SPACING, 20, 80, APP_LINE_HEIGHT, "User" )
      GUI():TextCreate(   :xDlg, :xDlg, @:aControlList[2][ CFG_FCONTROL ], APP_LINE_SPACING, 90, 170, APP_LINE_HEIGHT, cUser,,,,,, :aControlList[2] )
      GUI():LabelCreate(  :xDlg, :xDlg, @:aControlList[3][ CFG_FCONTROL ], 2 * APP_LINE_SPACING, 20, 80, APP_LINE_HEIGHT, "Password" )
      GUI():TextCreate(   :xDlg, :xDlg, @:aControlList[4][ CFG_FCONTROL ], 2 * APP_LINE_SPACING, 90, 170, APP_LINE_HEIGHT, cPass,,,,,, :aControlList[4],,.T. )
      GUI():ButtonCreate( :xDlg, :xDlg, @:aControlList[5][ CFG_FCONTROL ], 4 * APP_LINE_SPACING, 85, 50, APP_LINE_SPACING, "Login",, { || Login_Click( :xDlg ) } )
      GUI():ButtonCreate( :xDlg, :xDlg, @:aControlList[6][ CFG_FCONTROL ], 4 * APP_LINE_SPACING, 155, 50, APP_LINE_SPACING, "Cancel",, { || Cancel_Click( :xDlg ) } )
      GUI():SetFocus( :xDlg, :aControlList[ 2 ][ CFG_FCONTROL ] )

      GUI():DialogActivate( :xDlg,, .T. )

   ENDWITH

#ifdef HBMK_HAS_HMGE
   SET WINDOW MAIN ON
#endif
   (cUser);(cPass)

   RETURN Nil

STATIC FUNCTION Login_Click( xDlg )

   lLogin := .T.
   GUI():DialogClose( xDlg )

   RETURN Nil

STATIC FUNCTION Cancel_Click( xDlg )

   IF GUI():MsgYesNo( "Exit?" )
      lLogin := .F.
      GUI():DialogClose( xDlg )
   ENDIF

   RETURN Nil
