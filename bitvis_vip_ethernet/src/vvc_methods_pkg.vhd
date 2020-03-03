--================================================================================================================================
-- Copyright 2020 Bitvis
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_hvvc_to_vvc_bridge;
use bitvis_vip_hvvc_to_vvc_bridge.support_pkg.all;

use work.support_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.transaction_pkg.all;
use work.ethernet_sb_pkg.all;

library std;
use std.textio.all;

--==========================================================================================
--==========================================================================================
package vvc_methods_pkg is

  --==========================================================================================
  -- Types and constants for the ETHERNET VVC 
  --==========================================================================================
  constant C_VVC_NAME     : string := "ETHERNET_VVC";

  signal ETHERNET_VVCT    : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias  THIS_VVCT        : t_vvc_target_record is ETHERNET_VVCT;
  alias  t_bfm_config is t_ethernet_protocol_config;

  -- Type found in UVVM-Util types_pkg
  constant C_ETHERNET_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => WARNING
  );

  -- For debugging enable the rest of the msg ids in the test sequencer
  constant C_ETHERNET_VVC_MSG_ID_PANEL_DEFAULT : t_msg_id_panel := (
    ID_PACKET_INITIATE => ENABLED,
    ID_PACKET_COMPLETE => ENABLED,
    ID_PACKET_PREAMBLE => DISABLED,
    ID_PACKET_HDR      => DISABLED,
    ID_PACKET_DATA     => DISABLED,
    ID_PACKET_CHECKSUM => DISABLED,
    others             => DISABLED
  );

  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay;          -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;                    -- Maximum pending number in command executor before executor is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural;                    -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command executor exceeds this count. Used for early warning if command executor is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level;              -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold.
    result_queue_count_max                : natural;
    result_queue_count_threshold          : natural;
    result_queue_count_threshold_severity : t_alert_level;
    bfm_config                            : t_ethernet_protocol_config; -- Configuration for the VVC protocol. See VVC quick reference.
    msg_id_panel                          : t_msg_id_panel;             -- VVC dedicated message ID panel.
  end record;

  type t_vvc_config_array is array (t_channel range <>, natural range <>) of t_vvc_config;

  constant C_ETHERNET_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_ETHERNET_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    bfm_config                            => C_ETHERNET_PROTOCOL_CONFIG_DEFAULT,
    msg_id_panel                          => C_ETHERNET_VVC_MSG_ID_PANEL_DEFAULT
  );

  type t_vvc_status is
  record
    current_cmd_idx  : natural;
    previous_cmd_idx : natural;
    pending_cmd_cnt  : natural;
  end record;

  type t_vvc_status_array is array (t_channel range <>, natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx  => 0,
    previous_cmd_idx => 0,
    pending_cmd_cnt  => 0
  );

  shared variable shared_ethernet_vvc_config : t_vvc_config_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => (others => C_ETHERNET_VVC_CONFIG_DEFAULT));
  shared variable shared_ethernet_vvc_status : t_vvc_status_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => (others => C_VVC_STATUS_DEFAULT));
  shared variable shared_ethernet_sb         : t_generic_sb; -- Scoreboard


  --==========================================================================================
  -- Methods dedicated to this VVC 
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --==========================================================================================
  procedure ethernet_transmit(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant mac_source                : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_transmit(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_transmit(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_receive(
    signal   VVCT                       : inout t_vvc_target_record;
    constant vvc_instance_idx           : in    integer;
    constant channel                    : in    t_channel;
    constant msg                        : in    string;
    constant data_routing               : in    t_data_routing              := TO_RECEIVE_BUFFER;
    constant scope                      : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel  : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel               : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant mac_source                : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  --==========================================================================================
  -- Methods calling the HVVC-to-VVC bridge (for internal HVVC use)
  -- - These procedures are called from the HVVC to execute calls to the HVVC-to-VVC bridge.
  --   The bridge will then transfer the calls to the VVC in the physical layer which will
  --   execute the data transactions.
  --==========================================================================================
  procedure priv_ethernet_transmit_to_bridge(
    constant interpacket_gap_time : in    time;
    constant vvc_cmd              : in    t_vvc_cmd_record;
    constant dut_if_field_config  : in    t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : out   t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in    t_bridge_to_hvvc;
    variable dtt_info             : inout t_transaction_group;
    constant scope                : in    string;
    constant msg_id_panel         : in    t_msg_id_panel
  );

  procedure priv_ethernet_receive_from_bridge(
    variable received_frame       : out   t_ethernet_frame;
    variable fcs_error            : out   boolean;
    constant fcs_error_severity   : in    t_alert_level;
    constant vvc_cmd              : in    t_vvc_cmd_record;
    constant dut_if_field_config  : in    t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : out   t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in    t_bridge_to_hvvc;
    variable dtt_info             : inout t_transaction_group;
    constant scope                : in    string;
    constant msg_id_panel         : in    t_msg_id_panel;
    constant ext_proc_call        : in    string := "" -- External proc_call. Overwrite if called from another procedure
  );

  procedure priv_ethernet_expect_from_bridge(
    constant fcs_error_severity   : in    t_alert_level;
    constant vvc_cmd              : in    t_vvc_cmd_record;
    constant dut_if_field_config  : in    t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : out   t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in    t_bridge_to_hvvc;
    variable dtt_info             : inout t_transaction_group;
    constant scope                : in    string;
    constant msg_id_panel         : in    t_msg_id_panel
  );

  --==============================================================================
  -- Direct Transaction Transfer methods
  --==============================================================================
  procedure set_global_dtt(
    signal dtt_trigger    : inout std_logic;
    variable dtt_group    : inout t_transaction_group;
    constant vvc_cmd      : in t_vvc_cmd_record;
    constant vvc_config   : in t_vvc_config;
    constant scope        : in string := C_VVC_CMD_SCOPE_DEFAULT);

  procedure reset_dtt_info(
    variable dtt_group    : inout t_transaction_group;
    constant vvc_cmd      : in t_vvc_cmd_record);

  --==============================================================================
  -- Activity Watchdog
  --==============================================================================
  procedure activity_watchdog_register_vvc_state( signal   global_trigger_activity_watchdog : inout std_logic;
                                                  constant busy                             : in boolean;
                                                  constant vvc_idx_for_activity_watchdog    : in integer;
                                                  constant last_cmd_idx_executed            : in natural;
                                                  constant scope                            : in string := "ETHERNET_VVC");

end package vvc_methods_pkg;


package body vvc_methods_pkg is

  --==========================================================================================
  -- Methods dedicated to this VVC
  --==========================================================================================
  procedure ethernet_transmit(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant mac_source                : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
    constant proc_name : string := "ethernet_transmit";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel)  -- First part common for all
        & ", MAC dest: " & to_string(mac_destination, HEX, AS_IS, INCL_RADIX)
        & ", MAC src: " & to_string(mac_source, HEX, AS_IS, INCL_RADIX)
        & ", length: " & to_string(payload'length) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, TRANSMIT);
    shared_vvc_cmd.mac_destination                := mac_destination;
    shared_vvc_cmd.mac_source                     := mac_source;
    shared_vvc_cmd.length                         := payload'length;
    shared_vvc_cmd.payload(0 to payload'length-1) := payload;
    --shared_vvc_cmd.use_provided_msg_id_panel      := use_provided_msg_id_panel;
    --shared_vvc_cmd.msg_id_panel                   := msg_id_panel;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, msg_id_panel);
  end procedure ethernet_transmit;

  procedure ethernet_transmit(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
  begin
    ethernet_transmit(VVCT, vvc_instance_idx, channel, mac_destination,
      shared_ethernet_vvc_config(channel,vvc_instance_idx).bfm_config.mac_source, payload, msg, scope, use_provided_msg_id_panel, msg_id_panel);
  end procedure ethernet_transmit;

  procedure ethernet_transmit(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
  begin
    ethernet_transmit(VVCT, vvc_instance_idx, channel, shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_destination,
      shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_source, payload, msg, scope, use_provided_msg_id_panel, msg_id_panel);
  end procedure ethernet_transmit;


  procedure ethernet_receive(
    signal   VVCT                       : inout t_vvc_target_record;
    constant vvc_instance_idx           : in    integer;
    constant channel                    : in    t_channel;
    constant msg                        : in    string;
    constant data_routing               : in    t_data_routing              := TO_RECEIVE_BUFFER;
    constant scope                      : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel  : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel               : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
    constant proc_name : string := "ethernet_receive";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, RECEIVE);
    shared_vvc_cmd.data_routing               := data_routing;
    --shared_vvc_cmd.use_provided_msg_id_panel  := use_provided_msg_id_panel;
    --shared_vvc_cmd.msg_id_panel               := msg_id_panel;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, msg_id_panel);
  end procedure ethernet_receive;

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant mac_source                : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
    constant proc_name : string := "ethernet_expect";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel)  -- First part common for all
        & ", MAC dest: " & to_string(mac_destination, HEX, AS_IS, INCL_RADIX)
        & ", MAC src: " & to_string(mac_source, HEX, AS_IS, INCL_RADIX)
        & ", length: " & to_string(payload'length) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, EXPECT);
    shared_vvc_cmd.mac_destination                := mac_destination;
    shared_vvc_cmd.mac_source                     := mac_source;
    shared_vvc_cmd.length                         := payload'length;
    shared_vvc_cmd.payload(0 to payload'length-1) := payload;
    shared_vvc_cmd.alert_level                    := alert_level;
    --shared_vvc_cmd.use_provided_msg_id_panel      := use_provided_msg_id_panel;
    --shared_vvc_cmd.msg_id_panel                   := msg_id_panel;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, msg_id_panel);
  end procedure ethernet_expect;

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
  begin
    ethernet_expect(VVCT, vvc_instance_idx, channel, mac_destination,
      shared_ethernet_vvc_config(channel,vvc_instance_idx).bfm_config.mac_destination, payload, msg, alert_level, scope, use_provided_msg_id_panel, msg_id_panel);
  end procedure ethernet_expect;

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
  begin
    ethernet_expect(VVCT, vvc_instance_idx, channel, shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_source,
      shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_destination, payload, msg, alert_level, scope, use_provided_msg_id_panel, msg_id_panel);
  end procedure ethernet_expect;

  --==========================================================================================
  -- Methods calling the HVVC-to-VVC bridge (for internal HVVC use)
  --==========================================================================================
  procedure priv_ethernet_transmit_to_bridge(
    constant interpacket_gap_time : in    time;
    constant vvc_cmd              : in    t_vvc_cmd_record;
    constant dut_if_field_config  : in    t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : out   t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in    t_bridge_to_hvvc;
    variable dtt_info             : inout t_transaction_group;
    constant scope                : in    string;
    constant msg_id_panel         : in    t_msg_id_panel
  ) is
    constant proc_name : string := "ethernet_transmit";
    constant proc_call : string := proc_name
        & "(MAC dest: " & to_string(vvc_cmd.mac_destination, HEX, AS_IS, INCL_RADIX)
        & ", MAC src: " & to_string(vvc_cmd.mac_source, HEX, AS_IS, INCL_RADIX)
        & ", length: " & to_string(vvc_cmd.length) & ")";
    variable v_packet             : t_byte_array(0 to C_MAX_PACKET_LENGTH-1);
    variable v_frame              : t_ethernet_frame;
    variable v_payload_length     : natural;
    variable v_payload_length_slv : std_logic_vector(15 downto 0);
    variable v_crc_32             : std_logic_vector(31 downto 0);
    variable v_preamble_sfd_valid : boolean;
    variable v_mac_dest_valid     : boolean;
    variable v_mac_source_valid   : boolean;
    variable v_length_valid       : boolean;
    variable v_payload_valid      : boolean;
    variable v_fcs_valid          : boolean;
  begin
    -- Preamble
    for i in 0 to 6 loop
      v_packet(i) := C_PREAMBLE(55-(i*8) downto 55-(i*8)-7);     --|ET: Why reverse from standard? 10101010 MSb first.
    end loop;
    -- SFD
    v_packet(7) := C_SFD;
    -- MAC destination
    v_packet(8 to 13)       := to_byte_array(std_logic_vector(vvc_cmd.mac_destination)); --|ET: Hvordan vet vi at dette blir riktig?  msB->lowB=LeftB
    v_frame.mac_destination := vvc_cmd.mac_destination;
    -- MAC source
    v_packet(14 to 19) := to_byte_array(std_logic_vector(vvc_cmd.mac_source));
    v_frame.mac_source := vvc_cmd.mac_source;
    -- Length
    v_payload_length     := vvc_cmd.length;
    v_payload_length_slv := std_logic_vector(to_unsigned(vvc_cmd.length, 16));
    v_packet(20)         := v_payload_length_slv(15 downto 8);
    v_packet(21)         := v_payload_length_slv(7 downto 0);
    v_frame.length       := vvc_cmd.length;
    -- Payload
    v_packet(22 to 22+vvc_cmd.length-1) := vvc_cmd.payload(0 to vvc_cmd.length-1);
    v_frame.payload := vvc_cmd.payload;
    -- Pad if length is less than C_MIN_PAYLOAD_LENGTH(46)
    if vvc_cmd.length < C_MIN_PAYLOAD_LENGTH then
      v_payload_length := C_MIN_PAYLOAD_LENGTH;
      v_packet(22+vvc_cmd.length to 22+v_payload_length) := (others => (others => '0'));
    end if;
    -- FCS
    v_crc_32 := generate_crc_32(reverse_vectors_in_array(v_packet(8 to 22+v_payload_length-1)));  --|ET:Complete? Vectors? (=bytes?)
    v_crc_32 := not(v_crc_32);                                                                                          --|ET: Because
    v_packet(22+v_payload_length to 22+v_payload_length+3) := reverse_vectors_in_array(to_byte_array(v_crc_32));
    v_frame.fcs := v_crc_32;

    -- Add info to the DTT
    dtt_info.bt.ethernet_frame.fcs := v_crc_32;

    -- Check which fields are configured as valid
    v_preamble_sfd_valid := true when C_ETHERNET_FIELD_IDX_PREAMBLE_SFD > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_PREAMBLE_SFD).field_valid;
    v_mac_dest_valid     := true when C_ETHERNET_FIELD_IDX_MAC_DESTINATION > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_MAC_DESTINATION).field_valid;
    v_mac_source_valid   := true when C_ETHERNET_FIELD_IDX_MAC_SOURCE > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_MAC_SOURCE).field_valid;
    v_length_valid       := true when C_ETHERNET_FIELD_IDX_LENGTH > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_LENGTH).field_valid;
    v_payload_valid      := true when C_ETHERNET_FIELD_IDX_PAYLOAD > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_PAYLOAD).field_valid;
    v_fcs_valid          := true when C_ETHERNET_FIELD_IDX_FCS > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_FCS).field_valid;

    log(ID_PACKET_INITIATE, proc_call & ". Start transmitting packet. " & add_msg_delimiter(vvc_cmd.msg) & 
      format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);

    -- Send only valid configured fields to the bridge
    if v_preamble_sfd_valid then
      log(ID_PACKET_PREAMBLE, proc_call & ". Transmitting preamble. " & add_msg_delimiter(vvc_cmd.msg) &
        format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, TRANSMIT, v_packet(0 to 7),
        C_ETHERNET_FIELD_IDX_PREAMBLE_SFD, msg_id_panel);
    end if;
    if v_mac_dest_valid or v_mac_source_valid or v_length_valid then
      log(ID_PACKET_HDR, proc_call & ". Transmitting header. " & add_msg_delimiter(vvc_cmd.msg) &
        format_command_idx(vvc_cmd.cmd_idx) & to_string(v_frame, HEADER), scope, msg_id_panel);
    end if;
    if v_mac_dest_valid then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, TRANSMIT, v_packet(8 to 13),
        C_ETHERNET_FIELD_IDX_MAC_DESTINATION, msg_id_panel);
    end if;
    if v_mac_source_valid then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, TRANSMIT, v_packet(14 to 19),
        C_ETHERNET_FIELD_IDX_MAC_SOURCE, msg_id_panel);
    end if;
    if v_length_valid then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, TRANSMIT, v_packet(20 to 21),
        C_ETHERNET_FIELD_IDX_LENGTH, msg_id_panel);
    end if;
    if v_payload_valid then
      log(ID_PACKET_DATA, proc_call & ". Transmitting payload. " & add_msg_delimiter(vvc_cmd.msg) &
        format_command_idx(vvc_cmd.cmd_idx) & to_string(v_frame, PAYLOAD), scope, msg_id_panel);
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, TRANSMIT, v_packet(22 to 22+v_payload_length-1),
        C_ETHERNET_FIELD_IDX_PAYLOAD, msg_id_panel);
    end if;
    if v_fcs_valid then
      log(ID_PACKET_CHECKSUM, proc_call & ". Transmitting FCS. " & add_msg_delimiter(vvc_cmd.msg) &
        format_command_idx(vvc_cmd.cmd_idx) & to_string(v_frame, CHECKSUM), scope, msg_id_panel);
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, TRANSMIT, v_packet(22+v_payload_length to 22+v_payload_length+3),
        C_ETHERNET_FIELD_IDX_FCS, msg_id_panel);
    end if;

    -- Interpacket gap
    wait for interpacket_gap_time;

    log(ID_PACKET_COMPLETE, proc_call & ". Finished transmitting packet. " & add_msg_delimiter(vvc_cmd.msg) &
      format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
  end procedure priv_ethernet_transmit_to_bridge;

--|ET: Skal vel ikke sende annet enn frame (ikke packet) dersom det sendes til en SBI el.l.?  

  procedure priv_ethernet_receive_from_bridge(
    variable received_frame       : out   t_ethernet_frame;
    variable fcs_error            : out   boolean;
    constant fcs_error_severity   : in    t_alert_level;
    constant vvc_cmd              : in    t_vvc_cmd_record;
    constant dut_if_field_config  : in    t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : out   t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in    t_bridge_to_hvvc;
    variable dtt_info             : inout t_transaction_group;
    constant scope                : in    string;
    constant msg_id_panel         : in    t_msg_id_panel;
    constant ext_proc_call        : in    string := "" -- External proc_call. Overwrite if called from another procedure
  ) is
    constant local_proc_name : string := "ethernet_receive";
    constant local_proc_call : string := local_proc_name & "()";
    variable v_preamble_sfd       : std_logic_vector(63 downto 0) := (others => '0');   --|ET: preamble_and_sfd ?
    variable v_packet             : t_byte_array(0 to C_MAX_PACKET_LENGTH-1);
    variable v_payload_length     : integer;
    variable v_proc_call          : line; -- Current proc_call, external or local
    variable v_preamble_sfd_valid : boolean;
    variable v_mac_dest_valid     : boolean;
    variable v_mac_source_valid   : boolean;
    variable v_length_valid       : boolean;
    variable v_payload_valid      : boolean;
    variable v_fcs_valid          : boolean;
  begin
    -- Choose which procedure call to use (local or external)
    if ext_proc_call = "" then
      write(v_proc_call, local_proc_call);
    else
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    received_frame := C_ETHERNET_FRAME_DEFAULT;

    -- Check which fields are configured as valid
    v_preamble_sfd_valid := true when C_ETHERNET_FIELD_IDX_PREAMBLE_SFD > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_PREAMBLE_SFD).field_valid;
    v_mac_dest_valid     := true when C_ETHERNET_FIELD_IDX_MAC_DESTINATION > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_MAC_DESTINATION).field_valid;
    v_mac_source_valid   := true when C_ETHERNET_FIELD_IDX_MAC_SOURCE > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_MAC_SOURCE).field_valid;
    v_length_valid       := true when C_ETHERNET_FIELD_IDX_LENGTH > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_LENGTH).field_valid;
    v_payload_valid      := true when C_ETHERNET_FIELD_IDX_PAYLOAD > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_PAYLOAD).field_valid;
    v_fcs_valid          := true when C_ETHERNET_FIELD_IDX_FCS > dut_if_field_config'high else
                            dut_if_field_config(C_ETHERNET_FIELD_IDX_FCS).field_valid;

    log(ID_PACKET_INITIATE, v_proc_call.all & ". Waiting for packet. " & add_msg_delimiter(vvc_cmd.msg) & 
      format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);

    -- Await preamble and SFD
    if v_preamble_sfd_valid then
      while true loop
        -- Fetch one byte at the time until SFD is found
        blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, RECEIVE, 1, C_ETHERNET_FIELD_IDX_PREAMBLE_SFD, msg_id_panel);
        v_preamble_sfd   := v_preamble_sfd(55 downto 0) & bridge_to_hvvc.data_words(0);
        v_packet(1 to 7) := v_packet(0 to 6);
        v_packet(0)      := bridge_to_hvvc.data_words(0);
        if v_preamble_sfd = C_PREAMBLE & C_SFD then
          exit;
        end if;
      end loop;
      log(ID_PACKET_PREAMBLE, v_proc_call.all & ". Preamble received. " & add_msg_delimiter(vvc_cmd.msg) & 
        format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
    end if;

    -- Read MAC destination from bridge
    if v_mac_dest_valid then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, RECEIVE, 6, C_ETHERNET_FIELD_IDX_MAC_DESTINATION, msg_id_panel);
      v_packet(8 to 13)              := bridge_to_hvvc.data_words(0 to 5);
      received_frame.mac_destination := unsigned(to_slv(v_packet( 8 to 13)));
      -- Add info to the DTT
      dtt_info.bt.ethernet_frame.mac_destination := received_frame.mac_destination;
    end if;

    -- Read MAC source from bridge
    if v_mac_source_valid then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, RECEIVE, 6, C_ETHERNET_FIELD_IDX_MAC_SOURCE, msg_id_panel);
      v_packet(14 to 19)        := bridge_to_hvvc.data_words(0 to 5);
      received_frame.mac_source := unsigned(to_slv(v_packet(14 to 19)));
      -- Add info to the DTT
      dtt_info.bt.ethernet_frame.mac_source := received_frame.mac_source;
    end if;

    -- Read length from bridge
    if v_length_valid then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, RECEIVE, 2, C_ETHERNET_FIELD_IDX_LENGTH, msg_id_panel);
      v_packet(20 to 21)    := bridge_to_hvvc.data_words(0 to 1);
      received_frame.length := to_integer(unsigned(to_slv(v_packet(20 to 21))));
      -- Add info to the DTT
      dtt_info.bt.ethernet_frame.length := received_frame.length;
      log(ID_PACKET_HDR, v_proc_call.all & ". Header received. " & add_msg_delimiter(vvc_cmd.msg) & 
        format_command_idx(vvc_cmd.cmd_idx) & to_string(received_frame, HEADER), scope, msg_id_panel);
    end if;

    -- Check length and if payload is padded
    if received_frame.length > C_MAX_PAYLOAD_LENGTH then
      alert(ERROR, "Payload is larger than maximum alowed length, " & to_string(C_MAX_PAYLOAD_LENGTH) & " octets (bytes).", scope);
    end if;
    if received_frame.length < C_MIN_PAYLOAD_LENGTH then
      v_payload_length := C_MIN_PAYLOAD_LENGTH;
    else
      v_payload_length := received_frame.length;
    end if;

    -- Read payload from bridge
    if v_payload_valid then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, RECEIVE, v_payload_length, C_ETHERNET_FIELD_IDX_PAYLOAD, msg_id_panel);
      v_packet(22 to 22+v_payload_length-1)           := bridge_to_hvvc.data_words(0 to v_payload_length-1);
      received_frame.payload                          := (others => (others => '-')); -- Riviera pro don't allow non-static and others in aggregates
      received_frame.payload(0 to v_payload_length-1) := v_packet(22 to 22+v_payload_length-1);
      -- Add info to the DTT
      dtt_info.bt.ethernet_frame.payload := received_frame.payload;
      log(ID_PACKET_DATA, v_proc_call.all & ". Payload received. " & add_msg_delimiter(vvc_cmd.msg) & 
        format_command_idx(vvc_cmd.cmd_idx) & to_string(received_frame, PAYLOAD), scope, msg_id_panel);
    end if;

    -- Read FCS from bridge
    if v_fcs_valid then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, RECEIVE, 4, C_ETHERNET_FIELD_IDX_FCS, msg_id_panel);
      v_packet(22+v_payload_length to 22+v_payload_length+4-1) := bridge_to_hvvc.data_words(0 to 3);
      received_frame.fcs := to_slv(reverse_vectors_in_array(v_packet(22+v_payload_length to 22+v_payload_length+4-1)));
      -- Add info to the DTT
      dtt_info.bt.ethernet_frame.fcs := received_frame.fcs;
      log(ID_PACKET_CHECKSUM, v_proc_call.all & ". FCS received. " & add_msg_delimiter(vvc_cmd.msg) & 
        format_command_idx(vvc_cmd.cmd_idx) & to_string(received_frame, CHECKSUM), scope, msg_id_panel);

      fcs_error := not check_crc_32(reverse_vectors_in_array(v_packet(8 to 22+v_payload_length+4-1)));
      check_value(fcs_error, false, fcs_error_severity, "Check FCS value", scope, ID_NEVER, msg_id_panel);
    end if;

    log(ID_PACKET_COMPLETE, v_proc_call.all & ". Finished receiving packet. " & add_msg_delimiter(vvc_cmd.msg) &
      format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
  end procedure priv_ethernet_receive_from_bridge;

  procedure priv_ethernet_expect_from_bridge(
    constant fcs_error_severity   : in    t_alert_level;
    constant vvc_cmd              : in    t_vvc_cmd_record;
    constant dut_if_field_config  : in    t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : out   t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in    t_bridge_to_hvvc;
    variable dtt_info             : inout t_transaction_group;
    constant scope                : in    string;
    constant msg_id_panel         : in    t_msg_id_panel
  ) is
    constant proc_name : string := "ethernet_expect";
    constant proc_call : string := proc_name
        & "(MAC dest: " & to_string(vvc_cmd.mac_destination, HEX, AS_IS, INCL_RADIX)
        & ", MAC src: " & to_string(vvc_cmd.mac_source, HEX, AS_IS, INCL_RADIX)
        & ", length: " & to_string(vvc_cmd.length) & ")";
    variable v_packet         : t_byte_array(0 to C_MAX_PACKET_LENGTH-1);
    variable v_payload_length : integer;
    variable v_expected_frame : t_ethernet_frame;
    variable v_received_frame : t_ethernet_frame;
    variable v_fcs_error      : boolean;
    variable v_frame_passed   : boolean;
  begin
    -- For FCS calculation
    v_packet( 8 to 13)                  := to_byte_array(std_logic_vector(vvc_cmd.mac_destination));
    v_packet(14 to 19)                  := to_byte_array(std_logic_vector(vvc_cmd.mac_source));
    v_packet(20 to 21)                  := to_byte_array(std_logic_vector(to_unsigned(vvc_cmd.length, 16)));
    v_packet(22 to 22+vvc_cmd.length-1) := vvc_cmd.payload(0 to vvc_cmd.length-1);
    if vvc_cmd.length < C_MIN_PAYLOAD_LENGTH then
      v_payload_length := C_MIN_PAYLOAD_LENGTH;
      v_packet(22+vvc_cmd.length to 22+v_payload_length) := (others => (others => '0'));
    else
      v_payload_length := vvc_cmd.length;
    end if;

    v_expected_frame                 := C_ETHERNET_FRAME_DEFAULT;
    v_expected_frame.mac_destination := vvc_cmd.mac_destination;
    v_expected_frame.mac_source      := vvc_cmd.mac_source;
    v_expected_frame.length          := vvc_cmd.length;
    v_expected_frame.payload         := vvc_cmd.payload;
    v_expected_frame.fcs             := not generate_crc_32(reverse_vectors_in_array(v_packet(8 to 22+v_payload_length-1)));

    -- Add info to the DTT
    dtt_info.bt.ethernet_frame.fcs := v_expected_frame.fcs;

    -- Receive frame
    priv_ethernet_receive_from_bridge(received_frame       => v_received_frame,
                                      fcs_error            => v_fcs_error,
                                      fcs_error_severity   => fcs_error_severity,
                                      vvc_cmd              => vvc_cmd,
                                      dut_if_field_config  => dut_if_field_config,
                                      hvvc_to_bridge       => hvvc_to_bridge,
                                      bridge_to_hvvc       => bridge_to_hvvc,
                                      dtt_info             => dtt_info,
                                      scope                => scope,
                                      msg_id_panel         => msg_id_panel,
                                      ext_proc_call        => proc_call);

    -- Check received frame against expected frame
    v_frame_passed := compare_ethernet_frames(v_received_frame, v_expected_frame, vvc_cmd.alert_level,
      add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel, proc_call);

    if v_frame_passed then
      log(ID_PACKET_COMPLETE, proc_call & " => OK. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
    end if;
  end procedure priv_ethernet_expect_from_bridge;

  --==============================================================================
  -- Direct Transaction Transfer methods
  --==============================================================================
  procedure set_global_dtt(
    signal dtt_trigger    : inout std_logic;
    variable dtt_group    : inout t_transaction_group;
    constant vvc_cmd      : in t_vvc_cmd_record;
    constant vvc_config   : in t_vvc_config;
    constant scope        : in string := C_VVC_CMD_SCOPE_DEFAULT) is
  begin
    case vvc_cmd.operation is
      when TRANSMIT | RECEIVE | EXPECT =>
        dtt_group.bt.operation                              := vvc_cmd.operation;
        dtt_group.bt.ethernet_frame.mac_destination         := vvc_cmd.mac_destination;
        dtt_group.bt.ethernet_frame.mac_source              := vvc_cmd.mac_source;
        dtt_group.bt.ethernet_frame.length                  := vvc_cmd.length;
        dtt_group.bt.ethernet_frame.payload                 := vvc_cmd.payload;
        dtt_group.bt.vvc_meta.msg(1 to vvc_cmd.msg'length)  := vvc_cmd.msg;
        dtt_group.bt.vvc_meta.cmd_idx                       := vvc_cmd.cmd_idx;
        dtt_group.bt.transaction_status                     := IN_PROGRESS;
        gen_pulse(dtt_trigger, 0 ns, "pulsing global DTT trigger", scope, ID_NEVER);
      when others =>
        alert(TB_ERROR, "VVC operation not recognized");
    end case;

    wait for 0 ns;
  end procedure set_global_dtt;

  procedure reset_dtt_info(
    variable dtt_group    : inout t_transaction_group;
    constant vvc_cmd      : in t_vvc_cmd_record) is
  begin
    case vvc_cmd.operation is
      when TRANSMIT | RECEIVE | EXPECT =>
        dtt_group.bt := C_TRANSACTION_SET_DEFAULT;
      when others =>
        null;
    end case;

    wait for 0 ns;
  end procedure reset_dtt_info;

  --==============================================================================
  -- Activity Watchdog
  --==============================================================================
  procedure activity_watchdog_register_vvc_state( signal   global_trigger_activity_watchdog : inout std_logic;
                                                  constant busy                             : in boolean;
                                                  constant vvc_idx_for_activity_watchdog    : in integer;
                                                  constant last_cmd_idx_executed            : in natural;
                                                  constant scope                            : in string := "ETHERNET_VVC") is
  begin
    shared_activity_watchdog.priv_report_vvc_activity(vvc_idx               => vvc_idx_for_activity_watchdog,
                                                      busy                  => busy,
                                                      last_cmd_idx_executed => last_cmd_idx_executed);
    gen_pulse(global_trigger_activity_watchdog, 0 ns, "pulsing global trigger for activity watchdog", scope, ID_NEVER);
  end procedure;

end package body vvc_methods_pkg;