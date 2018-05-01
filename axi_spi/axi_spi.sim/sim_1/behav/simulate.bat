@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.1\\bin
call %xv_path%/xsim axi_spi_test_behav -key {Behavioral:sim_1:Functional:axi_spi_test} -tclbatch axi_spi_test.tcl -view D:/BME/MSC1/RA/HF/RendszerArch/axi_spi/axi_spi_test_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
