#include "dbstruct.ch"
#include "directry.ch"
#include "hbclass.ch"

CREATE CLASS DlgAutoPrint

   METHOD Print()

   ENDCLASS

METHOD Print() CLASS DlgAutoPrint

   LOCAL aItem, nPag, nLin, nCol, nLen

   SET PRINTER TO ( "rel.lst" )
   SET DEVICE TO PRINT
   nPag := 0
   nLin := 99
   GOTO TOP
   DO WHILE ! Eof()
      IF nLin > 64
         nPag += 1
         @ 0, 0   SAY ::cFileDBF
         @ 0, 71 SAY "Page " + StrZero( nPag, 3 )
         @ 1, 0   SAY Replicate( "-", 80 )
         nLin := 2
         nCol := 0
         FOR EACH aItem IN ::aEditList // need additional adjust
            nLen = Max( Len( aItem[ DBS_NAME ] ), Len( Transform( FieldGet( FieldNum( aItem[ DBS_NAME ] ) ), "" ) ) )
            IF nCol != 0 .AND. nCol + nLen > 79
               nLin += 1
               nCol := 0
            ENDIF
            @ nLin, nCol SAY aItem[ DBS_NAME ]
            nCol += nLen + 2
         NEXT
         nLin += 1
      ENDIF
      nCol := 0
      FOR EACH aItem IN ::aEditList // need additional adjust
         nLen = Max( Len( aItem[ DBS_NAME ] ), Len( Transform( FieldGet( FieldNum( aItem[ DBS_NAME ] ) ), "" ) ) )
         IF nCol != 0 .AND. nCol + nLen > 79
            nLin += 1
            nCol := 0
         ENDIF
         @ nLin, nCol SAY Transform( FieldGet( FieldNum( aItem[ DBS_NAME ] ) ), "" )
         nCol += nLen + 2
      NEXT
      nLin += 1
      SKIP
   ENDDO

   SET DEVICE TO SCREEN
   SET PRINTER TO

   DlgAutoPreview( "rel.lst" )

   RETURN Nil

