----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 20.12.2013 16:58:39
-- Design Name: 
-- Module Name: arbitration_round_robin - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq7000
-- Tool Versions: vivado 2013.3
-- 
-- Description:
-- This implementation of a multiple algorithms that determine which of
--   the input ports is allowed to send the to the output port.
-- The algorithm is specified by the ARBITRATION generic:
--          1: Round Robin
--          2: Priority based
--          3: Latency based
--          4: Weighted prio/latency based
--          5: Fair Queuing
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity arbitration_algorithm is
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
end arbitration_algorithm;

architecture rtl of arbitration_algorithm is

    -- state machine
    type state is (
        IDLE,
        ARBITRATE
    );
    signal cur_state       	: state;
    signal nxt_state        : state;

    type port_weight_type is array(0 to NR_PORTS-1) of integer;
    type prio_weight_type is array(0 to 8-1) of integer;
    signal port_weight          : port_weight_type := (0 => 1, 
                                                       1 => 1, 
                                                       2 => 1, 
                                                       3 => 1);
    signal prio_weight          : prio_weight_type := (0 => 0,
                                                       1 => 3500,
                                                       2 => 2500,
                                                       3 => 3750,
                                                       4 => 5000,
                                                       5 => 6250,
                                                       6 => 7500,
                                                       7 => 8750);

    signal arb_finished_reg     : std_logic := '0';
    signal cur_winner_reg       : std_logic_vector(LD_NR_PORTS-1 downto 0);
    signal nxt_winner_reg       : std_logic_vector(LD_NR_PORTS-1 downto 0);
    signal cnt                  : std_logic_vector(2 downto 0);
    
    signal run_arbitration_sig  : std_logic;
    signal arb_finished_sig     : std_logic;
    signal arbitration_timestamp : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal prev_req_reg         : std_logic_vector(NR_PORTS-1 downto 0);
    signal arb_req_reg          : std_logic_vector(NR_PORTS-1 downto 0);
    
    signal vft0_reg             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0); -- virtual finishing time
    signal vft1_reg             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal vft2_reg             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal vft3_reg             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal vst0_reg             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0); -- virtual start time
    signal vst1_reg             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal vst2_reg             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal vst3_reg             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal virtual_time_reg     : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    
    signal timestamp0           : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal timestamp1           : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal timestamp2           : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal timestamp3           : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    
    signal score0_reg           : integer;
    signal score1_reg           : integer;
    signal score2_reg           : integer;
    signal score3_reg           : integer;

