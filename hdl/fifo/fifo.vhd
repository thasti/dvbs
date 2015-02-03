library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity fifo is
	generic (
		num_words       : positive      := 8;                   -- FIFO Depth
		word_width      : positive      := 24;                  -- FIFO Width
		al_full_lvl     : natural       := 5;                   -- FIFO Almost Full Level
		al_empty_lvl    : natural       := 3                    -- FIFO Almost Empty Level
	);
	port (
		clk     : in std_logic;                                 -- System Clock
		rst     : in std_logic;                                 -- System Reset

		d       : in std_logic_vector(word_width-1 downto 0);   -- Input Data
		we      : in std_logic;                                 -- Write Enable
		full    : out std_logic;                                -- Full Flag
		al_full : out std_logic;                                -- Almost Full Flag

		q       : out std_logic_vector(word_width-1 downto 0);  -- Output Data
		re      : in std_logic;                                 -- Read Signal
		empty   : out std_logic;                                -- Empty Flag
		al_empty: out std_logic                                 -- Almost Empty Flag
	);
end entity;

architecture behavioral of fifo is

type mem_type is array(num_words-1 downto 0) of std_logic_vector(word_width-1 downto 0);

constant adr_width:     integer := integer(ceil(log2(real(num_words))));
constant full_value:    unsigned(adr_width-1 downto 0) := to_unsigned(num_words-1,adr_width);
constant empty_value:   unsigned(adr_width-1 downto 0) := (others => '0');

signal mem:             mem_type;
signal read_adr:        unsigned(adr_width-1 downto 0) := (others => '0');
signal write_adr:       unsigned(adr_width-1 downto 0) := (others => '0');
signal full_int:        std_logic;
signal empty_int:       std_logic;

begin
	process
	begin
	wait until rising_edge(clk);
		if rst = '1' then
			read_adr <= (others => '0');
			write_adr <= (others => '0');
		else
			if (we = '1' and full_int = '0') then
				mem(to_integer(write_adr)) <= d;
				write_adr <= write_adr + 1;
			end if;
			if (re = '1' and empty_int = '0') then
				read_adr <= read_adr + 1;
				q <= mem(to_integer(read_adr));
			end if;
		end if;
	end process;

	full_int        <= '1' when (write_adr = (read_adr - 1)) else '0';
	empty_int       <= '1' when (read_adr = write_adr) else '0';
	full            <= full_int;
	empty           <= empty_int;
	al_full         <= '1' when ((write_adr - read_adr) >= al_full_lvl) else '0';
	al_empty        <= '1' when ((write_adr - read_adr) <= al_empty_lvl) else '0';

end behavioral;

