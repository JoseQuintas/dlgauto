
/* ADO Field Types */

#define AD_EMPTY                        0
#define AD_TINYINT                      16
#define AD_SMALLINT                     2
#define AD_INTEGER                      3
#define AD_BIGINT                       20
#define AD_UNSIGNEDTINYINT              17
#define AD_UNSIGNEDSMALLINT             18
#define AD_UNSIGNEDINT                  19
#define AD_UNSIGNEDBIGINT               21
#define AD_SINGLE                       4
#define AD_DOUBLE                       5
#define AD_CURRENCY                     6
#define AD_DECIMAL                      14
#define AD_NUMERIC                      131
#define AD_BOOLEAN                      11
#define AD_ERROR                        10
#define AD_USERDEFINED                  132
#define AD_VARIANT                      12
#define AD_IDISPATCH                    9
#define AD_IUNKNOWN                     13
#define AD_GUID                         72
#define AD_DATE                         7
#define AD_DBDATE                       133
#define AD_DBTIME                       134
#define AD_DBTIMESTAMP                  135
#define AD_BSTR                         8
#define AD_CHAR                         129
#define AD_VARCHAR                      200
#define AD_LONGVARCHAR                  201
#define AD_WCHAR                        130
#define AD_VARWCHAR                     202
#define AD_LONGVARWCHAR                 203
#define AD_BINARY                       128
#define AD_VARBINARY                    204
#define AD_LONGVARBINARY                205
#define AD_CHAPTER                      136
#define AD_FILETIME                     64
#define AD_PROPVARIANT                  138
#define AD_VARNUMERIC                   139
#define AD_ARRAY                        /* &H2000 */

#define AD_FLD_KEYCOLUMN                0x8000
#define AD_FLD_ISNULLABLE               0x20
#define AD_FLD_MAYBENULL                0x40
#define AD_FLD_UPDATABLE                0x4

/* ADO Cursor Type */
#define AD_OPEN_FORWARDONLY             0
#define AD_OPEN_KEYSET                  1
#define AD_OPEN_DYNAMIC                 2
#define AD_OPEN_STATIC                  3

/* ADO Lock Types */
#define AD_LOCK_READONLY                1
#define AD_LOCK_PESSIMISTIC             2
#define AD_LOCK_OPTIMISTIC              3
#define AD_LOCK_TACHOPTIMISTIC          4

/* ADO Cursor Location */
#define AD_USE_NONE                      1
#define AD_USE_SERVER                    2
#define AD_USE_CLIENT                    3
#define AD_USE_CLIENTBATCH               3

/* Constant Group: ObjectStateEnum */
#define AD_STATE_CLOSED                 0
#define AD_STATE_OPEN                   1
#define AD_STATE_CONNECTING             2
#define AD_STATE_EXECUTING              4
#define AD_STATE_FETCHING               8
#define AD_EXECUTE_NORECORDS           128

#define AD_SCHEMA_TABLES 20

#define SQL_CMD_MAXSIZE                256000
