#include "hbclass.ch"
#include "frm_class.ch"

FUNCTION frm_CreateEdit( Self )

   LOCAL nRow, nCol, aItem, oTab := Nil, nPageCount := 0, nLen, aList := {}, nLenList, nRow2, nCol2 // , cTxt := ""
#ifdef THIS_HWGUI
   LOCAL oPanel, nTab, nPageNext

   hwg_SetColorInFocus(.T., , hwg_ColorRGB2N(255,255,0) )
#endif

   FOR EACH aItem IN ::aEditList
      AAdd( ::aControlList, AClone( aItem ) )
      Atail( ::aControlList )[ CFG_VALUE ] := &( ::cFileDbf )->( FieldGet( FieldNum( aItem[ CFG_FNAME ] ) ) )
   NEXT
   IF ::lWithTab
#ifdef THIS_HWGUI
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
            nLen := Len( aItem[ CFG_CAPTION ] ) + aItem[ CFG_FLEN ] + 3 + iif( Empty( aItem[ CFG_VTABLE ] ), 0, aItem[ CFG_VLEN ] + 3 )
         ELSE
            nLen := Max( aItem[ CFG_FLEN ] + iif( Empty( aItem[ CFG_VTABLE ] ), 0, aItem[ CFG_VLEN ] + 3 ), Len( aItem[ CFG_CAPTION ] ) )
         ENDIF
         IF ::nEditStyle == 1 .OR. ( nCol != 10 .AND. nCol + 30 + ( nLen * 12 ) > ::nDlgWidth - 40 ) .OR. nRow > ::nPageLimit
            IF ::lWithTab .AND. nRow > ::nPageLimit
               IF nPageCount > 0

#ifdef THIS_HWGUI
                  //ghost for getlist
                  AAdd( ::aControlList, CFG_EDITEMPTY )
                  @ nCol, nRow GET Atail( ::aControlList )[ CFG_TOBJ ] VAR Atail( ::aControlList )[ CFG_VALUE ] ;
                     OF oTab SIZE 0, 0 STYLE WS_DISABLED
                  AAdd( Atail( aList ), Atail( ::aControlList )[ CFG_TOBJ ] )
                  END PAGE OF oTab
#endif

               ENDIF
               nPageCount += 1
#ifdef THIS_HWGUI
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

#ifdef THIS_HWGUI
         @ nCol, nRow SAY aItem[ CFG_CAPTION ] OF iif( ::lWithTab, oTab, ::oDlg ) SIZE nLen * 12, 20 COLOR COLOR_FORE TRANSPARENT
#endif
#ifdef THIS_HMGE
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
#ifdef THIS_OOHG
         WITH OBJECT aItem[ CFG_TOBJ ] := TLabel():Define()
            :Row := nRow
            :Col := nCol
            :Value := aItem[ CFG_CAPTION ]
            :AutoSize := .T.
            :Height := 20
            :Width := nLen * 12
         ENDWITH
#endif


#ifdef THIS_HWGUI
         @ nCol2, nRow2 GET aItem[ CFG_TOBJ ] ;
            VAR aItem[ CFG_VALUE ] OF iif( ::lWithTab, oTab, ::oDlg ) ;
            SIZE aItem[ CFG_FLEN ] * 12, 20 ;
            STYLE WS_DISABLED + iif( aItem[ CFG_FTYPE ] == "N", ES_RIGHT, ES_LEFT ) ;
            MAXLENGTH aItem[ CFG_FLEN ] ;
            PICTURE PictureFromValue( aItem )
#endif
#ifdef THIS_HMGE_NOT_VALID_HERE
         // ATENTION: FAIL
         @ nRow2, nCol2 TEXTBOX ( aItem[ CFG_OBJ ] ) PARENT ( ::oDlg ) HEIGHT 20 WIDTH aItem[ CFG_LEN ] * 12
            FONTNAME "verdana" NUMERIC .T. VALUE aItem[ CFG_VALUE ] MAXLENGTH aItem[ CFG_LEN ] ON CHANGE Nil
