library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps_converter is
	port (
		clk	: in std_logic;
		rst	: in std_logic;
		clk_en	: in std_logic;
		start	: in std_logic;
		d	: in std_logic_vector(7 downto 0);
		q	: out std_logic
	);
end ps_converter;

architecture rtl of ps_converter is
	signal reg : std_logic_vector(7 downto 0) := (others => '0');
	signal cnt : unsigned(2 downto 0) := to_unsigned(0, 3);
begin
	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			reg <= (others => '0');
		elsif clk_en = '1' then
			if start = '1' then
				reg <= d;
				q <= d(7);
				cnt <= to_unsigned(6, 3);
			else
				q <= d(to_integer(cnt));
				cnt <= cnt - to_unsigned(1, 3);
			end if;
		end if;
	end process;
end rtl;

