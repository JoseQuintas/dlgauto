/*
ZE_ADOCLASS - ADO ROUTINES
2011.09 José Quintas
*/

#require "hbwin.hbc"
#include "hbclass.ch"
#include "inkey.ch"
#include "dbstruct.ch"
#include "ze_adoclass.ch"

CREATE CLASS ADOClass

   VAR Cn
   VAR Rs
   VAR cSQL
   VAR aQueryList
   VAR aWhereList
   VAR cMultiQueryTable

   DESTRUCTOR Destroy()
   // connection
   METHOD New( oConnection )           INLINE ::CN := oConnection, SELF
   METHOD Open( lError )
   METHOD Close()                      INLINE ::CloseRecordset() // , ::CloseConnection()
   METHOD CloseConnection()
   // table
   METHOD IndexList( cTable )
   METHOD DatabaseList()
   METHOD TableList()
   METHOD TableExists( cTable )
   METHOD TableRecCount( cTable, cFilter )
   METHOD IndexExists( cIndex, cTable )
   // recordset
   METHOD CloseRecordset()
   METHOD AbsolutePosition()           INLINE iif( ::Rs == Nil, 0,   ::Rs:AbsolutePosition )
   METHOD Bof()                        INLINE iif( ::Rs == Nil, .T., ::Rs:Bof() )
   METHOD Eof()                        INLINE iif( ::Rs == Nil, .T., ::Rs:Eof() )
   METHOD AddNew()                     INLINE ::Rs:AddNew()
   METHOD Update()                     INLINE ::Rs:Update()
   METHOD Append( ... )                INLINE ::Rs:Append( ... )
   METHOD Fields( ... )                INLINE iif( ::RecordCount() == 0, "", ::Rs:Fields( ... ) )
   METHOD Filter( cValue )             INLINE iif( ::Rs == Nil, Nil, iif( cValue == Nil, ::Rs:Filter, ::Rs:Filter := cValue ) )
   METHOD ResetFilter()                INLINE ::Rs:Filter := 0
   METHOD Find( cFind, p2, p3 )        INLINE iif( ::Rs == Nil, Nil, ::Rs:Find( cFind, p2, p3 ) )
   METHOD GetRows( ... )               INLINE InverseArray( ::Rs:GetRows( ... ) )
   METHOD MoveFirst()                  INLINE iif( ::RecordCount() == 0, Nil, ::Rs:MoveFirst() )
   METHOD MoveLast()                   INLINE iif( ::RecordCount() == 0, Nil, ::Rs:MoveLast() )
   METHOD MoveNext()                   INLINE iif( ::RecordCount() == 0, Nil, ::Rs:MoveNext() )
   METHOD MovePrevious()               INLINE iif( ::RecordCount() == 0, Nil, ::Rs:MovePrevious() )
   METHOD Move( nValue, ... )          INLINE iif( ::RecordCount() == 0, Nil, ::Rs:Move( nValue, ... ) ) // 0, 1=begin, 2=end
   METHOD RecordCount()                INLINE iif( ::Rs == Nil, 0, ::Rs:RecordCount() )
   METHOD RsCreate( aStru )
   METHOD Sort( cSort )                INLINE iif( ::RecordCount() == 0, Nil, ::Rs:Sort := cSort )
   METHOD BookMark( n )                INLINE ::Move( n, 1 )
   METHOD SQLToDbf( oStructure )
   // field
   METHOD FieldList( cTable )
   METHOD FieldExists( cField, cTable )
   METHOD Date( xField )
   METHOD Value( xField )
   METHOD String( xField, nLen )
   METHOD Number( xField, nLen, nDec )
   METHOD FStru( xField )
   METHOD FCount()                     INLINE iif( ::Rs == Nil, 0, ::Rs:Fields:Count() )
   METHOD FName( xField )              INLINE ::FStru( xField )[ 1 ]
   METHOD FType( xField )              INLINE ::FStru( xField )[ 2 ]
   METHOD FLen( xField )               INLINE ::FStru( xField )[ 3 ]
   METHOD FDec( xField )               INLINE ::FStru( xField )[ 4 ]
   // Query
   METHOD Execute( cSQL, lError )    // Update ::Rs
   METHOD ExecuteNoReturn( cSQL, lError )
   METHOD ExecuteReturnRS( cSQL, lError )
   METHOD ExecuteProcedure( ... )
   METHOD ExecuteProcedureNoReturn( ... )
   METHOD FieldSQL( xField, cQuery )
   METHOD DBFQueryExecuteInsert()
   METHOD DBFQueryExecuteUpdate()
   METHOD QueryExecuteInsert( cTable, lIgnore )
   METHOD QueryExecuteUpdate( cTable, cWhere )
   METHOD ExecuteReturnValue( cCmd )
   METHOD ReturnFunction( ... )
   METHOD QueryCreate()                        INLINE ::aQueryList := {}, Nil
   METHOD QueryAdd( cField, xValue )           INLINE AAdd( ::aQueryList, { cField, xValue } ), Nil
   METHOD MultiQueryCreate( cTable )           INLINE ::cMultiQueryTable := cTable, ::cSQL := "", ::QueryCreate()
   METHOD MultiQueryAdd( cField, xValue )      INLINE ::QueryAdd( cField, xValue )
   METHOD MultiQueryExecuteInsert( lEnd )
   METHOD Requery()                            INLINE ::Rs:Requery()

   ENDCLASS

