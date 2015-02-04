library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fifo_tb is
end fifo_tb;

architecture tb of fifo_tb is
	constant width : positive := 8;
	-- interface signals
	signal clk 	: std_logic := '0';
	signal rst 	: std_logic := '1';
	signal d	: std_logic_vector(width-1 downto 0) := (others => '0');
	signal we	: std_logic := '0';
	signal full	: std_logic;
	signal al_full	: std_logic;
	signal q	: std_logic_vector(width-1 downto 0);
	signal re	: std_logic := '0';
	signal empty	: std_logic;
	signal al_empty	: std_logic;


begin
	dut : entity work.fifo
	generic map (num_words => 8, word_width => width, al_full_lvl => 6, al_empty_lvl => 2)
	port map(clk => clk, rst => rst, d => d, we => we, full => full, al_full => al_full, q => q, re => re, empty => empty, al_empty => al_empty);

	clk <= not clk after 100 ns;
	rst <= '0' after 500 ns;

	test : process
	begin
		wait until falling_edge(rst);
		wait until rising_edge(clk);
		we <= '1';
		d <= x"AA";
		wait until rising_edge(clk);
		d <= x"55";
		wait until rising_edge(clk);
		d <= x"CC";
		wait until rising_edge(clk);
		we <= '0';
		re <= '1';
		wait until rising_edge(clk);
		re <= '0';
		wait until rising_edge(clk);
		re <= '1';
		wait until rising_edge(clk);
		re <= '0';
		wait;
	end process;
end tb;

