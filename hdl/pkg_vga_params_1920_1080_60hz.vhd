library ieee;
use ieee.std_logic_1164.all;

package pkg_vga_params_1920_1080_60hz is
    -- from https://timetoexplore.net/blog/video-timings-vga-720p-1080p
	constant PIXELCLK_FREQ : integer := 148500000; -- 148.5MHz (6.73ns)
    constant END_ACTIVE_X    : integer := 1920;
    constant FRONT_PORCH_X  : integer := 88;
    constant SYNC_PULSE_X   : integer := 44;
    constant BACK_PORCH_X   : integer := 148;
    
    constant END_FPORCH_X   : integer := END_ACTIVE_X + FRONT_PORCH_X;
    constant END_SYNC_X     : integer := END_FPORCH_X + SYNC_PULSE_X;
    constant END_BPORCH_X   : integer := END_SYNC_X + BACK_PORCH_X;     -- 800
    
    constant END_ACTIVE_Y   : integer := 1080;
    constant FRONT_PORCH_Y  : integer := 4;
    constant SYNC_PULSE_Y   : integer := 5;
    constant BACK_PORCH_Y   : integer := 36;
    
    constant END_FPORCH_Y   : integer := END_ACTIVE_Y + FRONT_PORCH_Y;           
    constant END_SYNC_Y     : integer := END_FPORCH_Y + SYNC_PULSE_Y;            
    constant END_BPORCH_Y   : integer := END_SYNC_Y + BACK_PORCH_Y;     -- 525  
    
    -- '1' for active high, '0' for active low
    constant ACTIVE_HS  : std_logic := '1';
    constant ACTIVE_VS  : std_logic := '1';      
end pkg_vga_params_1920_1080_60hz;