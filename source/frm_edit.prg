/*
frm_Edit - Create textbox/label on dialog
*/

#include "hbclass.ch"
#include "frm_class.ch"

FUNCTION frm_Edit( Self )

   LOCAL nRow, nCol, aItem, xTab, nPageCount := 0, nLen, aList := {}
   LOCAL nRow2, nCol2, lFirst := .T., aBrowDbf, aBrowField, oTBrowse
   LOCAL aKeyCodeList, aDlgKeyCodeList := {}, xTabPage, nHeight

   FOR EACH aItem IN ::aEditList
      IF aItem[ CFG_CTLTYPE ] != Nil .AND. aItem[ CFG_CTLTYPE ] != TYPE_BROWSE
         aItem[ CFG_VALUE ]    := ( ::cFileDbf )->( FieldGet( FieldNum( aItem[ CFG_FNAME ] ) ) )
      ENDIF
      AAdd( ::aControlList, AClone( aItem ) )
   NEXT
   IF ::lWithTab
      gui_TabCreate( ::xDlg, @xTab, 70, 5, ::nDlgWidth - 19, ::nDlgHeight - 75 )
      AAdd( ::aControlList, CFG_EMPTY )
      Atail( ::aControlList )[ CFG_CTLTYPE ]  := TYPE_TAB
      Atail( ::aControlList )[ CFG_FCONTROL ] := xTab
      nRow := 999999
   ELSE
      nRow := 80
   ENDIF
   nCol := 10
   FOR EACH aItem IN ::aControlList
      nHeight := 1
      DO CASE
      CASE aItem[ CFG_CTLTYPE ] == TYPE_BROWSE
         nLen := ::nDlgWidth - 30
         nHeight := 6
      CASE aItem[ CFG_CTLTYPE ] == TYPE_COMBOBOX
         IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
            nLen := ( Len( aItem[ CFG_CAPTION ] ) + aItem[ CFG_FLEN ] + 3 ) * 12
         ELSE
            nLen := ( Max( Len( aItem[ CFG_CAPTION ] ), aItem[ CFG_FLEN ] ) + 3 ) * 12
         ENDIF
      CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
         IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
            nLen := ( Len( aItem[ CFG_CAPTION ] ) + aItem[ CFG_FLEN ] + 3 ) * 12
         ELSE
            nLen := ( Max( Len( aItem[ CFG_CAPTION ] ), aItem[ CFG_FLEN ] ) + 3 ) * 12
         ENDIF

      CASE aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF aItem[ CFG_FLEN ] > 100
            aItem[ CFG_CTLTYPE ] := TYPE_EDITML
            nLen := ::nDlgWidth - 30
            nHeight := iif( aItem[ CFG_FTYPE ] == "M", 5, Round( aItem[ CFG_FLEN ] / 100, 0 ) )
         ELSE
            IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
               nLen := ( Len( aItem[ CFG_CAPTION ] ) + 1 + aItem[ CFG_FLEN ] + 3 ) * 12
            ELSE
               nLen := ( Max( Len( aItem[ CFG_CAPTION ] ), aItem[ CFG_FLEN ] ) + 3 ) * 12
            ENDIF
            IF ! Empty( aItem[ CFG_VTABLE ] )
               nLen += ( aItem[ CFG_VLEN ] + 3 ) * 12
            ENDIF
         ENDIF
      ENDCASE
      IF ::nEditStyle == 1 .OR. ( nCol != 10 .AND. nCol + 30 + nLen > ::nDlgWidth - 40 )
         IF ! lFirst
            nRow += ( ::nLineSpacing * iif( ::nEditStyle < 3, 2, 3 ) )
         ENDIF
         nCol := 10
      ENDIF
      IF ::lWithTab .AND. nRow + ( ( nHeight + iif( ::nEditStyle < 3, 2, 3 ) ) * ::nLineSpacing  ) > ::nDlgHeight - 100
         IF nPageCount > 0
            gui_TabPageEnd( ::xDlg, xTab, xTabPage )
         ENDIF
         nPageCount += 1
         gui_TabPageBegin( ::xDlg, xTab, @xTabPage, nPageCount, "Pag." + Str( nPageCount, 2 ) )
      AAdd( ::aControlList, CFG_EMPTY )
      Atail( ::aControlList )[ CFG_CTLTYPE ]  := TYPE_TABPAGE
      Atail( ::aControlList )[ CFG_FCONTROL ] := xTabPage
         nRow := 40
         AAdd( aList, {} )
         lFirst := .T.
         (lFirst)
      ENDIF
      DO CASE
      CASE aItem[ CFG_CTLTYPE ] == TYPE_BROWSE
         SELECT  ( Select( aItem[ CFG_BRWTABLE ] ) )
         oTBrowse := {}
         FOR EACH aBrowDBF IN ::aAllSetup
            IF aBrowDBF[ 1 ] == aItem[ CFG_BRWTABLE ]
               FOR EACH aBrowField IN aBrowDbf[ 2 ]
                  IF ! aBrowField[ CFG_FNAME ] == aItem[ CFG_BRWKEYTO ] .AND. aBrowField[ CFG_CTLTYPE ] != TYPE_BROWSE
                     AAdd( oTBrowse, { aBrowField[ CFG_CAPTION ], aBrowField[ CFG_FNAME ], aBrowField[ CFG_FPICTURE ] } )
                  ENDIF
               NEXT
               EXIT
            ENDIF
         NEXT
#ifdef HBMK_HAS_GTWVG
         aKeyCodeList := {}
