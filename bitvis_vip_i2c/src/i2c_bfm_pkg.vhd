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
--
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================
package i2c_bfm_pkg is

  --===============================================================================================
  -- Types and constants for I2C BFMs
  --===============================================================================================
  constant C_BFM_SCOPE     : string    := "I2C BFM";
  constant C_READ_BIT  : std_logic := '1';
  constant C_WRITE_BIT : std_logic := '0';

  type t_i2c_if is record
    scl : std_logic;                    -- clock
    sda : std_logic;                    -- data
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_i2c_bfm_config is record
    enable_10_bits_addressing       : boolean; -- true: 10-bit addressing enabled, false : 7-bit addressing enabled
    master_sda_to_scl               : time; -- Used in master mode, start condition. From sda active to scl active.
    master_scl_to_sda               : time; -- Used in master mode, stop condition. From scl inactive to sda inactive.
    master_stop_condition_hold_time : time; -- Used in master methods for holding the stop condition. Ensures that the master holds the stop condition for a certain amount of time before the next operation is started.
    max_wait_scl_change             : time; -- Used as timeout when checking the SCL active period.
    max_wait_scl_change_severity    : t_alert_level; -- The above timeout will have this severity.
    max_wait_sda_change             : time; -- Used when receiving and in slave transmit.
    max_wait_sda_change_severity    : t_alert_level; -- The above timeout will have this severity.
    i2c_bit_time                    : time; -- The bit period.
    i2c_bit_time_severity           : t_alert_level; -- A master method will report an alert with this severity if a slave performs clock stretching for longer than i2c_bit_time.
    acknowledge_severity            : t_alert_level; -- Severity if message not acknowledged
    slave_mode_address              : unsigned(9 downto 0); -- The slave methods expect to receive this address from the I2C master DUT.
    slave_mode_address_severity     : t_alert_level; -- The methods will report an alert with this severity if the address format is wrong or the address is not as expected.
    slave_rw_bit_severity           : t_alert_level; -- The methods will report an alert with this severity if the Read/Write bit is not as expected.
    reserved_address_severity       : t_alert_level; -- The methods will trigger an alert with this severity if the slave address is equal to one of the reserved addresses from the NXP I2C Specification. For a list of reserved addresses, please see the document referred to in section 3.
    match_strictness                : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    id_for_bfm                      : t_msg_id; -- The message ID used as a general message ID in the I2C BFM.
    id_for_bfm_wait                 : t_msg_id; -- The message ID used for logging waits in the I2C BFM.
    id_for_bfm_poll                 : t_msg_id; -- The message ID used for logging polling in the I2C BFM.
  end record;

  constant C_I2C_BFM_CONFIG_DEFAULT : t_i2c_bfm_config := (
    enable_10_bits_addressing       => false,
    master_sda_to_scl               => 20 ns,
    master_scl_to_sda               => 20 ns,
    master_stop_condition_hold_time => 20 ns,
    max_wait_scl_change             => 10 ms,
    max_wait_scl_change_severity    => failure,
    max_wait_sda_change             => 10 ms,
    max_wait_sda_change_severity    => failure,
    i2c_bit_time                    => -1 ns,
    i2c_bit_time_severity           => failure,
    acknowledge_severity            => failure,
    slave_mode_address              => "0000000000",
    slave_mode_address_severity     => failure,
    slave_rw_bit_severity           => failure,
    reserved_address_severity       => warning,
    match_strictness                => MATCH_EXACT,
    id_for_bfm                      => ID_BFM,
    id_for_bfm_wait                 => ID_BFM_WAIT,
    id_for_bfm_poll                 => ID_BFM_POLL
  );

  --===============================================================================================
  -- BFM procedures
  --===============================================================================================

  ------------------------------------------
  -- init_i2c_if_signals
  ------------------------------------------
  -- This function returns an I2C interface with initialized signals.
  -- All I2C signals are initialized to Z
  function init_i2c_if_signals(
    constant VOID : in t_void
  ) return t_i2c_if;

  ------------------------------------------
  -- i2c_master_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C slave DUT
  -- at address 'addr_value'.
  procedure i2c_master_transmit(
    constant addr_value                   : in unsigned;
    constant data                         : in t_byte_array;
    constant msg                          : in string;
    signal   scl                          : inout std_logic;
    signal   sda                          : inout std_logic;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_master_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C slave DUT
  -- at address 'addr_value'.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_transmit(
    constant addr_value                   : in unsigned;
    constant data                         : in t_byte_array;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_master_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C slave DUT
  -- at address 'addr_value'.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_transmit(
    constant addr_value                   : in unsigned;
    constant data                         : in std_logic_vector;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_slave_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C master DUT.
  procedure i2c_slave_transmit(
    constant data         : in t_byte_array;
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_slave_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C master DUT.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_transmit(
    constant data         : in t_byte_array;
    constant msg          : in string;
    signal   i2c_if       : inout t_i2c_if;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_slave_transmit
  ------------------------------------------
  -- This procedure transmits data 'data' to an I2C master DUT.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_transmit(
    constant data         : in std_logic_vector;
    constant msg          : in string;
    signal   i2c_if       : inout t_i2c_if;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_master_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C slave DUT
  -- at address 'addr_value'.
  procedure i2c_master_receive(
    constant addr_value                   : in unsigned;
    variable data                         : out t_byte_array;
    constant msg                          : in string;
    signal   scl                          : inout std_logic;
    signal   sda                          : inout std_logic;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in string                         := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- i2c_master_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C slave DUT
  -- at address 'addr_value'.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_receive(
    constant addr_value                   : in unsigned;
    variable data                         : out t_byte_array;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in string                         := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- i2c_master_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C slave DUT
  -- at address 'addr_value'.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_receive(
    constant addr_value                   : in unsigned;
    variable data                         : out std_logic_vector;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in string                         := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- i2c_slave_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C master DUT.
  -- at address 'addr_value'.
  procedure i2c_slave_receive(
    variable data          : out t_byte_array;
    constant msg           : in string;
    signal   scl           : inout std_logic;
    signal   sda           : inout std_logic;
    constant exp_rw_bit    : in std_logic        := C_WRITE_BIT;
    constant scope         : in string           := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- i2c_slave_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C master DUT.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_receive(
    variable data          : out t_byte_array;
    constant msg           : in string;
    signal   i2c_if        : inout t_i2c_if;
    constant scope         : in string           := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- i2c_slave_receive
  ------------------------------------------
  -- This procedure receives data 'data' from an I2C master DUT.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_receive(
    variable data          : out std_logic_vector;
    constant msg           : in string;
    signal   i2c_if        : inout t_i2c_if;
    constant scope         : in string           := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- i2c_master_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C slave DUT at address
  -- 'addr_value', and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as individual signals
  procedure i2c_master_check(
    constant addr_value                   : in unsigned;
    constant data_exp                     : in t_byte_array;
    constant msg                          : in string;
    signal   scl                          : inout std_logic;
    signal   sda                          : inout std_logic;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_master_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C slave DUT at address
  -- 'addr_value', and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_check(
    constant addr_value                   : in unsigned;
    constant data_exp                     : in t_byte_array;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_master_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C slave DUT at address
  -- 'addr_value', and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_master_check(
    constant addr_value                   : in unsigned;
    constant data_exp                     : in std_logic_vector;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_slave_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C master DUT,
  -- and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as individual signals
  procedure i2c_slave_check(
    constant data_exp     : in t_byte_array;
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant exp_rw_bit   : in std_logic        := C_WRITE_BIT;
    constant alert_level  : in t_alert_level    := error;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_slave_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C master DUT,
  -- and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_check(
    constant data_exp     : in t_byte_array;
    constant msg          : in string;
    signal   i2c_if       : inout t_i2c_if;
    constant exp_rw_bit   : in std_logic        := C_WRITE_BIT;
    constant alert_level  : in t_alert_level    := error;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- i2c_slave_check
  ------------------------------------------
  -- This procedure receives an I2C transaction from an I2C master DUT,
  -- and compares the read data to the expected data in 'data_exp'.
  -- If the read data is inconsistent with the expected data, an alert with
  -- severity 'alert_level' is triggered.
  -- The I2C interface in this procedure is given as a t_i2c_if signal record
  procedure i2c_slave_check(
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   i2c_if       : inout t_i2c_if;
    constant exp_rw_bit   : in std_logic        := C_WRITE_BIT;
    constant alert_level  : in t_alert_level    := error;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  );

  procedure i2c_master_quick_command(
    constant addr_value                   : in unsigned;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant rw_bit                       : in std_logic                      := C_WRITE_BIT;
    constant exp_ack                      : in boolean                        := true;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  );

end package i2c_bfm_pkg;

--=================================================================================================
--=================================================================================================

package body i2c_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- check slave address
  --
  -- Compares slave address with known reserved addresses and triggers an alert
  -- if equal. Input is a slave address, either 7-bit or 10-bit. Make sure that
  -- the correct length address is input to this procedure, i.e., that a 10-bit
  -- value is not sent in when the BFM is in 7-bit address mode.
  ---------------------------------------------------------------------------------

  procedure i2c_check_slave_addr(
    constant addr_value  : in unsigned;
    constant alert_level : t_alert_level;
    constant scope       : in string := C_TB_SCOPE_DEFAULT
  ) is
    constant C_BFM_SCOPE   : string := scope & ": i2c_check_slave_addr()";
    constant head      : string := "This address is reserved for ";
    constant tail      : string := ". Only use this address if you are certain " & "that the address is never going to be used " & "for its intended purpose. See I2C-bus specification Rev. 6 " & "for more information.";
    alias a_addr_value : unsigned(6 downto 0) is addr_value(6 downto 0);
  begin
    if addr_value'length = 7 then
      if a_addr_value(6 downto 2) = "00000" then
        case a_addr_value(1 downto 0) is
          when "00" =>
            -- general call (rw = 0)
            -- START byte (rw = 1)
            alert(alert_level, head & "general call and START byte" & tail, C_BFM_SCOPE);
          when "01" =>
            -- cbus addr
            alert(alert_level, head & "CBUS address" & tail, C_BFM_SCOPE);
          when "10" =>
            -- reserved for different bus format
            alert(alert_level, head & "different bus format" & tail, C_BFM_SCOPE);
          when "11" =>
            -- reserved for future purposes
            alert(alert_level, head & "future purposes" & tail, C_BFM_SCOPE);
          when others =>
            null;
        end case;
      elsif a_addr_value(6 downto 2) = "00001" then
        -- Hs-mode master code
        alert(alert_level, head & "High-speed mode (Hs-mode) master code" & tail, C_BFM_SCOPE);
      elsif a_addr_value(6 downto 2) = "11111" then
        -- device ID
        alert(alert_level, head & "device ID" & tail, C_BFM_SCOPE);
      elsif a_addr_value(6 downto 2) = "11110" then
        -- 10-bit-addressing
        alert(alert_level, head & "10-bit-addressing" & tail, C_BFM_SCOPE);
      else
      -- do nothing
      end if;
    elsif addr_value'length = 10 then
    -- do nothing
    else
      alert(error, "Invalid address length!", C_BFM_SCOPE);
    end if;
  end procedure;

  ---------------------------------------------------------------------------------
  -- initialize i2c to dut signals
  ---------------------------------------------------------------------------------

  function init_i2c_if_signals(
    constant VOID : in t_void
  ) return t_i2c_if is
    variable result : t_i2c_if;
  begin
    result.sda := 'Z';
    result.scl := 'Z';
    return result;
  end function;

  ---------------------------------------------------------------------------------
  -- check_time_window method here since it is local in uvvm_util.methods_pkg
  ---------------------------------------------------------------------------------
  -- check_time_window is used to check if a given condition occurred between
  -- min_time and max_time
  -- Usage: wait for requested condition until max_time is reached, then call check_time_window().
  -- The input 'success' is needed to distinguish between the following cases:
  --      - the signal reached success condition at max_time,
  --      - max_time was reached with no success condition
  procedure check_time_window(
    constant success      : boolean;    -- F.ex target'event, or target=exp
    constant elapsed_time : time;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant name         : string;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    -- Sanity check
    check_value(max_time >= min_time, TB_ERROR, name & " => min_time must be less than max_time." & LF & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel, name);

    if elapsed_time < min_time then
      alert(alert_level, name & " => Failed. Condition occurred too early, after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    elsif success then
      log(msg_id, name & " => OK. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else                                -- max_time reached with no success
      alert(alert_level, name & " => Failed. Timed out after " & to_string(max_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    end if;
  end;

  procedure i2c_master_transmit_single_byte(
    constant byte         : in std_logic_vector(7 downto 0);
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    for i in 7 downto 0 loop
      wait for config.i2c_bit_time / 4;
      if byte(i) = '1' then
        sda <= 'Z';
      else
        sda <= '0';
      end if;
      wait for config.i2c_bit_time / 4;
      scl <= 'Z';                       -- release
      wait for config.i2c_bit_time / 2;
      -- check for clock stretching
      await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
      scl <= '0';
    end loop;
  end procedure;

  procedure i2c_master_receive_single_byte(
    variable byte         : out std_logic_vector(7 downto 0);
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    for i in 7 downto 0 loop
      wait for config.i2c_bit_time / 2;
      scl     <= 'Z';                   -- release
      -- check for clock stretching
      await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      byte(i) := to_X01(sda);
      wait for config.i2c_bit_time / 2;
      scl     <= '0';
    end loop;
  end procedure;

  procedure i2c_master_set_ack(
    constant ack          : in std_logic;
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    wait for config.i2c_bit_time / 4;
    if ack = '1' then
      sda <= 'Z';
    else
      sda <= '0';
    end if;
    wait for config.i2c_bit_time / 4;
    scl <= 'Z';                         -- release
    wait for config.i2c_bit_time / 2;
    -- check for clock stretching
    await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
    scl <= '0';
    wait for config.i2c_bit_time / 4;
    sda <= 'Z';                         -- release
  end procedure;

  procedure i2c_master_check_ack(
    constant ack_exp      : in std_logic;
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    -- Check ACK
    -- The master shall drive scl during the acknowledge cycle
    -- A valid ack is detected when sda is '0'.
    wait for config.i2c_bit_time / 4;
    sda <= 'Z';                         -- release
    wait for config.i2c_bit_time / 4;
    scl <= 'Z';
    wait for config.i2c_bit_time / 4;
    check_value(sda, ack_exp, MATCH_STD, config.acknowledge_severity, msg, scope, ID_NEVER, msg_id_panel);
    wait for config.i2c_bit_time / 4;
    -- check for clock stretching
    await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
    scl <= '0';
  end procedure;

  procedure i2c_master_check_ack(
    variable v_ack_received : out boolean;
    constant ack_exp        : in std_logic;
    constant msg            : in string;
    signal   scl            : inout std_logic;
    signal   sda            : inout std_logic;
    constant scope          : in string           := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    -- Check ACK
    -- The master shall drive scl during the acknowledge cycle
    -- A valid ack is detected when sda is '0'.
    wait for config.i2c_bit_time / 4;
    sda            <= 'Z';              -- release
    wait for config.i2c_bit_time / 4;
    scl            <= 'Z';
    wait for config.i2c_bit_time / 4;
    v_ack_received := check_value(sda, ack_exp, MATCH_STD, NO_ALERT, msg, scope, ID_NEVER, msg_id_panel);
    wait for config.i2c_bit_time / 4;
    if v_ack_received then
      -- check for clock stretching
      await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
    end if;
    scl <= '0';
  end procedure;

  procedure i2c_slave_transmit_single_byte(
    constant byte         : in std_logic_vector(7 downto 0);
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    for i in 7 downto 0 loop
      wait for config.i2c_bit_time / 4;
      if byte(i) = '1' then
        sda <= 'Z';
      else
        sda <= '0';
      end if;
      await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    end loop;
  end procedure;

  procedure i2c_slave_receive_single_byte(
    variable byte         : out std_logic_vector(7 downto 0);
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    for i in 7 downto 0 loop
      await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      wait for config.i2c_bit_time / 4; -- to sample in the middle of the high period
      byte(i) := to_X01(sda);
      await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    end loop;
  end procedure;

  procedure i2c_slave_set_ack(
    constant ack          : in std_logic;
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    wait for config.i2c_bit_time / 4;
    if ack = '1' then
      sda <= 'Z';
    else
      sda <= '0';
    end if;
    await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    wait for config.i2c_bit_time / 4;
    sda <= 'Z';
  end procedure;

  procedure i2c_slave_check_ack(
    constant ack_exp      : in std_logic;
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    -- Time shall be at the falling edge time of SCL.

    -- Check ACK
    -- The master shall drive scl during the acknowledge cycle
    -- A valid ack is detected when sda is '0'.
    wait for config.i2c_bit_time / 4;
    sda <= 'Z';                         -- release
    await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    check_value(sda, ack_exp, MATCH_STD, config.acknowledge_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_master_transmit
  -- alert if size of data doesn't match with how long sda is kept low
  ---------------------------------------------------------------------------------
  procedure i2c_master_transmit(
    constant addr_value                   : in unsigned;
    constant data                         : in t_byte_array;
    constant msg                          : in string;
    signal   scl                          : inout std_logic;
    signal   sda                          : inout std_logic;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name                : string                       := "i2c_master_transmit";
    constant proc_call                : string                       := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_10_BIT_ADDRESS_PATTERN : std_logic_vector(4 downto 0) := "11110";

    -- Normalize to the 7 bit addr and 8 bit data widths
    variable v_normalized_addr : unsigned(9 downto 0) := normalize_and_check(addr_value, config.slave_mode_address, ALLOW_NARROWER, "addr", "config.slave_mode_address", msg);

    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(v_normalized_addr(9 downto 8));

    procedure i2c_master_transmit_single_byte(
      constant byte : in std_logic_vector(7 downto 0)
    ) is
    begin
      i2c_master_transmit_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_check_ack(
      constant ack_exp : in std_logic
    ) is
    begin
      i2c_master_check_ack(ack_exp, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    if not config.enable_10_bits_addressing then
      check_value(v_normalized_addr(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode.",
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(v_normalized_addr(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(v_normalized_addr, config.reserved_address_severity, scope);
    end if;

    check_value(data'ascending, failure, "Verifying that data is of ascending type.", scope, ID_NEVER, msg_id_panel);

    await_value(sda, '1', MATCH_STD, 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(sda) = '1' and to_X01(scl) = '1' then
      -- do the start condition
      sda <= '0';
      wait for config.master_sda_to_scl;
      scl <= '0';

      if sda = '0' then
        -- Transmit address
        if not config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(6 downto 0)) & '0'); -- 7 bit address + write bit

        else                            -- 10-bits addressing enabled
          -- transmit 11110<addr bit 9><addr bit 8><Write>
          i2c_master_transmit_single_byte(C_FIRST_10_BIT_ADDRESS_BITS & '0'); -- Pattern indicating 10-bit addresing + first 2 bits of 10-bit address + write bit
        end if;

        -- Check ACK
        -- The master shall drive scl during the acknowledge cycle
        -- A valid ack is detected when sda is '0'.
        i2c_master_check_ack('0');

        -- If 10-bits addressing is enabled, transmit second address byte.
        if config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(7 downto 0))); -- LSB of 10-bit address

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          i2c_master_check_ack('0');
        end if;

        -- serially shift out data to sda
        for i in 0 to data'length - 1 loop
          i2c_master_transmit_single_byte(data(i));

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          i2c_master_check_ack('0');
        end loop;

        wait for config.i2c_bit_time / 4;

        if action_when_transfer_is_done = RELEASE_LINE_AFTER_TRANSFER then
          -- do the stop condition
          sda <= '0';
          wait for config.i2c_bit_time / 4;
          scl <= 'Z';
          -- check for clock stretching
          await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
          wait for config.master_scl_to_sda;
          sda <= 'Z';
        else                            -- action_when_transfer_is_done = HOLD_LINE_AFTER_TRANSFER
          -- Do not perform the stop condition. Instead release SDA when SCL is low.
          -- This will prepare for a repeated start condition.
          sda <= 'Z';
          wait for config.i2c_bit_time / 4;
          scl <= 'Z';
          -- check for clock stretching
          await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
        end if;

        wait for config.master_stop_condition_hold_time;
      end if;
    else
      alert(error, proc_call & " sda and scl not inactive (high) when wishing to start " & add_msg_delimiter(msg), scope);
    end if;

    log(config.id_for_bfm, proc_call & "=> " & to_string(data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);

  end procedure;

  procedure i2c_master_transmit(
    constant addr_value                   : in unsigned;
    constant data                         : in t_byte_array;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    i2c_master_transmit(addr_value, data, msg,
                        i2c_if.scl, i2c_if.sda, action_when_transfer_is_done,
                        scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_master_transmit
  -- alert if size of data doesn't match with how long sda is kept low
  ---------------------------------------------------------------------------------
  procedure i2c_master_transmit(
    constant addr_value                   : in unsigned;
    constant data                         : in std_logic_vector;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  ) is
    variable v_bfm_tx_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) := normalize_and_check(data, v_bfm_tx_data, ALLOW_NARROWER, "data", "v_bfm_tx_data", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_master_transmit(addr_value, v_byte_array, msg,
                        i2c_if.scl, i2c_if.sda, action_when_transfer_is_done,
                        scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_slave_transmit
  -- alert if size of data doesn't match with how long sda is kept low
  ---------------------------------------------------------------------------------
  procedure i2c_slave_transmit(
    constant data         : in t_byte_array;
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name : string := "i2c_slave_transmit";
    constant proc_call : string := proc_name & "(" & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_bfm_rx_data   : std_logic_vector(7 downto 0) := (others => '0');
    variable v_received_addr : unsigned(9 downto 0)         := (others => '0');

    constant C_10_BIT_ADDRESS_PATTERN    : std_logic_vector(4 downto 0) := "11110";
    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(config.slave_mode_address(9 downto 8));

    procedure i2c_slave_transmit_single_byte(
      constant byte : in std_logic_vector(7 downto 0)
    ) is
    begin
      i2c_slave_transmit_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_slave_receive_single_byte(
      variable byte : out std_logic_vector(7 downto 0)
    ) is
    begin
      i2c_slave_receive_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_slave_set_ack(
      constant ack : in std_logic
    ) is
    begin
      i2c_slave_set_ack(ack, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_slave_check_ack(
      constant ack_exp : in std_logic
    ) is
    begin
      i2c_slave_check_ack(ack_exp, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

  begin
    if not config.enable_10_bits_addressing then
      check_value(config.slave_mode_address(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode.",
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(config.slave_mode_address(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(config.slave_mode_address, config.reserved_address_severity, scope);
    end if;

    check_value(data'ascending, failure, "Verifying that data is of ascending type.", scope, ID_NEVER, msg_id_panel);

    await_value(sda, '1', MATCH_STD, 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(sda) = '1' and to_X01(scl) = '1' then
      -- await the start condition
      await_value(sda, '0', 0 ns, config.max_wait_sda_change + config.max_wait_sda_change / 100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

      if sda = '0' then
        if not config.enable_10_bits_addressing then
          -- receive the address bits
          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(6 downto 0) := unsigned(v_bfm_rx_data(7 downto 1));
          -- Check R/W bit
          check_value(v_bfm_rx_data(0), '1', config.slave_rw_bit_severity, msg, scope, ID_NEVER, msg_id_panel);

          -- Set ACK/NACK based on address
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_received_addr = config.slave_mode_address then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " wrong slave address!" & " Expected: " & to_string(config.slave_mode_address, BIN, KEEP_LEADING_0) & ", Got: " & to_string(v_received_addr, BIN, KEEP_LEADING_0) & add_msg_delimiter(msg), scope);
            return;
          end if;
        else                            -- 10 bit addressing
          -- receive the first byte, consisting of "11110<bit 9><bit 8><write>"
          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(9 downto 8) := unsigned(v_bfm_rx_data(2 downto 1));
          -- Check R/W bit
          check_value(v_bfm_rx_data(0), '0', config.slave_rw_bit_severity, msg & ": checking R/W bit after first address byte (10-bit addressing)", scope, ID_NEVER, msg_id_panel);

          -- Set ACK/NACK based on first received byte
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_bfm_rx_data(7 downto 1) = C_FIRST_10_BIT_ADDRESS_BITS then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " first byte was other than expected! " & add_msg_delimiter(msg), scope);
            return;
          end if;

          -- Receive LSB of 10-bit address
          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(7 downto 0) := unsigned(v_bfm_rx_data);

          -- Set ACK/NACK based on address
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_received_addr = config.slave_mode_address then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, proc_call & " wrong slave address!" & " Expected: " & to_string(config.slave_mode_address, BIN, KEEP_LEADING_0) & ", Got: " & to_string(v_received_addr, BIN, KEEP_LEADING_0) & add_msg_delimiter(msg), scope);
            return;
          end if;

          -- Expect repeated start condition
          sda <= 'Z';                   -- other side should drive now

          await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
          await_value(sda, '1', MATCH_STD, 0 ns, config.master_scl_to_sda + config.master_scl_to_sda / 100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);

          if to_X01(sda) = '1' and to_X01(scl) = '1' then
            -- await the start condition
            await_value(sda, '0', 0 ns, config.max_wait_sda_change + config.max_wait_sda_change / 100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
            await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

            if sda = '0' then
              -- receive the first 2 address bits again+ read bit, consisting of "11110<bit 9><bit 8><read>"
              i2c_slave_receive_single_byte(v_bfm_rx_data);
              -- Check R/W bit
              check_value(v_bfm_rx_data(0), '1', config.slave_rw_bit_severity, add_msg_delimiter(msg) & ": checking R/W bit after first address byte (10-bit addressing)", scope, ID_NEVER, msg_id_panel);

              -- Set ACK/NACK based on first received byte
              -- The master shall drive scl during the acknowledge cycle
              -- A valid ack is detected when sda is '0'.
              if v_bfm_rx_data(7 downto 1) = C_FIRST_10_BIT_ADDRESS_BITS then
                -- ACK
                i2c_slave_set_ack('0');
              else
                -- NACK
                alert(config.slave_mode_address_severity, proc_call & " first byte was other than expected! " & add_msg_delimiter(msg), scope);
                return;
              end if;
            else
              alert(error, proc_call & " sda and scl not inactive (high) when wishing to start after repeated start condition for 10 bit address " & add_msg_delimiter(msg), scope);
            end if;
          end if;
        end if;

        for i in 0 to data'length - 1 loop
          i2c_slave_transmit_single_byte(data(i));

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          -- A NACK ('1'/'H') means that the transaction is over.
          if i < data'length - 1 then
            i2c_slave_check_ack('0');
          else                          -- final data byte expected
            i2c_slave_check_ack('1');
          end if;

          await_value(scl, '0', 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
        end loop;

        -- Wait for either the stop condition or preparation for
        -- repeated start condition.
        sda <= 'Z';                     -- other side should drive now
        await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
        await_value(sda, '1', MATCH_STD, 0 ns, config.master_scl_to_sda + config.master_scl_to_sda / 100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);

      end if;
    else
      alert(error, proc_call & " sda and scl not inactive (high) when wishing to start " & add_msg_delimiter(msg), scope);
    end if;

    log(config.id_for_bfm, proc_call & "=> " & to_string(data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);

  end procedure;

  procedure i2c_slave_transmit(
    constant data         : in t_byte_array;
    constant msg          : in string;
    signal   i2c_if       : inout t_i2c_if;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    i2c_slave_transmit(data, msg,
                       i2c_if.scl, i2c_if.sda,
                       scope, msg_id_panel, config);
  end procedure;

  procedure i2c_slave_transmit(
    constant data         : in std_logic_vector;
    constant msg          : in string;
    signal   i2c_if       : inout t_i2c_if;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
    variable v_bfm_tx_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) := normalize_and_check(data, v_bfm_tx_data, ALLOW_NARROWER, "data", "v_bfm_tx_data", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_slave_transmit(v_byte_array, msg,
                       i2c_if.scl, i2c_if.sda,
                       scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_master_receive
  ---------------------------------------------------------------------------------
  procedure i2c_master_receive(
    constant addr_value                   : in unsigned;
    variable data                         : out t_byte_array;
    constant msg                          : in string;
    signal   scl                          : inout std_logic;
    signal   sda                          : inout std_logic;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in string                         := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is

    -- Local proc_name; used if called from sequncer or VVC
    constant local_proc_name : string := "i2c_master_receive";
    -- Local proc_call; used if called from sequncer or VVC
    constant local_proc_call : string := local_proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";

    constant C_10_BIT_ADDRESS_PATTERN : std_logic_vector(4 downto 0) := "11110";

    -- Normalize to the 7 bit addr and 8 bit data widths
    variable v_normalized_addr : unsigned(9 downto 0) := normalize_and_check(addr_value, config.slave_mode_address, ALLOW_NARROWER, "addr", "config.slave_mode_address", msg);

    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(v_normalized_addr(9 downto 8));

    variable v_proc_call : line;

    procedure i2c_master_transmit_single_byte(
      constant byte : in std_logic_vector(7 downto 0)
    ) is
    begin
      i2c_master_transmit_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_receive_single_byte(
      variable byte : out std_logic_vector(7 downto 0)
    ) is
    begin
      i2c_master_receive_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_set_ack(
      constant ack : in std_logic
    ) is
    begin
      i2c_master_set_ack(ack, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_check_ack(
      constant ack_exp : in std_logic
    ) is
    begin
      i2c_master_check_ack(ack_exp, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'i2c_master_receive...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing i2c_master_receive...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    if not config.enable_10_bits_addressing then
      check_value(v_normalized_addr(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode.",
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(v_normalized_addr(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(v_normalized_addr(9 downto 0), config.reserved_address_severity, scope);
    end if;

    check_value(data'ascending, failure, "Verifying that data is of ascending type. " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);

    -- start condition
    await_value(sda, '1', MATCH_STD, 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(sda) = '1' and to_X01(scl) = '1' then
      -- do the start condition
      sda <= '0';
      wait for config.master_sda_to_scl;
      scl <= '0';

      if sda = '0' then
        -- Transmit address
        if not config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(6 downto 0)) & '1');
        else                            -- 10-bits addressing enabled
          -- Transmit Slave Address first 7 bits 11110<addr bit 9><addr bit 8><Write>
          i2c_master_transmit_single_byte(C_FIRST_10_BIT_ADDRESS_BITS & '0');
        end if;

        -- Check ACK
        -- The master shall drive scl during the acknowledge cycle
        -- A valid ack is detected when sda is '0'.
        i2c_master_check_ack('0');

        -- If 10-bits addressing is enabled, transmit second address byte.
        if config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(7 downto 0)));

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          i2c_master_check_ack('0');

          -- Now generate a repeated start condition, send the first byte again (only with read/write-bit set to read), check ack. Then receive data bytes.

          -- Generate repeated start condition
          wait for config.i2c_bit_time / 4;
          sda <= 'Z';
          wait for config.i2c_bit_time / 4;
          scl <= 'Z';
          -- check for clock stretching
          await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);

          wait for config.master_stop_condition_hold_time;
          -- do the start condition
          sda <= '0';
          wait for config.master_sda_to_scl;
          scl <= '0';
          if sda = '0' then
            -- Transmit Slave Address first 7 bits 11110<addr bit 9><addr bit 8><Read>
            i2c_master_transmit_single_byte(C_FIRST_10_BIT_ADDRESS_BITS & '1');

            -- Check ACK
            -- The master shall drive scl during the acknowledge cycle
            -- A valid ack is detected when sda is '0'.
            i2c_master_check_ack('0');
          else
            alert(error, v_proc_call.all & " sda not '0' when expected after repeated start condition for 10-bit addressing! " & add_msg_delimiter(msg), scope);
          end if;
        end if;

        -- receive the data bytes
        for i in 0 to data'length - 1 loop
          i2c_master_receive_single_byte(data(i));

          -- Set ACK/NACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          -- Each byte shall be ACKed except last byte.
          -- Transaction ends when master sets NACK.
          -- scl has been driven to '0' above
          if i < data'length - 1 then
            i2c_master_set_ack('0');    -- ACK
          else
            i2c_master_set_ack('1');    -- NACK
          end if;
        end loop;

        if action_when_transfer_is_done = RELEASE_LINE_AFTER_TRANSFER then
          -- do the stop condition
          sda <= '0';
          wait for config.i2c_bit_time / 4;
          scl <= 'Z';
          -- check for clock stretching
          await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);

          wait for config.master_scl_to_sda;
          sda <= 'Z';
        else                            -- action_when_transfer_is_done = HOLD_LINE_AFTER_TRANSFER
          -- Do not perform the stop condition. Instead release SDA when SCL is low.
          -- This will prepare for a repeated start condition.
          sda <= 'Z';
          wait for config.i2c_bit_time / 4;
          scl <= 'Z';
          -- check for clock stretching
          await_value(scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
        end if;

        wait for config.master_stop_condition_hold_time;
      end if;
    else
      alert(error, v_proc_call.all & " sda and scl not inactive (high) when wishing to start " & add_msg_delimiter(msg), scope);
    end if;

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. i2c_master_check)
    end if;

    DEALLOCATE(v_proc_call);
  end procedure;

  procedure i2c_master_receive(
    constant addr_value                   : in unsigned;
    variable data                         : out t_byte_array;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in string                         := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
  begin
    i2c_master_receive(addr_value, data, msg,
                       i2c_if.scl, i2c_if.sda, action_when_transfer_is_done,
                       scope, msg_id_panel, config, ext_proc_call);
  end procedure;

  procedure i2c_master_receive(
    constant addr_value                   : in unsigned;
    variable data                         : out std_logic_vector;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call                : in string                         := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    variable v_byte_array : t_byte_array(0 to 0);
  begin
    i2c_master_receive(addr_value, v_byte_array, msg,
                       i2c_if.scl, i2c_if.sda, action_when_transfer_is_done,
                       scope, msg_id_panel, config, ext_proc_call);

    data := v_byte_array(0);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_slave_receive
  ---------------------------------------------------------------------------------
  procedure i2c_slave_receive(
    variable data          : out t_byte_array;
    constant msg           : in string;
    signal   scl           : inout std_logic;
    signal   sda           : inout std_logic;
    constant exp_rw_bit    : in std_logic        := C_WRITE_BIT;
    constant scope         : in string           := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    -- Local proc_name; used if called from sequncer or VVC
    constant local_proc_name : string := "i2c_slave_receive";
    -- Local proc_call; used if called from sequncer or VVC
    constant local_proc_call : string := local_proc_name & "()";

    variable v_proc_call     : line;
    variable v_received_addr : unsigned(9 downto 0) := (others => '0');
    variable v_bfm_rx_data   : std_logic_vector(7 downto 0);

    constant C_10_BIT_ADDRESS_PATTERN    : std_logic_vector(4 downto 0) := "11110";
    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(config.slave_mode_address(9 downto 8));

    procedure i2c_slave_receive_single_byte(
      variable byte : out std_logic_vector(7 downto 0)
    ) is
    begin
      i2c_slave_receive_single_byte(byte, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_slave_set_ack(
      constant ack : in std_logic
    ) is
    begin
      i2c_slave_set_ack(ack, msg, scl, sda, scope, msg_id_panel, config);
    end procedure;
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'i2c_slave_receive...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing i2c_slave_receive...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    if not config.enable_10_bits_addressing then
      check_value(config.slave_mode_address(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode.",
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(config.slave_mode_address(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(config.slave_mode_address, config.reserved_address_severity, scope);
    end if;

    check_value(data'ascending, failure, "Verifying that data is of ascending type. " & add_msg_delimiter(msg) & ".", scope, ID_NEVER, msg_id_panel);
    -- Check that expected data range is 0 when expected read/write bit is read.
    if exp_rw_bit = C_READ_BIT then
      check_value(data'length, 0, TB_ERROR, "Expected data range must be 0 when expected R/W# bit is Read. " & add_msg_delimiter(msg) & ".", scope, ID_NEVER, msg_id_panel);
    end if;

    await_value(sda, '1', MATCH_STD, 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(sda) = '1' and to_X01(scl) = '1' then
      -- await the start condition
      await_value(sda, '0', 0 ns, config.max_wait_sda_change + config.max_wait_sda_change / 100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
      await_value(scl, '0', 0 ns, config.master_sda_to_scl + config.master_sda_to_scl / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

      if sda = '0' then
        if not config.enable_10_bits_addressing then
          -- receive the address bits
          i2c_slave_receive_single_byte(v_bfm_rx_data);

          check_value(v_bfm_rx_data(0), exp_rw_bit, config.slave_rw_bit_severity, msg, scope, ID_NEVER, msg_id_panel); -- R/W bit

          -- Set ACK/NACK based on address
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if unsigned(v_bfm_rx_data(7 downto 1)) = config.slave_mode_address(6 downto 0) then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, v_proc_call.all & " wrong slave address!" & " Expected: " & to_string(config.slave_mode_address, BIN, KEEP_LEADING_0) & ", Got: " & to_string(unsigned(v_bfm_rx_data(7 downto 1)), BIN, KEEP_LEADING_0) & add_msg_delimiter(msg), scope);
            deallocate(v_proc_call);
            return;
          end if;
        else
          -- receive the first byte, consisting of "11110<bit 9><bit 8><write>"
          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(9 downto 8) := unsigned(v_bfm_rx_data(2 downto 1));
          -- Check R/W bit
          check_value(v_bfm_rx_data(0), exp_rw_bit, config.slave_rw_bit_severity, add_msg_delimiter(msg) & ": checking R/W bit after first address byte (10-bit addressing)", scope, ID_NEVER, msg_id_panel);

          -- Set ACK/NACK based on first received byte
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_bfm_rx_data(7 downto 1) = C_FIRST_10_BIT_ADDRESS_BITS then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, v_proc_call.all & " first byte was other than expected! " & add_msg_delimiter(msg), scope);
            deallocate(v_proc_call);
            return;
          end if;

          i2c_slave_receive_single_byte(v_bfm_rx_data);
          v_received_addr(7 downto 0) := unsigned(v_bfm_rx_data);

          -- Set ACK/NACK based on address
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          if v_received_addr = config.slave_mode_address then
            -- ACK
            i2c_slave_set_ack('0');
          else
            -- NACK
            alert(config.slave_mode_address_severity, v_proc_call.all & " wrong slave address!" & " Expected: " & to_string(config.slave_mode_address, BIN, KEEP_LEADING_0) & ", Got: " & to_string(v_received_addr, BIN, KEEP_LEADING_0) & add_msg_delimiter(msg), scope);
            deallocate(v_proc_call);
            return;
          end if;

        end if;

        -- receive the data bytes
        for i in 0 to data'length - 1 loop
          i2c_slave_receive_single_byte(data(i));

          -- Set ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          i2c_slave_set_ack('0');
        end loop;

        -- Wait for either the stop condition or preparation for
        -- repeated start condition.
        await_value(scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change + config.max_wait_scl_change / 100, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);
        await_value(sda, '1', MATCH_STD, 0 ns, config.master_scl_to_sda + config.master_scl_to_sda / 100, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);

      end if;
    else
      alert(error, v_proc_call.all & " sda and scl not inactive (high) when wishing to start " & add_msg_delimiter(msg), scope);
    end if;

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. i2c_slave_check)
    end if;

    DEALLOCATE(v_proc_call);
  end procedure;

  procedure i2c_slave_receive(
    variable data          : out t_byte_array;
    constant msg           : in string;
    signal   i2c_if        : inout t_i2c_if;
    constant scope         : in string           := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
  begin
    i2c_slave_receive(data, msg,
                      i2c_if.scl, i2c_if.sda, C_WRITE_BIT,
                      scope, msg_id_panel, config, ext_proc_call);
  end procedure;

  procedure i2c_slave_receive(
    variable data          : out std_logic_vector;
    constant msg           : in string;
    signal   i2c_if        : inout t_i2c_if;
    constant scope         : in string           := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    variable v_byte_array : t_byte_array(0 to 0);
  begin
    i2c_slave_receive(v_byte_array, msg,
                      i2c_if.scl, i2c_if.sda, C_WRITE_BIT,
                      scope, msg_id_panel, config, ext_proc_call);
    data := v_byte_array(0);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_master_check
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the data_exp.
  procedure i2c_master_check(
    constant addr_value                   : in unsigned;
    constant data_exp                     : in t_byte_array;
    constant msg                          : in string;
    signal   scl                          : inout std_logic;
    signal   sda                          : inout std_logic;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name     : string  := "i2c_master_check";
    constant proc_call     : string  := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Helper variables
    variable v_data_array  : t_byte_array(data_exp'range);
    variable v_check_ok    : boolean := true;
    variable v_byte_ok     : boolean;
    variable v_alert_radix : t_radix;
  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    i2c_master_receive(addr_value, v_data_array, msg, scl, sda, action_when_transfer_is_done, scope, msg_id_panel, config, proc_call);

    for byte in data_exp'range loop
      for i in data_exp(byte)'range loop
        -- Allow don't care in expected value and use match strictness from config for comparison
        if data_exp(byte)(i) = '-' or check_value(v_data_array(byte)(i), data_exp(byte)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
          v_byte_ok := true;
        else
          v_byte_ok := false;
          exit;
        end if;
      end loop;

      if not v_byte_ok then
        -- Use binary representation when mismatch is due to weak signals
        v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_data_array(byte), data_exp(byte), MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
        alert(alert_level, proc_call & "=> Failed. Was " & to_string(v_data_array(byte), v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(data_exp(byte), v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
        v_check_ok    := false;
      end if;
    end loop;

    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_array, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  procedure i2c_master_check(
    constant addr_value                   : in unsigned;
    constant data_exp                     : in t_byte_array;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    i2c_master_check(addr_value, data_exp, msg,
                     i2c_if.scl, i2c_if.sda, action_when_transfer_is_done,
                     alert_level, scope, msg_id_panel, config);
  end procedure;

  procedure i2c_master_check(
    constant addr_value                   : in unsigned;
    constant data_exp                     : in std_logic_vector;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  ) is

    variable v_bfm_rx_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data_exp : std_logic_vector(7 downto 0) := normalize_and_check(data_exp, v_bfm_rx_data, ALLOW_NARROWER, "data", "v_bfm_rx_data", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data_exp);
  begin
    i2c_master_check(addr_value, v_byte_array, msg,
                     i2c_if.scl, i2c_if.sda, action_when_transfer_is_done,
                     alert_level, scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_slave_check
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the data_exp.
  procedure i2c_slave_check(
    constant data_exp     : in t_byte_array;
    constant msg          : in string;
    signal   scl          : inout std_logic;
    signal   sda          : inout std_logic;
    constant exp_rw_bit   : in std_logic        := C_WRITE_BIT;
    constant alert_level  : in t_alert_level    := error;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name : string := "i2c_slave_check";
    constant proc_call : string := proc_name & "(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- Helper variables
    variable v_data_array  : t_byte_array(data_exp'range);
    variable v_check_ok    : boolean := true;
    variable v_byte_ok     : boolean;
    variable v_alert_radix : t_radix;
  begin
    i2c_slave_receive(v_data_array, msg, scl, sda, exp_rw_bit, scope, msg_id_panel, config, proc_call);

    for byte in data_exp'range loop
      for i in data_exp(byte)'range loop
        -- Allow don't care in expected value and use match strictness from config for comparison
        if data_exp(byte)(i) = '-' or check_value(v_data_array(byte)(i), data_exp(byte)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
          v_byte_ok := true;
        else
          v_byte_ok := false;
          exit;
        end if;
      end loop;

      if not v_byte_ok then
        -- Use binary representation when mismatch is due to weak signals
        v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_data_array(byte), data_exp(byte), MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
        alert(alert_level, proc_call & "=> Failed. Was " & to_string(v_data_array(byte), v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(data_exp(byte), v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
        v_check_ok    := false;
      end if;
    end loop;

    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_array, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  procedure i2c_slave_check(
    constant data_exp     : in t_byte_array;
    constant msg          : in string;
    signal   i2c_if       : inout t_i2c_if;
    constant exp_rw_bit   : in std_logic        := C_WRITE_BIT;
    constant alert_level  : in t_alert_level    := error;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is
  begin
    i2c_slave_check(data_exp, msg,
                    i2c_if.scl, i2c_if.sda, exp_rw_bit,
                    alert_level, scope, msg_id_panel, config);
  end procedure;

  procedure i2c_slave_check(
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   i2c_if       : inout t_i2c_if;
    constant exp_rw_bit   : in std_logic        := C_WRITE_BIT;
    constant alert_level  : in t_alert_level    := error;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT
  ) is

    variable v_bfm_rx_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data_exp : std_logic_vector(7 downto 0) := normalize_and_check(data_exp, v_bfm_rx_data, ALLOW_NARROWER, "data", "v_bfm_rx_data", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data_exp);
  begin
    i2c_slave_check(v_byte_array, msg,
                    i2c_if.scl, i2c_if.sda, exp_rw_bit,
                    alert_level, scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------
  -- i2c_master_quick_command
  ---------------------------------------------------------------------------------
  procedure i2c_master_quick_command(
    constant addr_value                   : in unsigned;
    constant msg                          : in string;
    signal   i2c_if                       : inout t_i2c_if;
    constant rw_bit                       : in std_logic                      := C_WRITE_BIT;
    constant exp_ack                      : in boolean                        := true;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel                 := shared_msg_id_panel;
    constant config                       : in t_i2c_bfm_config               := C_I2C_BFM_CONFIG_DEFAULT
  ) is

    constant proc_call : string := "i2c_master_quick_command (A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", rw_bit: " & to_string(rw_bit) & ")";

    constant C_10_BIT_ADDRESS_PATTERN : std_logic_vector(4 downto 0) := "11110";

    -- Normalize to the 7 bit addr and 8 bit data widths
    variable v_normalized_addr : unsigned(9 downto 0) := normalize_and_check(addr_value, config.slave_mode_address, ALLOW_NARROWER, "addr", "config.slave_mode_address", msg);

    constant C_FIRST_10_BIT_ADDRESS_BITS : std_logic_vector(6 downto 0) := C_10_BIT_ADDRESS_PATTERN & std_logic_vector(v_normalized_addr(9 downto 8));

    variable v_ack_received : boolean := false;
    variable v_ack_ok       : boolean;
    variable v_check_ok     : boolean := true;

    procedure i2c_master_transmit_single_byte(
      constant byte : in std_logic_vector(7 downto 0)
    ) is
    begin
      i2c_master_transmit_single_byte(byte, msg, i2c_if.scl, i2c_if.sda, scope, msg_id_panel, config);
    end procedure;

    procedure i2c_master_check_ack(
      variable v_ack_received : out boolean;
      constant ack_exp        : in std_logic
    ) is
    begin
      i2c_master_check_ack(v_ack_received, ack_exp, msg, i2c_if.scl, i2c_if.sda, scope, msg_id_panel, config);
    end procedure;

  begin
    -- check whether config.i2c_bit_time was set probably
    check_value(config.i2c_bit_time /= -1 ns, TB_ERROR, "I2C Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    if not config.enable_10_bits_addressing then
      check_value(v_normalized_addr(9 downto 7), unsigned'("000"), config.slave_mode_address_severity,
                  "Verifying that top slave address bits (9-7) are not set in 7-bit addressing mode. " & add_msg_delimiter(msg),
                  scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER, msg_id_panel);
      i2c_check_slave_addr(v_normalized_addr(6 downto 0), config.reserved_address_severity, scope);
    else
      i2c_check_slave_addr(v_normalized_addr(9 downto 0), config.reserved_address_severity, scope);
    end if;

    -- start condition
    log(config.id_for_bfm, proc_call & "=> Awaiting start condition. " & add_msg_delimiter(msg), scope, msg_id_panel);
    await_value(i2c_if.sda, '1', MATCH_STD, 0 ns, config.max_wait_sda_change, config.max_wait_sda_change_severity, msg, scope, ID_NEVER, msg_id_panel);
    await_value(i2c_if.scl, '1', MATCH_STD, 0 ns, config.max_wait_scl_change, config.max_wait_scl_change_severity, msg, scope, ID_NEVER, msg_id_panel);

    if to_X01(i2c_if.sda) = '1' and to_X01(i2c_if.scl) = '1' then
      -- do the start condition
      i2c_if.sda <= '0';
      wait for config.master_sda_to_scl;
      i2c_if.scl <= '0';

      if i2c_if.sda = '0' then
        -- Transmit address
        log(config.id_for_bfm, proc_call & "=> Transmitting address. " & add_msg_delimiter(msg), scope, msg_id_panel);
        if not config.enable_10_bits_addressing then
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(6 downto 0)) & rw_bit);
        else                            -- 10-bits addressing enabled
          -- Transmit Slave Address first 7 bits 11110<addr bit 9><addr bit 8><Write>
          i2c_master_transmit_single_byte(C_FIRST_10_BIT_ADDRESS_BITS & rw_bit);
        end if;
        log(config.id_for_bfm, proc_call & "=> Address transmitted. " & add_msg_delimiter(msg), scope, msg_id_panel);

        -- Check ACK
        -- The master shall drive scl during the acknowledge cycle
        -- A valid ack is detected when sda is '0'.
        log(config.id_for_bfm, proc_call & "=> Checking ACK. " & add_msg_delimiter(msg), scope, msg_id_panel);
        i2c_master_check_ack(v_ack_received, '0');
        log(config.id_for_bfm, proc_call & "=> ACK was " & to_string(v_ack_received) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);

        -- If 10-bits addressing is enabled, transmit second address byte.
        if config.enable_10_bits_addressing then
          log(config.id_for_bfm, proc_call & "=> Transmitting second part of address. " & add_msg_delimiter(msg), scope, msg_id_panel);
          i2c_master_transmit_single_byte(std_logic_vector(v_normalized_addr(7 downto 0)));

          -- Check ACK
          -- The master shall drive scl during the acknowledge cycle
          -- A valid ack is detected when sda is '0'.
          log(config.id_for_bfm, proc_call & "=> Checking ACK. " & add_msg_delimiter(msg), scope, msg_id_panel);
          i2c_master_check_ack(v_ack_received, '0');
          log(config.id_for_bfm, proc_call & "=> ACK was " & to_string(v_ack_received) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);

          -- Now generate a repeated start condition, send the first byte again (only with read/write-bit set to read), check ack. Then receive data bytes.

          -- Generate repeated start condition
          log(config.id_for_bfm, proc_call & "=> Repeating start condition. " & add_msg_delimiter(msg), scope, msg_id_panel);
          wait for config.i2c_bit_time / 4;
          i2c_if.sda <= 'Z';
          wait for config.i2c_bit_time / 4;
          i2c_if.scl <= 'Z';
          -- check for clock stretching
          await_value(i2c_if.scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);

          wait for config.master_stop_condition_hold_time;
          -- do the start condition
          i2c_if.sda <= '0';
          wait for config.master_sda_to_scl;
          i2c_if.scl <= '0';
          if i2c_if.sda = '0' then
            -- Transmit Slave Address first 7 bits 11110<addr bit 9><addr bit 8><Write>
            log(config.id_for_bfm, proc_call & "=> Transmitting Slave Address first 7 bits. " & add_msg_delimiter(msg), scope, msg_id_panel);
            i2c_master_transmit_single_byte(C_FIRST_10_BIT_ADDRESS_BITS & '1');

            -- Check ACK
            -- The master shall drive scl during the acknowledge cycle
            -- A valid ack is detected when sda is '0'.
            log(config.id_for_bfm, proc_call & "=> Checking ACK. " & add_msg_delimiter(msg), scope, msg_id_panel);
            i2c_master_check_ack(v_ack_received, '0');
            log(config.id_for_bfm, proc_call & "=> ACK was " & to_string(v_ack_received) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
          else
            alert(error, "i2c_master_quick_command sda not '0' when expected after repeated start condition for 10-bit addressing! " & add_msg_delimiter(msg), scope);
          end if;
        end if;

        -- Do the stop condition if action_when_transfer_is_done is set to RELEASE_LINE_AFTER_TRANSFER
        if action_when_transfer_is_done = RELEASE_LINE_AFTER_TRANSFER then
          -- do the stop condition
          log(config.id_for_bfm, proc_call & "=> Setting stop condition.", scope, msg_id_panel);
          i2c_if.sda <= '0';
          wait for config.i2c_bit_time / 4;
          i2c_if.scl <= 'Z';
          -- check for clock stretching
          await_value(i2c_if.scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
          wait for config.master_scl_to_sda;
          i2c_if.sda <= 'Z';
        else                            -- action_when_transfer_is_done = HOLD_LINE_AFTER_TRANSFER
          -- Do not perform the stop condition. Instead release SDA when SCL is low.
          -- This will prepare for a repeated start condition.
          i2c_if.sda <= 'Z';
          wait for config.i2c_bit_time / 4;
          i2c_if.scl <= 'Z';
          -- check for clock stretching
          await_value(i2c_if.scl, '1', MATCH_STD, 0 ns, config.i2c_bit_time, config.i2c_bit_time_severity, msg, scope, ID_NEVER, msg_id_panel);
        end if;

        wait for config.master_stop_condition_hold_time;
      end if;
    else
      alert(error, proc_call & " sda and scl not inactive (high) when wishing to start " & add_msg_delimiter(msg), scope);
    end if;

    -- Compare values, but ignore any leading zero's if widths are different.
    -- Use ID_NEVER so that check_value method does not log when check is OK,
    -- log it here instead.
    v_ack_ok := check_value(v_ack_received, exp_ack, alert_level, msg, scope, ID_NEVER, msg_id_panel);

    if not v_ack_ok then
      v_check_ok := false;
    end if;

    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, slave response was " & to_string(v_ack_received) & ", expected " & to_string(exp_ack) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, proc_call & "=> FAILED, slave response was " & to_string(v_ack_received) & ", expected " & to_string(exp_ack) & ". " & add_msg_delimiter(msg), scope);
    end if;
  end procedure;

end package body i2c_bfm_pkg;
