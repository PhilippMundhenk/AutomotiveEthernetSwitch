----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 10.12.2013 10:48:52
-- Design Name: 
-- Module Name: output_queue_control - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description:
-- state machine that controls the storage of data transfered over the switching fabric
-- the frame is stored in the output queue module
-- the length and the frame's start position in the memory are stored in the output queue fifo
--
-- further information can be found in switch_port_txpath_output_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity output_queue_control is
    Generic (
        FABRIC_DATA_WIDTH           : integer;
        FRAME_LENGTH_WIDTH          : integer;
        NR_OQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer;
        TIMESTAMP_WIDTH             : integer;
        OQ_MEM_ADDR_WIDTH_A         : integer;
        OQ_MEM_ADDR_WIDTH_B         : integer;
        OQ_FIFO_DATA_WIDTH          : integer;
        FABRIC2TRANSMITTER_DATA_WIDTH_RATIO : integer
    );
    Port (
        clk                        	: in  std_logic;
        reset                       : in  std_logic;
        -- input interface fabric
        oqctrl_in_data              : in  std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        oqctrl_in_valid             : in  std_logic;
        oqctrl_in_length            : in  std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        oqctrl_in_prio              : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        oqctrl_in_timestamp         : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- output interface memory check
        oqctrl_out_mem_wr_addr      : out std_logic_vector(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_B-1 downto 0);
        -- output interface memory
        oqctrl_out_mem_wenable      : out std_logic;
        oqctrl_out_mem_addr         : out std_logic_vector(OQ_MEM_ADDR_WIDTH_A-1 downto 0);
        oqctrl_out_mem_data         : out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        -- output interface fifo
        oqctrl_out_fifo_wenable     : out std_logic;
        oqctrl_out_fifo_data        : out std_logic_vector(OQ_FIFO_DATA_WIDTH-1 downto 0);
        oqctrl_out_fifo_prio        : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0)
    );
end output_queue_control;

architecture rtl of output_queue_control is

    -- state machine
    type state is (
        IDLE,
        WRITE_MEM
    );
    -- state signals
    signal cur_state        : state;
    signal nxt_state        : state;

    -- config_output_state machine signals
    signal read_reg_sig             : std_logic := '0';
    signal update_cnt_sig           : std_logic := '0';
    signal reset_frame_length_sig   : std_logic := '0';
    signal update_mem_ptr_sig       : std_logic := '0';
    
    -- process registers
    signal frame_length_cnt         : std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
    signal frame_length_reg         : std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
    signal timestamp_reg            : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal prio_reg                 : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    signal mem_start_ptr_reg        : std_logic_vector(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto 0);

    signal high_priority_border_value_reg   : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0) := "001";
    
begin

    -- next state logic
    next_state_logic_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                cur_state <= IDLE;
            else
                cur_state <= nxt_state;
            end if;
        end if;
    end process next_state_logic_p;

    -- Decode next data_input_state, combinitorial logic
    output_logic_p : process(cur_state, oqctrl_in_valid, frame_length_cnt, frame_length_reg)
    begin
        -- default signal assignments
        nxt_state <= IDLE;
        read_reg_sig <= '0';
        update_cnt_sig <= '0';
        reset_frame_length_sig <= '0';
        update_mem_ptr_sig <= '0';
        oqctrl_out_mem_wenable <= '0';
        oqctrl_out_fifo_wenable <= '0';
        
        case cur_state is
            when IDLE => 
                if oqctrl_in_valid = '1' then
                    nxt_state <= WRITE_MEM;
                    read_reg_sig <= '1'; -- read_reg_p
                    update_cnt_sig <= '1'; -- cnt_frame_length_p
                    oqctrl_out_mem_wenable <= '1';
                end if;
            
            when WRITE_MEM => 
                nxt_state <= WRITE_MEM;
                if frame_length_cnt >= frame_length_reg then
                    nxt_state <= IDLE;
                    reset_frame_length_sig <= '1'; -- cnt_frame_length_p
                    oqctrl_out_fifo_wenable <= '1';
                    update_mem_ptr_sig <= '1'; -- update_mem_ptr_p
                elsif oqctrl_in_valid = '1' then
                    nxt_state <= WRITE_MEM;
                    update_cnt_sig <= '1'; -- cnt_frame_length_p
                    oqctrl_out_mem_wenable <= '1';
                end if;
                
        end case;
    end process output_logic_p;

    -- count frame bytes received from fabric
    cnt_frame_length_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                frame_length_cnt <= (others => '0');
            else
                frame_length_cnt <= frame_length_cnt;
                if reset_frame_length_sig = '1' then
                    frame_length_cnt <= (others => '0');
                elsif update_cnt_sig = '1' then
                    frame_length_cnt <= frame_length_cnt + FABRIC2TRANSMITTER_DATA_WIDTH_RATIO;
                end if;
            end if;
        end if;
    end process;
    
    -- read the frame length of the incoming frame
    read_reg_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                frame_length_reg <= (others => '0');
                timestamp_reg <= (others => '0');
                prio_reg <= (others => '0');
            else
                frame_length_reg <= frame_length_reg;
                timestamp_reg <= timestamp_reg;
                prio_reg <= prio_reg;
                if read_reg_sig = '1' then
                    frame_length_reg <= oqctrl_in_length;
                    timestamp_reg <= oqctrl_in_timestamp;
                    prio_reg <= oqctrl_in_prio;
                end if;
            end if;
        end if;
    end process;
    
    -- update memory start address of next incoming frame
    update_mem_ptr_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                mem_start_ptr_reg <= (others => '0');
            else
                mem_start_ptr_reg <= mem_start_ptr_reg;
                if update_mem_ptr_sig = '1' then
                    if NR_OQ_FIFOS = 2 and prio_reg >= high_priority_border_value_reg then
                        mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) <= 
                                mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) + 
                                frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A) + 1;
                    else
                        mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) <= mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) + 
                                frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A) + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
