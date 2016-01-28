----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 26.11.2013 17:14:16
-- Design Name: 
-- Module Name: input_queue_control - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description:
-- 3 Finite State Machines handle the reception of data frames and the control signals
-- config_input_state machine: receive valid ports informations from lookup module
-- data_input_state_machine: forward incoming frames to memory, count frame_length and store memory address
-- config_output_state machine: check if there are errors in the frame or if frame is to be skipped
--       if not: store output ports, frame length and memory pointer in frame queue fifo
--               the priority signal indicates which fifo to store the data in
--
-- more detailed information can found in file switch_port_rxpath_input_queue_control.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity input_queue_control is
    Generic (
        RECEIVER_DATA_WIDTH         : integer;
        NR_PORTS                    : integer;
        VLAN_PRIO_WIDTH             : integer;
        TIMESTAMP_WIDTH             : integer;
        IQ_MEM_ADDR_WIDTH           : integer;
        IQ_MEM_DATA_WIDTH_RATIO     : integer;
        IQ_FIFO_DATA_WIDTH          : integer;
        FRAME_LENGTH_WIDTH          : integer;
        IQ_FIFO_PRIO_START          : integer;
        IQ_FIFO_FRAME_LEN_START     : integer;
        IQ_FIFO_TIMESTAMP_START     : integer;
        IQ_FIFO_PORTS_START         : integer;
        IQ_FIFO_MEM_PTR_START       : integer;
        -- register width constants
        CONTROL_REG_ADDR_WIDTH      : integer := 1; -- two entries
        DATA_REG_ADDR_WIDTH         : integer := 1 -- two entries
    );
    Port ( 
        clk                         : in std_logic;
        reset                       : in std_logic;
        -- input interface mac
        iqctrl_in_mac_data          : in std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        iqctrl_in_mac_valid         : in std_logic;
        iqctrl_in_mac_last          : in std_logic; 
        iqctrl_in_mac_error         : in std_logic;
        -- input interface lookup
        iqctrl_in_lu_ports          : in std_logic_vector(NR_PORTS-1 downto 0);
        iqctrl_in_lu_prio           : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        iqctrl_in_lu_skip           : in std_logic;
        iqctrl_in_lu_timestamp      : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        iqctrl_in_lu_valid          : in std_logic;
        -- output interface memory
        iqctrl_out_mem_wenable      : out std_logic;
        iqctrl_out_mem_addr         : out std_logic_vector(IQ_MEM_ADDR_WIDTH-1 downto 0);
        iqctrl_out_mem_data         : out std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        -- output interface fifo
        iqctrl_out_fifo_wenable     : out std_logic;
        iqctrl_out_fifo_data        : out std_logic_vector(IQ_FIFO_DATA_WIDTH-1 downto 0)
    );
end input_queue_control;

