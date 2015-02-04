-- ethernet deframing unit
-- gets all data bytes  from rmii_rx
-- outputs the frame payload, to a FIFO interface
--
-- Note: This is very dirty :-) The following assumptions are made:
-- - EthernetII is used, no VLAN tag
-- - only IPv4 packets are received
-- - The IPv4 header has standard length (no optional flags)
-- - All packets on UDP port 40000 are directed towards us
-- - no MAC-, IP- or checksum fields are checked


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth_rx is
	port (
		clk	: in std_logic;
		rst	: in std_logic;

		rxd	: in std_logic_vector(1 downto 0);
		crsdv	: in std_logic;

		q	: out std_logic_vector(7 downto 0);
		q_valid	: out std_logic
	);
end eth_rx;

architecture behav of eth_rx is
	-- ethernet frame constants
	constant type_ip_hi	: std_logic_vector(7 downto 0) := x"08";
	constant type_ip_lo	: std_logic_vector(7 downto 0) := x"00";
	constant type_udp	: std_logic_vector(7 downto 0) := x"11";
	constant port_udp_hi	: std_logic_vector(7 downto 0) := x"9C";
	constant port_udp_lo	: std_logic_vector(7 downto 0) := x"40";

	-- ethernet frame offsets
	constant ethtype_hi_off	: unsigned(10 downto 0) := to_unsigned(12, 11);
	constant ethtype_lo_off	: unsigned(10 downto 0) := to_unsigned(13, 11);
	constant iptype_off	: unsigned(10 downto 0) := to_unsigned(23, 11);
	constant port_hi_off	: unsigned(10 downto 0) := to_unsigned(36, 11);
	constant port_lo_off	: unsigned(10 downto 0) := to_unsigned(37, 11);
	constant udplen_hi_off	: unsigned(10 downto 0) := to_unsigned(38, 11);
	constant udplen_lo_off	: unsigned(10 downto 0) := to_unsigned(39, 11);
	constant udpcrc_lo_off	: unsigned(10 downto 0) := to_unsigned(41, 11);

	constant udp_header_len	: unsigned(10 downto 0) := to_unsigned(8, 11);

	type rx_states is (idle, packet, payload, endofpacket);
	signal state		: rx_states := idle;

	signal eth_count	: unsigned(10 downto 0) := (others => '0');
	signal payload_count	: unsigned(10 downto 0) := (others => '0');

	signal udp_size		: unsigned(10 downto 0) := (others => '0');

	signal rx_byte		: std_logic_vector(7 downto 0);
	signal rx_dv		: std_logic;
	signal rx_crs		: std_logic;

begin
	rmii_rx : entity work.rmii_rx
	port map (clk => clk, rst => rst, rxd => rxd, crsdv => crsdv, rx_byte => rx_byte, rx_dv => rx_dv, rx_crs => rx_crs);

	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			eth_count <= to_unsigned(0, eth_count'length);
			payload_count <= to_unsigned(0, payload_count'length);
			udp_size <= to_unsigned(0, udp_size'length);
			q_valid <= '0';
			q <= (others => '0');
		end if;
		case state is
			when idle =>
				if rx_crs = '1' then
					eth_count <= to_unsigned(0, eth_count'length);
					state <= packet;
				end if;
			when packet =>
				if rx_dv = '1' then
					if eth_count = ethtype_hi_off and rx_byte /= type_ip_hi then
						report "Not an IP packet (High)!";
						state <= endofpacket;
					end if;
					if eth_count = ethtype_lo_off and rx_byte /= type_ip_lo then
						report "Not an IP packet (Low)!";
						state <= endofpacket;
					end if;
					if eth_count = iptype_off and rx_byte /= type_udp then
						report "Not an UDP packet!";
						state <= endofpacket;
					end if;
					if eth_count = port_hi_off and rx_byte /= port_udp_hi then
						report "Port not correct (High)!";
						state <= endofpacket;
					end if;
					if eth_count = port_lo_off and rx_byte /= port_udp_lo then
						report "Port not correct (Low)!";
						state <= endofpacket;
					end if;
					if eth_count = udplen_hi_off then
						report "Latched Length (High)!";
						udp_size(10 downto 8) <= unsigned(rx_byte(2 downto 0));
					end if;
					if eth_count = udplen_lo_off then
						report "Latched Length (Low)!";
						udp_size(7 downto 0) <= unsigned(rx_byte);
					end if;
					if eth_count = udpcrc_lo_off then
						report "Begin of Payload!";
						payload_count <= udp_size;
						state <= payload;
					end if;
					eth_count <= eth_count + to_unsigned(1, eth_count'length);
				end if;
				if rx_crs = '0' then
					state <= idle;
				end if;
			when payload =>
				if rx_dv = '1' then
					payload_count <= payload_count - to_unsigned(1, payload_count'length);
					if payload_count = udp_header_len then
						state <= endofpacket;
						q_valid <= '0';
					else
						report "Wrote byte to FIFO.";
						q_valid <= '1';
						q <= rx_byte;
					end if;
				else
					q_valid <= '0';
				end if;
				if rx_crs = '0' then
					report "Packet end too early.";
					state <= idle;
				end if;
			when endofpacket =>
				if rx_crs = '0' then
					state <= idle;
				end if;

		end case;
	end process;


end behav;
