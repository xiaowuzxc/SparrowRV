#-------------------------------------------------------------------------------------------------------
list:
	@echo ------------------------------
	@echo It is a UserGuide.
	@echo Must have iverilog, gtkwave and Python
	@echo ------------------------------
	@echo input : make [cmd] 
	@echo to choice what you want.
	@echo ------------------------------
	@echo Such as:make 1
	@echo You can sim D bus 
	@echo ------------------------------
	@echo [cmd]: information
	@echo 0: load inst.txt and sim rtl
	@echo 1: regress ISA test
	@echo 2: .bin file turn into inst.txt
	@echo 3: load .bin file and sim rtl
	@echo c: clean tb file
	@echo ------------------------------
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

#-------------------------------------------------------------------------------------------------------
.PHONY : c
c  :
	 rm  -rf  tb *.lxt inst.txt
#-------------------------------------------------------------------------------------------------------