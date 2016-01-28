----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 20.12.2013 15:04:30
-- Design Name: 
-- Module Name: output_port_arbitration - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: the switch fabric arbitration acts as a multiplexer between the input and output ports.
-- Each switch_fabric arbitration module is connected to one output port.
-- If one or multiple input ports are ready to send data to the output port connected to the 
--   fabric_arbitration module, they request access at the arbitration module.
-- The arbitration module then decides in a round robin manner which of the input ports is allowed to
--   send its frame to the output port.
-- As soon as the output port is ready to store the frame, the arbitration module connects the input
--   data signals to the output data signals.
-- 
-- further information can be found in file switch_fabric_arbitration.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity switch_fabric_arbitration is
    generic (
        FABRIC_DATA_WIDTH       : integer;
        NR_PORTS                : integer;
        ARBITRATION             : integer;
        FRAME_LENGTH_WIDTH      : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    port (
        clk                     : in  std_logic;
        reset                   : in  std_logic;
        timestamp_cnt           : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- data from the RX data path
        farb_in_data            : in  std_logic_vector(NR_PORTS*FABRIC_DATA_WIDTH-1 downto 0);
        farb_in_valid           : in  std_logic_vector(NR_PORTS-1 downto 0);
        farb_in_last            : in  std_logic_vector(NR_PORTS-1 downto 0);
        farb_in_ports_req       : in std_logic_vector(NR_PORTS-1 downto 0);
        farb_in_prio            : in std_logic_vector(NR_PORTS*VLAN_PRIO_WIDTH-1 downto 0);
        farb_in_timestamp       : in std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
        farb_in_length          : in std_logic_vector(NR_PORTS*FRAME_LENGTH_WIDTH-1 downto 0);
        farb_in_ports_gnt       : out std_logic_vector(NR_PORTS-1 downto 0);
        -- data TO the TX data path
        farb_out_prio           : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        farb_out_timestamp      : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        farb_out_data           : out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        farb_out_valid          : out std_logic;
        farb_out_length         : out std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        farb_out_req            : out std_logic;
        farb_out_accept_frame   : in  std_logic
    );
end switch_fabric_arbitration;

architecture rtl of switch_fabric_arbitration is
    
    constant LD_NR_PORTS : integer := 2;

    component arbitration_algorithm is
    generic(
        NR_PORTS                : integer;
        LD_NR_PORTS             : integer;
        ARBITRATION             : integer;
        FRAME_LENGTH_WIDTH      : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    port(
        clk                     : in std_logic;
        reset                   : in std_logic;
        in_start_arb            : in std_logic;
        in_req_ports            : in std_logic_vector(NR_PORTS-1 downto 0);
        in_prio                 : in std_logic_vector(NR_PORTS*VLAN_PRIO_WIDTH-1 downto 0);
        in_timestamp            : in std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
        timestamp_cnt           : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        in_length               : in std_logic_vector(NR_PORTS*FRAME_LENGTH_WIDTH-1 downto 0);
        out_arb_finished        : out std_logic;
        out_winner_port         : out std_logic_vector(LD_NR_PORTS-1 downto 0)
    );
    end component;

    -- state machine
    type state is (
        IDLE,
        ARBITRATE,
        REQ_OUTPUT,
        CONNECT,
        WAIT1,
        WAIT2,
        WAIT3
    );
    signal cur_state       	: state;
    signal nxt_state        : state;

    -- state machine signals
    signal start_arbitration_sig    : std_logic;
    signal winner_port_sig      : std_logic_vector(LD_NR_PORTS-1 downto 0);
    signal read_reg_sig         : std_logic;
    signal connect_sig          : std_logic;
    signal arbitration_finished_sig : std_logic;
    -- process registers
    signal gnt_port_id_reg      : std_logic_vector(LD_NR_PORTS-1 downto 0);
    signal length_reg           : std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
    signal prio_reg             : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    signal timestamp_reg        : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal req_reg               : std_logic_vector(NR_PORTS-1 downto 0);
    
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
  
	-- Decode next state, combinitorial logic
	output_logic_p : process(cur_state, farb_in_ports_req, req_reg, arbitration_finished_sig, farb_out_accept_frame, gnt_port_id_reg, farb_in_last)
	begin
		-- default signal assignments
		nxt_state <= IDLE;
        start_arbitration_sig <= '0';
        read_reg_sig <= '0';
        connect_sig <= '0';
		-- default output values
		farb_out_req <= '0';
		farb_in_ports_gnt <= (others => '0');
    
		case cur_state is
			when IDLE => -- waiting for a input port to request access
                if farb_in_ports_req /= 0 then
                    nxt_state <= ARBITRATE;
                	start_arbitration_sig <= '1'; -- arbitration_alg_p
                end if;
            
			when ARBITRATE => -- determine the winner input port
				if arbitration_finished_sig = '1' then
				    nxt_state <= REQ_OUTPUT;
                    read_reg_sig <= '1'; -- read_reg_p
				else
				    nxt_state <= ARBITRATE;
		        end if;

			when REQ_OUTPUT => -- check if the output port is ready to accept the frame
                if farb_out_accept_frame = '1' and farb_in_ports_req(to_integer(unsigned(gnt_port_id_reg))) = '1' then
				    nxt_state <= CONNECT;
				    farb_in_ports_gnt(to_integer(unsigned(gnt_port_id_reg))) <= '1';
                --elsif  
                --    req_reg /= farb_in_ports_req then -- restart new port requesting --> would affect round robin
                --    nxt_state <= IDLE;
				elsif farb_in_ports_req(to_integer(unsigned(gnt_port_id_reg))) = '1' then
				    nxt_state <= REQ_OUTPUT;
				    farb_out_req <= '1';
				end if;
            
			when CONNECT => -- send the frame from the input port to the output port
                connect_sig <= '1'; -- connect_p
                if farb_in_last(to_integer(unsigned(gnt_port_id_reg))) = '1' then
				    nxt_state <= WAIT1;
				    farb_in_ports_gnt(to_integer(unsigned(gnt_port_id_reg))) <= '1';
				else
				    nxt_state <= CONNECT;
				    farb_in_ports_gnt(to_integer(unsigned(gnt_port_id_reg))) <= '1';
				end if;
				
		    when WAIT1 => -- wait three cycles for giving the current granted port time to join the next arbitration round
		        nxt_state <= WAIT2;
		        
            when WAIT2 =>
                nxt_state <= WAIT3;
                
            when WAIT3 =>
                nxt_state <= IDLE;
				
		end case;
	end process;
	
	-- buffer the arbitration winner input port id
    round_robin_p : process (clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                gnt_port_id_reg <= (others => '0');
            else
                gnt_port_id_reg <= gnt_port_id_reg;
                if arbitration_finished_sig = '1' then
                    gnt_port_id_reg <= winner_port_sig;
                end if;
            end if;
        end if;
    end process;
	
	-- buffer requests
    request_p : process (clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                req_reg <= (others => '0');
            else
                req_reg <= farb_in_ports_req;
            end if;
        end if;
    end process;
	
	-- buffer the frame length of the winner input port
	read_reg_p : process (clk)
	begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                length_reg <= (others => '0');
                prio_reg <= (others => '0');
                timestamp_reg <= (others => '0');
            else
                length_reg <= length_reg;
                prio_reg <= prio_reg;
                timestamp_reg <= timestamp_reg;
                if read_reg_sig = '1' then
                    length_reg <= farb_in_length(((to_integer(unsigned(winner_port_sig)))+1)*FRAME_LENGTH_WIDTH-1 downto 
                                                                (to_integer(unsigned(winner_port_sig)))*FRAME_LENGTH_WIDTH);
                    prio_reg <= farb_in_prio(((to_integer(unsigned(winner_port_sig)))+1)*VLAN_PRIO_WIDTH-1 downto 
                                                                (to_integer(unsigned(winner_port_sig)))*VLAN_PRIO_WIDTH);
                    timestamp_reg <= farb_in_timestamp(((to_integer(unsigned(winner_port_sig)))+1)*TIMESTAMP_WIDTH-1 downto 
                                                                (to_integer(unsigned(winner_port_sig)))*TIMESTAMP_WIDTH);
                end if;
            end if;
        end if;
    end process;
	
	-- connect the arbitration winner input port to the output port
	connect_p : process(farb_in_data, farb_in_valid, connect_sig, gnt_port_id_reg)
	begin
        farb_out_valid <= '0';
        farb_out_data <= (others => '0');
        if connect_sig = '1' then
            farb_out_valid <= farb_in_valid(to_integer(unsigned(gnt_port_id_reg)));
            farb_out_data <= farb_in_data(((to_integer(unsigned(gnt_port_id_reg)))+1)*FABRIC_DATA_WIDTH-1 downto 
                                                        (to_integer(unsigned(gnt_port_id_reg)))*FABRIC_DATA_WIDTH);
        end if;
    end process;
	
	arbitration_alg_p : arbitration_algorithm
    generic map(
        NR_PORTS                => NR_PORTS,
        LD_NR_PORTS             => LD_NR_PORTS,
        ARBITRATION             => ARBITRATION,
        FRAME_LENGTH_WIDTH      => FRAME_LENGTH_WIDTH,
        VLAN_PRIO_WIDTH         => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH         => TIMESTAMP_WIDTH
    )
    port map(
        clk                     => clk,
        reset                   => reset,
        in_start_arb            => start_arbitration_sig,
        in_req_ports            => farb_in_ports_req,
        in_prio                 => farb_in_prio,
        in_timestamp            => farb_in_timestamp,
        timestamp_cnt           => timestamp_cnt,
        in_length               => farb_in_length,
        out_arb_finished        => arbitration_finished_sig,
        out_winner_port         => winner_port_sig
    );
	
	farb_out_length <= length_reg;
	farb_out_prio <= prio_reg;
	farb_out_timestamp <= timestamp_reg;
	
end rtl;
