/*
test_DBF - Create DBF for test
*/

#include "directry.ch"
#include "dbstruct.ch"

FUNCTION Test_DBF()

   IF ! File( "DBCLIENT.DBF" )
      dbCreate( "DBCLIENT", { ;
         { "IDCLIENT", "N", 6, 0 }, ;
         { "CLNAME",   "C", 50, 0 }, ;
         { "CLDOC",    "C", 18, 0 }, ;
         { "CLADDRESS","C", 50, 0 }, ;
         { "CLCITY",   "C", 20, 0 }, ;
         { "CLSTATE",  "C", 2, 0 }, ;
         { "CLDATE",   "D", 8, 0 }, ;
         { "CLVALUE",  "N", 14, 2 }, ;
         { "CLSELLER", "N", 6, 0 }, ;
         { "CLBANK",   "N", 6, 0 }, ;
         { "CLPAYTERM","N", 3, 0 }, ;
         { "CLSTATUS", "N", 1, 0 }, ;
         { "CLCOMMENT", "C", 255, 0 } } )
   ENDIF
   IF ! File( "DBPRODUCT.DBF" )
      dbCreate( "DBPRODUCT", { ;
         { "IDPRODUCT", "N", 6, 0 }, ;
         { "PRNAME",    "C", 50, 0 }, ;
         { "PRUNIT",    "N", 6, 0 }, ;
         { "PRGROUP",   "N", 6, 0 }, ;
         { "PRNCM",     "C", 8, 0 }, ;
         { "PRQT",      "N", 6, 0 }, ;
         { "PRVALUE",   "N", 14, 2 }, ;
         { "PRSTATUS",  "N", 1, 0 } } )
   ENDIF
   IF ! File( "DBUNIT.DBF" )
      dbCreate( "DBUNIT", { ;
         { "IDUNIT",   "N", 6, 0 }, ;
         { "UNSYMBOL", "C", 8, 0 }, ;
         { "UNNAME",   "C", 30, 0 } } )
   ENDIF
   IF ! File( "DBSELLER.DBF" )
      dbCreate( "DBSELLER", { ;
         { "IDSELLER", "N", 6, 0 }, ;
         { "SENAME",   "C", 30, 0 } } )
   ENDIF
   IF ! File( "DBBANK.DBF" )
      dbCreate( "DBBANK", { ;
         { "IDBANK", "N", 6, 0 }, ;
         { "BANAME", "C", 30, 0 } } )
   ENDIF
   IF ! File( "DBGROUP.DBF" )
      dbCreate( "DBGROUP", { ;
         { "IDGROUP", "N", 6, 0 }, ;
         { "GRNAME",  "C", 30, 0 } } )
   ENDIF
   IF ! File( "DBSTOCK.DBF" )
      dbCreate( "DBSTOCK", { ;
         { "IDSTOCK",   "N", 6, 0 }, ;
         { "STDATOPER", "D", 8, 0 }, ;
         { "STPRODUCT", "N", 6, 0 }, ;
         { "STCLIENT",  "N", 6, 0 }, ;
         { "STNUMDOC",  "C", 10, 0 }, ;
         { "STQT",      "N", 10, 0 } } )
   ENDIF
   IF ! File( "DBFINANC.DBF" )
      dbCreate( "DBFINANC", { ;
         { "IDFINANC",   "N", 6, 0 }, ;
         { "FIDATOPER",  "D", 8, 0 }, ;
         { "FICLIENT",   "N", 6, 0 }, ;
         { "FINUMDOC",   "C", 10, 0 }, ;
         { "FIDATTOPAY", "D", 8, 0 }, ;
         { "FIDATPAY",   "D", 8, 0 }, ;
         { "FIVALUE",    "N", 14, 2 }, ;
         { "FIBANK",     "N", 6, 0 } } )
   ENDIF
   IF ! File( "DBSTATE.DBF" )
      dbCreate( "DBSTATE", { ;
         { "IDSTATE", "C", 2, 0 }, ;
         { "STNAME",  "C", 30, 0 } } )
   ENDIF
   IF ! File( "DBTICKET.DBF" )
      dbCreate( "DBTICKET", { ;
         { "IDTICKET", "N", 6, 0 }, ;
         { "TIDATDOC", "D", 8, 0 }, ;
         { "TICLIENT", "N", 6, 0 }, ;
         { "TIVALUE",  "N", 14, 2 } } )
   ENDIF
   IF ! File( "DBTICKETPRO.DBF" )
      dbCreate( "DBTICKETPRO", { ;
         { "IDTICKPRO", "N", 6, 0 }, ;
         { "TPTICKET",  "N", 6, 0 }, ;
         { "TPPRODUCT", "N", 6, 0 }, ;
         { "TPQT",      "N", 6, 0 }, ;
         { "TPVALUE",   "N", 14, 2 } } )
   ENDIF
   DlgOpenFiles( "DBCLIENT", "DBPRODUCT", "DBUNIT", "DBSELLER", "DBBANK", ;
      "DBGROUP", "DBSTOCK", "DBFINANC", "DBSTATE", "DBTICKET", "DBTICKETPRO" )
   CLOSE DATABASES

   RETURN Nil

