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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.C_SB_CONFIG_DEFAULT;

use work.axi_bfm_pkg.all;
use work.axi_channel_handler_pkg.all;
use work.vvc_methods_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_entity_support_pkg.all;
use work.td_cmd_queue_pkg.all;
use work.td_result_queue_pkg.all;
use work.transaction_pkg.all;
use work.axi_read_data_queue_pkg.all;

--=================================================================================================
entity axi_vvc is
  generic(
    GC_ADDR_WIDTH                            : integer range 1 to C_VVC_CMD_ADDR_MAX_LENGTH := 8;
    GC_DATA_WIDTH                            : integer range 1 to C_VVC_CMD_DATA_MAX_LENGTH := 32;
    GC_ID_WIDTH                              : integer range 0 to C_VVC_CMD_ID_MAX_LENGTH   := 8;
    GC_USER_WIDTH                            : integer range 0 to C_VVC_CMD_USER_MAX_LENGTH := 8;
    GC_INSTANCE_IDX                          : natural                                      := 1; -- Instance index for this AXI_VVCT instance
    GC_AXI_CONFIG                            : t_axi_bfm_config                             := C_AXI_BFM_CONFIG_DEFAULT; -- Behavior specification for BFM
    GC_CMD_QUEUE_COUNT_MAX                   : natural                                      := C_CMD_QUEUE_COUNT_MAX;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural                                      := C_CMD_QUEUE_COUNT_THRESHOLD;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level                                := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;
    GC_RESULT_QUEUE_COUNT_MAX                : natural                                      := C_RESULT_QUEUE_COUNT_MAX;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural                                      := C_RESULT_QUEUE_COUNT_THRESHOLD;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level                                := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );
  port(
    clk               : in    std_logic;
    axi_vvc_master_if : inout t_axi_if := init_axi_if_signals(GC_ADDR_WIDTH, GC_DATA_WIDTH, GC_ID_WIDTH, GC_USER_WIDTH)
  );