architecture rtl of input_queue_control is

    -- register address constants
    constant CONTROL_REG_PORTS_START    : integer := 0;
    constant CONTROL_REG_PRIO_START     : integer := CONTROL_REG_PORTS_START + NR_PORTS;
    constant CONTROL_REG_TIMESTAMP_START : integer := CONTROL_REG_PRIO_START + VLAN_PRIO_WIDTH;
    constant CONTROL_REG_SKIP_START     : integer := CONTROL_REG_TIMESTAMP_START + TIMESTAMP_WIDTH;
    constant DATA_REG_FRAME_LEN_START   : integer := 0;
    constant DATA_REG_MEM_PTR_START     : integer := DATA_REG_FRAME_LEN_START + FRAME_LENGTH_WIDTH;
    constant DATA_REG_ERROR_START       : integer := DATA_REG_MEM_PTR_START + IQ_MEM_ADDR_WIDTH;

    -- config_input_state machine
    type config_input_state is (
        IDLE,
        HANDSHAKE
    );
    -- data_input_state machine
    type data_input_state is (
        IDLE,
        WRITE_MEM
    );
    -- config_output_state machine
    type config_output_state is (
        IDLE,
        WRITE_FIFO
    );
    -- state signals
    signal cur_ci_state       	: config_input_state;
    signal nxt_ci_state        	: config_input_state;
    signal cur_di_state        	: data_input_state;
    signal nxt_di_state        	: data_input_state;
    signal cur_co_state        	: config_output_state;
    signal nxt_co_state        	: config_output_state;
    
    -- control path regsiters
    constant CONTROL_REG_DEPTH 	: integer := 2 ** CONTROL_REG_ADDR_WIDTH;
    constant CONTROL_REG_WIDTH 	: integer := NR_PORTS + VLAN_PRIO_WIDTH + TIMESTAMP_WIDTH + 1;
    type control_reg_type is array(CONTROL_REG_DEPTH-1 downto 0) of std_logic_vector(CONTROL_REG_WIDTH-1 downto 0);
    signal control_reg          : control_reg_type := (others => (others => '0'));
    signal control_rd_addr      : std_logic_vector(CONTROL_REG_ADDR_WIDTH-1 downto 0);
    signal control_nr_entries   : std_logic_vector(CONTROL_REG_ADDR_WIDTH downto 0);
    
    -- data path regsiters
    constant DATA_REG_DEPTH     : integer := 2 ** DATA_REG_ADDR_WIDTH;
    constant DATA_REG_WIDTH     : integer := IQ_MEM_ADDR_WIDTH + FRAME_LENGTH_WIDTH + 1;
    type data_reg_type is array(DATA_REG_DEPTH-1 downto 0) of std_logic_vector(DATA_REG_WIDTH-1 downto 0);
    signal data_reg             : data_reg_type := (others => (others => '0'));
    signal data_rd_addr         : std_logic_vector(DATA_REG_ADDR_WIDTH-1 downto 0);
    signal data_nr_entries      : std_logic_vector(DATA_REG_ADDR_WIDTH downto 0);
    
    -- config_input_state machine signals
    signal control_reg_wr_sig   : std_logic := '0';
    -- data_input_state machine signals
    signal update_frame_length_cnt 	: std_logic := '0';
    signal update_mem_start_ptr     : std_logic := '0';
    signal data_reg_wr_sig          : std_logic := '0';
    -- config_output_state machine signals
    signal control_reg_rd_sig       : std_logic := '0';
    signal data_reg_rd_sig          : std_logic := '0';
    signal write_fifo_sig           : std_logic := '0';
    
    -- process registers
    signal frame_length_cnt         : std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
    signal mem_start_ptr_reg        : std_logic_vector(IQ_MEM_ADDR_WIDTH-1 downto 0);
    
