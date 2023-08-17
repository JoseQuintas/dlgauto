/*
frm_Class - Class for data and bypass for functions
*/

#include "hbclass.ch"
#include "frm_class.ch"

CREATE CLASS frm_Class

   VAR cTitle
   VAR cFileDBF
   VAR aEditList       INIT {}
   VAR cOptions        INIT "IED"
   VAR aOptionList     INIT {}
   VAR cSelected       INIT "NONE"

   VAR nEditStyle      INIT 1
   VAR nPageLimit      INIT 300
   VAR lWithTab        INIT .F.

   VAR nDlgWidth       INIT 1024
   VAR nDlgHeight      INIT 768
   VAR nLineSpacing    INIT 21
   VAR nLineHeight     INIT 20
   VAR nButtonSize     INIT 50
   VAR nButtonSpace    INIT 3
   VAR nTextSize       INIT 15

   VAR oDlg
   VAR aControlList   INIT {}
   VAR aAllSetup      INIT {}

   METHOD CreateControls()     INLINE frm_Buttons( Self ), frm_Edit( Self )
   METHOD ButtonSaveOn()
   METHOD ButtonSaveOff()
   METHOD UpdateEdit()
   METHOD EditOn()
   METHOD EditOff()
   METHOD Print()              INLINE frm_Print( Self )
   METHOD Execute()            INLINE frm_Dialog( Self )
   METHOD View()               INLINE frm_Browse( Self, "", "", ::cFileDbf, Nil ), ::UpdateEdit()
   METHOD Edit()               INLINE ::cSelected := "EDIT", ::EditOn()
   METHOD Delete()
   METHOD Insert()             INLINE Nil
   METHOD First()              INLINE &( ::cFileDbf )->( dbgotop() ),    ::UpdateEdit()
   METHOD Last()               INLINE &( ::cFileDbf )->( dbgobottom() ), ::UpdateEdit()
   METHOD Next()               INLINE &( ::cFileDbf )->( dbSkip() ),     ::UpdateEdit()
   METHOD Previous()           INLINE &( ::cFileDbf )->( dbSkip( -1 ) ), ::UpdateEdit()
   METHOD Exit()               INLINE gui_CloseDialog( ::oDlg )
   METHOD Save()
   METHOD Cancel()             INLINE ::cSelected := "NONE", ::EditOff(), ::UpdateEdit()
   METHOD Validate( aItem )    INLINE frm_Validate( aItem, Self )
   METHOD Browse( ... )        INLINE frm_Browse( Self, ... )

   ENDCLASS

METHOD ButtonSaveOn() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_CAPTION ] $ "Save,Cancel"
            gui_EnableButton( ::oDlg, aItem[ CFG_FCONTROL ], .T. )
         ELSE
            gui_EnableButton( ::oDlg, aItem[ CFG_FCONTROL ], .F. )
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD ButtonSaveOff() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_CAPTION ] $ "Save,Cancel"
            gui_EnableButton( ::oDlg, aItem[ CFG_FCONTROL ], .F. )
         ELSE
            gui_EnableButton( ::oDlg, aItem[ CFG_FCONTROL ], .T. )
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD EditOn() CLASS frm_Class

   LOCAL aItem, oFirstEdit, lFound := .F.

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT .AND. ! aItem[ CFG_ISKEY ]
         gui_EnableTextbox( ::oDlg, aItem[ CFG_FCONTROL ], .T. )
         IF ! lFound
            lFound := .T.
            oFirstEdit := aItem[ CFG_FCONTROL ]
         ENDIF
      ENDIF
   NEXT
   ::ButtonSaveOn()
   gui_SetFocus( ::oDlg, oFirstEdit )

   RETURN Nil

METHOD EditOff() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         gui_EnableTextbox( ::oDlg, aItem[ CFG_FCONTROL ], .F. )
      ENDIF
   NEXT
   ::ButtonSaveOff()

   RETURN Nil

METHOD Delete() CLASS frm_Class

#ifdef HBMK_HAS_HWGUI
   IF hwg_MsgYesNo( "Delete" )
      IF rLock()
         DELETE
         SKIP 0
         UNLOCK
      ENDIF
   ENDIF
#endif
   RETURN Nil

METHOD UpdateEdit() CLASS frm_Class

   LOCAL aItem, nSelect, xValue, cText

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF ! Empty( aItem[ CFG_FNAME ] )
            xValue := FieldGet( FieldNum( aItem[ CFG_FNAME ] ) )
            gui_SetTextboxValue( ::oDlg, aItem[ CFG_FCONTROL ], xValue )
            IF ! Empty( aItem[ CFG_VTABLE ] )
               nSelect := Select()
               SELECT ( Select( aItem[ CFG_VTABLE ] ) )
               SEEK xValue
               cText := &( aItem[ CFG_VTABLE ] )->( FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) ) )
               SELECT ( nSelect )
               gui_SetLabelValue( ::oDlg, aItem[ CFG_VCONTROL ], cText )
            ENDIF
         ENDIF
      ENDIF
   NEXT
   (cText)

   RETURN Nil

METHOD Save() CLASS frm_Class

   LOCAL aItem

   ::EditOff()
   IF ::cSelected == "INSERT"
      APPEND BLANK
   ENDIF
   IF RLock()
      FOR EACH aItem IN ::aControlList
         IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
            IF ! Empty( aItem[ CFG_FNAME ] )
               IF ! aItem[ CFG_ISKEY ] .OR. ::cSelected == "INSERT"
                  FieldPut( FieldNum( aItem[ CFG_FNAME ] ), aItem[ CFG_VALUE ] )
               ENDIF
            ENDIF
         ENDIF
      NEXT
      SKIP 0
      UNLOCK
   ENDIF
   ::cSelected := "NONE"

   RETURN Nil
