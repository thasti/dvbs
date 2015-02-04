library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity eth_rx_tb is
end eth_rx_tb;

architecture behav of eth_rx_tb is
	signal clk	: std_logic := '0';
	signal rst	: std_logic := '1';
	signal rxd	: std_logic_vector(1 downto 0) := "00";
	signal crsdv	: std_logic := '0';
	signal q	: std_logic_vector(7 downto 0);
	signal q_valid	: std_logic;

begin
	dut : entity work.eth_rx port map(clk, rst, rxd, crsdv, q, q_valid);

	rst <= '1', '0' after 100 ns;
	clk <= not clk after 10 ns;

	rx_test : process
		variable tmp	: integer;
		variable tmp_v	: std_logic_vector(7 downto 0);
		variable l	: line;
		file input_file : text is in "mpeg_packet.txt";
	begin
		wait until falling_edge(rst);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		-- preamble
		crsdv <= '1';
		rxd <= "01";
		for i in 0 to 10 loop
			wait until rising_edge(clk);
		end loop;
		-- SFD
		rxd <= "11";
		wait until rising_edge(clk);

		while not endfile(input_file) loop
			readline(input_file, l);
			read(l, tmp);
			tmp_v := std_logic_vector(to_unsigned(tmp, 8));
			for i in 0 to 3 loop
				rxd <= tmp_v(2*i + 1) & tmp_v(2*i);
				wait until rising_edge(clk);
			end loop;
		end loop;

		for i in 0 to 1 loop
			crsdv <= '0';
			wait until rising_edge(clk);
			crsdv <= '1';
			wait until rising_edge(clk);
		end loop;
		crsdv <= '0';
		wait;
	end process;
end behav;
