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
	@echo t: UART write iram
	@echo c: clean tb file
	@echo ==============================
#-------------------------------------------------------------------------------------------------------
.PHONY : 0
0 : 
	python3 tools/isa_test.py sim_rtl

.PHONY : 1
1 : 
	python3 tools/isa_test.py all_isa

.PHONY : 2
2 : 
	python3 tools/isa_test.py tsr_bin

.PHONY : 3
3 : 
	python3 tools/isa_test.py sim_bin

.PHONY : 4
4 : 
	python3 gtkwave tb.lxt

.PHONY : t
t : 
	python3 tools/isa_test.py tsr_app

#-------------------------------------------------------------------------------------------------------
.PHONY : c
c  :
	rm  -rf  tb *.lxt *.vcd inst.txt work transcript vlog.opt vsim.wlf
#-------------------------------------------------------------------------------------------------------