library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 -- this unit introduces 1 cycle delay between d and q

entity scrambler is
	generic (
		width	: positive
	);
	port (
		clk	: in std_logic;
		clk_en	: in std_logic;

		rst	: in std_logic;
		sync	: in std_logic;

		d	: in std_logic_vector(width-1 downto 0);
		q	: out std_logic_vector(width-1 downto 0)
	);
end entity scrambler;

architecture rtl of scrambler is
	signal prbs_rst : std_logic;
	signal prbs : std_logic_vector(width-1 downto 0);
	signal enable : std_logic;
	signal invert : std_logic;
	signal first_sync : std_logic;
	signal cnt : unsigned(2 downto 0) := (others => '0');
begin
	prbs15 : entity work.prbs
	generic map(
		n	=> 15,
		width	=> width
	)
	port map (
		clk	=> clk,
		clk_en	=> clk_en,
		rst	=> prbs_rst,
		q	=> prbs
	);
	prbs_rst <= rst or first_sync;

	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			cnt <= (others => '0');
		elsif (clk_en = '1') and (sync = '1') then
			cnt <= cnt + 1;
		end if;
	end process;

	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			q <= (others => '0');
		elsif clk_en = '1' then
			for i in 0 to width-1 loop
				q(i) <= d(i) xor ((prbs(i) and enable) or invert);
			end loop;
		end if;
	end process;
	enable <= not sync;
	first_sync <= sync when cnt = 0 else '0';
	invert <= first_sync;
end architecture rtl;
