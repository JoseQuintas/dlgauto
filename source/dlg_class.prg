#include "hbclass.ch"
#include "dlg_class.ch"

CREATE CLASS Dlg_Class

   VAR cTitle
   VAR cFileDBF
   VAR aEditList      INIT {}
   VAR cOptions       INIT "IED"
   VAR aOptionList    INIT {}

   VAR nEditStyle     INIT 1
   VAR nPageLimit     INIT 300
   VAR lWithTab       INIT .F.

   VAR nDlgWidth      INIT 1024
   VAR nDlgHeight     INIT 768
   VAR nLineHeight    INIT 25
   VAR nButtonSize    INIT 50
   VAR nButtonSpace   INIT 3
   VAR nTextSize      INIT 20
   VAR nControlHeight INIT 22

   VAR oDlg
   VAR aControlList   INIT {}

   METHOD CreateControls()     INLINE Dlg_CreateButton( Self ), Dlg_CreateEdit( Self )
   METHOD ButtonSaveOn()
   METHOD ButtonSaveOff()
   METHOD UpdateEdit()         INLINE Dlg_UpdateEdit( Self )
   METHOD EditOn()
   METHOD EditOff()
   METHOD Print()              INLINE Dlg_Print( Self )
   METHOD Execute()            INLINE Dlg_CreateDlg( Self )
   METHOD View()               INLINE Nil
   METHOD Edit()               INLINE ::EditOn()
   METHOD Delete()
   METHOD Insert()             INLINE Nil
   METHOD First()              INLINE &( ::cFileDbf )->( dbgotop() ),    ::UpdateEdit()
   METHOD Last()               INLINE &( ::cFileDbf )->( dbgobottom() ), ::UpdateEdit()
   METHOD Next()               INLINE &( ::cFileDbf )->( dbSkip() ),     ::UpdateEdit()
   METHOD Previous()           INLINE &( ::cFileDbf )->( dbSkip( -1 ) ), ::UpdateEdit()
   METHOD Exit()
   METHOD Save()
   METHOD Cancel()      INLINE ::EditOff(), ::UpdateEdit()

   ENDCLASS

METHOD ButtonSaveOn() CLASS Dlg_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_FNAME ] $ "Save,Cancel"
            aItem[ CFG_TOBJ ]:Enable()
         ELSE
            aItem[ CFG_TOBJ ]:Disable()
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD ButtonSaveOff() CLASS Dlg_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_BUTTON
         IF aItem[ CFG_FNAME ] $ "Save,Cancel"
            aItem[ CFG_TOBJ ]:Disable()
         ELSE
            aItem[ CFG_TOBJ ]:Enable()
         ENDIF
      ENDIF
   NEXT

   RETURN Nil

METHOD EditOn() CLASS Dlg_Class

   LOCAL aItem, oFirstEdit, lFound := .F.

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         aItem[ CFG_TOBJ ]:Enable()
         IF ! lFound
            lFound := .T.
            oFirstEdit := aItem[ CFG_TOBJ ]
         ENDIF
      ENDIF
   NEXT
   ::ButtonSaveOn()
   oFirstEdit:SetFocus()

   RETURN Nil

METHOD EditOff() CLASS Dlg_Class

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         aItem[ CFG_TOBJ ]:Disable()
      ENDIF
   NEXT
   ::ButtonSaveOff()

   RETURN Nil

METHOD Delete() CLASS dlg_Class

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

METHOD Save() CLASS dlg_Class

   LOCAL aItem

   ::EditOff()
   RLock()
   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF ! Empty( aItem[ CFG_FNAME ] )
            FieldPut( FieldNum( aItem[ CFG_FNAME ] ), aItem[ CFG_VALUE ] )
         ENDIF
      ENDIF
   NEXT
   SKIP 0
   UNLOCK

   RETURN Nil


METHOD Exit() CLASS dlg_Class

#ifdef HBMK_HAS_HWGUI
   ::oDlg:Close()
#endif

#ifdef HBMK_HAS_HMGE
   DoMethod( ::oDlg, "Release" )
#endif

   RETURN Nil
