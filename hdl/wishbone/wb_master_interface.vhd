----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.06.2020 20:50:04
-- Design Name: 
-- Module Name: wb_master_interface - rtl
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

entity wb_master_interface is
Generic(
    WB_DAT_W   : integer := 32;
    WB_ADR_W   : integer := 32;
    WB_GRAN : integer := 8     
);
Port (
    wb_clk_i    : in  std_logic;        -- clock
    wb_rst_i    : in  std_logic;        -- reset
    wb_adr_o    : out std_logic_vector(WB_ADR_W-1 downto 0);  -- address
    wb_dat_i    : in  std_logic_vector(WB_DAT_W-1 downto 0);  -- write data
    wb_dat_o    : out std_logic_vector(WB_DAT_W-1 downto 0); -- read data
    wb_we_o     : out std_logic;        -- write enable
    wb_sel_o    : out std_logic_vector(WB_DAT_W/WB_GRAN-1 downto 0); -- write byte valid strobe
    wb_stb_o    : out std_logic;        -- slave select 
    wb_ack_i    : in  std_logic;        -- slave acknowledge
    wb_cyc_o    : out std_logic         -- bus cycle valid
);
end wb_master_interface;

architecture rtl of wb_master_interface is

begin


end rtl;
