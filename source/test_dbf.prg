/*
test_DBF - Create DBF for test
*/

#include "directry.ch"
#include "dbstruct.ch"

FUNCTION Test_DBF()

   LOCAL nCount

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
      USE DBCLIENT
      SaveTestData()
      INDEX ON field->IdClient TAG primary
      INDEX ON field->clName TAG name
      USE
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
      USE DBPRODUCT
      SaveTestData()
      INDEX ON field->IdProduct TAG primary
      INDEX ON field->prName TAG name
      USE
   ENDIF
   IF ! File( "DBUNIT.DBF" )
      dbCreate( "DBUNIT", { ;
         { "IDUNIT",   "N", 6, 0 }, ;
         { "UNSYMBOL", "C", 8, 0 }, ;
         { "UNNAME",   "C", 30, 0 } } )
      USE DBUNIT
      SaveTestData( "UNIT" )
      INDEX ON field->IdUnit TAG primary
      INDEX ON field->UnName TAG name
      USE
   ENDIF
   IF ! File( "DBSELLER.DBF" )
      dbCreate( "DBSELLER", { ;
         { "IDSELLER", "N", 6, 0 }, ;
         { "SENAME",   "C", 30, 0 } } )
      USE DBSELLER
      SaveTestData()
      INDEX ON field->IdSeller TAG primary
      INDEX ON field->seName TAG name
      USE
   ENDIF
   IF ! File( "DBBANK.DBF" )
      dbCreate( "DBBANK", { ;
         { "IDBANK", "N", 6, 0 }, ;
         { "BANAME", "C", 30, 0 } } )
      USE DBBANK
      SaveTestData()
      INDEX ON field->IdBank TAG primary
      INDEX ON field->baName TAG name
      USE
   ENDIF
   IF ! File( "DBGROUP.DBF" )
      dbCreate( "DBGROUP", { ;
         { "IDGROUP", "N", 6, 0 }, ;
         { "GRNAME",  "C", 30, 0 } } )
      USE DBGROUP
      SaveTestData()
      INDEX ON field->IdGroup TAG primary
      INDEX ON field->grName TAG name
      USE
   ENDIF
   IF ! File( "DBSTOCK.DBF" )
      dbCreate( "DBSTOCK", { ;
         { "IDSTOCK",   "N", 6, 0 }, ;
         { "STDATOPER", "D", 8, 0 }, ;
         { "STPRODUCT", "N", 6, 0 }, ;
         { "STCLIENT",  "N", 6, 0 }, ;
         { "STNUMDOC",  "C", 10, 0 }, ;
         { "STQT",      "N", 10, 0 } } )
      USE DBSTOCK
      SaveTestData()
      INDEX ON field->IdStock TAG primary
      INDEX ON Str( field->StClient, 6 ) + Str( field->idStock, 6 ) tag client
      INDEX ON Str( field->stProduct, 6 ) + Str( field->idStock, 6 ) Tag product
      USE
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
      USE DBFINANC
      SaveTestData()
      INDEX ON field->IdFinanc TAG primary
      INDEX ON Str( field->fiClient, 6 ) + Str( field->idFinanc, 6 ) tag client
      USE
   ENDIF
   IF ! File( "DBSTATE.DBF" )
      dbCreate( "DBSTATE", { ;
         { "IDSTATE", "C", 2, 0 }, ;
         { "STNAME",  "C", 30, 0 } } )
      USE DBSTATE
      SaveTestData()
      INDEX ON field->IdState TAG primary
      INDEX ON field->stName TAG name
      USE
   ENDIF
   IF ! File( "DBTICKET.DBF" )
      dbCreate( "DBTICKET", { ;
         { "IDTICKET", "N", 6, 0 }, ;
         { "TIDATDOC", "D", 8, 0 }, ;
         { "TICLIENT", "N", 6, 0 }, ;
         { "TIVALUE",  "N", 14, 2 } } )
      USE DBTICKET
      SaveTestData()
      INDEX ON field->IdTicket TAG primary
      INDEX ON Str( field->tiClient, 6 ) + Str( field->idTicket, 6 ) tag client
      USE
   ENDIF
   IF ! File( "DBTICKETPRO.DBF" )
      dbCreate( "DBTICKETPRO", { ;
         { "IDTICKPRO", "N", 6, 0 }, ;
         { "TPTICKET",  "N", 6, 0 }, ;
         { "TPPRODUCT", "N", 6, 0 }, ;
         { "TPQT",      "N", 6, 0 }, ;
         { "TPVALUE",   "N", 14, 2 } } )
      USE DBTICKETPRO
      SaveTestData()
      INDEX ON field->idTickPro TAG primary
      INDEX ON Str( field->tpTicket, 6 ) + Str( field->IdTickPro, 6 ) TAG ticket
      USE
   ENDIF
   IF ! File( "DBFIELDS.DBF" )
      dbCreate( "DBFIELDS", { ;
         { "IDFIELD", "N", 6, 0 }, ;
         { "DBF",     "C", 20, 0 }, ;
         { "NAME",    "C", 10, 0 }, ;
         { "TYPE",    "C", 1, 0 }, ;
         { "LEN",     "N", 3, 0 }, ;
         { "DEC",     "N", 2, 0 } } )
      USE DBFIELDS
      INDEX ON field->idField TAG primary
      INDEX ON field->Dbf + Str( field->IDFIELD, 6 ) tag dbf
      USE
   ENDIF
   IF ! File ( "DBDBF.DBF" )
      dbCreate( "DBDBF", { ;
         { "IDDBF", "N", 6, 0 }, ;
         { "NAME",  "C", 20, 0 } } )
      USE DBDBF
      INDEX ON field->IdDbf tag primary
      USE
   ENDIF
   USE DBDBF
   nCount := LastRec()
   USE
   IF nCount < 1
      SaveTestStru()
   ENDIF

   RETURN Nil

