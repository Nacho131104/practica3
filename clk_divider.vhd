----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.04.2025 20:22:14
-- Design Name: 
-- Module Name: clk_divider - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_divider is
    Generic ( SIMULATION_MODE : boolean := false );
    Port ( clk_in : in STD_LOGIC;
           reset : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end clk_divider;

architecture Behavioral of clk_divider is
    -- Declarar una constante con un valor predeterminado
    constant DIVIDER_VALUE_SIM : integer := 5;
    constant DIVIDER_VALUE_REAL : integer := 50000000;
    signal counter : unsigned(31 downto 0) := (others => '0'); -- Cambio a unsigned
    signal temp_clk : STD_LOGIC := '0';
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            temp_clk <= '0';
        elsif rising_edge(clk_in) then
            -- Usar la constante adecuada dependiendo del modo de simulación
            if SIMULATION_MODE = true then
                if counter = to_unsigned(DIVIDER_VALUE_SIM - 1, counter'length) then
                    counter <= (others => '0');
                    temp_clk <= not temp_clk;  -- Toggle clock
                else
                    counter <= counter + 1;
                end if;
            else
                if counter = to_unsigned(DIVIDER_VALUE_REAL - 1, counter'length) then
                    counter <= (others => '0');
                    temp_clk <= not temp_clk;  -- Toggle clock
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    clk_out <= temp_clk;
end Behavioral;

