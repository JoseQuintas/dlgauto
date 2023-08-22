/*
frm_Edit - Create textbox/label on dialog
*/

#include "hbclass.ch"
#include "frm_class.ch"

FUNCTION frm_Edit( Self )

   LOCAL nRow, nCol, aItem, oTab, nPageCount := 0, nLen, aList := {}
   LOCAL nLenList, nRow2, nCol2 // oPanel

#ifdef HBMK_HAS_HWGUI
   LOCAL nPageNext, nTab

#endif

   FOR EACH aItem IN ::aEditList
      aItem[ CFG_VALUE ]    := &( ::cFileDbf )->( FieldGet( FieldNum( aItem[ CFG_FNAME ] ) ) )
      AAdd( ::aControlList, AClone( aItem ) )
   NEXT
   IF ::lWithTab

      gui_CreateTab( ::oDlg, @oTab, 70, 5, ::nDlgWidth - 19, ::nDlgHeight - 75 )
      AAdd( ::aControlList, CFG_EMPTY )
      Atail( ::aControlList )[ CFG_CTLTYPE ]  := TYPE_TAB
      Atail( ::aControlList )[ CFG_FCONTROL ] := oTab

      //CreatePanel( oTab, @oPanel, 23, 1, ::nDlgWidth - 25, ::nDlgHeight - 100 )
      //AAdd( ::aControlList, CFG_EMPTY )
      //Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_PANEL
      //Atail( ::aControlList )[ CFG_FCONTROL ] := oPanel
      nRow := 999
   ELSE
      nRow := 80
   ENDIF
   nCol := 10
   nLenList := Len( ::aControlList )
   FOR EACH aItem IN ::aControlList
      IF aItem:__EnumIndex > nLenList
         EXIT
      ENDIF
      IF aItem[ CFG_CTLTYPE ] != TYPE_EDIT
         LOOP
      ENDIF
      IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
         nLen := Len( aItem[ CFG_CAPTION ] ) + aItem[ CFG_FLEN ] + 1 + ;
            iif( Empty( aItem[ CFG_VTABLE ] ), 0, aItem[ CFG_VLEN ] + 4 )
      ELSE
         nLen := Max( aItem[ CFG_FLEN ] + 1 + iif( Empty( aItem[ CFG_VTABLE ] ), 0, aItem[ CFG_VLEN ] + 4 ), ;
            Len( aItem[ CFG_CAPTION ] ) )
      ENDIF
      IF ::nEditStyle == 1 .OR. ( nCol != 10 .AND. nCol + 30 + ( nLen * 12 ) > ::nDlgWidth - 40 ) .OR. ;
         ( nRow > ::nPageLimit .AND. ::lWithTab )
         IF ::lWithTab .AND. nRow > ::nPageLimit
            IF nPageCount > 0
               gui_PageEnd( ::oDlg, oTab )
            ENDIF
            nPageCount += 1
            gui_PageBegin( ::oDlg, oTab, "Pag." + Str( nPageCount, 2 ) )
            nRow := 40
            AAdd( aList, {} )
         ENDIF
         nCol := 10
         nRow += ( ::nLineSpacing * iif( ::nEditStyle < 3, 2, 3 ) )
      ENDIF
      IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
         nRow2 := nRow
         nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 )
      ELSE
         nRow2 := nRow + ::nLineSpacing
         nCol2 := nCol
      ENDIF
      gui_CreateLabel( iif( ::lWithTab, oTab, ::oDlg ), @aItem[ CFG_CCONTROL ], ;
         nRow, nCol, nLen * 12, ::nLineHeight, aItem[ CFG_CAPTION ], .F. )

      gui_CreateText( iif( ::lWithTab, oTab, ::oDlg ), @aItem[ CFG_FCONTROL ], ;
         nRow2, nCol2, aItem[ CFG_FLEN ] * 12 + 12, ::nLineHeight, ;
         @aItem[ CFG_VALUE ], aItem[ CFG_FPICTURE ], aitem[ CFG_FLEN ], ;
         { || ::Validate( aItem ) } )
      nCol += ( nLen + 3 ) * 12
      IF ::lWithTab
         AAdd( Atail( aList ), aItem[ CFG_FCONTROL ] )
      ENDIF
      IF ! Empty( aItem[ CFG_VTABLE ] )
         gui_CreateLabel( iif( ::lWithTab, oTab, ::oDlg ), @aItem[ CFG_VCONTROL ], ;
            nRow2, nCol2 + ( ( aItem[ CFG_FLEN ] + 4 ) * 12 ), aItem[ CFG_VLEN ] * 12, ;
            ::nLineHeight, Space( aItem[ CFG_VLEN ] ), .T. )
         //nCol += ( aItem[ CFG_VLEN ] + 3 ) * 12
      ENDIF
   NEXT
#ifdef HBMK_HAS_HWGUI
   // ghost for Getlist
   AAdd( ::aControlList, CFG_EMPTY )
   gui_CreateText( ::oDlg, @Atail( ::aControlList )[ CFG_FCONTROL ], ;
      nRow, nCol, 0, 0, "", "", 0, { || .T. } )
#endif
   IF ::lWithTab
      gui_PageEnd( ::oDlg, oTab )
#ifdef HBMK_HAS_HWGUI
      FOR nTab = 1 TO Len( aList )
         nPageNext  := iif( nTab == Len( aList ), 1, nTab + 1 )
         SetLostFocus( aList[ nTab, Len( aList[ nTab ] ) /* *ghost* - 1 */ ], oTab, nPageNext, aList[ nPageNext, 1 ] )
      NEXT
#endif
      gui_TabEnd()
   ENDIF
   (nRow2)
   (nCol2)
   //hb_MemoWrit( "tela.txt", cTxt )

   RETURN Nil

/* tab navigation */

#ifdef HBMK_HAS_HWGUI
STATIC FUNCTION SetLostFocus( oEdit, oTab, nPageNext, oEditNext )

   oEdit:bLostFocus := { || oTab:ChangePage( nPageNext ), oTab:SetTab( nPageNext ), gui_SetFocus( Nil, oEditNext ), .T. }

   RETURN Nil
#endif

