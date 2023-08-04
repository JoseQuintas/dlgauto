#include "frm_class.ch"

FUNCTION frm_CreateButton( Self, lDefault )

   LOCAL nRow, nCol, nRowLine := 1, aItem, aList := {}

   hb_Default( @lDefault, .T. )
   IF "I" $ ::cOptions
      AAdd( aList, { "Insert",   { || ::Insert() } } )
   ENDIF
   IF "E" $ ::cOptions
      AAdd( aList, { "Edit", { || ::Edit() } } )
   ENDIF
   IF "D" $ ::cOptions
      AAdd( aList, { "Delete",   { || ::Delete() } } )
   ENDIF
   IF lDefault
      AAdd( aList, { "View",     { || ::View() } } )
      AAdd( aList, { "First",    { || ::First() } } )
      AAdd( aList, { "Previous", { || ::Previous() } } )
      AAdd( aList, { "Next",     { || ::Next() } } )
      AAdd( aList, { "Last",     { || ::Last() } } )
   ENDIF
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
#ifdef CODE_HWGUI
      @ nCol, nRow BUTTON aItem[ CFG_FCONTROL ] ;
         CAPTION Nil ;
         OF ::oDlg SIZE ::nButtonSize, ::nButtonSize ;
         STYLE BS_TOP ;
         ON CLICK aItem[ CFG_ACTION ] ;
         ON INIT { || ;
            BtnSetImageText( aItem[ CFG_FCONTROL ]:Handle, aItem[ CFG_FNAME ], Self ) } ;
            TOOLTIP aItem[ CFG_FNAME ]
#endif
#ifdef CODE_HMGE
      aItem[ CFG_FCONTROL ] := "btn" + Ltrim( Str( aItem:__EnumIndex ) )
      DEFINE BUTTONEX ( aItem[ CFG_FCONTROL ] )
         ROW nRow
         COL nCol
         WIDTH ::nButtonSize
         HEIGHT ::nButtonSize
         PICTURE BtnSetImageText( , aItem[ CFG_FNAME ] )
         IMAGEWIDTH ::nButtonSize - 20
         IMAGEHEIGHT ::nButtonSize - 20
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
#ifdef CODE_OOHG
      aItem[ CFG_FCONTROL ] := "btn" + Ltrim( Str( aItem:__EnumIndex ) )
      @ nRow, nCol BUTTON ( aItem[ CFG_FCONTROL ] ) ;
         CAPTION aItem[ CFG_FNAME ] ;
         PICTURE BtnSetImageText( , aItem[ CFG_FNAME ] ) ;
         ACTION Eval( aItem[ CFG_ACTION ] ) ;
         WIDTH ::nButtonSize ;
         HEIGHT ::nButtonSize ;
         WINDRAW
#endif
      IF nCol > ::nDlgWidth - ( ::nButtonSize - ::nButtonSpace ) * 2
         nRowLine += 1
         nRow += ::nButtonSize + ::nButtonSpace
         nCol := ::nDlgWidth - ::nButtonSize - ::nButtonSpace
      ENDIF
      nCol += iif( nRowLine == 1, 1, -1 ) * ( ::nButtonSize + ::nButtonSpace )
   NEXT

   RETURN Nil

STATIC FUNCTION BtnSetImageText( hHandle, cCaption, oAuto )

   LOCAL cResName, nPos
#ifdef CODE_HWGUI
   LOCAL oIcon, hIcon
#endif
   LOCAL aList := { ;
      { "Insert",   "icoPlus" }, ;
      { "Edit",     "icoEdit" }, ;
      { "View",     "AppIcon" }, ;
      { "Delete",   "icoTrash" }, ;
      { "First",    "icoGoFirst" }, ;
      { "Previous", "icoGoLeft" }, ;
      { "Next",     "icoGoRight" }, ;
      { "Last",     "icoGoLast" }, ;
      { "Save",     "icoOk" }, ;
      { "Cancel",   "icoNoOk" }, ;
      { "Mail",     "icoMail" }, ;
      { "Print",    "icoPrint" }, ;
      { "CtlList",  "AppIcon" }, ;
      { "ThisDlg",  "AppIcon" }, ;
      { "Exit",     "icoDoor" } }

   IF ( nPos := hb_AScan( aList, { | e | e[1] == cCaption } ) ) != 0
      cResName := aList[ nPos, 2 ]
#ifdef CODE_HWGUI
      oIcon := HICON():AddResource( cResName, oAuto:nButtonSize - oAuto:nTextSize, oAuto:nButtonSize - oAuto:nTextSize )
      IF ValType( oIcon ) == "O"
         hIcon := oIcon:Handle
      ENDIF
#endif
   ENDIF
#ifdef CODE_HWGUI
   hwg_SendMessage( hHandle, BM_SETIMAGE, IMAGE_ICON, hIcon )
   hwg_SendMessage( hHandle, WM_SETTEXT, 0, cCaption )
#endif
   (hHandle)
   (oAuto)

   RETURN cResName
