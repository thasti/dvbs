library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rmii_tx_tb is
end rmii_tx_tb;

architecture behav of rmii_tx_tb is

	signal clk	: std_logic := '0';
	signal rst	: std_logic := '1';
	signal txd	: std_logic_vector(1 downto 0) := "00";
	signal txen	: std_logic := '0';
	signal start_tx	: std_logic := '0';
	signal d_in	: std_logic_vector(7 downto 0) := (others => '0');

begin	
	dut : entity work.rmii_tx port map(clk, rst, txd, txen, start_tx, d_in);

	rst <= '1', '0' after 100 ns;
	clk <= not clk after 10 ns;

	tx_test : process
	begin 
		wait until falling_edge(rst);
		wait until rising_edge(clk);
		d_in <= x"5a";
		start_tx <= '1';
		wait until rising_edge(clk);
		d_in <= x"a5";
		wait;
	end process;


end behav;
