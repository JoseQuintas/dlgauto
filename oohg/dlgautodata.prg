#include "hbclass.ch"
#include "dbstruct.ch"
#include "dlgauto.ch"
#include "oohg.ch"

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
   METHOD Exit()        INLINE DoMethod( "::oDlg", "release" )
   METHOD Save()
   METHOD Cancel()      INLINE ::EditOff(), ::EditUpdate()
   VAR oDlg

   ENDCLASS

METHOD Delete() CLASS DlgAutoData

/*
   IF hwg_MsgYesNo( "Delete" )
      IF rLock()
         DELETE
         SKIP 0
         UNLOCK
      ENDIF
   ENDIF
*/

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
      IF ! Empty( aItem[ 7 ] )
         IF Select( aItem[ 7 ] ) == 0
            SELECT 0
            USE ( aItem[ 7 ] )
            SET INDEX TO ( aItem[ 7 ] )
            SET ORDER TO 1
         ENDIF
      ENDIF
   NEXT
   SELECT ( Select( ::cFileDbf ) )

   WITH OBJECT ::oDlg := TForm():Define()
      :Col := 1000
      :Row := 500
      :Width := ::nDlgWidth
      :Height := ::nDlgHeight
      :Title := ::cFileDBF
      //MODAL ;
      //ON INIT ::EditUpdate()

      ::ButtonCreate()
      ::EditCreate()

      :EndWindow()
      :Center()
      :Activate()
   ENDWITH
   CLOSE DATABASES

   RETURN Nil
