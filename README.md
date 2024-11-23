This is a basic VHDL driver for the 64x32 Adafruit LED display. It is meant to work with Basys3 board - I would expect it do to work on other boards also, but haven't tried. This code is for my own use.

Though this is a first, and somewhat rudimentary version, I'm uploading it mainly for myself, as it took some effort to figure out what the hardware expects, and don't want to forget it.

Though there is some description on Adafruit's website about this panel, it is fairly high level. They also mention that it is undocumented, so pretty much everything comes by trial and error - and they are not joking!

But finally, a couple of notes for myself, the main thing:

 - The signal order and timing is as follow:
   - Enable the clock, and on each falling edge, clock out the current LED color of the current line. Keep OE and LATCH disabled.
   - Once the current 2 rows of LED data has been clocked out, disable the clock (important!) and enable OE and LATCH pins.
   - Disable LATCH after 1 or 2 clock cycles, but keep OE enabled for a few cycles more.
   - Once OE is disabled, switch line, and wait (currently I wait 10 clock cycles, which might be a bit pessimistic). Without wait the data for the different rows can get mixed up in the panel, and the previous row will display some wrong pixels :S
   - Start from the beginning for the next rows.
 - When it comes to LATCH and OE pins, they are ACTIVE LOW! When they are treated as active high, the panel works also, however the LEDs are dimmer, and some rows are also out of place - this took a bit of head scratching.
 
 
This version of the code will just display a pixel-alphabet as a demo, for myself.
