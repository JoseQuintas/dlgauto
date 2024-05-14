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
