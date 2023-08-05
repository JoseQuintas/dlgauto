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

   METHOD CreateControls()     INLINE frm_CreateButton( Self ), frm_CreateEdit( Self )
   METHOD ButtonSaveOn()
   METHOD ButtonSaveOff()
   METHOD UpdateEdit()         INLINE frm_UpdateEdit( Self )
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
   METHOD Exit()
   METHOD Save()
   METHOD Cancel()             INLINE ::cSelected := "NONE", ::EditOff(), ::UpdateEdit()

   ENDCLASS

METHOD ButtonSaveOn() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_FNAME ] $ "Save,Cancel"
            aItem[ CFG_FCONTROL ]:Enable()
         ELSE
            aItem[ CFG_FCONTROL ]:Disable()
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD ButtonSaveOff() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_FNAME ] $ "Save,Cancel"
            aItem[ CFG_FCONTROL ]:Disable()
         ELSE
            aItem[ CFG_FCONTROL ]:Enable()
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD EditOn() CLASS frm_Class

   LOCAL aItem, oFirstEdit, lFound := .F.

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT .AND. ! aItem[ CFG_ISKEY ]
         aItem[ CFG_FCONTROL ]:Enable()
         IF ! lFound
            lFound := .T.
            oFirstEdit := aItem[ CFG_FCONTROL ]
         ENDIF
      ENDIF
   NEXT
   ::ButtonSaveOn()
   oFirstEdit:SetFocus()

   RETURN Nil

METHOD EditOff() CLASS frm_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         aItem[ CFG_FCONTROL ]:Disable()
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

METHOD Save() CLASS frm_Class

   LOCAL aItem

   ::EditOff()
   RLock()
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
   ::cSelected := "NONE"

   RETURN Nil

METHOD Exit() CLASS frm_Class

#ifdef CODE_HWGUI
   ::oDlg:Close()
#endif

#ifdef CODE_HMGE_OR_OOHG
   DoMethod( ::oDlg, "Release" )
#endif

   RETURN Nil
