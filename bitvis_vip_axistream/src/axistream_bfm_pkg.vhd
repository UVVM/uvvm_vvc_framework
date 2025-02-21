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
-- VHDL unit     : Bitvis VIP AXISTREAM Library : axistream_bfm_pkg
--
-- Description   : See library quick reference (under 'doc') and README-file(s).
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--========================================================================================================================
--========================================================================================================================
package axistream_bfm_pkg is

  --========================================================================================================================
  -- Types and constants for AXISTREAM_BFM
  --========================================================================================================================
  constant C_BFM_SCOPE : string := "AXISTREAM_BFM";

  -- Constants for the maximum sizes to use in this BFM. Can be modified in adaptations_pkg.
  constant C_MAX_TUSER_BITS : positive := C_AXISTREAM_BFM_MAX_TUSER_BITS;
  constant C_MAX_TSTRB_BITS : positive := C_AXISTREAM_BFM_MAX_TSTRB_BITS;
  constant C_MAX_TID_BITS   : positive := C_AXISTREAM_BFM_MAX_TID_BITS;
  constant C_MAX_TDEST_BITS : positive := C_AXISTREAM_BFM_MAX_TDEST_BITS;

  constant C_RANDOM          : integer := -1;
  constant C_MULTIPLE_RANDOM : integer := -2;

  type t_user_array is array (natural range <>) of std_logic_vector(C_MAX_TUSER_BITS - 1 downto 0);
  type t_strb_array is array (natural range <>) of std_logic_vector(C_MAX_TSTRB_BITS - 1 downto 0);
  type t_id_array is array (natural range <>) of std_logic_vector(C_MAX_TID_BITS - 1 downto 0);
  type t_dest_array is array (natural range <>) of std_logic_vector(C_MAX_TDEST_BITS - 1 downto 0);

  -- Interface record for BFM signals
  type t_axistream_if is record
    tdata  : std_logic_vector;      -- Data. Width is constrained when the procedure is called
    tkeep  : std_logic_vector;      -- One valid-bit per data byte
    tuser  : std_logic_vector;      -- User sideband data
    tvalid : std_logic;             -- Data valid
    tlast  : std_logic;             -- Active high during last data word in packet.
    tready : std_logic;             -- Backpressure
    tstrb  : std_logic_vector;      -- Treated as sideband data by BFM: tstrb does not affect tdata
    tid    : std_logic_vector;      -- Treated as sideband data by BFM
    tdest  : std_logic_vector;      -- Treated as sideband data by BFM
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_axistream_bfm_config is record
    -- Common
    max_wait_cycles                : integer; -- Used for setting the maximum cycles to wait before an alert is issued when waiting for ready or valid signals from the DUT.
    max_wait_cycles_severity       : t_alert_level; -- The above timeout will have this severity
    clock_period                   : time; -- Period of the clock signal.
    clock_period_margin            : time; -- Input clock period margin to specified clock_period
    clock_margin_severity          : t_alert_level; -- The above margin will have this severity
    setup_time                     : time; -- Setup time for generated signals, set to clock_period/4
    hold_time                      : time; -- Hold time for generated signals, set to clock_period/4
    bfm_sync                       : t_bfm_sync; -- Synchronisation of the BFM procedures, i.e. using clock signals, using setup_time and hold_time.
    match_strictness               : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    byte_endianness                : t_byte_endianness; -- Byte ordering from left (big-endian) or right (little-endian)
    -- config for axistream_transmit()
    valid_low_at_word_num          : integer; -- Word index where the Source BFM shall deassert valid
    valid_low_multiple_random_prob : real range 0.0 to 1.0; -- Probability of how often valid shall be deasserted when using C_MULTIPLE_RANDOM
    valid_low_duration             : integer; -- Number of clock cycles to deassert valid
    valid_low_max_random_duration  : integer; -- Maximum number of clock cycles to deassert valid when using C_RANDOM
    -- config for axistream_receive()
    check_packet_length            : boolean; -- When true, receive() will check that last is set at data_array'high
    protocol_error_severity        : t_alert_level; -- severity if protocol errors are detected by axistream_receive()
    ready_low_at_word_num          : integer; -- Word index where the Sink BFM shall deassert ready
    ready_low_multiple_random_prob : real range 0.0 to 1.0; -- Probability of how often ready shall be deasserted when using C_MULTIPLE_RANDOM
    ready_low_duration             : integer; -- Number of clock cycles to deassert ready
    ready_low_max_random_duration  : integer; -- Maximum number of clock cycles to deassert ready when using C_RANDOM
    ready_default_value            : std_logic; -- Which value the BFM shall set ready to between accesses.
    -- Common
    id_for_bfm                     : t_msg_id; -- The message ID used as a general message ID in the BFM
  end record;

  -- Define the default value for the BFM config
  constant C_AXISTREAM_BFM_CONFIG_DEFAULT : t_axistream_bfm_config := (
    max_wait_cycles                => 100,
    max_wait_cycles_severity       => ERROR,
    clock_period                   => -1 ns,
    clock_period_margin            => 0 ns,
    clock_margin_severity          => TB_ERROR,
    setup_time                     => -1 ns,
    hold_time                      => -1 ns,
    bfm_sync                       => SYNC_ON_CLOCK_ONLY,
    match_strictness               => MATCH_EXACT,
    byte_endianness                => LOWER_BYTE_LEFT,
    valid_low_at_word_num          => 0,
    valid_low_multiple_random_prob => 0.5,
    valid_low_duration             => 0,
    valid_low_max_random_duration  => 5,
    check_packet_length            => false,
    protocol_error_severity        => ERROR,
    ready_low_at_word_num          => 0,
    ready_low_multiple_random_prob => 0.5,
    ready_low_duration             => 0,
    ready_low_max_random_duration  => 5,
    ready_default_value            => '0',
    id_for_bfm                     => ID_BFM
  );

  --========================================================================================================================
  -- BFM procedures
  --========================================================================================================================
  -- This function returns an AXI-Stream interface with initialized signals.
  -- All BFM output signals are initialized to 0
  -- All BFM input signals are initialized to Z
  function init_axistream_if_signals(
    is_master  : boolean;           -- When true, this BFM drives data signals
    data_width : natural;
    user_width : natural;
    id_width   : natural;
    dest_width : natural;
    config     : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) return t_axistream_if;

  --------------------------------------------------------
  --
  -- AXIStream Transmit
  --
  --------------------------------------------------------
  --
  -- Source: BFM
  -- Sink:   DUT
  --¨
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    constant data_array   : in t_byte_array; -- Byte in index 0 is transmitted first
    constant user_array   : in t_user_array;
    constant strb_array   : in t_strb_array;
    constant id_array     : in t_id_array;
    constant dest_array   : in t_dest_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- t_slv_array overload
  procedure axistream_transmit(
    constant data_array   : in t_slv_array; -- Word in index 0 is transmitted first
    constant user_array   : in t_user_array;
    constant strb_array   : in t_strb_array;
    constant id_array     : in t_id_array;
    constant dest_array   : in t_dest_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- std_logic_vector overload
  procedure axistream_transmit(
    constant data_array   : in std_logic_vector;
    constant user_array   : in t_user_array;
    constant strb_array   : in t_strb_array;
    constant id_array     : in t_id_array;
    constant dest_array   : in t_dest_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- Overloaded version without records
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    constant data_array          : in t_byte_array;
    constant user_array          : in t_user_array;
    constant strb_array          : in t_strb_array;
    constant id_array            : in t_id_array;
    constant dest_array          : in t_dest_array;
    constant msg                 : in string                 := "";
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- t_slv_array overload
  procedure axistream_transmit(
    constant data_array          : in t_slv_array;
    constant user_array          : in t_user_array;
    constant strb_array          : in t_strb_array;
    constant id_array            : in t_id_array;
    constant dest_array          : in t_dest_array;
    constant msg                 : in string                 := "";
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- std_logic_vector overload
  procedure axistream_transmit(
    constant data_array          : in std_logic_vector;
    constant user_array          : in t_user_array;
    constant strb_array          : in t_strb_array;
    constant id_array            : in t_id_array;
    constant dest_array          : in t_dest_array;
    constant msg                 : in string                 := "";
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- Overload for default strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    constant data_array   : in t_byte_array; -- Byte in index 0 is transmitted first
    constant user_array   : in t_user_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- t_slv_array overload
  procedure axistream_transmit(
    constant data_array   : in t_slv_array; -- Byte in index 0 is transmitted first
    constant user_array   : in t_user_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- std_logic_vector overload
  procedure axistream_transmit(
    constant data_array   : in std_logic_vector;
    constant user_array   : in t_user_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- Overload for default user_array, strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    constant data_array   : in t_byte_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- t_slv_array overload
  procedure axistream_transmit(
    constant data_array   : in t_slv_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- std_logic_vector overload
  procedure axistream_transmit(
    constant data_array   : in std_logic_vector;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );

  --------------------------------------------------------
  --
  -- AXIStream Receive
  --
  --------------------------------------------------------
  --
  -- Source: DUT
  -- Sink:   BFM
  --
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_receive_bytes(
    variable data_array    : inout t_byte_array;
    variable data_length   : inout natural; -- Number of bytes received
    variable user_array    : inout t_user_array;
    variable strb_array    : inout t_strb_array;
    variable id_array      : inout t_id_array;
    variable dest_array    : inout t_dest_array;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   axistream_if  : inout t_axistream_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  );
  procedure axistream_receive(
    variable data_array    : inout t_slv_array;
    variable data_length   : inout natural; -- Number of bytes received
    variable user_array    : inout t_user_array;
    variable strb_array    : inout t_strb_array;
    variable id_array      : inout t_id_array;
    variable dest_array    : inout t_dest_array;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   axistream_if  : inout t_axistream_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  );
  -- Overloaded version without records
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_receive_bytes(
    variable data_array          : inout t_byte_array;
    variable data_length         : inout natural; -- Number of bytes received
    variable user_array          : inout t_user_array;
    variable strb_array          : inout t_strb_array;
    variable id_array            : inout t_id_array;
    variable dest_array          : inout t_dest_array;
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call       : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  );
  -- Overloaded version without records
  procedure axistream_receive(
    variable data_array          : inout t_slv_array;
    variable data_length         : inout natural; -- Number of bytes received
    variable user_array          : inout t_user_array;
    variable strb_array          : inout t_strb_array;
    variable id_array            : inout t_id_array;
    variable dest_array          : inout t_dest_array;
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call       : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  --------------------------------------------------------
  --
  -- AXIStream Expect
  --
  --------------------------------------------------------
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    constant exp_data_array : in t_byte_array; -- Expected data
    constant exp_user_array : in t_user_array; -- Expected tuser
    constant exp_strb_array : in t_strb_array; -- Expected tstrb
    constant exp_id_array   : in t_id_array;   -- Expected tid
    constant exp_dest_array : in t_dest_array; -- Expected tdest
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- t_slv_array overload
  procedure axistream_expect(
    constant exp_data_array : in t_slv_array;  -- Expected data
    constant exp_user_array : in t_user_array; -- Expected tuser
    constant exp_strb_array : in t_strb_array; -- Expected tstrb
    constant exp_id_array   : in t_id_array;   -- Expected tid
    constant exp_dest_array : in t_dest_array; -- Expected tdest
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- std_logic_vector overload
  procedure axistream_expect(
    constant exp_data_array : in std_logic_vector; -- Expected data
    constant exp_user_array : in t_user_array;     -- Expected tuser
    constant exp_strb_array : in t_strb_array;     -- Expected tstrb
    constant exp_id_array   : in t_id_array;       -- Expected tid
    constant exp_dest_array : in t_dest_array;     -- Expected tdest
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- Overloaded version without records
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    constant exp_data_array      : in t_byte_array; -- Expected data
    constant exp_user_array      : in t_user_array; -- Expected tuser
    constant exp_strb_array      : in t_strb_array; -- Expected tstrb
    constant exp_id_array        : in t_id_array;   -- Expected tid
    constant exp_dest_array      : in t_dest_array; -- Expected tdest
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in t_alert_level          := error;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- t_slv_array overload
  procedure axistream_expect(
    constant exp_data_array      : in t_slv_array;  -- Expected data
    constant exp_user_array      : in t_user_array; -- Expected tuser
    constant exp_strb_array      : in t_strb_array; -- Expected tstrb
    constant exp_id_array        : in t_id_array;   -- Expected tid
    constant exp_dest_array      : in t_dest_array; -- Expected tdest
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in t_alert_level          := error;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- std_logic_vector overload
  procedure axistream_expect(
    constant exp_data_array      : in std_logic_vector; -- Expected data
    constant exp_user_array      : in t_user_array;     -- Expected tuser
    constant exp_strb_array      : in t_strb_array;     -- Expected tstrb
    constant exp_id_array        : in t_id_array;       -- Expected tid
    constant exp_dest_array      : in t_dest_array;     -- Expected tdest
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in t_alert_level          := error;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- Overload for default strb_array, id_array, dest_array
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    constant exp_data_array : in t_byte_array;
    constant exp_user_array : in t_user_array;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- t_slv_array overload
  procedure axistream_expect(
    constant exp_data_array : in t_slv_array;
    constant exp_user_array : in t_user_array;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- std_logic_vector overload
  procedure axistream_expect(
    constant exp_data_array : in std_logic_vector;
    constant exp_user_array : in t_user_array;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- Overload for default user_array, strb_array, id_array, dest_array
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    constant exp_data_array : in t_byte_array;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- t_slv_array overload
  procedure axistream_expect(
    constant exp_data_array : in t_slv_array;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );
  -- std_logic_vector overload
  procedure axistream_expect(
    constant exp_data_array : in std_logic_vector;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  );

end package axistream_bfm_pkg;

--========================================================================================================================
--========================================================================================================================

package body axistream_bfm_pkg is

  function init_axistream_if_signals(
    is_master  : boolean;           -- When true, this BFM drives data signals
    data_width : natural;
    user_width : natural;
    id_width   : natural;
    dest_width : natural;
    config     : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) return t_axistream_if is
    variable init_if : t_axistream_if(tdata(data_width - 1 downto 0),
                                      tkeep(data_width / 8 - 1 downto 0),
                                      tuser(user_width - 1 downto 0),
                                      tstrb(data_width / 8 - 1 downto 0),
                                      tid(id_width - 1 downto 0),
                                      tdest(dest_width - 1 downto 0)
                                     );
  begin

    if is_master then
      -- from slave to master
      init_if.tready := 'Z';

      -- from master to slave
      init_if.tvalid := '0';
      init_if.tdata  := (init_if.tdata'range => '0');
      init_if.tkeep  := (init_if.tkeep'range => '0');
      init_if.tuser  := (init_if.tuser'range => '0');
      init_if.tstrb  := (init_if.tstrb'range => '0');
      init_if.tid    := (init_if.tid'range => '0');
      init_if.tdest  := (init_if.tdest'range => '0');
      init_if.tlast  := '0';
    else
      -- from slave to master
      init_if.tready := config.ready_default_value;
      --init_if.tready := '0';
      -- from master to slave
      init_if.tvalid := 'Z';
      init_if.tdata  := (init_if.tdata'range => 'Z');
      init_if.tkeep  := (init_if.tkeep'range => 'Z');
      init_if.tuser  := (init_if.tuser'range => 'Z');
      init_if.tstrb  := (init_if.tstrb'range => 'Z');
      init_if.tid    := (init_if.tid'range => 'Z');
      init_if.tdest  := (init_if.tdest'range => 'Z');
      init_if.tlast  := 'Z';
    end if;
    return init_if;
  end function;

  --------------------------------------------------------
  --
  -- AXIStream Transmit
  --
  --------------------------------------------------------
  -- Send a packet on the AXI interface.
  -- Packet length and data is defined by data_array
  -- tuser is set based on user_array,
  -- tstrb is set based on strb_array, etc
  procedure axistream_transmit(
    constant data_array   : in t_slv_array; -- Word in index 0 is transmitted first
    constant user_array   : in t_user_array;
    constant strb_array   : in t_strb_array;
    constant id_array     : in t_id_array;
    constant dest_array   : in t_dest_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    constant C_DATA_ARRAY_BYTES_PER_WORD    : natural := data_array(data_array'low)'length / 8;
    constant C_PROC_CALL                    : string  := "axistream_transmit(" & to_string(data_array'length) & " words[" & to_string(C_DATA_ARRAY_BYTES_PER_WORD * 8) & "b])";
    constant C_NUM_BYTES_PER_WORD           : natural := axistream_if.tdata'length / 8;
    constant C_NUM_USER_BITS_PER_WORD       : natural := axistream_if.tuser'length;
    constant C_NUM_STRB_BITS_PER_WORD       : natural := axistream_if.tstrb'length;
    constant C_NUM_ID_BITS_PER_WORD         : natural := axistream_if.tid'length;
    constant C_NUM_DEST_BITS_PER_WORD       : natural := axistream_if.tdest'length;

    variable v_data_byte_array              : t_slv_array(0 to (data_array'length * C_DATA_ARRAY_BYTES_PER_WORD) - 1)(7 downto 0);
    variable v_byte_in_word                 : integer range 0 to C_NUM_BYTES_PER_WORD - 1 := 0; -- current byte within the data word
    variable v_clk_cycles_waited            : natural                                     := 0;
    variable v_wait_for_next_transfer_cycle : boolean; -- When set, the BFM shall wait for at least one clock cycle, until tready='1' before continuing
    variable v_time_of_rising_edge          : time                                        := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge         : time                                        := -1 ns; -- time stamp for clk period checking
    variable v_valid_low_duration           : natural                                     := 0;
    variable v_valid_low_cycle_count        : natural                                     := 0;
    variable v_timeout                      : boolean                                     := false;
    variable v_tready                       : std_logic; -- Sampled tready for the current clock cycle
    variable v_check_ok                     : boolean                                     := true;
  begin
    v_check_ok := v_check_ok and check_value(axistream_if.tdata'length >= 8, TB_ERROR, "Sanity check: Check that tdata is at least one byte wide. Narrower tdata is not supported.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(axistream_if.tdata'length mod 8 = 0, TB_ERROR, "Sanity check: Check that tdata is an integer number of bytes wide.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(axistream_if.tuser'length <= C_MAX_TUSER_BITS, TB_ERROR, "Sanity check: Check that C_MAX_TUSER_BITS is high enough for axistream_if.tuser.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(axistream_if.tid'length <= C_MAX_TID_BITS, TB_ERROR, "Sanity check: Check that C_MAX_TID_BITS is high enough for axistream_if.tid.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(axistream_if.tdest'length <= C_MAX_TDEST_BITS, TB_ERROR, "Sanity check: Check that C_MAX_TDEST_BITS is high enough for axistream_if.tdest.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(axistream_if.tkeep'length = (axistream_if.tdata'length / 8), TB_ERROR, "Sanity check: Check that width of tkeep equals number of bytes in tdata.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(axistream_if.tstrb'length = (axistream_if.tdata'length / 8), TB_ERROR, "Sanity check: Check that width of tstrb equals number of bytes in tdata.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(data_array(data_array'low)'length mod 8 = 0, TB_ERROR, "Sanity check: Check that data_array word is N*byte", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(data_array'ascending, TB_ERROR, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(user_array'ascending, TB_ERROR, "Sanity check: Check that user_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(strb_array'ascending, TB_ERROR, "Sanity check: Check that strb_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(id_array'ascending, TB_ERROR, "Sanity check: Check that id_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    v_check_ok := v_check_ok and check_value(dest_array'ascending, TB_ERROR, "Sanity check: Check that dest_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      v_check_ok := v_check_ok and check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
      v_check_ok := v_check_ok and check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
      v_check_ok := v_check_ok and check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    end if;
    if not (v_check_ok) then
      return;
    end if;

    axistream_if <= init_axistream_if_signals(is_master  => true, -- this BFM drives data signals
                                              data_width => axistream_if.tdata'length,
                                              user_width => axistream_if.tuser'length,
                                              id_width   => axistream_if.tid'length,
                                              dest_width => axistream_if.tdest'length,
                                              config     => config);

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    log(ID_PACKET_INITIATE, C_PROC_CALL & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    -- Convert SLV with variable word-width to byte-width
    v_data_byte_array := convert_slv_array_to_byte_array(data_array, config.byte_endianness);

    ------------------------------------------------------------------------------------------------------------
    -- Send byte by byte. There may be multiple bytes per clock cycle, depending on axistream_if'tdata width.
    ------------------------------------------------------------------------------------------------------------
    for byte in 0 to v_data_byte_array'high loop
      log(ID_PACKET_DATA, C_PROC_CALL & "=> Tx " & to_string(v_data_byte_array(byte), HEX, AS_IS, INCL_RADIX) & --     ", tuser=" & to_string(user_array(byte/C_NUM_BYTES_PER_WORD), HEX, AS_IS, INCL_RADIX) &
      --     ", tstrb=" & to_string(strb_array(byte/C_NUM_BYTES_PER_WORD), HEX, AS_IS, INCL_RADIX) &
      --     ", tid="   & to_string(id_array(byte/C_NUM_BYTES_PER_WORD),   HEX, AS_IS, INCL_RADIX) &
      --     ", tdest=" & to_string(dest_array(byte/C_NUM_BYTES_PER_WORD), HEX, AS_IS, INCL_RADIX) &
      ", byte# " & to_string(byte) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);

      -------------------------------------------------------------------
      -- Set tvalid low (once per transmission or multiple random times)
      -------------------------------------------------------------------
      if v_byte_in_word = 0 and (config.valid_low_duration > 0 or config.valid_low_duration = C_RANDOM) then
        v_valid_low_cycle_count := 0;
        -- Check if pulse duration is defined or random
        if config.valid_low_duration > 0 then
          v_valid_low_duration := config.valid_low_duration;
        elsif config.valid_low_duration = C_RANDOM then
          v_valid_low_duration := random(1, config.valid_low_max_random_duration);
        end if;

        -- Deassert tvalid once per transmission on a specific word
        if config.valid_low_at_word_num = byte / C_NUM_BYTES_PER_WORD then
          while v_valid_low_cycle_count < v_valid_low_duration loop
            v_valid_low_cycle_count := v_valid_low_cycle_count + 1;
            wait until rising_edge(clk);
            wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
          end loop;

        -- Deassert tvalid multiple random times per transmission
        elsif config.valid_low_at_word_num = C_MULTIPLE_RANDOM and random(0.0, 1.0) <= config.valid_low_multiple_random_prob then
          while v_valid_low_cycle_count < v_valid_low_duration loop
            v_valid_low_cycle_count := v_valid_low_cycle_count + 1;
            wait until rising_edge(clk);
            wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
          end loop;
        end if;
      end if;

      axistream_if.tvalid <= '1';

      -- Byte locations within the data word is described in chapter 2.3 in "ARM IHI0051A"
      axistream_if.tdata(7 + 8 * v_byte_in_word downto 8 * v_byte_in_word) <= v_data_byte_array(byte);

      -- Set sideband data for this transfer (i.e. this word)
      if v_byte_in_word = 0 then
        axistream_if.tuser(C_NUM_USER_BITS_PER_WORD - 1 downto 0) <= user_array(byte / C_NUM_BYTES_PER_WORD)(C_NUM_USER_BITS_PER_WORD - 1 downto 0);
        axistream_if.tstrb(C_NUM_STRB_BITS_PER_WORD - 1 downto 0) <= strb_array(byte / C_NUM_BYTES_PER_WORD)(C_NUM_STRB_BITS_PER_WORD - 1 downto 0);
        axistream_if.tid(C_NUM_ID_BITS_PER_WORD - 1 downto 0)     <= id_array(byte / C_NUM_BYTES_PER_WORD)(C_NUM_ID_BITS_PER_WORD - 1 downto 0);
        axistream_if.tdest(C_NUM_DEST_BITS_PER_WORD - 1 downto 0) <= dest_array(byte / C_NUM_BYTES_PER_WORD)(C_NUM_DEST_BITS_PER_WORD - 1 downto 0);
      end if;

      -- TKEEP[x] is associated with TDATA[(7+8*v_byte_in_word) : 8*v_byte_in_word].
      axistream_if.tkeep(v_byte_in_word) <= '1';

      -- Default: Go to next 'byte' iteration in zero time (when tdata is not completely filled with bytes).
      v_wait_for_next_transfer_cycle := false;

      if byte = v_data_byte_array'high then
        -- Packet done.
        axistream_if.tlast             <= '1';
        v_wait_for_next_transfer_cycle := true; -- No more bytes to fill in tdata
      else
        axistream_if.tlast <= '0';
      end if;

      if v_byte_in_word = C_NUM_BYTES_PER_WORD - 1 then
        -- Next byte is in the next clk cycle
        v_byte_in_word                 := 0;
        v_wait_for_next_transfer_cycle := true; -- No more bytes to fill in tdata
      else
        -- Next byte is in the same clk cycle
        v_byte_in_word := v_byte_in_word + 1;
      end if;

      --
      -- If no more bytes to fill in tdata, wait until the transfer takes place (tvalid=1 and tready=1)
      --
      if v_wait_for_next_transfer_cycle then
        wait until rising_edge(clk);
        if v_time_of_rising_edge = -1 ns then
          v_time_of_rising_edge := now;
        end if;
        v_tready := axistream_if.tready;
        check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                  config.clock_period, config.clock_period_margin, config.clock_margin_severity);

        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

        v_clk_cycles_waited := 1;
        -- Check tready signal is asserted (sampled at rising_edge)
        while v_tready = '0' loop
          wait until rising_edge(clk);
          v_tready := axistream_if.tready;

          -- Wait according to config.bfm_sync setup
          wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

          v_clk_cycles_waited := v_clk_cycles_waited + 1;
          -- If timeout then exit procedure
          if v_clk_cycles_waited >= config.max_wait_cycles then
            v_timeout := true;
            exit;
          end if;
        end loop;
        if v_timeout then
          exit;
        end if;

        -- Default values for the next clk cycle
        axistream_if <= init_axistream_if_signals(is_master  => true, -- this BFM drives data signals
                                                  data_width => axistream_if.tdata'length,
                                                  user_width => axistream_if.tuser'length,
                                                  id_width   => axistream_if.tid'length,
                                                  dest_width => axistream_if.tdest'length,
                                                  config     => config);
      end if;
    end loop;

    -- Done. Check if there was a timeout or it was successful
    if v_timeout then
      alert(config.max_wait_cycles_severity, C_PROC_CALL & "=> Failed. Timeout while waiting for tready. " & add_msg_delimiter(msg), scope);
    else
      log(ID_PACKET_COMPLETE, C_PROC_CALL & "=> Tx DONE. " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure axistream_transmit;

  -- Send a packet on the AXI interface.
  -- Packet length and data is defined by data_array
  -- tuser is set based on user_array,
  -- tstrb is set based on strb_array, etc
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    constant data_array   : in t_byte_array; -- Byte in index 0 is transmitted first
    constant user_array   : in t_user_array;
    constant strb_array   : in t_strb_array;
    constant id_array     : in t_id_array;
    constant dest_array   : in t_dest_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    constant C_PROC_NAME  : string  := "axistream_transmit_bytes";
    constant C_PROC_CALL  : string  := "axistream_transmit_bytes(" & to_string(data_array'length) & "B)";
    variable v_check_ok : boolean := false;
  begin
    -- DEPRECATE: data_array as t_byte_array will be removsed in next major release
    deprecate(C_PROC_NAME, "data_array as t_byte_array has been deprecated. Use data_array as t_slv_array.");

    -- t_byte_array sanity check
    v_check_ok := check_value(data_array'length > 0, TB_ERROR, C_PROC_CALL & "data_array length must be > 0", scope, ID_NEVER, msg_id_panel);
    if v_check_ok then
      -- call t_slv_array overloaded procedure
      axistream_transmit(data_array, user_array, strb_array, id_array, dest_array, msg, clk, axistream_if, scope, msg_id_panel, config);
    end if;
  end procedure axistream_transmit_bytes;

  -- SLV overload
  procedure axistream_transmit(
    constant data_array   : in std_logic_vector;
    constant user_array   : in t_user_array;
    constant strb_array   : in t_strb_array;
    constant id_array     : in t_id_array;
    constant dest_array   : in t_dest_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    variable v_data_array : t_slv_array(0 to 0)(data_array'length - 1 downto 0);
  begin
    v_data_array(0) := data_array;
    axistream_transmit(v_data_array, user_array, strb_array, id_array, dest_array, msg, clk, axistream_if, scope, msg_id_panel, config);
  end procedure;

  -- Overload that doesn't use records for the AXI interface:
  -- (In turn calls the record version)
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    constant data_array          : in t_byte_array;
    constant user_array          : in t_user_array;
    constant strb_array          : in t_strb_array;
    constant id_array            : in t_id_array;
    constant dest_array          : in t_dest_array;
    constant msg                 : in string                 := "";
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- call overloading procedure
    axistream_transmit_bytes(
      data_array          => data_array,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure axistream_transmit_bytes;

    -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_transmit(
    constant data_array          : in t_slv_array;
    constant user_array          : in t_user_array;
    constant strb_array          : in t_strb_array;
    constant id_array            : in t_id_array;
    constant dest_array          : in t_dest_array;
    constant msg                 : in string                 := "";
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- call overloading t_slv_array procedure
    axistream_transmit(
      data_array          => data_array,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure axistream_transmit;

    -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_transmit(
    constant data_array          : in std_logic_vector;
    constant user_array          : in t_user_array;
    constant strb_array          : in t_strb_array;
    constant id_array            : in t_id_array;
    constant dest_array          : in t_dest_array;
    constant msg                 : in string                 := "";
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
  begin
    -- call overloading slv procedure
    axistream_transmit(
      data_array          => data_array,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure axistream_transmit;

  -- Overload with default value for  strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    constant data_array   : in t_byte_array; -- Byte in index 0 is transmitted first
    constant user_array   : in t_user_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- One entry per word. Max words possible is the number of bytes in data_array
    constant C_STRB_ARRAY_DEFAULT : t_strb_array(0 to data_array'high) := (others => (others => '0'));
    constant C_ID_ARRAY_DEFAULT   : t_id_array(0 to data_array'high)   := (others => (others => '0'));
    constant C_DEST_ARRAY_DEFAULT : t_dest_array(0 to data_array'high) := (others => (others => '0'));
  begin
    axistream_transmit_bytes(
      data_array   => data_array,
      user_array   => user_array,
      strb_array   => C_STRB_ARRAY_DEFAULT,
      id_array     => C_ID_ARRAY_DEFAULT,
      dest_array   => C_DEST_ARRAY_DEFAULT,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit_bytes;

    -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_transmit(
    constant data_array   : in t_slv_array; -- Byte in index 0 is transmitted first
    constant user_array   : in t_user_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- One entry per word. Max words possible is the number of bytes in data_array
    constant C_STRB_ARRAY_DEFAULT : t_strb_array(0 to data_array'high) := (others => (others => '0'));
    constant C_ID_ARRAY_DEFAULT   : t_id_array(0 to data_array'high)   := (others => (others => '0'));
    constant C_DEST_ARRAY_DEFAULT : t_dest_array(0 to data_array'high) := (others => (others => '0'));
  begin
    -- call overloading t_slv_array procedure
    axistream_transmit(
      data_array   => data_array,
      user_array   => user_array,
      strb_array   => C_STRB_ARRAY_DEFAULT,
      id_array     => C_ID_ARRAY_DEFAULT,
      dest_array   => C_DEST_ARRAY_DEFAULT,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit;

  -- SLV overload with default values for strb_array, id_array and dest_array
  procedure axistream_transmit(
    constant data_array   : in std_logic_vector;
    constant user_array   : in t_user_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- One entry per word. Max words possible is the number of words in data_array
    constant C_STRB_ARRAY_DEFAULT : t_strb_array(0 to data_array'high) := (others => (others => '0'));
    constant C_ID_ARRAY_DEFAULT   : t_id_array(0 to data_array'high)   := (others => (others => '0'));
    constant C_DEST_ARRAY_DEFAULT : t_dest_array(0 to data_array'high) := (others => (others => '0'));
  begin
    axistream_transmit(
      data_array   => data_array,
      user_array   => user_array,
      strb_array   => C_STRB_ARRAY_DEFAULT,
      id_array     => C_ID_ARRAY_DEFAULT,
      dest_array   => C_DEST_ARRAY_DEFAULT,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit;

  -- Overload with default value for user_array, strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    constant data_array   : in t_byte_array; -- Byte in index 0 is transmitted first
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    constant C_USER_ARRAY_DEFAULT : t_user_array(0 to data_array'high) := (others => (others => '0'));
  begin
    -- Calling another overload that fills in strb_array, id_array, dest_array
    axistream_transmit_bytes(
      data_array   => data_array,
      user_array   => C_USER_ARRAY_DEFAULT,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit_bytes;

  -- Overload with default values for user_array, strb_array, id_array and dest_array
  procedure axistream_transmit(
    constant data_array   : in t_slv_array; -- Word in index 0 is transmitted first
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    constant C_USER_ARRAY_DEFAULT : t_user_array(0 to data_array'high) := (others => (others => '0'));
  begin
    axistream_transmit(
      data_array   => data_array,
      user_array   => C_USER_ARRAY_DEFAULT,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit;

  -- SLV overload with default values for user_array, strb_array, id_array and dest_array
  procedure axistream_transmit(
    constant data_array   : in std_logic_vector;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    constant C_USER_ARRAY_DEFAULT : t_user_array(0 to data_array'high) := (others => (others => '0'));
  begin
    axistream_transmit(
      data_array   => data_array,
      user_array   => C_USER_ARRAY_DEFAULT,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit;

  --------------------------------------------------------
  --
  -- AXIStream Receive
  --
  --------------------------------------------------------
  -- Receive a packet, store it in data_array
  -- data_array'length can be longer than the actual packet, so that you can call receive() without knowing the length to be expected.
  procedure axistream_receive(
    variable data_array    : inout t_slv_array;
    variable data_length   : inout natural; -- Number of bytes received
    variable user_array    : inout t_user_array;
    variable strb_array    : inout t_strb_array;
    variable id_array      : inout t_id_array;
    variable dest_array    : inout t_dest_array;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   axistream_if  : inout t_axistream_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant C_DATA_ARRAY_BYTES_PER_WORD : natural := data_array(data_array'low)'length / 8;
    constant C_NUM_BYTES_PER_WORD        : natural := axistream_if.tdata'length / 8;
    constant C_NUM_USER_BITS_PER_WORD    : natural := axistream_if.tuser'length;
    constant C_NUM_STRB_BITS_PER_WORD    : natural := axistream_if.tstrb'length;
    constant C_NUM_ID_BITS_PER_WORD      : natural := axistream_if.tid'length;
    constant C_NUM_DEST_BITS_PER_WORD    : natural := axistream_if.tdest'length;
    constant C_LOCAL_PROC_NAME           : string  := "axistream_receive"; -- Internal proc_name; used if called from sequncer or VVC
    constant C_LOCAL_PROC_CALL           : string  := C_LOCAL_PROC_NAME & "()"; -- Internal proc_call; used if called from sequncer or VVC

    variable v_proc_call                 : line; -- Current proc_call, external or local
    variable v_data_byte_array           : t_slv_array(0 to (data_array'length * C_DATA_ARRAY_BYTES_PER_WORD) - 1)(7 downto 0);
    variable v_byte_in_word              : integer range 0 to C_NUM_BYTES_PER_WORD - 1 := 0; -- current Byte within the data word
    variable v_byte_cnt                  : integer                                     := 0; -- # bytes received
    variable v_timeout                   : boolean                                     := false;
    variable v_done                      : boolean                                     := false;
    variable v_invalid_count             : integer                                     := 0; -- # cycles without valid being asserted
    variable v_byte_idx                  : integer;
    variable v_word_idx                  : integer;
    variable v_ready_low_duration        : natural                                     := 0;
    variable v_ready_low_cycle_count     : natural                                     := 0;
    variable v_time_of_rising_edge       : time                                        := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge      : time                                        := -1 ns; -- time stamp for clk period checking
    variable v_sample_data_now           : boolean                                     := false;
  begin
    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'axistream_receive...'
      write(v_proc_call, C_LOCAL_PROC_CALL);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing axistream_receive...'
      write(v_proc_call, ext_proc_call & " while executing " & C_LOCAL_PROC_NAME);
    end if;

    check_value(axistream_if.tuser'length <= C_MAX_TUSER_BITS, TB_ERROR, "Sanity check: Check that C_MAX_TUSER_BITS is high enough for axistream_if.tuser.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tdata'length >= 8, TB_ERROR, "Sanity check: Check that tdata is at least one byte wide. Narrower tdata is not supported.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tdata'length mod 8 = 0, TB_ERROR, "Sanity check: Check that tdata is an integer number of bytes wide.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tid'length <= C_MAX_TID_BITS, TB_ERROR, "Sanity check: Check that C_MAX_TID_BITS is high enough for axistream_if.tid.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tdest'length <= C_MAX_TDEST_BITS, TB_ERROR, "Sanity check: Check that C_MAX_TDEST_BITS is high enough for axistream_if.tdest.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tkeep'length = (axistream_if.tdata'length / 8), TB_ERROR, "Sanity check: Check that width of tkeep equals number of bytes in tdata.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tstrb'length = (axistream_if.tdata'length / 8), TB_ERROR, "Sanity check: Check that width of tstrb equals number of bytes in tdata.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(data_array'ascending, TB_ERROR, "Sanity check: Check that data_array is ascending (defined with 'to'), for knowing which byte is sent first", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(user_array'ascending, TB_ERROR, "Sanity check: Check that user_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(strb_array'ascending, TB_ERROR, "Sanity check: Check that strb_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(id_array'ascending, TB_ERROR, "Sanity check: Check that id_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(dest_array'ascending, TB_ERROR, "Sanity check: Check that dest_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    end if;

    -- Avoid driving inputs
    axistream_if <= init_axistream_if_signals(
      is_master  => false,
      data_width => axistream_if.tdata'length,
      user_width => axistream_if.tuser'length,
      id_width   => axistream_if.tid'length,
      dest_width => axistream_if.tdest'length,
      config     => config);

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    log(ID_PACKET_INITIATE, v_proc_call.all & "=> Receive packet. " & add_msg_delimiter(msg), scope, msg_id_panel);

    ------------------------------------------------------------------------------------------------------------
    -- Sample byte by byte. There may be multiple bytes per clock cycle, depending on axistream_if'tdata width.
    ------------------------------------------------------------------------------------------------------------
    while not v_done loop
      --------------------------------------------------------------------------------------
      -- Set tready low before given byte (once per transmission or multiple random times)
      --------------------------------------------------------------------------------------
      if v_byte_in_word = 0 and (config.ready_low_duration > 0 or config.ready_low_duration = C_RANDOM) then
        v_ready_low_cycle_count := 0;
        -- Check if pulse duration is defined or random
        if config.ready_low_duration > 0 then
          v_ready_low_duration := config.ready_low_duration;
        elsif config.ready_low_duration = C_RANDOM then
          v_ready_low_duration := random(1, config.ready_low_max_random_duration);
        end if;

        -- Deassert tready once per transmission on a specific word
        if config.ready_low_at_word_num = v_byte_cnt / C_NUM_BYTES_PER_WORD then
          axistream_if.tready <= '0';
          -- Wait until tvalid goes high before counting the deassertion cycles
          while axistream_if.tvalid = '0' and v_invalid_count < config.max_wait_cycles loop
            v_invalid_count := v_invalid_count + 1;
            wait until rising_edge(clk);
            -- If tvalid was asserted right before the rising_edge then we have already waited
            -- one cycle with tready deasserted
            if axistream_if.tvalid = '1' then
              v_ready_low_duration := v_ready_low_duration - 1;
            end if;
            wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
          end loop;
          -- TValid timed out
          if v_invalid_count >= config.max_wait_cycles then
            v_timeout            := true;
            v_done               := true;
            v_ready_low_duration := 0;
          end if;
          while v_ready_low_cycle_count < v_ready_low_duration loop
            v_ready_low_cycle_count := v_ready_low_cycle_count + 1;
            wait until rising_edge(clk);
            wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
          end loop;

        -- Deassert tready multiple random times per transmission
        elsif config.ready_low_at_word_num = C_MULTIPLE_RANDOM and random(0.0, 1.0) <= config.ready_low_multiple_random_prob then
          axistream_if.tready <= '0';
          while v_ready_low_cycle_count < v_ready_low_duration loop
            v_ready_low_cycle_count := v_ready_low_cycle_count + 1;
            wait until rising_edge(clk);
            wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
          end loop;
        end if;
      end if;

      ------------------------------------------------------------
      -- Assert the tready signal (after tvalid is high) and wait
      -- for the rising_edge of the clock to sample the data
      ------------------------------------------------------------
      if v_byte_in_word = 0 then
        -- To receive the first byte wait until tvalid goes high before asserting tready
        if v_byte_cnt = 0 and axistream_if.tvalid = '0' and not (v_timeout) then
          while axistream_if.tvalid = '0' and v_invalid_count < config.max_wait_cycles loop
            v_invalid_count := v_invalid_count + 1;
            wait until rising_edge(clk);
            -- If tvalid was asserted right before the rising_edge then we should sample
            -- the data right away, otherwise we wait
            if axistream_if.tvalid = '1' and axistream_if.tready = '1' then
              v_sample_data_now := true;
            else
              v_sample_data_now := false;
              wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
            end if;
          end loop;
          if not (v_sample_data_now) then
            -- TValid is now high, assert tready
            if v_invalid_count < config.max_wait_cycles then
              axistream_if.tready <= '1';
              wait until rising_edge(clk);
              if v_time_of_rising_edge = -1 ns then
                v_time_of_rising_edge := now;
              end if;
            -- TValid timed out
            else
              v_timeout := true;
              v_done    := true;
            end if;
          end if;
        -- TValid was already high, assert tready right away
        else
          axistream_if.tready <= '1';
          wait until rising_edge(clk);
          if v_time_of_rising_edge = -1 ns then
            v_time_of_rising_edge := now;
          end if;
        end if;
      end if;

      if not (v_timeout) then
        check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                  config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      end if;

      ------------------------------------------------------------
      -- Sample the data
      ------------------------------------------------------------
      if axistream_if.tvalid = '1' and axistream_if.tready = '1' then
        v_invalid_count := 0;

        -- Sample data
        v_data_byte_array(v_byte_cnt) := axistream_if.tdata(7 + 8 * v_byte_in_word downto 8 * v_byte_in_word);

        -- Sample sideband data for this transfer (this word): There is one array entry per word
        if v_byte_in_word = 0 then
          v_word_idx := v_byte_cnt / C_NUM_BYTES_PER_WORD;
          if (v_word_idx <= user_array'high) then -- Include this 'if' to allow a shorter user_array if the caller doesn't care what tuser is
            user_array(v_byte_cnt / C_NUM_BYTES_PER_WORD)(C_NUM_USER_BITS_PER_WORD - 1 downto 0) := axistream_if.tuser(C_NUM_USER_BITS_PER_WORD - 1 downto 0);
          end if;
          if (v_word_idx <= strb_array'high) then -- Include this 'if' to allow a shorter *_array if the caller doesn't care what tstrb is
            strb_array(v_byte_cnt / C_NUM_BYTES_PER_WORD)(C_NUM_STRB_BITS_PER_WORD - 1 downto 0) := axistream_if.tstrb(C_NUM_STRB_BITS_PER_WORD - 1 downto 0);
          end if;
          if (v_word_idx <= id_array'high) then -- Include this 'if' to allow a shorter *_array if the caller doesn't care what tid is
            id_array(v_byte_cnt / C_NUM_BYTES_PER_WORD)(C_NUM_ID_BITS_PER_WORD - 1 downto 0) := axistream_if.tid(C_NUM_ID_BITS_PER_WORD - 1 downto 0);
          end if;
          if (v_word_idx <= dest_array'high) then -- Include this 'if' to allow a shorter *_array if the caller doesn't care what tdest is
            dest_array(v_byte_cnt / C_NUM_BYTES_PER_WORD)(C_NUM_DEST_BITS_PER_WORD - 1 downto 0) := axistream_if.tdest(C_NUM_DEST_BITS_PER_WORD - 1 downto 0);
          end if;
        end if;

        log(ID_PACKET_DATA, v_proc_call.all & "=> Rx " & to_string(v_data_byte_array(v_byte_cnt), HEX, AS_IS, INCL_RADIX) & --     ", tuser=" & to_string(user_array(v_byte_cnt/C_NUM_BYTES_PER_WORD), HEX, AS_IS, INCL_RADIX) &
        --     ", tstrb=" & to_string(strb_array(v_byte_cnt/C_NUM_BYTES_PER_WORD), HEX, AS_IS, INCL_RADIX) &
        --     ", tid="   & to_string(id_array(v_byte_cnt/C_NUM_BYTES_PER_WORD),   HEX, AS_IS, INCL_RADIX) &
        --     ", tdest=" & to_string(dest_array(v_byte_cnt/C_NUM_BYTES_PER_WORD), HEX, AS_IS, INCL_RADIX) &
        " (byte# " & to_string(v_byte_cnt) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);

        -- Stop sampling data when we have filled the v_data_byte_array
        if v_byte_cnt = v_data_byte_array'high then
          -- Check tlast='1' at expected last byte
          if config.check_packet_length then
            check_value(axistream_if.tlast, '1', config.protocol_error_severity, "Check tlast at expected last byte = " & to_string(v_byte_cnt) & ". " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);
          end if;
          v_done := true;
        end if;

        -- Allow that tlast arrives sooner than indicated by v_data_byte_array'high
        -- if receive() is called without knowing the length to be expected.
        if axistream_if.tlast = '1' then
          if axistream_if.tkeep(v_byte_in_word) = '1' then
            if v_byte_in_word = C_NUM_BYTES_PER_WORD - 1 then
              -- it's the last byte in word and tlast='1', thus the last in packet.
              v_done := true;
            else
              if axistream_if.tkeep(v_byte_in_word + 1) = '0' then
                -- Next byte in word is invalid, so this is the last byte
                v_done     := true;
                -- Check that tkeep for the remaining bytes in the last word are also '0'. (Only continous stream supported)
                v_byte_idx := v_byte_in_word + 1;
                l_check_remaining_TKEEP : loop
                  check_value(axistream_if.tkeep(v_byte_idx), '0', ERROR, "Check that tkeep doesn't go from '1' to '0' to '1' again within this last word. (The BFM supports only continuous stream)", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
                  if v_byte_idx < (axistream_if.tkeep'length - 1) then
                    v_byte_idx := v_byte_idx + 1;
                  else
                    exit l_check_remaining_TKEEP;
                  end if;
                end loop;
              else
                -- Next byte in word is valid but the v_data_byte_array has finished
                if v_done then
                  alert(ERROR, v_proc_call.all & "=> Failed. data_array too small for received bytes. " & add_msg_delimiter(msg), scope);
                end if;
              end if;
            end if;
          end if;
        else                    -- tlast = 0
          -- Check that all tkeep bits are '1'. (Only continous stream supported)
          check_value(axistream_if.tkeep(v_byte_in_word), '1', ERROR, "When tlast='0', check that all tkeep bits are '1'. (The BFM supports only continuous stream)" & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel, v_proc_call.all);
        end if;

        -- Next byte is in the next clk cycle
        if v_byte_in_word = C_NUM_BYTES_PER_WORD - 1 then
          -- Don't wait on the last cycle
          if not (v_done) then
            wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
          end if;
          v_byte_in_word := 0;
        -- Next byte is in the same clk cycle
        else
          v_byte_in_word := v_byte_in_word + 1;
        end if;

        -- Next byte
        v_byte_cnt := v_byte_cnt + 1;

      ------------------------------------------------------------
      -- Data couldn't be sampled, wait until next cycle
      ------------------------------------------------------------
      elsif not (v_timeout) then
        -- Check for timeout (also when max_wait_cycles_severity = NO_ALERT,
        -- or else the VVC will wait forever, until the UVVM cmd times out)
        if v_invalid_count >= config.max_wait_cycles then
          v_timeout := true;
          v_done    := true;
        else
          v_invalid_count := v_invalid_count + 1;
        end if;
        wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      end if;
    end loop;                       -- while not v_done

    -- Wait according to bfm_sync config
    if not (v_timeout) then
      wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
    end if;

    -- Set the number of bytes received
    data_length := v_byte_cnt;

    -- Log the received frame
    if is_log_msg_enabled(ID_PACKET_PAYLOAD, msg_id_panel) then -- large frames may affect performance
      log(ID_PACKET_PAYLOAD, v_proc_call.all & "=> Rx Frame (" & to_string(v_byte_cnt) & " bytes) " & to_string(v_data_byte_array(0 to v_byte_cnt-1)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

    -- Check if there was a timeout or it was successful
    if v_timeout then
      alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout while waiting for valid data. " & add_msg_delimiter(msg), scope);
    else
      if ext_proc_call = "" then
        log(ID_PACKET_COMPLETE, v_proc_call.all & "=> Rx DONE (" & to_string(integer(ceil((real(v_byte_cnt) / real(C_DATA_ARRAY_BYTES_PER_WORD))))) & " words[" & to_string(C_DATA_ARRAY_BYTES_PER_WORD * 8) & "b]). " & add_msg_delimiter(msg), scope, msg_id_panel);
      else
        -- Log will be handled by calling procedure (e.g. axistream_expect)
      end if;
    end if;

    -- Convert SLV with byte-width to expected variable word-width
    data_array := convert_byte_array_to_slv_array(v_data_byte_array, C_DATA_ARRAY_BYTES_PER_WORD, config.byte_endianness);

    -- Done, set axistream back to default
    axistream_if <= init_axistream_if_signals(
      is_master  => false,
      data_width => axistream_if.tdata'length,
      user_width => axistream_if.tuser'length,
      id_width   => axistream_if.tid'length,
      dest_width => axistream_if.tdest'length,
      config     => config);

    DEALLOCATE(v_proc_call);
  end procedure axistream_receive;

  -- Receive a packet, store it in data_array
  -- data_array'length can be longer than the actual packet, so that you can call receive() without knowing the length to be expected.
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_receive_bytes(
    variable data_array    : inout t_byte_array;
    variable data_length   : inout natural; -- Number of bytes received
    variable user_array    : inout t_user_array;
    variable strb_array    : inout t_strb_array;
    variable id_array      : inout t_id_array;
    variable dest_array    : inout t_dest_array;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   axistream_if  : inout t_axistream_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant C_LOCAL_PROC_NAME : string := "axistream_receive_bytes"; -- Internal proc_name; used if called from sequncer or VVC
    constant C_LOCAL_PROC_CALL : string := C_LOCAL_PROC_NAME & "()"; -- Internal proc_call; used if called from sequncer or VVC
  begin
    -- DEPRECATE: data_array as t_byte_array will be removed in next major release
    deprecate(C_LOCAL_PROC_CALL, "data_array as t_byte_array has been deprecated. Use data_array as t_slv_array.");

    -- Call overloaded t_slv_array procedure
    axistream_receive(data_array, data_length, user_array, strb_array, id_array, dest_array,
                      msg, clk, axistream_if, scope, msg_id_panel, config, ext_proc_call);
  end procedure axistream_receive_bytes;

  -- Overloaded version without records
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_receive_bytes(
    variable data_array          : inout t_byte_array;
    variable data_length         : inout natural; -- Number of bytes received
    variable user_array          : inout t_user_array;
    variable strb_array          : inout t_strb_array;
    variable id_array            : inout t_id_array;
    variable dest_array          : inout t_dest_array;
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call       : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
  begin
    axistream_receive_bytes(
      data_array          => data_array,
      data_length         => data_length,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config,
      ext_proc_call       => ext_proc_call);
  end procedure axistream_receive_bytes;

  -- Overloading t_slv_array record procedure
  procedure axistream_receive(
    variable data_array          : inout t_slv_array;
    variable data_length         : inout natural; -- Number of bytes received
    variable user_array          : inout t_user_array;
    variable strb_array          : inout t_strb_array;
    variable id_array            : inout t_id_array;
    variable dest_array          : inout t_dest_array;
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call       : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
  begin
    -- Call the record version
    axistream_receive(
      data_array          => data_array,
      data_length         => data_length,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config,
      ext_proc_call       => ext_proc_call);
  end procedure axistream_receive;

  --------------------------------------------------------
  --
  -- AXIStream Expect
  --
  --------------------------------------------------------
  -- Receive data, then compare the received data against exp_data_array
  -- - If the received data is inconsistent with the expected data, an alert with
  --   severity 'alert_level' is triggered.
  procedure axistream_expect(
    constant exp_data_array : in t_slv_array; -- Expected data
    constant exp_user_array : in t_user_array; -- Expected tuser
    constant exp_strb_array : in t_strb_array; -- Expected tstrb
    constant exp_id_array   : in t_id_array; -- Expected tid
    constant exp_dest_array : in t_dest_array; -- Expected tdest
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    constant C_DATA_ARRAY_BYTES_PER_WORD : natural := exp_data_array(exp_data_array'low)'length / 8;
    constant C_PROC_CALL                 : string  := "axistream_expect(" & to_string(exp_data_array'length) & " words[" & to_string(C_DATA_ARRAY_BYTES_PER_WORD * 8) & "b])";

    constant C_NUM_BYTES_PER_WORD     : natural := axistream_if.tdata'length / 8;
    constant C_NUM_USER_BITS_PER_WORD : natural := axistream_if.tuser'length;
    constant C_NUM_STRB_BITS_PER_WORD : natural := axistream_if.tstrb'length;
    constant C_NUM_ID_BITS_PER_WORD   : natural := axistream_if.tid'length;
    constant C_NUM_DEST_BITS_PER_WORD : natural := axistream_if.tdest'length;

    variable v_config             : t_axistream_bfm_config := config;
    variable v_rx_data_array      : t_slv_array(exp_data_array'range)(exp_data_array(exp_data_array'low)'range); -- received data
    variable v_rx_user_array      : t_user_array(exp_user_array'range); -- received tuser
    variable v_rx_strb_array      : t_strb_array(exp_strb_array'range);
    variable v_rx_id_array        : t_id_array(exp_id_array'range);
    variable v_rx_dest_array      : t_dest_array(exp_dest_array'range);
    variable v_rx_data_length     : natural;
    variable v_data_error_cnt     : natural                := 0;
    variable v_user_error_cnt     : natural                := 0;
    variable v_strb_error_cnt     : natural                := 0;
    variable v_id_error_cnt       : natural                := 0;
    variable v_dest_error_cnt     : natural                := 0;
    variable v_first_errored_word : natural;
    variable v_alert_radix        : t_radix;
    variable v_check_ok           : boolean                := true;
    variable v_rx_user_slv_array  : t_slv_array(exp_user_array'range)(C_NUM_USER_BITS_PER_WORD-1 downto 0);
    variable v_rx_strb_slv_array  : t_slv_array(exp_strb_array'range)(C_NUM_STRB_BITS_PER_WORD-1 downto 0);
    variable v_rx_id_slv_array    : t_slv_array(exp_id_array'range)(C_NUM_ID_BITS_PER_WORD-1 downto 0);
    variable v_rx_dest_slv_array  : t_slv_array(exp_dest_array'range)(C_NUM_DEST_BITS_PER_WORD-1 downto 0);
    variable v_exp_user_slv_array : t_slv_array(exp_user_array'range)(C_NUM_USER_BITS_PER_WORD-1 downto 0);
    variable v_exp_strb_slv_array : t_slv_array(exp_strb_array'range)(C_NUM_STRB_BITS_PER_WORD-1 downto 0);
    variable v_exp_id_slv_array   : t_slv_array(exp_id_array'range)(C_NUM_ID_BITS_PER_WORD-1 downto 0);
    variable v_exp_dest_slv_array : t_slv_array(exp_dest_array'range)(C_NUM_DEST_BITS_PER_WORD-1 downto 0);
    variable v_all_alerts_line    : line;
  begin
    v_check_ok := v_check_ok and check_value(exp_data_array(exp_data_array'low)'length mod 8 = 0, TB_ERROR, "Sanity check: Check that exp_data_array word is N*byte", scope, ID_NEVER, msg_id_panel, C_PROC_CALL);
    if not (v_check_ok) then
      return;
    end if;

    -- v_data_byte_array := convert_slv_array_to_byte_array(data_array, shared_axistream_vvc_config(vvc_instance_idx).bfm_config.byte_endianness);
    -- v_rx_data_array := convert_slv_array_to_byte_array(exp_data_array, config.byte_endianness);

    -- Receive and store data
    axistream_receive(data_array    => v_rx_data_array,
                      data_length   => v_rx_data_length,
                      user_array    => v_rx_user_array,
                      strb_array    => v_rx_strb_array,
                      id_array      => v_rx_id_array,
                      dest_array    => v_rx_dest_array,
                      msg           => msg,
                      clk           => clk,
                      axistream_if  => axistream_if,
                      scope         => scope,
                      msg_id_panel  => msg_id_panel,
                      config        => v_config,
                      ext_proc_call => C_PROC_CALL);

    -- Check if each received bit matches the expected
    -- Find and report the first errored word
    for word in v_rx_data_array'high downto v_rx_data_array'low loop
      for i in v_rx_data_array(word)'range loop
        -- Allow don't care in expected value and use match strictness from config for comparison
        if exp_data_array(word)(i) = '-' or check_value(v_rx_data_array(word)(i), exp_data_array(word)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        -- Check is OK
        else
          --log(ID_PACKET_DATA, C_PROC_CALL & "=> NOK, checked " & to_string(v_rx_data_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_data_array(word), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
          -- Received word does not match the expected word
          v_data_error_cnt     := v_data_error_cnt + 1;
          v_first_errored_word := word;
        end if;
      end loop;
    end loop;

    -- Check tuser matches exp_user_array
    -- Check all bits the exp_user_array. If the caller (Test Sequencer or VVC) don't care, the length of exp_user_array input shall be only one
    for word in exp_user_array'high downto 0 loop
      for i in C_NUM_USER_BITS_PER_WORD - 1 downto 0 loop -- i = bit
        -- Put bits in corresponding slv array for proper presentation in log
        v_rx_user_slv_array(word)(i)   := v_rx_user_array(word)(i);
        v_exp_user_slv_array(word)(i)  := exp_user_array(word)(i);
        -- Allow don't care in expected value and use match strictness from config for comparison
        if exp_user_array(word)(i) = '-' or check_value(v_rx_user_array(word)(i), exp_user_array(word)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        -- Check is OK
        else
          log(ID_PACKET_DATA, C_PROC_CALL & "=> NOK(word=" & to_string(word) & "), checked " & to_string(v_rx_user_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_user_array(word), HEX, AS_IS, INCL_RADIX) & add_msg_delimiter(msg), scope, msg_id_panel);
          -- Received tuser word does not match the expected word
          v_user_error_cnt     := v_user_error_cnt + 1;
          v_first_errored_word := word;
        end if;
      end loop;
    end loop;

    -- Check that all bits in exp_strb_array matches received tstrb
    for word in exp_strb_array'high downto 0 loop
      for i in C_NUM_STRB_BITS_PER_WORD - 1 downto 0 loop -- i = bit
        -- Put bits in corresponding slv array for proper presentation in log
        v_rx_strb_slv_array(word)(i)   := v_rx_strb_array(word)(i);
        v_exp_strb_slv_array(word)(i)  := exp_strb_array(word)(i);
        -- Allow don't care in expected value and use match strictness from config for comparison
        if exp_strb_array(word)(i) = '-' or check_value(v_rx_strb_array(word)(i), exp_strb_array(word)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        -- Check is OK
        else
          log(ID_PACKET_DATA, C_PROC_CALL & "=> NOK(word=" & to_string(word) & "), checked " & to_string(v_rx_strb_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_strb_array(word), HEX, AS_IS, INCL_RADIX) & add_msg_delimiter(msg), scope, msg_id_panel);
          -- Received tstrb word does not match the expected word
          v_strb_error_cnt     := v_strb_error_cnt + 1;
          v_first_errored_word := word;
        end if;
      end loop;
    end loop;

    -- Check that all bits in exp_id_array matches received tid
    for word in exp_id_array'high downto 0 loop
      for i in C_NUM_ID_BITS_PER_WORD - 1 downto 0 loop -- i = bit
        -- Put bits in corresponding slv array for proper presentation in log
        v_rx_id_slv_array(word)(i)   := v_rx_id_array(word)(i);
        v_exp_id_slv_array(word)(i)  := exp_id_array(word)(i);
        -- Allow don't care in expected value and use match strictness from config for comparison
        if exp_id_array(word)(i) = '-' or check_value(v_rx_id_array(word)(i), exp_id_array(word)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        -- Check is OK
        else
          log(ID_PACKET_DATA, C_PROC_CALL & "=> NOK(word=" & to_string(word) & "), checked " & to_string(v_rx_id_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_id_array(word), HEX, AS_IS, INCL_RADIX) & add_msg_delimiter(msg), scope, msg_id_panel);
          -- Received tid word does not match the expected word
          v_id_error_cnt       := v_id_error_cnt + 1;
          v_first_errored_word := word;
        end if;
      end loop;
    end loop;

    -- Check that all bits in exp_dest_array matches received tdest
    for word in exp_dest_array'high downto 0 loop
      for i in C_NUM_DEST_BITS_PER_WORD - 1 downto 0 loop -- i = bit
        -- Put bits in corresponding slv array for proper presentation in log
        v_rx_dest_slv_array(word)(i)   := v_rx_dest_array(word)(i);
        v_exp_dest_slv_array(word)(i)  := exp_dest_array(word)(i);
        -- Allow don't care in expected value and use match strictness from config for comparison
        if exp_dest_array(word)(i) = '-' or check_value(v_rx_dest_array(word)(i), exp_dest_array(word)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        -- Check is OK
        else
          log(ID_PACKET_DATA, C_PROC_CALL & "=> NOK(word=" & to_string(word) & "), checked " & to_string(v_rx_dest_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_dest_array(word), HEX, AS_IS, INCL_RADIX) & add_msg_delimiter(msg), scope, msg_id_panel);
          -- Received tdest word does not match the expected word
          v_dest_error_cnt     := v_dest_error_cnt + 1;
          v_first_errored_word := word;
        end if;
      end loop;
    end loop;

    if v_data_error_cnt /= 0 then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix         := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_data_array(v_first_errored_word), exp_data_array(v_first_errored_word), MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      write(v_all_alerts_line, (LF & C_PROC_CALL & "=> Failed in " & to_string(v_data_error_cnt) & " data bits. First mismatch in word# " & to_string(v_first_errored_word+1) & ". Was " & to_string(v_rx_data_array(v_first_errored_word), v_alert_radix, AS_IS, INCL_RADIX) & 
        ". Expected " & to_string(exp_data_array(v_first_errored_word), v_alert_radix, AS_IS, INCL_RADIX) & "." & add_msg_delimiter(msg)));
      if C_ERROR_REPORT_EXTENT = EXTENDED then -- Append full data array to alert line when error report extent is set to EXTENDED
        write(v_all_alerts_line, (LF & "Was:" & LF & to_string(v_rx_data_array, v_alert_radix, AS_IS) & LF & "Expected:" & LF & to_string(exp_data_array, v_alert_radix, AS_IS) & LF));
      end if;
    end if;
    
    if v_user_error_cnt /= 0 then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix         := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_user_array(v_first_errored_word), exp_user_array(v_first_errored_word), MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      write(v_all_alerts_line,(LF & C_PROC_CALL & "=> Failed in " & to_string(v_user_error_cnt) & " tuser bits. First mismatch in word# " & to_string(v_first_errored_word+1) & ". Was " & to_string(v_rx_user_array(v_first_errored_word)(C_NUM_USER_BITS_PER_WORD - 1 downto 0), 
        v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_user_array(v_first_errored_word)(C_NUM_USER_BITS_PER_WORD - 1 downto 0), v_alert_radix, AS_IS, INCL_RADIX) & "." & add_msg_delimiter(msg)));
      if C_ERROR_REPORT_EXTENT = EXTENDED then -- Append full tuser array to alert line when error report extent is set to EXTENDED
        write(v_all_alerts_line, (LF & "Was:" & LF & to_string(v_rx_user_slv_array, v_alert_radix, AS_IS) & LF & "Expected:" & LF & to_string(v_exp_user_slv_array, v_alert_radix, AS_IS) & LF));
      end if;
    end if;
    
    if v_strb_error_cnt /= 0 then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix         := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_strb_array(v_first_errored_word), exp_strb_array(v_first_errored_word), MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      write(v_all_alerts_line, (LF & C_PROC_CALL & "=> Failed in " & to_string(v_strb_error_cnt) & " tstrb bits. First mismatch in word# " & to_string(v_first_errored_word+1) & ". Was " & to_string(v_rx_strb_slv_array(v_first_errored_word)(C_NUM_STRB_BITS_PER_WORD - 1 downto 0), 
        v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_strb_array(v_first_errored_word)(C_NUM_STRB_BITS_PER_WORD - 1 downto 0), v_alert_radix, AS_IS, INCL_RADIX) & "." & add_msg_delimiter(msg)));
      if C_ERROR_REPORT_EXTENT = EXTENDED then -- Append full tstrb array to alert line when error report extent is set to EXTENDED
        write(v_all_alerts_line, (LF & "Was:" & LF & to_string(v_rx_strb_slv_array, v_alert_radix, AS_IS) & LF & "Expected:" & LF & to_string(v_exp_strb_slv_array, v_alert_radix, AS_IS) & LF));
      end if;
    end if;
    
    if v_id_error_cnt /= 0 then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix         := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_id_array(v_first_errored_word), exp_id_array(v_first_errored_word), MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      write(v_all_alerts_line, (LF & C_PROC_CALL & "=> Failed in " & to_string(v_id_error_cnt) & " tid bits. First mismatch in word# " & to_string(v_first_errored_word+1) & ". Was " & to_string(v_rx_id_array(v_first_errored_word)(C_NUM_ID_BITS_PER_WORD - 1 downto 0), 
        v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_id_array(v_first_errored_word)(C_NUM_ID_BITS_PER_WORD - 1 downto 0), v_alert_radix, AS_IS, INCL_RADIX) & "." & add_msg_delimiter(msg)));
      if C_ERROR_REPORT_EXTENT = EXTENDED then -- Append full tid array to alert line when error report extent is set to EXTENDED
        write(v_all_alerts_line, (LF & "Was:" & LF & to_string(v_rx_id_slv_array, v_alert_radix, AS_IS) & LF & "Expected:" & LF & to_string(v_exp_id_slv_array, v_alert_radix, AS_IS) & LF));
      end if;
    end if;
    
    if v_dest_error_cnt /= 0 then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix         := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_dest_array(v_first_errored_word), exp_dest_array(v_first_errored_word), MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      write(v_all_alerts_line, (LF & C_PROC_CALL & "=> Failed in " & to_string(v_dest_error_cnt) & " tdest bits. First mismatch in word# " & to_string(v_first_errored_word+1) & ". Was " & to_string(v_rx_dest_array(v_first_errored_word)(C_NUM_DEST_BITS_PER_WORD - 1 downto 0), 
        v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_dest_array(v_first_errored_word)(C_NUM_DEST_BITS_PER_WORD - 1 downto 0), v_alert_radix, AS_IS, INCL_RADIX) & "." & add_msg_delimiter(msg)));
      if C_ERROR_REPORT_EXTENT = EXTENDED then -- Append full tdest array to alert line when error report extent is set to EXTENDED
        write(v_all_alerts_line, (LF & "Was:" & LF & to_string(v_rx_dest_slv_array, v_alert_radix, AS_IS) & LF & "Expected:" & LF & to_string(v_exp_dest_slv_array, v_alert_radix, AS_IS) & LF));
      end if;
    end if;
    
    -- No more than one alert per packet
    if (v_data_error_cnt = 0) and (v_user_error_cnt = 0) and (v_strb_error_cnt = 0) and (v_id_error_cnt = 0) and (v_dest_error_cnt = 0) then -- Log OK when no errors present
      log(ID_PACKET_COMPLETE, C_PROC_CALL & "=> OK, received " & to_string(exp_data_array'length) & " words[" & to_string(C_DATA_ARRAY_BYTES_PER_WORD * 8) & "b]). " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      if C_ERROR_REPORT_EXTENT = EXTENDED then -- Append summary of amount of wrong bits to alert line when error report extent is EXTENDED
        write(v_all_alerts_line, (LF & "Summary of errors in expected transaction. Failed in: " & LF & to_string(v_data_error_cnt) & " data bits." & LF & to_string(v_user_error_cnt) & " tuser bits." & LF & to_string(v_strb_error_cnt) & " tstrb bits." & LF & 
          to_string(v_id_error_cnt) & " tid bits." & LF & to_string(v_dest_error_cnt) & " tdest bits." & LF));
      end if;
      alert(alert_level, v_all_alerts_line.all, scope);
    end if;

    deallocate(v_all_alerts_line);
  end procedure axistream_expect;

  -- t_byte_array overload
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    constant exp_data_array : in t_byte_array; -- Expected data
    constant exp_user_array : in t_user_array; -- Expected tuser
    constant exp_strb_array : in t_strb_array; -- Expected tstrb
    constant exp_id_array   : in t_id_array; -- Expected tid
    constant exp_dest_array : in t_dest_array; -- Expected tdest
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    constant C_PROC_CALL  : string  := "axistream_expect_bytes(" & to_string(exp_data_array'length) & "B)";
    variable v_check_ok : boolean := false;

  begin
    -- t_byte_array sanity check
    v_check_ok := check_value(exp_data_array'length > 0, TB_ERROR, C_PROC_CALL & "data_array length must be > 0", scope, ID_NEVER, msg_id_panel);

    if v_check_ok then
      -- call t_byte_array overloaded procedure
      axistream_expect(exp_data_array,
                       exp_user_array,
                       exp_strb_array,
                       exp_id_array,
                       exp_dest_array,
                       msg,
                       clk,
                       axistream_if,
                       alert_level,
                       scope,
                       msg_id_panel,
                       config);
    end if;
  end procedure;

  -- SLV overload
  procedure axistream_expect(
    constant exp_data_array : in std_logic_vector; -- Expected data
    constant exp_user_array : in t_user_array; -- Expected tuser
    constant exp_strb_array : in t_strb_array; -- Expected tstrb
    constant exp_id_array   : in t_id_array; -- Expected tid
    constant exp_dest_array : in t_dest_array; -- Expected tdest
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    variable v_exp_data_array : t_slv_array(0 to 0)(exp_data_array'length - 1 downto 0);
  begin
    v_exp_data_array(0) := exp_data_array;
    axistream_expect(v_exp_data_array,
                     exp_user_array,
                     exp_strb_array,
                     exp_id_array,
                     exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;

  -- Overloaded version without records
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    constant exp_data_array      : in t_byte_array; -- Expected data
    constant exp_user_array      : in t_user_array; -- Expected tuser
    constant exp_strb_array      : in t_strb_array; -- Expected tstrb
    constant exp_id_array        : in t_id_array; -- Expected tid
    constant exp_dest_array      : in t_dest_array; -- Expected tdest
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in t_alert_level          := error;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
  begin
    axistream_expect_bytes(
      exp_data_array      => exp_data_array,
      exp_user_array      => exp_user_array,
      exp_strb_array      => exp_strb_array,
      exp_id_array        => exp_id_array,
      exp_dest_array      => exp_dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      alert_level         => alert_level,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure;

  -- SLV array without axistream record
  procedure axistream_expect(
    constant exp_data_array      : in t_slv_array; -- Expected data
    constant exp_user_array      : in t_user_array; -- Expected tuser
    constant exp_strb_array      : in t_strb_array; -- Expected tstrb
    constant exp_id_array        : in t_id_array; -- Expected tid
    constant exp_dest_array      : in t_dest_array; -- Expected tdest
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in t_alert_level          := error;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
  begin
    axistream_expect(
      exp_data_array      => exp_data_array,
      exp_user_array      => exp_user_array,
      exp_strb_array      => exp_strb_array,
      exp_id_array        => exp_id_array,
      exp_dest_array      => exp_dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      alert_level         => alert_level,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure;

  -- SLV without axistream record
  procedure axistream_expect(
    constant exp_data_array      : in std_logic_vector; -- Expected data
    constant exp_user_array      : in t_user_array; -- Expected tuser
    constant exp_strb_array      : in t_strb_array; -- Expected tstrb
    constant exp_id_array        : in t_id_array; -- Expected tid
    constant exp_dest_array      : in t_dest_array; -- Expected tdest
    constant msg                 : in string;
    signal   clk                 : in std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in t_alert_level          := error;
    constant scope               : in string                 := C_BFM_SCOPE;
    constant msg_id_panel        : in t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
  begin
    axistream_expect(
      exp_data_array      => exp_data_array,
      exp_user_array      => exp_user_array,
      exp_strb_array      => exp_strb_array,
      exp_id_array        => exp_id_array,
      exp_dest_array      => exp_dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      alert_level         => alert_level,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure;

  -- Overload without exp_strb_array, exp_id_array, exp_dest_array arguments' argument
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    constant exp_data_array : in t_byte_array; -- Expected data
    constant exp_user_array : in t_user_array; -- Expected tuser
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- Default value: don't care
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0)   := (others => (others => '-'));
  begin
    axistream_expect_bytes(exp_data_array,
                           exp_user_array,
                           v_exp_strb_array,
                           v_exp_id_array,
                           v_exp_dest_array,
                           msg,
                           clk,
                           axistream_if,
                           alert_level,
                           scope,
                           msg_id_panel,
                           config);
  end procedure;

    -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_expect(
    constant exp_data_array : in t_slv_array; -- Expected data
    constant exp_user_array : in t_user_array; -- Expected tuser
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- Default value: don't care
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0)   := (others => (others => '-'));
  begin
    -- call overloaded t_slv_array procedure
    axistream_expect(exp_data_array,
                     exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;

  -- SLV overload with default values for exp_strb_array, exp_id_array and exp_dest_array (will be set to don't care)
  procedure axistream_expect(
    constant exp_data_array : in std_logic_vector; -- Expected data
    constant exp_user_array : in t_user_array; -- Expected tuser
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- Default value: don't care
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0)   := (others => (others => '-'));
  begin
    axistream_expect(exp_data_array,
                     exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;

  -- Overload without arguments exp_user_array, exp_strb_array, exp_id_array, exp_dest_array arguments
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    constant exp_data_array : in t_byte_array; -- Expected data
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- Default value: don't care
    variable v_exp_user_array : t_user_array(0 to 0) := (others => (others => '-'));
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0)   := (others => (others => '-'));
  begin
    axistream_expect_bytes(exp_data_array,
                           v_exp_user_array,
                           v_exp_strb_array,
                           v_exp_id_array,
                           v_exp_dest_array,
                           msg,
                           clk,
                           axistream_if,
                           alert_level,
                           scope,
                           msg_id_panel,
                           config);
  end procedure;

  -- Overload with default values for exp_user_array, exp_strb_array, exp_id_array and exp_dest_array (will be set to don't care)
  procedure axistream_expect(
    constant exp_data_array : in t_slv_array; -- Expected data
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- Default value: don't care
    variable v_exp_user_array : t_user_array(0 to 0) := (others => (others => '-'));
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0)   := (others => (others => '-'));
  begin
    axistream_expect(exp_data_array,
                     v_exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;

  -- SLV overload with default values for exp_user_array, exp_strb_array, exp_id_array and exp_dest_array (will be set to don't care)
  procedure axistream_expect(
    constant exp_data_array : in std_logic_vector; -- Expected data
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in t_alert_level          := error;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
  ) is
    -- Default value: don't care
    variable v_exp_user_array : t_user_array(0 to 0) := (others => (others => '-'));
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0)   := (others => (others => '-'));
  begin
    axistream_expect(exp_data_array,
                     v_exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;

end package body axistream_bfm_pkg;