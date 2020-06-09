----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.06.2020 23:42:54
-- Design Name: 
-- Module Name: wb_tb_pkg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:     Wishbone Master Procedures for Testbench reads and writes
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

use work.wb_pkg.all;

package wb_tb_pkg is

    constant wb_tclk_default : time := 10ns;

    procedure p_wb_write(
        signal   wb_clk    : std_logic;
        signal   wb_master : t_wb_master;
        constant address   : unsigned(WB_ADR_W-1 downto 0);
        constant wdata     : unsigned(WB_DAT_W-1 downto 0);
        constant byte_sel  : std_logic_vector(WB_DAT_W/WB_GRAN-1 downto 0) := x"F"  
    ) is
    begin
        -- Set Master control Signals 
        wb_master.stb_o <= '1';
        wb_master.we_o <= '1';
        wb_master.sel_o <= byte_sel;
        wb_master.cyc_o <= '1';
        -- Set Master Data signals
        wb_master.adr_o <= std_logic_vector(address);
        wb_master.dat_o <= std_logic_vector(wdata);
        
        -- Wait for slave to accept wdata
        wait until clk = '1' and wb_master.ack_i = '1';
        
        -- Deassert Master Control Signals
        wb_master.stb_o <= '0';
        wb_master.cyc_o <= '0';
    end p_wb_write;

    procedure p_wb_read(
        signal   wb_clk    : std_logic;
        signal   wb_master : t_wb_master;
        constant address   : unsigned(WB_ADR_W-1 downto 0);
        signal   rdata     : unsigned(WB_DAT_W-1 downto 0)
    ) is
    begin
       -- Set Master Control Signals 
        wb_master.stb_o <= '1';
        wb_master.we_o <= '0';
        wb_master.sel_o <= byte_sel;
        wb_master.cyc_o <= '1';
        wb_master.adr_o <= std_logic_vector(address);        
        
        -- Wait for slave to send rdata 
        wait until wb_clk = '1' and wb_master.ack_i = '1';
        
        -- Accept rdata
        rdata <= wb_master.dat_i;
        
        -- Deassert Master Control Signals
        wb_master.stb_o <= '0';
        wb_master.cyc_o <= '0';
        wait until wb_clk = '1' 
    end p_wb_write;
    
    
    procedure p_wb_respond(
        signal   wb_clk    : std_logic;
        signal   wb_slave  : t_wb_slave;
        constant rdata     : unsigned(WB_DAT_W-1 downto 0) := x"DABEEFEE";
        constant delay     : integer := 0
    ) is 
        variable delay_count : integer;
    begin
        -- wait for a command
        wait until wb_clk = '1' and wb_slave.cyc_i = '1' and wb_slave.stb_i = '1';
        -- insert wait states if required
        if delay > 0 then
            for i in 0 to delay-1
            loop
                wait until wb_clk = '1';
            end loop;
        end if;
        -- repond to command
        if wb_slave.we_i = '1' then
            report("Write of " & wb_slave.dat_i & " to address " & wb_slave.adr_i);
        else 
            report("Read of " & rdata & " at address " & wb_slave.adr_i);
            wb_slave.dat_o <= std_logic_vector(rdata);
        end if;
        -- acknowledge command
        wb_slave.ack_o <= '1';
        
        -- wait until slave select is de-asserted
        wait until wb_clk = '1' and wb_slave.stb_i = '0';
        
        -- finish acknowledement
        wb_slave.ack_o <= '1';
    end p_wb_respond;

end wb_tb_pkg;