METHOD Destroy() CLASS ADOClass

   IF ::Rs != Nil
      ::CloseRecordset()
      ::Rs := Nil // is it needed?
   ENDIF

   RETURN Nil

METHOD CloseConnection() CLASS ADOClass

   ::CloseRecordset()
   BEGIN SEQUENCE WITH __BreakBlock()
      ::Cn:Close()
   ENDSEQUENCE

   RETURN Nil

METHOD CloseRecordset() CLASS ADOClass

   BEGIN SEQUENCE WITH __BreakBlock()
      ::Rs:Close()
   ENDSEQUENCE
   ::Rs := Nil // is it needed?

   RETURN Nil

METHOD Open( lError ) CLASS ADOClass

   LOCAL lOk := .F., cMessage

   hb_Default( @lError, .T. )
   BEGIN SEQUENCE WITH __BreakBlock()
      IF ::cn:State() != AD_STATE_OPEN
         ::Cn:Open()
      ENDIF
      lOk := .T.
   ENDSEQUENCE
   IF lError .AND. ! lOk
      cMessage := LTrim( Str( ::Cn:Errors(0):Number() ) ) + " " + ::Cn:Errors(0):Description()
      Errorsys_WriteErrorLog( cMessage, 3 )
      MsgStop( cMessage )
      QUIT
   ENDIF

   RETURN lOk

METHOD Execute( cSQL, lError ) CLASS ADOClass

   ::Rs := Nil
   ::Rs := ::ExecuteReturnRS( cSQL, lError )

   RETURN Nil

METHOD ExecuteProcedureNoReturn( ... ) CLASS ADOClass

   LOCAL cSQL, aItem, aList := hb_AParams()

   cSQL := "CALL " + aList[ 1 ]
   hb_ADel( aList, 1, .T. )

   cSQL += "("
   FOR EACH aItem IN aList
      cSQL += ValueSQL( aItem )
      cSQL += iif( aItem:__ENumIsLast(), "", "," )
   NEXT
   cSQL += ")"

   RETURN ::ExecuteNoReturn( cSQL )

METHOD ExecuteProcedure( ... ) CLASS ADOClass

   LOCAL cSQL, aItem, aList := hb_AParams()

   cSQL := "CALL " + aList[ 1 ]
   hb_ADel( aList, 1, .T. )

   cSQL += "("
   FOR EACH aItem IN aList
      cSQL += ValueSQL( aItem )
      cSQL += iif( aItem:__ENumIsLast(), "", "," )
   NEXT
   cSQL += ")"
   ::Execute( cSQL )

   RETURN Nil

METHOD ExecuteNoReturn( cSQL, lError ) CLASS ADOClass

   LOCAL lOk := .F.

   IF ::Cn == Nil
      RETURN Nil
   ENDIF
   hb_Default( @lError, .T. )
   cSQL := iif( cSQL == Nil, ::cSQL, cSQL ) // not hb_default
   IF ::Cn:State() != AD_STATE_OPEN
      ::Open()
   ENDIF
   cSQL := Trim( cSQL )
   IF Right( AllTrim( cSQL ), 1 ) != ";"
      cSQL += ";"
   ENDIF
   IF Len( Trim( cSQL ) ) != 0
      BEGIN SEQUENCE WITH __BreakBlock()
         ::Cn:Execute( cSQL, , AD_EXECUTE_NORECORDS )
         lOk := .T.
      ENDSEQUENCE
      IF ! lOk
         Errorsys_WriteErrorLog( LTrim( Str( ::Cn:Errors( 0 ):Number() ) ) + " " + ;
            ::Cn:Errors( 0 ):Description() + hb_Eol() + ;
            "Full SQL:" + hb_Eol() + ;
            cSQL, 3 )
      ENDIF
      IF ! lOk
         IF lError
            Eval( ErrorBlock() )
            QUIT
         ENDIF
      ENDIF
   ENDIF

   RETURN Nil

