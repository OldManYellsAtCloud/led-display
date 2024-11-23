------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 06/09/2023 12:09:00 PM
---- Design Name: 
---- Module Name: led_display_tb - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity led_display_tb is
----  Port ( );
--end led_display_tb;

--architecture Behavioral of led_display_tb is


--component led_display is
--    Port ( clk_i : in STD_LOGIC; --internal clock
--           r_i : out STD_LOGIC_VECTOR (0 to 1); --red leds, top and bottom
--           g_i : out STD_LOGIC_VECTOR (0 to 1); --green leds, top and bottom
--           b_i : out STD_LOGIC_VECTOR (0 to 1); -- blue leds, top and bottom

--           oe_i : out STD_LOGIC := '0'; -- output enable
--           lat_i : out STD_LOGIC := '0'; -- latch
--           clk_pin_i : out STD_LOGIC; -- clock pin of the display
--           lines_i : out STD_LOGIC_VECTOR (0 to 3); --line selector
--           led_i : out unsigned(15 downto 0);
--           sw_i : in unsigned(15 downto 0)
--           ); 
           
--end component;
   
--   signal clk_state: std_logic := '0';
----   signal main_clock: std_logic:= '0';
----   signal lines_state: std_logic_vector(3 downto 0);
   
----   signal display_clk: std_logic := '0';

--begin

----dut: led_display port map(lines_i => lines_state, r_i=>myr, oe_i=>myoe, lat_i=>mylat, clk_i => clk_state, sw_i => "0000000000000000");
--dut: led_display port map(clk_i => clk_state, sw_i => "0000000000000000");


--process
--begin
--    for i in 0 to 1024 loop
--        clk_state <= not clk_state;
--        wait for 1ns;
--    end loop;
--end process;















---------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity tb_led_display is
end tb_led_display;

architecture tb of tb_led_display is

    component led_display
        port (clk_i     : in std_logic;
              r_i       : out std_logic_vector (0 to 1);
              g_i       : out std_logic_vector (0 to 1);
              b_i       : out std_logic_vector (0 to 1);
              oe_i      : out std_logic;
              lat_i     : out std_logic;
              clk_pin_i : out std_logic;
              lines_i   : out std_logic_vector (3 downto 0);
              led_i     : out unsigned (15 downto 0);
              sw_i      : in unsigned (15 downto 0));
    end component;

    signal clk_i     : std_logic := '0';
    signal r_i       : std_logic_vector (0 to 1);
    signal g_i       : std_logic_vector (0 to 1);
    signal b_i       : std_logic_vector (0 to 1);
    signal oe_i      : std_logic;
    signal lat_i     : std_logic;
    signal clk_pin_i : std_logic;
    signal lines_i   : std_logic_vector (3 downto 0);
    signal led_i     : unsigned (15 downto 0);
    signal sw_i      : unsigned (15 downto 0);

    constant TbPeriod : time := 100 ps; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : led_display
    port map (clk_i     => clk_i,
              r_i       => r_i,
              g_i       => g_i,
              b_i       => b_i,
              oe_i      => oe_i,
              lat_i     => lat_i,
              clk_pin_i => clk_pin_i,
              lines_i   => lines_i,
              led_i     => led_i,
              sw_i      => sw_i);


    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        sw_i <= (others => '0');

        for i in 0 to 100000 loop
			clk_i <= '1';
			wait for 10 ps;
			clk_i <= '0';
			wait for 10 ps;
        end loop;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.



--end Behavioral;
