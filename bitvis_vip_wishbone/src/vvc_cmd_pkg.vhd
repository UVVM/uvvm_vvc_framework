--========================================================================================================================
-- This VVC was generated with Bitvis VVC Generator
--========================================================================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

--========================================================================================================================
--========================================================================================================================
package vvc_cmd_pkg is


  --========================================================================================================================
  -- t_operation
  -- - VVC and BFM operations
  --========================================================================================================================
  type t_operation is (
    NO_OPERATION,
    AWAIT_COMPLETION,
    AWAIT_ANY_COMPLETION,
    ENABLE_LOG_MSG,
    DISABLE_LOG_MSG,
    FLUSH_COMMAND_QUEUE,
    FETCH_RESULT,
    INSERT_DELAY,
    TERMINATE_CURRENT_COMMAND,
    -- VVC local
    WRITE, READ, CHECK
  );

  --<USER_INPUT> Create constants for the maximum sizes to use in this VVC.
  -- You can create VVCs with smaller sizes than these constants, but not larger.
  -- For example, given a VVC with parallel data bus and address bus, constraints should be added for maximum data length
  -- and address length 
  -- Example:
  constant C_VVC_CMD_DATA_MAX_LENGTH          : natural := 1024;
  constant C_VVC_CMD_ADDR_MAX_LENGTH          : natural := 64;
  constant C_VVC_CMD_STRING_MAX_LENGTH        : natural := 300;

  --========================================================================================================================
  -- t_vvc_cmd_record
  -- - Record type used for communication with the VVC
  --========================================================================================================================
  type t_vvc_cmd_record is record
    -- VVC dedicated fields
    addr                  : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH-1 downto 0);
    data                  : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    max_receptions        : integer;
    -- Common VVC fields
    operation             : t_operation;
    proc_call             : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    msg                   : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    cmd_idx               : natural;
    command_type          : t_immediate_or_queued;
    msg_id                : t_msg_id;
    gen_integer_array     : t_integer_array(0 to 1); -- Increase array length if needed
    gen_boolean           : boolean; -- Generic boolean
    timeout               : time;
    alert_level           : t_alert_level;
    delay                 : time;
    quietness             : t_quietness;
  end record;

  constant C_VVC_CMD_DEFAULT : t_vvc_cmd_record := (
    addr                  => (others => '0'),
    data                  => (others => '0'),
    max_receptions        => 1,
    -- Common VVC fields
    operation             => NO_OPERATION,
    proc_call             => (others => NUL),
    msg                   => (others => NUL),
    cmd_idx               => 0,
    command_type          => NO_COMMAND_TYPE,
    msg_id                => NO_ID,
    gen_integer_array     => (others => -1), 
    gen_boolean           => false,
    timeout               => 0 ns, 
    alert_level           => FAILURE,
    delay                 => 0 ns,
    quietness             => NON_QUIET
    
  );

  --========================================================================================================================
  -- shared_vvc_cmd
  -- - Shared variable used for transmitting VVC commands
  --========================================================================================================================
  shared variable shared_vvc_cmd : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;

  --===============================================================================================
  -- t_vvc_result, t_vvc_result_queue_element, t_vvc_response and shared_vvc_response : 
  -- 
  -- - These are used for storing the result of the read/receive BFM commands issued by the VVC,
  -- - so that the result can be transported from the VVC to the sequencer via a 
  --   a fetch_result() call as described in VVC_Framework_common_methods_QuickRef
  -- 
  -- - t_vvc_result matches the return value of read/receive procedure in the BFM.
  --   It can also be defined as a record if multiple return values shall be transported from the BFM
  --===============================================================================================
  subtype  t_vvc_result is std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
  
  type t_vvc_result_queue_element is record
    cmd_idx       : natural;   -- from UVVM handshake mechanism
    result        : t_vvc_result;
  end record;

  type t_vvc_response is record
    fetch_is_accepted    : boolean;
    transaction_result   : t_transaction_result;
    result               : t_vvc_result;
  end record;

  shared variable shared_vvc_response : t_vvc_response;
  
  --===============================================================================================
  -- t_last_received_cmd_idx : 
  -- - Used to store the last queued cmd in vvc interpreter.
  --===============================================================================================
  type t_last_received_cmd_idx is array (t_channel range <>,natural range <>) of integer;
  
  --===============================================================================================
  -- shared_vvc_last_received_cmd_idx
  --  - Shared variable used to get last queued index from vvc to sequencer
  --=============================================================================================== 
  shared variable shared_vvc_last_received_cmd_idx : t_last_received_cmd_idx(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM) := (others => (others => -1));
  
end package vvc_cmd_pkg;

package body vvc_cmd_pkg is

end package body vvc_cmd_pkg;