begin

    -- next state logic
    next_state_logic_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                cur_ci_state <= IDLE;
                cur_di_state <= IDLE;
                cur_co_state <= IDLE;
            else
                cur_ci_state <= nxt_ci_state;
                cur_di_state <= nxt_di_state;
                cur_co_state <= nxt_co_state;
            end if;
        end if;
    end process next_state_logic_p;

    -- Decode next config_input_state, combinitorial logic
    ci_output_logic_p : process(cur_ci_state, iqctrl_in_lu_valid)
    begin
        -- default signal assignments
        nxt_ci_state <= IDLE;
        control_reg_wr_sig <= '0';
        
        case cur_ci_state is
            when IDLE => 
                if iqctrl_in_lu_valid = '1' then
                    nxt_ci_state <= HANDSHAKE;
                    control_reg_wr_sig <= '1'; -- control_reg_p
                end if;
            
            when HANDSHAKE => 
                nxt_ci_state <= IDLE;
        end case;
    end process ci_output_logic_p;
    
    -- control register read and write accesses
    control_reg_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                control_rd_addr <= (others => '0');
                control_nr_entries <= (others => '0');
                iqctrl_out_fifo_data(IQ_FIFO_PORTS_START+NR_PORTS-1 downto IQ_FIFO_PORTS_START) 
                    <= (others => '0');
            else
                control_rd_addr <= control_rd_addr;
                control_nr_entries <= control_nr_entries;
                iqctrl_out_fifo_data(IQ_FIFO_PRIO_START+VLAN_PRIO_WIDTH-1 downto IQ_FIFO_PRIO_START) 
                    <= control_reg(conv_integer(control_rd_addr))(CONTROL_REG_PRIO_START+VLAN_PRIO_WIDTH-1 downto CONTROL_REG_PRIO_START);
                iqctrl_out_fifo_data(IQ_FIFO_TIMESTAMP_START+TIMESTAMP_WIDTH-1 downto IQ_FIFO_TIMESTAMP_START) 
                    <= control_reg(conv_integer(control_rd_addr))(CONTROL_REG_TIMESTAMP_START+TIMESTAMP_WIDTH-1 downto CONTROL_REG_TIMESTAMP_START);
                iqctrl_out_fifo_data(IQ_FIFO_PORTS_START+NR_PORTS-1 downto IQ_FIFO_PORTS_START) 
                    <= control_reg(conv_integer(control_rd_addr))(CONTROL_REG_PORTS_START+NR_PORTS-1 downto CONTROL_REG_PORTS_START);
                if control_reg_wr_sig = '1' and control_reg_rd_sig = '1' then
                    control_reg(conv_integer(control_rd_addr)+conv_integer(control_nr_entries)) 
                        <= iqctrl_in_lu_skip & iqctrl_in_lu_timestamp & iqctrl_in_lu_prio & iqctrl_in_lu_ports;
                    control_rd_addr <= control_rd_addr + 1;
                elsif control_reg_wr_sig = '1' then
                    control_reg(conv_integer(control_rd_addr)+conv_integer(control_nr_entries)) 
                        <= iqctrl_in_lu_skip & iqctrl_in_lu_timestamp & iqctrl_in_lu_prio & iqctrl_in_lu_ports;
                    control_nr_entries <= control_nr_entries + 1;
                elsif control_reg_rd_sig = '1' then
                    control_nr_entries <= control_nr_entries - 1;
                    control_rd_addr <= control_rd_addr + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Decode next data_input_state, combinitorial logic
    di_output_logic_p : process(cur_di_state, iqctrl_in_mac_valid, iqctrl_in_mac_last, mem_start_ptr_reg, frame_length_cnt,
                                    iqctrl_in_mac_data, iqctrl_in_mac_error)
    begin
        -- default signal assignments
        nxt_di_state <= IDLE;
        iqctrl_out_mem_wenable <= iqctrl_in_mac_valid;
        iqctrl_out_mem_data <= iqctrl_in_mac_data;
        iqctrl_out_mem_addr <= mem_start_ptr_reg + frame_length_cnt;
        update_frame_length_cnt <= '0';
        update_mem_start_ptr <= '0';
        data_reg_wr_sig <= '0';
        
        case cur_di_state is
            when IDLE => 
                if iqctrl_in_mac_valid = '1' then
                    update_frame_length_cnt <= '1'; -- frame_length_cnt_p
                    nxt_di_state <= WRITE_MEM;
                end if;
            
            when WRITE_MEM => 
                if iqctrl_in_mac_last = '1' and iqctrl_in_mac_valid = '1' then
                    nxt_di_state <= IDLE;
                    data_reg_wr_sig <= '1'; -- data_reg_p
                    if iqctrl_in_mac_error = '0' then
                        update_mem_start_ptr <= '1'; -- update_mem_ptr_p
                    end if;
                elsif iqctrl_in_mac_valid = '1' then
                    nxt_di_state <= WRITE_MEM;
                    update_frame_length_cnt <= '1'; -- frame_length_cnt_p
                else
                    nxt_di_state <= WRITE_MEM;
                end if;
        end case;
    end process di_output_logic_p;
    
    -- count bytes of the current frame
    frame_length_cnt_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                frame_length_cnt <= (others => '0');
            else
                frame_length_cnt <= frame_length_cnt + update_frame_length_cnt;
                if nxt_di_state = IDLE then
                    frame_length_cnt <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
    -- updates the start position of the next frame
    update_mem_ptr_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                mem_start_ptr_reg <= (others => '0');
            else
                mem_start_ptr_reg <= mem_start_ptr_reg;
                if update_mem_start_ptr = '1' then -- move start pointer to new 32-bit line
                    mem_start_ptr_reg <= mem_start_ptr_reg + frame_length_cnt + 1 + 
                        (conv_integer(mem_start_ptr_reg + frame_length_cnt + 1) mod IQ_MEM_DATA_WIDTH_RATIO);
                end if;
            end if;
        end if;
    end process;
    
    -- data register read and write accesses
    data_reg_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                data_rd_addr <= (others => '0');
                data_nr_entries <= (others => '0');
                iqctrl_out_fifo_data(IQ_FIFO_FRAME_LEN_START+FRAME_LENGTH_WIDTH-1 downto IQ_FIFO_FRAME_LEN_START) 
                    <= (others => '0');
                iqctrl_out_fifo_data(IQ_FIFO_MEM_PTR_START+IQ_MEM_ADDR_WIDTH-1 downto IQ_FIFO_MEM_PTR_START) 
                    <= (others => '0');
            else
                data_rd_addr <= data_rd_addr;
                data_nr_entries <= data_nr_entries;
                iqctrl_out_fifo_data(IQ_FIFO_FRAME_LEN_START+FRAME_LENGTH_WIDTH-1 downto IQ_FIFO_FRAME_LEN_START) 
                    <= data_reg(conv_integer(data_rd_addr))(DATA_REG_FRAME_LEN_START+FRAME_LENGTH_WIDTH-1 downto DATA_REG_FRAME_LEN_START);
                iqctrl_out_fifo_data(IQ_FIFO_MEM_PTR_START+IQ_MEM_ADDR_WIDTH-1 downto IQ_FIFO_MEM_PTR_START) 
                    <= data_reg(conv_integer(data_rd_addr))(DATA_REG_MEM_PTR_START+IQ_MEM_ADDR_WIDTH-1 downto DATA_REG_MEM_PTR_START);
                if data_reg_wr_sig = '1' and data_reg_rd_sig = '1' then
                    data_reg(conv_integer(data_rd_addr)+conv_integer(data_nr_entries)) 
                        <= iqctrl_in_mac_error & mem_start_ptr_reg & frame_length_cnt + 1;
                    data_rd_addr <= data_rd_addr + 1;
                elsif data_reg_wr_sig = '1' then
                    data_reg(conv_integer(data_rd_addr)+conv_integer(data_nr_entries)) 
                        <= iqctrl_in_mac_error & mem_start_ptr_reg & frame_length_cnt + 1;
                    data_nr_entries <= data_nr_entries + 1;
                elsif data_reg_rd_sig = '1' then
                    data_rd_addr <= data_rd_addr + 1;
                    data_nr_entries <= data_nr_entries - 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Decode next config_output_state, combinitorial logic
    co_output_logic_p : process(cur_co_state,control_nr_entries, data_nr_entries)
    begin
        -- default signal assignments
        nxt_co_state <= IDLE;
        control_reg_rd_sig <= '0';
        data_reg_rd_sig <= '0';
        write_fifo_sig <= '0';
        
        case cur_co_state is
            when IDLE => 
                if control_nr_entries > 0 and data_nr_entries > 0 then
                    control_reg_rd_sig <= '1'; -- control_reg_p
                    data_reg_rd_sig <= '1'; -- data_reg_p
                    write_fifo_sig <= '1'; -- write_fifo_p
                    nxt_co_state <= WRITE_FIFO;
                end if;
            
            when WRITE_FIFO => 
                nxt_co_state <= IDLE;
        end case;
    end process co_output_logic_p;

    -- write data to fifo by setting the enable signal
    write_fifo_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                iqctrl_out_fifo_wenable <= '0';
            else
                iqctrl_out_fifo_wenable <= '0';
                if write_fifo_sig = '1' then
                    if control_reg(conv_integer(control_rd_addr))(CONTROL_REG_SKIP_START) = '0'
                            and data_reg(conv_integer(data_rd_addr))(DATA_REG_ERROR_START) = '0' 
                            and control_reg(conv_integer(control_rd_addr))(CONTROL_REG_PORTS_START+NR_PORTS-1 downto CONTROL_REG_PORTS_START) /= 0 then
                        iqctrl_out_fifo_wenable <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

end rtl;
