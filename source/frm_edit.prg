/*
frm_Edit - Create textbox/label on dialog
*/

#include "hbclass.ch"
#include "frm_class.ch"
#ifndef VK_INSERT
   #define VK_INSERT  45
   #define VK_DELETE  46
   #define VK_RETURN  13
#endif

FUNCTION frm_Edit( Self )

   LOCAL nRow, nCol, aItem, xTab, nPageCount := 0, nLen, aList := {}
   LOCAL nRow2, nCol2, lFirst := .T., aBrowDbf, aBrowField, oTBrowse
   LOCAL aKeyDownList, xTabPage, nHeight

   /* began control list with fields */
   FOR EACH aItem IN ::aEditList
      AAdd( ::aControlList, AClone( aItem ) )
   NEXT

   /* create tab, if use tab */
   IF ::lWithTab

      gui_TabCreate( ::xDlg, @xTab, 70, 5, APP_DLG_WIDTH - 19, APP_DLG_HEIGHT - 75 )

      AAdd( ::aControlList, EmptyFrmClassItem() )
      Atail( ::aControlList )[ CFG_CTLTYPE ]  := TYPE_TAB
      Atail( ::aControlList )[ CFG_FCONTROL ] := xTab
      nRow := 999999
   ELSE
      nRow := 40
   ENDIF
   nCol := 10

   FOR EACH aItem IN ::aControlList

     /* check needed size */
      nHeight := 1
      DO CASE
      CASE hb_AScan( { TYPE_TAB, TYPE_TABPAGE, TYPE_HWGUIBUG, TYPE_BUTTON, TYPE_ADDBUTTON }, { | e | e == aItem[ CFG_CTLTYPE ] } ) != 0
         /* these controls do not need additional code */
         LOOP
      CASE aItem[ CFG_CTLTYPE ] == TYPE_BROWSE
         nLen := APP_DLG_WIDTH - 30
         nHeight := 7

      CASE aItem[ CFG_CTLTYPE ] == TYPE_COMBOBOX
         IF ::nLayout == 1 .OR. ::nLayout == 2
            nLen := ( Max( 15, Len( aItem[ CFG_CAPTION ] ) ) + Max( 15, aItem[ CFG_FLEN ] + 3 ) ) * 12
         ELSE
            nLen := ( Max( 15, Max( Len( aItem[ CFG_CAPTION ] ), aItem[ CFG_FLEN ] ) ) + 3 ) * 12
         ENDIF

      CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
         IF ::nLayout == 1 .OR. ::nLayout == 2
            nLen := ( Len( aItem[ CFG_CAPTION ] ) + aItem[ CFG_FLEN ] + 3 ) * 12
         ELSE
            nLen := ( Max( Len( aItem[ CFG_CAPTION ] ), aItem[ CFG_FLEN ] ) + 3 ) * 12
         ENDIF

      CASE aItem[ CFG_CTLTYPE ] == TYPE_SPINNER .OR. aItem[ CFG_CTLTYPE ] == TYPE_DATEPICKER
         IF ::nLayout == 1 .OR. ::nLayout == 2
            nLen := ( Max( 15, Len( aItem[ CFG_CAPTION ] ) ) + Max( 6, aItem[ CFG_FLEN ] + 3 ) ) * 12
         ELSE
            nLen := ( Max( 6, Max( Len( aItem[ CFG_CAPTION ] ), aItem[ CFG_FLEN ] ) ) + 3 ) * 12
         ENDIF

      CASE aItem[ CFG_CTLTYPE ] == TYPE_TEXT
         IF aItem[ CFG_FLEN ] > 100 .OR. aItem[ CFG_FTYPE ] == "M"
            aItem[ CFG_CTLTYPE ] := TYPE_MLTEXT
            nLen := APP_DLG_WIDTH - 30
            nHeight := iif( aItem[ CFG_FTYPE ] == "M", 5, Round( aItem[ CFG_FLEN ] / 100, 0 ) )
         ELSE
            IF ::nLayout == 1 .OR. ::nLayout == 2
               nLen := ( Len( aItem[ CFG_CAPTION ] ) + 1 + Max( aItem[ CFG_FLEN ], 5 ) + 3 ) * 12
            ELSE
               nLen := ( Max( Len( aItem[ CFG_CAPTION ] ), Max( aItem[ CFG_FLEN ], 5 ) ) + 3 ) * 12
            ENDIF
            IF ! Empty( aItem[ CFG_VTABLE ] )
               nLen += ( aItem[ CFG_VLEN ] + 3 ) * 12
            ENDIF
         ENDIF
      OTHERWISE
         gui_MsgBox( "Check about control type " + hb_ValToExp( aItem[ CFG_CTLTYPE ] ) )
      ENDCASE

      /* check max row and max col */
      IF ::nLayout == 1 .OR. ( nCol != 10 .AND. nCol + 30 + nLen > APP_DLG_WIDTH - 40 )
         IF ! lFirst
            nRow += ( APP_LINE_SPACING * iif( ::nLayout < 3, 1, 2 ) )
         ENDIF
         nCol := 10
      ENDIF

      /* check if create a new tabpage */
      IF ::lWithTab .AND. nRow + ( ( nHeight + iif( ::nLayout < 3, 1, 2 ) ) * APP_LINE_SPACING  ) > APP_DLG_HEIGHT - 100
         IF nPageCount > 0

            gui_TabPageEnd( ::xDlg, xTab, xTabPage )

         ENDIF
         nPageCount += 1

         gui_TabPageBegin( ::xDlg, xTab, @xTabPage, nPageCount, "Page" + Str( nPageCount, 2 ) )

         AAdd( ::aControlList, EmptyFrmClassItem() )
         Atail( ::aControlList )[ CFG_CTLTYPE ]  := TYPE_TABPAGE
         Atail( ::aControlList )[ CFG_FCONTROL ] := xTabPage
         nRow := 40
         AAdd( aList, {} )
         lFirst := .T.
         (lFirst)
      ENDIF

      /* create control */
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
         /* if editable browse, keys to do that */
         IF aItem[ CFG_BRWEDIT ]
            aKeyDownList := { ;
               { VK_INSERT, { || ::BrowseAction( aItem, VK_INSERT ) } }, ;
               { VK_DELETE, { || ::BrowseAction( aItem, VK_DELETE ) } }, ;
               { VK_RETURN, { || ::BrowseAction( aItem, VK_RETURN ) } } }
         ELSE
            aKeyDownList := {}
         ENDIF
         nRow2 := nRow + APP_LINE_SPACING

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow + 2, nCol, nLen * 12, APP_LINE_HEIGHT, aItem[ CFG_BRWTITLE ], .F., APP_FONTSIZE_SMALL )

         gui_Browse( ::xDlg, xTabPage, @aItem[ CFG_FCONTROL ], nRow2, 5, ;
            APP_DLG_WIDTH - 30, nHeight * APP_LINE_HEIGHT, ;
            oTbrowse, Nil, Nil, aItem[ CFG_BRWTABLE ], aKeyDownList, Self )

         SELECT ( Select( ::cFileDBF ) )
         nRow += ( ( nHeight + iif( ::nLayout < 3, 1, 2 ) ) * APP_LINE_SPACING  )

      CASE aItem[ CFG_CTLTYPE ] == TYPE_COMBOBOX
         IF ::nLayout == 1 .OR. ::nLayout == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 + 30 )
         ELSE
            nRow2 := nRow + APP_LINE_SPACING
            nCol2 := nCol
         ENDIF

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow + 2, nCol, Len( aItem[ CFG_CAPTION ] ) * 12, APP_LINE_HEIGHT, aItem[ CFG_CAPTION ], .F., APP_FONTSIZE_SMALL )

         gui_ComboCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, Max( 10, Len( aItem[ CFG_CAPTION ] ) ) * 12, APP_LINE_HEIGHT, ( aItem[ CFG_COMBOLIST ] ) )

         nCol += nLen

      CASE aItem[ CFG_CTLTYPE ] == TYPE_CHECKBOX
         IF ::nLayout == 1 .OR. ::nLayout == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 + 30 )
         ELSE
            nRow2 := nRow + APP_LINE_SPACING
            nCol2 := nCol
         ENDIF

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow + 2, nCol, nLen * 12, APP_LINE_HEIGHT, aItem[ CFG_CAPTION ], .F., APP_FONTSIZE_SMALL )

         gui_CheckboxCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, nLen, APP_LINE_HEIGHT )

         nCol += nLen

      CASE aItem[ CFG_CTLTYPE ] == TYPE_DATEPICKER
         IF ::nLayout == 1 .OR. ::nLayout == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 + 30 )
         ELSE
            nRow2 := nRow + APP_LINE_SPACING
            nCol2 := nCol
         ENDIF

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow + 2, nCol, nLen * 12, APP_LINE_HEIGHT, aItem[ CFG_CAPTION ], .F., APP_FONTSIZE_SMALL )

         gui_DatePickerCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, nLen, APP_LINE_HEIGHT, aItem[ CFG_VALUE ] ) // aItem[ CFG_FPICTURE ] )

         nCol += nLen

      CASE aItem[ CFG_CTLTYPE ] == TYPE_SPINNER
         IF ::nLayout == 1 .OR. ::nLayout == 2
            nRow2 := nRow
            nCol2 := nCol + ( Len( aItem[ CFG_CAPTION ] ) * 12 + 30 )
         ELSE
            nRow2 := nRow + APP_LINE_SPACING
            nCol2 := nCol
         ENDIF

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow + 2, nCol, Len( aItem[ CFG_CAPTION ] ) * 12, APP_LINE_HEIGHT, aItem[ CFG_CAPTION ], .F., APP_FONTSIZE_SMALL )

         gui_SpinnerCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, Max( 6, Len( aItem[ CFG_CAPTION ] ) ) * 12, APP_LINE_HEIGHT, @aItem[ CFG_VALUE ], aItem[ CFG_SPINNER ] )

         nCol += nLen

      CASE aItem[ CFG_CTLTYPE ] == TYPE_MLTEXT // multiline
         nRow2 := nRow + APP_LINE_SPACING

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow + 2, nCol, nLen * 12, APP_LINE_HEIGHT, aItem[ CFG_CAPTION ], .F., APP_FONTSIZE_SMALL )

         gui_MLTextCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, 5, APP_DLG_WIDTH - 30, nHeight * APP_LINE_HEIGHT, @aItem[ CFG_VALUE ] )

         nRow += ( ( nHeight + iif( ::nLayout < 3, 1, 2 ) ) * APP_LINE_SPACING  )

      CASE aItem[ CFG_CTLTYPE ] == TYPE_TEXT
         IF ::nLayout == 1 .OR. ::nLayout == 2
            nRow2 := nRow
            nCol2 := nCol + ( Max( Len( aItem[ CFG_CAPTION ] ), 5 ) * 12 )
         ELSE
            nRow2 := nRow + APP_LINE_SPACING
            nCol2 := nCol
         ENDIF

         gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_CCONTROL ], ;
            nRow + 2, nCol, Len( aItem[ CFG_CAPTION ] ) * 12 + 12, APP_LINE_HEIGHT, aItem[ CFG_CAPTION ], .F., APP_FONTSIZE_SMALL )

         aItem[ CFG_ACTION ] := { || ::Browse( ::xDlg, @aItem[ CFG_FCONTROL ], iif( aItem[ CFG_ISKEY ], ::cFileDbf, aItem[ CFG_VTABLE ] ) ) }
         gui_TextCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_FCONTROL ], ;
            nRow2, nCol2, Max( aItem[ CFG_FLEN ], 5 ) * 12 + 12, APP_LINE_HEIGHT, ;
            @aItem[ CFG_VALUE ], aItem[ CFG_FPICTURE ], aitem[ CFG_FLEN ], ;
            { || ::Validate( aItem ) }, ;
            iif( aItem[ CFG_ISKEY ] .OR. ! Empty( aItem[ CFG_VTABLE ] ), aItem[ CFG_ACTION ], Nil ), ;
            iif( aItem[ CFG_ISKEY ] .OR. ! Empty( aItem[ CFG_VTABLE ] ), "bmpsearch", Nil ), @aItem, ;
            Self )

         IF ! Empty( aItem[ CFG_VTABLE ] ) .AND. ! Empty( aItem[ CFG_VSHOW ] )

            gui_LabelCreate( iif( ::lWithTab, xTabPage, ::xDlg ), @aItem[ CFG_VCONTROL ], ;
               nRow2, nCol2 + ( Max( aItem[ CFG_FLEN ], 5 ) * 12 + 42 ), aItem[ CFG_VLEN ] * 12, ;
               APP_LINE_HEIGHT, Space( aItem[ CFG_VLEN ] ), .T., APP_FONTSIZE_NORMAL )

         ENDIF
         nCol := nCol + nLen + 30
      OTHERWISE
         gui_MsgBox( "This control is not available " + hb_ValToExp( aItem[ CFG_CTLTYPE ] ) )
      ENDCASE
      IF ::lWithTab
         IF ! aItem[ CFG_ISKEY ]
            AAdd( Atail( aList ), aItem[ CFG_FCONTROL ] )
         ENDIF
      ENDIF
      lFirst := .F.
   NEXT
   IF gui_LibName() == "HWGUI"
      /* dummy textbox to works last valid */
      AAdd( ::aControlList, EmptyFrmClassItem() )
      Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_HWGUIBUG

      gui_TextCreate( ::xDlg, @Atail( ::aControlList )[ CFG_FCONTROL ], ;
         nRow, nCol, 0, 0, "", "", 0, { || .T. } )

   ENDIF
   IF ::lWithTab

      gui_TabPageEnd( ::xDlg, xTab )

      gui_TabNavigate( ::xDlg, xTab, aList )

      gui_TabEnd( xTab, nPageCount )

   ENDIF

   gui_DlgSetKey( Self )

   RETURN Nil
