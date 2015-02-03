-- ethernet RMII interface
-- Stefan Biereigel
-- reads data from the RMII PHY interface
-- RX preamble & FSC is stripped, only data in frame is output to 
--
-- port description
--
-- TO PHY:
-- rxd0,1	output data 
-- crsdv	output data valid
--
-- TO CTRL:
-- clk		50 MHz RMII clock
-- rst		sync reset
-- rx_dv	send trigger input
-- rx_byte	tx module is ready for transfer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rmii_rx is 
	port (
		clk	: in std_logic;
		rst	: in std_logic;

		rxd 	: in std_logic_vector(1 downto 0);
		crsdv	: in std_logic;

		rx_byte	: out std_logic_vector(7 downto 0);
		rx_dv	: out std_logic;
		rx_crs	: out std_logic

	);

end rmii_rx;

architecture behav of rmii_rx is

type rx_states is (idle, sync, data);
signal cnt	: unsigned(1 downto 0);
signal data_i	: std_logic_vector(7 downto 0);
signal rx_state	: rx_states;
signal crs_i	: std_logic;
signal dv_i	: std_logic;

begin
	tx_proc : process
	begin 
		wait until rising_edge(clk);
		if rst = '1' then
			cnt <= to_unsigned(0,cnt'length);
			rx_state <= idle;
			crs_i <= '0';
			dv_i <= '0';
			rx_dv <= '0';
			rx_crs <= '0';
			rx_byte <= x"00";
		else
			case rx_state is
				when idle =>
					rx_dv <= '0';
					rx_crs <= '0';
					rx_byte <= x"00";
					crs_i <= '0';
					dv_i <= '0';
					if crsdv = '1' then
						rx_state <= sync;
					end if;
				when sync =>
					if rxd = "11" then -- FSD
						rx_state <= data;
						cnt <= to_unsigned(0, cnt'length);
					elsif rxd /= "01" or crsdv = '0' then -- no sync pattern anymore
						rx_state <= idle;
					end if;
				when data =>
					if cnt = to_unsigned(0, cnt'length) and dv_i = '1' then
						rx_byte <= data_i;
						rx_dv <= '1';
					else
						rx_dv <= '0';
					end if;
					rx_crs <= '1';
					data_i(2*to_integer(cnt)+1 downto 2*to_integer(cnt)) <= rxd(1 downto 0);
					if cnt(0) = '0' then -- crsdv resembles CRS
						crs_i <= crsdv;
					else
						dv_i <= crsdv;
						if crsdv <= '0' then
							rx_state <= idle;
							rx_crs <= '0';
						end if;
					end if;
					cnt <= cnt + to_unsigned(1,cnt'length);
				end case;
			end if;
	end process;
end behav;

		
		
