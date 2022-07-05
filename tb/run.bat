@chcp 65001
:cmsl
@echo ============================
@echo input 0-9 or c to choice what you want.
@echo ----------------------------
@echo 0: load inst.txt and sim rtl
@echo 1: regress ISA test
@echo 2: .bin file turn into inst.txt
@echo 3: load .bin file and sim rtl
@echo 4: show last wave file
@echo c: clean tb file
@echo ============================
@set /p cmchc=Enter number:

@if %cmchc% == 0 (python tools/isa_test.py sim_rtl & goto cmsl)^
else if %cmchc% == 1 (python tools/isa_test.py all_isa & goto cmsl)^
else if %cmchc% == 2 (python tools/isa_test.py tsr_bin & goto cmsl)^
else if %cmchc% == 3 (python tools/isa_test.py sim_bin & goto cmsl)^
else if %cmchc% == 4 (gtkwave tb.lxt & goto cmsl)^
else if %cmchc% == c (del tb *.lxt inst.txt & @echo clean & goto cmsl)^
else (echo Error 0 & goto cmsl)

pause