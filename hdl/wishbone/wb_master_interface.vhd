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

use work.wb_pkg.all;

entity wb_master_interface is
Port (
    -- wishbone I/F
    wb_clk_i    : in  std_logic;        -- clock
    wb_rst_i    : in  std_logic;        -- reset
    wb_mosi     : out t_wb_mosi;
    wb_miso     : in  t_wb_miso;
    
    -- I/O
    valid_cmd    : in  std_logic;
    ready_cmd    : out std_logic;
    addr_cmd     : std_logic_vector(WB_ADR_W-1 downto 0);
    we_cmd       : std_logic;
    wdata_cmd    : std_logic_vector(WB_DAT_W-1 downto 0);
    
    valid_rsp   : out std_logic;
    rdata_rsp   : out std_logic_vector(WB_DAT_W-1 downto 0); 
    wen_rsp    : out  std_logic; -- show if response was a write
    ready_rsp   : in std_logic

);
end wb_master_interface;

architecture rtl of wb_master_interface is
    type t_state is (IDLE, WB_WAIT_FOR_ACK, DONE);
    signal state : t_state;
begin
    
    state_machine : process(wb_clk_i, wb_rst_i) is 
    begin
        if wb_rst_i = '1' then
            state <= IDLE;
        else
            if rising_edge(wb_clk_i) then
                case state is 
                    when IDLE => 
                        if valid_cmd = '1' then
                            state <= WB_WAIT_FOR_ACK;
                        end if;
                    
                    when WB_WAIT_FOR_ACK => 
                        if wb_miso.ack = '1' then
                            state <= DONE;
                            rdata_rsp <= wb_miso.rdata; -- register RDATA
                            wen_rsp <= we_cmd;          -- register if RDATA is relevant 
                        end if;
                    when DONE => 
                        if ready_rsp = '1' then
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;
    
    
    comb_out : process(all) is 
    begin
        -- defaults
        ready_cmd <= '0';
        valid_rsp <= '0';
        wb_mosi.stb <= '0';
        wb_mosi.cyc <= '0';
        wb_mosi.wdata <= x"0000_0000";
        wb_mosi.adr <= x"0000_0000";
        wb_mosi.we <= '0';
        wb_mosi.sel <= x"F";
        case state is 
            when IDLE => 
                ready_cmd <= '1';
            when WB_WAIT_FOR_ACK => 
                wb_mosi.stb <= '1';
                wb_mosi.cyc <= '1';
                wb_mosi.wdata <= wdata_cmd;
                wb_mosi.adr <= addr_cmd;
                wb_mosi.we <= we_cmd;
                wb_mosi.sel <= x"F";
            when DONE => 
                valid_rsp <= '1';
        end case;
    end process;


end rtl;
