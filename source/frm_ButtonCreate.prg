/*
frm_ButtonCreate - create the buttons
part of frmclass
*/

#include "frm_class.ch"

FUNCTION frm_ButtonCreate( Self )

   LOCAL nRow, nCol, nRowLine := 1, aItem, aList := {}

   IF "I" $ ::cOptions
      AAdd( aList, { "Insert",   { || ::Insert_Click() } } )
   ENDIF
   IF "E" $ ::cOptions
      AAdd( aList, { "Edit", { || ::Edit_Click() } } )
   ENDIF
   IF "D" $ ::cOptions
      AAdd( aList, { "Delete",   { || ::Delete_Click() } } )
   ENDIF
   IF ::lNavigate
      AAdd( aList, { "View",     { || ::View_Click() } } )
      AAdd( aList, { "First",    { || ::Move_Click( "FIRST" ) } } )
      AAdd( aList, { "Previous", { || ::Move_Click( "PREV" ) } } )
      AAdd( aList, { "Next",     { || ::Move_Click( "NEXT" ) } } )
      AAdd( aList, { "Last",     { || ::Move_Click( "LAST" ) } } )
   ENDIF
   IF "P" $ ::cOptions
      AAdd( aList, { "Print",    { || ::Print_Click() } } )
   ENDIF
   FOR EACH aItem IN ::aOptionList
      AAdd( aList, { aItem[1], aItem[2] } )
   NEXT
   IF "E" $ ::cOptions .OR. "S" $ ::cOptions
      AAdd( aList, { "Save",     { || ::Save_Click() } } )
      AAdd( aList, { "Cancel",   { || ::Cancel_Click() } } )
   ENDIF
   AAdd( aList, { "Exit",     { || ::Exit_Click() } } )

   nCol := 10
   nRow := 10
   FOR EACH aItem IN aList
      AAdd( ::aControlList, EmptyFrmClassItem() )
      Atail( ::aControlList )[ CFG_CTLTYPE ]  := TYPE_BUTTON
      Atail( ::aControlList )[ CFG_CAPTION ] := aItem[1]
      Atail( ::aControlList )[ CFG_ACTION ]   := aItem[ 2 ]
   NEXT
   FOR EACH aItem IN ::aControlList
      IF aItem[ CFG_CTLTYPE ] != TYPE_BUTTON
         LOOP
      ENDIF
      GUI():ButtonCreate( ::xDlg, ::xDlg, @aItem[ CFG_FCONTROL ], nRow, nCol, APP_BUTTON_SIZE, APP_BUTTON_SIZE, ;
         aItem[ CFG_CAPTION ], IconFromCaption( aItem[ CFG_CAPTION ] ), aItem[ CFG_ACTION ] )

      IF nCol > APP_DLG_WIDTH - ( APP_BUTTON_SIZE - APP_BUTTON_BETWEEN ) * 2
         nRowLine += 1
         nRow += APP_BUTTON_SIZE + APP_BUTTON_BETWEEN
         nCol := APP_DLG_WIDTH - APP_BUTTON_SIZE - APP_BUTTON_BETWEEN
      ENDIF
      nCol += iif( nRowLine == 1, 1, -1 ) * ( APP_BUTTON_SIZE + APP_BUTTON_BETWEEN )
   NEXT

   RETURN Nil

STATIC FUNCTION IconFromCaption( cCaption )

   LOCAL cResName, nPos
   LOCAL aList := { ;
      { "Insert",   "icoPlus" }, ;
      { "Edit",     "icoEdit" }, ;
      { "View",     "icoGrid" }, ;
      { "Delete",   "icoTrash" }, ;
      { "Filter",   "icoFilter" }, ;
      { "First",    "icoGoFirst" }, ;
      { "Previous", "icoGoLeft" }, ;
      { "Next",     "icoGoRight" }, ;
      { "Last",     "icoGoLast" }, ;
      { "Save",     "icoOk" }, ;
      { "Cancel",   "icoNoOk" }, ;
      { "Mail",     "icoMail" }, ;
      { "Print",    "icoPrint" }, ;
      { "Exit",     "icoDoor" }, ;
      { "History",  "icoBook" } }

   IF ( nPos := hb_AScan( aList, { | e | e[1] == cCaption } ) ) != 0
      cResName := aList[ nPos, 2 ]
   ELSE
      cResName := "icowindow"
   ENDIF

   RETURN cResName
