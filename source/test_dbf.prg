/*
test_DBF - Create DBF for test
*/

#include "directry.ch"
#include "dbstruct.ch"

FUNCTION Test_DBF()

   LOCAL nCont, cTxt, lLoadStru := .F.

   IF ! File( "DBCLIENT.DBF" )
      dbCreate( "DBCLIENT", { ;
         { "IDCLIENT", "N", 6, 0 }, ;
         { "CLNAME",   "C", 50, 0 }, ;
         { "CLDOC",    "C", 18, 0 }, ;
         { "CLADDRESS","C", 50, 0 }, ;
         { "CLCITY",   "C", 20, 0 }, ;
         { "CLSTATE",  "C", 2, 0 }, ;
         { "CLMAIL",   "C", 50, 0 }, ;
         { "CLSELLER", "N", 6, 0 }, ;
         { "CLBANK",   "N", 6, 0 } } )
      USE DBCLIENT
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "CLIENT", nCont )
         APPEND BLANK
         REPLACE IDCLIENT WITH nCont, CLNAME WITH cTxt, CLDOC WITH cTxt, ;
            CLADDRESS WITH cTxt, CLCITY WITH cTxt, CLSTATE WITH StrZero( nCont, 2 ), ;
            CLMAIL WITH cTxt, CLSELLER WITH nCont, CLBANK WITH nCont
      NEXT
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
         { "PRVALUE",   "N", 14, 2 } } )
      USE DBPRODUCT
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "PRODUCT", nCont )
         APPEND BLANK
         REPLACE IDPRODUCT WITH nCont, PRNAME WITH cTxt, PRUNIT WITH nCont, ;
            PRGROUP WITH nCont, PRNCM WITH cTxt, PRQT WITH nCont, ;
            PRVALUE WITH nCont
      NEXT
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
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "UNIT", nCont )
         APPEND BLANK
         REPLACE IDUNIT WITH nCont, UNSYMBOL WITH cTxt, UNNAME WITH cTxt
      NEXT
      INDEX ON field->IdUnit TAG primary
      INDEX ON field->UnName TAG name
      USE
   ENDIF
   IF ! File( "DBSELLER.DBF" )
      dbCreate( "DBSELLER", { ;
         { "IDSELLER", "N", 6, 0 }, ;
         { "SENAME",   "C", 30, 0 } } )
      USE DBSELLER
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "SELLER", nCont )
         APPEND BLANK
         REPLACE IDSELLER WITH nCont, SENAME WITH cTxt
      NEXT
      INDEX ON field->IdSeller TAG primary
      INDEX ON field->seName TAG name
      USE
   ENDIF
   IF ! File( "DBBANK.DBF" )
      dbCreate( "DBBANK", { ;
         { "IDBANK", "N", 6, 0 }, ;
         { "BANAME", "C", 30, 0 } } )
      USE DBBANK
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "BANK", nCont )
         APPEND BLANK
         REPLACE IDBANK WITH nCont, BANAME WITH cTxt
      NEXT
      INDEX ON field->IdBank TAG primary
      INDEX ON field->baName TAG name
      USE
   ENDIF
   IF ! File( "DBGROUP.DBF" )
      dbCreate( "DBGROUP", { ;
         { "IDGROUP", "N", 6, 0 }, ;
         { "GRNAME",  "C", 30, 0 } } )
      USE DBGROUP
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "GROUP", nCont )
         APPEND BLANK
         REPLACE IDGROUP WITH nCont, GRNAME WITH cTxt
      NEXT
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
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "STOCK" , nCont )
         APPEND BLANK
         REPLACE IDSTOCK WITH nCont, STDATOPER WITH Date() + nCont, ;
            STCLIENT WITH nCont, STNUMDOC WITH cTxt, ;
            STPRODUCT WITH nCont, STQT WITH nCont
      NEXT
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
         { "FIDATPAY",   "D", 10, 0 }, ;
         { "FIVALUE",    "N", 14, 2 }, ;
         { "FIBANK",     "N", 6, 0 } } )
      USE DBFINANC
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "FINANC", nCont )
         APPEND BLANK
         REPLACE IDFINANC WITH nCont, FIDATOPER WITH Date() + nCont, ;
            FICLIENT WITH nCont, FINUMDOC WITH cTxt, ;
            FIDATTOPAY WITH DATE() + 30, FIBANK WITH nCont
      NEXT
      INDEX ON field->IdFinanc TAG primary
      INDEX ON Str( field->fiClient, 6 ) + Str( field->idFinanc, 6 ) tag client
      USE
   ENDIF
   IF ! File( "DBSTATE.DBF" )
      dbCreate( "DBSTATE", { ;
         { "IDSTATE", "C", 2, 0 }, ;
         { "STNAME",  "C", 30, 0 } } )
      USE DBSTATE
      FOR nCont = 1 TO 9
         cTxt := ToDescription( "STATE", nCont )
         APPEND BLANK
         REPLACE IDSTATE WITH StrZero( nCont, 2 ), STNAME WITH cTxt
      NEXT
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
      APPEND BLANK
      REPLACE ;
         field->IdTicket WITH 1, ;
         field->tiDatDoc WITH Date(), ;
         field->tiClient WITH 1, ;
         field->tiValue WITH 100
      APPEND BLANK
      REPLACE ;
         field->IdTicket WITH 2, ;
         field->tiDatDoc WITH Date(), ;
         field->tiClient WITH 2, ;
         field->tiValue WITH 200
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
      APPEND BLANK
      REPLACE ;
         field->idTickPro WITH 1, ;
         field->tpTicket WITH 1, ;
         field->tpProduct WITH 1, ;
         field->tpQt WITH 1, ;
         field->tpValue WITH 1
      APPEND BLANK
      REPLACE ;
         field->idTickPro WITH 2, ;
         field->tpTicket WITH 1, ;
         field->tpProduct WITH 2, ;
         field->tpQt WITH 2, ;
         field->tpValue WITH 2
      APPEND BLANK
      REPLACE ;
         field->idTickPro WITH 3, ;
         field->tpTicket WITH 2, ;
         field->tpProduct WITH 3, ;
         field->tpQt WITH 3, ;
         field->tpValue WITH 3
      APPEND BLANK
      REPLACE ;
         field->idTickPro WITH 4, ;
         field->tpTicket WITH 2, ;
         field->tpProduct WITH 4, ;
         field->tpQt WITH 4, ;
         field->tpValue WITH 4
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
      lLoadStru := .T.
   ENDIF
   IF ! File ( "DBDBF.DBF" )
      dbCreate( "DBDBF", { ;
         { "IDDBF", "N", 6, 0 }, ;
         { "NAME",  "C", 20, 0 } } )
      USE DBDBF
      INDEX ON field->IdDbf tag primary
      USE
      lLoadStru := .T.
   ENDIF
   IF lLoadStru
      LoadStru()
   ENDIF

   RETURN Nil

STATIC FUNCTION LoadStru()

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

STATIC FUNCTION ToDescription( cText, n )

   cText += " "
   DO CASE
   CASE n == 1 ; cText += "ONE"
   CASE n == 2 ; cText += "TWO"
   CASE n == 3 ; cText += "THREE"
   CASE n == 4 ; cText += "FOUR"
   CASE n == 5 ; cText += "FIVE"
   CASE n == 6 ; cText += "SIX"
   CASE n == 7 ; cText += "SEVEN"
   CASE n == 8 ; cText += "EIGHT"
   CASE n == 9 ; cText += "NINE"
   ENDCASE
   cText += " "

   RETURN Replicate( cText, 5 )

