library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity conv_coder_tb is
end conv_coder_tb;

architecture tb of conv_coder_tb is
	signal clk 	: std_logic := '0';
	signal rst 	: std_logic := '1';
	signal clk_en 	: std_logic := '0';
	signal d 	: std_logic := '0';
	signal x 	: std_logic;
	signal y 	: std_logic;

begin
	dut : entity work.conv_coder
	port map(clk => clk, rst => rst, clk_en => clk_en, d => d, x => x, y => y);

	clk <= not clk after 100 ns;
	rst <= '0' after 500 ns;

	process
		variable seed1, seed2	: positive;
		variable rand		: real;
		variable rand_vector	: std_logic_vector(0 downto 0);
	begin
		wait until falling_edge(rst);
		for i in 0 to 255 loop
			uniform(seed1, seed2, rand);
			rand_vector := std_logic_vector(to_unsigned(integer(round(rand)),1));
			wait until rising_edge(clk);
			clk_en <= '1';
			d <= rand_vector(0);
		end loop;
	wait;
	end process;
end tb;

