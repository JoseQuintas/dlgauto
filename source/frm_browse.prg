/*
frm_browse - browse
*/

#include "frm_class.ch"

FUNCTION frm_Browse( Self, cTable, ... )

   LOCAL oTBrowse := {}, aItem, aField, cKeyboard := ""

   FOR EACH aItem IN ::aAllSetup
      IF aItem[1] == cTable
         FOR EACH aField IN aItem[2]
            AAdd( oTBrowse, { aField[ CFG_CAPTION ], Transform( aField[ CFG_FNAME ], aField[ CFG_FPICTURE ] ) } )
            IF aField[ CFG_ISKEY ]
               cKeyboard := aField[ CFG_FNAME ]
            ENDIF
         NEXT
      ENDIF
   NEXT
   (cKeyboard)

   RETURN Nil
