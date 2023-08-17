/*
frm_DBF - Create DBF for test
*/

FUNCTION frm_DBF()

   LOCAL nCont, cTxt

   IF ! File( "JPCADASTRO.DBF" )
      dbCreate( "JPCADASTRO", { ;
         { "IDCADASTRO", "N+", 6, 0 }, ;
         { "CDNOME",     "C", 50, 0 }, ;
         { "CDCNPJ",  "C", 18, 0 }, ;
         { "CDENDERECO",     "C", 50, 0 }, ;
         { "CDBAIRRO", "C", 20, 0 }, ;
         { "CDCIDADE", "C", 20, 0 }, ;
         { "CDUF", "C", 2, 0 }, ;
         { "CDCEP", "C", 9, 0 }, ;
         { "CDTELEFONE", "C", 15, 0 }, ;
         { "CDEMAIL", "C", 50, 0 }, ;
         { "CDVENDEDOR", "N", 6, 0 }, ;
         { "CDPORTADOR", "N", 6, 0 } } )
      USE JPCADASTRO
      FOR nCont = 1 TO 9
         cTxt := Replicate( "CADASTRO" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE IDCADASTRO WITH nCont, CDNOME WITH cTxt, CDCNPJ WITH cTxt, ;
            CDENDERECO WITH cTxt, CDBAIRRO WITH cTxt, CDCIDADE WITH cTxt, ;
            CDBAIRRO WITH cTxt, CDCIDADE WITH cTxt, CDUF WITH StrZero( nCont, 2 ), ;
            CDCEP WITH cTxt, CDTELEFONE WITH cTxt, CDEMAIL WITH cTxt, ;
            CDVENDEDOR WITH nCont, CDPORTADOR WITH nCont
      NEXT
      INDEX ON field->idCadastro TAG primary
      INDEX ON field->cdNome TAG nome
      USE
   ENDIF
   IF ! File( "JPPRODUTO.DBF" )
      dbCreate( "JPPRODUTO", { ;
         { "IDPRODUTO", "N+", 6, 0 }, ;
         { "IENOME",    "C", 50, 0 }, ;
         { "IEUNIDADE", "N", 6, 0 }, ;
         { "IEGRUPO",   "N", 6, 0 }, ;
         { "IENCM",     "C", 8, 0 }, ;
         { "IECEST",    "C", 7, 0 }, ;
         { "IEQTD",     "N", 6, 0 }, ;
         { "IEVALOR",   "N", 14, 2 } } )
      USE jpproduto
      FOR nCont = 1 TO 9
         cTxt := Replicate( "PRODUTO" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE IDPRODUTO WITH nCont, IENOME WITH cTxt, ieUnidade WITH nCont, ;
            IEGRUPO WITH nCont, IENCM WITH cTxt, IECEST WITH cTxt, IEQTD WITH nCont, ;
            IEVALOR WITH nCont
      NEXT
      INDEX ON field->IDPRODUTO TAG primary
      INDEX ON field->IENOME TAG nome
      USE
   ENDIF
   IF ! File( "JPUNIDADE.DBF" )
      dbCreate( "JPUNIDADE", { ;
         { "IDUNIDADE", "N+", 6, 0 }, ;
         { "UNIDSIGLA", "C", 8, 0 }, ;
         { "UNIDNOME",  "C", 30, 0 } } )
      USE JPUNIDADE
      FOR nCont = 1 TO 9
         cTxt := Replicate( "UNIDADE" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE IDUNIDADE WITH nCont, UNIDSIGLA WITH cTxt, UNIDNOME WITH cTxt
      NEXT
      INDEX ON field->IDUNIDADE TAG primary
      INDEX ON field->UNIDNOME TAG nome
      USE
   ENDIF
   IF ! File( "JPVENDEDOR.DBF" )
      dbCreate( "JPVENDEDOR", { ;
         { "IDVENDEDOR", "N+", 6, 0 }, ;
         { "VENDNOME",   "C", 30, 0 } } )
      USE JPVENDEDOR
      FOR nCont = 1 TO 9
         cTxt := Replicate( "VENDEDOR" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE IDVENDEDOR WITH nCont, VENDNOME WITH cTxt
      NEXT
      INDEX ON field->IDVENDEDOR TAG primary
      INDEX ON field->VENDNOME TAG nome
      USE
   ENDIF
   IF ! File( "JPPORTADOR.DBF" )
      dbCreate( "JPPORTADOR", { ;
         { "IDPORTADOR", "N+", 6, 0 }, ;
         { "PORTNOME",   "C", 30, 0 } } )
      USE JPPORTADOR
      FOR nCont = 1 TO 9
         cTxt := Replicate( "PORTADOR" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE IDPORTADOR WITH nCont, PORTNOME WITH cTxt
      NEXT
      INDEX ON field->IDPORTADOR TAG primary
      INDEX ON field->PORTNOME TAG nome
      USE
   ENDIF
   IF ! File( "JPGRUPO.DBF" )
      dbCreate( "JPGRUPO", { ;
         { "IDGRUPO", "N+", 6, 0 }, ;
         { "GRUPONOME", "C", 30, 0 } } )
      USE JPGRUPO
      FOR nCont = 1 TO 9
         cTxt := Replicate( "GRUPO" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE IDGRUPO WITH nCont, GRUPONOME WITH cTxt
      NEXT
      INDEX ON field->IDGRUPO TAG primary
      INDEX ON field->GRUPONOME TAG nome
      USE
   ENDIF
   IF ! File( "JPESTOQUE.DBF" )
      dbCreate( "JPESTOQUE", { ;
         { "IDESTOQUE", "N+", 6, 0 }, ;
         { "ESDATLAN", "D", 8, 0 }, ;
         { "ESPRODUTO", "N", 6, 0 }, ;
         { "ESCADASTRO", "N", 6, 0 }, ;
         { "ESNUMDOC", "C", 10, 0 }, ;
         { "ESQTDE", "N", 10, 0 } } )
      USE JPESTOQUE
      FOR nCont = 1 TO 9
         cTxt := Replicate( "ESTOQUE" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE IDESTOQUE WITH nCont, ESDATLAN WITH Date() + nCont, ;
            ESCADASTRO WITH nCont, ESNUMDOC WITH cTxt, ;
            ESPRODUTO WITH nCont, ESQTDE WITH nCont
      NEXT
      INDEX ON field->IDESTOQUE TAG primary
      USE
   ENDIF
   IF ! File( "JPFINANC.DBF" )
      dbCreate( "JPFINANC", { ;
         { "IDFINANC", "N+", 6, 0 }, ;
         { "FIDATEMI", "D", 8, 0 }, ;
         { "FICADASTRO", "N", 6, 0 }, ;
         { "FINUMDOC", "C", 10, 0 }, ;
         { "FIDATVEN", "D", 8, 0 }, ;
         { "FIDATPAG", "N", 10, 0 }, ;
         { "FIVALOR", "N", 14, 2 }, ;
         { "FIPORTADOR", "N", 6, 0 }, ;
         { "FIOBS", "C", 100, 0 } } )
      USE JPFINANC
      FOR nCont = 1 TO 9
         cTxt := Replicate( "FINANC" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE IDFINANC WITH nCont, FIDATEMI WITH Date() + nCont, ;
            FICADASTRO WITH nCont, FINUMDOC WITH cTxt, ;
            FIDATVEN WITH DATE() + 30, FIPORTADOR WITH nCont, FIOBS WITH cTxt
      NEXT
      INDEX ON field->IDFINANC TAG primary
      USE
   ENDIF
   IF ! File( "JPUF.DBF" )
      dbCreate( "JPUF", { ;
         { "UFSIGLA", "C", 2, 0 }, ;
         { "UFNOME", "C", 30, 0 } } )
      USE JPUF
      FOR nCont = 1 TO 9
         cTxt := Replicate( "UF" + Str( nCont, 1 ), 10 )
         APPEND BLANK
         REPLACE UFSIGLA WITH StrZero( nCont, 2 ), UFNOME WITH cTxt
      NEXT
      INDEX ON field->UFSIGLA TAG primary
      USE
   ENDIF

   RETURN Nil
