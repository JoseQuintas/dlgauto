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
   VAR nLineSpacing    INIT 25
   VAR nLineHeight     INIT 20
   VAR nButtonSize     INIT 50
   VAR nButtonSpace    INIT 3
   VAR nTextSize       INIT 20
   VAR nControlHeight  INIT 22

   VAR oDlg
   VAR aControlList   INIT {}

   METHOD CreateControls()     INLINE frm_Buttons( Self ), frm_CreateEdit( Self )
   METHOD ButtonSaveOn()
   METHOD ButtonSaveOff()
   METHOD UpdateEdit()
   METHOD EditOn()
   METHOD EditOff()
   METHOD Print()              INLINE frm_Print( Self )
   METHOD Execute()            INLINE frm_CreateFrm( Self )
   METHOD View()               INLINE Nil
   METHOD Edit()               INLINE ::cSelected := "EDIT", ::EditOn()
   METHOD Delete()
   METHOD Insert()             INLINE Nil
   METHOD First()              INLINE &( ::cFileDbf )->( dbgotop() ),    ::UpdateEdit()
   METHOD Last()               INLINE &( ::cFileDbf )->( dbgobottom() ), ::UpdateEdit()
   METHOD Next()               INLINE &( ::cFileDbf )->( dbSkip() ),     ::UpdateEdit()
   METHOD Previous()           INLINE &( ::cFileDbf )->( dbSkip( -1 ) ), ::UpdateEdit()
   METHOD Exit()               INLINE CloseDlg( ::oDlg )
   METHOD Save()
   METHOD Cancel()             INLINE ::cSelected := "NONE", ::EditOff(), ::UpdateEdit()
   METHOD Browse( ... )        INLINE frm_Browse( Self, ... )

   ENDCLASS

METHOD ButtonSaveOn() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_CAPTION ] $ "Save,Cancel"
            EnableButton( ::oDlg, aItem[ CFG_FCONTROL ], .T. )
         ELSE
            EnableButton( ::oDlg, aItem[ CFG_FCONTROL ], .F. )
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD ButtonSaveOff() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_CAPTION ] $ "Save,Cancel"
            EnableButton( ::oDlg, aItem[ CFG_FCONTROL ], .F. )
         ELSE
            EnableButton( ::oDlg, aItem[ CFG_FCONTROL ], .T. )
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD EditOn() CLASS frm_Class

   LOCAL aItem, oFirstEdit, lFound := .F.

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT .AND. ! aItem[ CFG_ISKEY ]
         EnableTextbox( ::oDlg, aItem[ CFG_FCONTROL ], .T. )
         IF ! lFound
            lFound := .T.
            oFirstEdit := aItem[ CFG_FCONTROL ]
         ENDIF
      ENDIF
   NEXT
   ::ButtonSaveOn()
   SetFocusAny( ::oDlg, oFirstEdit )

   RETURN Nil

METHOD EditOff() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         EnableTextbox( ::oDlg, aItem[ CFG_FCONTROL ], .F. )
      ENDIF
   NEXT
   ::ButtonSaveOff()

   RETURN Nil

METHOD Delete() CLASS frm_Class

#ifdef CODE_HWGUI
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
            UpdateTextbox( ::oDlg, aItem[ CFG_FCONTROL ], xValue )
         ENDIF
         IF ! Empty( aItem[ CFG_VTABLE ] )
            nSelect := Select()
            SELECT ( Select( aItem[ CFG_VTABLE ] ) )
            SEEK xValue
            cText := &( aItem[ CFG_VTABLE ] )->( FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) ) )
            SELECT ( nSelect )
            UpdateLabel( ::oDlg, aItem[ CFG_VCONTROL ], cText )
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
