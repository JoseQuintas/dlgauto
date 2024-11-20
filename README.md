-----------
Application
-----------

This is an application simulator.
It uses DBF structure to construct dialogs and others.

It uses an array, that begins with DBF structure, and adds more needed information/elements.

LIB defined by variables created by HBMK when use HBC
At momment HBMK_HAS_HWGUI, HBMK_HAS_HMGE, HBMK_HAS_OOHG, HBMK_HAS_GTWVG, HBMK_HAS_FIVEWIN

-----
Array
-----

Check frm_class.ch to see each element

-------------
configuration
-------------

test.prg contains configuration for DBFs created by it.

- aKeyList:        field key for each dbf
- aSeekList:       to seek code on another dbf
- aBrowseList:     to browse data from another dbf related to current record
- aComboList:      fields to use combobox and options list
- aCheckList:      fields to use checkbox
- aDatePickerList: fields to use datepicker
- aSpinnerList:    fields to use spinner
- aAddOptionList:  buttons to add

-------
Modules
-------

frm_class.prg            - create a complete dialog for a database table with or without setup
frm_ButtonCreate.prg     - buttons on "toolbar"
frm_DialogBrowse.prg     - dialog with browse
frm_DialogData.prg       - dialog for the database table
frm_DialogFree.prg       - dialog without dbf
frm_DialogLogin.prg      - dialog login
frm_DialogMenu.prg       - dialog menu of DBFs
frm_DialogPreview.prg    - dialog to preview single report
frm_EditCreate.prg       - create all controls used on dialog
frm_EditValidate.prg     - validate "textbox", can show description, can open browse or dialog
frm_EventBrowseClick.prg - from a browse on dialog, create a dialog for database table used on browse
frm_EventPrint.prg       - generate report for database table
frm_FuncMain.prg         - main class execute

lib.prg                  - select a library class, include lib_xxxx as part of it
lib_xxxx.prg             - class of specific library (hmg3, hmg extended, oohg, fivewin, gtwvg)

test.prg            - main procedure, load setup
test_dbf.prg        - create default DBFs
test_LoadSetup.prg  - load saved setup
test_setup.prg      - create default setup for DBFs created on test_dbf.prg
