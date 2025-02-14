call \tools\util\c.bat /cmd \github\dlgauto\source\lib_hwgui.prg hwgui.hbc -hblib
call \tools\util\c.bat /cmd \github\dlgauto\source\lib_hmg3.prg hmg3.hbc -hblib
call \tools\util\c.bat /cmd \github\dlgauto\source\lib_hmge.prg hmge.hbc -hblib
call \tools\util\c.bat /cmd \github\dlgauto\source\lib_oohg.prg oohg.hbc -hblib
SET HB_USER_LDFLAGS=-Wl,--allow-multiple-definition -s -static

