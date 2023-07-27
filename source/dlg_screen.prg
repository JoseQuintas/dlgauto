#include "hbclass.ch"
#include "dbstruct.ch"
#include "dlgauto.ch"

CREATE CLASS DlgAutoEdit

   VAR cTitle
   VAR cFileDBF
   VAR aEditList   INIT {}
   VAR lWithTab    INIT .F.
   VAR nLineHeight INIT 25
   VAR nEditStyle  INIT 1
   VAR nPageLimit  INIT 300
   METHOD EditUpdate()
   METHOD EditCreate()
   METHOD EditOn()
   METHOD EditOff()
   VAR oDlg

   ENDCLASS

METHOD EditCreate() CLASS DlgAutoEdit

   LOCAL nRow, nCol, aItem, oTab := Nil, nPageCount := 0, nLen, aList := {}, nLenList, nRow2, nCol2
#ifdef HBMK_HAS_HWGUI
   LOCAL oPanel, nTab, nPageNext

   hwg_SetColorInFocus(.T., , hwg_ColorRGB2N(255,255,0) )
#endif
#ifdef HBMK_HAS_HMGE
   LOCAL cMacro
#endif
#ifdef HBMK_HAS_OOHG
   LOCAL cMacro
#endif

   FOR EACH aItem IN ::aEditList
      AAdd( ::aControlList, AClone( aItem ) )
      //Atail( ::aControlList )[ CFG_NAME ]    := aItem[ DBS_NAME ]
      //Atail( ::aControlList )[ CFG_VALTYPE ] := aItem[ DBS_TYPE ]
      //Atail( ::aControlList )[ CFG_LEN ]     := aItem[ DBS_LEN ]
      //Atail( ::aControlList )[ CFG_DEC ]     := aItem[ DBS_DEC ]
      //Atail( ::aControlList )[ CFG_CAPTION ] := aItem[ 5 ]
      Atail( ::aControlList )[ CFG_VALUE ]   := &( ::cFileDbf )->( FieldGet( FieldNum( aItem[ DBS_NAME ] ) ) )
      //Atail( ::aControlList )[ CFG_VALID ]   := aItem[ 6 ]
      //Atail( ::aControlList )[ CFG_VTABLE ]  := aItem[ 7 ]
      //Atail( ::aControlList )[ CFG_VFIELD ]  := aItem[ 8 ]
      //Atail( ::aControlList )[ CFG_VSHOW ]   := aItem[ 9 ]
      //Atail( ::aControlList )[ CFG_VVALUE ]  := aItem[ 10 ]
   NEXT
   IF ::lWithTab
#ifdef HBMK_HAS_HWGUI
      @ 5, 70 TAB oTab ITEMS {} OF ::oDlg ID 101 SIZE ::nDlgWidth - 10, ::nDlgHeight - 140 STYLE WS_CHILD + WS_VISIBLE
      AAdd( ::aControlList, CFG_EDITEMPTY )
      Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_TAB
      Atail( ::aControlList )[ CFG_OBJ ]     := oTab

      @ 1, 23 PANEL oPanel OF oTab SIZE ::nDlgWidth - 12, ::nDlgHeight - 165 BACKCOLOR STYLE_BACK
      AAdd( ::aControlList, CFG_EDITEMPTY )
      Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_PANEL
      Atail( ::aControlList )[ CFG_OBJ ]     := oPanel
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
                  @ nCol, nRow GET Atail( ::aControlList )[ CFG_OBJ ] VAR Atail( ::aControlList )[ CFG_VALUE ] ;
                     OF oTab SIZE 0, 0 STYLE WS_DISABLED
                  AAdd( Atail( aList ), Atail( ::aControlList )[ CFG_OBJ ] )
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
         @ nCol, nRow SAY aItem[ CFG_CAPTION ] OF iif( ::lWithTab, oTab, ::oDlg ) SIZE nLen * 12, 20 COLOR STYLE_FORE TRANSPARENT
#endif
#ifdef HBMK_HAS_HMGE
         cMacro := "LabelA" + Ltrim( Str( aItem:__EnumIndex ) )
         DEFINE LABEL &cMacro
            PARENT ::oDlg
            COL nCol
            ROW nRow
            WIDTH nLen * 12
            HEIGHT 20
            VALUE aItem[ CFG_CAPTION ]
         END LABEL
#endif


#ifdef HBMK_HAS_HWGUI
         @ nCol2, nRow2 GET aItem[ CFG_OBJ ] ;
            VAR aItem[ CFG_VALUE ] OF iif( ::lWithTab, oTab, ::oDlg ) ;
            SIZE aItem[ CFG_LEN ] * 12, 20 ;
            STYLE WS_DISABLED + iif( aItem[ CFG_VALTYPE ] == "N", ES_RIGHT, ES_LEFT ) ;
            MAXLENGTH aItem[ CFG_LEN ] ;
            PICTURE PictureFromValue( aItem )
#endif
#ifdef HBMK_HAS_HMGE
         cMacro := "Text" + Ltrim( Str( aItem:__EnumIndex ) )
         aItem[ CFG_CTLNAME ] := cMacro
         @ nRow2, nCol2 TEXTBOX &cMacro ;
            PARENT ::oDlg ;
            HEIGHT 20 ;
            WIDTH aItem[ CFG_LEN ] * 12 ;
            VALUE "" ; // aItem[ CFG_VALUE ] ;
            MAXLENGTH aItem[ CFG_LEN ] ;
            FONT "verdana" SIZE 12 ;
            UPPERCASE
            ON CHANGE Nil
