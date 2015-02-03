library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity mapper is
	generic (
		width	: positive := 8
	);
	port (
		clk	: in std_logic;
		rst	: in std_logic;
		clk_en	: in std_logic;
		d_i	: in std_logic;
		d_q	: in std_logic;
		q_i	: out std_logic_vector(width-1 downto 0);
		q_q	: out std_logic_vector(width-1 downto 0)
	);
end mapper;

architecture rtl of mapper is
	constant mag : signed(width-1 downto 0) :=
		to_signed(integer((real(2**(width-1) - 1) * sqrt(2.0)/2.0)),width);
begin
	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			q_i <= (others => '0');
			q_q <= (others => '0');
		elsif clk_en = '1' then
			case d_i is
				when '0' =>
					q_i <= std_logic_vector(mag);
				when '1' =>
					q_i <= std_logic_vector(-mag);
				when others =>
					report "Unreachable";
			end case;

			case d_q is
				when '0' =>
					q_q <= std_logic_vector(mag);
				when '1' =>
					q_q <= std_logic_vector(-mag);
				when others =>
					report "Unreachable";
			end case;
		end if;
	end process;
end rtl;
