FUNCTION frm_CreateDBF()

   LOCAL nCont

   IF ! File( "people.dbf" )
      dbCreate( "people", { ;
         { "IDPEOPLE", "N", 6, 0 }, ;
         { "NAME",     "C", 30, 0 }, ;
         { "ADDRESS",  "C", 50, 0 }, ;
         { "CITY",     "C", 30, 0 } } )
      USE people
      FOR nCont = 1 TO 9
         APPEND BLANK
         REPLACE IDPEOPLE WITH nCont, NAME WITH Replicate( "P" + Str( nCont, 1 ), 15 ), ;
            ADDRESS WITH Replicate( "P" + Str( nCont, 1 ) , 25 ), CITY WITH Replicate( "P" + Str( nCont, 1 ), 15 )
      NEXT
      INDEX ON field->idPeople TAG primary
      INDEX ON field->Name     TAG name
      USE
   ENDIF
   IF ! File( "product.dbf" )
      dbCreate( "product", { ;
         { "IDPRODUCT", "N", 6, 0 }, ;
         { "NAME",      "C", 30, 0 }, ;
         { "VALUE",     "N", 14, 2 } } )
      USE product
      FOR nCont = 1 TO 9
         APPEND BLANK
         REPLACE IDPRODUCT WITH nCont, NAME WITH Replicate( "U" + Str( nCont, 1 ), 10 ), VALUE WITH nCont
      NEXT
      INDEX ON field->idProduct TAG primary
      INDEX ON field->Name      TAG name
      USE
   ENDIF
   IF ! File( "account.dbf" )
      dbCreate( "account", { ;
         { "IDACCOUNT", "N", 6, 0 }, ;
         { "DATEMOV",   "D", 8, 0 }, ;
         { "IDPEOPLE",  "N", 6, 0 }, ;
         { "IDPRODUCT", "N", 6, 0 }, ;
         { "QT",        "N", 9, 0 }, ;
         { "VALUE",     "N", 14, 2 } } )
      USE account
      FOR nCont = 1 TO 9
         APPEND BLANK
         REPLACE IDACCOUNT WITH nCont, IDPEOPLE WITH nCont, IDPRODUCT WITH nCont, VALUE WITH nCont * 1000
      NEXT
      INDEX ON field->IdAccount TAG primary
      USE
   ENDIF

   RETURN Nil