METHOD ExecuteReturnRS( cSQL, lError ) CLASS ADOClass

   LOCAL lOk := .F., Rs //, nKey

   IF ::Cn == Nil
      RETURN Nil
   ENDIF
   hb_Default( @lError, .T. )
   cSQL := iif( cSQL == Nil, ::cSQL, cSQL ) // não pode usar hb_Default
   IF ::Cn:State() != AD_STATE_OPEN
      ::Open()
   ENDIF
   cSQL := Trim( cSQL )
   IF Right( AllTrim( cSQL ), 1 ) != ";"
      cSQL += ";"
   ENDIF
   IF Len( Trim( cSQL ) ) != 0
      BEGIN SEQUENCE WITH __BreakBlock()
         Rs := ::Cn:Execute( cSQL )
         lOk := .T.
      ENDSEQUENCE
      IF ! lOk
         Errorsys_WriteErrorLog( LTrim( Str( ::Cn:Errors( 0 ):Number( ) ) ) + " " + ;
            ::Cn:Errors( 0 ):Description() + hb_Eol() + ;
            "Full SQL:" + hb_Eol() + ;
            cSQL, 3 )
      ENDIF
      IF ! lOk
         IF lError
            Eval( ErrorBlock() )
            QUIT
         ENDIF
      ENDIF
   ENDIF

   RETURN Rs

METHOD ReturnFunction( ... ) CLASS ADOClass

   LOCAL cSQL, aItem, aList := hb_AParams(), oRs, xValue

   cSQL := "SELECT " + aList[ 1 ]
   hb_ADel( aList, 1, .T. )

   cSQL += "("
   FOR EACH aItem IN aList
      cSQL += ValueSQL( aItem )
      cSQL += iif( aItem:__ENumIsLast(), "", "," )
   NEXT
   cSQL += ")"
   oRs := ::ExecuteReturnRS( cSQL )
   IF oRs != Nil
      xValue := oRs:Fields(0):Value
      oRs:Close()
   ENDIF

   RETURN xValue

METHOD FStru( xField ) CLASS ADOClass

   LOCAL cName, cType, nLen, nDec, nType

   IF ::Rs == Nil
      RETURN { "NIL", "C", 0, 0 }
   ENDIF
   cName := Upper( Trim( ::Rs:Fields( xField ):Name ) )
   nType := ::Rs:Fields( xField ):Type
   // Size is not allways right
   DO CASE
   CASE nType == AD_BOOLEAN
      cType := "L"
      nLen  := 1
      nDec  := 0
   CASE hb_AScan( { AD_DATE, AD_DBDATE, AD_DBTIME, AD_DBTIMESTAMP }, nType ) != 0
      cType := "D"
      nLen  := 8
      nDec  := 0
   CASE hb_AScan( { AD_BIGINT, AD_SMALLINT, AD_TINYINT, AD_INTEGER, AD_UNSIGNEDTINYINT, AD_UNSIGNEDSMALLINT, AD_UNSIGNEDINT, AD_UNSIGNEDBIGINT }, nType ) != 0
      cType := "N"
      nLen  := ::rs:Fields( xField ):Precision
      nDec  := 0
   CASE hb_AScan( { AD_DOUBLE, AD_SINGLE }, nType ) != 0
      cType := "N"
      nLen  := ::Rs:Fields( xField ):Precision
      nDec  := ::Rs:Fields( xField ):NumericScale
   CASE nType == AD_CURRENCY
      cType := "N"
      nLen  := ::Rs:Fields( xField ):Precision
      nDec  := ::Rs:Fields( xField ):NumericScale
   CASE hb_AScan( { AD_DECIMAL, AD_NUMERIC, AD_VARNUMERIC }, nType ) != 0
      cType := "N"
      nLen  := ::Rs:Fields( xField ):Precision
      nDec  := ::Rs:Fields( xField ):NumericScale
   CASE hb_AScan( { AD_BSTR, AD_CHAR, AD_VARCHAR, AD_LONGVARCHAR, AD_WCHAR, AD_VARWCHAR, AD_LONGVARWCHAR }, nType ) > 0
      cType := "C"
      nLen := ::Rs:Fields( xField ):DefinedSize
      IF nLen > 255
         cType := "M"
         nLen := 10
      ENDIF
      nDec := 0
   CASE hb_AScan( { AD_BINARY, AD_VARBINARY, AD_LONGVARBINARY }, xField ) != 0
      cType := "M"
      nLen  := 10
      nDec  := 0
   OTHERWISE
      MsgStop( "Undefined ADO Type " + Ltrim( Str( ::Rs:Fields( xField ):Type ) ) )
      cType := "M"
      nLen  := 10
      nDec  := 0
   ENDCASE
   IF cType == "N"
      nLen := iif( nLen < 0, 13, nLen )
      nLen := iif( nLen > 15, 15, nLen )
      nDec := iif( nDec < 0, 6, nDec )
      nDec := iif( nDec > 6, 6, nDec )
      IF nDec != 0
         nLen := nLen + nDec + 1
      ENDIF
   ENDIF

   RETURN { cName, cType, nLen, nDec }

