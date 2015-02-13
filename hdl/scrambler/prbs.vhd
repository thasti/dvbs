library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 -- implements n-th order prbs with common polynomials y = x^n + x^(n-1) + 1

entity prbs is
	generic (
		n	: positive;
		width	: positive
	);
	port (
		clk	: in std_logic;
		clk_en	: in std_logic;
		rst	: in std_logic;

		q	: out std_logic_vector(width-1 downto 0);
		def_val	: in std_logic_vector(n-1 downto 0)
	);
end entity prbs;

architecture rtl of prbs is
	signal sr	: std_logic_vector(n-1 downto 0) := def_val;
begin
	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			sr <= def_val;
		elsif clk_en = '1' then
			for i in 0 to width-1 loop
				sr(width-1-i) <= sr(n-1-i) xor sr(n-2-i);
			end loop;
			for i in 0 to n-width-1 loop
				sr(width+i) <= sr(i);
			end loop;			
		end if;
	end process;
	bla : for i in 0 to width-1 generate
		q(width-1-i) <= sr(n-1-i) xor sr(n-2-i);
	end generate bla;

	assert (n>width) report "mode not supported: n should be greater than width" severity failure;
end architecture rtl;
