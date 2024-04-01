library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity UART is
	generic (
		parity      : string  := "Even"; -- "None" , "Even" , "Odd"
		stopBitsNum : integer := 1;
		clkFreq     : integer := 100000000;
		baudRate    : integer := 1920000
	);
	port (
		clk : in std_logic;
		rst : in std_logic;

		Rx : in std_logic;
		Tx : out std_logic;

		dataIn    : in std_logic_vector(8 - 1 downto 0);
		dataInRdy : in std_logic;

		dataOut    : out std_logic_vector(8 - 1 downto 0);
		dataOutRdy : out std_logic;

		error : out std_logic
	);
end UART;

architecture behavioral of UART is

	constant cycle   : integer                  := (clkFreq / baudRate);
	signal Tx_cntr_1 : integer range 0 to cycle := 0;
	signal Tx_cntr_2 : integer range 0 to 11    := 0;
	signal Tx_out    : std_logic                := '1';
	signal Tx_clk    : std_logic                := '0';
	type Tx_state is (start, d0, d1, d2, d3, d4, d5, d6, d7, p, stop1, stop2);
	signal Tx_st : Tx_state := start;

	component FIFO is
		generic (
			fifo_width  : integer := 8;
			fifo_height : integer := 50
		);
		port (
			clk      : in std_logic;
			rst      : in std_logic;
			wr_en    : in std_logic;
			rd_en    : in std_logic;
			data_in  : in std_logic_vector (fifo_width - 1 downto 0);
			data_out : out std_logic_vector (fifo_width - 1 downto 0);
			empty    : out std_logic;
			full     : out std_logic);
	end component;

	signal fifo_read_en  : std_logic                    := '0';
	signal fifo_write_en : std_logic                    := '0';
	signal fifo_data_in  : std_logic_vector(7 downto 0) := "00000000";
	signal fifo_empty    : std_logic;
	signal fifo_full     : std_logic;
	signal fifo_data_out : std_logic_vector(7 downto 0);

begin
	FIFO_Inst : FIFO generic map(
		fifo_width  => 8,
		fifo_height => 30)
	port map(
		clk      => clk,
		rst      => rst,
		wr_en    => fifo_write_en,
		rd_en    => fifo_read_en,
		data_out => fifo_data_out,
		data_in  => fifo_data_in,
		empty    => fifo_empty,
		full     => fifo_full);
	reading_data_Tx : process (dataInRdy)
	begin
		fifo_data_in  <= dataIn;
		fifo_write_en <= dataInRdy;
	end process; -- reading_data_Tx

	Tx_Inst : process (Tx_clk)
	begin
		if rising_edge(TX_clk) then
			case Tx_st is
				when start =>
					Tx_out <= '0';
					Tx_st  <= d0;
				when d0 =>
					Tx_out <= fifo_data_out(0);
					Tx_st  <= d1;
				when d1 =>
					Tx_out <= fifo_data_out(1);
					Tx_st  <= d2;
				when d2 =>
					Tx_out <= fifo_data_out(2);
					Tx_st  <= d3;
				when d3 =>
					Tx_out <= fifo_data_out(3);
					Tx_st  <= d4;
				when d4 =>
					Tx_out <= fifo_data_out(4);
					Tx_st  <= d5;
				when d5 =>
					Tx_out <= fifo_data_out(5);
					Tx_st  <= d6;
				when d6 =>
					Tx_out <= fifo_data_out(6);
					Tx_st  <= d7;
				when d7 =>
					Tx_out <= fifo_data_out(7);
					if parity = "None" then
						Tx_st <= stop1;
					else
						Tx_st <= p;
					end if;
				when p =>
					if parity = "Even" then
						Tx_out <= not fifo_data_out(0) xor fifo_data_out(1) xor fifo_data_out(2) xor fifo_data_out(3) xor fifo_data_out(4) xor fifo_data_out(5) xor fifo_data_out(6) xor fifo_data_out(7);
					elsif parity = "Odd" then
						Tx_out <= fifo_data_out(0) xor fifo_data_out(1) xor fifo_data_out(2) xor fifo_data_out(3) xor fifo_data_out(4) xor fifo_data_out(5) xor fifo_data_out(6) xor fifo_data_out(7);
					end if;
					Tx_st <= stop2;
				when stop1 =>
					Tx_out <= '1';
					Tx_st  <= stop2;
				when stop2 =>
					Tx_out <= '1';
					Tx_st  <= start;

			end case;
		end if;
	end process; -- Tx_Inst

	Tx_clk_Inst : process (fifo_empty, clk)
	begin
		if (fifo_empty = '0' or not (Tx_st = start)) then
			if rising_edge(clk) then
				if Tx_cntr_2 > 10 then
					Tx_cntr_2 <= 0;
				elsif Tx_cntr_2 < 11 then
					fifo_read_en <= '0';
					if Tx_cntr_1 = 0 then
						Tx_clk <= '1';
					else
						Tx_clk <= '0';
					end if;
				end if;
				if Tx_cntr_1 = cycle then
					if Tx_st = start then
						fifo_read_en <= '1';
					end if;
					Tx_cntr_1 <= 0;
					Tx_cntr_2 <= Tx_cntr_2 + 1;
				else
					fifo_read_en <= '0';
					Tx_cntr_1    <= Tx_cntr_1 + 1;
				end if;
			end if;
		end if;
	end process; -- Tx_clk_Inst

	Tx <= Tx_out;
end architecture;
