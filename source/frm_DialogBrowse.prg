/*
frm_DialogBrowse - browse
*/

#include "frm_class.ch"

FUNCTION frm_DialogBrowse( Self, xDlg, xControl, cTable )

   LOCAL oTBrowse := {}, aItem, xValue, cField, nSelect, nPos, nIndexOrd

   IF ! ::lIsSQL
      nSelect := Select()
      SELECT ( cTable )
      nIndexOrd := IndexOrd()
   ENDIF

   // check begin if is defined a order to browse
   nPos := hb_Ascan( ::aAllSetup, { | e | e[1] == cTable } )
   IF nPos != 0 .AND. ::aAllSetup[ nPos, 3 ] != Nil
      IF ! ::lIsSQL
         SET ORDER TO ( ::aAllSetup[ nPos, 3 ] )
      ENDIF
   ENDIF
   // check end
   FOR EACH aItem IN ::aAllSetup[ nPos, 2 ]
      IF ! Empty( aItem[ CFG_FNAME ] ) // aItem[ CFG_CTLTYPE ] == TYPE_TEXT
         AAdd( oTBrowse, { aItem[ CFG_CAPTION ], aItem[ CFG_FNAME ], aItem[ CFG_FPICTURE ], ;
               aItem[ CFG_FTYPE ] } )
         IF aItem[ CFG_ISKEY ]
            cField := aItem[ CFG_FNAME ]
         ENDIF
      ENDIF
   NEXT

   DialogBrowse( oTBrowse, cTable, cField, @xValue )

   IF ! Empty( xValue ) .AND. ! Empty( xControl )
      GUI():ControlSetValue( xDlg, xControl, xValue )
   ENDIF
   IF ! ::lIsSQL
      SET ORDER TO ( nIndexOrd )
      SELECT ( nSelect )
   ENDIF
   GUI():SetFocus( ::xDlg )

   RETURN Nil

FUNCTION DialogBrowse( oTBrowse, cTable, cField, xValue )

   LOCAL oThisForm, aItem

   oThisForm := frm_Class():New()
   oThisForm:cOptions := ""
   oThisForm:lNavigate := .F.
   GUI():DialogCreate( @oThisForm:xDlg, 0, 0, APP_DLG_WIDTH, APP_DLG_HEIGHT, cTable,, .T. )
   frm_Button( oThisForm, .F. )
   AAdd( oThisForm:aControlList, EmptyFrmClassItem() )
   aItem := Atail( oThisForm:aControlList )
   aItem[ CFG_CTLTYPE ] := TYPE_BROWSE
   GUI():Browse( oThisForm:xDlg, oThisForm:xDlg, @aItem[ CFG_FCONTROL ], 70, 5, ;
      APP_DLG_WIDTH - 10, APP_DLG_HEIGHT - 115, ;
      oTbrowse, cField, @xValue, cTable, {}, oThisForm )
   IF GUI():LibName() == "HWGUI"
      aItem[ CFG_FCONTROL ]:lInFocus := .T.
   ENDIF
   // works for hmge from button
   GUI():SetFocus( oThisForm:xDlg, aItem[ CFG_FCONTROL ] )
   GUI():DialogActivate( oThisForm:xDlg, { || GUI():SetFocus( oThisForm:xDlg, aItem[ CFG_FCONTROL ] ) } )

   RETURN Nil
