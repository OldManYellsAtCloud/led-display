library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;




entity spi_reader is
    Port ( QspiCSn_i : out STD_LOGIC;
           QspiDB_i : inout STD_LOGIC_VECTOR (3 downto 0);
           clk_i: in STD_LOGIC;
           serial_out_i: out std_logic;
           data_en_i: out std_logic);
end spi_reader;

architecture Behavioral of spi_reader is

signal spi_clock: std_logic := '0';
signal data_coming: std_logic := '0';

begin

spi_clock_gen: process(clk_i)
constant spi_div: integer := 434; -- match the rs232 clock speed for test
variable spi_cnt: integer range 0 to 100000000/spi_div := 0;
begin
    if (spi_cnt >= spi_div ) then
        spi_cnt := 0;
        spi_clock <= not spi_clock;
    else
        spi_cnt := spi_cnt + 1;
    end if;
end process;

STARTUPE2_inst : STARTUPE2
    generic map (
        PROG_USR => "FALSE", -- Activate program event security feature. Requires encrypted bitstreams.
        SIM_CCLK_FREQ => 0.0 -- Set the Configuration Clock Frequency(ns) for simulation.
    )
    port map (
        CFGCLK => open, -- 1-bit output: Configuration main clock output
        CFGMCLK => open, -- 1-bit output: Configuration internal oscillator clock output
        EOS => open, -- 1-bit output: Active high output signal indicating the End Of Startup.
        PREQ => open, -- 1-bit output: PROGRAM request to fabric output
        CLK => '0', -- 1-bit input: User start-up clock input
        GSR => '0', -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
        GTS => '0', -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
        KEYCLEARB => '1', -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
        PACK => '0', -- 1-bit input: PROGRAM acknowledge input
        USRCCLKO => spi_clock, -- 1-bit input: User CCLK input
        -- For Zynq-7000 devices, this input must be tied to GND
        USRCCLKTS => '0', -- 1-bit input: User CCLK 3-state enable input
        -- For Zynq-7000 devices, this input must be tied to VCC
        USRDONEO => '1', -- 1-bit input: User DONE pin output control
        USRDONETS => '0' -- 1-bit input: User DONE 3-state enable output
);


spi_grab_data: process(spi_clock, data_coming)
variable cnt: integer range 0 to 7;
begin
if (data_coming = '1' and falling_edge(spi_clock) and cnt <= 7) then
    data_en_i <= '1';
    serial_out_i <= QspiDB_i(1);
    cnt := cnt + 1;
end if;
end process;


spi_read_byte: process(spi_clock)

variable step: integer := 0;

begin
    if(rising_edge(spi_clock)) then
        case step is
            when 0 => QspiCSn_i <= '0';
            when 1 | 2 | 3 | 4 | 5 | 6 => QspiDB_i(0) <= '0';--read command 0x3
            when 7 | 8 => QspiDB_i(0) <= '1'; -- read command finish
            when 9 | 10 => QspiDB_i(0) <= '0'; --first data address: 0x21728d = 0b001000010111001010001100
            when 11 => QspiDB_i(0) <= '1';
            when 12 to 15 => QspiDB_i(0) <= '0';
            when 16 => QspiDB_i(0) <= '1';
            when 17 => QspiDB_i(0) <= '0';
            when 18 | 19 | 20 => QspiDB_i(0) <= '1';
            when 21 | 22 => QspiDB_i(0) <= '0';
            when 23 => QspiDB_i(0) <= '1';
            when 24 => QspiDB_i(0) <= '0';
            when 25 => QspiDB_i(0) <= '1';
            when 26 | 27 | 28 => QspiDB_i(0) <= '0';
            when 29 | 30 => QspiDB_i(0) <= '1';
            when 31 | 32 => QspiDB_i(0) <= '0'; -- last bit of address
            when others => data_coming <= '1';
        end case;
    end if;
end process;


end Behavioral;
