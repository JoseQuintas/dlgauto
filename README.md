-----------
Application
-----------

This is an application simulator.
It uses DBF structure to construct dialogs and others.

It uses an array, that begins with DBF structure, and adds more needed information/elements.

LIB defined by variables created by HBMK when use HBC
At momment HBMK_HAS_HWGUI, HBMK_HAS_HMGE, HBMK_HAS_OOHG, HBMK_HAS_GTWVG

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

-------
Modules
-------

frm_class.prg       - create a complete dialog for a database table with or without setup
frm_browse.prg      - create a browse for a database, exclusive or part of a dialog
frm_browseclick.prg - from a browse on dialog, create a dialog for database table used on browse
frm_buttons.prg     - create the buttons on "toolbar"
frm_dialog.prg      - create the dialog for the database table
frm_edit.prg        - create all controls used on dialog
frm_main.prg        - main class execute
frm_preview.prg     - preview of report for database table
frm_print.prg       - generate report for database table
frm_valid.prg       - validate "textbox", can show description, can open browse or dialog
lib_xxxx.prg        - routines of specific library (hmg3, hmg extended, oohg, fivewin, gtwvg)

test.prg            - main procedure, load setup
test_dbf.prg        - create default DBFs
test_dlglogin.prg   - login dialog
test_menu.prg       - menu of DBFs
test_nodatabase.prg - sample without database
test_setup.prg      - create default setup for DBFs created on test_dbf.prg
