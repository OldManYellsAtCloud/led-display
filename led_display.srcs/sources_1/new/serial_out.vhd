----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2023 01:30:19 PM
-- Design Name: 
-- Module Name: serial_out - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serial_out is
  Port ( RsTx_i: out STD_LOGIC;
        clk_i: in STD_LOGIC;
        data_in_i: in STD_LOGIC;
        data_en_i: in STD_LOGIC);
end serial_out;

architecture Behavioral of serial_out is
signal serial_clock: std_logic := '0';
begin


serial_pumper: process(data_en_i, serial_clock)
variable cnt: integer:= 0;
variable buf: std_logic_vector(7 downto 0) := "00000000";
begin
    if (rising_edge(serial_clock) and data_en_i = '1' and cnt < 12) then
        if (cnt < 8) then
            buf(cnt) := data_in_i;
        end if;
        
        case cnt is
            when 0 => RsTx_i <= '0';
            when 1 to 8 => RsTx_i <= buf(cnt - 1);
            when 9 => RsTx_i <= '1';
            when 10 => RsTx_i <= '0';
            when others => null;
        end case;
        cnt := cnt + 1;
    end if;
end process serial_pumper;

-- generate clock for the display
clock_divider: process(clk_i)

--constant display_div: integer := 8;
constant serial_div: integer := 434; --115200 baudrate on rising edge
variable serial_cnt: integer range 0 to serial_div := 0;

begin
    if (rising_edge(clk_i)) then
        
        if serial_cnt = serial_div then
            serial_clock <= not serial_clock;
            serial_cnt := 0;
        else
            serial_cnt := serial_cnt + 1;
        end if;
        
    end if;
end process clock_divider;


--serial_pumper: process(serial_clock)
--variable counter: integer range 0 to 59 := 0;
--begin
--    if (rising_edge(serial_clock)) then
--        --"0101 0000"
--        case counter is
--            -- start bit
--            when 0  | 4  | 5  | 6  | 8  | 10 | 
--                 12 | 13 | 18 | 20 | 22 | 24 |
--                 28 | 30 | 31 | 33 | 34 | 38 |
--                 40 | 42 | 43 | 45 | 48 | 50 |
--                 51 | 52 | 53 | 54 | 55 | 57 |
--                 58 => RsTx_i <= '0';
--            when others => rsTx_i <= '1';
--        end case;
        
--        if counter = 59 then
--            counter := 0;
--        else
--            counter := counter + 1;
--        end if;
--    end if;
--end process serial_pumper;

end Behavioral;
