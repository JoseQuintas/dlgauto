#include "hbclass.ch"
#include "dbstruct.ch"
#include "dlgauto.ch"

CREATE CLASS DlgAutoData INHERIT DlgAutoBtn, DlgAutoEdit, DlgAutoPrint

   VAR nDlgWidth    INIT 1024
   VAR nDlgHeight   INIT 768
   VAR cTitle
   VAR cFileDBF
   VAR aEditList INIT {}
   METHOD Execute()
   METHOD View()        INLINE Nil
   METHOD Edit()        INLINE ::EditOn()
   METHOD Delete()
   METHOD Insert()      INLINE Nil
   METHOD First()       INLINE &( ::cFileDbf )->( dbgotop() ),    ::EditUpdate()
   METHOD Last()        INLINE &( ::cFileDbf )->( dbgobottom() ), ::EditUpdate()
   METHOD Next()        INLINE &( ::cFileDbf )->( dbSkip() ),     ::EditUpdate()
   METHOD Previous()    INLINE &( ::cFileDbf )->( dbSkip( -1 ) ), ::EditUpdate()

#ifdef HBMK_HAS_HWGUI
   METHOD Exit()        INLINE ::oDlg:Close()
#endif

#ifdef HBMK_HAS_HMGE
   METHOD Exit()        INLINE DoMethod( "::oDlg", "Release" )
#endif

   METHOD Save()
   METHOD Cancel()      INLINE ::EditOff(), ::EditUpdate()
   VAR oDlg

   ENDCLASS

METHOD Delete() CLASS DlgAutoData

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

METHOD Save() CLASS DlgAutoData

   LOCAL aItem

   ::EditOff()
   RLock()
   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF ! Empty( aItem[ CFG_NAME ] )
            FieldPut( FieldNum( aItem[ CFG_NAME ] ), aItem[ CFG_VALUE ] )
         ENDIF
      ENDIF
   NEXT
   SKIP 0
   UNLOCK

   RETURN Nil

METHOD Execute() CLASS DlgAutoData

   LOCAL aItem

   SELECT 0
   USE ( ::cFileDBF )
   FOR EACH aItem IN ::aEditList
      IF ! Empty( aItem[ CFG_VTABLE ] )
         IF Select( aItem[ CFG_VTABLE ] ) == 0
            SELECT 0
            USE ( aItem[ CFG_VTABLE ] )
            SET INDEX TO ( aItem[ CFG_VTABLE ] )
            SET ORDER TO 1
         ENDIF
      ENDIF
   NEXT
   SELECT ( Select( ::cFileDbf ) )

#ifdef HBMK_HAS_HWGUI
   INIT DIALOG ::oDlg CLIPPER NOEXIT TITLE ::cTitle ;
      AT 0, 0 SIZE ::nDlgWidth, ::nDlgHeight ;
      BACKCOLOR COLOR_BACK ;
      ON EXIT hwg_EndDialog() ;
      ON INIT { || ::EditUpdate() }
   ::ButtonCreate()
   ::EditCreate()
   ACTIVATE DIALOG ::oDlg CENTER
#endif
#ifdef HBMK_HAS_HMGE
   DEFINE WINDOW ::oDlg ;
      AT 1000, 500 ;
      WIDTH ::nDlgWidth ;
      HEIGHT ::nDlgHeight ;
      TITLE ::cFileDBF ;
      MODAL ;
      ON INIT ::EditUpdate()

      ::ButtonCreate()
      ::EditCreate()

   END WINDOW
   ::oDlg.CENTER
   ::oDlg.ACTIVATE
#endif
#ifdef HBMK_HAS_OOHG
   WITH OBJECT ::oDlg := TForm():Define()
      :Row := 500
      :Col := 1000
      :Width := ::nDlgWidth
      :Height := ::nDlgHeight
      :Title := ::cFileDbf
      // :Init := ::EditUpdate()
   ENDWITH
    _EndWindow()
      ::ButtonCreate()
      ::EditCreate()
   ::oDlg:Center()
   ::oDlg:Activate()
#endif
   CLOSE DATABASES

   RETURN Nil
