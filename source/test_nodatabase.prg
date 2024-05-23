/*
test_nodatabase - test with no database
*/

#include "frm_class.ch"

FUNCTION test_noDatabase( nLayout )

   LOCAL oFrm, aItem, oTemp
   LOCAL aList := { ;
      { "Code Number", 123 }, ;
      { "Name", Pad( "Any Name", 30 ) }, ;
      { "Telephone", Pad( "11-000-000", 30 ) }, ;
      { "Address", Pad( "Avenue Any", 40 ) }, ;
      { "Doc", Pad( "Doc Any", 30 ) }, ;
      { "Comments", Pad( "Some comments", 500 ) } }

   oFrm := frm_Class():New()
   WITH OBJECT oFrm
      :cTitle      := "simple test"
      :cOptions    := ""
      :lNavigate   := .F.
      :lModal      := .T.
      :nLayout     := nLayout
      FOR EACH aItem IN aList
         oTemp := EmptyFrmClassItem()
         oTemp[ CFG_FTYPE ]   := ValType( aItem[2] )
         oTemp[ CFG_FLEN ]    := iif( ValType( aItem[2] ) == "C", Len( aItem[2] ), 10 )
         oTemp[ CFG_CAPTION ] := aItem[1]
         oTemp[ CFG_VALUE ]   := aItem[2]
         oTemp[ CFG_CTLTYPE ] := TYPE_TEXT
         AAdd( :aEditList, oTemp )
      NEXT
      :Execute()
   ENDWITH

   RETURN Nil
