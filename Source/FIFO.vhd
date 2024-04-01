library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity FIFO is
    generic (
        fifo_width : integer := 8;
        fifo_height : integer := 50
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        wr_en : in std_logic;
        rd_en : in std_logic;
        data_in : in std_logic_vector (fifo_width - 1 downto 0);
        data_out : out std_logic_vector (fifo_width - 1 downto 0);
        empty : out std_logic;
        full : out std_logic);
end FIFO;

architecture Behavioral of FIFO is
    type fifo_memory is array (0 to fifo_height - 1) of std_logic_vector (fifo_width - 1 downto 0);
    signal fifo : fifo_memory;
    signal wr_ptr, rd_ptr : integer range 0 to fifo_height - 1 := 0;
    signal count : integer range 0 to fifo_height := 0;
begin
    process (clk, rst)
    begin
        if rst = '1' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
        elsif rising_edge(clk) then
            if wr_en = '1' and count < fifo_height then
                fifo(wr_ptr) <= data_in;
                wr_ptr <= (wr_ptr + 1) mod fifo_height;
                count <= count + 1;
            end if;
            if rd_en = '1' and count > 0 then
                data_out <= fifo(rd_ptr);
                rd_ptr <= (rd_ptr + 1) mod fifo_height;
                count <= count - 1;
            end if;
        end if;
    end process;

    empty <= '1' when count = 0 else
        '0';
    full <= '1' when count = fifo_height else
        '0';
end Behavioral;