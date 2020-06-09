----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2020 14:11:58
-- Design Name: 
-- Module Name: display_top - Behavioral
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

entity display_top is
    Generic(
        G_USE_640x480_CLOCKS : boolean := false
    );
    Port ( 
        CLK : in  std_logic;
        
        BTN : in  std_logic_vector(4 downto 0);
        LED : out std_logic_vector(15 downto 0);
        SW  : in  std_logic_vector(15 downto 0);
        
        VGA_RED : out std_logic_vector(3 downto 0);
        VGA_GREEN : out std_logic_vector(3 downto 0);
        VGA_BLUE : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic
    );
end display_top;

architecture Behavioral of display_top is
    component clk_wiz_pixelclk_1280x1024
    port
        (-- Clock in ports
        -- Clock out ports
        clk_out_108          : out    std_logic;
        -- Status and control signals
        resetn             : in     std_logic;
        locked            : out    std_logic;
        clk_in1           : in     std_logic
        );
    end component;
    component clk_wiz_pixelclk_640x480
    port
        (-- Clock in ports
        -- Clock out ports
        clk_out_25          : out    std_logic;
        -- Status and control signals
        resetn             : in     std_logic;
        locked            : out    std_logic;
        clk_in1           : in     std_logic
        );
    end component;
    
    signal pixelclk_108 : std_logic;
    signal reset_n : std_logic;
    
begin
    reset_n <= not BTN(4);

    -- assign unused LEDs and stuff
    LED(14 downto 0) <= (others => '0');
    
clk_sel_108MHz : if G_USE_640x480_CLOCKS = false generate
    clk_gen : clk_wiz_pixelclk_1280x1024
    port map ( 
        -- Clock out ports  
        clk_out_108 => pixelclk_108,
        -- Status and control signals                
        resetn => reset_n,
        locked => LED(15),
        -- Clock in ports
        clk_in1 => CLK
    );
end generate clk_sel_108MHz;
clk_sel_25MHz : if G_USE_640x480_CLOCKS = true generate
    clk_gen : clk_wiz_pixelclk_640x480
    port map ( 
        -- Clock out ports  
        clk_out_25 => pixelclk_108,
        -- Status and control signals                
        resetn => reset_n,
        locked => LED(15),
        -- Clock in ports
        clk_in1 => CLK
    );
end generate clk_sel_25MHz;

--    u_display_control : entity work.display_control
--    port map( 
--        pixelclk    => pixelclk_108,
--        reset_n     => reset_n,
--        vga_hs      => VGA_HS,
--        vga_vs      => VGA_VS,
--        vga_g       => VGA_GREEN,
--        vga_r       => VGA_RED,
--        vga_b       => VGA_BLUE
--    );
    u_display_control : entity work.display_text_controller
    port map( 
        pixelclk    => pixelclk_108,
        areset_n     => reset_n,
        vga_hs      => VGA_HS,
        vga_vs      => VGA_VS,
        vga_g       => VGA_GREEN,
        vga_r       => VGA_RED,
        vga_b       => VGA_BLUE
    );

end Behavioral;