METHOD FieldSQL( xField, cQuery ) CLASS ADOClass

   LOCAL Rs, xValue

   Rs     := ::ExecuteReturnRS( cQuery )
   xValue := Rs:Fields( xField ):Value
   Rs:Close()

   RETURN xValue

METHOD String( xField, nLen ) CLASS ADOClass

   LOCAL xValue

   IF ::Eof()
      xValue := ""
   ELSE
      xValue := ::Rs:Fields( xField ):Value
   ENDIF
   DO CASE
   CASE ValType( xValue ) == "N"
      xValue := Ltrim( Str( xValue ) )
   CASE ValType( xValue ) == "D"
      xValue := Dtoc( xValue )
   CASE ValType( xValue ) == "C"
      xValue := Trim( xValue )
   OTHERWISE
      xValue := ""
   ENDCASE
   IF nLen != Nil
      xValue := Pad( xValue, nLen )
   ENDIF

   RETURN xValue

METHOD Number( xField, nLen, nDec ) CLASS ADOClass

   LOCAL xValue

   IF ::Eof()
      xValue := 0
   ELSE
      xValue := ::Rs:Fields( xField ):Value
   ENDIF
   DO CASE
   CASE ValType( xValue ) == "N"
   CASE ValType( xValue ) == "C"
      xValue := Val( xValue )
   OTHERWISE
      xValue := 0
   ENDCASE
   xValue := Val( hb_NTos( xValue ) )
   IF ValType( nLen ) == "N" .AND. ValType( nDec ) != "N"
      Errorsys_WriteErrorLog( "Change source code to do not inform decimals", 3 )
      nLen := Nil
   ENDIF

   RETURN xValue

METHOD Date( xField ) CLASS ADOClass

   LOCAL xValue

   IF ::Eof()
      xValue := Ctod( "" )
   ELSE
      xValue := ::Rs:Fields( xField ):Value
   ENDIF
   DO CASE
   CASE ValType( xValue ) == "D"
   OTHERWISE
      xValue := Ctod("")
   ENDCASE

   RETURN xValue

METHOD ExecuteReturnValue( cCmd ) CLASS ADOClass

   LOCAL xResultado, oRs

   oRs := ::ExecuteReturnRS( cCmd )
   IF oRs == Nil
      RETURN Nil
   ENDIF
   IF oRs:Eof()
      oRs:Close()
      RETURN Nil
   ENDIF
   xResultado := oRs:Fields( 0 ):Value
   oRs:Close()

   RETURN xResultado

METHOD Value( xField ) CLASS ADOClass

   LOCAL xValue, cType

   cType := ::FType( xField )
   DO CASE
   CASE cType == "N"
      xValue := ::Number( xField )
   CASE cType == "D"
      xValue := ::Date( xField )
   CASE cType == "C"
      xValue := ::String( xField )
   OTHERWISE
      xValue := ::String( xField )
   ENDCASE

   RETURN xValue

METHOD SQLToDbf( oStructure ) CLASS ADOClass

   LOCAL nSelect, cDbfFile, nCont, oElement

   ::Execute()

   IF ::Rs == Nil
      IF oStructure == Nil
         oStructure := { { "NONE", "C", 5, 0 } }
      ENDIF
   ENDIF
   IF oStructure == Nil
      oStructure := {}
      FOR nCont = 1 TO ::Rs:Fields:Count()
         AAdd( oStructure, ::FStru( nCont - 1 ) )
      NEXT
   ELSE
      FOR EACH oElement IN oStructure
         IF Len( oElement ) < 4
            AAdd( oElement, 0 )
         ENDIF
      NEXT
   ENDIF
   nSelect  := Select()
   cDbfFile := MyTempFile( "DBF" )
   SELECT 0
   dbCreate( cDbfFile, oStructure )
   USE ( cDbfFile ) ALIAS SQLToDbf
   DO WHILE ! ::Rs:Eof()
      RecAppend()
      FOR nCont = 1 TO Len( oStructure )
         DO CASE
         CASE oStructure[ nCont, 2 ] == "N" ; FieldPut( nCont, ::Number( oStructure[ nCont, 1 ] ) )
         CASE oStructure[ nCont, 2 ] == "D" ; FieldPut( nCont, ::Date( oStructure[ nCont, 1 ] ) )
         OTHERWISE                          ; FieldPut( nCont, ::String( oStructure[ nCont, 1 ] ) )
         ENDCASE
      NEXT
      ::Rs:MoveNext()
   ENDDO
   USE
   SELECT ( nSelect )
   ::CloseRecordset()

   RETURN cDbfFile