-- switch fabric 32 bit
    output_p : process(high_priority_border_value_reg, mem_start_ptr_reg, frame_length_cnt, timestamp_reg, oqctrl_in_prio, frame_length_reg)
    begin
        if NR_OQ_FIFOS = 1 then
            oqctrl_out_mem_addr     <= mem_start_ptr_reg + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
            oqctrl_out_fifo_data    <= mem_start_ptr_reg & "00" & timestamp_reg & frame_length_reg;
            oqctrl_out_mem_wr_addr  <= mem_start_ptr_reg & "00";
        else
            oqctrl_out_mem_wr_addr  <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) & "00" &
                                            mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) & "00";
            if oqctrl_in_prio >= high_priority_border_value_reg then
                oqctrl_out_mem_addr     <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) 
                                + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
                oqctrl_out_fifo_data    <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) & "00" & timestamp_reg & frame_length_reg;
            else
                oqctrl_out_mem_addr     <= mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) 
                                + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
                oqctrl_out_fifo_data    <= mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) & "00" & timestamp_reg & frame_length_reg;
            end if;
        end if;
    end process;

-- switch fabric 16 bit
--    output_p : process(high_priority_border_value_reg, mem_start_ptr_reg, frame_length_cnt, timestamp_reg, oqctrl_in_prio, frame_length_reg)
--    begin
--        if NR_OQ_FIFOS = 1 then
--            oqctrl_out_mem_addr     <= mem_start_ptr_reg + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
--            oqctrl_out_fifo_data    <= mem_start_ptr_reg & "0" & timestamp_reg & frame_length_reg;
--            oqctrl_out_mem_wr_addr  <= mem_start_ptr_reg & "0";
--        else
--            oqctrl_out_mem_wr_addr  <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) & "0" &
--                                            mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) & "0";
--            if oqctrl_in_prio >= high_priority_border_value_reg then
--                oqctrl_out_mem_addr     <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) 
--                                + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
--                oqctrl_out_fifo_data    <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) & "0" & timestamp_reg & frame_length_reg;
--            else
--                oqctrl_out_mem_addr     <= mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) 
--                                + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
--                oqctrl_out_fifo_data    <= mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) & "0" & timestamp_reg & frame_length_reg;
--            end if;
--        end if;
--    end process;

-- switch fabric 8 bit
--    output_p : process(high_priority_border_value_reg, mem_start_ptr_reg, frame_length_cnt, timestamp_reg, oqctrl_in_prio, frame_length_reg)
--    begin
--        if NR_OQ_FIFOS = 1 then
--            oqctrl_out_mem_addr     <= mem_start_ptr_reg + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
--            oqctrl_out_fifo_data    <= mem_start_ptr_reg & timestamp_reg & frame_length_reg;
--            oqctrl_out_mem_wr_addr  <= mem_start_ptr_reg;
--        else
--            oqctrl_out_mem_wr_addr  <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) &
--                                            mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0);
--            if oqctrl_in_prio >= high_priority_border_value_reg then
--                oqctrl_out_mem_addr     <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) 
--                                + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
--                oqctrl_out_fifo_data    <= mem_start_ptr_reg(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_A-1 downto (NR_OQ_FIFOS-1)*OQ_MEM_ADDR_WIDTH_A) & timestamp_reg & frame_length_reg;
--            else
--                oqctrl_out_mem_addr     <= mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) 
--                                + frame_length_cnt(FRAME_LENGTH_WIDTH-1 downto OQ_MEM_ADDR_WIDTH_B - OQ_MEM_ADDR_WIDTH_A);
--                oqctrl_out_fifo_data    <= mem_start_ptr_reg(OQ_MEM_ADDR_WIDTH_A-1 downto 0) & timestamp_reg & frame_length_reg;
--            end if;
--        end if;
--    end process;
    
    oqctrl_out_mem_data     <= oqctrl_in_data;
    oqctrl_out_fifo_prio    <= prio_reg;
    
end rtl;
