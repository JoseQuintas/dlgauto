#include "hbclass.ch"
#include "dlg_class.ch"

FUNCTION Dlg_CreateEdit( Self )

   LOCAL nRow, nCol, aItem, oTab := Nil, nPageCount := 0, nLen, aList := {}, nLenList, nRow2, nCol2 // , cTxt := ""
#ifdef HBMK_HAS_HWGUI
   LOCAL oPanel, nTab, nPageNext

   hwg_SetColorInFocus(.T., , hwg_ColorRGB2N(255,255,0) )
#endif
#ifdef HBMK_HAS_OOHG
   LOCAL oControl
#endif

   FOR EACH aItem IN ::aEditList
      AAdd( ::aControlList, AClone( aItem ) )
      Atail( ::aControlList )[ CFG_VALUE ] := &( ::cFileDbf )->( FieldGet( FieldNum( aItem[ CFG_NAME ] ) ) )
   NEXT
   IF ::lWithTab
#ifdef HBMK_HAS_HWGUI
      @ 5, 70 TAB oTab ITEMS {} OF ::oDlg ID 101 SIZE ::nDlgWidth - 10, ::nDlgHeight - 140 STYLE WS_CHILD + WS_VISIBLE
      AAdd( ::aControlList, CFG_EDITEMPTY )
      Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_TAB
      Atail( ::aControlList )[ CFG_TOBJ ]     := oTab

      @ 1, 23 PANEL oPanel OF oTab SIZE ::nDlgWidth - 12, ::nDlgHeight - 165 BACKCOLOR COLOR_BACK
      AAdd( ::aControlList, CFG_EDITEMPTY )
      Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_PANEL
      Atail( ::aControlList )[ CFG_TOBJ ]     := oPanel
#endif
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
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
            nLen := Len( aItem[ CFG_CAPTION ] ) + aItem[ CFG_LEN ] + 3 + iif( Empty( aItem[ CFG_VTABLE ] ), 0, Len( aItem[ CFG_VVALUE ] ) + 3 )
         ELSE
            nLen := Max( aItem[ CFG_LEN ] + iif( Empty( aItem[ CFG_VTABLE ] ), 0, Len( aItem[ CFG_VVALUE ] ) + 3 ), Len( aItem[ CFG_CAPTION ] ) )
         ENDIF
         IF ::nEditStyle == 1 .OR. ( nCol != 10 .AND. nCol + 30 + ( nLen * 12 ) > ::nDlgWidth - 40 ) .OR. nRow > ::nPageLimit
            IF ::lWithTab .AND. nRow > ::nPageLimit
               IF nPageCount > 0

#ifdef HBMK_HAS_HWGUI
                  //ghost for getlist
                  AAdd( ::aControlList, CFG_EDITEMPTY )
                  @ nCol, nRow GET Atail( ::aControlList )[ CFG_TOBJ ] VAR Atail( ::aControlList )[ CFG_VALUE ] ;
                     OF oTab SIZE 0, 0 STYLE WS_DISABLED
                  AAdd( Atail( aList ), Atail( ::aControlList )[ CFG_TOBJ ] )
                  END PAGE OF oTab
#endif

               ENDIF
               nPageCount += 1
#ifdef HBMK_HAS_HWGUI
               BEGIN PAGE "Pag." + Str( nPageCount, 2 ) OF oTab
#endif
               nRow := 40
               AAdd( aList, {} )
            ENDIF
            nCol := 10
            nRow += ( ::nLineHeight * 2 )
         ENDIF
         IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 )
         ELSE
            nRow2 := nRow + ::nLineHeight
            nCol2 := nCol
         ENDIF

#ifdef HBMK_HAS_HWGUI
         @ nCol, nRow SAY aItem[ CFG_CAPTION ] OF iif( ::lWithTab, oTab, ::oDlg ) SIZE nLen * 12, 20 COLOR COLOR_FORE TRANSPARENT
#endif
#ifdef HBMK_HAS_HMGE
         aItem[ CFG_TOBJ ] := "LabelA" + Ltrim( Str( aItem:__EnumIndex ) )
         DEFINE LABEL ( aItem[ CFG_TOBJ ] )
            PARENT ( ::oDlg )
            COL nCol
            ROW nRow
            WIDTH nLen * 12
            HEIGHT 20
            VALUE aItem[ CFG_CAPTION ]
         END LABEL
#endif
#ifdef HBMK_HAS_OOHG
         WITH OBJECT oControl := TLabel():Define()
            :Row := nRow
            :Col := nCol
            :Value := aItem[ CFG_CAPTION ]
            :AutoSize := .T.
            :Height := 20
            :Width := nLen * 12
         ENDWITH
#endif


#ifdef HBMK_HAS_HWGUI
         @ nCol2, nRow2 GET aItem[ CFG_TOBJ ] ;
            VAR aItem[ CFG_VALUE ] OF iif( ::lWithTab, oTab, ::oDlg ) ;
            SIZE aItem[ CFG_LEN ] * 12, 20 ;
            STYLE WS_DISABLED + iif( aItem[ CFG_VALTYPE ] == "N", ES_RIGHT, ES_LEFT ) ;
            MAXLENGTH aItem[ CFG_LEN ] ;
            PICTURE PictureFromValue( aItem )
