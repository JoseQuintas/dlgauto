/*
frm_buttons - create the buttons
*/

#include "frm_class.ch"

FUNCTION frm_Buttons( Self )

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
   IF ::lNavigate
      AAdd( aList, { "View",     { || ::View() } } )
      AAdd( aList, { "First",    { || ::First() } } )
      AAdd( aList, { "Previous", { || ::Previous() } } )
      AAdd( aList, { "Next",     { || ::Next() } } )
      AAdd( aList, { "Last",     { || ::Last() } } )
   ENDIF
   IF "P" $ ::cOptions
      AAdd( aList, { "Print",    { || ::Print() } } )
   ENDIF
   FOR EACH aItem IN ::aOptionList
      AAdd( aList, { aItem[1], aItem[2] } )
   NEXT
   IF "E" $ ::cOptions .OR. "S" $ ::cOptions
      AAdd( aList, { "Save",     { || ::DataSave() } } )
      AAdd( aList, { "Cancel",   { || ::Cancel() } } )
   ENDIF
   AAdd( aList, { "Exit",     { || ::Exit() } } )

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
      gui_ButtonCreate( ::xDlg, @aItem[ CFG_FCONTROL ], nRow, nCol, APP_BUTTON_SIZE, APP_BUTTON_SIZE, ;
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
   ENDIF

   RETURN cResName
