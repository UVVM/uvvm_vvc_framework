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
--========================================================================================================================
-- This VVC was generated with Bitvis VVC Generator
--========================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--========================================================================================================================
--========================================================================================================================
package wishbone_bfm_pkg is

  --========================================================================================================================
  -- Types and constants for WISHBONE BFM
  --========================================================================================================================
  constant C_BFM_SCOPE : string := "WISHBONE BFM";

  type t_wishbone_if is record
    -- Common for slave and master interfaces
    dat_o : std_logic_vector;           -- to dut
    dat_i : std_logic_vector;           -- from dut

    -- Master interface
    adr_o : std_logic_vector;           -- to dut, address
    cyc_o : std_logic;                  -- to dut, valid bus cycle
    stb_o : std_logic;                  -- to dut, chip select
    we_o  : std_logic;                  -- to dut, write enable
    ack_i : std_logic;                  -- from dut
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_wishbone_bfm_config is record
    max_wait_cycles          : integer;
    max_wait_cycles_severity : t_alert_level;
    clock_period             : time;    -- Needed in the VVC
    clock_period_margin      : time;    -- Input clock period margin to specified clock_period
    clock_margin_severity    : t_alert_level; -- The above margin will have this severity
    setup_time               : time;    -- Setup time for generated signals, set to clock_period/4
    hold_time                : time;    -- Hold time for generated signals, set to clock_period/4
    match_strictness         : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    id_for_bfm               : t_msg_id;
    id_for_bfm_wait          : t_msg_id;
    id_for_bfm_poll          : t_msg_id;
  end record;

  -- Define the default value for the BFM config
  constant C_WISHBONE_BFM_CONFIG_DEFAULT : t_wishbone_bfm_config := (
    max_wait_cycles          => 10,
    max_wait_cycles_severity => failure,
    clock_period             => -1 ns,
    clock_period_margin      => 0 ns,
    clock_margin_severity    => TB_ERROR,
    setup_time               => -1 ns,
    hold_time                => -1 ns,
    match_strictness         => MATCH_EXACT,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL
  );

  --========================================================================================================================
  -- BFM procedures
  --========================================================================================================================
  -- This function returns an Wishbone interface with initialized signals.
  -- All BFM output signals are initialized to 0
  -- All BFM input signals are initialized to Z
  function init_wishbone_if_signals(
    addr_width : natural;
    data_width : natural
  ) return t_wishbone_if;

  procedure wishbone_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   wishbone_if  : inout t_wishbone_if;
    constant scope        : in string                := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel        := shared_msg_id_panel;
    constant config       : in t_wishbone_bfm_config := C_WISHBONE_BFM_CONFIG_DEFAULT
  );

  procedure wishbone_read(
    constant addr_value    : in unsigned;
    variable data_value    : out std_logic_vector;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   wishbone_if   : inout t_wishbone_if;
    constant scope         : in string                := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel        := shared_msg_id_panel;
    constant config        : in t_wishbone_bfm_config := C_WISHBONE_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  procedure wishbone_check(
    constant addr_value   : in unsigned;
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   wishbone_if  : inout t_wishbone_if;
    constant alert_level  : in t_alert_level         := error;
    constant scope        : in string                := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel        := shared_msg_id_panel;
    constant config       : in t_wishbone_bfm_config := C_WISHBONE_BFM_CONFIG_DEFAULT
  );

end package wishbone_bfm_pkg;

--========================================================================================================================
--========================================================================================================================

package body wishbone_bfm_pkg is

  function init_wishbone_if_signals(
    addr_width : natural;
    data_width : natural
  ) return t_wishbone_if is
    variable result : t_wishbone_if(dat_o(data_width - 1 downto 0),
                                    dat_i(data_width - 1 downto 0),
                                    adr_o(addr_width - 1 downto 0)
                                   );
  begin
    -- BFM to DUT signals
    result.dat_o := (result.dat_o'range => '0');
    result.adr_o := (result.adr_o'range => '0');
    result.cyc_o := '0';
    result.stb_o := '0';
    result.we_o  := '0';

    -- DUT to BFM signals
    result.dat_i := (result.dat_i'range => 'Z');
    result.ack_i := 'Z';
    return result;
  end function;

  procedure wishbone_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   wishbone_if  : inout t_wishbone_if;
    constant scope        : in string                := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel        := shared_msg_id_panel;
    constant config       : in t_wishbone_bfm_config := C_WISHBONE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name         : string                                                  := "wishbone_write";
    constant proc_call         : string                                                  := "wishbone_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(wishbone_if.adr_o'length - 1 downto 0) := normalize_and_check(std_logic_vector(addr_value), wishbone_if.adr_o, ALLOW_NARROWER, "address", "wishbone_if.adr_o", msg);
    variable v_normalized_data : std_logic_vector(wishbone_if.dat_o'length - 1 downto 0) := normalize_and_check(data_value, wishbone_if.dat_o, ALLOW_NARROWER, "data", "wishbone_if.dat_o", msg);

    variable timeout             : boolean := false;
    variable v_last_falling_edge : time    := -1 ns; -- time stamp for clk period checking

  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_name);

    -- check if enough room for setup_time in low period
    if (clk = '1') and (config.setup_time > (config.clock_period / 2 - clk'last_event)) then
      await_value(clk, '0', 0 ns, config.clock_period / 2, TB_FAILURE, proc_name & ": timeout waiting for clk low period for setup_time.");
    end if;
    -- Wait setup_time specified in config record  --wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    wait_until_given_time_after_rising_edge(clk, config.setup_time);

    wishbone_if.dat_o <= v_normalized_data;
    wishbone_if.adr_o <= v_normalized_addr;
    wishbone_if.cyc_o <= '1';           -- Valid bus cycle activated
    wishbone_if.stb_o <= '1';           -- Chip-select
    wishbone_if.we_o  <= '1';           -- Write enable

    wait until falling_edge(clk);       -- wait for DUT update of signal
    -- check if clk period since last rising edge is within specifications and take a new time stamp
    if v_last_falling_edge > -1 ns then
      check_value_in_range(now - v_last_falling_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "checking clk period is within requirement.");
    end if;
    v_last_falling_edge := now;         -- time stamp for clk period checking

    for cycle in 1 to config.max_wait_cycles loop
      if wishbone_if.ack_i = '0' then
        wait until falling_edge(clk);
        -- check if clk period since last rising edge is within specifications and take a new time stamp
        if v_last_falling_edge > -1 ns then
          check_value_in_range(now - v_last_falling_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "checking clk period is within requirement.");
        end if;
        v_last_falling_edge := now;     -- time stamp for clk period checking
      else
        exit;
      end if;
      if cycle = config.max_wait_cycles then
        timeout := true;
      end if;
    end loop;

    -- did we timeout?
    if timeout then
      alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for ack_i" & add_msg_delimiter(msg), scope);
    else
      wait until rising_edge(clk);

      -- Wait hold time specified in config record  --wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
      wait_until_given_time_after_rising_edge(clk, config.hold_time);
    end if;

    wishbone_if <= init_wishbone_if_signals(wishbone_if.adr_o'length, wishbone_if.dat_o'length);
    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure wishbone_write;

  procedure wishbone_read(
    constant addr_value    : in unsigned;
    variable data_value    : out std_logic_vector;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   wishbone_if   : inout t_wishbone_if;
    constant scope         : in string                := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel        := shared_msg_id_panel;
    constant config        : in t_wishbone_bfm_config := C_WISHBONE_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    -- local_proc_name/call used if called from sequencer or VVC
    constant local_proc_name : string := "wishbone_read";
    constant local_proc_call : string := local_proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(wishbone_if.adr_o'length - 1 downto 0) := normalize_and_check(std_logic_vector(addr_value), wishbone_if.adr_o, ALLOW_NARROWER, "addr", "wishbone_if.adr_o", msg);
    variable v_normalized_data : std_logic_vector(wishbone_if.dat_i'length - 1 downto 0) := normalize_and_check(data_value, wishbone_if.dat_i, ALLOW_NARROWER, "data", "wishbone_if.dat_i", msg);

    -- Helper variables
    variable timeout             : boolean := false;
    variable v_last_falling_edge : time    := -1 ns; -- time stamp for clk period checking
    variable v_last_rising_edge  : time    := -1 ns; -- time stamp for clk period checking
    variable v_proc_call         : line;
  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_name);
    check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_name);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, local_proc_name);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, local_proc_name);

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'wishbone_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing wishbone_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    -- check if enough room for setup_time in low period
    if (clk = '1') and (config.setup_time > (config.clock_period / 2 - clk'last_event)) then
      await_value(clk, '0', 0 ns, config.clock_period / 2, TB_FAILURE, local_proc_name & ": timeout waiting for clk low period for setup_time.");
    end if;
    -- Wait setup_time specified in config record -- wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    wait_until_given_time_after_rising_edge(clk, config.setup_time);

    wishbone_if.adr_o <= v_normalized_addr;
    wishbone_if.cyc_o <= '1';           -- Valid bus cycle activated
    wishbone_if.stb_o <= '1';           -- Chip-select
    wishbone_if.we_o  <= '0';           -- Read

    wait until falling_edge(clk);       -- wait for DUT update of signal
    -- check if clk period since last rising edge is within specifications and take a new time stamp
    if v_last_falling_edge > -1 ns then
      check_value_in_range(now - v_last_falling_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "checking clk period is within requirement.");
    end if;
    v_last_falling_edge := now;         -- time stamp for clk period checking

    for cycle in 1 to config.max_wait_cycles loop
      if wishbone_if.ack_i = '0' then
        wait until falling_edge(clk);
        -- check if clk period since last rising edge is within specifications and take a new time stamp
        if v_last_falling_edge > -1 ns then
          check_value_in_range(now - v_last_falling_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "checking clk period is within requirement.");
        end if;
        v_last_falling_edge := now;     -- time stamp for clk period checking
      else
        exit;
      end if;
      if cycle = config.max_wait_cycles then
        timeout := true;
      end if;
    end loop;

    -- did we timeout?
    if timeout then
      alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout waiting for ack_i " & add_msg_delimiter(msg), scope);
    else
      wait until rising_edge(clk);
      -- check if clk period since last rising edge is within specifications and take a new time stamp
      if v_last_rising_edge > -1 ns then
        check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "checking clk period is within requirement.");
      end if;
      v_last_rising_edge := now;        -- time stamp for clk period checking

      -- Wait hold time specified in config record --wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
      wait_until_given_time_after_rising_edge(clk, config.hold_time);
    end if;

    v_normalized_data := wishbone_if.dat_i;
    data_value        := v_normalized_data(data_value'length - 1 downto 0);

    wishbone_if <= init_wishbone_if_signals(wishbone_if.adr_o'length, wishbone_if.dat_i'length);

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. wishbone_check)
    end if;

    deallocate(v_proc_call);
  end procedure wishbone_read;

  procedure wishbone_check(
    constant addr_value   : in unsigned;
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   wishbone_if  : inout t_wishbone_if;
    constant alert_level  : in t_alert_level         := error;
    constant scope        : in string                := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel        := shared_msg_id_panel;
    constant config       : in t_wishbone_bfm_config := C_WISHBONE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name : string := "wishbone_check";
    constant proc_call : string := "wishbone_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(wishbone_if.dat_i'length - 1 downto 0) := normalize_and_check(data_exp, wishbone_if.dat_i, ALLOW_NARROWER, "data", "wishbone_if.dat_i", msg);

    -- Helper variables
    variable v_data_value  : std_logic_vector(wishbone_if.dat_i'length - 1 downto 0) := (others => '0');
    variable v_check_ok    : boolean                                                 := true;
    variable v_alert_radix : t_radix;
  begin
    wishbone_read(addr_value, v_data_value, msg, clk, wishbone_if, scope, msg_id_panel, config, proc_call);

    for i in v_normalized_data'range loop
      -- Allow don't care in expected value and use match strictness from config for comparison
      if v_normalized_data(i) = '-' or check_value(v_data_value(i), v_normalized_data(i), config.match_strictness, NO_ALERT, msg) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_data_value, v_normalized_data, MATCH_STD, NO_ALERT, msg) else HEX;
      alert(alert_level, proc_call & "=> Failed. Was " & to_string(v_data_value, v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data, v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure wishbone_check;

end package body wishbone_bfm_pkg;

