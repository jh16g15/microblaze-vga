----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2020 15:41:37
-- Design Name: 
-- Module Name: tb_display_control - tb
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_display_control is
--  Port ( );
end tb_display_control;

architecture tb of tb_display_control is

    constant CLK_PERIOD : time := 10ns;   -- 100 MHz for 1280x1024
--    constant CLK_PERIOD : time := 40ns;   -- 25 MHz for 640x480

    signal pixelclk_108 : std_logic := '1';
    signal reset_n      : std_logic := '1';
    signal VGA_RED      : std_logic_vector(3 downto 0);
    signal VGA_GREEN    : std_logic_vector(3 downto 0);
    signal VGA_BLUE     : std_logic_vector(3 downto 0);
    signal VGA_HS       : std_logic;
    signal VGA_VS       : std_logic;
begin

    pixelclk_108 <= not pixelclk_108 after CLK_PERIOD/2;

    stim : process
    begin
        reset_n <= '1';
        
        wait for 5 ns;
        reset_n <= '0';
        wait for 16 ns;
        reset_n <= '1';
        
        wait;    
    
    end process;
    

    u_display_control : entity work.display_control
    port map( 
        pixelclk    => pixelclk_108,
        reset_n     => reset_n,
        vga_hs      => VGA_HS,
        vga_vs      => VGA_VS,
        vga_g       => VGA_GREEN,
        vga_r       => VGA_RED,
        vga_b       => VGA_BLUE
   );


    u_vga_sim_logger : entity work.vga_sim_logger
    generic map(
        G_SWAP_SYNC_POLARITY => false,
        G_LOG_FILE_NAME => "vga_sim_log.txt"
    )
    port map(
        clk     => pixelclk_108,
        hsync   => VGA_HS,
        vsync   => VGA_VS,
        Red     => VGA_RED,
        Green   => VGA_GREEN,
        Blue    => VGA_BLUE
    );

end tb;