METHOD DatabaseList() CLASS ADOClass

   LOCAL aList := {}

   ::Execute( "SHOW DATABASES" )
   DO WHILE ! ::Eof()
      IF ::String( "Database" ) == "information_schema"
         ::MoveNext()
         LOOP
      ENDIF
      AAdd( aList, ::String( "Database" ) )
      ::MoveNext()
   ENDDO
   ::CloseRecordset()

   RETURN aList

METHOD TableList() CLASS ADOClass

   LOCAL acTableList := {}, Rs

   IF ".XLS" $ Upper( ::cn:ConnectionString )
      rs := ::cn:openSchema(20) // adSchemaTables
      DO WHILE ! Rs:Eof()
         IF ! "Print_Are" $ rs:Fields( "Table_Name" ):Value .AND. ;
               ! "FilterDatabase" $ rs:Fields( "Table_Name" ):Value
            AAdd( acTableList, "[" + rs:Fields( "Table_Name" ):Value + "]" )
         ENDIF
         rs:MoveNext()
      ENDDO
      rs:Close()
   ELSE
      // SHOW TABLES - show view too
      ::Execute( "SELECT DISTINCT table_name AS TABELA FROM information_schema.TABLES WHERE table_schema=DATABASE()" )
      DO WHILE ! ::Eof()
         AAdd( acTableList, ::Value( "TABELA" ) )
         ::MoveNext()
      ENDDO
      ::CloseRecordset()
   ENDIF

   RETURN acTableList

METHOD TableExists( cTable ) CLASS ADOClass

   LOCAL nQtd

   nQtd := ::ExecuteReturnValue( "SELECT COUNT(*)" + ;
      " FROM information_schema.TABLES" + ;
      " WHERE table_schema=DATABASE() AND table_name=" + StringSQL( cTable ) )

   RETURN nQtd > 0

METHOD IndexExists( cIndex, cTable ) CLASS ADOClass

   RETURN hb_AScan( ::IndexList( cTable ), { | e | Upper( e ) == Upper( cIndex ) } ) != 0

METHOD FieldList( cTable ) CLASS ADOClass

   LOCAL acFieldList := {}

   ::cSQL := "SELECT COLUMN_NAME AS CAMPO FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=" + StringSQL( cTable )
   ::Execute()

   DO WHILE ! ::Eof()
      AAdd( acFieldList, ::Value( "CAMPO" ) )
      ::MoveNext()
   ENDDO
   ::CloseRecordset()

   RETURN acFieldList

METHOD FieldExists( cField, cTable ) CLASS ADOClass

   LOCAL nQtd

   IF cTable == Nil
      MsgStop( "Field test without table name (field,table) (FieldExists), check log error" )
      Errorsys_WriteErrorLog( "Field test without table name (field,table)", 2 )
   ENDIF
   nQtd := ::ExecuteReturnValue( "SELECT COUNT(*)" + ;
      " FROM information_schema.COLUMNS" + ;
      " WHERE TABLE_SCHEMA=DATABASE()" + ;
      " AND TABLE_NAME=" + StringSQL( cTable ) + ;
      " AND COLUMN_NAME=" + StringSQL( cField ) )

   RETURN nQtd > 0

METHOD IndexList( cTable ) CLASS ADOClass

   LOCAL acIndexList := {}

   ::cSQL := "SHOW INDEX FROM " + cTable
   ::Execute()
   DO WHILE ! ::Eof()
      IF ::Number( "SEQ_IN_INDEX" ) == 1
         AAdd( acIndexList, ::Value( "KEY_NAME" ) )
      ENDIF
      ::MoveNext()
   ENDDO
   ::CloseRecordset()

   RETURN acIndexList

METHOD QueryExecuteInsert( cTable, lIgnore ) CLASS ADOClass

   LOCAL oField, cSQL, nValue

   hb_Default( @lIgnore, .F. )
   cSQL := "INSERT " + iif( lIgnore, "IGNORE ", "" ) + "INTO " + cTable + " ( "

   FOR EACH oField IN ::aQueryList
      cSQL += oField[ 1 ]
      IF ! oField:__EnumIsLast
         cSQL += ", "
      ENDIF
   NEXT
   cSQL += " ) VALUES ( "
   FOR EACH oField in ::aQueryList
      cSQL += ValueSQL( oField[ 2 ] )
      IF ! oField:__EnumIsLast
         cSQL += ", "
      ENDIF
   NEXT
   cSQL += " )"
   ::ExecuteNoReturn( cSQL )
   nValue := ::ExecuteReturnValue( "SELECT LAST_INSERT_ID()" )
   IF ValType( nValue ) == Nil
      nValue := 1
   ENDIF

   RETURN nValue

