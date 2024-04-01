quit -sim
.main clear

set PrefMain(saveLines) 1000000000

cd C:/FPGA/HW01/Sim
cmd /c "if exist work rmdir /S /Q work"
vlib work
vmap work

vcom -2008 ../Source/*.vhd
vcom -2008 ../Test/UART_tb.vhd

vsim -t 100ps -vopt UART_tb -voptargs=+acc

config wave -signalnamewidth 1

# add wave -format Logic -radix decimal sim:/UART_tb/*
add wave -format Logic -radix decimal sim:/UART_tb/UARTInst/*


run -all








# do C:/FPGA/HW01/TCL/UART_tcl.tcl