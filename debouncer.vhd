library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debouncer is
    Port (
        clk     : in  STD_LOGIC;  -- Reloj de 100 MHz
        reset   : in  STD_LOGIC;
        noisy   : in  STD_LOGIC;  -- Entrada con rebotes (SW)
        clean   : out STD_LOGIC   -- Salida filtrada
    );
end debouncer;

architecture Behavioral of debouncer is
    constant MAX_COUNT : integer := 999999; -- ~10ms a 100 MHz
    signal count       : integer range 0 to MAX_COUNT := 0;
    signal state       : STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            count <= 0;
            state <= '0';
        elsif rising_edge(clk) then
            if noisy /= state then
                count <= count + 1;
                if count = MAX_COUNT then
                    state <= noisy;
                    count <= 0;
                end if;
            else
                count <= 0;
            end if;
        end if;
    end process;
    clean <= state;
end Behavioral;

