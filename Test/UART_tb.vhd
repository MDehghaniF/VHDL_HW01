library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_tb is
end UART_tb;

architecture behavioral of UART_tb is
    component UART is
        generic (
            parity : string := "Even"; -- "None" , "Even" , "Odd"
            stopBitsNum : integer := 1;
            clkFreq : integer := 100_000_000;
            baudRate : integer := 19200
        );
        port (
            clk : in std_logic;
            rst : in std_logic;

            Rx : in std_logic;
            Tx : out std_logic;

            dataIn : in std_logic_vector(8 - 1 downto 0);
            dataInRdy : in std_logic;

            dataOut : out std_logic_vector(8 - 1 downto 0);
            dataOutRdy : out std_logic;

            error : out std_logic
        );
    end component;

    constant periodCLK : time := 20ns;

    signal clk : std_logic;
    signal rst : std_logic := '0';

    signal Rx : std_logic := '1';
    signal Tx : std_logic;

    signal dataIn : std_logic_vector(8 - 1 downto 0);
    signal dataInRdy : std_logic := '0';

    signal dataOut : std_logic_vector(8 - 1 downto 0);
    signal dataOutRdy : std_logic;

    signal error : std_logic;
begin

    UARTInst : UART port map
        (clk, rst, Rx, Tx, dataIn, dataInRdy, dataOut, dataOutRdy, error);

    process
    begin
        for i in 1 to 10 loop
            clk <= '1';
            wait for periodCLK/2;
            clk <= '0';
            wait for periodCLK/2;
        end loop;
        dataIn <= "10101010";
        dataInRdy <= '1';
        clk <= '1';
        wait for periodCLK/2;
        clk <= '0';
        wait for periodCLK/2;
        dataInRdy <= '0';
        for i in 1 to 10 loop
            clk <= '1';
            wait for periodCLK/2;
            clk <= '0';
            wait for periodCLK/2;
        end loop;

        dataInRdy <= '0';
        dataIn <= "00000000";
        for i in 1 to 10 loop
            clk <= '1';
            wait for periodCLK/2;
            clk <= '0';
            wait for periodCLK/2;
        end loop;
        wait;
    end process;

end architecture;