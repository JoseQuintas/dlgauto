#include "frm_class.ch"

FUNCTION frm_UpdateEdit( Self )

   LOCAL aItem, nSelect, xValue, cText

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF ! Empty( aItem[ CFG_FNAME ] )
            xValue := FieldGet( FieldNum( aItem[ CFG_FNAME ] ) )

#ifdef CODE_HWGUI
            aItem[ CFG_FCONTROL ]:Value := xValue
#endif
#ifdef CODE_HMGE_OR_OOHG
            // NOTE: string value, except if declared different on textbox creation
            SetProperty( ::oDlg, aItem[ CFG_FCONTROL ], "VALUE", iif( ValType( xValue ) == "D", hb_Dtoc( xValue ), xValue ) )
#endif

         ENDIF
         IF ! Empty( aItem[ CFG_VTABLE ] )
            nSelect := Select()
            SELECT ( Select( aItem[ CFG_VTABLE ] ) )
            SEEK xValue
            cText := &( aItem[ CFG_VTABLE ] )->( FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) ) )

#ifdef CODE_HWGUI
            aItem[ CFG_VCONTROL ]:SetText( cText )
            aItem[ CFG_VCONTROL ]:Refresh()
#endif
#ifdef CODE_HMGE_OR_OOHG
            SetProperty( ::oDlg, aItem[ CFG_VCONTROL ], "VALUE", cText )
#endif

            SELECT ( nSelect )
         ENDIF
      ENDIF
   NEXT
   (cText)

   RETURN Nil

