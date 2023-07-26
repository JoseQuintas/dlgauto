
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
   CLOSE DATABASES

   RETURN Nil
