library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rmii_rx_tb is
end rmii_rx_tb;

architecture behav of rmii_rx_tb is

	signal clk	: std_logic := '0';
	signal rst	: std_logic := '1';
	signal rxd	: std_logic_vector(1 downto 0) := "00";
	signal crsdv	: std_logic := '0';
	signal rx_dv	: std_logic := '0';
	signal rx_byte	: std_logic_vector(7 downto 0) := (others => '0');
	signal rx_crs	: std_logic := '0';

begin	
	dut : entity work.rmii_rx port map(clk, rst, rxd, crsdv, rx_byte, rx_dv, rx_crs);

	rst <= '1', '0' after 100 ns;
	clk <= not clk after 10 ns;

	rx_test : process
	begin 
		wait until falling_edge(rst);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		crsdv <= '1';
		rxd <= "01";
		for i in 0 to 10 loop
			wait until rising_edge(clk);
		end loop;
		rxd <= "11";

		for i in 0 to 13 loop
			wait until rising_edge(clk);
			rxd <= std_logic_vector(to_unsigned(i mod 4,2));
			wait until rising_edge(clk);
			rxd <= std_logic_vector(to_unsigned(i mod 4,2));
		end loop;
		for i in 0 to 1 loop
			wait until rising_edge(clk);
			rxd <= not std_logic_vector(to_unsigned(i mod 4,2));
			crsdv <= '0';
			wait until rising_edge(clk);
			rxd <= not std_logic_vector(to_unsigned(i mod 4,2));
			crsdv <= '1';
		end loop;
		wait until rising_edge(clk);
		crsdv <= '0';


		wait;
	end process;


end behav;