METHOD QueryExecuteUpdate( cTable, cWhere ) CLASS ADOClass

   LOCAL oField, cSQL := "UPDATE " + cTable + " SET "

   IF Len( ::aQueryList ) == 0
      RETURN Nil
   ENDIF
   FOR EACH oField IN ::aQueryList
      cSQL += oField[ 1 ] + "=" + ValueSQL( oField[ 2 ] )
      IF ! oField:__EnumIsLast
         cSQL += ", "
      ENDIF
   NEXT
   cSQL += " WHERE " + cWhere
   ::ExecuteNoReturn( cSQL )

   RETURN Nil

METHOD DBFQueryExecuteInsert() CLASS ADOClass

   RecAppend()
   ::DbfQueryExecuteUpdate()

   RETURN Nil

METHOD DBFQueryExecuteUpdate() CLASS ADOClass

   LOCAL oElement

   RecLock()
   FOR EACH oElement IN ::aQueryList
      FieldPut( FieldPos( oElement[ 1 ] ), oElement[ 2 ] )
   NEXT
   RecUnlock()

   RETURN Nil

METHOD MultiQueryExecuteInsert( lEnd ) CLASS ADOClass

   LOCAL oField, lInicial := .F.

   hb_Default( @lEnd, .F. )

   IF lEnd
      IF Len( ::cSQL ) != 0
         ::ExecuteNoReturn( ::cSQL )
      ENDIF
      RETURN Nil
   ENDIF
   IF Len( ::cSQL ) == 0
      ::cSQL := "INSERT INTO " + ::cMultiQueryTable + " ( "
      FOR EACH oField IN ::aQueryList
         ::cSQL += oField[ 1 ]
         IF ! oField:__EnumIsLast
            ::cSQL += ", "
         ENDIF
      NEXT
      ::cSQL += " ) VALUES "
      lInicial := .T.
   ENDIF
   IF ! lInicial
      ::cSQL += ", "
   ENDIF
   ::cSQL += " ( "
   FOR EACH oField in ::aQueryList
      ::cSQL += ValueSQL( oField[ 2 ] )
      IF ! oField:__EnumIsLast
         ::cSQL += ", "
      ENDIF
   NEXT
   ::cSQL += " )"
   IF Len( ::cSQL ) > SQL_CMD_MAXSIZE
      ::ExecuteNoReturn( ::cSQL )
      ::cSQL := ""
   ENDIF

   RETURN Nil

METHOD TableRecCount( cTable, cFilter ) CLASS ADOClass

   RETURN ::ExecuteReturnValue( "SELECT COUNT(*) FROM " + cTable + iif( cFilter == Nil, "", " WHERE " + cFilter ) )

METHOD RsCreate( aStru ) CLASS ADOClass

   LOCAL oADO, oElement

   oADO := win_OleCreateObject( "ADODB.Recordset" )
   FOR EACH oElement IN aStru
      DO CASE
      CASE oElement[ DBS_TYPE ] == "I"
         oADO:Fields:Append( oElement[ DBS_NAME ], AD_BIGINT, oElement[ DBS_LEN ], AD_FLD_KEYCOLUMN )
      CASE oElement[ DBS_TYPE ] == "N"
         IF oElement[ DBS_DEC ] == 0
            oADO:Fields:Append( oElement[ DBS_NAME], AD_BIGINT, oElement[ DBS_LEN ] )
         ELSE
            oADO:Fields:Append( oElement[ DBS_NAME ], AD_DOUBLE, oElement[ DBS_LEN ] )
            oADO:Fields( oElement[ DBS_NAME ] ):NumericScale := oElement[ DBS_DEC ]
         ENDIF
      CASE oElement[ DBS_TYPE ] == "C"
         oADO:Fields:Append( oElement[ DBS_NAME ], AD_VARCHAR, oElement[ DBS_LEN ] )
      CASE oElement[ DBS_TYPE ] == "D"
         oADO:Fields:Append( oElement[ DBS_NAME ], AD_DATE )
      CASE oElement[ DBS_TYPE ] == "M"
         oADO:Fields:Append( oElement[ DBS_NAME ], AD_LONGVARCHAR )
      ENDCASE
   NEXT

   ::Rs := oADO
   ::Rs:Open()

   RETURN Nil