#endif
#ifdef THIS_HMGE_OR_OOHG
         DO CASE
         CASE aItem[ CFG_FTYPE ] == "N"
            aItem[ CFG_TOBJ ] := "Text" + Ltrim( Str( aItem:__EnumIndex ) )
            DEFINE TEXTBOX ( aItem[ CFG_TOBJ ] )
               PARENT ( ::oDlg )
               ROW nRow2
               COL nCol2
               HEIGHT    20
               WIDTH     aItem[ CFG_FLEN ] * 12
               FONTNAME "verdana"
               NUMERIC .T.
               VALUE     aItem[ CFG_VALUE ]
               MAXLENGTH aItem[ CFG_FLEN ]
               ON CHANGE Nil
            END TEXTBOX
         CASE aItem[ CFG_FTYPE ] == "D"
            aItem[ CFG_TOBJ ] := "Text" + Ltrim( Str( aItem:__EnumIndex ) )
            DEFINE TEXTBOX ( aItem[ CFG_TOBJ ] )
               PARENT ( ::oDlg )
               ROW nRow2
               COL nCol2
               HEIGHT    20
               WIDTH     aItem[ CFG_FLEN ] * 12
               DATE .T.
               VALUE     aItem[ CFG_VALUE ]
            END TEXTBOX
         OTHERWISE
            aItem[ CFG_TOBJ ] := "Text" + Ltrim( Str( aItem:__EnumIndex ) )
            DEFINE TEXTBOX ( aItem[ CFG_TOBJ ] )
               PARENT ( ::oDlg )
               ROW nRow2
               COL nCol2
               HEIGHT    20
               WIDTH     aItem[ CFG_FLEN ] * 12
               FONTNAME "verdana"
               VALUE     aItem[ CFG_VALUE ]
               MAXLENGTH aItem[ CFG_FLEN ]
            END TEXTBOX
         ENDCASE
#endif
#ifdef THIS_OOHG_OOP
         // not confirmed
         WITH OBJECT aItem[ CFG_TOBJ ] := TText():Define()
            :Row    := nRow2
            :Col    := nCol2
            :Width  := aItem[ CFG_FLEN ] * 12
            :Height := 20
            :Value  := aItem[ CFG_VALUE ]
         ENDWITH
#endif

         nCol += ( nLen + 3 ) * 12

#ifdef THIS_HWGUI
         IF ::lWithTab
            AAdd( Atail( aList ), aItem[ CFG_TOBJ ] )
         ENDIF
#endif


         IF ! Empty( aItem[ CFG_VTABLE ] )
#ifdef THIS_HWGUI
            @ nCol2 + ( ( aItem[ CFG_FLEN ] + 3 ) * 12 ), nRow2 SAY aItem[ CFG_VOBJ ] CAPTION Space( aItem[ CFG_VLEN ] ) OF ;
               iif( ::lWithTab, oTab, ::oDlg ) SIZE aItem[ CFG_VLEN ] * 12, 20 COLOR COLOR_FORE BACKCOLOR COLOR_BACK ;
               STYLE WS_BORDER
#endif
#ifdef THIS_HMGE
            aItem[ CFG_VOBJ ] := "LabelB" + Ltrim( Str( aItem:__EnumIndex ) )
            @ nRow2, nCol2 + ( ( aItem[ CFG_FLEN ] + 3 ) * 12 ) LABEL ( aItem[ CFG_VOBJ ] ) ;
               PARENT ( ::oDlg ) ;
               VALUE Space( aItem[ CFG_VLEN ] ) WIDTH aItem[ CFG_VLEN ] * 12 HEIGHT 20 ;
               BORDER
#endif
#ifdef THIS_OOHG
            WITH OBJECT aItem[ CFG_VOBJ ] := TLabel():Define()
               :Row := nRow2
               :Col := nCol2 + ( ( nLen + 3 ) * 12 )
               :Value := Space( aItem[ CFG_VLEN ] )
               :Height := 20
               :Width := aItem[ CFG_VLEN ] * 12
               //:Border := .T.
            ENDWITH
#endif
            nCol += ( aItem[ CFG_VLEN ] + 3 ) * 12
         ENDIF
      ENDIF
   NEXT
#ifdef THIS_HWGUI
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
   //hb_MemoWrit( "tela.txt", cTxt )

   RETURN Nil

#ifdef THIS_HWGUI
STATIC FUNCTION SetLostFocus( oEdit, oTab, nPageNext, oEditNext )

   oEdit:bLostFocus := { || oTab:ChangePage( nPageNext ), oTab:SetTab( nPageNext ), oEditNext:SetFocus(), .T. }

   RETURN Nil
#endif

#ifdef THIS_HWGUI
STATIC FUNCTION PictureFromValue( oValue )

   LOCAL cPicture, cType, nLen, nDec

   cType := oValue[ CFG_FTYPE ]
   nLen  := oValue[ CFG_FLEN ]
   nDec  := oValue[ CFG_FDEC ]
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