#endif
#ifdef HBMK_HAS_HMGE
         aItem[ CFG_TOBJ ] := "Text" + Ltrim( Str( aItem:__EnumIndex ) )
         @ nRow2, nCol2 TEXTBOX ( aItem[ CFG_TOBJ ] ) ;
            PARENT    ( ::oDlg ) ;
            HEIGHT    20 ;
            WIDTH     aItem[ CFG_LEN ] * 12 ;
            VALUE     aItem[ CFG_VALUE ] ;
            MAXLENGTH aItem[ CFG_LEN ] ;
            FONT      "verdana" SIZE 12 ;
            UPPERCASE
            ON CHANGE Nil
#endif
#ifdef HBMK_HAS_OOHG
         WITH OBJECT aItem[ CFG_TOBJ ] := TText():Define()
            :Row    := nRow2
            :Col    := nCol2
            :Width  := aItem[ CFG_LEN ] * 12
            :Height := 20
            :Value  := aItem[ CFG_VALUE ]
         ENDWITH
#endif

         nCol += ( nLen + 3 ) * 12

#ifdef HBMK_HAS_HWGUI
         IF ::lWithTab
            AAdd( Atail( aList ), aItem[ CFG_TOBJ ] )
         ENDIF
#endif


         IF ! Empty( aItem[ CFG_VTABLE ] )
#ifdef HBMK_HAS_HWGUI
            @ nCol2 + ( ( aItem[ CFG_LEN ] + 3 ) * 12 ), nRow2 SAY aItem[ CFG_VOBJ ] CAPTION aItem[ CFG_VVALUE ] OF ;
               iif( ::lWithTab, oTab, ::oDlg ) SIZE Len( aItem[ CFG_VVALUE ] ) * 12, 20 COLOR COLOR_FORE BACKCOLOR COLOR_BACK ;
               STYLE WS_BORDER
#endif
#ifdef HBMK_HAS_HMGE
            aItem[ CFG_VOBJ ] := "LabelB" + Ltrim( Str( aItem:__EnumIndex ) )
            @ nRow2, nCol2 + ( ( aItem[ CFG_LEN ] + 3 ) * 12 ) LABEL ( aItem[ CFG_VOBJ ] ) ;
               PARENT ( ::oDlg ) ;
               VALUE aItem[ CFG_VVALUE ] WIDTH Len( aItem[ CFG_VVALUE ] ) * 12 HEIGHT 20 ;
               BORDER
#endif
#ifdef HBMK_HAS_OOHG
            WITH OBJECT aItem[ CFG_VOBJ ] := TLabel():Define()
               :Row := nRow2
               :Col := nCol2 + ( ( nLen + 3 ) * 12 )
               :Value := aItem[ CFG_VVALUE ]
               :Height := 20
               :Width := Len( aItem[ CFG_VVALUE ] ) * 12
               :Border := .T.
            ENDWITH
#endif
            nCol += ( Len( aItem[ CFG_VVALUE ] ) + 3 ) * 12
         ENDIF
      ENDIF
   NEXT
#ifdef HBMK_HAS_HWGUI
   // ghost for Getlist
   AAdd( ::aControlList, CFG_EDITEMPTY )
   @ nCol, nRow GET Atail( ::aControlList )[ CFG_TOBJ ] VAR Atail( ::aControlList )[ CFG_VALUE ] ;
      OF iif( ::lWithTab, oTab, ::oDlg ) SIZE 0, 0 STYLE WS_DISABLED
   IF ::lWithTab
      AAdd( ATail( aList ), Atail( ::aControlList )[ CFG_TOBJ ] )
      END PAGE OF oTab
      FOR nTab = 1 TO Len( aList )
         nPageNext  := iif( nTab == Len( aList ), 1, nTab + 1 )
         SetLostFocus( aList[ nTab, Len( aList[ nTab ] ) - 1 ], oTab, nPageNext, aList[ nPageNext, 1 ] )
      NEXT
   ENDIF
#endif
   (nRow2)
   (nCol2)
#ifdef HBMK_HAS_OOHG
   (oControl)
#endif
   //hb_MemoWrit( "tela.txt", cTxt )

   RETURN Nil

#ifdef HBMK_HAS_HWGUI
STATIC FUNCTION SetLostFocus( oEdit, oTab, nPageNext, oEditNext )

   oEdit:bLostFocus := { || oTab:ChangePage( nPageNext ), oTab:SetTab( nPageNext ), oEditNext:SetFocus(), .T. }

   RETURN Nil
#endif

#ifdef HBMK_HAS_HWGUI
STATIC FUNCTION PictureFromValue( oValue )

   LOCAL cPicture, cType, nLen, nDec

   cType := oValue[ CFG_VALTYPE ]
   nLen  := oValue[ CFG_LEN ]
   nDec  := oValue[ CFG_DEC ]
   DO CASE
   CASE cType == "D"
      cPicture := "@D"
   CASE cType == "N"
      cPicture := Replicate( "9", nLen - nDec )
      IF nDec != 0
         cPicture += "." + Replicate( "9", nDec )
      ENDIF
   CASE cType == "M"
      cPicture := "@S100"
   CASE cType == "C"
      cPicture := iif( nLen > 100, "@S100", "@X" )
   ENDCASE

   RETURN cPicture
#endif