FUNCTION ExcelConnection( cFileName, cVersion )

   LOCAL oConexao

   DO CASE
   CASE ValType( cVersion ) == "C"
   CASE ".xlsx" $ Lower( cFileName ); cVersion := "12.0 Xml" // XLSX
   //CASE "t00" $ Lower( cFileName )  ; cVersion := "5.0"  // 95 seems no more available
   OTHERWISE                        ; cVersion := "8.0" // 97/2000/XP
   ENDCASE
   oConexao := win_OleCreateObject( "ADODB.Connection" )
   oConexao:ConnectionString := ;
      [Provider=Microsoft.ACE.OLEDB.12.0;Data Source=] + cFileName + ;
      [;Extended Properties="Excel ] + cVersion + [;HDR=YES";]
      /* Allow Formula=true; consider start = as formula or not */

   RETURN oConexao

FUNCTION MySQLConnection( cServer, cDatabase, cUser, cPassword, nPort )

   LOCAL cnConnection, cString

   hb_Default( @nPort, 3306 )
   cString := iif( win_OsIs10(), "Provider=MSDASQL;", "" )
   cString += "Driver={MySQL ODBC 5.3 ANSI Driver};"
   cString += "Server=" + cServer + ";" + ;
      "Port=" + Ltrim( Str( nPort ) ) + ";" + ;
      "Stmt=;"    + ;
      "Database=" + cDatabase + ";" + ;
      "User="     + cUser + ";" + ;
      "Password=" + cPassword + ";" + ;
      "Collation=latin1_swedish_ci;" + ;
      "AUTO_RECONNECT=1;" + ;
      "COMPRESSED_PROTO=0"

   cnConnection := win_OleCreateObject( "ADODB.Connection" )
   IF ValType( cnConnection ) != "O"
      MsgStop( "Não foi possível criar a conexão com o banco de dados" + hb_Eol() + ;
         "Verifique com o administrador do computador" )
      QUIT
   ENDIF
   cnConnection:ConnectionString  := "" // em caso de erro não aparece senha
   cnConnection:ConnectionString  := cString
   cnConnection:CursorLocation    := AD_USE_CLIENT
   cnConnection:CommandTimeOut    := 600 // seconds
   cnConnection:ConnectionTimeOut := 1200 // seconds

   RETURN cnConnection

FUNCTION ADSConnection( cPath )

   LOCAL oConexao := win_OleCreateObject( "ADODB.Connection" )

   oConexao:ConnectionString := "Provider=Advantage OLE DB Provider;" + ;
      "Mode=Share Deny None;" + ;
      "Show Deleted Records in DBF Tables with Advantage=False;" + ;
      "Data Source=" + cPath + ";Advantage Server Type=ADS_Local_Server;" + ;
      "TableType=ADS_CDX;Security Mode=ADS_IGNORERIGHTS;" + ;
      "Lock Mode=Compatible;" + ;
      "Use NULL values in DBF Tables with Advantage=True;" + ;
      "Exclusive=No;Deleted=No;"
   oConexao:CursorLocation := AD_USE_CLIENT
   oConexao:CommandTimeOut := 20

   RETURN oConexao

FUNCTION SQLiteConnection( cFileName )

   LOCAL oConexao := win_OleCreateObject( "ADODB.Connection" )

   oConexao:ConnectionString := iif( win_OsIs10(), "Provider=MSDASQL;", "" ) + ;
      "Driver={SQLite3 ODBC Driver};Database=" + cFileName + ";"
   oConexao:CursorLocation := AD_USE_CLIENT
   oConexao:CommandTimeOut := 20

   RETURN oConexao

FUNCTION AccessConnection( cFile )

   LOCAL oConexao := win_OleCreateObject( "ADODB.Connection" )
   LOCAL oCat     := win_OleCreateObject( "ADOX.Catalog" )

   oConexao:ConnectionString := "Provider='Microsoft.Jet.OLEDB.4.0'; Data Source='" + cFile + ";"
   IF ! File( cFile )
      oCat:Create( oConexao )
      oCat:Close()
   ENDIF

   RETURN oConexao

FUNCTION StringSQL( cString, nLen ); RETURN ValueSQL( cString, "C", nLen )

FUNCTION DateSQL( dDate ); RETURN ValueSQL( dDate, "D" )

FUNCTION NumberSQL( xValue ); RETURN ValueSQL( xValue, "N" )

