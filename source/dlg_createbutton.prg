#include "dlg_class.ch"

FUNCTION Dlg_CreateButton( Self )

   LOCAL nRow, nCol, nRowLine := 1, aItem, aList := {}

   IF "I" $ ::cOptions
      AAdd( aList, { "Insert",   { || ::Insert() } } )
   ENDIF
   IF "E" $ ::cOptions
      AAdd( aList, { "Edit", { || ::Edit() } } )
   ENDIF
   IF "D" $ ::cOptions
      AAdd( aList, { "Delete",   { || ::Delete() } } )
   ENDIF
   AAdd( aList, { "View",     { || ::View() } } )
   AAdd( aList, { "First",    { || ::First() } } )
   AAdd( aList, { "Previous", { || ::Previous() } } )
   AAdd( aList, { "Next",     { || ::Next() } } )
   AAdd( aList, { "Last",     { || ::Last() } } )
   IF "E" $ ::cOptions
      AAdd( aList, { "Save",     { || ::Save() } } )
      AAdd( aList, { "Cancel",   { || ::Cancel() } } )
   ENDIF
   IF "P" $ ::cOptions
      AAdd( aList, { "Print",    { || ::Print() } } )
   ENDIF
   FOR EACH aItem IN ::aOptionList
      AAdd( aList, { aItem[1], aItem[2] } )
   NEXT
   AAdd( aList, { "Exit",     { || ::Exit() } } )

   nCol := 10
   nRow := 10
   FOR EACH aItem IN aList
      AAdd( ::aControlList, CFG_EDITEMPTY )
      Atail( ::aControlList )[ CFG_CTLTYPE ] := TYPE_BUTTON
      Atail( ::aControlList )[ CFG_FNAME ]    := aItem[1]
      Atail( ::aControlList )[ CFG_ACTION ]  := aItem[ 2 ]
   NEXT
   FOR EACH aItem IN ::aControlList
#ifdef THIS_HWGUI
      @ nCol, nRow BUTTON aItem[ CFG_TOBJ ] ;
         CAPTION Nil ;
         OF ::oDlg SIZE ::nButtonSize, ::nButtonSize ;
         STYLE BS_TOP ;
         ON CLICK aItem[ CFG_ACTION ] ;
         ON INIT { || ;
            BtnSetImageText( aItem[ CFG_TOBJ ]:Handle, aItem[ CFG_FNAME ], Self ) } ;
            TOOLTIP aItem[ CFG_FNAME ]
#endif
#ifdef THIS_HMGE
      aItem[ CFG_TOBJ ] := "btn" + Ltrim( Str( aItem:__EnumIndex ) )
      DEFINE BUTTONEX &( aItem[ CFG_TOBJ ] )
         WIDTH ::nButtonSize
         HEIGHT ::nButtonSize
         PICTURE "icobook.ico"
         IMAGEWIDTH ::nButtonSize - 20
         IMAGEHEIGHT ::nButtonSize - 20
         COL nCol
         ROW nRow
         CAPTION aItem[ CFG_FNAME ]
         ACTION Eval( aItem[ CFG_ACTION ] )
         FONTNAME "verdana"
         FONTSIZE 9
         FONTBOLD .T.
         FONTCOLOR GRAY
         VERTICAL .T.
         BACKCOLOR WHITE
         FLAT .T.
         NOXPSTYLE .T.
      END BUTTONEX
#endif
      IF nCol > ::nDlgWidth - ( ::nButtonSize - ::nButtonSpace ) * 2
         nRowLine += 1
         nRow += ::nButtonSize + ::nButtonSpace
         nCol := ::nDlgWidth - ::nButtonSize - ::nButtonSpace
      ENDIF
      nCol += iif( nRowLine == 1, 1, -1 ) * ( ::nButtonSize + ::nButtonSpace )
   NEXT

   RETURN Nil

#ifdef THIS_HWGUI
STATIC FUNCTION BtnSetImageText( hHandle, cCaption, oAuto )

   LOCAL oIcon, nPos, cResName, hIcon
   LOCAL aList := { ;
      { "Insert",   "AppIcon" }, ;
      { "Edit",     "AppIcon" }, ;
      { "View",     "AppIcon" }, ;
      { "Delete",   "AppIcon" }, ;
      { "First",    "AppIcon" }, ;
      { "Previous", "AppIcon" }, ;
      { "Next",     "AppIcon" }, ;
      { "Last",     "AppIcon" }, ;
      { "Save",     "AppIcon" }, ;
      { "Cancel",   "AppIcon" }, ;
      { "Mail",     "AppIcon" }, ;
      { "Print",    "AppIcon" }, ;
      { "CtlList",  "AppIcon" }, ;
      { "ThisDlg",  "AppIcon" }, ;
      { "Exit",     "AppIcon" } }

   IF ( nPos := hb_AScan( aList, { | e | e[1] == cCaption } ) ) != 0
      cResName := aList[ nPos, 2 ]
      oIcon := HICON():AddResource( cResName, oAuto:nButtonSize - oAuto:nTextSize, oAuto:nButtonSize - oAuto:nTextSize )
      IF ValType( oIcon ) == "O"
         hIcon := oIcon:Handle
      ENDIF
   ENDIF
   hwg_SendMessage( hHandle, BM_SETIMAGE, IMAGE_ICON, hIcon )
   hwg_SendMessage( hHandle, WM_SETTEXT, 0, cCaption )

   RETURN Nil
#endif
