----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.06.2020 21:58:10
-- Design Name: 
-- Module Name: tb_wb_components - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.wb_pkg.all;
use work.wb_tb_pkg.all;

entity tb_wb_gpio is
end tb_wb_gpio;

architecture Behavioral of tb_wb_gpio is
    constant tclk    : time := 10ns;
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal wb_mosi   : t_wb_mosi;
    signal wb_miso   : t_wb_miso;
    signal rdata     : UNSIGNED(31 downto 0);
    
    signal LEDS      : std_logic_vector(15 downto 0);
    signal SW        : std_logic_vector(15 downto 0);
    signal BTN       : std_logic_vector(4 downto 0);
begin

clk <= not clk after tclk/2;

master_stimulus : process is 
    constant LED_ADDR : unsigned(31 downto 0) := x"0020_0000";
    constant SW_ADDR  : unsigned(31 downto 0) := x"0020_0004";
    constant BTN_ADDR : unsigned(31 downto 0) := x"0020_0008";
    variable address  : unsigned(31 downto 0) := x"0000_0000";
    variable wdata    : unsigned(31 downto 0) := x"FE11_D0D0";
begin
    
    reset <= '1';
    wait for 1 ns;
    reset <= '0';
    wait for 1 ns;

    
    SW <= x"F001";

    wait until clk = '1';
    p_wb_write(wb_clk => clk, wb_mosi => wb_mosi, wb_miso => wb_miso, address => LED_ADDR, wdata => wdata);
    p_wb_write(wb_clk => clk, wb_mosi => wb_mosi, wb_miso => wb_miso, address => SW_ADDR, wdata => wdata);
    p_wb_read(wb_clk => clk, wb_mosi => wb_mosi, wb_miso => wb_miso, address => LED_ADDR, rdata => rdata);
    
    p_wb_read(wb_clk => clk, wb_mosi => wb_mosi, wb_miso => wb_miso, address => SW_ADDR, rdata => rdata);
    
    wait until clk = '1';    
    
    wait;
    
end process; 

--gpio_slave : entity work.wb_slave_gpio
--    port map( 
--        wb_clk_i    => clk,      -- in  std_logic;        -- clock
--        wb_rst_i    => reset,    -- in  std_logic;        -- reset
--        wb_mosi     => wb_mosi,  -- in  t_wb_mosi;   
--        wb_miso     => wb_miso,  -- out t_wb_miso;   
--        leds_out    => LEDS,     -- out STD_LOGIC_VECTOR (g_num_leds-1 downto 0);
--        switches_in => SW,       -- in STD_LOGIC_VECTOR (g_num_sw-1 downto 0);
--        buttons_in  => BTN      -- in STD_LOGIC_VECTOR (g_num_btn-1 downto 0)
--    );
    
memory_slave : entity work.wb_slave_memory
    generic map(
        G_ADDR_W => 10,
        G_DATA_W => 32,
        G_DEPTH => 16,  -- words (1024 =4 Kbit)
        G_USE_INIT_FILE => false,
        G_INIT_FILE_NAME => ""
    )
    port map( 
        wb_clk_i    => clk,      -- in  std_logic;        -- clock
        wb_rst_i    => reset,    -- in  std_logic;        -- reset
        wb_mosi     => wb_mosi,  -- in  t_wb_mosi;   
        wb_miso     => wb_miso  -- out t_wb_miso;   
    
    );

end Behavioral;
