/*
lib - select gui library source code
*/

THREAD STATIC oGUI

/* not a good option, debug will use lib.prg and not lib_xxxx.prg */

#ifdef HBMK_HAS_HWGUI
   #include "lib_hwgui.prg"
#endif

#ifdef HBMK_HAS_HMGE
   #include "lib_hmge.prg"
#endif

#ifdef HBMK_HAS_OOHG
   #include "lib_oohg.prg"
#endif

#ifdef HBMK_HAS_GTWVG
   #include "lib_gtwvg.prg"
#endif

#ifdef HBMK_HAS_HMG3
   #include "lib_hmg3.prg"
#endif

#ifdef HBMK_HAS_FIVEWIN
   #include "lib_fivewin.prg"
#endif

FUNCTION GUI( xValue )

   IF xValue != Nil
      oGUI := xValue
   ENDIF
   IF oGUI == Nil
#ifdef HBMK_HAS_HMGE
      oGUI := HMGEClass():New()
#endif
#ifdef HBMK_HAS_HMG3
      oGUI := HMG3Class():New()
#endif
#ifdef HBMK_HAS_OOHG
      oGUI := OOHGClass():New()
#endif
#ifdef HBMK_HAS_HWGUI
      oGUI := HWGUIClass():New()
#endif
#ifdef HBMK_HAS_FIVEWIN
      oGUI := FIVEWINClass():New()
#endif
   ENDIF

   RETURN oGUI

