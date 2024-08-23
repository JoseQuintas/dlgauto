/*
frm_Valid - valid used on getbox, edit, textbox
called from frm_class
*/

#include "frm_class.ch"

FUNCTION frm_Valid( Self, aItem )

   LOCAL nSelect, lFound := .T., xValue, nPos

   // not ok for all libraries
   // IF ! GUI():LibName() $ "HWGUI,FIVEWIN" .AND. ! GUI():IsCurrentFocus( ::xDlg )
      //this affects external programs
      //GUI():MsgBox( "ENTER" )
      //GUI():SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] )
      //RETURN .F.
   // ENDIF

   // if btn cancel abort validate (current on hwgui only)
   nPos := hb_AScan( ::aControlList, { | e | e[ CFG_CTLTYPE ] == TYPE_BUTTON .AND. ;
      e[ CFG_CAPTION ] == "Cancel" } )
   IF nPos != 0
      IF GUI():IsCurrentFocus( ::xDlg, ::aControlList[ nPos, CFG_FCONTROL ] )
         RETURN .T.
      ENDIF
   ENDIF

   xValue := GUI():ControlGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
   IF aItem[ CFG_ISKEY ]
      IF aItem[ CFG_FTYPE ] == "C"
         SEEK Pad( xValue, aItem[ CFG_FLEN ] )
      ELSE
         SEEK xValue
      ENDIF
      IF ::cSelected == "INSERT"
         IF ! Eof()
            GUI():Msgbox( "Code already exists" )
            GUI():SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
            RETURN .F.
         ENDIF
      ELSE
         IF Eof()
            GUI():Msgbox( "Code not found " + alias() + " " + hb_ValToExp( xValue )  + ;
               " index " + Str( IndexOrd() ) )
            GUI():SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
            RETURN .F.
         ENDIF
      ENDIF
      IF ::cSelected == "INSERT"
         APPEND BLANK
         FieldPut( FieldNum( aItem[ CFG_FNAME ] ), xValue )
         SKIP 0
      ENDIF
      ::DataLoad()
      GUI():ControlSetValue( ::xDlg, aItem[ CFG_FCONTROL ], xValue )
      ::EditOn()
   ELSEIF ! Empty( aItem[ CFG_VTABLE ] )
      // if setup to find on another dbf
      nSelect := Select()
      SELECT ( Select( aItem[ CFG_VTABLE ] ) )
      IF aItem[ CFG_FTYPE ] == "C"
         SEEK Pad( xValue, aItem[ CFG_FLEN ] )
      ELSE
         SEEK xValue
      ENDIF
      lFound := ! Eof()
      IF ! lFound
         IF GUI():MsgYesNo( "Code does not exists. Create new one?" )
            frm_Main( aItem[ CFG_VTABLE ], AClone( ::aAllSetup ), .T. )
         ENDIF
         //::Browse( ::xDlg, @aItem[ CFG_FCONTROL ], aItem[ CFG_VTABLE ] )
         GUI():SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
      ENDIF
      IF ! Empty( aItem[ CFG_VSHOW ] )
         xValue := FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) )
         GUI():ControlSetValue( ::xDlg, aItem[ CFG_VCONTROL ], xValue )
      ENDIF
      SELECT ( nSelect )
   ENDIF

   RETURN lFound
