library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use ieee.math_real.uniform;
use ieee.math_real.floor;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity led_display is
    Port ( clk_i : in STD_LOGIC; --internal clock
           r_i : out STD_LOGIC_VECTOR (0 to 1); --red leds, top and bottom
           g_i : out STD_LOGIC_VECTOR (0 to 1); --green leds, top and bottom
           b_i : out STD_LOGIC_VECTOR (0 to 1); -- blue leds, top and bottom

           oe_i : out STD_LOGIC := '0'; -- output enable
           lat_i : out STD_LOGIC := '0'; -- latch
           clk_pin_i : out STD_LOGIC; -- clock pin of the display
           lines_i : out STD_LOGIC_VECTOR (0 to 3) := "0000"; --line selector
           led_i : out unsigned(15 downto 0);
           sw_i : in unsigned(15 downto 0);
           
           
           
           oe_debug_i : out STD_LOGIC;
           lat_debug_i: out STD_LOGIC;
           r0_debug_i: out STD_LOGIC;
           
           lines_debug_i : out STD_LOGIC_VECTOR (3 downto 0);
           clk_debug_i : out STD_LOGIC
           ); 
           
end led_display;

architecture Behavioral of led_display is

type STATE is (ENABLE_ON, SERIAL_OUT, SWITCH_LINE);
type letter_array is array(0 to 25) of std_logic_vector(0 to 319);

signal current_state: STATE := SERIAL_OUT;

signal display_clock: std_logic := '0';
signal internal_display_clock: std_logic := '0';
signal snail_clock: std_logic := '0';

constant display_div: integer := 3;

constant LED_START: integer := 0;

signal framebuffer: std_logic_vector(0 to 2047) := (others => '0');