STATIC FUNCTION SaveTestStru()

   LOCAL aList := {}, aStru, aField, aFile, nCont := 1

   FOR EACH aFile IN Directory( "*.dbf" )
      AAdd( aList, { hb_FNameName( aFile[ F_NAME ] ), {} } )
      USE ( aFile[ 1 ] )
      aStru := dbStruct()
      FOR EACH aField IN aStru
         AAdd( aTail( aList )[ 2 ], { aField[ DBS_NAME ], aField[ DBS_TYPE ], ;
            aField[ DBS_LEN ], aField[ DBS_DEC ] } )
      NEXT
      USE
   NEXT

   SELECT A
   USE DBDBF
   SET INDEX TO DBDBF
   SELECT B
   USE DBFIELDS
   SET INDEX TO DBFIELDS
   FOR EACH aFile IN aList
      SELECT a
      APPEND BLANK
      REPLACE ;
         field->idDBF WITH aFile:__EnumIndex, ;
         field->NAME WITH aFile[ 1 ]
      SELECT B
      FOR EACH aStru IN aFile[ 2 ]
         APPEND BLANK
         REPLACE ;
            field->IDFIELD WITH nCont++, ;
            field->DBF  WITH aFile[ 1 ], ;
            field->NAME WITH aStru[ DBS_NAME ], ;
            field->TYPE WITH aStru[ DBS_TYPE ], ;
            field->LEN  WITH aStru[ DBS_LEN ], ;
            field->DEC  WITH aStru[ DBS_DEC ]
      NEXT
   NEXT
   CLOSE DATABASES

   RETURN Nil

STATIC FUNCTION SaveTestData()

   LOCAL aStru, aItem, cText, nCont, nField

   aStru := dbStruct()
   FOR nCont = 1 TO 9
      cText := Substr( Alias(), 3 ) + " "
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
