/*
ERRORSYS                                                       *
*/

#include "fileio.ch"
#include "error.ch"
#include "hbgtinfo.ch"
#include "hbmemory.ch"

// put messages to STDERR
#command ? <list,...>   =>  ?? hb_Eol() ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

* Note:  automatically executes at startup

PROCEDURE ERRORSYS

   ErrorBlock( { | e | JoseQuintasError( e ) } )

   RETURN

STATIC FUNCTION JoseQuintasError( e )

   LOCAL nCont, cMessage

   // by default, division by zero yields zero
   IF ( e:GenCode == EG_ZERODIV )
      RETURN 0
   ENDIF

   // build error message
   cMessage := ErrorMessage(e)
   hb_Default( @cMessage )
   IF ! Empty( e:OsCode )
      cMessage += ";(DOS Error " + Ltrim( Str( e:OsCode ) ) + ")"
   ENDIF
   IF cMessage == NIL
      cMessage := ""
   ENDIF

   // Only retry IF open error 2014.09.24.1810
   IF e:OsCode == 64 .AND. e:GenCode == EG_OPEN
      //@ 15, 15 SAY "Servidor sumiu. Tentar novamente em 2 segundos"
      Inkey(5)
      RETURN .T.
   ENDIF

   // For network open error, set NetErr() and subsystem default
   IF ( e:GenCode == EG_OPEN .AND. e:OsCode == 32 .AND. e:CanDefault )
      NetErr( .T. )
      RETURN ( .F. )     // NOTE
   ENDIF

   // for lock error during APPEND BLANK, set NetErr() and subsystem default
   IF ( e:GenCode == EG_APPENDLOCK .AND. e:CanDefault )
      NetErr( .T. )
      RETURN ( .F. )     // NOTE
   ENDIF
   Errorsys_WriteErrorLog( "SYSTEM ERROR", 1 ) // com id maquina
   @ MaxRow(), 0 SAY ""
   ? cMessage
   Errorsys_WriteErrorLog( cMessage )
   nCont := 2
   DO WHILE ( ! Empty( ProcName( nCont ) ) )
      cMessage := "Called from " + Trim( ProcName( nCont ) ) + "(" + Ltrim( Str( ProcLine( nCont ) ) ) + ")"
      ? cMessage
      Errorsys_WriteErrorLog( cMessage )
      nCont++
   ENDDO
   Errorsys_WriteErrorLog( ArgumentList( e ) )
   Errorsys_WriteErrorLog( Replicate( "-", 80 ) )
   ShellExecuteOpen( "notepad.exe", hb_Cwd() + "hb_out.log" )
   // give up
   ErrorLevel( 1 )
   PostQuitMessage( 0 )
   QUIT

   RETURN .F.

STATIC FUNCTION ErrorMessage( e )

   LOCAL cMessage := ""

   // start error message
   BEGIN SEQUENCE WITH __BreakBlock()
      cMessage := if( e:Severity > ES_WARNING, "Error ", "Warning " )
   ENDSEQUENCE

   // add subsystem name IF available
   IF ( ValType( e:SubSystem ) == "C" )
      cMessage += e:SubSystem
   ELSE
      cMessage += "???"
   ENDIF

   // add subsystem's error code IF available
   IF ( ValType( e:SubCode ) == "N" )
      cMessage += ( "/" + Ltrim(Str( e:SubCode ) ) )
   ELSE
      cMessage += "/???"
   ENDIF

   // add error description IF available
   IF ( ValType( e:Description ) == "C" )
      cMessage += ( "  " + e:Description )
   ENDIF

   // add either filename or operation
   IF ! Empty( e:Filename )
      cMessage += (": " + e:Filename )
   ELSEIF ! Empty( e:Operation )
      cMessage += ( ": " + e:Operation )
   ENDIF

   RETURN cMessage

FUNCTION Errorsys_WriteErrorLog( cText, nDetail )

   LOCAL hFileOutput, cFileName, nCont, nCont2

   hb_Default( @cText, "" )
   hb_Default( @nDetail, 0 )

   IF nDetail > 0
      Errorsys_WriteErrorLog()
      Errorsys_WriteErrorLog( "Error on "       + Dtoc( Date() ) + " " + Time() )
      Errorsys_WriteErrorLog( "EXE Name; " + hb_Argv(0) )
      Errorsys_WriteErrorLog( "Memory:" + Ltrim( Str( Memory(0) / 1024 / 1024, 5, 2 ) ) + " GB" )
      Errorsys_WriteErrorLog( "Mem.VM:" + Ltrim( Str( Memory( HB_MEM_VM ) / 1024 / 1024, 5, 2 ) ) + " GB" )
      Errorsys_WriteErrorLog( "Alias:  "        + Alias() )
      Errorsys_WriteErrorLog( "Folder: "        + hb_cwd() )
      Errorsys_WriteErrorLog( "Windows: "       + OS() )
      Errorsys_WriteErrorLog( "Computer Name: " + GetEnv( "COMPUTERNAME" ) )
      Errorsys_WriteErrorLog( "Windows User: "  + GetEnv( "USERNAME" ) )
      Errorsys_WriteErrorLog( "Logon Server: "  + Substr( GetEnv( "LOGONSERVER" ), 2 ) )
      Errorsys_WriteErrorLog( "User Domain: "   + GetEnv( "USERDOMAIN" ) )
      Errorsys_WriteErrorLog( "Harbour: "       + Version() )
      Errorsys_WriteErrorLog( "Compiler: "      + HB_Compiler() )
      Errorsys_WriteErrorLog( "GT: "            + hb_GtInfo( HB_GTI_VERSION ) )
      Errorsys_WriteErrorLog()
      Errorsys_WriteErrorLog()
   ENDIF
   cFileName := "hb_out.log"
   IF ! File( cFileName )
      hFileOutput := fCreate( cFileName, FC_NORMAL )
      fClose( hFileOutput )
   ENDIF

   hFileOutput := fOpen( cFileName, FO_READWRITE )
   fSeek( hFileOutput, 0, FS_END )
   fWrite( hFileOutput, cText + Space(2) + hb_Eol() )
   IF nDetail > 1
      nCont  := 1
      nCont2 := 0
      DO WHILE nCont2 < 5
         IF Empty( ProcName( nCont ) )
            nCont2++
         ELSE
            cText := "Called from " + Trim( ProcName( nCont ) ) + "(" + Ltrim( Str( ProcLine( nCont ) ) ) + ")"
            fWrite( hFileOutput, cText + hb_Eol() )
         ENDIF
         nCont++
      ENDDO
      fWrite( hFileOutput, hb_Eol() )
   ENDIF
   fClose( hFileOutput )

   RETURN NIL

STATIC FUNCTION ArgumentList( e )

   LOCAL xArg, cArguments := ""

   IF ValType( e:Args ) == "A"
      FOR EACH xArg IN e:Args
         cArguments += [(] + Ltrim( Str( xArg:__EnumIndex() ) ) + [) = Tipo: ] + ValType( xArg )
         IF xArg != NIL
            cArguments +=  [ Valor: ] + Alltrim( hb_ValToExp( xArg ) )
         ENDIF
         cArguments += hb_Eol()
      NEXT
   ENDIF

   RETURN cArguments

#define WIN_SW_SHOWNORMAL 1

FUNCTION ShellExecuteOpen( cFileName, cParameters, cPath, nShow )

   wapi_ShellExecute( Nil, "open", cFileName, cParameters, cPath, hb_DefaultValue( nShow, WIN_SW_SHOWNORMAL ) )

   RETURN Nil
