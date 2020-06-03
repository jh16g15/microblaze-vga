----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2020 13:27:02
-- Design Name: 
-- Module Name: display_control - rtl
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

-- Select which resolution we are targetting
use work.pkg_vga_params_1280_1024_60hz.all;
--use work.pkg_vga_params_640_480_60hz.all;

entity display_control is    
Port ( 
    pixelclk : in std_logic;
    reset_n : in std_logic;
    vga_hs : out std_logic;
    vga_vs : out std_logic;
    vga_g : out std_logic_vector (3 downto 0);
    vga_r : out std_logic_vector (3 downto 0);
    vga_b : out std_logic_vector (3 downto 0)
);
end display_control;

architecture rtl of display_control is
    
    -- font parameters
    constant CHAR_W : integer := 8;
    constant CHAR_H : integer := 16;
    
    -- font RAM parameters
    constant CHARS_IN_FONT : integer := 256;
    constant ADDR_W : integer := 12;        -- todo: parametersise this
    constant DATA_W : integer := CHAR_W;
    constant DEPTH : integer := CHAR_H * CHARS_IN_FONT;

    -- display parameters
    constant CHARS_X : integer := END_ACTIVE_X / CHAR_W;
    constant CHARS_Y : integer := END_ACTIVE_Y / CHAR_H; 
    
    -- RAM control signals
    signal ena      : std_logic;
    signal enb      : std_logic;
    signal wea      : std_logic;
    signal addra    : std_logic_vector(ADDR_W-1 downto 0);
    signal addrb    : std_logic_vector(ADDR_W-1 downto 0);
    signal dia      : std_logic_vector(DATA_W-1 downto 0);
    signal dob      : std_logic_vector(DATA_W-1 downto 0);
    
    signal h_count  : integer; 
    signal v_count  : integer;
    signal h_count_d1  : integer; 
    signal v_count_d1  : integer;
    signal h_count_d2  : integer; 
    signal v_count_d2  : integer;
    signal active_area : std_logic;
    
    signal char_x   : integer;
    signal char_y   : integer;
    signal char_address : integer;
    
    -- display signals
    signal font_line : std_logic_vector(CHAR_W-1 downto 0);
    signal font_row : integer;
    signal charcode_to_display : unsigned(ADDR_W-1 downto 0); -- up to 255, but need to scale up width to avoid overflow
    signal charcode_base_address : unsigned(ADDR_W-1 downto 0);
    
    signal vga_r2 : std_logic_vector(3 downto 0);
    signal vga_g2 : std_logic_vector(3 downto 0);
    signal vga_b2 : std_logic_vector(3 downto 0);
    
    signal char_x_slv : std_logic_vector(15 downto 0); 
    signal make_char_green : std_logic;
    signal make_char_red : std_logic;
    
begin
    
    -- Char Address mapping - which char we are in from the mem
    -- this is the first stage in the pipeline so don't use counter delays
    char_x <= to_integer(shift_right(to_unsigned(h_count, 32), 3)); -- 8 pixels width per char
    char_y <= to_integer(shift_right(to_unsigned(v_count, 32), 4)); -- 16 pixels width per char
    
    char_address <= char_y * CHARS_X + char_x;
    
    
    
    
    --    Content Generation
    -- need to give 2 cycles of time to "go back" to when these chars were selected
    
    -- we want bit 7 when we are in cycle 0 for the character row
    vga_r2 <= X"f" when font_line(7 - to_integer(to_unsigned(h_count_d2, 32)(2 downto 0))) = '1' and active_area = '1' and make_char_red = '1' else x"0";
    vga_g2 <= X"f" when font_line(7 - to_integer(to_unsigned(h_count_d2, 32)(2 downto 0))) = '1' and active_area = '1' and make_char_green = '1' else x"0";
    vga_b2 <= X"0" when font_line(7 - to_integer(to_unsigned(h_count_d2, 32)(2 downto 0))) = '1' and active_area = '1' else x"0";
        
    
    -- add a 1 pixel blue border to check alignment
    -- we need to use the counters we are using for the sync signal generation
    process(h_count_d2, v_count_d2) is
    begin
        if active_area = '1' then -- remove this when we remove the border, as it's checked above
            if ( h_count_d2 = 0 or h_count_d2 = END_ACTIVE_X-1 or v_count_d2 = 0 or v_count_d2 = END_ACTIVE_Y-1) then
                vga_r <= vga_r2;
                vga_g <= vga_g2;
                vga_b <= X"f";
            else
                vga_r <= vga_r2;
                vga_g <= vga_g2;
                vga_b <= vga_b2;
            
            end if;
        else
            vga_r <= x"0";
            vga_g <= x"0";
            vga_b <= x"0";
        end if;
    end process;
   
        
        
