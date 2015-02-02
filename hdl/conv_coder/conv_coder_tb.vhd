library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity conv_coder_tb is
end conv_coder_tb;

architecture tb of conv_coder_tb is
	-- interface signals
	signal clk 	: std_logic := '0';
	signal rst 	: std_logic := '1';
	signal clk_en 	: std_logic := '0';
	signal d 	: std_logic := '0';
	signal x 	: std_logic;
	signal y 	: std_logic;
	-- number of bits to check
	constant n_bit	: positive := 1000;
	-- test vector
	signal rand_vector	: std_logic_vector(0 to n_bit + 6) := (others => '0');
	signal x_test		: std_logic;
	signal y_test		: std_logic;

begin
	dut : entity work.conv_coder
	port map(clk => clk, rst => rst, clk_en => clk_en, d => d, x => x, y => y);

	clk <= not clk after 100 ns;
	rst <= '0' after 500 ns;

	prepare : process
		variable seed1, seed2	: positive;
		variable rand		: real;
		variable rand_unsigned	: std_logic_vector(0 downto 0);
	begin
		for i in 0 to n_bit-1 loop
			uniform(seed1, seed2, rand);
			rand_unsigned := std_logic_vector(to_unsigned(integer(round(rand)),1));
			rand_vector(6 + i) <= rand_unsigned(0);
		end loop;
	wait;
	end process;

	test : process
	begin
		wait until falling_edge(rst);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		for i in 6 to n_bit + 6 - 1 loop
			clk_en <= '1';
			d <= rand_vector(i);
			x_test <= 	(rand_vector(i) xor
					rand_vector(i-1) xor
					rand_vector(i-2) xor
					rand_vector(i-3) xor
					rand_vector(i-6));

			y_test <= 	(rand_vector(i) xor
					rand_vector(i-2) xor
					rand_vector(i-3) xor
					rand_vector(i-5) xor
					rand_vector(i-6));

			wait until rising_edge(clk);
			wait until falling_edge(clk);

			assert x = x_test
			report "X output error."
			severity failure;

			assert y = y_test
			report "Y output error."
			severity failure;
		end loop;
	end process;
end tb;