#else
         IF aItem[ CFG_BRWEDIT ]
            aKeyCodeList := { ;
               { VK_INSERT, { || gui_MsgBox( "INSERT " + aItem[ CFG_BRWTABLE ] ) } }, ;
               { VK_DELETE, { || gui_MsgBox( "DELETE " + aItem[ CFG_BRWTABLE ] ) } }, ;
               { VK_RETURN, { || gui_MsgBox( "EDIT "   + aItem[ CFG_BRWTABLE ] ) } } }
         ELSE
            aKeyCodeList := {}
         ENDIF
#endif
         gui_Browse( ::xDlg, xTabPage, @aItem[ CFG_FCONTROL ], nRow, 5, ;
            ::nDlgWidth - 30, nHeight * ::nLineHeight, ;
            oTbrowse, Nil, Nil, aItem[ CFG_BRWTABLE ], aKeyCodeList, @aDlgKeyCodeList )
         SELECT ( Select( ::cFileDBF ) )
         nRow += ( ( nHeight + iif( ::nEditStyle < 3, 2, 3 ) ) * ::nLineSpacing  )

      CASE aItem[ CFG_CTLTYPE ] == TYPE_EDITML
         nRow2 := nRow + ::nLineSpacing
         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow, nCol, nLen * 12, ::nLineHeight, aItem[ CFG_CAPTION ], .F. )
         gui_MLTextCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, 5, ::nDlgWidth-30, nHeight * ::nLineHeight, @aItem[ CFG_VALUE ] )
         nRow += ( ( nHeight + iif( ::nEditStyle < 3, 2, 3 ) ) * ::nLineSpacing  )

      CASE aItem[ CFG_CTLTYPE ] == TYPE_COMBOBOX
         IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 + 30 )
         ELSE
            nRow2 := nRow + ::nLineSpacing
            nCol2 := nCol
         ENDIF

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow, nCol, nLen * 12, ::nLineHeight, aItem[ CFG_CAPTION ], .F. )
         gui_ComboCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, nLen, ::nLineHeight, aItem[ CFG_COMBOLIST ] )
         nCol += nLen

      CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
         IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 + 30 )
         ELSE
            nRow2 := nRow + ::nLineSpacing
            nCol2 := nCol
         ENDIF

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow, nCol, nLen * 12, ::nLineHeight, aItem[ CFG_CAPTION ], .F. )
         gui_CheckboxCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, nLen, ::nLineHeight )
         nCol += nLen

      CASE aItem[ CFG_CTLTYPE ] == TYPE_DATEPICKER
         IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 + 30 )
         ELSE
            nRow2 := nRow + ::nLineSpacing
            nCol2 := nCol
         ENDIF

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow, nCol, nLen * 12, ::nLineHeight, aItem[ CFG_CAPTION ], .F. )
         gui_DatePickerCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, nLen, ::nLineHeight, aItem[ CFG_VALUE ] ) // aItem[ CFG_FPICTURE ] )
         nCol += nLen

      CASE aItem[ CFG_CTLTYPE ] == TYPE_EDIT
         IF ::nEditStyle == 1 .OR. ::nEditStyle == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 )
         ELSE
            nRow2 := nRow + ::nLineSpacing
            nCol2 := nCol
         ENDIF
         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow, nCol, Len( aItem[ CFG_CAPTION ] ) * 12 + 12, ::nLineHeight, aItem[ CFG_CAPTION ], .F. )

         gui_TextCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, aItem[ CFG_FLEN ] * 12 + 12, ::nLineHeight, ;
            @aItem[ CFG_VALUE ], aItem[ CFG_FPICTURE ], aitem[ CFG_FLEN ], ;
            { || ::Validate( aItem ) }, ;
            iif( aItem[ CFG_ISKEY ] .OR. ! Empty( aItem[ CFG_VTABLE ] ), { || gui_Msgbox( "click" ) }, Nil ), ;
            iif( aItem[ CFG_ISKEY ] .OR. ! Empty( aItem[ CFG_VTABLE ] ), "bmpsearch", Nil ) )
         IF ! Empty( aItem[ CFG_VTABLE ] ) .AND. ! Empty( aItem[ CFG_VSHOW ] )
            gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_VCONTROL ], ;
               nRow2, nCol2 + ( aItem[ CFG_FLEN ] * 12 + 42 ), aItem[ CFG_VLEN ] * 12, ;
               ::nLineHeight, Space( aItem[ CFG_VLEN ] ), .T. )
         ENDIF
         nCol := nCol + nLen + 30
      ENDCASE
      IF ::lWithTab
         IF ! aItem[ CFG_ISKEY ]
            AAdd( Atail( aList ), aItem[ CFG_FCONTROL ] )
         ENDIF
      ENDIF
      lFirst := .F.
   NEXT
#ifdef HBMK_HAS_HWGUI
   // dummy textbox to works last valid
   AAdd( ::aControlList, CFG_EMPTY )
   Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_HWGUIBUG
   gui_TextCreate( ::xDlg, @Atail( ::aControlList )[ CFG_FCONTROL ], ;
      nRow, nCol, 0, 0, "", "", 0, { || .T. } )
#endif
   IF ::lWithTab
      gui_TabPageEnd( ::xDlg, xTab )
      gui_TabNavigate( ::xDlg, xTab, aList )
      gui_TabEnd( xTab, nPageCount )
   ENDIF

   //AAdd( ::aControlList, CFG_EMPTY )
   //Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_STATUSBAR
   //gui_Statusbar( ::xDlg, @Atail( ::aControlList )[ CFG_FCONTROL ] )
   (nRow2)
   (nCol2)

   RETURN Nil
