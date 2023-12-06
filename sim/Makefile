UVM_HOME = $(VCS_HOME)/etc/uvm

comp:
	vcs -full64 -f flist -sverilog -assert svaext -debug_acc+dmptf \
		-debug_acc+r+line \
		-timescale=1ns/1ns \
		+incdir+$(UVM_HOME)/src \
		+incdir+../tb \
		-fsdb -kdb +define+SIM \
		$(UVM_HOME)/src/uvm.sv \
		../tb/arashi_tb.sv \
		+define+UVM_REPORT_DISABLE_FILE_LINE \
		$(UVM_HOME)/src/dpi/uvm_dpi.cc

run:
	./simv

clean:
	rm -rf csrc simv* novas* *.fsdb ucli.key verdi* vc_hdrs.h

all: comp run
