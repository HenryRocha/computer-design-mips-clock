all: compile

compile:
	quartus_sh --flow compile mips_clock

program:
	quartus_pgm -m jtag -c 1 -o "p;output_files/mips_clock.sof"

jtag:
	killall jtagd; jtagd; jtagconfig
