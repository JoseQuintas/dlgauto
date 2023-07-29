#include "dlg_class.ch"

FUNCTION Dlg_UpdateEdit( Self )

   LOCAL aItem, nSelect, xValue, cText

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF ! Empty( aItem[ CFG_NAME ] )
            xValue := FieldGet( FieldNum( aItem[ CFG_NAME ] ) )

#ifdef HBMK_HAS_HWGUI
            aItem[ CFG_TOBJ ]:Value := xValue
#endif
#ifdef HBMK_HAS_HMGE
            SetProperty( ::oDlg, aItem[ CFG_TOBJ ], "VALUE", iif( ValType( xValue ) == "N", Ltrim( Str( xValue ) ), xValue ) )
#endif

         ENDIF
         IF ! Empty( aItem[ CFG_VTABLE ] )
            nSelect := Select()
            SELECT ( Select( aItem[ CFG_VTABLE ] ) )
            SEEK xValue
            cText := &( aItem[ CFG_VTABLE ] )->( FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) ) )

#ifdef HBMK_HAS_HWGUI
            aItem[ CFG_VOBJ ]:SetText( cText )
            aItem[ CFG_VOBJ ]:Refresh()
#endif
#ifdef HBMK_HAS_HMGE
            SetProperty( ::oDlg, aItem[ CFG_VOBJ ], "VALUE", cText )
#endif

            SELECT ( nSelect )
         ENDIF
      ENDIF
   NEXT
   (cText)

   RETURN Nil

