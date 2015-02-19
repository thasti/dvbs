-- interleaver
--
-- The interleaver consists of I branches, each of them containing i*M bytes.
-- The first branch (index 0) includes no memory. The output is registered,
-- therefore this block introduces one cycle of delay.
-- sync resets the interleaver to the first branch

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity interleaver is
	generic (
		I	: positive := 12;	-- number of branches
		M	: positive := 17	-- elementary branch depth in bytes
	);
	port (
		clk	: in std_logic;
		rst	: in std_logic;
		clk_en	: in std_logic;
		sync	: in std_logic;
		d	: in std_logic_vector(7 downto 0);
		q	: out std_logic_vector(7 downto 0)
	);

end interleaver;

architecture rtl of interleaver is

	-- ram declaration (containing the delay line)
	constant ram_length : positive := M * (I-1) * I / 2;
	constant ram_bits : positive := integer(ceil(log2(real(ram_length))));
	type memory_t is array(ram_length-1 downto 0) of std_logic_vector(7 downto 0);
	signal ram : memory_t;

	-- branch counter
	constant I_bits : positive := integer(ceil(log2(real(I))));
	signal branch	: unsigned(I_bits-1 downto 0) := (others => '0');

	-- intra branch address counters
	constant iba_bits : positive := integer(ceil(log2(real((I-1)*M))));
	type iba is array(0 to I-2) of unsigned(iba_bits-1 downto 0);
	signal iba_cnt : iba := (others => (others => '0'));

	signal addr_dbg : std_logic_vector(ram_bits-1 downto 0);

begin
	intra_branch_counters : process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			for j in 1 to I-2 loop
				iba_cnt(j) <= (others => '0');
			end loop;
		elsif clk_en = '1' then
			if branch /= to_unsigned(0, iba_bits) then
				if iba_cnt(to_integer(branch) - 1) = to_unsigned(to_integer(branch) * M - 1, iba_bits) then
					iba_cnt(to_integer(branch) - 1) <= (others => '0');
				else
					iba_cnt(to_integer(branch) - 1) <= iba_cnt(to_integer(branch) - 1) + to_unsigned(1, iba_bits);
				end if;
			end if;
		end if;
	end process;

	ram_access : process
		variable addr : unsigned(ram_bits-1 downto 0) := (others => '0');
	begin
		wait until rising_edge(clk);
		if clk_en = '1' then
			if branch = to_unsigned(0, branch'length) then
				q <= d;
			else
				-- RAM offset for current branch
				-- plus intra-branch-offset for current branch
				-- FIXME move complex calculation into offset LUT
				addr := to_unsigned(
					(to_integer(branch) - 1) * M * to_integer(branch) / 2 +
					to_integer(iba_cnt(to_integer(branch)-1)), ram_bits);

				addr_dbg <= std_logic_vector(addr);
				ram(to_integer(addr)) <= d;
				q <= ram(to_integer(addr));
			end if;

			if branch = to_unsigned(I-1, I_bits) then
				branch <= to_unsigned(0, branch'length);
			else
				branch <= branch + to_unsigned(1, branch'length);
			end if;
		end if;
	end process;
end rtl;
