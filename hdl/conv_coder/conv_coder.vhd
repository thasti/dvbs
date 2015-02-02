library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conv_coder is
	port (
		clk	: in std_logic;
		rst	: in std_logic;
		clk_en	: in std_logic;
		d	: in std_logic;
		x	: out std_logic;
		y	: out std_logic
	);
end conv_coder;

architecture rtl of conv_coder is
	signal delay : std_logic_vector(0 to 5) := (others => '0');

begin
	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			delay <= (others => '0');
		elsif clk_en = '1' then
			delay <= d & delay(0 to 4);

			-- X has G = 171o = 121d = 1111001
			x <= d xor delay(0) xor delay(1) xor delay(2) xor delay(5);
			-- Y has G = 133o = 91d = 1011011
			y <= d xor delay(1) xor delay(2) xor delay(4) xor delay(5);
		end if;
	end process;
end rtl;