#endif
#ifdef HBMK_HAS_OOHG
         cMacro := "Text" + Ltrim( Str( aItem:__EnumIndex ) )
         aItem[ CFG_CTLNAME ] := cMacro
         @ nRow2, nCol2 TEXTBOX &cMacro ;
            PARENT ::oDlg ;
            HEIGHT 20 ;
            WIDTH aItem[ CFG_LEN ] * 12 ;
            VALUE "" ; // aItem[ CFG_VALUE ] ;
            MAXLENGTH aItem[ CFG_LEN ] ;
            FONT "verdana" SIZE 12 ;
            UPPERCASE
            ON CHANGE Nil
#endif

            nCol += ( nLen * 12 ) + 30

#ifdef HBMK_HAS_HWGUI
         IF ::lWithTab
            AAdd( Atail( aList ), aItem[ CFG_OBJ ] )
         ENDIF
#endif


         IF ! Empty( aItem[ CFG_VTABLE ] )
#ifdef HBMK_HAS_HWGUI
            @ nCol2 + ( ( aItem[ CFG_LEN ] + 3 ) * 12 ), nRow2 SAY aItem[ CFG_VOBJ ] CAPTION aItem[ CFG_VVALUE ] OF ;
               iif( ::lWithTab, oTab, ::oDlg ) SIZE Len( aItem[ CFG_VVALUE ] ) * 12, 20 COLOR STYLE_FORE ;
               STYLE WS_BORDER TRANSPARENT
#endif
#ifdef HBMK_HAS_HMGE
            cMacro := "LabelB" + Ltrim( Str( aItem:__EnumIndex ) )
            aItem[ CFG_VCTLNAME ] := cMacro
            DEFINE LABEL &cMacro
               PARENT ::oDlg
               COL nCol2 + ( ( aItem[ CFG_LEN ] + 3 ) * 12 )
               ROW nRow2
               VALUE aItem[ CFG_VVALUE ]
               WIDTH Len( aItem[ CFG_VVALUE ] ) * 12
               HEIGHT 20
               BORDER .T.
#endif
#ifdef HBMK_HAS_OOHG
            cMacro := "LabelB" + Ltrim( Str( aItem:__EnumIndex ) )
            aItem[ CFG_VCTLNAME ] := cMacro
            DEFINE LABEL &cMacro
               PARENT ::oDlg
               COL nCol2 + ( ( aItem[ CFG_LEN ] + 3 ) * 12 )
               ROW nRow2
               VALUE aItem[ CFG_VVALUE ]
               WIDTH Len( aItem[ CFG_VVALUE ] ) * 12
               HEIGHT 20
               BORDER .T.
#endif
         ENDIF
      ENDIF
   NEXT
#ifdef HBMK_HAS_HWGUI
   // ghost for Getlist
   AAdd( ::aControlList, CFG_EDITEMPTY )
   @ nCol, nRow GET Atail( ::aControlList )[ CFG_OBJ ] VAR Atail( ::aControlList )[ CFG_VALUE ] ;
      OF iif( ::lWithTab, oTab, ::oDlg ) SIZE 0, 0 STYLE WS_DISABLED
   IF ::lWithTab
      AAdd( ATail( aList ), Atail( ::aControlList )[ CFG_OBJ ] )
      END PAGE OF oTab
      FOR nTab = 1 TO Len( aList )
         nPageNext  := iif( nTab == Len( aList ), 1, nTab + 1 )
         SetLostFocus( aList[ nTab, Len( aList[ nTab ] ) - 1 ], oTab, nPageNext, aList[ nPageNext, 1 ] )
      NEXT
   ENDIF
#endif
   (nRow2)
   (nCol2)
   RETURN Nil

METHOD EditOn() CLASS DlgAutoEdit

   LOCAL aItem, oFirstEdit, lFound := .F.

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         aItem[ CFG_OBJ ]:Enable()
         IF ! lFound
            lFound := .T.
            oFirstEdit := aItem[ CFG_OBJ ]
         ENDIF
      ENDIF
   NEXT
   ::ButtonSaveOn()
   oFirstEdit:SetFocus()

   RETURN Nil

METHOD EditOff() CLASS DlgAutoEdit

   LOCAL aItem

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         aItem[ CFG_OBJ ]:Disable()
      ENDIF
   NEXT
   ::ButtonSaveOff()

   RETURN Nil

METHOD EditUpdate() CLASS DlgAutoEdit

   LOCAL aItem, nSelect

   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF ! Empty( aItem[ CFG_NAME ] )

#ifdef HBMK_HAS_HWGUI
            aItem[ CFG_OBJ ]:Value := FieldGet( FieldNum( aItem[ CFG_NAME ] ) )
            aItem[ CFG_OBJ ]:Refresh()
#endif
#ifdef HBMK_HAS_HMGE
//            SetProperty( "::Dlg", aItem[ CFG_CTLNAME ], "VALUE", FieldGet( FieldNum( aItem[ CFG_NAME ] ) ) )
#endif

         ENDIF
         IF ! Empty( aItem[ CFG_VTABLE ] )
            nSelect := Select()
            SELECT ( Select( aItem[ CFG_VTABLE ] ) )

#ifdef HBMK_HAS_HWGUI
            SEEK aItem[ CFG_OBJ ]:Value
            aItem[ CFG_VOBJ ]:SetText( &( aItem[ CFG_VTABLE ] )->( FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) ) ) )
            aItem[ CFG_VOBJ ]:Refresh()
#endif
#ifdef HBMK_HAS_HMGE
            //SEEK GetProperty( "::Dlg", aItem[ CFG_CTLNAME ], "VALUE" )
            //SetProperty( "::Dlg", aItem[ CFG_VCTLNAME ], "VALUE", &( aItem[ CFG_VTABLE ] )->( FieldGet( FieldNum( aItem[ CFG_VSHOW ] ) ) ) )
#endif

            SELECT ( nSelect )
         ENDIF
      ENDIF
   NEXT

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
