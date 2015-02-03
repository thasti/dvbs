library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity mapper_tb is
end mapper_tb;

architecture tb of mapper_tb is
	constant width : positive := 8;
	-- interface signals
	signal clk 	: std_logic := '0';
	signal rst 	: std_logic := '1';
	signal clk_en 	: std_logic := '0';
	signal d_valid 	: std_logic := '0';
	signal d_i 	: std_logic := '0';
	signal d_q 	: std_logic := '0';
	signal q_i 	: std_logic_vector(width-1 downto 0);
	signal q_q 	: std_logic_vector(width-1 downto 0);

begin
	dut : entity work.mapper
	generic map (width => width)
	port map(clk => clk, rst => rst, clk_en => clk_en, d_valid => d_valid, d_i => d_i, d_q => d_q, q_i => q_i, q_q => q_q);

	clk <= not clk after 100 ns;
	rst <= '0' after 500 ns;

	test : process
	begin
		wait until falling_edge(rst);
		wait until rising_edge(clk);
		clk_en <= '1';
		d_valid <= '1';
		d_i <= '0';
		d_q <= '0';
		wait until rising_edge(clk);
		d_valid <= '0';
		wait until rising_edge(clk);
		d_valid <= '1';
		d_i <= '0';
		d_q <= '1';
		wait until rising_edge(clk);
		d_valid <= '0';
		wait until rising_edge(clk);
		d_valid <= '1';
		d_i <= '1';
		d_q <= '0';
		wait until rising_edge(clk);
		d_valid <= '0';
		wait until rising_edge(clk);
		d_valid <= '1';
		d_i <= '1';
		d_q <= '1';
		wait until rising_edge(clk);
		d_valid <= '0';
		wait until rising_edge(clk);
		clk_en <= '0';
		d_i <= '0';
		d_q <= '0';
		wait;
	end process;
end tb;

