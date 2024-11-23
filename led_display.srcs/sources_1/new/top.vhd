----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2023 01:40:51 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
  Port ( clk : in STD_LOGIC; --internal clock
           r : out STD_LOGIC_VECTOR (0 to 1); --red leds, top and bottom
           g : out STD_LOGIC_VECTOR (0 to 1); --green leds, top and bottom
           b : out STD_LOGIC_VECTOR (0 to 1); -- blue leds, top and bottom
           oe : out STD_LOGIC := '0'; -- output enable
           lat : out STD_LOGIC := '0'; -- latch
           clk_pin: out STD_LOGIC; -- clock pin of the display
           lines : out STD_LOGIC_VECTOR (3 downto 0) := "0000"; --line selector
           RsTx: out STD_LOGIC;
           led: out unsigned(15 downto 0);
           sw: in unsigned(15 downto 0);
           QspiCSn : out STD_LOGIC;
           QspiDB : inout STD_LOGIC_VECTOR (3 downto 0);
           
           oe_debug : out STD_LOGIC;
           lat_debug: out STD_LOGIC;
           r0_debug: out STD_LOGIC;
           
           lines_debug : out STD_LOGIC_VECTOR (3 downto 0);
           clk_debug: out STD_LOGIC
           
           );
           

end top;

architecture Behavioral of top is

    component led_display is
    Port ( clk_i : in STD_LOGIC; --internal clock
           r_i : out STD_LOGIC_VECTOR (0 to 1); --red leds, top and bottom
           g_i : out STD_LOGIC_VECTOR (0 to 1); --green leds, top and bottom
           b_i : out STD_LOGIC_VECTOR (0 to 1); -- blue leds, top and bottom
           oe_i : out STD_LOGIC := '0'; -- output enable
           lat_i : out STD_LOGIC := '0'; -- latch
           clk_pin_i: out STD_LOGIC; -- clock pin of the display
           lines_i : out STD_LOGIC_VECTOR (0 to 3) := "0000"; --line selector
           led_i: out unsigned(15 downto 0);
           sw_i: in unsigned(15 downto 0);
           
           oe_debug_i : out STD_LOGIC;
           lat_debug_i: out STD_LOGIC;
           r0_debug_i: out STD_LOGIC;
           
           lines_debug_i : out STD_LOGIC_VECTOR (3 downto 0);
           clk_debug_i : out STD_LOGIC
           
     );
    end component;

    component serial_out is
     Port ( RsTx_i: out STD_LOGIC;
            clk_i: in STD_LOGIC;
            data_in_i: in STD_LOGIC;
            data_en_i: in STD_LOGIC);
     end component;
        
     
    component spi_reader is
    Port ( QspiCSn_i: out STD_LOGIC;
           QspiDB_i: inout STD_LOGIC_VECTOR (3 downto 0);
           clk_i: in STD_LOGIC;
           serial_out_i: out STD_LOGIC;
           data_en_i: out std_logic);
    end component;
    
    signal serial_wire: STD_LOGIC;
    signal data_en_wire: STD_LOGIC;

begin

le:  led_display port map (clk_i=>clk, r_i=>r, g_i=>g, b_i=>b, oe_i=>oe, lat_i=>lat, clk_pin_i=>clk_pin, lines_i=>lines, led_i=>led, sw_i=>sw,
                            oe_debug_i=>oe_debug, lat_debug_i=>lat_debug, r0_debug_i=>r0_debug, lines_debug_i=>lines_debug, clk_debug_i=>clk_debug);
ser: serial_out  port map (clk_i=>clk, RsTx_i=>RsTx, data_in_i=>serial_wire, data_en_i=>data_en_wire);
sp:  spi_reader  port map (QspiCSn_i=>QspiCSn, QspiDB_i=>QspiDB, clk_i=>clk, serial_out_i=>serial_wire, data_en_i=>data_en_wire);



end Behavioral;
