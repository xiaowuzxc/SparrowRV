#-------------------------------------------------------------------------------------------------------
list:
	@echo ==============================
	@echo It is a UserGuide.
	@echo Must have iverilog, gtkwave and Python
	@echo ==============================
	@echo input : make [cmd] 
	@echo to choice what you want.
	@echo ------------------------------
	@echo Such as:make 1
	@echo You can sim D bus 
	@echo ==============================
	@echo [cmd]: information---------------Tools
	@echo 0: load inst.txt and sim rtl-----iverilog   
	@echo 1: regress ISA test--------------iverilog   
	@echo 2: .bin file turn into inst.txt
	@echo 3: load .bin file and sim rtl----iverilog   
	@echo 4: show last wave file-----------gtkwave
	@echo 5: load inst.txt and sim rtl-----modelsim
	@echo 6: load .bin file and sim rtl----modelsim
	@echo c: clean tb file
	@echo ==============================
#-------------------------------------------------------------------------------------------------------
.PHONY : 0
0 : 
	python tools/isa_test.py sim_rtl

.PHONY : 1
1 : 
	python tools/isa_test.py all_isa

.PHONY : 2
2 : 
	python tools/isa_test.py tsr_bin

.PHONY : 3
3 : 
	python tools/isa_test.py sim_bin

.PHONY : 4
4 : 
	python gtkwave tb.lxt

.PHONY : 5
5 : 
	vsim -do msim.tcl

.PHONY : 6
6 : 
	python tools/isa_test.py tsr_bin
	vsim -do ./msim.tcl

#-------------------------------------------------------------------------------------------------------
.PHONY : c
c  :
	rm  -rf  tb *.lxt inst.txt work transcript vlog.opt vsim.wlf
#-------------------------------------------------------------------------------------------------------