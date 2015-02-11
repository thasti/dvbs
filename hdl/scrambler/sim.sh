#!/bin/bash

TIME=1ms
UNIT=scrambler_tb
ghdl --clean
ghdl -a prbs.vhd
ghdl -a scrambler.vhd
ghdl -a $UNIT.vhd
ghdl -m $UNIT

echo "[ TIME SIMULATION ]";
ghdl -r $UNIT --wave=output.ghw  --stop-time=$TIME
gtkwave output.ghw gtkwave.sav
ghdl --clean