FUNCTION DlgOpenFiles( ... )

   LOCAL aFiles, lOk := .T., cFile

   aFiles := hb_AParams()

   FOR EACH cFile IN aFiles
      IF ! DlgOpenAFile( cFile )
         lOk := .F.
         EXIT
      ENDIF
   NEXT
   IF ! lOk
      CLOSE DATABASES
   ENDIF

   RETURN lOk

FUNCTION DlgOpenAFile( cFile )

   USE ( cFile )
   IF LastRec() == 0
      SaveTestData()
   ENDIF
   IF ! File( cFile + ".CDX" )
      DO CASE
      CASE cFile == "DBCLIENT"
         INDEX ON field->IdClient TAG primary
         INDEX ON field->clName TAG name
      CASE cFile == "DBPRODUCT"
         INDEX ON field->IdProduct TAG primary
         INDEX ON field->prName TAG name
      CASE cFile == "DBUNIT"
         INDEX ON field->IdUnit TAG primary
         INDEX ON field->UnName TAG name
      CASE cFile == "DBSELLER"
         INDEX ON field->IdSeller TAG primary
         INDEX ON field->seName TAG name
      CASE cFile == "DBBANK"
         INDEX ON field->IdBank TAG primary
         INDEX ON field->baName TAG name
      CASE cFile == "DBGROUP"
         INDEX ON field->IdGroup TAG primary
         INDEX ON field->grName TAG name
      CASE cFile == "DBSTOCK"
         INDEX ON field->IdStock TAG primary
         INDEX ON Str( field->StClient, 6 ) + Str( field->idStock, 6 ) tag client
         INDEX ON Str( field->stProduct, 6 ) + Str( field->idStock, 6 ) Tag product
      CASE cFile == "DBFINANC"
         INDEX ON field->IdFinanc TAG primary
         INDEX ON Str( field->fiClient, 6 ) + Str( field->idFinanc, 6 ) tag client
      CASE cFile == "DBSTATE"
         INDEX ON field->IdState TAG primary
         INDEX ON field->stName TAG name
      CASE cFile == "DBTICKET"
         INDEX ON field->IdTicket TAG primary
         INDEX ON Str( field->tiClient, 6 ) + Str( field->idTicket, 6 ) tag client
      CASE cFile == "DBTICKETPRO"
         INDEX ON field->idTickPro TAG primary
         INDEX ON Str( field->tpTicket, 6 ) + Str( field->IdTickPro, 6 ) TAG ticket
      ENDCASE
   ENDIF
   IF File( cFile + ".CDX" )
      SET INDEX TO ( cFile )
   ENDIF

   RETURN .T.

STATIC FUNCTION SaveTestData()

   LOCAL aStru, aItem, cText, nCont, nField

   aStru := dbStruct()
   FOR nCont = 1 TO 9
      cText := ""
      DO CASE
      CASE nCont == 1 ; cText += "ONE"
      CASE nCont == 2 ; cText += "TWO"
      CASE nCont == 3 ; cText += "THREE"
      CASE nCont == 4 ; cText += "FOUR"
      CASE nCont == 5 ; cText += "FIVE"
      CASE nCont == 6 ; cText += "SIX"
      CASE nCont == 7 ; cText += "SEVEN"
      CASE nCont == 8 ; cText += "EIGHT"
      CASE nCont == 9 ; cText += "NINE"
      OTHERWISE   ; cText += "ANY"
      ENDCASE
      cText := cText + " " + Substr( Alias(), 3 ) + " "
      cText := Replicate( cText, 10 )
      APPEND BLANK
      FOR nField = 1 TO Len( aStru )
         aItem := aStru[ nField ]
         IF aItem[ DBS_TYPE ] == "N";     FieldPut( nField, nCont )
         ELSEIF aItem[ DBS_TYPE ] == "D"; FieldPut( nField, Date() - 30 + nCont )
         ELSEIF aItem[ DBS_TYPE ] $ "CM"; FieldPut( nField, cText )
         ELSEIF aItem[ DBS_TYPE ] == "L"; FieldPut( nField, .T. )
         ENDIF
      NEXT
   NEXT

   RETURN Nil