constant letters: letter_array := (
--A
"00001111111100000000111111110000000011111111000000001111111100001111000000001111111100000000111111110000000011111111000000001111111111111111111111111111111111111111111111111111111111111111111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111",
--B
"11111111111100001111111111110000111111111111000011111111111100001111000000001111111100000000111111110000000011111111000000001111111111111111000011111111111100001111111111110000111111111111000011110000000011111111000000001111111100000000111111110000000011111111111111110000111111111111000011111111111100001111111111110000",
--C
"00001111111100000000111111110000000011111111000000001111111100001111000000001111111100000000111111110000000011111111000000001111111100000000000011110000000000001111000000000000111100000000000011110000000011111111000000001111111100000000111111110000000011110000111111110000000011111111000000001111111100000000111111110000",
--D
"11111111111100001111111111110000111111111111000011111111111100001111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111111111110000111111111111000011111111111100001111111111110000",
--E
"11111111111111111111111111111111111111111111111111111111111111111111000000000000111100000000000011110000000000001111000000000000111111111111000011111111111100001111111111110000111111111111000011110000000000001111000000000000111100000000000011110000000000001111111111111111111111111111111111111111111111111111111111111111",
--F
"11111111111111111111111111111111111111111111111111111111111111111111000000000000111100000000000011110000000000001111000000000000111111111111000011111111111100001111111111110000111111111111000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000",
--G
"00001111111100000000111111110000000011111111000000001111111100001111000000000000111100000000000011110000000000001111000000000000111100001111111111110000111111111111000011111111111100001111111111110000000011111111000000001111111100000000111111110000000011110000111111110000000011111111000000001111111100000000111111110000",
--H
"11110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111111111111111111111111111111111111111111111111111111111111111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111",
--I
"00111111111111000011111111111100001111111111110000111111111111000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000011111111111100001111111111110000111111111111000011111111111100",
--J
"00000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111111110000000011111111000000001111111100000000111111110000000011110000111111110000000011111111000000001111111100000000111111110000",
--K
"11110000000011111111000000001111111100000000111111110000000011111111000011110000111100001111000011110000111100001111000011110000111111110000000011111111000000001111111100000000111111110000000011110000111100001111000011110000111100001111000011110000111100001111000000001111111100000000111111110000000011111111000000001111",
--L
"11110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111111111111111111111111111111111111111111111111111111111111111",
--M
"11100000000001111110000000000111111000000000011111100000000001111111110000111111111111000011111111111100001111111111110000111111111000111100011111100011110001111110001111000111111000111100011111100000000001111110000000000111111000000000011111100000000001111110000000000111111000000000011111100000000001111110000000000111",
--N
"11110000000011111111000000001111111100000000111111110000000011111111111100001111111111110000111111111111000011111111111100001111111100001111111111110000111111111111000011111111111100001111111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111",
--O
"00001111111100000000111111110000000011111111000000001111111100001111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011110000111111110000000011111111000000001111111100000000111111110000",
--P
"11111111111100001111111111110000111111111111000011111111111100001111000000001111111100000000111111110000000011111111000000001111111111111111000011111111111100001111111111110000111111111111000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000",
--Q
"00001111111100000000111111110000000011111111000000001111111100001111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000111100001111000011110000111100001111000011110000111100000000111100001111000011110000111100001111000011110000111100001111",
--R
"11111111111100001111111111110000111111111111000011111111111100001111000000001111111100000000111111110000000011111111000000001111111111111111000011111111111100001111111111110000111111111111000011110000111100001111000011110000111100001111000011110000111100001111000000001111111100000000111111110000000011111111000000001111",
--S
"00001111111111110000111111111111000011111111111100001111111111111111000000000000111100000000000011110000000000001111000000000000000011111111000000001111111100000000111111110000000011111111000000000000000011110000000000001111000000000000111100000000000011111111111111110000111111111111000011111111111100001111111111110000",
--T
"11111111111111111111111111111111111111111111111111111111111111110000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000",
--U
"11110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011110000111111110000000011111111000000001111111100000000111111110000",
--V
"11100000000001111110000000000111111000000000011111100000000001111110000000000111111000000000011111100000000001111110000000000111000111000011100000011100001110000001110000111000000111000011100000011100001110000001110000111000000111000011100000011100001110000000001111000000000000111100000000000011110000000000001111000000",
--W
"11100000000001111110000000000111111000000000011111100000000001111110000000000111111000000000011111100000000001111110000000000111111000111100011111100011110001111110001111000111111000111100011111111100001111111111110000111111111111000011111111111100001111111110000000000111111000000000011111100000000001111110000000000111",
--X
"11110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111000011111111000000001111111100000000111111110000000011111111000011110000000011111111000000001111111100000000111111110000000011111111000000001111111100000000111111110000000011111111000000001111",
--Y
"11100000000001111110000000000111111000000000011111100000000001111110000000000111111000000000011111100000000001111110000000000111000111111111100000011111111110000001111111111000000111111111100000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000",
--Z
"11111111111111111111111111111111111111111111111111111111111111110000000011110000000000001111000000000000111100000000000011110000000011110000000000001111000000000000111100000000000011110000000011110000000000001111000000000000111100000000000011110000000000001111111111111111111111111111111111111111111111111111111111111111"
);

signal line_counter: integer range 0 to 15 := 0;
signal led_counter: integer range 0 to 63 := 0;
signal debug_led: integer range 0 to 8 := 0;

signal current_char_l: std_logic_vector(0 to 319) := letters(0);
signal current_char_r: std_logic_vector(0 to 319) := letters(25);


constant ENABLE: std_logic := '0';
constant DISABLE: std_logic := not ENABLE;

signal r_enable: std_logic := '0';
signal g_enable: std_logic := '0';
signal b_enable: std_logic := '0';

signal shift_col: integer range 1 to 62 := 1;


begin