FUNCTION ValueSQL( xValue, cType, nLen )

   LOCAL cString, cValType

   cValType := ValType( xValue )
   hb_Default( @cType, cValType )
   DO CASE
   CASE xValue == Nil
      cString := "NULL"
   CASE cType == "D"
      IF Empty( xValue ) .OR. ValType( xValue ) != "D"
         cString := "NULL"
      ELSE
         cString := ['] + hb_Dtoc( xValue, "YYYY-MM-DD" ) + [']
      ENDIF
   CASE cType == "N"
      IF cValType == "C"
         xValue := Val( xValue )
      ENDIF
      cString := Ltrim( hb_NTos( xValue ) )
      IF "." $ cString
         DO WHILE Right( cString, 1 ) == "0"
            cString := Substr( cString, 1, Len( cString ) - 1 )
         ENDDO
         IF Right( cString, 1 ) == "."
            cString := Substr( cString, 1, Len( cString ) - 1 )
         ENDIF
      ENDIF
   OTHERWISE
      IF cValType == "N"
         xValue := hb_NTos( xValue )
      ENDIF
      cString := Trim( xValue )
      IF nLen != Nil
         cString := Pad( cString, nLen )
      ENDIF
      IF "\" $ cString
         cString := StrTran( cString, [\], [\\] )
      ENDIF
      IF ['] $ cString
         cString := StrTran( cString, ['], [\'] )
      ENDIF
      IF Chr(13) $ cString
         cString := StrTran( cString, Chr(13), "\" + Chr(13) )
      ENDIF
      IF Chr(10) $ cString
         cString := StrTran( cString, Chr(10), "\" + Chr(10) )
      ENDIF
      cString := ['] + AllTrim( cString ) + [']
   ENDCASE

   RETURN cString

FUNCTION ADORecCount( cTable, cWhere, cnSQL )

   LOCAL nValue

   IF cnSQL == Nil
      cnSQL := ADOLocal()
   ENDIF
   WITH OBJECT cnSQL
      :cSQL := "SELECT COUNT(*) AS QTD FROM " + cTable + iif( cWhere == Nil .OR. Empty( cWhere ), "", " WHERE " + cWhere )
      :Execute()
      nValue := :Number( "QTD" )
      :CloseRecordset()
   ENDWITH

   RETURN nValue

FUNCTION ADOField( cField, cType, cTable, cWhere, cnSQL )

   LOCAL xResult

   IF cnSQL == Nil
      cnSQL := ADOLocal()
   ENDIF
   WITH OBJECT cnSQL
      :cSQL := "SELECT " + cField + " FROM " + cTable + iif( cWhere == Nil .OR. Empty( cWhere ), "", " WHERE " + cWhere )
      :Execute()
      DO CASE
      CASE cType == "N" ; xResult := :Number( cField )
      CASE cType == "D" ; xResult := :Date( cField )
      OTHERWISE         ; xResult := :String( cField )
      ENDCASE
      :CloseRecordset()
   ENDWITH

   RETURN xResult

FUNCTION ADOExecuteReturnValue( cSQL )

   LOCAL cnSQL := ADOLocal(), xValue

   cnSQL:Execute( cSQL )

   IF ! cnSQL:Eof()
      xValue := cnSQL:Fields( 0 ):Value
   ENDIF

   cnSQL:CloseRecordset()

   RETURN xValue

FUNCTION ArrayAsSQL( aList )

   LOCAL cTxt := "", oItem

   FOR EACH oItem IN aList
      IF oItem:__EnumIndex != 1
         cTxt += ", "
      ENDIF
      cTxt += ValueSQL( oItem )
   NEXT

   RETURN cTxt

FUNCTION InverseArray( aSource )

   LOCAL aTarget, nRow, nCol, nMaxRow, nMaxCol

   nMaxRow := Len( aSource[ 1 ] )
   nMaxCol := Len( aSource )

   aTarget := Array( nMaxRow, nMaxCol )

   FOR nRow = 1 TO nMaxRow
      FOR nCol = 1 TO nMaxCol
         aTarget[ nRow, nCol ] := aSource[ nCol, nRow ]
      NEXT
   NEXT

   RETURN aTarget

FUNCTION ADOSkipper( cnSQL, nSkip )

   LOCAL nRec := cnSQL:AbsolutePosition()

   IF ! cnSQL:Eof()
      cnSQL:Move( nSkip )
      IF cnSQL:Eof()
         cnSQL:MoveLast()
      ENDIF
      IF cnSQL:Bof()
         cnSQL:MoveFirst()
      ENDIF
   ENDIF

   RETURN cnSQL:AbsolutePosition() - nRec

// for most used connection
FUNCTION ADOLocal()

   LOCAL cnSQL

   cnSQL := ADOClass():New( /*     */ )

   RETURN cnSQL

