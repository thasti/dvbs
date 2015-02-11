library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scrambler_tb is
end scrambler_tb;

architecture tb of scrambler_tb is
	-- interface signals
	signal clk 	: std_logic := '0';
	signal clk_en 	: std_logic := '1';
	signal rst 	: std_logic := '1';
	signal sync 	: std_logic := '0';
	signal d 	: std_logic_vector(7 downto 0) := (others => '0');
	signal q 	: std_logic_vector(7 downto 0);
begin
	dut : entity work.scrambler
	generic map (
		width	=> 8
	)
	port map (
		clk	=> clk,
		clk_en	=> clk_en,
		rst	=> rst,
		sync	=> sync,
		d	=> d,
		q	=> q
	);

	clk <= not clk after 100 ns;
	rst <= '0' after 500 ns;

	process
	begin
		wait until falling_edge(rst);
		wait until rising_edge(clk);

		for i in 0 to 1880 loop
			d <= std_logic_vector(to_unsigned(i mod 256,8));
			if i mod 188 = 0 then
				sync <= '1';
			else
				sync <= '0';
			end if;
			wait until rising_edge(clk);
		end loop;
		sync <= '0';
		wait;
	end process;
end tb;
