/*
miscelaneous
workaround to found functions
Check the best to fit your needs
*/

FUNCTION RecLock()

   DO WHILE ! RLock()
      Inkey(0.3)
   ENDDO

   RETURN Nil

FUNCTION RecUnlock()

   SKIP 0
   UNLOCK

   RETURN Nil

FUNCTION RecAppend()

   APPEND BLANK

   RETURN Nil

FUNCTION MyTempFile( cExt )

   RETURN "TEMP" + iif( cExt == Nil, ".TMP", "." + cExt )

#if   defined( HBMK_HAS_FIVEWIN )
#elif defined( HBMK_HAS_HMGE )
#elif defined( HBMK_HAS_HMG3 )
#elif defined( HBMK_HAS_OOHG )
#else
FUNCTION MsgStop( cText )

   RETURN GUI():MsgBox( cText )
#endif

FUNCTION Errorsys_WriteErrorLog( cText )

   (cText)

   RETURN Nil