begin

    timestamp0 <= in_timestamp(63 downto 0);
    timestamp1 <= in_timestamp(127 downto 64);
    timestamp2 <= in_timestamp(191 downto 128);
    timestamp3 <= in_timestamp(255 downto 192);

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
	output_logic_p : process(cur_state, in_start_arb, arb_finished_reg)
	begin
		-- default signal assignments
		nxt_state <= IDLE;
		out_arb_finished <= '0';
		run_arbitration_sig <= '0';
		arb_finished_sig <= '0';
    
		case cur_state is
			when IDLE => -- waiting for a input port to request access
                if in_start_arb = '1' then
                    nxt_state <= ARBITRATE;
                	run_arbitration_sig <= '1';
                end if;
            
			when ARBITRATE => -- determine the winner input port
			    if arb_finished_reg = '1' then
			        nxt_state <= IDLE;
                	out_arb_finished <= '1';
                	arb_finished_sig <= '1';
			    else
			        nxt_state <= ARBITRATE;
			        run_arbitration_sig <= '1';
			    end if;
		        
		end case;
    end process;

    arbitration_p : process(clk)
        variable tmp_port       : integer := 0;
        variable leading_port   : integer := 0;
        variable leading_port01 : integer := 0;
        variable leading_port23 : integer := 0;
        variable tmp_prio       : integer := 0;
        variable tmp_prio0      : integer := 0;
        variable tmp_prio1      : integer := 0;
        variable tmp_prio2      : integer := 0;
        variable tmp_prio3      : integer := 0;
        variable leading_prio   : integer := 0;
        variable tmp_latency    : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_latency0   : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_latency1   : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_latency2   : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_latency3   : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_timestamp  : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_timestamp0 : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_timestamp1 : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_timestamp2 : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_timestamp3 : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable leading_latency : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable leading_latency01 : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable leading_latency23 : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
        variable tmp_score      : integer;
        variable tmp_score0     : integer;
        variable tmp_score1     : integer;
        variable tmp_score2     : integer;
        variable tmp_score3     : integer;
        variable leading_score  : integer;
        variable leading_score01 : integer;
        variable leading_score23 : integer;
        variable tmp_winner     : integer;
    begin
        if (clk'event and clk = '1') then
    		if reset = '1' then
    		    arb_finished_reg <= '0';
    		    nxt_winner_reg <= (others => '0');
    		    cnt <= (others => '0');
    		    arbitration_timestamp <= (others => '0');
    		    prev_req_reg <= (others => '0');
    		    arb_req_reg <= (others => '0');
    		    vft0_reg <= (others => '0');
    		    vft1_reg <= (others => '0');
    		    vft2_reg <= (others => '0');
    		    vft3_reg <= (others => '0');
    		    vst0_reg <= (others => '0');
                vst1_reg <= (others => '0');
                vst2_reg <= (others => '0');
                vst3_reg <= (others => '0');
                virtual_time_reg <= (others => '0');
    		else
    		    arb_finished_reg <= '0';
                nxt_winner_reg <= nxt_winner_reg;
                cnt <= cnt;
                
                if ARBITRATION = 1 then  -- Round Robin
                    if run_arbitration_sig = '1' then
                        for i in 1 to NR_PORTS loop
                            tmp_port := (to_integer(unsigned(cur_winner_reg))+i) mod NR_PORTS;
                            if in_req_ports(tmp_port) = '1' then
                                arb_finished_reg <= '1';
                                nxt_winner_reg <= std_logic_vector(to_unsigned(tmp_port,LD_NR_PORTS));
                            end if;
                            exit when in_req_ports(tmp_port) = '1';
                        end loop;
                    end if;
            
                elsif ARBITRATION = 2 then -- Priority based
                    if run_arbitration_sig = '1' then
                        leading_port := 0;
                        leading_prio := 0;
                        for i in 1 to NR_PORTS loop
                            tmp_port := (to_integer(unsigned(cur_winner_reg))+i) mod NR_PORTS;
                            tmp_prio := to_integer(unsigned(in_prio((tmp_port+1)*VLAN_PRIO_WIDTH-1 downto tmp_port*VLAN_PRIO_WIDTH))) + 1;
                            if in_req_ports(tmp_port) = '1' then
                                if tmp_prio > leading_prio then
                                    leading_prio := tmp_prio;
                                    leading_port := tmp_port;
                                end if;
                            end if;
                        end loop;
                        nxt_winner_reg <= std_logic_vector(to_unsigned(leading_port,LD_NR_PORTS));
                        arb_finished_reg <= '1';
                    end if;
        
--                elsif ARBITRATION = 3 then -- Latency based -- 4 clock cycles
--                    if run_arbitration_sig = '1' then
--                        if cnt = 0 then
--                            leading_port := 0;
--                            leading_latency := (others => '0');
--                        end if;
--                        tmp_port := (to_integer(unsigned(cur_winner_reg))+to_integer(unsigned(cnt)) + 1) mod NR_PORTS;
--                        tmp_timestamp := in_timestamp((tmp_port+1)*TIMESTAMP_WIDTH-1 downto tmp_port*TIMESTAMP_WIDTH);
--                        tmp_latency := timestamp_cnt - tmp_timestamp;
--                        if in_req_ports(tmp_port) = '1' then
--                            if tmp_latency > leading_latency then
--                                leading_latency := tmp_latency;
--                                leading_port := tmp_port;
--                            end if;
--                        end if;
--                        cnt <= cnt + 1;
--                        if cnt = 3 then
--                            nxt_winner_reg <= std_logic_vector(to_unsigned(leading_port,LD_NR_PORTS));
--                            arb_finished_reg <= '1';
--                            cnt <= (others => '0');
--                        end if;
--                    end if;

                    elsif ARBITRATION = 3 then -- Latency based -- 1 clock cycle
                        if run_arbitration_sig = '1' then
                            -- determine latency of each port
                            leading_port := 0;
                            leading_latency := (others => '0');
                            tmp_timestamp0 := in_timestamp(TIMESTAMP_WIDTH-1 downto 0);
                            tmp_latency0 := timestamp_cnt - tmp_timestamp0;
                            tmp_timestamp1 := in_timestamp(2*TIMESTAMP_WIDTH-1 downto TIMESTAMP_WIDTH);
                            tmp_latency1 := timestamp_cnt - tmp_timestamp1;
                            tmp_timestamp2 := in_timestamp(3*TIMESTAMP_WIDTH-1 downto 2*TIMESTAMP_WIDTH);
                            tmp_latency2 := timestamp_cnt - tmp_timestamp2;
                            tmp_timestamp3 := in_timestamp(4*TIMESTAMP_WIDTH-1 downto 3*TIMESTAMP_WIDTH);
                            tmp_latency3 := timestamp_cnt - tmp_timestamp3;
                            -- semifinal
                            leading_latency01 := tmp_latency1;
                            leading_port01 := 1;
                            if in_req_ports(1) = '0' or (tmp_latency0 >= tmp_latency1 and in_req_ports(0) = '1') then
                                leading_latency01 := tmp_latency0;
                                leading_port01 := 0;
                            end if;
                            leading_latency23 := tmp_latency3;
                            leading_port23 := 3;
                            if in_req_ports(3) = '0' or (tmp_latency2 >= tmp_latency3 and in_req_ports(2) = '1') then
                                leading_latency23 := tmp_latency2;
                                leading_port23 := 2;
                            end if;
                            --final
                            leading_latency := leading_latency23;
                            leading_port := leading_port23;
                            if in_req_ports(leading_port23) = '0' or (leading_latency01 >= leading_latency23 and in_req_ports(leading_port01) = '1') then
                                leading_latency := leading_latency01;
                                leading_port := leading_port01;
                            end if; 
                            nxt_winner_reg <= std_logic_vector(to_unsigned(leading_port,LD_NR_PORTS));
                            arb_finished_reg <= '1';
                        end if;
                                           
--                elsif ARBITRATION = 4 then -- Weighted prio/latency based -- 4 clock cycles
--                    if run_arbitration_sig = '1' then
--                        -- depending on the weigths this is round robin, priority based, latency based or a mixture
--                        if cnt = 0 then
--                            leading_port := 0;
--                            leading_score := 0;
--                        end if;
--                        tmp_port := (to_integer(unsigned(cur_winner_reg))+to_integer(unsigned(cnt)) + 1) mod NR_PORTS;
--                        tmp_timestamp := in_timestamp((tmp_port+1)*TIMESTAMP_WIDTH-1 downto tmp_port*TIMESTAMP_WIDTH);
--                        tmp_latency := timestamp_cnt - tmp_timestamp;
--                        tmp_prio := to_integer(unsigned(in_prio((tmp_port+1)*VLAN_PRIO_WIDTH-1 downto tmp_port*VLAN_PRIO_WIDTH)));
--                        tmp_score := port_weight(tmp_port) * to_integer(unsigned(tmp_latency)) +  prio_weight(tmp_prio);
--                        if in_req_ports(tmp_port) = '1' then
--                            if tmp_score > leading_score then
--                                leading_score := tmp_score;
--                                leading_port := tmp_port;
--                            end if;
--                        end if;
--                        cnt <= cnt + 1;
--                        if cnt = 3 then
--                            nxt_winner_reg <= std_logic_vector(to_unsigned(leading_port,LD_NR_PORTS));
--                            arb_finished_reg <= '1';
--                            cnt <= (others => '0');
--                        end if;
--                    end if;

                    elsif ARBITRATION = 4 then -- Latency based -- one clock cycle
                        if run_arbitration_sig = '1' then
                            -- determine latency of each port
                            tmp_timestamp0 := in_timestamp(TIMESTAMP_WIDTH-1 downto 0);
                            tmp_latency0 := timestamp_cnt - tmp_timestamp0;
                            tmp_prio0 := to_integer(unsigned(in_prio(VLAN_PRIO_WIDTH-1 downto 0)));
                            tmp_score0 := to_integer(unsigned(tmp_latency0)) +  prio_weight(tmp_prio0);
                            score0_reg <= to_integer(unsigned(tmp_latency0)) +  prio_weight(tmp_prio0);
                            tmp_timestamp1 := in_timestamp(2*TIMESTAMP_WIDTH-1 downto TIMESTAMP_WIDTH);
                            tmp_latency1 := timestamp_cnt - tmp_timestamp1;
                            tmp_prio1 := to_integer(unsigned(in_prio(2*VLAN_PRIO_WIDTH-1 downto VLAN_PRIO_WIDTH)));
                            tmp_score1 := to_integer(unsigned(tmp_latency1)) +  prio_weight(tmp_prio1);
                            score1_reg <= to_integer(unsigned(tmp_latency1)) +  prio_weight(tmp_prio1);
                            tmp_timestamp2 := in_timestamp(3*TIMESTAMP_WIDTH-1 downto 2*TIMESTAMP_WIDTH);
                            tmp_latency2 := timestamp_cnt - tmp_timestamp2;
                            tmp_prio2 := to_integer(unsigned(in_prio(3*VLAN_PRIO_WIDTH-1 downto 2*VLAN_PRIO_WIDTH)));
                            tmp_score2 := to_integer(unsigned(tmp_latency2)) +  prio_weight(tmp_prio2);
                            score2_reg <= to_integer(unsigned(tmp_latency2)) +  prio_weight(tmp_prio2);
                            tmp_timestamp3 := in_timestamp(4*TIMESTAMP_WIDTH-1 downto 3*TIMESTAMP_WIDTH);
                            tmp_latency3 := timestamp_cnt - tmp_timestamp3;
                            tmp_prio3 := to_integer(unsigned(in_prio(4*VLAN_PRIO_WIDTH-1 downto 3*VLAN_PRIO_WIDTH)));
                            tmp_score3 := to_integer(unsigned(tmp_latency3)) +  prio_weight(tmp_prio3);
                            score3_reg <= to_integer(unsigned(tmp_latency3)) +  prio_weight(tmp_prio3);
                            -- semifinal
                            leading_score01 := tmp_score1;
                            leading_port01 := 1;
                            if in_req_ports(1) = '0' or (tmp_score0 >= tmp_score1 and in_req_ports(0) = '1') then
                                leading_score01 := tmp_score0;
                                leading_port01 := 0;
                            end if;
                            leading_score23 := tmp_score3;
                            leading_port23 := 3;
                            if in_req_ports(3) = '0' or (tmp_score2 >= tmp_score3 and in_req_ports(2) = '1') then
                                leading_score23 := tmp_score2;
                                leading_port23 := 2;
                            end if;
                            -- final
                            leading_score := leading_score23;
                            leading_port := leading_port23;
                            if in_req_ports(leading_port23) = '0' or (leading_score01 >= leading_score23 and in_req_ports(leading_port01) = '1') then
                                leading_score := leading_score01;
                                leading_port := leading_port01;
                            end if; 
                            nxt_winner_reg <= std_logic_vector(to_unsigned(leading_port,LD_NR_PORTS));
                            arb_finished_reg <= '1';
                        end if;
                  
                elsif ARBITRATION = 5 then -- Fair Queuing
                    prev_req_reg <= in_req_ports;
                    arbitration_timestamp <= arbitration_timestamp;
                    if arb_finished_sig = '1' then
                        arbitration_timestamp <= timestamp_cnt;
                    end if;
                    -- port 0
                    vft0_reg <= vft0_reg;
                    vst0_reg <= vst0_reg;
                    if in_req_ports(0) = '0' then -- no request for transmission
                    elsif in_req_ports(0) = '1' and prev_req_reg(0) = '0' then -- new request, not requested in previous arbtiration round
                        if cur_winner_reg = 0 then -- message queued behind previous winner message
                            vft0_reg <= vft0_reg + in_length(FRAME_LENGTH_WIDTH-1 downto 0);
                            vst0_reg <= vft0_reg;
                        else -- new arriving message
                            if arb_req_reg /= 0 then -- more ports requesting access
                                vft0_reg <= timestamp_cnt - arbitration_timestamp + in_length(FRAME_LENGTH_WIDTH-1 downto 0);
                                vst0_reg <= timestamp_cnt - arbitration_timestamp;
                            else -- port 0 is the only port requesting access
                                vft0_reg(FRAME_LENGTH_WIDTH-1 downto 0) <= in_length(FRAME_LENGTH_WIDTH-1 downto 0);
                                vft0_reg(TIMESTAMP_WIDTH-1 downto FRAME_LENGTH_WIDTH) <= (others => '0');
                                vst0_reg <= (others => '0');
                            end if;
                        end if;
                    elsif arb_finished_sig = '1' then -- normalisation of virtual finish and virtual start time, so that vst of winner is 0 -> preventing overflows
                        if nxt_winner_reg = 0 then
                            vft0_reg <= vft0_reg - vst0_reg;
                            vst0_reg <= vst0_reg - vst0_reg;
                        elsif nxt_winner_reg = 1 then
                            vft0_reg <= vft0_reg - vst1_reg;
                            vst0_reg <= vst0_reg - vst1_reg;
                        elsif nxt_winner_reg = 2 then
                            vft0_reg <= vft0_reg - vst2_reg;
                            vst0_reg <= vst0_reg - vst2_reg;
                        elsif nxt_winner_reg = 3 then
                            vft0_reg <= vft0_reg - vst3_reg;
                            vst0_reg <= vst0_reg - vst3_reg;
                        end if;
                    end if;
                    -- port 1
                    vft1_reg <= vft1_reg;
                    vst1_reg <= vst1_reg;
                    if in_req_ports(1) = '0' then
                    elsif in_req_ports(1) = '1' and prev_req_reg(1) = '0' then
                        if cur_winner_reg = 1 then -- message queued behind previous winner message
                            vft1_reg <= vft1_reg + in_length(2*FRAME_LENGTH_WIDTH-1 downto FRAME_LENGTH_WIDTH);
                            vst1_reg <= vft1_reg;
                        else -- new arriving message
                            if arb_req_reg /= 0 then
                                vft1_reg <= timestamp_cnt - arbitration_timestamp + in_length(2*FRAME_LENGTH_WIDTH-1 downto FRAME_LENGTH_WIDTH);
                                vst1_reg <= timestamp_cnt - arbitration_timestamp;
                            else
                                vft1_reg(FRAME_LENGTH_WIDTH-1 downto 0) <= in_length(2*FRAME_LENGTH_WIDTH-1 downto FRAME_LENGTH_WIDTH);
                                vft1_reg(TIMESTAMP_WIDTH-1 downto FRAME_LENGTH_WIDTH) <= (others => '0');
                                vst1_reg <= (others => '0');
                            end if;
                        end if;
                    elsif arb_finished_sig = '1' then
                        if nxt_winner_reg = 0 then
                            vft1_reg <= vft1_reg - vst0_reg;
                            vst1_reg <= vst1_reg - vst0_reg;
                        elsif nxt_winner_reg = 1 then
                            vft1_reg <= vft1_reg - vst1_reg;
                            vst1_reg <= vst1_reg - vst1_reg;
                        elsif nxt_winner_reg = 2 then
                            vft1_reg <= vft1_reg - vst2_reg;
                            vst1_reg <= vst1_reg - vst2_reg;
                        elsif nxt_winner_reg = 3 then
                            vft1_reg <= vft1_reg - vst3_reg;
                            vst1_reg <= vst1_reg - vst3_reg;
                        end if;
                    end if;
                    -- port 2
                    vft2_reg <= vft2_reg;
                    vst2_reg <= vst2_reg;
                    if in_req_ports(2) = '0' then
                    elsif in_req_ports(2) = '1' and prev_req_reg(2) = '0' then
                        if cur_winner_reg = 2 then -- message queued behind previous winner message
                            vft2_reg <= vft2_reg + in_length(3*FRAME_LENGTH_WIDTH-1 downto 2*FRAME_LENGTH_WIDTH);
                            vst2_reg <= vft2_reg;
                        else -- new arriving message
                            if arb_req_reg /= 0 then
                                vft2_reg <= timestamp_cnt - arbitration_timestamp + in_length(3*FRAME_LENGTH_WIDTH-1 downto 2*FRAME_LENGTH_WIDTH);
                                vst2_reg <= timestamp_cnt - arbitration_timestamp;
                            else
                                vft2_reg(FRAME_LENGTH_WIDTH-1 downto 0) <= in_length(3*FRAME_LENGTH_WIDTH-1 downto 2*FRAME_LENGTH_WIDTH);
                                vft2_reg(TIMESTAMP_WIDTH-1 downto FRAME_LENGTH_WIDTH) <= (others => '0');
                                vst2_reg <= (others => '0');
                            end if;
                        end if;
                    elsif arb_finished_sig = '1' then
                        if nxt_winner_reg = 0 then
                            vft2_reg <= vft2_reg - vst0_reg;
                            vst2_reg <= vst2_reg - vst0_reg;
                        elsif nxt_winner_reg = 1 then
                            vft2_reg <= vft2_reg - vst1_reg;
                            vst2_reg <= vst2_reg - vst1_reg;
                        elsif nxt_winner_reg = 2 then
                            vft2_reg <= vft2_reg - vst2_reg;
                            vst2_reg <= vst2_reg - vst2_reg;
                        elsif nxt_winner_reg = 3 then
                            vft2_reg <= vft2_reg - vst3_reg;
                            vst2_reg <= vst2_reg - vst3_reg;
                        end if;
                    end if;
                    -- port 3
                    vft3_reg <= vft3_reg;
                    vst3_reg <= vst3_reg;
                    if in_req_ports(3) = '0' then
                    elsif in_req_ports(3) = '1' and prev_req_reg(3) = '0' then
                        if cur_winner_reg = 3 then -- message queued behind previous winner message
                            vft3_reg <= vft3_reg + in_length(4*FRAME_LENGTH_WIDTH-1 downto 3*FRAME_LENGTH_WIDTH);
                            vst3_reg <= vft3_reg;
                        else -- new arriving message
                            if arb_req_reg /= 0 then
                                vft3_reg <= timestamp_cnt - arbitration_timestamp + in_length(4*FRAME_LENGTH_WIDTH-1 downto 3*FRAME_LENGTH_WIDTH);
                                vst3_reg <= timestamp_cnt - arbitration_timestamp;
                            else
                                vft3_reg(FRAME_LENGTH_WIDTH-1 downto 0) <= in_length(4*FRAME_LENGTH_WIDTH-1 downto 3*FRAME_LENGTH_WIDTH);
                                vft3_reg(TIMESTAMP_WIDTH-1 downto FRAME_LENGTH_WIDTH) <= (others => '0');
                                vst3_reg <= (others => '0');
                            end if;
                        end if;
                    elsif arb_finished_sig = '1' then
                        if nxt_winner_reg = 0 then
                            vft3_reg <= vft3_reg - vst0_reg;
                            vst3_reg <= vst3_reg - vst0_reg;
                        elsif nxt_winner_reg = 1 then
                            vft3_reg <= vft3_reg - vst1_reg;
                            vst3_reg <= vst3_reg - vst1_reg;
                        elsif nxt_winner_reg = 2 then
                            vft3_reg <= vft3_reg - vst2_reg;
                            vst3_reg <= vst3_reg - vst2_reg;
                        elsif nxt_winner_reg = 3 then
                            vft3_reg <= vft3_reg - vst3_reg;
                            vst3_reg <= vst3_reg - vst3_reg;
                        end if;
                    end if;
                    
                    if run_arbitration_sig = '1' then
                        --cnt <= cnt + 1;
                        --if cnt = 0 then
                            leading_port := 0;
                            leading_score := 0;
                        --end if;
                        --if cnt = 1 then
                            if in_req_ports(0) = '1' then
                                ----if leading_score = 0 or to_integer(unsigned(vft0_reg)) < leading_score then
                                    ----leading_port := 0;
                                    leading_score := to_integer(unsigned(vft0_reg));
                                ----end if;
                            end if;
                            if in_req_ports(1) = '1' then
                                if leading_score = 0 or to_integer(unsigned(vft1_reg)) < leading_score then
                                    leading_port := 1;
                                    leading_score := to_integer(unsigned(vft1_reg));
                                end if;
                            end if;                            
                            if in_req_ports(2) = '1' then
                                if leading_score = 0 or to_integer(unsigned(vft2_reg)) < leading_score then
                                    leading_port := 2;
                                    leading_score := to_integer(unsigned(vft2_reg));
                                end if;
                            end if;
                            if in_req_ports(3) = '1' then
                                if leading_score = 0 or to_integer(unsigned(vft3_reg)) < leading_score then
                                    leading_port := 3;
                                    leading_score := to_integer(unsigned(vft3_reg));
                                end if;
                            end if;                            
                            nxt_winner_reg <= std_logic_vector(to_unsigned(leading_port,LD_NR_PORTS));
                            arb_finished_reg <= '1';
                            arb_req_reg <= in_req_ports;
                            --cnt <= (others => '0');
                        --end if;
                    end if;
                    
                    if run_arbitration_sig = '1' then
                        if cur_winner_reg = 0 then
                            virtual_time_reg <= vft0_reg;
                        elsif cur_winner_reg = 1 then
                            virtual_time_reg <= vft1_reg;
                        elsif cur_winner_reg = 2 then
                            virtual_time_reg <= vft2_reg;
                        elsif cur_winner_reg = 3 then
                            virtual_time_reg <= vft3_reg;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    update_pre_port_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                cur_winner_reg <= (others => '0');
            else
                cur_winner_reg <= cur_winner_reg;
                if arb_finished_sig = '1' then
                    cur_winner_reg <= nxt_winner_reg;
                end if;
            end if;
        end if;
    end process;

    out_winner_port <= nxt_winner_reg;

end rtl;