-- test pattern    
--    vga_r <= std_logic_vector(to_unsigned(h_count, 16)(3 downto 0));    
--    vga_g <= std_logic_vector(to_unsigned(h_count, 16)(7 downto 4));
--    vga_b <= std_logic_vector(to_unsigned(h_count, 16)(11 downto 8));
    
    -- VGA Control Signals
    active_area <= '1' when (h_count_d2 < END_ACTIVE_X) and (v_count_d2 < END_ACTIVE_Y) else '0';

    -- we will need to delay these sync signals for every cycle taken to fetch pixel data
    -- current latency required = 2 (block RAM + font_line register)
    
    vga_hs <= ACTIVE_HS when (h_count_d2 >= END_FPORCH_X) and (h_count_d2 < END_SYNC_X) else not ACTIVE_HS;
    vga_vs <= ACTIVE_VS when (v_count_d2 >= END_FPORCH_Y) and (v_count_d2 < END_SYNC_Y) else not ACTIVE_VS;
    
    -- VSYNC and HSYNC counters
    sync_counters : process(pixelclk)
    begin   
    if reset_n = '0' then 
        h_count <= 0;
        v_count <= 0;
    else
        if rising_edge(pixelclk) then
            -- counters
            if h_count >=  END_BPORCH_X then
                h_count <= 0;
            else 
                h_count <= h_count + 1;
            end if;
            if v_count >= END_BPORCH_Y then
                v_count <= 0;
            else
                if h_count >=  END_BPORCH_X then
                    v_count <= v_count + 1;
                end if;
            end if;
            
            h_count_d1 <= h_count;
            h_count_d2 <= h_count_d1;
            
            v_count_d1 <= v_count;
            v_count_d2 <= v_count_d1;
            
            
            
        end if;
    end if;
    end process;

    
    

    -- write port A not in use
    ena <= '0';
    wea <= '0';
    addra <= std_logic_vector(to_unsigned(0 , ADDR_W));
    dia <= (others => '0');


    font_ram : entity work.simple_dual_two_clocks
        generic map(
            ADDR_W => ADDR_W,
            DATA_W => DATA_W,
            DEPTH  => DEPTH,
            USE_INIT_FILE => true,
            INIT_FILE_NAME => "../tools/font_rom.txt"
        )
        port map(
            clka    => pixelclk,
            clkb    => pixelclk,
            ena     => ena,
            enb     => enb,
            wea     => wea,
            addra   => addra,
            addrb   => addrb,
            dia     => dia,
            dob     => dob
        );
    
    -- these all use the earliest h/v_count as its the start of the pipeline
    font_row <= to_integer(to_unsigned(v_count, 32)(3 downto 0)); -- bottom 4 bits of v_count
    
    -- temp char display test - this will eventually come from a 
    process(char_address) is 
    begin
        if char_address = 0 or char_address = 159 then
            charcode_to_display <= x"008";
        elsif char_address = 10080 or char_address = 10239 then
            charcode_to_display <= x"00a";
        elsif char_address >= 160 and char_address < 290 then
            charcode_to_display <= char_address - to_unsigned(160, 12);
        elsif char_address = 320 then
            charcode_to_display <= x"008";
        -- check for artifacting
        elsif char_address = 481 then
            charcode_to_display <= x"039"; -- 9
        elsif char_address = 160 * 4 + 1 then
            charcode_to_display <= x"037";  -- 7
        elsif char_address = 160 * 4 + 2 then
            charcode_to_display <= x"038";  -- 8
        elsif char_address = 160 * 4 + 3 then
            charcode_to_display <= x"039";  -- 9
        elsif char_address = 160 * 4 + 4 then
            charcode_to_display <= x"03a";  -- :
        else
            charcode_to_display <= x"000";
        end if;


    end process;
    
--    charcode_to_display(ADDR_W-1 downto 8) <= (others => '0');
--    charcode_to_display(7 downto 0) <= to_unsigned(char_address, 32)(7 downto 0); -- 0 to 

    charcode_base_address <= shift_left(charcode_to_display, 4); -- charcode*16 
    font_line <= dob;
    read_font_line : process(pixelclk) 
    -- read_font_line : process(h_count) 
    begin
        if rising_edge(pixelclk) then
            -- defaults
            enb <= '0'; 
            -- if we are at the start of a new char
            if to_unsigned(h_count, 32)(2 downto 0) = B"000" then
                enb <= '1';
                -- temp display char select
                addrb <= std_logic_vector(charcode_base_address + font_row); -- (0 to 255) * 16 + vcount % 16
                char_x_slv <= std_logic_vector(to_unsigned(char_x, 16));
            end if;
        
        end if;
    end process;
    
    -- alternate character colouring
    make_char_green <= char_x_slv(0);
    make_char_red <= not char_x_slv(0);
	
	
	

    
end rtl;
