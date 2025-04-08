library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity redundancia is
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
end redundancia;

architecture Behavioral of redundancia is
    signal count1, count2 : STD_LOGIC_VECTOR (7 downto 0);
    signal enable1, enable2 : STD_LOGIC := '1';
    signal clk_1hz : STD_LOGIC;
    signal reset_n : STD_LOGIC;
    signal count_value : STD_LOGIC_VECTOR (7 downto 0);
    signal sw_clean : STD_LOGIC;

    component clk_divider
        Generic ( SIMULATION_MODE : boolean := false );
        Port (
            clk_in : in STD_LOGIC;
            reset : in STD_LOGIC;
            clk_out : out STD_LOGIC
        );
    end component;

    component contador1
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enable : in STD_LOGIC;
            count : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    component contador2
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enable : in STD_LOGIC;
            count : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    component display_controller
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            count : in STD_LOGIC_VECTOR (7 downto 0);
            an : out STD_LOGIC_VECTOR (7 downto 0);
            seg : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;
--Añadimos el nuevo componente del debouncer que hemos hecho
    component debouncer
        Port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            noisy : in  STD_LOGIC;
            clean : out STD_LOGIC
        );
    end component;

begin
    -- Reset activo bajo
    reset_n <= not RESET;

    -- Divisor de reloj a 1 Hz
    DIV: clk_divider 
        generic map (SIMULATION_MODE => SIMULATION_MODE)
        port map (
            clk_in => CLK100MHZ,
            reset => reset_n,
            clk_out => clk_1hz
        );

    -- Instancia de los contadores
    U1: contador1 port map (clk => clk_1hz, reset => reset_n, enable => enable1, count => count1);
    U2: contador2 port map (clk => clk_1hz, reset => reset_n, enable => enable2, count => count2);

    -- Antirrebotes del switch
    U_DEBOUNCER: debouncer port map (
        clk   => CLK100MHZ,
        reset => reset_n,
        noisy => SW(0),
        clean => sw_clean
    );

    -- Selección de contador
    process(sw_clean, count1, count2)
    begin
        if sw_clean = '1' then
            enable1 <= '0';
            enable2 <= '1';
            count_value <= count2+count1;
        else
            enable1 <= '1';
            enable2 <= '0';
            count_value <= count1+count2;
        end if;
        LED_CONTADOR_1 <= enable1;
        LED_CONTADOR_2 <= enable2;
    end process;

    -- Mostrar en LEDs y display
    LED <= count_value;

    DISP: display_controller port map (
        clk => CLK100MHZ,
        reset => reset_n,
        count => count_value,
        an => AN,
        seg => SEG
    );

end Behavioral;

