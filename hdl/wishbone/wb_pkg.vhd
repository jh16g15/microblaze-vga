----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.06.2020 23:46:46
-- Design Name: wb_pkg
-- Module Name: pkg_wb - Behavioral
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

package wb_pkg is
    
    constant WB_DAT_W   : integer := 32;
    constant WB_ADR_W   : integer := 32;
    constant WB_GRAN    : integer := 8;  
    
    type t_WB_MISO is record
        rdata  : std_logic_vector(WB_DAT_W-1 downto 0);  -- read data
        ack    : std_logic;        -- slave acknowledge
    end record t_WB_MISO;
    
    type t_WB_MOSI is record
        adr    : std_logic_vector(WB_ADR_W-1 downto 0);  -- address
        wdata  : std_logic_vector(WB_DAT_W-1 downto 0); -- write data
        we     : std_logic;        -- write enable
        sel    : std_logic_vector(WB_DAT_W/WB_GRAN-1 downto 0); -- write byte valid strobe
        stb    : std_logic;        -- slave chip select (handled by interconnect usually?)
        cyc    : std_logic;         -- bus cycle valid, may be held high by master indefinitely
    end record t_WB_MOSI;

end package wb_pkg;

