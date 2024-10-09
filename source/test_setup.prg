/*
test_dbf - setup on json, may change at any time
*/

FUNCTION test_Setup()

   LOCAL cTxt := ""

   cTxt += '[' + hb_Eol()
   cTxt += '[ "LOGIN", [ false ] ],' + hb_Eol()

   cTxt += '[ "KEYLIST", [' + hb_Eol()
   cTxt += '[ "cDbfName",    "cFieldName", "nBrowseOrder"],' + hb_Eol()
   cTxt += '[ "DBCLIENT",    "IDCLIENT",   2 ],' + hb_Eol()
   cTxt += '[ "DBPRODUCT",   "IDPRODUCT",  2 ],' + hb_Eol()
   cTxt += '[ "DBUNIT",      "IDUNIT",     2 ],' + hb_Eol()
   cTxt += '[ "DBSELLER",    "IDSELLER",   2 ],' + hb_Eol()
   cTxt += '[ "DBBANK",      "IDBANK",     2 ],' + hb_Eol()
   cTxt += '[ "DBGROUP",     "IDGROUP",    2 ],' + hb_Eol()
   cTxt += '[ "DBSTOCK",     "IDSTOCK"       ],' + hb_Eol()
   cTxt += '[ "DBFINANC",    "IDFINANC"      ],' + hb_Eol()
   cTxt += '[ "DBSTATE",     "IDSTATE",    2 ],' + hb_Eol()
   cTxt += '[ "DBTICKET",    "IDTICKET"      ],' + hb_Eol()
   cTxt += '[ "DBTICKETPRO", "IDTICKETPRO"   ],' + hb_Eol()
   cTxt += '[ "DBDBF",       "IDDBF",      2 ],' + hb_Eol()
   cTxt += '[ "DBFIELDS",    "IDFIELD",    2 ]' + hb_Eol()
   cTxt += ']],' + hb_Eol()

   cTxt += '[ "SEEKLIST",[' + hb_Eol()
   cTxt += '[ "cDbfOrigin", "cFieldName", "cDbfTarget", "cFieldTarget", "cFieldShow" ],' + hb_Eol()
   cTxt += '[ "DBCLIENT",   "CLSELLER",   "DBSELLER",   "IDSELLER",     "SENAME" ],' + hb_Eol()
   cTxt += '[ "DBCLIENT",   "CLBANK",     "DBBANK",     "IDBANK",       "BANAME" ],' + hb_Eol()
   cTxt += '[ "DBTICKET",   "TICLIENT",   "DBCLIENT",   "IDCLIENT",     "CLNAME" ],' + hb_Eol()
   cTxt += '[ "xxxDBCLIENT",   "CLSTATE",    "DBSTATE",    "IDSTATE",      "STNAME" ],' + hb_Eol()
   cTxt += '[ "DBPRODUCT",  "IEUNIT",     "DBUNIT",     "IDUNIT",       "UNNAME" ],' + hb_Eol()
   cTxt += '[ "DBSTOCK",    "STCLIENT",   "DBCLIENT",   "IDCLIENT",     "CLNAME" ],' + hb_Eol()
   cTxt += '[ "DBSTOCK",    "STPRODUCT",  "DBPRODUCT",  "IDPRODUCT",    "PRNAME" ],' + hb_Eol()
   cTxt += '[ "DBSTOCK",    "STGROUP",    "DBGROUP",    "IDGROUP",      "GRNAME" ],' + hb_Eol()
   cTxt += '[ "DBFINANC",   "FICLIENT",   "DBCLIENT",   "IDCLIENT",     "CLNAME" ],' + hb_Eol()
   cTxt += '[ "DBFINANC",   "FIBANK",     "DBBANK",     "IDBANK",       "BANAME" ]' + hb_Eol()
   cTxt += ']],' + hb_Eol()

   cTxt += '[ "BROWSELIST",[' + hb_Eol()
   cTxt += '[ "cDbfOrigin",  "cFieldName", "cDbfTarget", "nOrder", "cFieldTarget", "cTargetKey", "lEdit", "cTitle" ],' + hb_Eol()
   cTxt += '[ "DBTICKET",    "IDTICKET",   "DBTICKETPRO",2,        "TPTICKET",     "IDTICKEDPRO",true,   "PROD LIST" ],' + hb_Eol()
   cTxt += '[ "DBDBF",       "NAME",       "DBFIELDS",   2,        "DBF",          "IDFIELD",    false,   "DBF LIST" ],' + hb_Eol()
   cTxt += '[ "DBCLIENT",    "IDCLIENT",   "DBFINANC",   2,        "FICLIENT",     "IDFINANC",   true,    "FINANC LIST" ],' + hb_Eol()
   cTxt += '[ "DBCLIENT",    "IDCLIENT",   "DBSTOCK",    2,        "STCLIENT",     "IDSTOCK",    false,   "STOCK LIST" ],' + hb_Eol()
   cTxt += '[ "DBCLIENT",    "IDCLIENT",   "DBTICKET",   2,        "TICLIENT",     "IDTICKET",   true,    "TICKET LIST" ]' + hb_Eol()
   cTxt += ']],' + hb_Eol()

   cTxt += '[ "TYPELIST",[' + hb_Eol()
   cTxt += '[ "cDbfName", "cFieldName", "cType",      "aListMinMax" ],' + hb_Eol()
   cTxt += '[ "DBCLIENT", "CLSTATE",    "COMBOBOX",   ["AC","RS","SP","RJ","PR","RN"] ],' + hb_Eol()
   cTxt += '[ "DBCLIENT", "CLSTATUS",   "CHECKBOX" ],' + hb_Eol()
   cTxt += '[ "DBCLIENT", "CLDATE",     "DATEPICKER" ],' + hb_Eol()
   cTxt += '[ "DBFINANC", "FIDATTOPAY", "DATEPICKER" ],' + hb_Eol()
   cTxt += '[ "DBCLIENT", "CLPAYTERM",  "SPINNER",     [0,120] ]' + hb_Eol()
   cTxt += ']]' + hb_Eol()
   cTxt += ']' + hb_Eol()

   RETURN cTxt
