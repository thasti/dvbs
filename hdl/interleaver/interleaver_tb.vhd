library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity interleaver_tb is
end interleaver_tb;

architecture tb of interleaver_tb is
	constant width : positive := 8;
	-- interface signals
	signal clk 	: std_logic := '0';
	signal rst 	: std_logic := '1';
	signal clk_en 	: std_logic := '0';
	signal sync 	: std_logic := '0';
	signal d 	: std_logic_vector(7 downto 0);
	signal q 	: std_logic_vector(7 downto 0);

begin
	dut : entity work.interleaver
	generic map (I => 12, M => 17)
	port map(clk => clk, rst => rst, clk_en => clk_en, sync => sync, d => d, q => q);

	clk <= not clk after 100 ns;
	rst <= '0' after 500 ns;

	test : process
	variable cnt	: unsigned(7 downto 0) := to_unsigned(0, 8);
	begin
		wait until falling_edge(rst);
		while true loop
			wait until rising_edge(clk);
			clk_en <= '1';
			d <= std_logic_vector(cnt);
			cnt := cnt + to_unsigned(1, 8);
		end loop;
	end process;
end tb;

