comp:
	vcs -full64 -f flist -sverilog -assert svaext -debug_acc+dmptf -fsdb -kdb -DSIM

run:
	./simv

clean:
	rm -rf csrc simv* novas* *.fsdb ucli.key verdi* vc_hdrs.h

all: comp run
