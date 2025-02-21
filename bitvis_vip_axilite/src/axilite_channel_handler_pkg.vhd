--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : Package for accessing each AXI-Lite channel separately. Used by the VVC
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.axilite_bfm_pkg.all;

--=================================================================================================
package axilite_channel_handler_pkg is

  --===============================================================================================
  -- Types and constants
  --===============================================================================================
  constant C_SCOPE : string := "AXILITE_CHANNEL_HANDLER";

  --===============================================================================================
  -- Procedures
  --===============================================================================================

  ------------------------------------------
  -- write_address_channel_write
  ------------------------------------------
  -- This procedure writes adress on the write address channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure write_address_channel_write(
    constant awaddr_value : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   awaddr       : inout std_logic_vector;
    signal   awvalid      : inout std_logic;
    signal   awprot       : inout std_logic_vector(2 downto 0); -- [0: '0' - unpriviliged access, '1' - priviliged access; 1: '0' - secure access, '1' - non-secure access, 2: '0' - Data access, '1' - Instruction accesss]
    signal   awready      : in std_logic;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- write_data_channel_write
  ------------------------------------------
  -- This procedure writes data on the write data channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure write_data_channel_write(
    constant wdata_value  : in std_logic_vector;
    constant wstrb_value  : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   wdata        : inout std_logic_vector;
    signal   wstrb        : inout std_logic_vector;
    signal   wvalid       : inout std_logic;
    signal   wready       : in std_logic;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- write_response_channel_check
  ------------------------------------------
  -- This procedure checks the write response on the write response channel
  -- - If the received response was inconsistent with config.expected_response, 
  --   an alert with severity config.expected_response_severity is issued.
  -- - When completed, a log message with ID id_for_bfm is issued.
  procedure write_response_channel_check(
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   bready       : inout std_logic;
    signal   bresp        : in std_logic_vector(1 downto 0);
    signal   bvalid       : in std_logic;
    constant alert_level  : in t_alert_level        := error;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- read_address_channel_write
  ------------------------------------------
  -- This procedure writes adress on the read address channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure read_address_channel_write(
    constant araddr_value : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   araddr       : inout std_logic_vector;
    signal   arvalid      : inout std_logic;
    signal   arprot       : inout std_logic_vector(2 downto 0);
    signal   arready      : in std_logic;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- read_data_channel_receive
  ------------------------------------------
  -- This procedure receives read data on the read data channel,
  -- and returns the read data
  -- - If the received response was inconsistent with config.expected_response, 
  --   an alert with severity config.expected_response_severity is issued.
  procedure read_data_channel_receive(
    variable rdata_value   : out std_logic_vector;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   rready        : inout std_logic;
    signal   rdata         : in std_logic_vector;
    signal   rresp         : in std_logic_vector(1 downto 0);
    signal   rvalid        : in std_logic;
    constant scope         : in string               := C_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel       := shared_msg_id_panel;
    constant config        : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string               := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- read_data_channel_check
  ------------------------------------------
  -- This procedure receives and checks read data and 
  -- read response on the read data channel
  -- - If the received data is inconsistent with rdata_exp, 
  --   an alert with severity alert_level is issued.
  -- - If the received data is correct, a log message with ID id_for_bfm is issued.
  procedure read_data_channel_check(
    constant rdata_exp    : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   rready       : inout std_logic;
    signal   rdata        : in std_logic_vector;
    signal   rresp        : in std_logic_vector(1 downto 0);
    signal   rvalid       : in std_logic;
    constant alert_level  : in t_alert_level        := error;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  );

end package axilite_channel_handler_pkg;

package body axilite_channel_handler_pkg is

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  procedure write_address_channel_write(
    constant awaddr_value : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   awaddr       : inout std_logic_vector;
    signal   awvalid      : inout std_logic;
    signal   awprot       : inout std_logic_vector(2 downto 0); -- [0: '0' - unpriviliged access, '1' - priviliged access; 1: '0' - secure access, '1' - non-secure access, 2: '0' - Data access, '1' - Instruction accesss]
    signal   awready      : in std_logic;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call              : string                                       := "write_address_channel_write(" & to_string(awaddr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_awready        : boolean                                      := true;
    variable v_normalized_awaddr    : std_logic_vector(awaddr'length - 1 downto 0) := normalize_and_check(awaddr_value, awaddr, ALLOW_NARROWER, "AWADDR", "awaddr", msg);
    -- Helper variables
    variable v_time_of_rising_edge  : time                                         := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                         := -1 ns; -- time stamp for clk period checking
  begin
    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write data channel outputs
      if cycle = config.num_aw_pipe_stages then
        awaddr  <= v_normalized_awaddr;
        awprot  <= axprot_to_slv(config.protection_setting);
        awvalid <= '1';
      end if;
      wait until rising_edge(clk);
      -- Checking clock behavior
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write address channel access is done
      if awready = '1' and cycle >= config.num_aw_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        awvalid         <= '0';
        v_await_awready := false;
        exit;
      end if;
    end loop;
    check_value(not v_await_awready, config.max_wait_cycles_severity, ": Timeout waiting for AWREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure write_address_channel_write;

  procedure write_data_channel_write(
    constant wdata_value  : in std_logic_vector;
    constant wstrb_value  : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   wdata        : inout std_logic_vector;
    signal   wstrb        : inout std_logic_vector;
    signal   wvalid       : inout std_logic;
    signal   wready       : in std_logic;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call              : string                                      := "write_data_channel_write(" & to_string(wdata_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(wstrb_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_wready         : boolean                                     := true;
    variable v_normalized_wdata     : std_logic_vector(wdata'length - 1 downto 0) := normalize_and_check(wdata_value, wdata, ALLOW_NARROWER, "WDATA", "wdata", msg);
    variable v_normalized_wstrb     : std_logic_vector(wstrb'length - 1 downto 0) := normalize_and_check(wstrb_value, wstrb, ALLOW_EXACT_ONLY, "WSTRB", "wstrb", msg);
    -- Helper variables
    variable v_time_of_rising_edge  : time                                        := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                        := -1 ns; -- time stamp for clk period checking
  begin
    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write data channel outputs
      if cycle = config.num_w_pipe_stages then
        wdata  <= v_normalized_wdata;
        wstrb  <= v_normalized_wstrb;
        wvalid <= '1';
      end if;
      wait until rising_edge(clk);
      -- Checking clock behavior
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write data channel access is done
      if wready = '1' and cycle >= config.num_w_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        wvalid         <= '0';
        v_await_wready := false;
        exit;
      end if;
    end loop;
    check_value(not v_await_wready, config.max_wait_cycles_severity, ": Timeout waiting for WREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure write_data_channel_write;

  procedure write_response_channel_check(
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   bready       : inout std_logic;
    signal   bresp        : in std_logic_vector(1 downto 0);
    signal   bvalid       : in std_logic;
    constant alert_level  : in t_alert_level        := error;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name              : string  := "write_response_channel_check";
    constant proc_call              : string  := proc_name & "()";
    variable v_await_bvalid         : boolean := true;
    variable v_time_of_rising_edge  : time    := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time    := -1 ns; -- time stamp for clk period checking
    variable v_alert_radix          : t_radix;
  begin

    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write response channel ready signal
      if cycle = config.num_b_pipe_stages then
        bready <= '1';
      end if;
      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write response channel access is done
      if bvalid = '1' and cycle >= config.num_b_pipe_stages then
        -- Checking BRESP value
        check_value(bresp, xresp_to_slv(config.expected_response), config.expected_response_severity, ": BRESP detected", scope, BIN, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        bready         <= '0';
        v_await_bvalid := false;
      end if;
      if not v_await_bvalid then
        exit;
      end if;
    end loop;

    check_value(not v_await_bvalid, config.max_wait_cycles_severity, ": Timeout waiting for BVALID", scope, ID_NEVER, msg_id_panel, proc_call);

    log(config.id_for_bfm, proc_call & "=> OK. " & add_msg_delimiter(msg), scope, msg_id_panel);

  end procedure write_response_channel_check;

  procedure read_address_channel_write(
    constant araddr_value : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   araddr       : inout std_logic_vector;
    signal   arvalid      : inout std_logic;
    signal   arprot       : inout std_logic_vector(2 downto 0);
    signal   arready      : in std_logic;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call              : string                                       := "read_address_channel_write(" & to_string(araddr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_arready        : boolean                                      := true;
    variable v_normalized_araddr    : std_logic_vector(araddr'length - 1 downto 0) := normalize_and_check(araddr_value, araddr, ALLOW_NARROWER, "ARADDR", "araddr", msg);
    -- Helper variables
    variable v_time_of_rising_edge  : time                                         := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                         := -1 ns; -- time stamp for clk period checking
  begin
    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write data channel outputs
      if cycle = config.num_ar_pipe_stages then
        araddr  <= v_normalized_araddr;
        arprot  <= axprot_to_slv(config.protection_setting);
        arvalid <= '1';
      end if;
      wait until rising_edge(clk);
      -- Checking clock behavior
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write address channel access is done
      if arready = '1' and cycle >= config.num_ar_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        arvalid         <= '0';
        v_await_arready := false;
        exit;
      end if;
    end loop;
    check_value(not v_await_arready, config.max_wait_cycles_severity, ": Timeout waiting for ARREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure read_address_channel_write;

  procedure read_data_channel_receive(
    variable rdata_value   : out std_logic_vector;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   rready        : inout std_logic;
    signal   rdata         : in std_logic_vector;
    signal   rresp         : in std_logic_vector(1 downto 0);
    signal   rvalid        : in std_logic;
    constant scope         : in string               := C_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel       := shared_msg_id_panel;
    constant config        : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string               := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name        : string  := "read_data_channel_receive"; -- Local proc_name; used if called from sequncer or VVC
    constant local_proc_call        : string  := local_proc_name & "()"; -- Local proc_call; used if called from sequncer or VVC
    variable v_proc_call            : line;
    variable v_rdata_value          : std_logic_vector(rdata'length - 1 downto 0);
    variable v_await_rvalid         : boolean := true;
    variable v_time_of_rising_edge  : time    := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time    := -1 ns; -- time stamp for clk period checking
  begin

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'axilite_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing axilite_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the read data channel ready signal
      if cycle = config.num_r_pipe_stages then
        rready <= '1';
      end if;
      wait until rising_edge(clk);
      -- Checking clock behavior
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the read data channel access is done
      if rvalid = '1' and cycle >= config.num_r_pipe_stages then
        v_await_rvalid := false;
        -- Storing RDATA
        v_rdata_value  := rdata;
        -- Checking RRESP
        check_value(rresp, xresp_to_slv(config.expected_response), config.expected_response_severity, ": RRESP detected", scope, BIN, KEEP_LEADING_0, ID_NEVER, msg_id_panel, v_proc_call.all);
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        rready         <= '0';
      end if;
      if not v_await_rvalid then
        exit;
      end if;
    end loop;
    check_value(not v_await_rvalid, config.max_wait_cycles_severity, ": Timeout waiting for RVALID", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    -- Assigning output variable
    rdata_value := v_rdata_value;

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(v_rdata_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. read_data_channel_check)
    end if;
    deallocate(v_proc_call);
  end procedure read_data_channel_receive;

  procedure read_data_channel_check(
    constant rdata_exp    : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   rready       : inout std_logic;
    signal   rdata        : in std_logic_vector;
    signal   rresp        : in std_logic_vector(1 downto 0);
    signal   rvalid       : in std_logic;
    constant alert_level  : in t_alert_level        := error;
    constant scope        : in string               := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name         : string                                      := "read_data_channel_check";
    constant proc_call         : string                                      := proc_name & "(" & to_string(rdata_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_rdata_value     : std_logic_vector(rdata'length - 1 downto 0) := (others => '0');
    variable v_rdata_ok        : boolean                                     := true;
    variable v_alert_radix     : t_radix;
    -- Normalize to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(rdata'length - 1 downto 0) := normalize_and_check(rdata_exp, rdata, ALLOW_NARROWER, "RDATA", "RDATA", msg);
  begin
    -- Receiving response
    read_data_channel_receive(v_rdata_value, msg, clk, rready, rdata, rresp, rvalid, scope, msg_id_panel, config, proc_call);
    -- Checking RDATA
    for i in v_normalized_data'range loop
      -- Allow don't care in expected value and use match strictness from config for comparison
      if v_normalized_data(i) = '-' or check_value(v_rdata_value(i), v_normalized_data(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER, msg_id_panel) then
        v_rdata_ok := true;
      else
        v_rdata_ok := false;
        exit;
      end if;
    end loop;

    if not v_rdata_ok then
      -- Use binary representation when mismatch is due to weak signals
      if not v_rdata_ok then
        v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rdata_value, v_normalized_data, MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel) else HEX;
        alert(alert_level, proc_call & "=> Failed. Was " & to_string(v_rdata_value, v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data, v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
      end if;
    else
      log(config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_rdata_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

  end procedure read_data_channel_check;

end package body axilite_channel_handler_pkg;