clk_pin_i <= display_clock;
clk_debug_i <= display_clock;
lines_i <= std_logic_vector(to_unsigned(line_counter, lines_i'length));
lines_debug_i <= std_logic_vector(to_unsigned(line_counter, lines_i'length));

framebuffer(64 *  6 + 5 to 64 *  6 + 20) <= current_char_l(  0 to  15); -- 5 - 20
framebuffer(64 *  7 + 5 to 64 *  7 + 20) <= current_char_l( 16 to  31);
framebuffer(64 *  8 + 5 to 64 *  8 + 20) <= current_char_l( 32 to  47);
framebuffer(64 *  9 + 5 to 64 *  9 + 20) <= current_char_l( 48 to  63);
framebuffer(64 * 10 + 5 to 64 * 10 + 20) <= current_char_l( 64 to  79);
framebuffer(64 * 11 + 5 to 64 * 11 + 20) <= current_char_l( 80 to  95);
framebuffer(64 * 12 + 5 to 64 * 12 + 20) <= current_char_l( 96 to 111);
framebuffer(64 * 13 + 5 to 64 * 13 + 20) <= current_char_l(112 to 127);
framebuffer(64 * 14 + 5 to 64 * 14 + 20) <= current_char_l(128 to 143);
framebuffer(64 * 15 + 5 to 64 * 15 + 20) <= current_char_l(144 to 159);
framebuffer(64 * 16 + 5 to 64 * 16 + 20) <= current_char_l(160 to 175);
framebuffer(64 * 17 + 5 to 64 * 17 + 20) <= current_char_l(176 to 191);
framebuffer(64 * 18 + 5 to 64 * 18 + 20) <= current_char_l(192 to 207);
framebuffer(64 * 19 + 5 to 64 * 19 + 20) <= current_char_l(208 to 223);
framebuffer(64 * 20 + 5 to 64 * 20 + 20) <= current_char_l(224 to 239);
framebuffer(64 * 21 + 5 to 64 * 21 + 20) <= current_char_l(240 to 255);
framebuffer(64 * 22 + 5 to 64 * 22 + 20) <= current_char_l(256 to 271);
framebuffer(64 * 23 + 5 to 64 * 23 + 20) <= current_char_l(272 to 287);
framebuffer(64 * 24 + 5 to 64 * 24 + 20) <= current_char_l(288 to 303);
framebuffer(64 * 25 + 5 to 64 * 25 + 20) <= current_char_l(304 to 319);


framebuffer(64 *  6 + 43 to 64 *  6 + 58) <= current_char_r(  0 to  15); -- 5 - 20
framebuffer(64 *  7 + 43 to 64 *  7 + 58) <= current_char_r( 16 to  31);
framebuffer(64 *  8 + 43 to 64 *  8 + 58) <= current_char_r( 32 to  47);
framebuffer(64 *  9 + 43 to 64 *  9 + 58) <= current_char_r( 48 to  63);
framebuffer(64 * 10 + 43 to 64 * 10 + 58) <= current_char_r( 64 to  79);
framebuffer(64 * 11 + 43 to 64 * 11 + 58) <= current_char_r( 80 to  95);
framebuffer(64 * 12 + 43 to 64 * 12 + 58) <= current_char_r( 96 to 111);
framebuffer(64 * 13 + 43 to 64 * 13 + 58) <= current_char_r(112 to 127);
framebuffer(64 * 14 + 43 to 64 * 14 + 58) <= current_char_r(128 to 143);
framebuffer(64 * 15 + 43 to 64 * 15 + 58) <= current_char_r(144 to 159);
framebuffer(64 * 16 + 43 to 64 * 16 + 58) <= current_char_r(160 to 175);
framebuffer(64 * 17 + 43 to 64 * 17 + 58) <= current_char_r(176 to 191);
framebuffer(64 * 18 + 43 to 64 * 18 + 58) <= current_char_r(192 to 207);
framebuffer(64 * 19 + 43 to 64 * 19 + 58) <= current_char_r(208 to 223);
framebuffer(64 * 20 + 43 to 64 * 20 + 58) <= current_char_r(224 to 239);
framebuffer(64 * 21 + 43 to 64 * 21 + 58) <= current_char_r(240 to 255);
framebuffer(64 * 22 + 43 to 64 * 22 + 58) <= current_char_r(256 to 271);
framebuffer(64 * 23 + 43 to 64 * 23 + 58) <= current_char_r(272 to 287);
framebuffer(64 * 24 + 43 to 64 * 24 + 58) <= current_char_r(288 to 303);
framebuffer(64 * 25 + 43 to 64 * 25 + 58) <= current_char_r(304 to 319);


framebuffer(64 *  6 + 24 to 64 *  6 + 39) <= letters(23)(  0 to  15); -- 5 - 20
framebuffer(64 *  7 + 24 to 64 *  7 + 39) <= letters(23)( 16 to  31);
framebuffer(64 *  8 + 24 to 64 *  8 + 39) <= letters(23)( 32 to  47);
framebuffer(64 *  9 + 24 to 64 *  9 + 39) <= letters(23)( 48 to  63);
framebuffer(64 * 10 + 24 to 64 * 10 + 39) <= letters(23)( 64 to  79);
framebuffer(64 * 11 + 24 to 64 * 11 + 39) <= letters(23)( 80 to  95);
framebuffer(64 * 12 + 24 to 64 * 12 + 39) <= letters(23)( 96 to 111);
framebuffer(64 * 13 + 24 to 64 * 13 + 39) <= letters(23)(112 to 127);
framebuffer(64 * 14 + 24 to 64 * 14 + 39) <= letters(23)(128 to 143);
framebuffer(64 * 15 + 24 to 64 * 15 + 39) <= letters(23)(144 to 159);
framebuffer(64 * 16 + 24 to 64 * 16 + 39) <= letters(23)(160 to 175);
framebuffer(64 * 17 + 24 to 64 * 17 + 39) <= letters(23)(176 to 191);
framebuffer(64 * 18 + 24 to 64 * 18 + 39) <= letters(23)(192 to 207);
framebuffer(64 * 19 + 24 to 64 * 19 + 39) <= letters(23)(208 to 223);
framebuffer(64 * 20 + 24 to 64 * 20 + 39) <= letters(23)(224 to 239);
framebuffer(64 * 21 + 24 to 64 * 21 + 39) <= letters(23)(240 to 255);
framebuffer(64 * 22 + 24 to 64 * 22 + 39) <= letters(23)(256 to 271);
framebuffer(64 * 23 + 24 to 64 * 23 + 39) <= letters(23)(272 to 287);
framebuffer(64 * 24 + 24 to 64 * 24 + 39) <= letters(23)(288 to 303);
framebuffer(64 * 25 + 24 to 64 * 25 + 39) <= letters(23)(304 to 319);


--r0_debug_i <= '1' when (line_counter = 1 and led_counter > 0 and led_counter < 64) else '0';


       -- the line 0 should not shift, it's decoration. But line 16 should shift.
r_i <= framebuffer(line_counter * 64 + led_counter) & framebuffer((line_counter + 16) * 64 + (led_counter + shift_col) mod 62 + 1) 
		  when r_enable = '1' and line_counter = 0 else
	   -- the last line, line 31 should not shift, but its counterpart, line 15 should not
	   framebuffer(line_counter * 64 + (led_counter + shift_col) mod 62 + 1) & framebuffer((line_counter + 16) * 64 + led_counter)
	      when r_enable = '1' and line_counter = 15 else
	   -- the first and last columns are also decorations, they should not shift
	   framebuffer(line_counter * 64 + led_counter) & framebuffer((line_counter + 16) * 64 + led_counter)
	      when r_enable = '1' and (led_counter = 0 or led_counter = 63) else
	   -- the middle part (not first/last line/column)
	   framebuffer(line_counter * 64 + (led_counter + shift_col) mod 62 + 1) & framebuffer((line_counter + 16) * 64 + (led_counter + shift_col) mod 62 + 1) 
	      when r_enable = '1'
	   else "00";
	   
	   
g_i <= framebuffer(line_counter * 64 + led_counter) & framebuffer((line_counter + 16) * 64 + (led_counter + shift_col) mod 62 + 1) 
		  when g_enable = '1' and line_counter = 0 else
	   framebuffer(line_counter * 64 + (led_counter + shift_col) mod 62 + 1) & framebuffer((line_counter + 16) * 64 + led_counter)
	      when g_enable = '1' and line_counter = 15 else
	   framebuffer(line_counter * 64 + led_counter) & framebuffer((line_counter + 16) * 64 + led_counter)
	      when g_enable = '1' and (led_counter = 0 or led_counter = 63) else
	   framebuffer(line_counter * 64 + (led_counter + shift_col) mod 62 + 1) & framebuffer((line_counter + 16) * 64 + (led_counter + shift_col) mod 62 + 1) 
	      when g_enable = '1'
	   else "00";
	   
	   
b_i <= framebuffer(line_counter * 64 + led_counter) & framebuffer((line_counter + 16) * 64 + (led_counter + shift_col) mod 62 + 1) 
		  when b_enable = '1' and line_counter = 0 else
	   framebuffer(line_counter * 64 + (led_counter + shift_col) mod 62 + 1) & framebuffer((line_counter + 16) * 64 + led_counter)
	      when b_enable = '1' and line_counter = 15 else
	   framebuffer(line_counter * 64 + led_counter) & framebuffer((line_counter + 16) * 64 + led_counter)
	      when b_enable = '1' and (led_counter = 0 or led_counter = 63) else
	   framebuffer(line_counter * 64 + (led_counter + shift_col) mod 62 + 1) & framebuffer((line_counter + 16) * 64 + (led_counter + shift_col) mod 62 + 1) 
	      when b_enable = '1'
	   else "00";

       
--Generate the display_clock and internal_display_clock signals
--They are basically the same, but display_clock is routed
--directly to the clock pin of the display, and it is only active,
--when display data is being sent to the panel.
--internal_display_clock is used internally to sync, to set the different
--signals, according to the statemachine. Using that changing the display
--data will be in sync with the actual display.
display_clk_gen: process(clk_i)
variable clk_cnt: integer range 0 to display_div;
begin
    if rising_edge(clk_i) then
        clk_cnt := clk_cnt + 1;
        if clk_cnt = display_div then
            clk_cnt := 0;
            internal_display_clock <= not internal_display_clock;
            if current_state = SERIAL_OUT then
				display_clock <= not display_clock;
			end if;
        end if;
    end if;
end process display_clk_gen;

colorizer: process(internal_display_clock)
variable cnt : integer := 0;
variable cnt2 : integer := 0;
variable any_led_on : boolean;
begin
	if rising_edge(clk_i) then
	    cnt2 := cnt2 + 1;
		if cnt2 = 8000000 then
			cnt2 := 0;
			cnt := cnt + 1;
			
			any_led_on := false;
			if cnt mod 38 > 18 then 
				any_led_on := true;
				r_enable <= '1';
			else 
				r_enable <= '0';
			end if;
			
			if cnt mod 76 > 38 then 
				g_enable <= '0';
			else 
				any_led_on := true;
				g_enable <= '1';
			end if;
			
			
			if cnt mod 58 > 29 then 
				b_enable <= '0';
			else 
				any_led_on := true;
				b_enable <= '1';
			end if;
			
			-- avoid being completely black.
			if not any_led_on then
				b_enable <= '1';
			end if;
			
		end if;
	end if;
end process colorizer;

--This process is only for demo/debugging. It changes the displayed
--letter every 8M clock cycles.
char_switcher: process(internal_display_clock)
variable cnt1: integer := 0;
variable charcnt: integer range 0 to 25 := 0;
begin
	if rising_edge(internal_display_clock) then
		if cnt1 = 8000000 then -- arbitrary clock cycle number, for a demo this is big enough
			current_char_l <= letters(charcnt);
			current_char_r <= letters(25 - charcnt);
			if charcnt = 25 then
				charcnt := 0;
			else
				charcnt := charcnt + 1;
			end if;
			
			cnt1 := 0;
		else
			cnt1 := cnt1 + 1;
		end if;
	end if;
end process char_switcher;

side_decoration: process(internal_display_clock)
variable cnt1: integer := 0;
variable state: integer range 0 to 7 := 0;
begin

if rising_edge(internal_display_clock) then
	if cnt1 = 250000 then
		cnt1 := 0;
		if state = 7 then
			state := 0;
		else
			state := state + 1;
		end if;
		
		-- top row
		for i in 0 to 63 loop		
			if (i - state) mod 8 < 4 then
				framebuffer(i) <= '1';
			else
				framebuffer(i) <= '0';
			end if;
		end loop;
		
		-- right side
		for i in 1 to 30 loop
			if (i - state + 7) mod 8 < 4 then
				framebuffer(i * 64 + 63) <= '1';
			else
				framebuffer(i * 64 + 63) <= '0';
			end if;
		end loop;
		
		-- bottom row
		for i in 63 downto 0 loop
			if (63 - i - state + 2) mod 8 > 3 then
				framebuffer(31 * 64 + i) <= '1';
			else
				framebuffer(31 * 64 + i) <= '0';
			end if;
		end loop;
		
		-- left side
		for i in 30 downto 1 loop
			if (30 - i - state + 2) mod 8 > 3 then
				framebuffer(i * 64) <= '1';
			else
				framebuffer(i * 64) <= '0';
			end if;
		end loop;
		
		
	else
		cnt1 := cnt1 + 1;
	end if;
end if;


end process side_decoration;

shifting: process(internal_display_clock)
variable cnt : integer range 0 to 450000 := 0;
begin
	if rising_edge(internal_display_clock) then
		if cnt = 450000 then
			cnt := 0;
			if shift_col = 62 then
				shift_col <= 1;
			else
				shift_col <= shift_col + 1;
			end if;
		else
			cnt := cnt + 1;
		end if;
	end if;
end process shifting;


--The main statemachine, the heart. This is described in the README.
--But also, it's not that long.
state_machine: process(internal_display_clock)
variable wait_counter: integer range 0 to 1000 := 0;
variable line_cnt_var: integer range 0 to 15 := 0;
variable led_cnt_var: integer range 0 to 63 := 0;
begin
    if falling_edge(internal_display_clock) then
        case current_state is
            when ENABLE_ON =>
                --debug_led <= 1;
                oe_i <= ENABLE;
                oe_debug_i <= ENABLE;
                lat_i <= ENABLE;
                lat_debug_i <= ENABLE;
                if wait_counter = 3 then
                    lat_i <= DISABLE;
                    lat_debug_i <= DISABLE;
                end if;
                    
                if wait_counter = 500 then -- while oe is enabled, the LED stays on - the longer it is on, the brighter it is.
										   -- of course it needs some balance, so that it doesn't kill the refresh rate
										   -- let's see if 500 clock cycles is good enough for both.
					current_state <= SWITCH_LINE;
					wait_counter := 0;
				else
					wait_counter := wait_counter + 1;	
				end if;
                
            when SWITCH_LINE =>
				--debug_led <= 2;
				
				oe_i <= DISABLE;
                oe_debug_i <= DISABLE;
                lat_i <= DISABLE;
                lat_debug_i <= DISABLE;
				
				if wait_counter = 0 then
					if line_cnt_var = 15 then
						line_cnt_var := 0;
					else
						line_cnt_var := line_cnt_var + 1;
					end if;
				end if;
				
                if wait_counter = 10 then
					current_state <= SERIAL_OUT;
					wait_counter := 0;
				else
					wait_counter := wait_counter + 1;
				end if;
			when SERIAL_OUT =>
				oe_i <= DISABLE;
                oe_debug_i <= DISABLE;
                lat_i <= DISABLE;
                lat_debug_i <= DISABLE;
				if led_cnt_var = 63 then
					led_cnt_var := 0;
					current_state <= ENABLE_ON;
				else
					led_cnt_var := led_cnt_var + 1;
				end if;
			when others =>
                oe_i <= DISABLE;
                oe_debug_i <= DISABLE;
                lat_i <= DISABLE;
                lat_debug_i <= DISABLE;
        end case;
    end if;
    line_counter <= line_cnt_var;
    led_counter <= led_cnt_var;
end process state_machine;


end Behavioral;
