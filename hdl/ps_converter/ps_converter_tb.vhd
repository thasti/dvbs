library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ps_converter_tb is
end ps_converter_tb;

architecture tb of ps_converter_tb is
	-- interface signals
	signal clk 	: std_logic := '0';
	signal rst 	: std_logic := '1';
	signal clk_en 	: std_logic := '0';
	signal start 	: std_logic := '0';
	signal d 	: std_logic_vector(7 downto 0) := (others => '0');
	signal q 	: std_logic;

	-- number of bits to check
	constant n_byte	: positive := 100;

	-- test vector
	type byte_array	is array(0 to n_byte-1) of std_logic_vector(7 downto 0);
	signal rand_vector	: byte_array;

begin
	dut : entity work.ps_converter
	port map(clk => clk, rst => rst, clk_en => clk_en, start => start, d => d, q => q);

	clk <= not clk after 100 ns;
	rst <= '0' after 500 ns;

	prepare : process
		variable seed1, seed2	: positive;
		variable rand		: real;
		variable rand_unsigned	: std_logic_vector(7 downto 0);
	begin
		for i in 0 to n_byte-1 loop
			uniform(seed1, seed2, rand);
			rand_unsigned := std_logic_vector(to_unsigned(integer(round(255.0*rand)),8));
			rand_vector(i) <= rand_unsigned;
		end loop;
	wait;
	end process;

	test : process
	begin
		wait until falling_edge(rst);
		wait until rising_edge(clk);
		wait until falling_edge(clk);
		for i in 0 to n_byte - 1 loop
			clk_en <= '1';
			start <= '1';
			d <= rand_vector(i);
			for j in 0 to 7 loop
				wait until rising_edge(clk);
				start <= '0';
				wait until falling_edge(clk);

				assert q = rand_vector(i)(7-j)
				report "Q output error with i = " & integer'image(i) & " and j = " & integer'image(j) & "."
				severity warning;

			end loop;
		end loop;
	end process;
end tb;

