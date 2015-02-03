-- ethernet RMII interface
-- Stefan Biereigel
-- reads data from the RMII PHY interface
-- RX preamble & FSC is stripped, only data in frame is output to 
--
-- port description
--
-- TO PHY:
-- txd0,1	output data 
-- txen		output data valid
--
-- TO CTRL:
-- clk		50 MHz RMII clock
-- rst		sync reset
-- start_tx	send trigger input
-- tx_rdy	tx module is ready for transfer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rmii_tx is 
	port (
		clk	: in std_logic;
		rst	: in std_logic;

		txd 	: out std_logic_vector(1 downto 0);
		txen	: out std_logic;

		tx_run	: in std_logic;
		tx_byte	: in std_logic_vector(7 downto 0)

	);

end rmii_tx;

architecture behav of rmii_tx is

type tx_states is (idle, tx);
signal cnt	: unsigned(1 downto 0);
signal data	: std_logic_vector(7 downto 0);
signal tx_state	: tx_states;

begin
	tx_proc : process
	begin 
		wait until rising_edge(clk);
		if rst = '1' then
			txen <= '0';
			txd <= "00";
			cnt <= to_unsigned(0,cnt'length);
		else
			case tx_state is
				when idle => 
					txd <= "00";
					txen <= '0';
					if tx_run = '1' then
						tx_state <= tx;
						data <= tx_byte;
					end if;
				when tx =>
					txen <= '1';	
					cnt <= cnt + to_unsigned(1,cnt'length);
					txd(1 downto 0) <= data(2*to_integer(cnt)+1 downto 2*to_integer(cnt));
					if cnt = 3 then
						-- fifo read deassert
						-- read data
						if tx_run = '0' then
							tx_state <= idle;
						else
							data <= tx_byte;
						end if;
					end if;
				end case;
			end if;
	end process;
end behav;

		
		
