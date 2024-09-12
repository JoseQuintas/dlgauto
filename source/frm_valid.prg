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
      IF ::lIsSQL
         ::cnSQL:cSQL := "SELECT * FROM " + ::cDataTable + ;
            " WHERE " + ::cDataField + " = " + hb_ValToExp( xValue )
         ::cnSQL:Execute()
         IF ::cSelected == "INSERT"
            IF ! ::cnSQL:Eof()
               GUI():Msgbox( "Code already exists" )
               GUI():SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
               ::cnSQL:CloseRecordset()
               RETURN .F.
            ENDIF
         ELSE
            IF ::cnSQL:Eof()
               GUI():Msgbox( "Code not found" )
               GUI():SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
               ::cnSQL:CloseRecordset()
               RETURN .F.
            ENDIF
         ENDIF
         ::cnSQL:CloseRecordset()
         IF ::cSelected == "INSERT"
            ::cnSQL:cSQL := "INSERT INTO " + ::cDataTable + " ( " + ::cDataField + " ) VALUES " + ;
               " ( " + hb_ValToExp( xValue ) + ")"
            ::cnSQL:ExecuteNoReturn()
         ENDIF
      ELSE
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
      ENDIF
      ::DataLoad()
      GUI():ControlSetValue( ::xDlg, aItem[ CFG_FCONTROL ], xValue )
      ::EditOn()
   ELSEIF ! Empty( aItem[ CFG_VTABLE ] )
      IF ::lisSQL
         ::cnSQL:cSQL := "SELEC COUNT(*)"
         IF ! Empty( aItem[ CFG_VSHOW ] )
            ::cnSQL:cSQL += ", " + aItem[ CFG_VSHOW ]
         ENDIF
         ::cnSQL:cSQL += " WHERE " + aItem[ CFG_VFIELD ] + " = " + hb_ValToExp( xValue )
         ::cnSQL:Execute()
         lFound := ! ::cnSQL:Eof()
         IF ! lFound
            IF GUI():MsgYesNo( "Code does not exists. Create new one?" )
               frm_Main( aItem[ CFG_VTABLE ], AClone( ::aAllSetup ), .T. )
            ENDIF
            //::Browse( ::xDlg, @aItem[ CFG_FCONTROL ], aItem[ CFG_VTABLE ] )
            GUI():SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
         ENDIF
         IF ! Empty( aItem[ CFG_VSHOW ] )
            xValue := ::cnSQL:Value( aItem[ CFG_VSHOW ] )
            GUI():ControlSetValue( ::xDlg, aItem[ CFG_VCONTROL ], xValue )
         ENDIF
         ::cnSQL:CloseRecordset()
      ELSE
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
   ENDIF

   RETURN lFound
