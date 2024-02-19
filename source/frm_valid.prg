/*
frm_Valid - valid used on getbox, edit, textbox
*/

#include "frm_class.ch"

FUNCTION frm_Validate( aItem, Self )

   LOCAL nSelect, lFound := .T., xValue, nPos

   // if btn cancel abort validate (current on hwgui only)
   nPos := hb_AScan( ::aControlList, { | e | e[ CFG_CTLTYPE ] == TYPE_BUTTON .AND. ;
      e[ CFG_CAPTION ] == "Cancel" } )
   IF nPos != 0
      IF gui_IsCurrentFocus( ::xDlg, ::aControlList[ nPos, CFG_FCONTROL ] )
         RETURN .T.
      ENDIF
   ENDIF

   xValue := gui_TextGetValue( ::xDlg, aItem[ CFG_FCONTROL ] )
   IF aItem[ CFG_ISKEY ]
      IF aItem[ CFG_FTYPE ] == "C"
         SEEK Pad( xValue, aItem[ CFG_FLEN ] )
      ELSE
         SEEK xValue
      ENDIF
      IF ::cSelected == "INSERT"
         IF ! Eof()
            gui_Msgbox( "Code already exists" )
            gui_SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
            RETURN .F.
         ENDIF
      ELSE
         IF Eof()
            gui_Msgbox( "Code not found" )
            gui_SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
            RETURN .F.
         ENDIF
      ENDIF
      IF ::cSelected == "INSERT"
         APPEND BLANK
         FieldPut( FieldNum( aItem[ CFG_FNAME ] ), xValue )
         SKIP 0
      ENDIF
      ::UpdateEdit()
      gui_TextSetValue( ::xDlg, aItem[ CFG_FCONTROL ], xValue )
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
         frm_Browse( Self, ::xDlg, @aItem[ CFG_FCONTROL ], aItem[ CFG_VTABLE ] )
         gui_SetFocus( ::xDlg, aItem[ CFG_FCONTROL ] ) // minigui need this
      ENDIF
      IF ! Empty( aItem[ CFG_VSHOW ] )
         xValue := FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) )
         gui_LabelSetValue( ::xDlg, aItem[ CFG_VCONTROL ], xValue )
      ENDIF
      SELECT ( nSelect )
   ENDIF

   RETURN lFound
