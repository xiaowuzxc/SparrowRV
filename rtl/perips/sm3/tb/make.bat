chcp 65001
echo "开始编译"
iverilog -g2005-sv -Y .sv -o tb -I ../ -y ../ tb_sm3_core_top.sv
echo "生成波形"
vvp -n tb 
echo "显示波形"
gtkwave tb.vcd
pause