# bug_synth_03
yosys. Removing a comment changes behaviour.

To reproduce you will need a Go Board.

This code is for the Go Board:
https://www.nandland.com/goboard/introduction.html

It might be possible to reproduce with an ice40 based card that has at least

-	one led
-	two Dual 7-Segment LED Displays.

but I have found that many things change the behaviuor (generated json file), including:

- Changing the order of declarations of registers and wires.
- Changing the output from one led to an other.
- Removing an non used declaration.
- Changing an non used declaration (number of bits of a register per example).

An finally:

- Removing comments.

This makes it VERY DIFFICULT to reduce a code with a bug to its minimal expression.

If you do not have a Go Board change the file "GO_BOARD.pcf" with the specs for the led and displays in your board but reproduction is not guaranteed.
And then:

-	make
-	make prog

The led WILL turn ON and the displays will show the error data.

If you remove the complete comment (line 90 to line 96 included) in file "rtl/io_bug_03.v" and then 

-	make 
-	make prog

The led WILL NOT turn ON and the displays will show zeros.

I strongly recommend that neither of the above change the generated json file for future versions of yosys.

To achive that, I recomend normalizing (ordering) the internal structures of the read verilog syntax BEFORE any compilation (any filter being passed) and even before every optimization, at least as an option to the user (it will be slower but safer).

