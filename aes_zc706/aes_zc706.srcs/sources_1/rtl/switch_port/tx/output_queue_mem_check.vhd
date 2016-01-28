----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 10.12.2013 16:17:41
-- Design Name: 
-- Module Name: output_queue_overflow_check - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: this module checks upon a request if another frame can be accepted from the switching fabric
-- No accept uppon a request will be returned if either the FIFO is full or there is not enough place in the memory
-- 
-- further information can be found in switch_port_txpath_output_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity output_queue_mem_check is
    Generic (
        OQ_FIFO_DATA_WIDTH          : integer;
        OQ_MEM_ADDR_WIDTH           : integer;
        OQ_FIFO_MEM_PTR_START       : integer;
        FRAME_LENGTH_WIDTH          : integer;
        NR_OQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer
    );
    Port ( 
        clk                	: in  std_logic;
        reset               : in  std_logic;
        req                 : in  std_logic;
        req_length          : in  std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        req_prio            : in  std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        accept_frame        : out std_logic;
        mem_wr_ptr          : in  std_logic_vector(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH-1 downto 0);
        fifo_data           : in  std_logic_vector(NR_OQ_FIFOS*OQ_FIFO_DATA_WIDTH-1 downto 0);
        fifo_full           : in  std_logic_vector(NR_OQ_FIFOS-1 downto 0);
        fifo_empty          : in  std_logic_vector(NR_OQ_FIFOS-1 downto 0)
    );
end output_queue_mem_check;


    

architecture rtl of output_queue_mem_check is
    signal high_priority_border_value_reg   : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0) := "001";
    signal debug_rd_reg                     : std_logic_vector(OQ_MEM_ADDR_WIDTH-1 downto 0);
    signal debug_wr_reg                     : std_logic_vector(OQ_MEM_ADDR_WIDTH-1 downto 0);
    signal debug_mem_space                  : std_logic_vector(OQ_MEM_ADDR_WIDTH-1 downto 0);
    signal debug_length                     : std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
begin

    -- upon a request signal from switch fabric check if the frame can be accepted
    -- accept_frame = req AND (fifo_empty OR (NOT fifo_full AND (mem_rd_ptr - mem_wr_ptr >= req_length)))
--    mem_check_p : process (clk)
--        variable mem_rd_ptr         : std_logic_vector(OQ_MEM_ADDR_WIDTH-1 downto 0);
--        variable temp_mem_full      : std_logic;
--        variable temp_accept        : std_logic;
--    begin
--        if clk'event and clk = '1' then
--            if reset = '1' then
--                accept_frame <= '0';
--            else
--                temp_accept := req;
--                for i in 0 to NR_OQ_FIFOS-1 loop
--                    mem_rd_ptr := fifo_data(i*OQ_FIFO_DATA_WIDTH+OQ_FIFO_MEM_PTR_START+OQ_MEM_ADDR_WIDTH-1 downto i*OQ_FIFO_DATA_WIDTH+OQ_FIFO_MEM_PTR_START);
--                    if mem_rd_ptr - mem_wr_ptr >= req_length then
--                        temp_mem_full := '0';
--                    else
--                        temp_mem_full := '1';
--                    end if;
--                    if temp_accept = '1' then
--                        temp_accept := fifo_empty(i) or (not fifo_full(i) and not temp_mem_full);
--                    else
--                        temp_accept := '0';
--                    end if;
--                end loop;
--                accept_frame <= temp_accept;
--            end if;
--        end if;
--    end process;

    mem_check_p : process (clk)
        variable mem_rd_ptr         : std_logic_vector(OQ_MEM_ADDR_WIDTH-1 downto 0);
        variable tmp_mem_wr_ptr     : std_logic_vector(OQ_MEM_ADDR_WIDTH-1 downto 0);
        variable temp_mem_full      : std_logic;
        variable temp_accept        : std_logic;
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                accept_frame <= '0';
            else
                temp_accept := req;
                if NR_OQ_FIFOS = 1 then
                    mem_rd_ptr := fifo_data(OQ_FIFO_MEM_PTR_START+OQ_MEM_ADDR_WIDTH-1 downto OQ_FIFO_MEM_PTR_START);
                    if mem_rd_ptr - mem_wr_ptr >= req_length then
                        temp_mem_full := '0';
                    else
                        temp_mem_full := '1';
                    end if;
                    if temp_accept = '1' then
                        temp_accept := fifo_empty(0) or (not fifo_full(0) and not temp_mem_full);
                    else
                        temp_accept := '0';
                    end if;                    
                elsif NR_OQ_FIFOS = 2 then
                    if req_prio >= high_priority_border_value_reg then
                        mem_rd_ptr := fifo_data(OQ_FIFO_DATA_WIDTH+OQ_FIFO_MEM_PTR_START+OQ_MEM_ADDR_WIDTH-1 downto OQ_FIFO_DATA_WIDTH+OQ_FIFO_MEM_PTR_START);
                        tmp_mem_wr_ptr := mem_wr_ptr(2*OQ_MEM_ADDR_WIDTH-1 downto OQ_MEM_ADDR_WIDTH);
                        if mem_rd_ptr - tmp_mem_wr_ptr >= req_length + 4 then -- + 4: memory is alligned to full 32 bit words when using 32 bit fabric width --> actual memory space is max. length+4
                            temp_mem_full := '0';
                        else
                            temp_mem_full := '1';
                        end if;
                        if temp_accept = '1' then
                            temp_accept := fifo_empty(1) or (not fifo_full(1) and not temp_mem_full);
                        else
                            temp_accept := '0';
                        end if;                      
                    else
                        mem_rd_ptr := fifo_data(OQ_FIFO_MEM_PTR_START+OQ_MEM_ADDR_WIDTH-1 downto OQ_FIFO_MEM_PTR_START);
                        debug_rd_reg <= fifo_data(OQ_FIFO_MEM_PTR_START+OQ_MEM_ADDR_WIDTH-1 downto OQ_FIFO_MEM_PTR_START);
                        tmp_mem_wr_ptr := mem_wr_ptr(OQ_MEM_ADDR_WIDTH-1 downto 0);
                        debug_wr_reg <= mem_wr_ptr(OQ_MEM_ADDR_WIDTH-1 downto 0);
                        debug_length <= req_length;
                        debug_mem_space <= mem_rd_ptr - tmp_mem_wr_ptr;
                        if mem_rd_ptr - tmp_mem_wr_ptr >= req_length + 4 then -- + 4: memory is alligned to full 32 bit words when using 32 bit fabric width --> actual memory space is max. length+4
                            temp_mem_full := '0';
                        else
                            temp_mem_full := '1';
                        end if;
                        if temp_accept = '1' then
                            temp_accept := fifo_empty(0) or (not fifo_full(0) and not temp_mem_full);
                        else
                            temp_accept := '0';
                        end if;   
                    end if;
                end if;
                accept_frame <= temp_accept;
            end if;
        end if;
    end process;

end rtl;
