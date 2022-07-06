@chcp 65001
:cmsl
@echo ============================
@echo input 0-9 or c to choice what you want.
@echo Num: Function--------------------Tools
@echo 0: load inst.txt and sim rtl-----iverilog   
@echo 1: regress ISA test--------------iverilog   
@echo 2: .bin file turn into inst.txt
@echo 3: load .bin file and sim rtl----iverilog   
@echo 4: show last wave file-----------gtkwave
@echo 5: load inst.txt and sim rtl-----modelsim
@echo 6: load .bin file and sim rtl----modelsim
@echo c: clean tb file
@echo ============================
@set /p cmchc=Enter Number:

@if %cmchc% == 0 (python tools/isa_test.py sim_rtl & goto cmsl)^
else if %cmchc% == 1 (python tools/isa_test.py all_isa & goto cmsl)^
else if %cmchc% == 2 (python tools/isa_test.py tsr_bin & goto cmsl)^
else if %cmchc% == 3 (python tools/isa_test.py sim_bin & goto cmsl)^
else if %cmchc% == 4 (gtkwave tb.lxt & goto cmsl)^
else if %cmchc% == 5 (python tools/isa_test.py vsim_rtl & goto cmsl)^
else if %cmchc% == 6 (python tools/isa_test.py vsim_bin & goto cmsl)^
else if %cmchc% == c (del tb *.lxt inst.txt transcript vlog.opt & rd /s work & @echo clean & goto cmsl)^
else (echo Error 0 & goto cmsl)

pause