----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.04.2025 16:09:07
-- Design Name: 
-- Module Name: tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb is
end tb;

architecture Behavioral of tb is
 
    constant CLK_PERIOD : time := 10 ns; -- periodo del reloj
    
    --componente de la redundancia
    component redundancia is
        Generic ( SIMULATION_MODE : boolean := false );
        Port (
            CLK100MHZ : in STD_LOGIC;
            RESET : in STD_LOGIC;
            SW : in STD_LOGIC_VECTOR (0 downto 0);
            LED : out STD_LOGIC_VECTOR (7 downto 0);
            LED_CONTADOR_1 : out STD_LOGIC;
            LED_CONTADOR_2 : out STD_LOGIC;
            AN : out STD_LOGIC_VECTOR (7 downto 0);
            SEG : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;
    
    --señales
    signal clk_sim        : STD_LOGIC := '0';
    signal reset_sim      : STD_LOGIC := '0';
    signal sw_sim         : STD_LOGIC_VECTOR(0 downto 0) := "0";
    signal led_sim        : STD_LOGIC_VECTOR(7 downto 0);
    signal led_contador1  : STD_LOGIC;
    signal led_contador2  : STD_LOGIC;
    signal an_sim         : STD_LOGIC_VECTOR(7 downto 0);
    signal seg_sim        : STD_LOGIC_VECTOR(6 downto 0);
    
    -- para controlar la simulacion
    signal finalizado   : boolean := false;
    
    --para mostrar los valores 
    signal valorDisplay : integer := 0;
    signal clkcontador     : integer := 0;
    
begin
    
    uut: redundancia 
    generic map (
        SIMULATION_MODE => true
    )
    port map (
        CLK100MHZ => clk_sim,
        RESET => reset_sim,
        SW => sw_sim,
        LED => led_sim,
        LED_CONTADOR_1 => led_contador1,
        LED_CONTADOR_2 => led_contador2,
        AN => an_sim,
        SEG => seg_sim
    );
    
    -- Clock generation process
    clk_process: process
    begin
        while not finalizado loop
            clk_sim <= '0';
            wait for CLK_PERIOD/2;
            clk_sim <= '1';
            wait for CLK_PERIOD/2;
            clkcontador <= clkcontador + 1;
        end loop;
        wait;
    end process;
    
    -- Decodificador del display para pasarlo a numero
    display_decode: process(seg_sim)
    begin
        case seg_sim is
            when "1000000" => valorDisplay <= 0;  
            when "1111001" => valorDisplay <= 1;  
            when "0100100" => valorDisplay <= 2;  
            when "0110000" => valorDisplay <= 3;  
            when "0011001" => valorDisplay <= 4;  
            when "0010010" => valorDisplay <= 5;  
            when "0000010" => valorDisplay <= 6; 
            when "1111000" => valorDisplay <= 7;  
            when "0000000" => valorDisplay <= 8;  
            when "0010000" => valorDisplay <= 9;  
            when "0001000" => valorDisplay <= 10; 
            when "0000011" => valorDisplay <= 11; 
            when "1000110" => valorDisplay <= 12; 
            when "0100001" => valorDisplay <= 13; 
            when "0000110" => valorDisplay <= 14; 
            when "0001110" => valorDisplay <= 15; 
            when others    => valorDisplay <= -1; -- por si es invalido
        end case;
    end process;
    
    stim_proc: process
    begin
        --Inicializamos con el reset activo
        reset_sim <= '1';
        sw_sim <= "0";    -- Empezamos con el contador1
        wait for 100 ns;
        reset_sim <= '0'; --Desactivamos reset
        
   
        --Hacemos que el contador 1 funcione un tiempo
        wait for 200 ns;
        
        --Mostramos los valores
        report "Time: " & time'image(now) & 
               ", SW = 0 (Counter 1 active), LED_CONTADOR_1 = " & std_logic'image(led_contador1) & 
               ", LED_CONTADOR_2 = " & std_logic'image(led_contador2) & 
               ", LED = " & integer'image(to_integer(unsigned(led_sim))) & 
               ", Display Value = " & integer'image(valorDisplay);
        wait for 100 ns;
        
        -- Cambiamos al otro contador 2
        sw_sim <= "1";
        wait for 200 ns;
        
        --Mostramos los valores despues de cambiar
        report "Time: " & time'image(now) & 
               ", SW = 1 (Counter 2 active), LED_CONTADOR_1 = " & std_logic'image(led_contador1) & 
               ", LED_CONTADOR_2 = " & std_logic'image(led_contador2) & 
               ", LED = " & integer'image(to_integer(unsigned(led_sim))) & 
               ", Display Value = " & integer'image(valorDisplay);
        wait for 200 ns;
        
        --Cambiamos al contador1 otra vez
        sw_sim <= "0";
        wait for 200 ns;
        
        --y volvemos a mostrar los valores
        report "Time: " & time'image(now) & 
               ", SW = 0 (Counter 1 active), LED_CONTADOR_1 = " & std_logic'image(led_contador1) & 
               ", LED_CONTADOR_2 = " & std_logic'image(led_contador2) & 
               ", LED = " & integer'image(to_integer(unsigned(led_sim))) & 
               ", Display Value = " & integer'image(valorDisplay);
        wait for 200 ns;
        
        --Acabamos a simulacion
        finalizado<= true;
        wait;
    end process;
   
monitor_proc: process
    variable counter_name : string(1 to 9);  --Contador 1 o contador2
begin
    wait for 50 ns;

    while not finalizado loop
        --Dice cual de los dos contadores es el que esta activo 
        if sw_sim = "0" then
            counter_name := "Counter 1";
        else
            counter_name := "Counter 2";
        end if;

        -- Solo reporta cada cierto número de ciclos
        if clkcontador mod 10 = 0 then
            report "Monitoring at time: " & time'image(now) &
                   ", Active counter: " & counter_name &
                   ", LED value: " & integer'image(to_integer(unsigned(led_sim))) &
                   ", LED_CONTADOR_1 = " & std_logic'image(led_contador1) &
                   ", LED_CONTADOR_2 = " & std_logic'image(led_contador2);
        end if;

        wait for 50 ns;
    end loop;

    wait;
end process;


end Behavioral;
