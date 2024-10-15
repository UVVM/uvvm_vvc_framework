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
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.ti_protected_types_pkg.all;

package ti_vvc_framework_support_pkg is

  --constant C_VVC_NAME_MAX_LENGTH : natural := 20;
  constant C_VVC_NAME_MAX_LENGTH : natural := C_MAX_VVC_NAME_LENGTH;

  ------------------------------------------------------------------------
  -- Common support types for UVVM
  ------------------------------------------------------------------------
  type t_immediate_or_queued is (NO_command_type, IMMEDIATE, QUEUED);

  type t_flag_record is record
    set       : std_logic;
    reset     : std_logic;
    is_active : std_logic;
  end record;

  type t_uvvm_state is (IDLE, PHASE_A, PHASE_B, INIT_COMPLETED);

  type t_lastness is (LAST, NOT_LAST);

  type t_broadcastable_cmd is (NO_CMD, ENABLE_LOG_MSG, DISABLE_LOG_MSG, FLUSH_COMMAND_QUEUE, INSERT_DELAY, AWAIT_COMPLETION, TERMINATE_CURRENT_COMMAND);

  constant C_BROADCAST_CMD_STRING_MAX_LENGTH : natural := 300;

  type t_vvc_broadcast_cmd_record is record
    operation   : t_broadcastable_cmd;
    msg_id      : t_msg_id;
    msg         : string(1 to C_BROADCAST_CMD_STRING_MAX_LENGTH);
    proc_call   : string(1 to C_BROADCAST_CMD_STRING_MAX_LENGTH);
    quietness   : t_quietness;
    delay       : time;
    timeout     : time;
    gen_integer : integer;
  end record;

  constant C_VVC_BROADCAST_CMD_DEFAULT : t_vvc_broadcast_cmd_record := (
    operation   => NO_CMD,
    msg_id      => NO_ID,
    msg         => (others => NUL),
    proc_call   => (others => NUL),
    quietness   => NON_QUIET,
    delay       => 0 ns,
    timeout     => 0 ns,
    gen_integer => -1
  );

  ------------------------------------------------------------------------
  -- Common signals for acknowledging a pending command
  ------------------------------------------------------------------------
  shared variable shared_vvc_broadcast_cmd : t_vvc_broadcast_cmd_record := C_VVC_BROADCAST_CMD_DEFAULT;
  signal VVC_BROADCAST                     : std_logic                  := 'L';

  ------------------------------------------------------------------------
  -- Common signals for triggering VVC activity in central VVC register
  ------------------------------------------------------------------------
  signal global_trigger_vvc_activity_register : std_logic := 'L';

  ------------------------------------------------------------------------
  -- Common signal for signalling between VVCs, used during await_any_completion()
  -- Default (when not active): Z
  -- Awaiting: 1:
  -- Completed: 0
  -- This signal is a vector to support multiple sequencers calling await_any_completion simultaneously:
  -- - When calling await_any_completion, each sequencer specifies which bit in this global signal the VVCs shall use.
  ------------------------------------------------------------------------
  signal global_awaiting_completion : std_logic_vector(C_MAX_NUM_SEQUENCERS - 1 downto 0); -- ACK on global triggers

  ------------------------------------------------------------------------
  -- Shared variables for UVVM framework
  ------------------------------------------------------------------------
  shared variable shared_cmd_idx    : integer      := 0;
  shared variable shared_uvvm_state : t_uvvm_state := IDLE;

  -------------------------------------------
  -- flag_handler
  -------------------------------------------
  -- Flag handler is a general flag/semaphore handling mechanism between two separate processes/threads
  -- The idea is to allow one process to set a flag and another to reset it. The flag may then be used by both - or others
  -- May be used for a message from process 1 to process 2 with acknowledge; - like do-something & done, or valid & ack
  procedure flag_handler(
    signal flag : inout t_flag_record
  );

  -------------------------------------------
  -- set_flag
  -------------------------------------------
  -- Sets reset and is_active to 'Z' and pulses set_flag
  procedure set_flag(
    signal flag : inout t_flag_record
  );

  -------------------------------------------
  -- reset_flag
  -------------------------------------------
  -- Sets set and is_active to 'Z' and pulses reset_flag
  procedure reset_flag(
    signal flag : inout t_flag_record
  );

  -------------------------------------------
  -- await_uvvm_initialization
  -------------------------------------------
  -- Waits until uvvm has been initialized
  procedure await_uvvm_initialization(
    constant dummy : in t_void
  );

  -------------------------------------------
  -- await_uvvm_completion
  -------------------------------------------
  procedure await_uvvm_completion(
    constant timeout              : time;
    constant alert_level          : t_alert_level           := TB_ERROR;
    constant sb_poll_time         : time                    := 100 us;
    constant print_alert_counters : t_report_alert_counters := NO_REPORT;
    constant print_sbs            : t_report_sb             := NO_REPORT;
    constant print_vvcs           : t_report_vvc            := NO_REPORT;
    constant scope                : string                  := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel         : t_msg_id_panel          := shared_msg_id_panel
  );

  -------------------------------------------
  -- format_command_idx
  -------------------------------------------
  -- Converts the command index to string, enclused by
  -- C_CMD_IDX_PREFIX and C_CMD_IDX_SUFFIX
  impure function format_command_idx(
    command_idx : integer
  ) return string;

  --***********************************************
  -- BROADCAST COMMANDS
  --***********************************************

  -------------------------------------------
  -- enable_log_msg (Broadcast)
  -------------------------------------------
  -- Enables a log message for all VVCs
  procedure enable_log_msg(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg_id        : in t_msg_id;
    constant msg           : in string      := "";
    constant quietness     : in t_quietness := NON_QUIET;
    constant scope         : in string      := C_VVC_CMD_SCOPE_DEFAULT
  );

  -------------------------------------------
  -- disable_log_msg (Broadcast)
  -------------------------------------------
  -- Disables a log message for all VVCs
  procedure disable_log_msg(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg_id        : in t_msg_id;
    constant msg           : in string      := "";
    constant quietness     : in t_quietness := NON_QUIET;
    constant scope         : in string      := C_VVC_CMD_SCOPE_DEFAULT
  );

  -------------------------------------------
  -- flush_command_queue (Broadcast)
  -------------------------------------------
  -- Flushes the command queue for all VVCs
  procedure flush_command_queue(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  -------------------------------------------
  -- insert_delay (Broadcast)
  -------------------------------------------
  -- Inserts delay into all VVCs (specified as number of clock cycles)
  procedure insert_delay(
    signal   VVC_BROADCAST : inout std_logic;
    constant delay         : in natural; -- in clock cycles
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  -------------------------------------------
  -- insert_delay (Broadcast)
  -------------------------------------------
  -- Inserts delay into all VVCs (specified as time)
  procedure insert_delay(
    signal   VVC_BROADCAST : inout std_logic;
    constant delay         : in time;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  -------------------------------------------
  -- await_completion (Broadcast)
  -------------------------------------------
  -- Wait for all VVCs to finish (specified as time)
  procedure await_completion(
    signal   VVC_BROADCAST : inout std_logic;
    constant timeout       : in time;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  -------------------------------------------
  -- terminate_current_command (Broadcast)
  -------------------------------------------
  -- terminates all current tasks
  procedure terminate_current_command(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  -------------------------------------------
  -- terminate_all_commands (Broadcast)
  -------------------------------------------
  -- terminates all tasks
  procedure terminate_all_commands(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  );
  -------------------------------------------
  -- transmit_broadcast
  -------------------------------------------
  -- Common broadcast transmission routine
  procedure transmit_broadcast(
    signal   VVC_BROADCAST : inout std_logic;
    constant operation     : in t_broadcastable_cmd;
    constant proc_call     : in string;
    constant msg_id        : in t_msg_id;
    constant msg           : in string      := "";
    constant quietness     : in t_quietness := NON_QUIET;
    constant delay         : in time        := 0 ns;
    constant delay_int     : in integer     := -1;
    constant timeout       : in time        := std.env.resolution_limit;
    constant scope         : in string      := C_VVC_CMD_SCOPE_DEFAULT
  );

  -------------------------------------------
  -- get_scope_for_log
  -------------------------------------------
  -- Returns a string with length <= C_LOG_SCOPE_WIDTH.
  -- Inputs vvc_name and channel are truncated to match C_LOG_SCOPE_WIDTH if to long.
  -- An alert is issued if C_MINIMUM_VVC_NAME_SCOPE_WIDTH and C_MINIMUM_CHANNEL_SCOPE_WIDTH
  -- are to long relative to C_LOG_SCOPE_WIDTH.
  impure function get_scope_for_log(
    constant vvc_name     : string;
    constant instance_idx : natural;
    constant channel      : t_channel
  ) return string;

  -------------------------------------------
  -- get_scope_for_log
  -------------------------------------------
  -- Returns a string with length <= C_LOG_SCOPE_WIDTH.
  -- Input vvc_name is truncated to match C_LOG_SCOPE_WIDTH if to long.
  -- An alert is issued if C_MINIMUM_VVC_NAME_SCOPE_WIDTH
  -- is to long relative to C_LOG_SCOPE_WIDTH.
  impure function get_scope_for_log(
    constant vvc_name     : string;
    constant instance_idx : natural
  ) return string;

  -------------------------------------------
  -- await_completion
  -------------------------------------------
  procedure await_completion(
    constant vvc_select   : in t_vvc_select;
    variable vvc_list     : inout t_prot_vvc_list;
    constant wanted_idx   : in integer;
    constant timeout      : in time;
    constant list_action  : in t_list_action  := CLEAR_LIST;
    constant msg          : in string         := "";
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  );

  -- Overload without vvc_select, using ALL_OF
  procedure await_completion(
    variable vvc_list     : inout t_prot_vvc_list;
    constant timeout      : in time;
    constant list_action  : in t_list_action  := CLEAR_LIST;
    constant msg          : in string         := "";
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  );

  -- Overload. Awaits completion of any or all VVCs in the list, or until timeout
  procedure await_completion(
    constant vvc_select   : in t_vvc_select;
    variable vvc_list     : inout t_prot_vvc_list;
    constant timeout      : in time;
    constant list_action  : in t_list_action  := CLEAR_LIST;
    constant msg          : in string         := "";
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  );

  -- Overload. Awaits completion of all VVCs in the activity register (Broadcast), or until timeout.
  procedure await_completion(
    constant vvc_select   : in t_vvc_select;
    constant timeout      : in time;
    constant msg          : in string         := "";
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  );

  -- ============================================================================
  -- Activity Watchdog
  -- ============================================================================
  procedure activity_watchdog(
    constant num_exp_vvc : natural;
    constant timeout     : time;
    constant alert_level : t_alert_level := TB_ERROR;
    constant msg         : string        := "Activity_Watchdog"
  );

  -- ============================================================================
  -- Unwanted Activity Detection
  -- ============================================================================
  -- Checks for unwanted activity and issues an alert of severity
  procedure check_unwanted_activity(
    signal   tracked_signal : std_logic;
    constant alert_level    : t_alert_level;
    constant signal_name    : string;
    constant scope          : string
  );

  -- Overload for std_logic_vector signal
  procedure check_unwanted_activity(
    signal   tracked_signal : std_logic_vector;
    constant alert_level    : t_alert_level;
    constant signal_name    : string;
    constant scope          : string
  );

  -- ============================================================================
  -- VVC Activity Register
  -- ============================================================================
  shared variable shared_vvc_activity_register : t_vvc_activity;

  -- ============================================================================
  -- Hierarchical VVC (HVVC)
  -- ============================================================================
  type t_vvc_operation is (TRANSMIT, RECEIVE); -- Type of operation to be executed by the VVC
  type t_direction is (TRANSMIT, RECEIVE); -- Direction of the interface (used by the IF field config)
  type t_field_position is (FIRST, MIDDLE, LAST, FIRST_AND_LAST); -- Position of a field within a packet

  type t_hvvc_to_bridge is record
    trigger          : boolean;         -- Trigger signal
    operation        : t_vvc_operation; -- Operation of the VVC
    num_data_words   : positive;        -- Number of data words transferred
    data_words       : t_slv_array;     -- Data sent to the VVC
    dut_if_field_idx : natural;         -- Index of the interface field
    dut_if_field_pos : t_field_position; -- Position of the interface field within the packet
    msg_id_panel     : t_msg_id_panel;  -- Message ID panel of the HVVC
  end record;

  type t_bridge_to_hvvc is record
    trigger    : boolean;               -- Trigger signal
    data_words : t_slv_array;           -- Data received from the VVC
  end record;

  type t_dut_if_field_config is record
    dut_address           : unsigned;   -- Address of the DUT IF field
    dut_address_increment : integer;    -- Incrementation of the address on each access
    data_width            : positive;   -- Width of the data per transfer
    use_field             : boolean;    -- Used by the HVVC to send/request fields to/from the bridge or ignore them when not applicable
    field_description     : string;     -- Description of the DUT IF field
  end record;

  constant C_DUT_IF_FIELD_CONFIG_DEFAULT : t_dut_if_field_config(dut_address(0 downto 0)) := (
    dut_address           => (others => '0'),
    dut_address_increment => 0,
    data_width            => 8,
    use_field             => true,
    field_description     => "default");

  type t_dut_if_field_config_array is array (natural range <>) of t_dut_if_field_config;

  type t_dut_if_field_config_direction_array is array (t_direction range <>) of t_dut_if_field_config_array;

  constant C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY_DEFAULT : t_dut_if_field_config_direction_array(t_direction'low to t_direction'high)(0 to 0)(dut_address(0 downto 0), field_description(1 to 7)) := (others => (others => C_DUT_IF_FIELD_CONFIG_DEFAULT));

end package ti_vvc_framework_support_pkg;

package body ti_vvc_framework_support_pkg is

  ------------------------------------------------------------------------
  --
  ------------------------------------------------------------------------
  -- Flag handler is a general flag/semaphore handling mechanism between two separate processes/threads
  -- The idea is to allow one process to set a flag and another to reset it. The flag may then be used by both - or others
  -- May be used for a message from process 1 to process 2 with acknowledge; - like do-something & done, or valid & ack
  procedure flag_handler(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.reset <= 'Z';
    flag.set   <= 'Z';

    flag.is_active <= '0';
    wait until flag.set = '1';
    flag.is_active <= '1';
    wait until flag.reset = '1';
    flag.is_active <= '0';
  end procedure;

  procedure set_flag(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.reset     <= 'Z';
    flag.is_active <= 'Z';
    gen_pulse(flag.set, 0 ns, "set flag", C_TB_SCOPE_DEFAULT, ID_NEVER);
  end procedure;

  procedure reset_flag(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.set       <= 'Z';
    flag.is_active <= 'Z';
    gen_pulse(flag.reset, 0 ns, "reset flag", C_TB_SCOPE_DEFAULT, ID_NEVER);
  end procedure;

  -- This procedure checks the shared_uvvm_state on each delta cycle
  procedure await_uvvm_initialization(
    constant dummy : in t_void) is
  begin
    while (shared_uvvm_state /= INIT_COMPLETED) loop
      wait for 0 ns;
    end loop;
  end procedure;

  -- Lists all the registered VVCs
  procedure report_vvcs(
    constant void : in t_void
  ) is
    constant C_PREFIX : string := C_LOG_PREFIX & "     ";
    variable v_line   : line;
  begin
    -- Print report header
    write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
    write(v_line, timestamp_header(now, justify("*** SUMMARY OF VVCS***", LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF);
    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

    -- Print VVCs
    if shared_vvc_activity_register.priv_get_num_registered_vvcs(void) = 0 then
      write(v_line, "     " & "No VVCs to report." & LF);
    else
      for idx in 0 to shared_vvc_activity_register.priv_get_num_registered_vvcs(void) - 1 loop
        write(v_line, "     " & to_string(shared_vvc_activity_register.priv_get_vvc_info(idx)) & LF);
      end loop;
    end if;

    -- Print report bottom line
    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

    -- Write the info string to transcript
    wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
    prefix_lines(v_line, C_PREFIX);
    write_line_to_log_destination(v_line);
    DEALLOCATE(v_line);
  end procedure;

  -- Waits until all the registered VVCs are inactive or a timeout occurs
  procedure await_uvvm_completion(
    constant timeout              : time;
    constant alert_level          : t_alert_level           := TB_ERROR;
    constant sb_poll_time         : time                    := 100 us;
    constant print_alert_counters : t_report_alert_counters := NO_REPORT;
    constant print_sbs            : t_report_sb             := NO_REPORT;
    constant print_vvcs           : t_report_vvc            := NO_REPORT;
    constant scope                : string                  := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel         : t_msg_id_panel          := shared_msg_id_panel
  ) is
    constant C_NAME         : string := "await_uvvm_completion()";
    variable v_elapsed_time : time   := 0 ns;
    variable v_timestamp    : time;
    variable v_line         : line;
  begin
    -- Wait until all the enabled scoreboards have no pending data or a timeout occurs
    v_timestamp    := now;
    await_sb_completion(timeout, alert_level, sb_poll_time, NO_REPORT, NO_REPORT, scope, msg_id_panel, C_NAME);
    v_elapsed_time := v_elapsed_time + (now - v_timestamp);

    -- Sanity checks (alerts are generated in await_sb_completion)
    if timeout <= 0 ns or sb_poll_time <= 0 ns then
      return;
    end if;

    -- Wait for any commands arriving to the interpreter at the same time to be processed
    wait for C_LOG_TIME_BASE;
    v_elapsed_time := v_elapsed_time + C_LOG_TIME_BASE;

    -- Wait until the VVCs are inactive or a timeout occurs
    if shared_vvc_activity_register.priv_get_num_registered_vvcs(void) > 0 then
      loop
        if shared_vvc_activity_register.priv_are_all_vvc_inactive(void) or v_elapsed_time >= timeout then
          exit;
        else
          v_timestamp    := now;
          wait on global_trigger_vvc_activity_register for timeout - v_elapsed_time;
          v_elapsed_time := v_elapsed_time + (now - v_timestamp);
        end if;
      end loop;
    end if;

    -- Print success/fail log message
    if v_elapsed_time >= timeout and not(shared_vvc_activity_register.priv_are_all_vvc_inactive(void)) then
      for idx in 0 to shared_vvc_activity_register.priv_get_num_registered_vvcs(void) - 1 loop
        if shared_vvc_activity_register.priv_get_vvc_activity(idx) = ACTIVE then
          write(v_line, "  " & shared_vvc_activity_register.priv_get_vvc_info(idx) & LF);
        end if;
      end loop;
      alert(alert_level, C_NAME & " => Failed. The following VVC(s) are still active after " & to_string(v_elapsed_time, get_time_unit(v_elapsed_time)) & ":\n" & v_line.all, scope);
    else
      if shared_vvc_activity_register.priv_get_num_registered_vvcs(void) = 0 then
        log(ID_AWAIT_UVVM_COMPLETION, C_NAME & " => OK. There are no VVCs.", scope, msg_id_panel);
      else
        log(ID_AWAIT_UVVM_COMPLETION, C_NAME & " => OK. All VVCs are inactive. Condition occurred after " & to_string(v_elapsed_time, get_time_unit(v_elapsed_time)), scope, msg_id_panel);
      end if;

      -- Print reports
      if print_sbs = REPORT_SCOREBOARDS then
        report_scoreboards(void);
      end if;
      if print_vvcs = REPORT_VVCS then
        report_vvcs(void);
      end if;
      if print_alert_counters = REPORT_ALERT_COUNTERS then
        report_alert_counters(INTERMEDIATE);
      elsif print_alert_counters = REPORT_ALERT_COUNTERS_FINAL then
        report_alert_counters(FINAL);
      end if;
    end if;
    DEALLOCATE(v_line);
  end procedure;

  impure function format_command_idx(
    command_idx : integer
  ) return string is
  begin
    return C_CMD_IDX_PREFIX & to_string(command_idx) & C_CMD_IDX_SUFFIX;
  end;

  procedure enable_log_msg(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg_id        : in t_msg_id;
    constant msg           : in string      := "";
    constant quietness     : in t_quietness := NON_QUIET;
    constant scope         : in string      := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "enable_log_msg";
    constant proc_call : string := proc_name & "(VVC_BROADCAST, " & to_upper(to_string(msg_id)) & ")";
  begin
    transmit_broadcast(VVC_BROADCAST, ENABLE_LOG_MSG, proc_call, msg_id, msg, quietness, scope => scope);
  end procedure;

  procedure disable_log_msg(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg_id        : in t_msg_id;
    constant msg           : in string      := "";
    constant quietness     : in t_quietness := NON_QUIET;
    constant scope         : in string      := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "disable_log_msg";
    constant proc_call : string := proc_name & "(VVC_BROADCAST, " & to_upper(to_string(msg_id)) & ")";
  begin
    transmit_broadcast(VVC_BROADCAST, DISABLE_LOG_MSG, proc_call, msg_id, msg, quietness, scope => scope);
  end procedure;

  procedure flush_command_queue(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "flush_command_queue";
    constant proc_call : string := proc_name & "(VVC_BROADCAST)";
  begin
    transmit_broadcast(VVC_BROADCAST, FLUSH_COMMAND_QUEUE, proc_call, NO_ID, msg, scope => scope);
  end procedure;

  procedure insert_delay(
    signal   VVC_BROADCAST : inout std_logic;
    constant delay         : in natural; -- in clock cycles
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "insert_delay";
    constant proc_call : string := proc_name & "(VVC_BROADCAST, " & to_string(delay) & ")";
  begin
    transmit_broadcast(VVC_BROADCAST, FLUSH_COMMAND_QUEUE, proc_call, NO_ID, msg, NON_QUIET, 0 ns, delay, scope => scope);
  end procedure;

  procedure insert_delay(
    signal   VVC_BROADCAST : inout std_logic;
    constant delay         : in time;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "insert_delay";
    constant proc_call : string := proc_name & "(VVC_BROADCAST, " & to_string(delay) & ")";
  begin
    transmit_broadcast(VVC_BROADCAST, INSERT_DELAY, proc_call, NO_ID, msg, NON_QUIET, delay, scope => scope);
  end procedure;

  procedure await_completion(
    signal   VVC_BROADCAST : inout std_logic;
    constant timeout       : in time;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "await_completion";
    constant proc_call : string := proc_name & "(VVC_BROADCAST)";
  begin
    log(ID_OLD_AWAIT_COMPLETION, "Procedure is not supporting the VVC activity register.", scope);
    transmit_broadcast(VVC_BROADCAST, AWAIT_COMPLETION, proc_call, NO_ID, msg, NON_QUIET, 0 ns, -1, timeout, scope);
  end procedure;

  procedure terminate_current_command(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "terminate_current_command";
    constant proc_call : string := proc_name & "(VVC_BROADCAST)";
  begin
    transmit_broadcast(VVC_BROADCAST, TERMINATE_CURRENT_COMMAND, proc_call, NO_ID, msg, scope => scope);
  end procedure;

  procedure terminate_all_commands(
    signal   VVC_BROADCAST : inout std_logic;
    constant msg           : in string := "";
    constant scope         : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "terminate_all_commands";
    constant proc_call : string := proc_name & "(VVC_BROADCAST)";
  begin
    flush_command_queue(VVC_BROADCAST, msg);
    terminate_current_command(VVC_BROADCAST, msg, scope => scope);
  end procedure;

  procedure transmit_broadcast(
    signal   VVC_BROADCAST : inout std_logic;
    constant operation     : in t_broadcastable_cmd;
    constant proc_call     : in string;
    constant msg_id        : in t_msg_id;
    constant msg           : in string      := "";
    constant quietness     : in t_quietness := NON_QUIET;
    constant delay         : in time        := 0 ns;
    constant delay_int     : in integer     := -1;
    constant timeout       : in time        := std.env.resolution_limit;
    constant scope         : in string      := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    await_semaphore_in_delta_cycles(protected_semaphore);

    -- Increment shared_cmd_idx. It is protected by the protected_semaphore and only one sequencer can access the variable at a time.
    shared_cmd_idx := shared_cmd_idx + 1;

    if global_show_msg_for_uvvm_cmd then
      log(ID_UVVM_SEND_CMD, to_string(proc_call) & ": " & add_msg_delimiter(to_string(msg)) & format_command_idx(shared_cmd_idx), scope);
    else
      log(ID_UVVM_SEND_CMD, to_string(proc_call) & format_command_idx(shared_cmd_idx), scope);
    end if;

    shared_vvc_broadcast_cmd.operation                        := operation;
    shared_vvc_broadcast_cmd.msg_id                           := msg_id;
    shared_vvc_broadcast_cmd.msg                              := (others => NUL); -- default empty
    shared_vvc_broadcast_cmd.msg(1 to msg'length)             := msg;
    shared_vvc_broadcast_cmd.quietness                        := quietness;
    shared_vvc_broadcast_cmd.timeout                          := timeout;
    shared_vvc_broadcast_cmd.delay                            := delay;
    shared_vvc_broadcast_cmd.gen_integer                      := delay_int;
    shared_vvc_broadcast_cmd.proc_call                        := (others => NUL); -- default empty
    shared_vvc_broadcast_cmd.proc_call(1 to proc_call'length) := proc_call;

    if VVC_BROADCAST /= 'L' then
      -- a VVC is waiting for example in await_completion
      wait until VVC_BROADCAST = 'L';
    end if;

    -- Trigger the broadcast
    VVC_BROADCAST <= '1';
    wait for 0 ns;
    -- set back to 'L' and wait until all VVCs have set it back
    VVC_BROADCAST <= 'L';

    wait until VVC_BROADCAST = 'L' for timeout; -- Wait for executor
    if not (VVC_BROADCAST'event) and VVC_BROADCAST /= 'L' then -- Indicates timeout
      tb_error("Timeout while waiting for the broadcast command to be ACK'ed", scope);
    else
      log(ID_UVVM_CMD_ACK, "ACK received for broadcast command" & format_command_idx(shared_cmd_idx), scope);
    end if;

    shared_vvc_broadcast_cmd := C_VVC_BROADCAST_CMD_DEFAULT;

    wait for 0 ns;
    wait for 0 ns;
    wait for 0 ns;
    wait for 0 ns;
    wait for 0 ns;

    release_semaphore(protected_semaphore);

  end procedure;

  impure function get_scope_for_log(
    constant vvc_name     : string;
    constant instance_idx : natural;
    constant channel      : t_channel
  ) return string is
    constant C_INSTANCE_IDX_STR          : string  := to_string(instance_idx);
    constant C_CHANNEL_STR               : string  := to_upper(to_string(channel));
    constant C_SCOPE_LENGTH              : natural := vvc_name'length + C_INSTANCE_IDX_STR'length + C_CHANNEL_STR'length + 2; -- +2 because of the two added commas
    variable v_vvc_name_truncation_value : integer;
    variable v_channel_truncation_value  : integer;
    variable v_vvc_name_truncation_idx   : integer;
    variable v_channel_truncation_idx    : integer;
  begin

    if (C_MINIMUM_VVC_NAME_SCOPE_WIDTH + C_MINIMUM_CHANNEL_SCOPE_WIDTH + C_INSTANCE_IDX_STR'length + 2) > C_LOG_SCOPE_WIDTH then -- +2 because of the two added commas
      alert(TB_WARNING, "The combined width of C_MINIMUM_VVC_NAME_SCOPE_WIDTH and C_MINIMUM_CHANNEL_SCOPE_WIDTH cannot be greater than C_LOG_SCOPE_WIDTH - (number of characters in instance) - 2.", C_SCOPE);
    end if;

    -- If C_SCOPE_LENGTH is not greater than allowed width, return scope
    if C_SCOPE_LENGTH <= C_LOG_SCOPE_WIDTH then
      return vvc_name & "," & C_INSTANCE_IDX_STR & "," & C_CHANNEL_STR;

    -- If C_SCOPE_LENGTH is greater than allowed width

    -- Check if vvc_name is greater than minimum width to truncate
    elsif vvc_name'length <= C_MINIMUM_VVC_NAME_SCOPE_WIDTH then
      return vvc_name & "," & C_INSTANCE_IDX_STR & "," & C_CHANNEL_STR(1 to (C_CHANNEL_STR'length - (C_SCOPE_LENGTH - C_LOG_SCOPE_WIDTH)));

    -- Check if channel is greater than minimum width to truncate
    elsif C_CHANNEL_STR'length <= C_MINIMUM_CHANNEL_SCOPE_WIDTH then
      return vvc_name(1 to (vvc_name'length - (C_SCOPE_LENGTH - C_LOG_SCOPE_WIDTH))) & "," & C_INSTANCE_IDX_STR & "," & C_CHANNEL_STR;

    -- If both vvc_name and channel is to be truncated
    else

      -- Calculate linear scaling of truncation between vvc_name and channel: (a*x)/(a+b), (b*x)/(a+b)
      v_vvc_name_truncation_idx  := integer(round(real(vvc_name'length * (C_SCOPE_LENGTH - C_LOG_SCOPE_WIDTH))) / real(vvc_name'length + C_CHANNEL_STR'length));
      v_channel_truncation_value := integer(round(real(C_CHANNEL_STR'length * (C_SCOPE_LENGTH - C_LOG_SCOPE_WIDTH))) / real(vvc_name'length + C_CHANNEL_STR'length));

      -- In case division ended with .5 and both rounded up
      if (v_vvc_name_truncation_idx + v_channel_truncation_value) > (C_SCOPE_LENGTH - C_LOG_SCOPE_WIDTH) then
        v_channel_truncation_value := v_channel_truncation_value - 1;
      end if;

      -- Character index to truncate
      v_vvc_name_truncation_idx := vvc_name'length - v_vvc_name_truncation_idx;
      v_channel_truncation_idx  := C_CHANNEL_STR'length - v_channel_truncation_value;

      -- If bellow minimum name width
      while v_vvc_name_truncation_idx < C_MINIMUM_VVC_NAME_SCOPE_WIDTH loop
        v_vvc_name_truncation_idx := v_vvc_name_truncation_idx + 1;
        v_channel_truncation_idx  := v_channel_truncation_idx - 1;
      end loop;

      -- If bellow minimum channel width
      while v_channel_truncation_idx < C_MINIMUM_CHANNEL_SCOPE_WIDTH loop
        v_channel_truncation_idx  := v_channel_truncation_idx + 1;
        v_vvc_name_truncation_idx := v_vvc_name_truncation_idx - 1;
      end loop;

      return vvc_name(1 to v_vvc_name_truncation_idx) & "," & C_INSTANCE_IDX_STR & "," & C_CHANNEL_STR(1 to v_channel_truncation_idx);

    end if;
  end function;

  impure function get_scope_for_log(
    constant vvc_name     : string;
    constant instance_idx : natural
  ) return string is
    constant C_INSTANCE_IDX_STR : string  := to_string(instance_idx);
    constant C_SCOPE_LENGTH     : integer := vvc_name'length + C_INSTANCE_IDX_STR'length + 1; -- +1 because of the added comma
  begin

    if (C_MINIMUM_VVC_NAME_SCOPE_WIDTH + C_INSTANCE_IDX_STR'length + 1) > C_LOG_SCOPE_WIDTH then -- +1 because of the added comma
      alert(TB_WARNING, "The width of C_MINIMUM_VVC_NAME_SCOPE_WIDTH cannot be greater than C_LOG_SCOPE_WIDTH - (number of characters in instance) - 1.", C_SCOPE);
    end if;

    -- If C_SCOPE_LENGTH is not greater than allowed width, return scope
    if C_SCOPE_LENGTH <= C_LOG_SCOPE_WIDTH then
      return vvc_name & "," & C_INSTANCE_IDX_STR;

    -- If C_SCOPE_LENGTH is greater than allowed width truncate vvc_name
    else
      return vvc_name(1 to (vvc_name'length - (C_SCOPE_LENGTH - C_LOG_SCOPE_WIDTH))) & "," & C_INSTANCE_IDX_STR;

    end if;
  end function;

  procedure await_completion(
    constant vvc_select   : in t_vvc_select;
    variable vvc_list     : inout t_prot_vvc_list;
    constant wanted_idx   : in integer;
    constant timeout      : in time;
    constant list_action  : in t_list_action  := CLEAR_LIST;
    constant msg          : in string         := "";
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  ) is
    constant proc_name                      : string                                      := "await_completion";
    constant proc_call                      : string                                      := proc_name & "(" & to_string(vvc_select) & "," & vvc_list.priv_get_vvc_list & "," & to_string(timeout, ns) & ")";
    constant proc_call_short                : string                                      := proc_name & "(" & to_string(vvc_select) & "," & to_string(timeout, ns) & ")";
    constant c_index_not_found              : integer                                     := -1;
    constant c_vvc_list_length              : natural                                     := vvc_list.priv_get_num_vvc_in_list;
    variable v_vvc_idx_in_activity_register : t_integer_array(0 to C_MAX_TB_VVC_NUM)      := (others => -1);
    variable v_num_vvc_instances            : natural                                     := 0;
    variable v_tot_vvc_instances            : natural range 0 to C_MAX_TB_VVC_NUM         := 0;
    variable v_vvc_logged                   : std_logic_vector(0 to C_MAX_TB_VVC_NUM - 1) := (others => '0');
    variable v_vvcs_completed               : natural                                     := 0;
    variable v_local_cmd_idx                : integer;
    variable v_timestamp                    : time;
    variable v_done                         : boolean                                     := false;
    variable v_first_wait                   : boolean                                     := true;
    variable v_list_idx                     : natural                                     := 0;
    variable v_proc_call                    : line;
  begin
    if vvc_select = ALL_VVCS and shared_vvc_activity_register.priv_get_num_registered_vvcs(void) = c_vvc_list_length then
      v_proc_call := new string'(proc_call_short);
    else
      v_proc_call := new string'(proc_call);
    end if;

    if c_vvc_list_length > 1 and wanted_idx >= 0 then
      alert(TB_ERROR, v_proc_call.all & add_msg_delimiter(msg) & "=> wanted_idx and VVC list can only be used with 1 single VVC in the VVC list.", scope);
    end if;

    -- Increment shared_cmd_idx. It is protected by the protected_semaphore and only one sequencer can access the variable at a time.
    -- Store it in a local variable since new commands might be executed from another sequencer.
    await_semaphore_in_delta_cycles(protected_semaphore);
    shared_cmd_idx  := shared_cmd_idx + 1;
    v_local_cmd_idx := shared_cmd_idx;
    release_semaphore(protected_semaphore);

    log(ID_AWAIT_COMPLETION, v_proc_call.all & ": " & add_msg_delimiter(msg) & "." & format_command_idx(v_local_cmd_idx), scope, msg_id_panel);

    -- Give a warning for incorrect use of ALL_VVCS
    if vvc_select = ALL_VVCS and shared_vvc_activity_register.priv_get_num_registered_vvcs(void) /= c_vvc_list_length then
      alert(TB_WARNING, v_proc_call.all & add_msg_delimiter(msg) & "=> When using ALL_VVCS with a VVC list, only the VVCs from the list will be checked." & format_command_idx(v_local_cmd_idx), scope);
    end if;

    -- Check that list is not empty
    if c_vvc_list_length = 0 then
      v_done := true;
    end if;

    -- Loop through the VVC list and get the corresponding index from the vvc activity register
    for i in 0 to c_vvc_list_length - 1 loop
      if vvc_list.priv_get_instance(i) = ALL_INSTANCES or vvc_list.priv_get_channel(i) = ALL_CHANNELS then
        -- Check how many instances or channels of this VVC are registered in the vvc activity register
        v_num_vvc_instances := shared_vvc_activity_register.priv_get_num_registered_vvc_matches(vvc_list.priv_get_name(i),
                                                                                                vvc_list.priv_get_instance(i), vvc_list.priv_get_channel(i));
        -- Get the index for every instance or channel of this VVC
        for j in 0 to v_num_vvc_instances - 1 loop
          v_vvc_idx_in_activity_register(v_tot_vvc_instances + j) := shared_vvc_activity_register.priv_get_vvc_idx(j, vvc_list.priv_get_name(i),
                                                                                                                   vvc_list.priv_get_instance(i), vvc_list.priv_get_channel(i));
        end loop;
      else
        -- Get the index for a specific VVC
        v_vvc_idx_in_activity_register(v_tot_vvc_instances) := shared_vvc_activity_register.priv_get_vvc_idx(vvc_list.priv_get_name(i),
                                                                                                             vvc_list.priv_get_instance(i), vvc_list.priv_get_channel(i));
        v_num_vvc_instances                                 := 0 when v_vvc_idx_in_activity_register(v_tot_vvc_instances) = c_index_not_found else 1;
      end if;

      -- Update the total number of VVCs in the group
      v_tot_vvc_instances := v_tot_vvc_instances + v_num_vvc_instances;

      -- Check if the VVC from the list is registered in the vvc activity register, otherwise clean the list and exit procedure
      if v_vvc_idx_in_activity_register(v_tot_vvc_instances - v_num_vvc_instances) = c_index_not_found then
        alert(TB_ERROR, v_proc_call.all & add_msg_delimiter(msg) & "=> " & vvc_list.priv_get_vvc_info(i) & " does not support this procedure." & format_command_idx(v_local_cmd_idx), scope);
        v_done := true;
        exit;
      end if;
    end loop;

    if v_tot_vvc_instances = 0 then
      alert(TB_WARNING, v_proc_call.all & add_msg_delimiter(msg) & "=> No matching VVC from vvc_list found in VVC activity register.", scope);
    end if;

    v_timestamp := now;
    while not (v_done) loop
      v_list_idx := 0;
      for i in 0 to v_tot_vvc_instances - 1 loop
        -- Wait for the VVCs in the group to complete (INACTIVE status)
        if wanted_idx = -1 then
          if shared_vvc_activity_register.priv_get_vvc_activity(v_vvc_idx_in_activity_register(i)) = INACTIVE then
            if not (v_vvc_logged(i)) then
              log(ID_AWAIT_COMPLETION_END, v_proc_call.all & "=> " & shared_vvc_activity_register.priv_get_vvc_info(v_vvc_idx_in_activity_register(i)) & " finished. " & add_msg_delimiter(msg) & format_command_idx(v_local_cmd_idx), scope, msg_id_panel);
              v_vvc_logged(i)  := '1';
              v_vvcs_completed := v_vvcs_completed + 1;
            end if;
            if vvc_select = ANY_OF or v_vvcs_completed = v_tot_vvc_instances then
              v_done := true;
            end if;
          end if;
        -- Wait for the VVCs in the group to complete (cmd_idx completed)
        else
          if shared_vvc_activity_register.priv_is_cmd_idx_executed(v_vvc_idx_in_activity_register(i), wanted_idx) then
            if not (v_vvc_logged(i)) then
              log(ID_AWAIT_COMPLETION_END, v_proc_call.all & "=> " & shared_vvc_activity_register.priv_get_vvc_info(v_vvc_idx_in_activity_register(i)) & " finished. " & add_msg_delimiter(msg) & format_command_idx(v_local_cmd_idx), scope, msg_id_panel);
              v_vvc_logged(i)  := '1';
              v_vvcs_completed := v_vvcs_completed + 1;
            end if;
            if vvc_select = ANY_OF or v_vvcs_completed = v_tot_vvc_instances then
              v_done := true;
            end if;
          end if;
        end if;
        -- Increment the vvc_list index (different from the v_vvc_idx_in_activity_register)
        if not (vvc_list.priv_get_instance(v_list_idx) = ALL_INSTANCES or vvc_list.priv_get_channel(v_list_idx) = ALL_CHANNELS) then
          v_list_idx := v_list_idx + 1;
        end if;
      end loop;

      if not (v_done) then
        if v_first_wait then
          log(ID_AWAIT_COMPLETION_WAIT, v_proc_call.all & " - Pending completion. " & add_msg_delimiter(msg) & format_command_idx(v_local_cmd_idx), scope, msg_id_panel);
          v_first_wait := false;
        end if;

        -- Wait for vvc activity trigger pulse
        wait on global_trigger_vvc_activity_register for timeout;

        -- Check if there was a timeout
        if now >= v_timestamp + timeout then
          alert(TB_ERROR, v_proc_call.all & "=> Timeout. " & add_msg_delimiter(msg) & format_command_idx(v_local_cmd_idx), scope);
          v_done := true;
        end if;
      end if;
    end loop;

    if list_action = CLEAR_LIST then
      vvc_list.clear_list(VOID);
      log(ID_AWAIT_COMPLETION_LIST, v_proc_call.all & "=> All VVCs removed from the list. " & add_msg_delimiter(msg) & format_command_idx(v_local_cmd_idx), scope, msg_id_panel);
    elsif list_action = KEEP_LIST then
      log(ID_AWAIT_COMPLETION_LIST, v_proc_call.all & "=> Keeping all VVCs in the list. " & add_msg_delimiter(msg) & format_command_idx(v_local_cmd_idx), scope, msg_id_panel);
    end if;
    deallocate(v_proc_call);
  end procedure;

  procedure await_completion(
    variable vvc_list     : inout t_prot_vvc_list;
    constant timeout      : in time;
    constant list_action  : in t_list_action  := CLEAR_LIST;
    constant msg          : in string         := "";
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_completion(ALL_OF, vvc_list, timeout, list_action, msg, scope, msg_id_panel);
  end procedure await_completion;

  procedure await_completion(
    constant vvc_select   : in t_vvc_select;
    variable vvc_list     : inout t_prot_vvc_list;
    constant timeout      : in time;
    constant list_action  : in t_list_action  := CLEAR_LIST;
    constant msg          : in string         := "";
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_completion(vvc_select, vvc_list, -1, timeout, list_action, msg, scope, msg_id_panel);
  end procedure await_completion;

  procedure await_completion(
    constant vvc_select   : in t_vvc_select;
    constant timeout      : in time;
    constant msg          : in string         := "";
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  ) is
    constant proc_name  : string := "await_completion";
    constant proc_call  : string := proc_name & "(" & to_string(vvc_select) & "," & to_string(timeout, ns) & ")";
    variable v_vvc_list : t_prot_vvc_list;
  begin
    if vvc_select = ALL_VVCS then
      -- Get all the VVCs from the vvc activity register and put them in the vvc_list
      for i in 0 to shared_vvc_activity_register.priv_get_num_registered_vvcs(void) - 1 loop
        v_vvc_list.add(shared_vvc_activity_register.priv_get_vvc_name(i),
                       shared_vvc_activity_register.priv_get_vvc_instance(i),
                       shared_vvc_activity_register.priv_get_vvc_channel(i), scope, msg_id_panel);
      end loop;
      await_completion(vvc_select, v_vvc_list, timeout, CLEAR_LIST, msg, scope, msg_id_panel);
    else
      alert(TB_ERROR, proc_call & add_msg_delimiter(msg) & "=> A VVC list is required when using " & to_string(vvc_select) & ".", scope);
    end if;
  end procedure;

  -- ============================================================================
  -- Activity Watchdog
  -- ============================================================================
  -------------------------------------------------------------------------------
  -- Activity watchdog:
  -- Include this as a concurrent procedure from your testbench.
  -------------------------------------------------------------------------------
  procedure activity_watchdog(
    constant num_exp_vvc : natural;
    constant timeout     : time;
    constant alert_level : t_alert_level := TB_ERROR;
    constant msg         : string        := "Activity_Watchdog"
  ) is
    variable v_timeout : time;

  begin
    wait for 0 ns;
    log(ID_WATCHDOG, "Starting activity watchdog , timeout=" & to_string(timeout, C_LOG_TIME_BASE) & ". " & msg);
    wait for 0 ns;

    -- Check if all expected VVCs are registered
    if (num_exp_vvc /= shared_vvc_activity_register.priv_get_num_registered_vvcs(void)) and (num_exp_vvc > 0) then
      shared_vvc_activity_register.priv_list_registered_vvc(msg);
      alert(TB_WARNING, "Number of VVCs in activity watchdog is not expected, actual=" & to_string(shared_vvc_activity_register.priv_get_num_registered_vvcs(void)) & ", exp=" & to_string(num_exp_vvc) & ".\n" & "Note that leaf VVCs (e.g. channels) are counted individually. " & msg);
    end if;

    loop
      wait on global_trigger_vvc_activity_register for timeout;

      if not (global_trigger_vvc_activity_register'event) and shared_vvc_activity_register.priv_are_all_vvc_inactive(void) then
        alert(alert_level, "Activity watchdog timer ended after " & to_string(timeout, C_LOG_TIME_BASE) & "! " & msg);
      end if;

    end loop;
    wait;
  end procedure activity_watchdog;

  -- ============================================================================
  -- Unwanted Activity Detection
  -- ============================================================================
  -------------------------------------------------------------------------------
  procedure check_unwanted_activity(
    signal   tracked_signal : std_logic;
    constant alert_level    : t_alert_level;
    constant signal_name    : string;
    constant scope          : string
  ) is
    variable v_last_value   : std_logic := tracked_signal'last_value;
  begin
    -- Exclude checks for signal transitions from 'U', 'L' to/from '0', 'H' to/from '1'
    if not (v_last_value = 'U' or
           (v_last_value = 'L' and tracked_signal = '0') or
           (v_last_value = '0' and tracked_signal = 'L') or
           (v_last_value = 'H' and tracked_signal = '1') or
           (v_last_value = '1' and tracked_signal = 'H')) then
      if tracked_signal'event then
        alert(alert_level, "Unwanted activity detected. " & signal_name & " changed from " &
          to_string(tracked_signal'last_value) & " to " & to_string(tracked_signal), scope);
      end if;
    end if;
  end procedure;

  procedure check_unwanted_activity(
    signal   tracked_signal : std_logic_vector;
    constant alert_level    : t_alert_level;
    constant signal_name    : string;
    constant scope          : string
  ) is
    variable v_is_unwanted_activity : boolean := false;
    variable v_last_value           : std_logic_vector(tracked_signal'range) := tracked_signal'last_value;
  begin
    -- Loop through each bit in the vector and check for unwanted activity
    for i in 0 to tracked_signal'length - 1 loop
      -- Exclude signal transitions from 'U', 'L' to/from '0', 'H' to/from '1'
      if not (v_last_value(i) = 'U' or
             (v_last_value(i) = 'L' and tracked_signal(i) = '0') or
             (v_last_value(i) = '0' and tracked_signal(i) = 'L') or
             (v_last_value(i) = 'H' and tracked_signal(i) = '1') or
             (v_last_value(i) = '1' and tracked_signal(i) = 'H')) then
        v_is_unwanted_activity := true;
      end if;
    end loop;

    if v_is_unwanted_activity then
      if tracked_signal'event then
        alert(alert_level, "Unwanted activity detected. " & signal_name & " changed from " &
          to_string(tracked_signal'last_value, HEX, KEEP_LEADING_0, INCL_RADIX) & " to " & to_string(tracked_signal, HEX, KEEP_LEADING_0, INCL_RADIX), scope);
      end if;
    end if;
  end procedure;

end package body ti_vvc_framework_support_pkg;
