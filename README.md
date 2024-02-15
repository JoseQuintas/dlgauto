LIB defined by variables created by HBMK when use HBC
At momment HBMK_HAS_HWGUI, HBMK_HAS_HMGE, HBMK_HAS_OOHG, HBMK_HAS_GTWVG

About the big array:

To work with DBFs need:

Field name          ( CFG_FNAME )
Field type          ( CFG_FTYPE )
Field len           ( CFG_FLEN )
Field decimals      ( CFG_FDEC )

A table has a key   ( CFG_ISKEY )

To works on screen need complement

a caption           ( CFG_CAPTION )
a variable          ( CFG_VALUE )
a validation        ( CFG_VALID )

GUI have label and textbox
label (CFG_CCONTROL)
textbox (CFG_FCONTROL)

if the field is a key to another file

table to make search    ( CFG_VTABLE )
field destination       ( CFG_VFIELD )
field to show content   ( CFG_VSHOW )

The label for this information on GUI: ( CFG_VCONTROL )
it is needed to know size for this label ( CFG_VLEN )

on gui buttons have action ( CFG_ACTION )

To create a browse of a related data

There exists a table for browse ( CFG_BTABLE )
You need a field reference from master table ( CFG_BKEYFROM )
May be need to use another index ord ( CFG_BINDEXORD )
There exists the field reference on browse table ( CFG_BKEYTO )
Browse table have second field for index   ( CFG_BKEYTO2 )
Browse table can be edited or not  ( CFG_BEDIT )

check ch if there are elements added