begin
  -- Check the interface widths to assure that the interface was correctly set up
  assert (axi_vvc_master_if.write_address_channel.awaddr'length = GC_ADDR_WIDTH) report "axi_vvc_master_if.write_address_channel.awaddr'length =/ GC_ADDR_WIDTH" severity failure;
  assert (axi_vvc_master_if.read_address_channel.araddr'length = GC_ADDR_WIDTH) report "axi_vvc_master_if.read_address_channel.araddr'length =/ GC_ADDR_WIDTH" severity failure;
  assert (axi_vvc_master_if.write_data_channel.wdata'length = GC_DATA_WIDTH) report "axi_vvc_master_if.write_data_channel.wdata'length =/ GC_DATA_WIDTH" severity failure;
  assert (axi_vvc_master_if.write_data_channel.wstrb'length = GC_DATA_WIDTH / 8) report "axi_vvc_master_if.write_data_channel.wstrb'length =/ GC_DATA_WIDTH/8" severity failure;
  assert (axi_vvc_master_if.read_data_channel.rdata'length = GC_DATA_WIDTH) report "axi_vvc_master_if.read_data_channel.rdata'length =/ GC_DATA_WIDTH" severity failure;
end entity axi_vvc;

--=================================================================================================
--=================================================================================================

architecture behave of axi_vvc is

  constant C_SCOPE      : string       := get_scope_for_log(C_VVC_NAME, GC_INSTANCE_IDX);
  constant C_VVC_LABELS : t_vvc_labels := assign_vvc_labels(C_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);

  signal executor_is_busy                           : boolean := false;
  signal write_address_channel_executor_is_busy     : boolean := false;
  signal write_data_channel_executor_is_busy        : boolean := false;
  signal write_response_channel_executor_is_busy    : boolean := false;
  signal read_address_channel_executor_is_busy      : boolean := false;
  signal read_data_channel_executor_is_busy         : boolean := false;
  signal any_executors_busy                         : boolean := false;
  signal queue_is_increasing                        : boolean := false;
  signal write_address_channel_queue_is_increasing  : boolean := false;
  signal write_data_channel_queue_is_increasing     : boolean := false;
  signal write_response_channel_queue_is_increasing : boolean := false;
  signal read_address_channel_queue_is_increasing   : boolean := false;
  signal read_data_channel_queue_is_increasing      : boolean := false;
  signal last_write_response_channel_idx_executed   : natural := 0;
  signal last_read_data_channel_idx_executed        : natural := 0;
  signal terminate_current_cmd                      : t_flag_record;
  signal clock_period                               : time;

  -- Instantiation of the element dedicated Queue
  shared variable command_queue                : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable write_address_channel_queue  : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable write_data_channel_queue     : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable write_response_channel_queue : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable read_address_channel_queue   : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable read_data_channel_queue      : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable result_queue                 : work.td_result_queue_pkg.t_generic_queue;

  alias vvc_config                          : t_vvc_config is shared_axi_vvc_config(GC_INSTANCE_IDX);
  alias vvc_status                          : t_vvc_status is shared_axi_vvc_status(GC_INSTANCE_IDX);
  -- Transaction info
  alias vvc_transaction_info_trigger        : std_logic is global_axi_vvc_transaction_trigger(GC_INSTANCE_IDX);
  alias vvc_transaction_info                : t_transaction_group is shared_axi_vvc_transaction_info(GC_INSTANCE_IDX);
  -- VVC Activity
  signal entry_num_in_vvc_activity_register : integer;

  --UVVM: temporary fix for HVVC, remove function below in v3.0
  function get_msg_id_panel(
    constant command    : in t_vvc_cmd_record;
    constant vvc_config : in t_vvc_config
  ) return t_msg_id_panel is
  begin
    -- If the parent_msg_id_panel is set then use it,
    -- otherwise use the VVCs msg_id_panel from its config.
    if command.msg(1 to 5) = "HVVC:" then
      return vvc_config.parent_msg_id_panel;
    else
      return vvc_config.msg_id_panel;
    end if;
  end function;

  procedure peek_command_and_prepare_executor(
    variable command             : inout t_vvc_cmd_record;
    variable command_queue       : inout work.td_cmd_queue_pkg.t_generic_queue;
    constant vvc_config          : in t_vvc_config;
    variable vvc_status          : inout t_vvc_status;
    signal   queue_is_increasing : in boolean;
    signal   executor_is_busy    : inout boolean;
    constant vvc_labels          : in t_vvc_labels;
    constant msg_id_panel        : in t_msg_id_panel := shared_msg_id_panel; --UVVM: unused, remove in v3.0
    constant executor_id         : in t_msg_id       := ID_CMD_EXECUTOR;
    constant executor_wait_id    : in t_msg_id       := ID_CMD_EXECUTOR_WAIT
  ) is
    variable v_msg_id_panel : t_msg_id_panel;
  begin
    executor_is_busy            <= false;
    vvc_status.previous_cmd_idx := command.cmd_idx;
    vvc_status.current_cmd_idx  := 0;

    wait for 0 ns;                      -- to allow delta updates in other processes.
    if command_queue.is_empty(VOID) then
      log(executor_wait_id, "Executor: Waiting for command", to_string(vvc_labels.scope), vvc_config.msg_id_panel);
      wait until queue_is_increasing;
    end if;

    -- Queue is now not empty
    executor_is_busy <= true;
    wait until executor_is_busy;
    command          := command_queue.peek(VOID);

    v_msg_id_panel             := get_msg_id_panel(command, vvc_config);
    log(executor_id, to_string(command.proc_call) & " - Will be executed " & format_command_idx(command), to_string(vvc_labels.scope), v_msg_id_panel); -- Get and ack the new command
    vvc_status.pending_cmd_cnt := command_queue.get_count(VOID);
    vvc_status.current_cmd_idx := command.cmd_idx;
  end procedure peek_command_and_prepare_executor;

begin

  -- Remove vsim-8684 warning
  p_initial_drivers : process begin
    axi_vvc_master_if.write_address_channel.awready <= 'Z';
    axi_vvc_master_if.write_data_channel.wready     <= 'Z';
    axi_vvc_master_if.write_response_channel.bvalid <= 'Z';
    axi_vvc_master_if.write_response_channel.bid    <= (axi_vvc_master_if.write_response_channel.bid'range => 'Z');
    axi_vvc_master_if.write_response_channel.bresp  <= (others => 'Z');
    axi_vvc_master_if.write_response_channel.buser  <= (axi_vvc_master_if.write_response_channel.buser'range => 'Z');
    axi_vvc_master_if.read_address_channel.arready  <= 'Z';
    axi_vvc_master_if.read_data_channel.rlast       <= 'Z';
    axi_vvc_master_if.read_data_channel.rvalid      <= 'Z';
    axi_vvc_master_if.read_data_channel.rid         <= (axi_vvc_master_if.read_data_channel.rid'range => 'Z');
    axi_vvc_master_if.read_data_channel.rdata       <= (axi_vvc_master_if.read_data_channel.rdata'range => 'Z');
    axi_vvc_master_if.read_data_channel.rresp       <= (others => 'Z');
    axi_vvc_master_if.read_data_channel.ruser       <= (axi_vvc_master_if.read_data_channel.ruser'range => 'Z');
    wait;
  end process p_initial_drivers;

  --===============================================================================================
  -- Constructor
  -- - Set up the defaults and show constructor if enabled
  --===============================================================================================
  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, result_queue, GC_AXI_CONFIG,
                                                 GC_CMD_QUEUE_COUNT_MAX, GC_CMD_QUEUE_COUNT_THRESHOLD, GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
                                                 GC_RESULT_QUEUE_COUNT_MAX, GC_RESULT_QUEUE_COUNT_THRESHOLD, GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
                                                 C_VVC_MAX_INSTANCE_NUM);
  --===============================================================================================

  --===============================================================================================
  -- Set if any of the executors are busy
  --===============================================================================================
  any_executors_busy <= executor_is_busy or write_address_channel_executor_is_busy or write_data_channel_executor_is_busy or write_response_channel_executor_is_busy or read_address_channel_executor_is_busy or read_data_channel_executor_is_busy;
  --===============================================================================================

  --===============================================================================================
  -- Command interpreter
  -- - Interpret, decode and acknowledge commands from the central sequencer
  --===============================================================================================
  cmd_interpreter : process
    variable v_cmd_has_been_acked : boolean; -- Indicates if acknowledge_cmd() has been called for the current shared_vvc_cmd
    variable v_local_vvc_cmd      : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;
    variable v_msg_id_panel       : t_msg_id_panel;
    variable v_temp_msg_id_panel  : t_msg_id_panel; --UVVM: temporary fix for HVVC, remove in v3.0
  begin
    -- 0. Initialize the process prior to first command
    work.td_vvc_entity_support_pkg.initialize_interpreter(terminate_current_cmd, global_awaiting_completion);
    -- initialise shared_vvc_last_received_cmd_idx for channel and instance
    shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := 0;
    -- Register VVC in vvc activity register
    entry_num_in_vvc_activity_register                    <= shared_vvc_activity_register.priv_register_vvc(name          => C_VVC_NAME,
                                                                                                            instance      => GC_INSTANCE_IDX,
                                                                                                            num_executors => 6);
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel                                        := vvc_config.msg_id_panel;

    -- Then for every single command from the sequencer
    loop                                -- basically as long as new commands are received

      -- 1. wait until command targeted at this VVC. Must match VVC name, instance and channel (if applicable)
      --    releases global semaphore
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.await_cmd_from_sequencer(C_VVC_LABELS, vvc_config, THIS_VVCT, VVC_BROADCAST, global_vvc_busy, global_vvc_ack, v_local_vvc_cmd);
      v_cmd_has_been_acked                                  := false; -- Clear flag
      -- update shared_vvc_last_received_cmd_idx with received command index
      shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := v_local_vvc_cmd.cmd_idx;
      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel                                        := get_msg_id_panel(v_local_vvc_cmd, vvc_config);

      -- 2a. Put command on the queue if intended for the executor
      -------------------------------------------------------------------------
      if v_local_vvc_cmd.command_type = QUEUED then
        work.td_vvc_entity_support_pkg.put_command_on_queue(v_local_vvc_cmd, command_queue, vvc_status, queue_is_increasing);

      -- 2b. Otherwise command is intended for immediate response
      -------------------------------------------------------------------------
      elsif v_local_vvc_cmd.command_type = IMMEDIATE then

        --UVVM: temporary fix for HVVC, remove two lines below in v3.0
        if v_local_vvc_cmd.operation /= DISABLE_LOG_MSG and v_local_vvc_cmd.operation /= ENABLE_LOG_MSG then
          v_temp_msg_id_panel     := vvc_config.msg_id_panel;
          vvc_config.msg_id_panel := v_msg_id_panel;
        end if;

        case v_local_vvc_cmd.operation is

          when DISABLE_LOG_MSG =>
            uvvm_util.methods_pkg.disable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when ENABLE_LOG_MSG =>
            uvvm_util.methods_pkg.enable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when FLUSH_COMMAND_QUEUE =>
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, command_queue, vvc_config, vvc_status, C_VVC_LABELS);
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, write_address_channel_queue, vvc_config, vvc_status, C_VVC_LABELS);
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, write_data_channel_queue, vvc_config, vvc_status, C_VVC_LABELS);
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, write_response_channel_queue, vvc_config, vvc_status, C_VVC_LABELS);
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, read_address_channel_queue, vvc_config, vvc_status, C_VVC_LABELS);
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, read_data_channel_queue, vvc_config, vvc_status, C_VVC_LABELS);

          when TERMINATE_CURRENT_COMMAND =>
            work.td_vvc_entity_support_pkg.interpreter_terminate_current_command(v_local_vvc_cmd, vvc_config, C_VVC_LABELS, terminate_current_cmd, executor_is_busy);

          when FETCH_RESULT =>
            work.td_vvc_entity_support_pkg.interpreter_fetch_result(result_queue, entry_num_in_vvc_activity_register, v_local_vvc_cmd, vvc_config, C_VVC_LABELS, shared_vvc_response);

          when others =>
            tb_error("Unsupported command received for IMMEDIATE execution: '" & to_string(v_local_vvc_cmd.operation) & "'", C_SCOPE);

        end case;

        --UVVM: temporary fix for HVVC, remove line below in v3.0
        if v_local_vvc_cmd.operation /= DISABLE_LOG_MSG and v_local_vvc_cmd.operation /= ENABLE_LOG_MSG then
          vvc_config.msg_id_panel := v_temp_msg_id_panel;
        end if;

      else
        tb_error("command_type is not IMMEDIATE or QUEUED", C_SCOPE);
      end if;

      -- 3. Acknowledge command after runing or queuing the command
      -------------------------------------------------------------------------
      if not v_cmd_has_been_acked then
        work.td_target_support_pkg.acknowledge_cmd(global_vvc_ack, v_local_vvc_cmd.cmd_idx);
      end if;

    end loop;
    wait;
  end process;
  --===============================================================================================

  --===============================================================================================
  -- Command executor
  -- - Fetch and execute the commands
  --===============================================================================================
  cmd_executor : process
    constant C_EXECUTOR_ID                           : natural                                      := 0;
    variable v_cmd                                   : t_vvc_cmd_record;
    variable v_read_data                             : t_vvc_result; -- See vvc_cmd_pkg
    variable v_timestamp_start_of_current_bfm_access : time                                         := 0 ns;
    variable v_timestamp_start_of_last_bfm_access    : time                                         := 0 ns;
    variable v_timestamp_end_of_last_bfm_access      : time                                         := 0 ns;
    variable v_command_is_bfm_access                 : boolean                                      := false;
    variable v_prev_command_was_bfm_access           : boolean                                      := false;
    variable v_msg_id_panel                          : t_msg_id_panel;
    variable v_normalised_addr                       : unsigned(GC_ADDR_WIDTH - 1 downto 0)         := (others => '0');
    variable v_normalised_data                       : std_logic_vector(GC_DATA_WIDTH - 1 downto 0) := (others => '0');
    variable v_finish2start_warning_triggered        : boolean                                      := false;
  begin
    -- 0. Initialize the process prior to first command
    -------------------------------------------------------------------------
    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    -- Setup AXI scoreboard
    AXI_VVC_SB.set_scope("AXI_VVC_SB");
    AXI_VVC_SB.enable(GC_INSTANCE_IDX, "AXI VVC SB Enabled");
    AXI_VVC_SB.config(GC_INSTANCE_IDX, C_SB_CONFIG_DEFAULT);
    AXI_VVC_SB.enable_log_msg(GC_INSTANCE_IDX, ID_DATA);

    loop

      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, 0, command_queue.is_empty(VOID), C_SCOPE);

      -- 1. Set defaults, fetch command and log
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_queue, vvc_config, vvc_status, queue_is_increasing, executor_is_busy, C_VVC_LABELS);

      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, 0, command_queue.is_empty(VOID), C_SCOPE);

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);

      -- Check if command is a BFM access
      v_prev_command_was_bfm_access := v_command_is_bfm_access; -- save for inter_bfm_delay
      if v_cmd.operation = WRITE or v_cmd.operation = READ or v_cmd.operation = CHECK then
        v_command_is_bfm_access := true;
      else
        v_command_is_bfm_access := false;
      end if;

      -- Insert delay if needed
      work.td_vvc_entity_support_pkg.insert_inter_bfm_delay_if_requested(vvc_config                         => vvc_config,
                                                                         command_is_bfm_access              => v_prev_command_was_bfm_access,
                                                                         timestamp_start_of_last_bfm_access => v_timestamp_start_of_last_bfm_access,
                                                                         timestamp_end_of_last_bfm_access   => v_timestamp_end_of_last_bfm_access,
                                                                         msg_id_panel                       => v_msg_id_panel,
                                                                         scope                              => C_SCOPE);

      if v_command_is_bfm_access then
        v_timestamp_start_of_current_bfm_access := now;
      end if;

      -- 2. Execute the fetched command
      -------------------------------------------------------------------------
      case v_cmd.operation is           -- Only operations in the dedicated record are relevant

        -- VVC dedicated operations
        --===================================
        when WRITE =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Normalise address and data
          v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, "v_cmd.addr", "v_normalised_addr", "axi_write() called with too wide address. " & v_cmd.msg);
          v_normalised_data := normalize_and_check(v_cmd.data_array(0), v_normalised_data, ALLOW_WIDER_NARROWER, "v_cmd.data_array(0)", "v_normalised_data", "axi_write() called with too wide data. " & v_cmd.msg);

          -- Adding the write command to the write address channel queue , write data channel queue and write response channel queue
          work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, write_address_channel_queue, vvc_status, write_address_channel_queue_is_increasing);
          work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, write_data_channel_queue, vvc_status, write_data_channel_queue_is_increasing);
          work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, write_response_channel_queue, vvc_status, write_response_channel_queue_is_increasing);

        when READ =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Normalise address and data
          v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, "v_cmd.addr", "v_normalised_addr", "axi_read() called with too wide address. " & v_cmd.msg);

          -- Adding the read command to the read address channel queue and the read address data queue
          work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, read_address_channel_queue, vvc_status, read_address_channel_queue_is_increasing);
          work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, read_data_channel_queue, vvc_status, read_data_channel_queue_is_increasing);

        when CHECK =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Normalise address and data
          v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, "v_cmd.addr", "v_normalised_addr", "axi_check() called with too wide address. " & v_cmd.msg);
          v_normalised_data := normalize_and_check(v_cmd.data_array(0), v_normalised_data, ALLOW_WIDER_NARROWER, "v_cmd.data_array(0)", "v_normalised_data", "axi_check() called with too wide data. " & v_cmd.msg);

          -- Adding the check command to the read address channel queue and the read address data queue
          work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, read_address_channel_queue, vvc_status, read_address_channel_queue_is_increasing);
          work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, read_data_channel_queue, vvc_status, read_data_channel_queue_is_increasing);

        -- UVVM common operations
        --===================================
        when INSERT_DELAY =>
          log(ID_INSERTED_DELAY, "Running: " & to_string(v_cmd.proc_call) & " " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
          if v_cmd.gen_integer_array(0) = -1 then
            -- Delay specified using time
            wait until terminate_current_cmd.is_active = '1' for v_cmd.delay;
          else
            -- Delay specified using integer
            check_value(vvc_config.bfm_config.clock_period > -1 ns, TB_ERROR, "Check that clock_period is configured when using insert_delay().",
                        C_SCOPE, ID_NEVER, v_msg_id_panel);
            wait until terminate_current_cmd.is_active = '1' for v_cmd.gen_integer_array(0) * vvc_config.bfm_config.clock_period;
          end if;

        when others =>
          tb_error("Unsupported local command received for execution: '" & to_string(v_cmd.operation) & "'", C_SCOPE);
      end case;

      if v_command_is_bfm_access then
        v_timestamp_end_of_last_bfm_access   := now;
        v_timestamp_start_of_last_bfm_access := v_timestamp_start_of_current_bfm_access;
        if ((vvc_config.inter_bfm_delay.delay_type = TIME_START2START) and ((now - v_timestamp_start_of_current_bfm_access) > vvc_config.inter_bfm_delay.delay_in_time)) then
          alert(vvc_config.inter_bfm_delay.inter_bfm_delay_violation_severity, "BFM access exceeded specified start-to-start inter-bfm delay, " & to_string(vvc_config.inter_bfm_delay.delay_in_time) & ".", C_SCOPE);
        elsif vvc_config.inter_bfm_delay.delay_type = TIME_FINISH2START and not v_finish2start_warning_triggered then
          v_finish2start_warning_triggered := true;
          tb_warning("Delay type TIME_FINISH2START is not supported by this VVC. Waiting according to TIME_START2START", C_SCOPE);
        end if;
      end if;

      -- Reset terminate flag if any occurred
      if (terminate_current_cmd.is_active = '1') then
        log(ID_CMD_EXECUTOR, "Termination request received", C_SCOPE, v_msg_id_panel);
        uvvm_vvc_framework.ti_vvc_framework_support_pkg.reset_flag(terminate_current_cmd);
      end if;

      -- These commands are sent to other executors where they are executed.
      -- Since the commands can finish in any order, to detect when this specific command has finished, we store the cmd_idx
      -- in a list with pending commands which will be cleared in the corresponding executor when it has finished.
      if v_cmd.operation = WRITE or v_cmd.operation = READ or v_cmd.operation = CHECK then
        shared_vvc_activity_register.priv_add_pending_cmd_idx(entry_num_in_vvc_activity_register, v_cmd.cmd_idx);
      end if;

      -- In case we only allow a single pending transaction, wait here until every channel is finished. 
      -- Even though this wait doesn't have a timeout, each of the executors have timeouts.
      if vvc_config.force_single_pending_transaction and v_command_is_bfm_access then
        wait until not write_address_channel_executor_is_busy and not write_data_channel_executor_is_busy and not write_response_channel_executor_is_busy and not read_address_channel_executor_is_busy and not read_data_channel_executor_is_busy;
      end if;

    end loop;
  end process cmd_executor;
  --===============================================================================================

  --===============================================================================================
  -- Read address channel executor
  -- - Fetch and execute the read address channel transactions
  --===============================================================================================
  read_address_channel_executor : process
    constant C_EXECUTOR_ID        : natural                                    := 1;
    variable v_cmd                : t_vvc_cmd_record;
    variable v_msg_id_panel       : t_msg_id_panel;
    variable v_normalized_arid    : std_logic_vector(GC_ID_WIDTH - 1 downto 0) := (others => '0');
    variable v_normalized_araddr  : unsigned(GC_ADDR_WIDTH - 1 downto 0)       := (others => '0');
    constant C_CHANNEL_SCOPE      : string                                     := get_scope_for_log(C_VVC_NAME & "_AR", GC_INSTANCE_IDX);
    constant C_CHANNEL_VVC_LABELS : t_vvc_labels                               := assign_vvc_labels(C_CHANNEL_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);
  begin
    -- Set the command response queue up to the same settings as the command queue
    read_address_channel_queue.set_scope(C_CHANNEL_SCOPE & ":Q");
    read_address_channel_queue.set_queue_count_max(GC_CMD_QUEUE_COUNT_MAX);
    read_address_channel_queue.set_queue_count_threshold(GC_CMD_QUEUE_COUNT_THRESHOLD);
    read_address_channel_queue.set_queue_count_threshold_severity(GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY);
    -- Wait until VVC is registered in vvc activity register in the interpreter
    wait until entry_num_in_vvc_activity_register >= 0;
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    loop
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, 0, read_address_channel_queue.is_empty(VOID), C_SCOPE);
      -- Fetch commands
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, read_address_channel_queue, vvc_config, vvc_status, read_address_channel_queue_is_increasing, read_address_channel_executor_is_busy, C_CHANNEL_VVC_LABELS, shared_msg_id_panel, ID_CHANNEL_EXECUTOR, ID_CHANNEL_EXECUTOR_WAIT);
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, 0, read_address_channel_queue.is_empty(VOID), C_SCOPE);

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel      := get_msg_id_panel(v_cmd, vvc_config);
      -- Normalize values from command record to their actual sizes
      if v_normalized_arid'length > 0 then
        v_normalized_arid := normalize_and_check(v_cmd.id, v_normalized_arid, ALLOW_WIDER_NARROWER, "v_cmd.id", "v_normalized_arid", "Function called with too wide arid. " & v_cmd.msg);
      end if;
      v_normalized_araddr := normalize_and_check(v_cmd.addr, v_normalized_araddr, ALLOW_WIDER_NARROWER, "v_cmd.addr", "v_normalized_araddr", "Function called with too wide araddr. " & v_cmd.msg);
      -- Set vvc transaction info
      set_arw_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_CHANNEL_SCOPE);
      -- Start transaction
      read_address_channel_write(arid_value     => v_normalized_arid,
                                 araddr_value   => v_normalized_araddr,
                                 arlen_value    => v_cmd.len,
                                 arsize_value   => v_cmd.size,
                                 arburst_value  => v_cmd.burst,
                                 arlock_value   => v_cmd.lock,
                                 arcache_value  => v_cmd.cache,
                                 arprot_value   => v_cmd.prot,
                                 arqos_value    => v_cmd.qos,
                                 arregion_value => v_cmd.region,
                                 aruser_value   => v_cmd.auser,
                                 msg            => format_msg(v_cmd),
                                 clk            => clk,
                                 arid           => axi_vvc_master_if.read_address_channel.arid,
                                 araddr         => axi_vvc_master_if.read_address_channel.araddr,
                                 arlen          => axi_vvc_master_if.read_address_channel.arlen,
                                 arsize         => axi_vvc_master_if.read_address_channel.arsize,
                                 arburst        => axi_vvc_master_if.read_address_channel.arburst,
                                 arlock         => axi_vvc_master_if.read_address_channel.arlock,
                                 arcache        => axi_vvc_master_if.read_address_channel.arcache,
                                 arprot         => axi_vvc_master_if.read_address_channel.arprot,
                                 arqos          => axi_vvc_master_if.read_address_channel.arqos,
                                 arregion       => axi_vvc_master_if.read_address_channel.arregion,
                                 aruser         => axi_vvc_master_if.read_address_channel.aruser,
                                 arvalid        => axi_vvc_master_if.read_address_channel.arvalid,
                                 arready        => axi_vvc_master_if.read_address_channel.arready,
                                 scope          => C_CHANNEL_SCOPE,
                                 msg_id_panel   => v_msg_id_panel,
                                 config         => vvc_config.bfm_config);

      -- Update vvc transaction info
      set_arw_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_CHANNEL_SCOPE);
      -- Set vvc transaction info back to default values
      reset_arw_vvc_transaction_info(vvc_transaction_info, v_cmd);
    end loop;
  end process read_address_channel_executor;
  --===============================================================================================

  --===============================================================================================
  -- Read data channel executor
  -- - Fetch and execute the read data channel transactions
  --===============================================================================================
  read_data_channel_executor : process
    constant C_EXECUTOR_ID          : natural      := 2;
    variable v_cmd                  : t_vvc_cmd_record;
    variable v_result               : t_vvc_result := C_EMPTY_VVC_RESULT; -- See vvc_cmd_pkg
    variable v_msg_id_panel         : t_msg_id_panel;
    variable v_read_data_queue      : t_axi_read_data_queue;
    variable v_queue_count          : natural;
    variable v_cmd_len              : natural;
    variable v_normalized_rid       : std_logic_vector(GC_ID_WIDTH - 1 downto 0);
    variable v_check_ok             : boolean      := true;
    constant C_CHANNEL_SCOPE        : string       := get_scope_for_log(C_VVC_NAME & "_R", GC_INSTANCE_IDX);
    constant C_CHANNEL_VVC_LABELS   : t_vvc_labels := assign_vvc_labels(C_CHANNEL_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);
  begin
    -- Set the command response queue up to the same settings as the command queue
    read_data_channel_queue.set_scope(C_CHANNEL_SCOPE & ":Q");
    read_data_channel_queue.set_queue_count_max(GC_CMD_QUEUE_COUNT_MAX);
    read_data_channel_queue.set_queue_count_threshold(GC_CMD_QUEUE_COUNT_THRESHOLD);
    read_data_channel_queue.set_queue_count_threshold_severity(GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY);
    -- Setup the read data queue
    v_read_data_queue.set_scope(C_CHANNEL_SCOPE & ":PQ");
    -- Wait until VVC is registered in vvc activity register in the interpreter
    wait until entry_num_in_vvc_activity_register >= 0;
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    loop
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, last_read_data_channel_idx_executed, read_data_channel_queue.is_empty(VOID), C_SCOPE);
      -- get a command from the queue without removing it
      peek_command_and_prepare_executor(v_cmd, read_data_channel_queue, vvc_config, vvc_status, read_data_channel_queue_is_increasing, read_data_channel_executor_is_busy, C_CHANNEL_VVC_LABELS, shared_msg_id_panel, ID_CHANNEL_EXECUTOR, ID_CHANNEL_EXECUTOR_WAIT);
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, last_read_data_channel_idx_executed, read_data_channel_queue.is_empty(VOID), C_SCOPE);

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);
      -- Handling commands
      case v_cmd.operation is
        when READ =>
          -- Set vvc transaction info
          set_r_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_CHANNEL_SCOPE);
          -- Start transaction
          read_data_channel_receive(read_result     => v_result,
                                    read_data_queue => v_read_data_queue,
                                    msg             => format_msg(v_cmd),
                                    clk             => clk,
                                    rid             => axi_vvc_master_if.read_data_channel.rid,
                                    rdata           => axi_vvc_master_if.read_data_channel.rdata,
                                    rresp           => axi_vvc_master_if.read_data_channel.rresp,
                                    rlast           => axi_vvc_master_if.read_data_channel.rlast,
                                    ruser           => axi_vvc_master_if.read_data_channel.ruser,
                                    rvalid          => axi_vvc_master_if.read_data_channel.rvalid,
                                    rready          => axi_vvc_master_if.read_data_channel.rready,
                                    scope           => C_CHANNEL_SCOPE,
                                    msg_id_panel    => v_msg_id_panel,
                                    config          => vvc_config.bfm_config);

          -- Looking for the correct response in the queue
          if v_normalized_rid'length > 0 then
            v_queue_count := read_data_channel_queue.get_count(VOID);
            for i in 1 to v_queue_count loop
              v_cmd            := read_data_channel_queue.peek(POSITION, i);
              v_normalized_rid := normalize_and_check(v_cmd.id, v_normalized_rid, ALLOW_WIDER_NARROWER, "v_cmd.id", "v_normalized_rid", v_cmd.msg);
              if check_value(v_result.rid, v_normalized_rid, vvc_config.bfm_config.match_strictness, NO_ALERT, "Checking if the correct ID is found in the command queue", C_CHANNEL_SCOPE, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, v_msg_id_panel) then
                -- Correct ID found. We stop searching for the ID
                read_data_channel_queue.delete(POSITION, i, SINGLE);
                exit;
              elsif i = v_queue_count then
                -- We didn't find the correct RID
                alert(vvc_config.bfm_config.general_severity,"Unexpected read data with RID: " & to_string(v_result.rid), C_CHANNEL_SCOPE);
                for ii in 1 to v_queue_count loop
                    alert(vvc_config.bfm_config.general_severity,"Removing read_data_channel_queue(" & to_string(ii) & ") element", C_CHANNEL_SCOPE);
                    read_data_channel_queue.delete(POSITION, ii, SINGLE);
                end loop;
              end if;
            end loop;
          else
            -- ID have length of zero. Using first response in the queue
            v_cmd := read_data_channel_queue.get(VOID);
          end if;

          -- Request SB check result
          if v_cmd.data_routing = TO_SB then
            -- call SB check_received
            AXI_VVC_SB.check_received(GC_INSTANCE_IDX, v_result);
          else
            -- Store the result
            work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,
                                                        cmd_idx      => v_cmd.cmd_idx,
                                                        result       => v_result);
          end if;

          -- Update vvc transaction info
          set_r_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_CHANNEL_SCOPE);

        when CHECK =>
          -- Set vvc transaction info
          set_r_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_CHANNEL_SCOPE);
          -- Start transaction
          read_data_channel_receive(read_result     => v_result,
                                    read_data_queue => v_read_data_queue,
                                    msg             => format_msg(v_cmd),
                                    clk             => clk,
                                    rid             => axi_vvc_master_if.read_data_channel.rid,
                                    rdata           => axi_vvc_master_if.read_data_channel.rdata,
                                    rresp           => axi_vvc_master_if.read_data_channel.rresp,
                                    rlast           => axi_vvc_master_if.read_data_channel.rlast,
                                    ruser           => axi_vvc_master_if.read_data_channel.ruser,
                                    rvalid          => axi_vvc_master_if.read_data_channel.rvalid,
                                    rready          => axi_vvc_master_if.read_data_channel.rready,
                                    scope           => C_CHANNEL_SCOPE,
                                    msg_id_panel    => v_msg_id_panel,
                                    config          => vvc_config.bfm_config,
                                    ext_proc_call   => "read_data_channel_check");

          -- Looking for the correct response in the queue
          if v_normalized_rid'length > 0 then
            v_queue_count := read_data_channel_queue.get_count(VOID);
            for i in 1 to v_queue_count loop
              v_cmd            := read_data_channel_queue.peek(POSITION, i);
              v_normalized_rid := normalize_and_check(v_cmd.id, v_normalized_rid, ALLOW_WIDER_NARROWER, "v_cmd.id", "v_normalized_rid", v_cmd.msg);
              if check_value(v_result.rid, v_normalized_rid, vvc_config.bfm_config.match_strictness, NO_ALERT, "Checking if the correct ID is found in the command queue", C_CHANNEL_SCOPE, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, v_msg_id_panel) then
                -- Correct ID found. We stop searching for the ID
                read_data_channel_queue.delete(POSITION, i, SINGLE);
                exit;
              elsif i = v_queue_count then
                -- We didn't find the correct RID
                alert(vvc_config.bfm_config.general_severity,"Unexpected read data with RID: " & to_string(v_result.rid), C_CHANNEL_SCOPE);
                for ii in 1 to v_queue_count loop
                    alert(vvc_config.bfm_config.general_severity,"Removing read_data_channel_queue(" & to_string(ii) & ") element", C_CHANNEL_SCOPE);
                    read_data_channel_queue.delete(POSITION, ii, SINGLE);
                end loop;
              end if;
            end loop;
          else
            -- ID have length of zero. Using first response in the queue
            v_cmd := read_data_channel_queue.get(VOID);
          end if;

          -- Checking response
          v_cmd_len := to_integer(v_cmd.len);
          if v_normalized_rid'length > 0 then
            if not check_value(v_result.rid, v_normalized_rid, v_cmd.alert_level, "Checking RID. " & add_msg_delimiter(format_msg(v_cmd)), C_CHANNEL_SCOPE, HEX, SKIP_LEADING_0, ID_POS_ACK, v_msg_id_panel) then
              v_check_ok := false;
            end if;
          end if;
          if not check_value(v_result.rdata(0 to v_cmd_len), v_cmd.data_array(0 to v_cmd_len), v_cmd.alert_level, "Checking RDATA. " & add_msg_delimiter(format_msg(v_cmd)), C_CHANNEL_SCOPE, HEX, SKIP_LEADING_0, ID_POS_ACK, v_msg_id_panel) then
            v_check_ok := false;
          end if;
          if not check_value(v_result.rresp(0 to v_cmd_len) = v_cmd.resp_array(0 to v_cmd_len), v_cmd.alert_level, "Checking RRESP. " & add_msg_delimiter(format_msg(v_cmd)), C_CHANNEL_SCOPE, ID_POS_ACK, v_msg_id_panel) then
            v_check_ok := false;
          end if;
          if GC_USER_WIDTH > 0 then
            if not check_value(v_result.ruser(0 to v_cmd_len), v_cmd.user_array(0 to v_cmd_len), v_cmd.alert_level, "Checking RUSER. " & add_msg_delimiter(format_msg(v_cmd)), C_CHANNEL_SCOPE, HEX, SKIP_LEADING_0, ID_POS_ACK, v_msg_id_panel) then
              v_check_ok := false;
            end if;
          end if;

          if v_check_ok then
            log(vvc_config.bfm_config.id_for_bfm, "read data channel check OK. " & add_msg_delimiter(format_msg(v_cmd)), C_CHANNEL_SCOPE, v_msg_id_panel);
          end if;

          -- Update vvc transaction info
          set_r_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_CHANNEL_SCOPE);

        when others =>
          tb_error("Unsupported local command received for execution: '" & to_string(v_cmd.operation) & "'", C_CHANNEL_SCOPE);
      end case;
      v_check_ok                          := true;
      last_read_data_channel_idx_executed <= v_cmd.cmd_idx;

      -- Update vvc transaction info
      set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_CHANNEL_SCOPE);
      -- Set vvc transaction info back to default values
      reset_r_vvc_transaction_info(vvc_transaction_info);
      reset_vvc_transaction_info(vvc_transaction_info, v_cmd);
    end loop;
  end process read_data_channel_executor;
  --===============================================================================================

  --===============================================================================================
  -- write address channel executor
  -- - Fetch and execute the write address channel transactions
  --===============================================================================================
  write_address_channel_executor : process
    constant C_EXECUTOR_ID        : natural                                    := 3;
    variable v_cmd                : t_vvc_cmd_record;
    variable v_msg_id_panel       : t_msg_id_panel;
    variable v_normalized_awid    : std_logic_vector(GC_ID_WIDTH - 1 downto 0) := (others => '0');
    variable v_normalized_awaddr  : unsigned(GC_ADDR_WIDTH - 1 downto 0)       := (others => '0');
    constant C_CHANNEL_SCOPE      : string                                     := get_scope_for_log(C_VVC_NAME & "_AW", GC_INSTANCE_IDX);
    constant C_CHANNEL_VVC_LABELS : t_vvc_labels                               := assign_vvc_labels(C_CHANNEL_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);
  begin
    -- Set the command response queue up to the same settings as the command queue
    write_address_channel_queue.set_scope(C_CHANNEL_SCOPE & ":Q");
    write_address_channel_queue.set_queue_count_max(GC_CMD_QUEUE_COUNT_MAX);
    write_address_channel_queue.set_queue_count_threshold(GC_CMD_QUEUE_COUNT_THRESHOLD);
    write_address_channel_queue.set_queue_count_threshold_severity(GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY);
    -- Wait until VVC is registered in vvc activity register in the interpreter
    wait until entry_num_in_vvc_activity_register >= 0;
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    loop
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, 0, write_address_channel_queue.is_empty(VOID), C_SCOPE);
      -- Fetch commands
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, write_address_channel_queue, vvc_config, vvc_status, write_address_channel_queue_is_increasing, write_address_channel_executor_is_busy, C_CHANNEL_VVC_LABELS, shared_msg_id_panel, ID_CHANNEL_EXECUTOR, ID_CHANNEL_EXECUTOR_WAIT);
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, 0, write_address_channel_queue.is_empty(VOID), C_SCOPE);

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel      := get_msg_id_panel(v_cmd, vvc_config);
      -- Normalise address
      if v_normalized_awid'length > 0 then
        v_normalized_awid := normalize_and_check(v_cmd.id, v_normalized_awid, ALLOW_WIDER_NARROWER, "v_cmd.id", "v_normalized_awid", "Function called with too wide awid. " & v_cmd.msg);
      end if;
      v_normalized_awaddr := normalize_and_check(v_cmd.addr, v_normalized_awaddr, ALLOW_WIDER_NARROWER, "v_cmd.addr", "v_normalized_awaddr", "Function called with too wide awaddr. " & v_cmd.msg);
      -- Set vvc transaction info
      set_arw_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_CHANNEL_SCOPE);
      -- Start transaction
      write_address_channel_write(awid_value     => v_normalized_awid,
                                  awaddr_value   => v_normalized_awaddr,
                                  awlen_value    => v_cmd.len,
                                  awsize_value   => v_cmd.size,
                                  awburst_value  => v_cmd.burst,
                                  awlock_value   => v_cmd.lock,
                                  awcache_value  => v_cmd.cache,
                                  awprot_value   => v_cmd.prot,
                                  awqos_value    => v_cmd.qos,
                                  awregion_value => v_cmd.region,
                                  awuser_value   => v_cmd.auser,
                                  msg            => format_msg(v_cmd),
                                  clk            => clk,
                                  awid           => axi_vvc_master_if.write_address_channel.awid,
                                  awaddr         => axi_vvc_master_if.write_address_channel.awaddr,
                                  awlen          => axi_vvc_master_if.write_address_channel.awlen,
                                  awsize         => axi_vvc_master_if.write_address_channel.awsize,
                                  awburst        => axi_vvc_master_if.write_address_channel.awburst,
                                  awlock         => axi_vvc_master_if.write_address_channel.awlock,
                                  awcache        => axi_vvc_master_if.write_address_channel.awcache,
                                  awprot         => axi_vvc_master_if.write_address_channel.awprot,
                                  awqos          => axi_vvc_master_if.write_address_channel.awqos,
                                  awregion       => axi_vvc_master_if.write_address_channel.awregion,
                                  awuser         => axi_vvc_master_if.write_address_channel.awuser,
                                  awvalid        => axi_vvc_master_if.write_address_channel.awvalid,
                                  awready        => axi_vvc_master_if.write_address_channel.awready,
                                  scope          => C_CHANNEL_SCOPE,
                                  msg_id_panel   => v_msg_id_panel,
                                  config         => vvc_config.bfm_config);

      -- Update vvc transaction info
      set_arw_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_CHANNEL_SCOPE);
      -- Set vvc transaction info back to default values
      reset_arw_vvc_transaction_info(vvc_transaction_info, v_cmd);
    end loop;
  end process write_address_channel_executor;
  --===============================================================================================

  --===============================================================================================
  -- write data channel executor
  -- - Fetch and execute the write data channel transactions
  --===============================================================================================
  write_data_channel_executor : process
    constant C_EXECUTOR_ID        : natural      := 4;
    variable v_cmd                : t_vvc_cmd_record;
    variable v_msg_id_panel       : t_msg_id_panel;
    variable v_wdata_array_ptr    : t_slv_array_ptr;
    variable v_wstrb_array_ptr    : t_slv_array_ptr;
    variable v_wuser_array_ptr    : t_slv_array_ptr;
    constant C_CHANNEL_SCOPE      : string       := get_scope_for_log(C_VVC_NAME & "_W", GC_INSTANCE_IDX);
    constant C_CHANNEL_VVC_LABELS : t_vvc_labels := assign_vvc_labels(C_CHANNEL_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);
  begin
    -- Set the command response queue up to the same settings as the command queue
    write_data_channel_queue.set_scope(C_CHANNEL_SCOPE & ":Q");
    write_data_channel_queue.set_queue_count_max(GC_CMD_QUEUE_COUNT_MAX);
    write_data_channel_queue.set_queue_count_threshold(GC_CMD_QUEUE_COUNT_THRESHOLD);
    write_data_channel_queue.set_queue_count_threshold_severity(GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY);
    -- Wait until VVC is registered in vvc activity register in the interpreter
    wait until entry_num_in_vvc_activity_register >= 0;
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    loop
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, 0, write_data_channel_queue.is_empty(VOID), C_SCOPE);
      -- Fetch commands
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, write_data_channel_queue, vvc_config, vvc_status, write_data_channel_queue_is_increasing, write_data_channel_executor_is_busy, C_CHANNEL_VVC_LABELS, shared_msg_id_panel, ID_CHANNEL_EXECUTOR, ID_CHANNEL_EXECUTOR_WAIT);
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, 0, write_data_channel_queue.is_empty(VOID), C_SCOPE);

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel    := get_msg_id_panel(v_cmd, vvc_config);
      -- Initializing array pointers
      v_wdata_array_ptr := new t_slv_array(0 to to_integer(unsigned(v_cmd.len)))(GC_DATA_WIDTH-1 downto 0);
      v_wstrb_array_ptr := new t_slv_array(0 to to_integer(unsigned(v_cmd.len)))(GC_DATA_WIDTH/8-1 downto 0);
      v_wuser_array_ptr := new t_slv_array(0 to to_integer(unsigned(v_cmd.len)))(GC_USER_WIDTH-1 downto 0);
      for i in 0 to to_integer(unsigned(v_cmd.len)) loop
        v_wdata_array_ptr(i) := v_cmd.data_array(i)(GC_DATA_WIDTH - 1 downto 0);
        v_wstrb_array_ptr(i) := v_cmd.strb_array(i)(GC_DATA_WIDTH / 8 - 1 downto 0);
        v_wuser_array_ptr(i) := v_cmd.user_array(i)(GC_USER_WIDTH - 1 downto 0);
      end loop;
      -- Set vvc transaction info
      set_w_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_CHANNEL_SCOPE);
      -- Start transaction
      write_data_channel_write(wdata_value  => v_wdata_array_ptr.all,
                               wstrb_value  => v_wstrb_array_ptr.all,
                               wuser_value  => v_wuser_array_ptr.all,
                               awlen_value  => v_cmd.len,
                               msg          => format_msg(v_cmd),
                               clk          => clk,
                               wdata        => axi_vvc_master_if.write_data_channel.wdata,
                               wstrb        => axi_vvc_master_if.write_data_channel.wstrb,
                               wlast        => axi_vvc_master_if.write_data_channel.wlast,
                               wuser        => axi_vvc_master_if.write_data_channel.wuser,
                               wvalid       => axi_vvc_master_if.write_data_channel.wvalid,
                               wready       => axi_vvc_master_if.write_data_channel.wready,
                               scope        => C_CHANNEL_SCOPE,
                               msg_id_panel => v_msg_id_panel,
                               config       => vvc_config.bfm_config);
      deallocate(v_wdata_array_ptr);
      deallocate(v_wstrb_array_ptr);
      deallocate(v_wuser_array_ptr);

      -- Update vvc transaction info
      set_w_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_CHANNEL_SCOPE);
      -- Set vvc transaction info back to default values
      reset_w_vvc_transaction_info(vvc_transaction_info);
    end loop;
  end process write_data_channel_executor;
  --===============================================================================================

  --===============================================================================================
  -- write response channel executor
  -- - Fetch and execute the write response channel transactions
  --===============================================================================================
  write_response_channel_executor : process
    constant C_EXECUTOR_ID          : natural      := 5;
    variable v_cmd                  : t_vvc_cmd_record;
    variable v_msg_id_panel         : t_msg_id_panel;
    variable v_normalized_bid       : std_logic_vector(GC_ID_WIDTH - 1 downto 0);
    variable v_normalized_buser     : std_logic_vector(GC_USER_WIDTH - 1 downto 0);
    variable v_bid_value            : std_logic_vector(GC_ID_WIDTH - 1 downto 0);
    variable v_bresp_value          : t_xresp;
    variable v_buser_value          : std_logic_vector(GC_USER_WIDTH - 1 downto 0);
    variable v_queue_count          : integer;
    constant C_CHANNEL_SCOPE        : string       := get_scope_for_log(C_VVC_NAME & "_B", GC_INSTANCE_IDX);
    constant C_CHANNEL_VVC_LABELS   : t_vvc_labels := assign_vvc_labels(C_CHANNEL_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);
  begin
    -- Set the command response queue up to the same settings as the command queue
    write_response_channel_queue.set_scope(C_CHANNEL_SCOPE & ":Q");
    write_response_channel_queue.set_queue_count_max(GC_CMD_QUEUE_COUNT_MAX);
    write_response_channel_queue.set_queue_count_threshold(GC_CMD_QUEUE_COUNT_THRESHOLD);
    write_response_channel_queue.set_queue_count_threshold_severity(GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY);
    -- Wait until VVC is registered in vvc activity register in the interpreter
    wait until entry_num_in_vvc_activity_register >= 0;
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    loop
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, last_write_response_channel_idx_executed, write_response_channel_queue.is_empty(VOID), C_SCOPE);
      -- get a command from the queue without removing it
      peek_command_and_prepare_executor(v_cmd, write_response_channel_queue, vvc_config, vvc_status, write_response_channel_queue_is_increasing, write_response_channel_executor_is_busy, C_CHANNEL_VVC_LABELS, shared_msg_id_panel, ID_CHANNEL_EXECUTOR, ID_CHANNEL_EXECUTOR_WAIT);
      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, last_write_response_channel_idx_executed, write_response_channel_queue.is_empty(VOID), C_SCOPE);

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);
      -- Set vvc transaction info
      set_b_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_CHANNEL_SCOPE);
      -- Receiving a write response
      write_response_channel_receive(bid_value    => v_bid_value,
                                     bresp_value  => v_bresp_value,
                                     buser_value  => v_buser_value,
                                     msg          => format_msg(v_cmd),
                                     clk          => clk,
                                     bid          => axi_vvc_master_if.write_response_channel.bid,
                                     bresp        => axi_vvc_master_if.write_response_channel.bresp,
                                     buser        => axi_vvc_master_if.write_response_channel.buser,
                                     bvalid       => axi_vvc_master_if.write_response_channel.bvalid,
                                     bready       => axi_vvc_master_if.write_response_channel.bready,
                                     alert_level  => vvc_config.bfm_config.general_severity,
                                     scope        => C_CHANNEL_SCOPE,
                                     msg_id_panel => v_msg_id_panel,
                                     config       => vvc_config.bfm_config);

      -- Looking for the correct response in the queue
      if v_normalized_bid'length > 0 then
        v_queue_count := write_response_channel_queue.get_count(VOID);
        for i in 1 to v_queue_count loop
          v_cmd            := write_response_channel_queue.peek(POSITION, i);
          v_normalized_bid := normalize_and_check(v_cmd.id, v_normalized_bid, ALLOW_WIDER_NARROWER, "v_cmd.id", "v_normalized_bid", v_cmd.msg);
          if check_value(v_bid_value, v_normalized_bid, vvc_config.bfm_config.match_strictness, NO_ALERT, "Checking if the correct ID is found in the command queue", C_CHANNEL_SCOPE, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, v_msg_id_panel) then
            -- Correct ID found. We stop searching for the ID
            write_response_channel_queue.delete(POSITION, i, SINGLE);
            exit;
          elsif i = v_queue_count then
            -- We didn't find the correct BID
            alert(vvc_config.bfm_config.general_severity, "Unexpected write response with BID: " & to_string(v_bid_value), C_CHANNEL_SCOPE);
            alert(vvc_config.bfm_config.general_severity,"Removing write_response_channel_queue(" & to_string(i) & ") element", C_CHANNEL_SCOPE);
            write_response_channel_queue.delete(POSITION, i, SINGLE);
          end if;
        end loop;
      else
        -- ID have length of zero. Using first response in the queue
        v_cmd := write_response_channel_queue.get(VOID);
      end if;

      -- Checking response
      if v_normalized_bid'length > 0 then
        check_value(v_bid_value, v_normalized_bid, vvc_config.bfm_config.match_strictness, vvc_config.bfm_config.general_severity, "Checking BID value. " & add_msg_delimiter(format_msg(v_cmd)), C_CHANNEL_SCOPE, HEX, KEEP_LEADING_0, ID_POS_ACK, v_msg_id_panel);
      end if;
      if v_normalized_buser'length > 0 then
        v_normalized_buser := normalize_and_check(v_cmd.user, v_normalized_buser, ALLOW_WIDER_NARROWER, "v_cmd.user", "v_normalized_buser", v_cmd.msg);
        check_value(v_buser_value, v_normalized_buser, vvc_config.bfm_config.match_strictness, vvc_config.bfm_config.general_severity, "Checking BUSER value. " & add_msg_delimiter(format_msg(v_cmd)), C_CHANNEL_SCOPE, HEX, KEEP_LEADING_0, ID_POS_ACK, v_msg_id_panel);
      end if;
      if v_bresp_value /= v_cmd.resp then
        alert(vvc_config.bfm_config.general_severity,"Unexpected BRESP value. Was " & to_string(v_bresp_value) & ". Expected " & to_string(v_cmd.resp) ,  C_CHANNEL_SCOPE);
      end if;

      last_write_response_channel_idx_executed <= v_cmd.cmd_idx;

      -- Update vvc transaction info
      set_b_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_CHANNEL_SCOPE);
      set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_CHANNEL_SCOPE);
      -- Set vvc transaction info back to default values
      reset_b_vvc_transaction_info(vvc_transaction_info);
      reset_vvc_transaction_info(vvc_transaction_info, v_cmd);
    end loop;
  end process write_response_channel_executor;
  --===============================================================================================

  --===============================================================================================
  -- Command termination handler
  -- - Handles the termination request record (sets and resets terminate flag on request)
  --===============================================================================================
  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd); -- flag: is_active, set, reset
  --===============================================================================================

  --===============================================================================================
  -- Clock period
  -- - Finds the clock period
  --===============================================================================================
  p_clock_period : process
  begin
    wait until rising_edge(clk);
    clock_period <= now;
    wait until rising_edge(clk);
    clock_period <= now - clock_period;
    wait;
  end process;
  --===============================================================================================

  --===============================================================================================
  -- Unwanted activity detection
  -- - Monitors unwanted activity from the DUT
  --===============================================================================================
  p_unwanted_activity : process
  begin
    -- Add a delay to allow the VVC to be registered in the activity register
    wait for std.env.resolution_limit;

    loop
      -- Skip if the vvc is inactive to avoid waiting for an inactive activity register
      if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = ACTIVE then
        -- Wait until the vvc is inactive
        loop
          wait on global_trigger_vvc_activity_register;
          if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = INACTIVE then
            exit;
          end if;
        end loop;
      end if;

      -- All ready signals are not monitored. See AXI VVC QuickRef.
      wait on axi_vvc_master_if.write_response_channel.bid, axi_vvc_master_if.write_response_channel.bresp, axi_vvc_master_if.write_response_channel.buser,
              axi_vvc_master_if.write_response_channel.bvalid, axi_vvc_master_if.read_data_channel.rid, axi_vvc_master_if.read_data_channel.rdata,
              axi_vvc_master_if.read_data_channel.rresp, axi_vvc_master_if.read_data_channel.rlast, axi_vvc_master_if.read_data_channel.ruser,
              axi_vvc_master_if.read_data_channel.rvalid, global_trigger_vvc_activity_register;

      -- Check the changes on the DUT outputs only when the vvc is inactive
      if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = INACTIVE then
        -- Skip checking the changes if the bvalid signal goes low within one clock period after the VVC becomes inactive
        if not (falling_edge(axi_vvc_master_if.write_response_channel.bvalid) and global_trigger_vvc_activity_register'last_event < clock_period) then
          check_unwanted_activity(axi_vvc_master_if.write_response_channel.bvalid, vvc_config.unwanted_activity_severity, "bvalid", C_SCOPE);
          check_unwanted_activity(axi_vvc_master_if.write_response_channel.bid, vvc_config.unwanted_activity_severity, "bid", C_SCOPE);
          check_unwanted_activity(axi_vvc_master_if.write_response_channel.bresp, vvc_config.unwanted_activity_severity, "bresp", C_SCOPE);
          check_unwanted_activity(axi_vvc_master_if.write_response_channel.buser, vvc_config.unwanted_activity_severity, "buser", C_SCOPE);
        end if;

        -- Skip checking the changes if the rvalid signal goes low within one clock period after the VVC becomes inactive
        if not (falling_edge(axi_vvc_master_if.read_data_channel.rvalid) and global_trigger_vvc_activity_register'last_event < clock_period) then
          check_unwanted_activity(axi_vvc_master_if.read_data_channel.rvalid, vvc_config.unwanted_activity_severity, "rvalid", C_SCOPE);
          check_unwanted_activity(axi_vvc_master_if.read_data_channel.rid, vvc_config.unwanted_activity_severity, "rid", C_SCOPE);
          check_unwanted_activity(axi_vvc_master_if.read_data_channel.rdata, vvc_config.unwanted_activity_severity, "rdata", C_SCOPE);
          check_unwanted_activity(axi_vvc_master_if.read_data_channel.rresp, vvc_config.unwanted_activity_severity, "rresp", C_SCOPE);
          check_unwanted_activity(axi_vvc_master_if.read_data_channel.rlast, vvc_config.unwanted_activity_severity, "rlast", C_SCOPE);
          check_unwanted_activity(axi_vvc_master_if.read_data_channel.ruser, vvc_config.unwanted_activity_severity, "ruser", C_SCOPE);
        end if;
      end if;
    end loop;
  end process p_unwanted_activity;
  --===============================================================================================

end architecture behave;
