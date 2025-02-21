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
use ieee.math_real.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.types_pkg.all;
use work.string_methods_pkg.all;
use work.adaptations_pkg.all;
use work.license_pkg.all;
use work.global_signals_and_shared_variables_pkg.all;
use work.alert_hierarchy_pkg.all;
use work.protected_types_pkg.all;
use std.env.all;

package methods_pkg is

  constant C_UVVM_VERSION : string := "v2 2024.10.23";

  -- -- ============================================================================
  -- -- Initialisation and license
  -- -- ============================================================================
  --   procedure initialise_util(
  --     constant dummy  : in t_void
  --     );
  --
  -- ============================================================================
  -- File handling (that needs to use other utility methods)
  -- ============================================================================
  procedure check_file_open_status(
    constant status    : in file_open_status;
    constant file_name : in string;
    constant scope     : in string := C_SCOPE
  );

  procedure set_alert_file_name(
    constant file_name : string := C_ALERT_FILE_NAME
  );

  -- msg_id is unused. This is a deprecated overload
  procedure set_alert_file_name(
    constant file_name : string := C_ALERT_FILE_NAME;
    constant msg_id    : t_msg_id
  );

  procedure set_log_file_name(
    constant file_name : string := C_LOG_FILE_NAME
  );

  -- msg_id is unused. This is a deprecated overload
  procedure set_log_file_name(
    constant file_name : string := C_LOG_FILE_NAME;
    constant msg_id    : t_msg_id
  );

  -- ============================================================================
  -- Log-related
  -- ============================================================================
  procedure log(
    msg_id          : t_msg_id;
    msg             : string;
    scope           : string            := C_TB_SCOPE_DEFAULT;
    msg_id_panel    : t_msg_id_panel    := shared_msg_id_panel;
    log_destination : t_log_destination := shared_default_log_destination;
    log_file_name   : string            := C_LOG_FILE_NAME;
    open_mode       : file_open_kind    := append_mode
  );

  procedure log(
    msg             : string;
    scope           : string            := C_TB_SCOPE_DEFAULT;
    msg_id_panel    : t_msg_id_panel    := shared_msg_id_panel;
    log_destination : t_log_destination := shared_default_log_destination;
    log_file_name   : string            := C_LOG_FILE_NAME;
    open_mode       : file_open_kind    := append_mode
  );

  procedure log_text_block(
    msg_id              : t_msg_id;
    variable text_block : inout line;
    formatting          : t_log_format; -- FORMATTED or UNFORMATTED
    msg_header          : string               := "";
    scope               : string               := C_TB_SCOPE_DEFAULT;
    msg_id_panel        : t_msg_id_panel       := shared_msg_id_panel;
    log_if_block_empty  : t_log_if_block_empty := WRITE_HDR_IF_BLOCK_EMPTY;
    log_destination     : t_log_destination    := shared_default_log_destination;
    log_file_name       : string               := C_LOG_FILE_NAME;
    open_mode           : file_open_kind       := append_mode
  );

  procedure write_to_file(
    file_name        : string;
    open_mode        : file_open_kind;
    variable my_line : inout line
  );

  procedure write_line_to_log_destination(
    variable log_line        : inout line;
    constant log_destination : in t_log_destination := shared_default_log_destination;
    constant log_file_name   : in string            := C_LOG_FILE_NAME;
    constant open_mode       : in file_open_kind    := append_mode
  );

  procedure enable_log_msg(
    constant msg_id       : t_msg_id;
    variable msg_id_panel : inout t_msg_id_panel;
    constant msg          : string      := "";
    constant scope        : string      := C_TB_SCOPE_DEFAULT;
    constant quietness    : t_quietness := NON_QUIET
  );

  procedure enable_log_msg(
    msg_id    : t_msg_id;
    msg       : string;
    quietness : t_quietness := NON_QUIET;
    scope     : string      := C_TB_SCOPE_DEFAULT
  );

  procedure enable_log_msg(
    msg_id    : t_msg_id;
    quietness : t_quietness := NON_QUIET;
    scope     : string      := C_TB_SCOPE_DEFAULT
  );

  procedure disable_log_msg(
    constant msg_id       : t_msg_id;
    variable msg_id_panel : inout t_msg_id_panel;
    constant msg          : string      := "";
    constant scope        : string      := C_TB_SCOPE_DEFAULT;
    constant quietness    : t_quietness := NON_QUIET
  );

  procedure disable_log_msg(
    msg_id    : t_msg_id;
    msg       : string;
    quietness : t_quietness := NON_QUIET;
    scope     : string      := C_TB_SCOPE_DEFAULT
  );

  procedure disable_log_msg(
    msg_id    : t_msg_id;
    quietness : t_quietness := NON_QUIET;
    scope     : string      := C_TB_SCOPE_DEFAULT
  );

  impure function is_log_msg_enabled(
    msg_id       : t_msg_id;
    msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) return boolean;

  procedure set_log_destination(
    constant log_destination : t_log_destination;
    constant quietness       : t_quietness := NON_QUIET
  );

  function get_time_unit(
    constant value : time
  ) return time;

  -- ============================================================================
  -- Alert-related
  -- ============================================================================
  procedure alert(
    constant alert_level : t_alert_level;
    constant msg         : string;
    constant scope       : string := C_TB_SCOPE_DEFAULT
  );

  -- Dedicated alert-procedures all alert levels (less verbose - as 2 rather than 3 parameters...)
  procedure note(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure tb_note(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure warning(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure tb_warning(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure manual_check(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure error(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure tb_error(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure failure(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure tb_failure(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure increment_expected_alerts(
    constant alert_level : t_alert_level;
    constant number      : natural := 1;
    constant msg         : string  := "";
    constant scope       : string  := C_TB_SCOPE_DEFAULT
  );

  procedure report_alert_counters(
    constant order : in t_order
  );

  procedure report_alert_counters(
    constant dummy : in t_void
  );

  procedure report_global_ctrl(
    constant dummy : in t_void
  );

  procedure report_msg_id_panel(
    constant dummy : in t_void
  );

  procedure set_alert_attention(
    alert_level : t_alert_level;
    attention   : t_attention;
    msg         : string := ""
  );

  impure function get_alert_attention(
    alert_level : t_alert_level
  ) return t_attention;

  procedure set_alert_stop_limit(
    alert_level : t_alert_level;
    value       : natural
  );

  impure function get_alert_stop_limit(
    alert_level : t_alert_level
  ) return natural;

  impure function get_alert_counter(
    alert_level : t_alert_level;
    attention   : t_attention := REGARD
  ) return natural;

  procedure increment_alert_counter(
    alert_level : t_alert_level;
    attention   : t_attention := REGARD; -- regard, expect, ignore
    number      : natural     := 1
  );

  procedure increment_expected_alerts_and_stop_limit(
    constant alert_level : t_alert_level;
    constant number      : natural := 1;
    constant msg         : string  := "";
    constant scope       : string  := C_TB_SCOPE_DEFAULT
  );

  procedure report_check_counters(
    constant dummy : in t_void
  );

  procedure report_check_counters(
    constant order : in t_order
  );

  procedure report_scoreboards(
    constant void : in t_void
  );

  -- ============================================================================
  -- Deprecate message
  -- ============================================================================
  procedure deprecate(
    caller_name  : string;
    constant msg : string := ""
  );

  -- ============================================================================
  -- Non time consuming checks
  -- ============================================================================
  -- Matching if same width or only zeros in "extended width"
  function matching_widths(
    value1 : std_logic_vector;
    value2 : std_logic_vector
  ) return boolean;

  function matching_widths(
    value1 : unsigned;
    value2 : unsigned
  ) return boolean;

  function matching_widths(
    value1 : signed;
    value2 : signed
  ) return boolean;

  -- function version of check_value (with return value)
  impure function check_value(
    constant value        : boolean;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : boolean;
    constant exp          : boolean;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value            : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : std_logic;
    constant exp          : std_logic;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value            : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "slv"
  ) return boolean;

  impure function check_value(
    constant value        : std_logic_vector;
    constant exp          : std_logic_vector;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "slv"
  ) return boolean;

  impure function check_value(
    constant value            : unsigned;
    constant exp              : unsigned;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "unsigned"
  ) return boolean;

  impure function check_value(
    constant value        : unsigned;
    constant exp          : unsigned;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "unsigned"
  ) return boolean;

  impure function check_value(
    constant value            : signed;
    constant exp              : signed;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "signed"
  ) return boolean;

  impure function check_value(
    constant value        : signed;
    constant exp          : signed;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "signed"
  ) return boolean;

  impure function check_value(
    constant value        : integer;
    constant exp          : integer;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : real;
    constant exp          : real;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : time;
    constant exp          : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : string;
    constant exp          : string;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value            : t_slv_array;
    constant exp              : t_slv_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_slv_array"
  ) return boolean;

  impure function check_value(
    constant value        : t_slv_array;
    constant exp          : t_slv_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_slv_array"
  ) return boolean;

  impure function check_value(
    constant value            : t_signed_array;
    constant exp              : t_signed_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_signed_array"
  ) return boolean;

  impure function check_value(
    constant value        : t_signed_array;
    constant exp          : t_signed_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_signed_array"
  ) return boolean;

  impure function check_value(
    constant value            : t_unsigned_array;
    constant exp              : t_unsigned_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_unsigned_array"
  ) return boolean;

  impure function check_value(
    constant value        : t_unsigned_array;
    constant exp          : t_unsigned_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_unsigned_array"
  ) return boolean;

  -- overloads for function versions of check_value (alert level optional)
  impure function check_value(
    constant value        : boolean;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : boolean;
    constant exp          : boolean;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value            : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : std_logic;
    constant exp          : std_logic;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value            : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "slv"
  ) return boolean;

  impure function check_value(
    constant value        : std_logic_vector;
    constant exp          : std_logic_vector;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "slv"
  ) return boolean;

  impure function check_value(
    constant value            : unsigned;
    constant exp              : unsigned;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "unsigned"
  ) return boolean;

  impure function check_value(
    constant value        : unsigned;
    constant exp          : unsigned;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "unsigned"
  ) return boolean;

  impure function check_value(
    constant value            : signed;
    constant exp              : signed;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "signed"
  ) return boolean;

  impure function check_value(
    constant value        : signed;
    constant exp          : signed;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "signed"
  ) return boolean;

  impure function check_value(
    constant value        : integer;
    constant exp          : integer;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : real;
    constant exp          : real;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : time;
    constant exp          : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value        : string;
    constant exp          : string;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean;

  impure function check_value(
    constant value            : t_slv_array;
    constant exp              : t_slv_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_slv_array"
  ) return boolean;

  impure function check_value(
    constant value        : t_slv_array;
    constant exp          : t_slv_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_slv_array"
  ) return boolean;

  impure function check_value(
    constant value            : t_signed_array;
    constant exp              : t_signed_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_signed_array"
  ) return boolean;

  impure function check_value(
    constant value        : t_signed_array;
    constant exp          : t_signed_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_signed_array"
  ) return boolean;

  impure function check_value(
    constant value            : t_unsigned_array;
    constant exp              : t_unsigned_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_unsigned_array"
  ) return boolean;

  impure function check_value(
    constant value        : t_unsigned_array;
    constant exp          : t_unsigned_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_unsigned_array"
  ) return boolean;

  -- overloads for procedure version of check_value (no return value)
  procedure check_value(
    constant value        : boolean;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value        : boolean;
    constant exp          : boolean;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value            : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "slv"
  );

  procedure check_value(
    constant value        : std_logic_vector;
    constant exp          : std_logic_vector;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "slv"
  );

  procedure check_value(
    constant value            : unsigned;
    constant exp              : unsigned;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "unsigned"
  );

  procedure check_value(
    constant value        : unsigned;
    constant exp          : unsigned;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "unsigned"
  );

  procedure check_value(
    constant value            : signed;
    constant exp              : signed;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "signed"
  );

  procedure check_value(
    constant value        : signed;
    constant exp          : signed;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "signed"
  );

  procedure check_value(
    constant value        : std_logic;
    constant exp          : std_logic;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value            : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()"
  );

  procedure check_value(
    constant value        : integer;
    constant exp          : integer;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value        : real;
    constant exp          : real;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value        : time;
    constant exp          : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value        : string;
    constant exp          : string;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value            : t_slv_array;
    constant exp              : t_slv_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_slv_array"
  );

  procedure check_value(
    constant value        : t_slv_array;
    constant exp          : t_slv_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_slv_array"
  );

  procedure check_value(
    constant value            : t_signed_array;
    constant exp              : t_signed_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_signed_array"
  );

  procedure check_value(
    constant value        : t_signed_array;
    constant exp          : t_signed_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_signed_array"
  );

  procedure check_value(
    constant value            : t_unsigned_array;
    constant exp              : t_unsigned_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_unsigned_array"
  );

  procedure check_value(
    constant value        : t_unsigned_array;
    constant exp          : t_unsigned_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_unsigned_array"
  );

  -- Procedure overloads for check_value without mandatory alert_level
  procedure check_value(
    constant value        : boolean;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value        : boolean;
    constant exp          : boolean;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value            : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "slv"
  );

  procedure check_value(
    constant value        : std_logic_vector;
    constant exp          : std_logic_vector;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "slv"
  );

  procedure check_value(
    constant value            : unsigned;
    constant exp              : unsigned;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "unsigned"
  );

  procedure check_value(
    constant value        : unsigned;
    constant exp          : unsigned;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "unsigned"
  );

  procedure check_value(
    constant value            : signed;
    constant exp              : signed;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "signed"
  );

  procedure check_value(
    constant value        : signed;
    constant exp          : signed;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "signed"
  );

  procedure check_value(
    constant value        : std_logic;
    constant exp          : std_logic;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value            : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()"
  );

  procedure check_value(
    constant value        : integer;
    constant exp          : integer;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value        : real;
    constant exp          : real;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value        : time;
    constant exp          : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value        : string;
    constant exp          : string;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  );

  procedure check_value(
    constant value            : t_slv_array;
    constant exp              : t_slv_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_slv_array"
  );

  procedure check_value(
    constant value        : t_slv_array;
    constant exp          : t_slv_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_slv_array"
  );

  procedure check_value(
    constant value            : t_signed_array;
    constant exp              : t_signed_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_signed_array"
  );

  procedure check_value(
    constant value        : t_signed_array;
    constant exp          : t_signed_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_signed_array"
  );

  procedure check_value(
    constant value            : t_unsigned_array;
    constant exp              : t_unsigned_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_unsigned_array"
  );

  procedure check_value(
    constant value        : t_unsigned_array;
    constant exp          : t_unsigned_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_unsigned_array"
  );

  -- 
  -- Check_value_in_range
  impure function check_value_in_range(
    constant value        : integer;
    constant min_value    : integer;
    constant max_value    : integer;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "integer"
  ) return boolean;

  impure function check_value_in_range(
    constant value        : unsigned;
    constant min_value    : unsigned;
    constant max_value    : unsigned;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "unsigned"
  ) return boolean;

  impure function check_value_in_range(
    constant value        : signed;
    constant min_value    : signed;
    constant max_value    : signed;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "signed"
  ) return boolean;

  impure function check_value_in_range(
    constant value        : time;
    constant min_value    : time;
    constant max_value    : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) return boolean;

  impure function check_value_in_range(
    constant value        : real;
    constant min_value    : real;
    constant max_value    : real;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) return boolean;

  -- Function overloads for check_value_in_range without mandatory alert_level
  impure function check_value_in_range(
    constant value        : integer;
    constant min_value    : integer;
    constant max_value    : integer;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "integer"
  ) return boolean;

  impure function check_value_in_range(
    constant value        : unsigned;
    constant min_value    : unsigned;
    constant max_value    : unsigned;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "unsigned"
  ) return boolean;

  impure function check_value_in_range(
    constant value        : signed;
    constant min_value    : signed;
    constant max_value    : signed;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "signed"
  ) return boolean;

  impure function check_value_in_range(
    constant value        : time;
    constant min_value    : time;
    constant max_value    : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) return boolean;

  impure function check_value_in_range(
    constant value        : real;
    constant min_value    : real;
    constant max_value    : real;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) return boolean;

  -- Procedure overloads for check_value_in_range
  procedure check_value_in_range(
    constant value        : integer;
    constant min_value    : integer;
    constant max_value    : integer;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  procedure check_value_in_range(
    constant value        : unsigned;
    constant min_value    : unsigned;
    constant max_value    : unsigned;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  procedure check_value_in_range(
    constant value        : signed;
    constant min_value    : signed;
    constant max_value    : signed;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  procedure check_value_in_range(
    constant value        : time;
    constant min_value    : time;
    constant max_value    : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  procedure check_value_in_range(
    constant value        : real;
    constant min_value    : real;
    constant max_value    : real;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  -- Procedure overloads for check_value_in_range without mandatory alert_level
  procedure check_value_in_range(
    constant value        : integer;
    constant min_value    : integer;
    constant max_value    : integer;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  procedure check_value_in_range(
    constant value        : unsigned;
    constant min_value    : unsigned;
    constant max_value    : unsigned;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  procedure check_value_in_range(
    constant value        : signed;
    constant min_value    : signed;
    constant max_value    : signed;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  procedure check_value_in_range(
    constant value        : time;
    constant min_value    : time;
    constant max_value    : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  procedure check_value_in_range(
    constant value        : real;
    constant min_value    : real;
    constant max_value    : real;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  );

  -- Check_stable
  procedure check_stable(
    signal target         : boolean;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "boolean"
  );

  procedure check_stable(
    signal target         : in std_logic_vector;
    constant stable_req   : in time;
    constant alert_level  : in t_alert_level;
    variable success      : out boolean;
    constant msg          : in string;
    constant scope        : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : in string         := "check_stable()";
    constant value_type   : in string         := "slv"
  );

  procedure check_stable(
    signal target         : std_logic_vector;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "slv"
  );

  procedure check_stable(
    signal target         : unsigned;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "unsigned"
  );

  procedure check_stable(
    signal target         : signed;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "signed"
  );

  procedure check_stable(
    signal target         : std_logic;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "std_logic"
  );

  procedure check_stable(
    signal target         : integer;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "integer"
  );

  procedure check_stable(
    signal target         : real;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "real"
  );

  -- Procedure overloads for check_stable without mandatory alert_level
  procedure check_stable(
    signal target         : boolean;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "boolean"
  );

  procedure check_stable(
    signal target         : std_logic_vector;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "slv"
  );

  procedure check_stable(
    signal target         : unsigned;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "unsigned"
  );

  procedure check_stable(
    signal target         : signed;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "signed"
  );

  procedure check_stable(
    signal target         : std_logic;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "std_logic"
  );

  procedure check_stable(
    signal target         : integer;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "integer"
  );

  procedure check_stable(
    signal target         : real;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "real"
  );

  procedure await_stable_value(
    signal target         : boolean;
    constant expected     : boolean;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "boolean"
  );

  procedure await_stable_value(
    signal target         : std_logic_vector;
    constant expected     : std_logic_vector;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "slv"
  );

  procedure await_stable_value(
    signal target         : unsigned;
    constant expected     : unsigned;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "unsigned"
  );

  procedure await_stable_value(
    signal target         : signed;
    constant expected     : signed;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "signed"
  );

  procedure await_stable_value(
    signal target         : std_logic;
    constant expected     : std_logic;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "std_logic"
  );

  procedure await_stable_value(
    signal target         : integer;
    constant expected     : integer;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "integer"
  );

  procedure await_stable_value(
    signal target         : real;
    constant expected     : real;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "real"
  );

  impure function random(
    constant length : integer
  ) return std_logic_vector;

  impure function random(
    constant VOID : t_void
  ) return std_logic;

  impure function random(
    constant min_value : integer;
    constant max_value : integer
  ) return integer;

  impure function random(
    constant min_value : real;
    constant max_value : real
  ) return real;

  impure function random(
    constant min_value       : time;
    constant max_value       : time;
    constant time_resolution : time
  ) return time;

  impure function random(
    constant min_value : time;
    constant max_value : time
  ) return time;

  procedure random(
    variable v_seed1  : inout positive;
    variable v_seed2  : inout positive;
    variable v_target : inout std_logic_vector
  );

  procedure random(
    variable v_seed1  : inout positive;
    variable v_seed2  : inout positive;
    variable v_target : inout std_logic
  );

  procedure random(
    constant min_value : integer;
    constant max_value : integer;
    variable v_seed1   : inout positive;
    variable v_seed2   : inout positive;
    variable v_target  : inout integer
  );

  procedure random(
    constant min_value : real;
    constant max_value : real;
    variable v_seed1   : inout positive;
    variable v_seed2   : inout positive;
    variable v_target  : inout real
  );

  procedure random(
    constant min_value       : time;
    constant max_value       : time;
    constant time_resolution : time;
    variable v_seed1         : inout positive;
    variable v_seed2         : inout positive;
    variable v_target        : inout time;
    constant ext_proc_call   : string := ""
  );

  procedure random(
    constant min_value : time;
    constant max_value : time;
    variable v_seed1   : inout positive;
    variable v_seed2   : inout positive;
    variable v_target  : inout time
  );

  procedure randomize(
    constant seed1 : positive;
    constant seed2 : positive;
    constant msg   : string := "randomizing seeds";
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  procedure randomise(
    constant seed1 : positive;
    constant seed2 : positive;
    constant msg   : string := "randomising seeds";
    constant scope : string := C_TB_SCOPE_DEFAULT
  );

  function convert_byte_array_to_slv(
    constant byte_array      : t_byte_array;
    constant byte_endianness : t_byte_endianness
  ) return std_logic_vector;

  function convert_slv_to_byte_array(
    constant slv             : std_logic_vector;
    constant byte_endianness : t_byte_endianness
  ) return t_byte_array;

  function convert_byte_array_to_slv_array(
    constant byte_array      : t_byte_array;
    constant bytes_in_word   : natural;
    constant byte_endianness : t_byte_endianness := LOWER_BYTE_LEFT
  ) return t_slv_array;

  function convert_slv_array_to_byte_array(
    constant slv_array       : t_slv_array;
    constant byte_endianness : t_byte_endianness := LOWER_BYTE_LEFT
  ) return t_byte_array;

  function convert_slv_array_to_byte_array(
    constant slv_array       : t_slv_array;
    constant ascending       : boolean           := false;
    constant byte_endianness : t_byte_endianness := LOWER_BYTE_LEFT
  ) return t_byte_array;

  function reverse_vector(
    constant value : std_logic_vector
  ) return std_logic_vector;

  impure function reverse_vectors_in_array(
    constant value : t_slv_array
  ) return t_slv_array;

  function log2(
    constant num : positive
  ) return natural;

  -- Warning! This function should NOT be used outside the UVVM library.
  --          Function is only included to support internal functionality.
  --          The function can be removed without notification.
  function matching_values(
    constant value1           : in std_logic_vector;
    constant value2           : in std_logic_vector;
    constant match_strictness : in t_match_strictness := MATCH_STD
  ) return boolean;

  -- ============================================================================
  -- Time consuming checks
  -- ============================================================================
  procedure await_change(
    signal target         : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "boolean"
  );

  procedure await_change(
    signal target         : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "std_logic"
  );

  procedure await_change(
    signal target         : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "slv"
  );

  procedure await_change(
    signal target         : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "unsigned"
  );

  procedure await_change(
    signal target         : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "signed"
  );

  procedure await_change(
    signal target         : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "integer"
  );

  procedure await_change(
    signal target         : real;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "real"
  );

  -- Procedure overloads for await_change without mandatory alert_level
  procedure await_change(
    signal target         : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "boolean"
  );

  procedure await_change(
    signal target         : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "std_logic"
  );

  procedure await_change(
    signal target         : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "slv"
  );

  procedure await_change(
    signal target         : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "unsigned"
  );

  procedure await_change(
    signal target         : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "signed"
  );

  procedure await_change(
    signal target         : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "integer"
  );

  procedure await_change(
    signal target         : real;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "real"
  );

  -- Await Value procedures
  procedure await_value(
    signal target         : boolean;
    constant exp          : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target             : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : std_logic;
    constant exp          : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target             : in std_logic_vector;
    constant exp              : in std_logic_vector;
    constant match_strictness : in t_match_strictness;
    constant min_time         : in time;
    constant max_time         : in time;
    constant alert_level      : in t_alert_level;
    variable success          : out boolean;
    constant msg              : in string;
    constant scope            : in string         := C_TB_SCOPE_DEFAULT;
    constant radix            : in t_radix        := HEX_BIN_IF_INVALID;
    constant format           : in t_format_zeros := SKIP_LEADING_0;
    constant msg_id           : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : in t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : in string         := ""
  );

  procedure await_value(
    signal target             : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := SKIP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : std_logic_vector;
    constant exp          : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : unsigned;
    constant exp          : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : signed;
    constant exp          : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : integer;
    constant exp          : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : real;
    constant exp          : real;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  -- Await Value Overloads without Mandatory Alert_Level
  procedure await_value(
    signal target         : boolean;
    constant exp          : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target             : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : std_logic;
    constant exp          : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target             : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := SKIP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : std_logic_vector;
    constant exp          : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : unsigned;
    constant exp          : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : signed;
    constant exp          : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : integer;
    constant exp          : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_value(
    signal target         : real;
    constant exp          : real;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  -- main std_logic version
  procedure await_change_to_value(
    signal target             : std_logic;
    constant exp_value        : std_logic;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant value_type       : string         := "std_logic"
  );

  procedure await_change_to_value(
    signal target         : std_logic;
    constant exp_value    : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_change_to_value(
    signal target         : std_logic;
    constant exp_value    : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_change_to_value(
    signal target             : std_logic;
    constant exp_value        : std_logic;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  );

  -- main std_logic_vector version
  procedure await_change_to_value(
    signal target             : std_logic_vector;
    constant exp_value        : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant value_type       : string         := "std_logic_vector"
  );

  procedure await_change_to_value(
    signal target         : std_logic_vector;
    constant exp_value    : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_change_to_value(
    signal target         : std_logic_vector;
    constant exp_value    : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_change_to_value(
    signal target             : std_logic_vector;
    constant exp_value        : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  );

  -- main boolean version
  procedure await_change_to_value(
    signal target         : boolean;
    constant exp_value    : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "boolean"
  );

  procedure await_change_to_value(
    signal target         : boolean;
    constant exp_value    : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  -- main unsigned version
  procedure await_change_to_value(
    signal target         : unsigned;
    constant exp_value    : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "unsigned"
  );

  procedure await_change_to_value(
    signal target         : unsigned;
    constant exp_value    : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  -- main signed version
  procedure await_change_to_value(
    signal target         : signed;
    constant exp_value    : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "signed"
  );

  procedure await_change_to_value(
    signal target         : signed;
    constant exp_value    : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  -- main integer version
  procedure await_change_to_value(
    signal target         : integer;
    constant exp_value    : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "integer"
  );

  procedure await_change_to_value(
    signal target         : integer;
    constant exp_value    : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  -- main real version
  procedure await_change_to_value(
    signal target         : real;
    constant exp_value    : real;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "real"
  );

  procedure await_change_to_value(
    signal target         : real;
    constant exp_value    : real;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  -- Await Stable Procedures
  procedure await_stable(
    signal target            : boolean;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : std_logic;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : in std_logic_vector;
    constant stable_req      : in time; -- Minimum stable requirement
    constant stable_req_from : in t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : in time; -- Timeout if stable_req not achieved
    constant timeout_from    : in t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : in t_alert_level;
    variable success         : out boolean;
    constant msg             : in string;
    constant scope           : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : in t_msg_id_panel := shared_msg_id_panel;
    constant caller_name     : in string         := ""
  );

  procedure await_stable(
    signal target            : std_logic_vector;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : unsigned;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : signed;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : integer;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : real;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  -- Await Stable Procedures without Mandatory Alert_Level
  -- Await Stable Procedures
  procedure await_stable(
    signal target            : boolean;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : std_logic;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : std_logic_vector;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : unsigned;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : signed;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : integer;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  procedure await_stable(
    signal target            : real;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  );

  impure function check_sb_completion(
    constant alert_level          : t_alert_level;
    constant print_alert_counters : t_report_alert_counters := NO_REPORT;
    constant print_sbs            : t_report_sb             := NO_REPORT;
    constant scope                : string                  := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel         : t_msg_id_panel          := shared_msg_id_panel;
    constant ext_proc_call        : string                  := ""
  ) return boolean;

  impure function check_sb_completion(
    constant void : t_void
  ) return boolean;

  procedure check_sb_completion(
    constant alert_level          : t_alert_level;
    constant print_alert_counters : t_report_alert_counters := NO_REPORT;
    constant print_sbs            : t_report_sb             := NO_REPORT;
    constant scope                : string                  := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel         : t_msg_id_panel          := shared_msg_id_panel
  );

  procedure check_sb_completion(
    constant void : t_void
  );

  procedure await_sb_completion(
    constant timeout              : time;
    constant alert_level          : t_alert_level           := TB_ERROR;
    constant sb_poll_time         : time                    := 100 us;
    constant print_alert_counters : t_report_alert_counters := NO_REPORT;
    constant print_sbs            : t_report_sb             := NO_REPORT;
    constant scope                : string                  := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel         : t_msg_id_panel          := shared_msg_id_panel;
    constant ext_proc_call        : string                  := ""
  );

  -----------------------------------------------------
  -- Pulse Generation Procedures
  -----------------------------------------------------
  procedure gen_pulse(
    signal target           : inout std_logic;
    constant pulse_value    : std_logic;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout std_logic;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout std_logic;
    constant pulse_value    : std_logic;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout std_logic;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target         : inout std_logic;
    constant pulse_value  : std_logic;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target         : inout std_logic;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout boolean;
    constant pulse_value    : boolean;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout boolean;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout boolean;
    constant pulse_value    : boolean;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout boolean;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target         : inout boolean;
    constant pulse_value  : boolean;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target         : inout boolean;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout std_logic_vector;
    constant pulse_value    : std_logic_vector;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout std_logic_vector;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout std_logic_vector;
    constant pulse_value    : std_logic_vector;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target           : inout std_logic_vector;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target         : inout std_logic_vector;
    constant pulse_value  : std_logic_vector;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  procedure gen_pulse(
    signal target         : inout std_logic_vector;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  );

  -----------------------------------------------------
  -- Clock Generator Procedures
  -----------------------------------------------------
  procedure clock_generator(
    signal clock_signal            : inout std_logic;
    constant clock_period          : in time;
    constant clock_high_percentage : in natural range 1 to 99 := 50
  );

  -- Overloaded version with duty cycle in time
  procedure clock_generator(
    signal clock_signal      : inout std_logic;
    constant clock_period    : in time;
    constant clock_high_time : in time
  );

  -- Overloaded version with clock count
  procedure clock_generator(
    signal clock_signal            : inout std_logic;
    signal clock_count             : inout natural;
    constant clock_period          : in time;
    constant clock_high_percentage : in natural range 1 to 99 := 50
  );

  -- Overloaded version with clock count and duty cycle in time
  procedure clock_generator(
    signal clock_signal      : inout std_logic;
    signal clock_count       : inout natural;
    constant clock_period    : in time;
    constant clock_high_time : in time
  );

  -- Overloaded version with clock enable and clock name
  procedure clock_generator(
    signal clock_signal            : inout std_logic;
    signal clock_ena               : in boolean;
    constant clock_period          : in time;
    constant clock_name            : in string;
    constant clock_high_percentage : in natural range 1 to 99 := 50
  );

  -- Overloaded version with clock enable, clock name
  -- and duty cycle in time.
  procedure clock_generator(
    signal clock_signal      : inout std_logic;
    signal clock_ena         : in boolean;
    constant clock_period    : in time;
    constant clock_name      : in string;
    constant clock_high_time : in time
  );

  -- Overloaded version with clock enable, clock name
  -- and clock count
  procedure clock_generator(
    signal clock_signal            : inout std_logic;
    signal clock_ena               : in boolean;
    signal clock_count             : out natural;
    constant clock_period          : in time;
    constant clock_name            : in string;
    constant clock_high_percentage : in natural range 1 to 99 := 50
  );

  -- Overloaded version with clock enable, clock name,
  -- clock count and duty cycle in time.
  procedure clock_generator(
    signal clock_signal      : inout std_logic;
    signal clock_ena         : in boolean;
    signal clock_count       : out natural;
    constant clock_period    : in time;
    constant clock_name      : in string;
    constant clock_high_time : in time
  );

  -----------------------------------------------------
  -- Adjustable Clock Generator Procedures
  -----------------------------------------------------  
  procedure adjustable_clock_generator(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in boolean;
    constant clock_period        : in time;
    signal clock_high_percentage : in natural range 0 to 100
  );

  procedure adjustable_clock_generator(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in boolean;
    constant clock_period        : in time;
    constant clock_name          : in string;
    signal clock_high_percentage : in natural range 0 to 100
  );

  -- Overloaded version with clock enable, clock name
  -- and clock count
  procedure adjustable_clock_generator(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in boolean;
    signal clock_count           : out natural;
    constant clock_period        : in time;
    constant clock_name          : in string;
    signal clock_high_percentage : in natural range 0 to 100
  );

  procedure deallocate_line_if_exists(
    variable line_to_be_deallocated : inout line
  );

  -- ============================================================================
  -- Synchronization methods
  -- ============================================================================
  -- method to block a global flag with the name flag_name
  procedure block_flag(
    constant flag_name                : in string;
    constant msg                      : in string;
    constant already_blocked_severity : in t_alert_level := warning;
    constant scope                    : in string        := C_TB_SCOPE_DEFAULT
  );

  -- method to unblock a global flag with the name flag_name
  procedure unblock_flag(
    constant flag_name : in string;
    constant msg       : in string;
    signal trigger     : inout std_logic; -- Parameter must be global_trigger as method await_unblock_flag() uses that global signal to detect unblocking.
    constant scope     : in string := C_TB_SCOPE_DEFAULT
  );

  -- method to wait for the global flag with the name flag_name
  procedure await_unblock_flag(
    constant flag_name        : in string;
    constant timeout          : in time;
    constant msg              : in string;
    constant flag_returning   : in t_flag_returning := KEEP_UNBLOCKED;
    constant timeout_severity : in t_alert_level    := error;
    constant scope            : in string           := C_TB_SCOPE_DEFAULT
  );
  procedure await_barrier(
    signal barrier_signal     : inout std_logic;
    constant timeout          : in time;
    constant msg              : in string;
    constant timeout_severity : in t_alert_level := error;
    constant scope            : in string        := C_TB_SCOPE_DEFAULT
  );
  -------------------------------------------
  -- await_semaphore_in_delta_cycles
  -------------------------------------------
  -- tries to lock the semaphore for C_NUM_SEMAPHORE_LOCK_TRIES in adaptations_pkg
  procedure await_semaphore_in_delta_cycles(
    variable semaphore : inout t_protected_semaphore
  );
  -------------------------------------------
  -- release_semaphore
  -------------------------------------------
  -- releases the semaphore
  procedure release_semaphore(
    variable semaphore : inout t_protected_semaphore
  );

  -- ============================================================================
  -- Watchdog-related
  -- ============================================================================
  procedure watchdog_timer(
    signal watchdog_ctrl : in t_watchdog_ctrl;
    constant timeout     : time;
    constant alert_level : t_alert_level := error;
    constant msg         : string        := ""
  );

  procedure extend_watchdog(
    signal watchdog_ctrl : inout t_watchdog_ctrl;
    constant time_extend : time := 0 ns
  );

  procedure reinitialize_watchdog(
    signal watchdog_ctrl : inout t_watchdog_ctrl;
    constant timeout     : time
  );

  procedure terminate_watchdog(
    signal watchdog_ctrl : inout t_watchdog_ctrl
  );

  -- ============================================================================
  -- generate_crc
  -- ============================================================================
  --
  -- This function generate the CRC based on the input values. CRC is generated
  -- MSb first.
  --
  -- Input criteria:
  --   - Inputs have to be decending (CRC generated from high to low)
  --   - crc_in must be one bit shorter than polynomial
  --
  -- Return vector is one bit shorter than polynomial
  --
  ---------------------------------------------------------------------------------
  impure function generate_crc(
    constant data       : in std_logic_vector;
    constant crc_in     : in std_logic_vector;
    constant polynomial : in std_logic_vector
  ) return std_logic_vector;

  -- slv array have to be acending
  impure function generate_crc(
    constant data       : in t_slv_array;
    constant crc_in     : in std_logic_vector;
    constant polynomial : in std_logic_vector
  ) return std_logic_vector;

end package;

--=================================================================================================
--=================================================================================================
--=================================================================================================

package body methods_pkg is

  constant C_BURIED_SCOPE : string := "(Util buried)";

  -- The following constants are not used. Report statements in the given functions allow elaboration time messages
  constant C_BITVIS_LICENSE_INITIALISED        : boolean := show_license(VOID);
  constant C_BITVIS_LIBRARY_INFO_SHOWN         : boolean := show_uvvm_utility_library_info(VOID);
  constant C_BITVIS_LIBRARY_RELEASE_INFO_SHOWN : boolean := show_uvvm_utility_library_release_info(VOID);

  -- ============================================================================
  -- Initialisation and license
  -- ============================================================================
  --   -- Executed a single time ONLY
  --   procedure pot_show_license(
  --     constant dummy  : in t_void
  --     ) is
  --   begin
  --     if not shared_license_shown then
  --       show_license(v_trial_license);
  --       shared_license_shown := true;
  --     end if;
  --   end;
  --   -- Executed a single time ONLY
  --   procedure initialise_util(
  --     constant dummy  : in t_void
  --     ) is
  --   begin
  --     set_log_file_name(C_LOG_FILE_NAME);
  --     set_alert_file_name(C_ALERT_FILE_NAME);
  --     shared_license_shown.set(1);
  --     shared_initialised_util.set(true);
  --   end;
  procedure pot_initialise_util(
    constant dummy : in t_void
  ) is
    variable v_minimum_log_line_width : natural := 0;
  begin
    if not shared_initialised_util then
      shared_initialised_util := true;
      if not shared_log_file_name_is_set then
        set_log_file_name(C_LOG_FILE_NAME);
      end if;
      if not shared_alert_file_name_is_set then
        set_alert_file_name(C_ALERT_FILE_NAME);
      end if;
      if C_ENABLE_HIERARCHICAL_ALERTS then
        initialize_hierarchy;
      end if;

      -- Check that all log widths are valid
      v_minimum_log_line_width := v_minimum_log_line_width + C_LOG_PREFIX_WIDTH + C_LOG_TIME_WIDTH + 5; -- Add 5 for spaces
      if not (C_SHOW_LOG_ID or C_SHOW_LOG_SCOPE) then
        v_minimum_log_line_width := v_minimum_log_line_width + 10; -- Minimum length in order to wrap lines properly
      else
        if C_SHOW_LOG_ID then
          v_minimum_log_line_width := v_minimum_log_line_width + C_LOG_MSG_ID_WIDTH;
        end if;
        if C_SHOW_LOG_SCOPE then
          v_minimum_log_line_width := v_minimum_log_line_width + C_LOG_SCOPE_WIDTH;
        end if;
      end if;

      bitvis_assert(C_LOG_LINE_WIDTH >= v_minimum_log_line_width, failure, "C_LOG_LINE_WIDTH is too low. Needs to higher than " & to_string(v_minimum_log_line_width) & ". ", C_SCOPE);

      --show_license(VOID);
      --       if C_SHOW_uvvm_utilITY_LIBRARY_INFO then
      --         show_uvvm_utility_library_info(VOID);
      --       end if;
      --       if C_SHOW_uvvm_utilITY_LIBRARY_RELEASE_INFO then
      --         show_uvvm_utility_library_release_info(VOID);
      --       end if;
    end if;
  end procedure;

  procedure deallocate_line_if_exists(
    variable line_to_be_deallocated : inout line
  ) is
  begin
    deprecate(get_procedure_name_from_instance_name(line_to_be_deallocated'instance_name), "deallocating a null-line shal have no effect according to the LRM. Just use deallocate()");
    if line_to_be_deallocated /= null then
      deallocate(line_to_be_deallocated);
    end if;
  end procedure;

  -- ============================================================================
  -- File handling (that needs to use other utility methods)
  -- ============================================================================
  procedure check_file_open_status(
    constant status    : in file_open_status;
    constant file_name : in string;
    constant scope     : in string := C_SCOPE
  ) is
  begin
    case status is
      when open_ok =>
        null; --**** logmsg (if log is open for write)
      when status_error =>
        alert(tb_warning, "File: " & file_name & " is already open", scope);
      when name_error =>
        alert(tb_error, "Cannot open file: " & file_name, scope);
      when mode_error =>
        alert(tb_error, "File: " & file_name & " exists, but cannot be opened in write mode", scope);
    end case;
  end procedure;

  procedure set_alert_file_name(
    constant file_name : string := C_ALERT_FILE_NAME
  ) is
    variable v_file_open_status : file_open_status;
  begin
    if C_WARNING_ON_LOG_ALERT_FILE_RUNTIME_RENAME and shared_alert_file_name_is_set then
      warning("alert file name already set. Setting new alert file " & file_name);
    end if;
    shared_alert_file_name_is_set := true;
    file_close(ALERT_FILE);
    file_open(v_file_open_status, ALERT_FILE, file_name, write_mode);
    check_file_open_status(v_file_open_status, file_name);

    if now > 0 ns then -- Do not show note if set at the very start.
      -- NOTE: We should usually use log() instead of report. However,
      --       in this case, there is an issue with log() initialising
      --       the log file and therefore blocking subsequent set_log_file_name().
      report "alert file name set: " & file_name;
    end if;
  end procedure;

  procedure set_alert_file_name(
    constant file_name : string := C_ALERT_FILE_NAME;
    constant msg_id    : t_msg_id
  ) is
    variable v_file_open_status : file_open_status;
  begin
    deprecate(get_procedure_name_from_instance_name(file_name'instance_name), "msg_id parameter is no longer in use. Please call this procedure without the msg_id parameter.");
    set_alert_file_name(file_name);
  end procedure;

  procedure set_log_file_name(
    constant file_name : string := C_LOG_FILE_NAME
  ) is
    variable v_file_open_status : file_open_status;
  begin
    if C_WARNING_ON_LOG_ALERT_FILE_RUNTIME_RENAME and shared_log_file_name_is_set then
      warning("log file name already set. Setting new log file " & file_name);
    end if;
    shared_log_file_name_is_set := true;
    file_close(LOG_FILE);
    file_open(v_file_open_status, LOG_FILE, file_name, write_mode);
    check_file_open_status(v_file_open_status, file_name);

    if now > 0 ns then -- Do not show note if set at the very start.
      -- NOTE: We should usually use log() instead of report. However,
      --       in this case, there is an issue with log() initialising
      --       the alert file and therefore blocking subsequent set_alert_file_name().
      report "log file name set: " & file_name;
    end if;
  end procedure;

  procedure set_log_file_name(
    constant file_name : string := C_LOG_FILE_NAME;
    constant msg_id    : t_msg_id
  ) is
  begin
    -- msg_id is no longer in use. However, can not call deprecate() since Util may not
    -- have opened a log file yet. Attempting to call deprecate() when there is no open
    -- log file will cause a fatal error. Leaving this alone with no message.
    set_log_file_name(file_name);
  end procedure;

  -- ============================================================================
  -- Log-related
  -- ============================================================================
  impure function align_log_time(
    value : time
  ) return string is
    variable v_line                : line;
    variable v_value_width         : natural;
    variable v_result              : string(1 to 50); -- sufficient for any relevant time value
    variable v_result_width        : natural;
    variable v_delimeter_pos       : natural;
    variable v_time_number_width   : natural;
    variable v_time_width          : natural;
    variable v_num_initial_blanks  : integer;
    variable v_found_decimal_point : boolean;
  begin
    -- 1. Store normal write (to string) and note width
    write(v_line, value, left, 0, C_LOG_TIME_BASE); -- required as width is unknown
    v_value_width                := v_line'length;
    v_result(1 to v_value_width) := v_line.all;
    deallocate(v_line);

    -- 2. Search for decimal point or space between number and unit
    v_found_decimal_point := true; -- default
    v_delimeter_pos       := pos_of_leftmost('.', v_result(1 to v_value_width), 0);
    if v_delimeter_pos = 0 then -- No decimal point found
      v_found_decimal_point := false;
      v_delimeter_pos       := pos_of_leftmost(' ', v_result(1 to v_value_width), 0);
    end if;

    -- Potentially alert if time stamp is truncated.
    if C_LOG_TIME_TRUNC_WARNING then
      if not shared_warned_time_stamp_trunc then
        if (C_LOG_TIME_DECIMALS < (v_value_width - 3 - v_delimeter_pos)) then
          alert(TB_WARNING, "Time stamp has been truncated to " & to_string(C_LOG_TIME_DECIMALS) & " decimal(s) in the next log message - settable in adaptations_pkg." & " (Actual time stamp has more decimals than displayed) " & "\nThis alert is shown once only.",
          C_BURIED_SCOPE);
          shared_warned_time_stamp_trunc := true;
        end if;
      end if;
    end if;

    -- 3. Derive Time number (integer or real)
    if C_LOG_TIME_DECIMALS = 0 then
      v_time_number_width := v_delimeter_pos - 1;
      -- v_result as is
    else -- i.e. a decimal value is required
      if v_found_decimal_point then
        v_result(v_value_width - 2 to v_result'right) := (others => '0'); -- Zero extend
      else -- Shift right after integer part and add point
        v_result(v_delimeter_pos + 1 to v_result'right) := v_result(v_delimeter_pos to v_result'right - 1);
        v_result(v_delimeter_pos)                       := '.';
        v_result(v_value_width - 1 to v_result'right)   := (others => '0'); -- Zero extend
      end if;
      v_time_number_width := v_delimeter_pos + C_LOG_TIME_DECIMALS;
    end if;

    -- 4. Add time unit for full time specification
    v_time_width := v_time_number_width + 3;
    if C_LOG_TIME_BASE = ns then
      v_result(v_time_number_width + 1 to v_time_width) := " ns";
    else
      v_result(v_time_number_width + 1 to v_time_width) := " ps";
    end if;

    -- 5. Prefix
    v_num_initial_blanks := maximum(0, (C_LOG_TIME_WIDTH - v_time_width));
    if v_num_initial_blanks > 0 then
      v_result(v_num_initial_blanks + 1 to v_result'right) := v_result(1 to v_result'right - v_num_initial_blanks);
      v_result(1 to v_num_initial_blanks)                  := fill_string(' ', v_num_initial_blanks);
      v_result_width                                       := C_LOG_TIME_WIDTH;
    else
      -- v_result as is
      v_result_width := v_time_width;
    end if;
    return v_result(1 to v_result_width);
  end function;

  -- Writes Line to a file without modifying the contents of the line
  -- Not yet available in VHDL
  procedure tee(
    file file_handle : text;
    variable my_line : inout line
  ) is
    variable v_line : line;
  begin
    write(v_line, my_line.all);
    writeline(file_handle, v_line);
    deallocate(v_line);
  end procedure;

  -- Open, append/write to and close file. Also deallocates contents of the line
  procedure write_to_file(
    file_name        : string;
    open_mode        : file_open_kind;
    variable my_line : inout line
  ) is
    file v_specified_file_pointer : text;
  begin
    file_open(v_specified_file_pointer, file_name, open_mode);
    writeline(v_specified_file_pointer, my_line);
    file_close(v_specified_file_pointer);
  end procedure;

  procedure write_line_to_log_destination(
    variable log_line        : inout line;
    constant log_destination : in t_log_destination := shared_default_log_destination;
    constant log_file_name   : in string            := C_LOG_FILE_NAME;
    constant open_mode       : in file_open_kind    := append_mode) is
  begin
    -- Write the info string to the target file
    if log_file_name'length = 0 and (log_destination = LOG_ONLY or log_destination = CONSOLE_AND_LOG) then
      -- Output file specified, but file name was invalid.
      alert(TB_ERROR, "log called with log_destination " & to_upper(to_string(log_destination)) & ", but log file name was empty.");
    else
      case log_destination is
        when CONSOLE_AND_LOG =>
          tee(OUTPUT, log_line); -- write to transcript, while keeping the line contents
          -- write to file
          if log_file_name = C_LOG_FILE_NAME then
            -- If the log file is the default file, it is not necessary to open and close it again
            writeline(LOG_FILE, log_line);
          else
            -- If the log file is a custom file name, the file will have to be opened.
            write_to_file(log_file_name, open_mode, log_line);
          end if;
        when CONSOLE_ONLY =>
          writeline(OUTPUT, log_line); -- Write to console and deallocate contents of line
        when LOG_ONLY =>
          if log_file_name = C_LOG_FILE_NAME then
            -- If the log file is the default file, it is not necessary to open and close it again
            writeline(LOG_FILE, log_line);
          else
            -- If the log file is a custom file name, the file will have to be opened.
            write_to_file(log_file_name, open_mode, log_line);
          end if;
      end case;
    end if;
  end procedure;

  procedure log(
    msg_id          : t_msg_id;
    msg             : string;
    scope           : string            := C_TB_SCOPE_DEFAULT;
    msg_id_panel    : t_msg_id_panel    := shared_msg_id_panel; -- compatible with old code
    log_destination : t_log_destination := shared_default_log_destination;
    log_file_name   : string            := C_LOG_FILE_NAME;
    open_mode       : file_open_kind    := append_mode
  ) is
    constant C_MSG_NORMALISED     : string(1 to msg'length) := msg;
    variable v_msg               : line;
    variable v_msg_indent        : line;
    variable v_msg_indent_width  : natural;
    variable v_info              : line;
    variable v_info_final        : line;
    variable v_log_msg_id        : string(1 to C_LOG_MSG_ID_WIDTH);
    variable v_log_scope         : string(1 to C_LOG_SCOPE_WIDTH);
    variable v_log_pre_msg_width : natural;
    variable v_idx               : natural := 1;

  begin
    -- Check if message ID is enabled
    if (msg_id_panel(msg_id) = ENABLED) then
      pot_initialise_util(VOID); -- Only executed the first time called

      -- Prepare strings for msg_id and scope
      v_log_msg_id := to_upper(justify(to_string(msg_id), left, C_LOG_MSG_ID_WIDTH, KEEP_LEADING_SPACE, ALLOW_TRUNCATE));
      if (scope'length = 0) then
        v_log_scope := justify("(non scoped)", left, C_LOG_SCOPE_WIDTH, KEEP_LEADING_SPACE, ALLOW_TRUNCATE);
      else
        v_log_scope := justify(to_string(scope), left, C_LOG_SCOPE_WIDTH, KEEP_LEADING_SPACE, ALLOW_TRUNCATE);
      end if;

      -- Handle actual log info line
      -- First write all fields preceeding the actual message - in order to measure their width
      -- (Prefix is taken care of later)
      write(v_info,
      return_string_if_true(v_log_msg_id, C_SHOW_LOG_ID) & -- Optional
      " " & align_log_time(now) & "  " & return_string_if_true(v_log_scope, C_SHOW_LOG_SCOPE) & " "); -- Optional
      v_log_pre_msg_width := v_info'length; -- Width of string preceeding the actual message
      -- Handle \r as potential initial open line
      if msg'length > 1 then
        if C_USE_BACKSLASH_R_AS_LF then
          loop
            if (C_MSG_NORMALISED(v_idx to v_idx + 1) = "\r") then
              write(v_info_final, LF); -- Start transcript with an empty line
              v_idx := v_idx + 2;
            else
              write(v_msg, remove_initial_chars(msg, v_idx - 1));
              exit;
            end if;
          end loop;
        else
          write(v_msg, msg);
        end if;
      end if;

      -- Handle dedicated ID indentation.
      write(v_msg_indent, to_string(C_MSG_ID_INDENT(msg_id)));
      v_msg_indent_width := v_msg_indent'length;
      write(v_info, v_msg_indent.all);
      deallocate(v_msg_indent);

      -- Then add the message it self (after replacing \n with LF
      if msg'length > 1 then
        write(v_info, to_string(replace_backslash_n_with_lf(v_msg.all)));
      end if;
      deallocate(v_msg);

      if not C_SINGLE_LINE_LOG then
        -- Modify and align info-string if additional lines are required (after wrapping lines)
        wrap_lines(v_info, 1, v_log_pre_msg_width + v_msg_indent_width + 1, C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH);
      else
        -- Remove line feed character if
        -- single line log/alert enabled
        replace(v_info, LF, ' ');
      end if;

      -- Handle potential log header by including info-lines inside the log header format and update of waveview header.
      if (msg_id = ID_LOG_HDR) then
        write(v_info_final, LF & LF);
        -- also update the Log header string
        shared_current_log_hdr.normal := justify(msg, left, C_LOG_HDR_FOR_WAVEVIEW_WIDTH, KEEP_LEADING_SPACE, ALLOW_TRUNCATE);
        shared_log_hdr_for_waveview   := justify(msg, left, C_LOG_HDR_FOR_WAVEVIEW_WIDTH, KEEP_LEADING_SPACE, ALLOW_TRUNCATE);
      elsif (msg_id = ID_LOG_HDR_LARGE) then
        write(v_info_final, LF & LF);
        shared_current_log_hdr.large := justify(msg, left, C_LOG_HDR_FOR_WAVEVIEW_WIDTH, KEEP_LEADING_SPACE, ALLOW_TRUNCATE);
        write(v_info_final, fill_string('=', (C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH)) & LF);
      elsif (msg_id = ID_LOG_HDR_XL) then
        write(v_info_final, LF & LF);
        shared_current_log_hdr.xl := justify(msg, left, C_LOG_HDR_FOR_WAVEVIEW_WIDTH, KEEP_LEADING_SPACE, ALLOW_TRUNCATE);
        write(v_info_final, LF & fill_string('#', (C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH)) & LF & LF);
      end if;

      write(v_info_final, v_info.all); -- include actual info
      deallocate(v_info);
      -- Handle rest of potential log header
      if (msg_id = ID_LOG_HDR) then
        write(v_info_final, LF & fill_string('-', (C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH)));
      elsif (msg_id = ID_LOG_HDR_LARGE) then
        write(v_info_final, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH)));
      elsif (msg_id = ID_LOG_HDR_XL) then
        write(v_info_final, LF & LF & fill_string('#', (C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH)) & LF & LF);
      end if;

      -- Add prefix to all lines
      prefix_lines(v_info_final);

      -- Write the info string to the target file
      if log_file_name'length = 0 and (log_destination = LOG_ONLY or log_destination = CONSOLE_AND_LOG) then
        -- Output file specified, but file name was invalid.
        alert(TB_ERROR, "log called with log_destination " & to_upper(to_string(log_destination)) & ", but log file name was empty.");
      else
        case log_destination is
          when CONSOLE_AND_LOG =>
            tee(OUTPUT, v_info_final); -- write to transcript, while keeping the line contents
            -- write to file
            if log_file_name = C_LOG_FILE_NAME then
              -- If the log file is the default file, it is not necessary to open and close it again
              writeline(LOG_FILE, v_info_final);
            else
              -- If the log file is a custom file name, the file will have to be opened.
              write_to_file(log_file_name, open_mode, v_info_final);
            end if;
          when CONSOLE_ONLY =>
            writeline(OUTPUT, v_info_final); -- Write to console and deallocate contents of line
          when LOG_ONLY =>
            if log_file_name = C_LOG_FILE_NAME then
              -- If the log file is the default file, it is not necessary to open and close it again
              writeline(LOG_FILE, v_info_final);
            else
              -- If the log file is a custom file name, the file will have to be opened.
              write_to_file(log_file_name, open_mode, v_info_final);
            end if;
        end case;
        deallocate(v_info_final);
      end if;
    end if;
  end procedure;

  -- Calls overloaded log procedure with default msg_id
  procedure log(
    msg             : string;
    scope           : string            := C_TB_SCOPE_DEFAULT;
    msg_id_panel    : t_msg_id_panel    := shared_msg_id_panel; -- compatible with old code
    log_destination : t_log_destination := shared_default_log_destination;
    log_file_name   : string            := C_LOG_FILE_NAME;
    open_mode       : file_open_kind    := append_mode
  ) is
  begin
    log(C_TB_MSG_ID_DEFAULT, msg, scope, msg_id_panel, log_destination, log_file_name, open_mode);
  end procedure;

  -- Logging for multi line text. Also deallocates the text_block, for consistency.
  procedure log_text_block(
    msg_id              : t_msg_id;
    variable text_block : inout line;
    formatting          : t_log_format; -- FORMATTED or UNFORMATTED
    msg_header          : string               := "";
    scope               : string               := C_TB_SCOPE_DEFAULT;
    msg_id_panel        : t_msg_id_panel       := shared_msg_id_panel;
    log_if_block_empty  : t_log_if_block_empty := WRITE_HDR_IF_BLOCK_EMPTY;
    log_destination     : t_log_destination    := shared_default_log_destination;
    log_file_name       : string               := C_LOG_FILE_NAME;
    open_mode           : file_open_kind       := append_mode
  ) is
    variable v_text_block_empty_note : string(1 to 26) := "Note: Text block was empty";
    variable v_header_line           : line;
    variable v_log_body              : line;
    variable v_text_block_is_empty   : boolean;
  begin
    if ((log_file_name'length = 0) and ((log_destination = CONSOLE_AND_LOG) or (log_destination = LOG_ONLY))) then
      alert(TB_ERROR, "log_text_block called with log_destination " & to_upper(to_string(log_destination)) & ", but log file name was empty.");
      -- Check if message ID is enabled
    elsif (msg_id_panel(msg_id) = ENABLED) then
      pot_initialise_util(VOID); -- Only executed the first time called

      v_text_block_is_empty := (text_block = null);

      if (formatting = UNFORMATTED) then
        if (not v_text_block_is_empty) then
          -- Write the info string to the target file without any header, footer or indentation
          case log_destination is
            when CONSOLE_AND_LOG =>
              tee(OUTPUT, text_block); -- Write to console, but keep text_block
              -- Write to log and deallocate text_block. Open specified file if not open.
              if log_file_name = C_LOG_FILE_NAME then
                writeline(LOG_FILE, text_block);
              else
                write_to_file(log_file_name, open_mode, text_block);
              end if;
            when CONSOLE_ONLY =>
              writeline(OUTPUT, text_block); -- Write to console and deallocate text_block
            when LOG_ONLY =>
              -- Write to log and deallocate text_block. Open specified file if not open.
              if log_file_name = C_LOG_FILE_NAME then
                writeline(LOG_FILE, text_block);
              else
                write_to_file(log_file_name, open_mode, text_block);
              end if;
          end case;

        end if;
      elsif not (v_text_block_is_empty and (log_if_block_empty = SKIP_LOG_IF_BLOCK_EMPTY)) then

        -- Add and print header
        write(v_header_line, LF & LF & fill_string('*', (C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH)));
        prefix_lines(v_header_line);

        -- Add header underline, body and footer
        write(v_log_body, fill_string('-', (C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH)) & LF);
        if v_text_block_is_empty then
          if log_if_block_empty = NOTIFY_IF_BLOCK_EMPTY then
            write(v_log_body, v_text_block_empty_note); -- Notify that the text block was empty
          end if;
        else
          write(v_log_body, text_block.all); -- include input text
        end if;
        write(v_log_body, LF & fill_string('*', (C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH)) & LF);
        prefix_lines(v_log_body);

        case log_destination is

          when CONSOLE_AND_LOG =>
            -- Write header to console
            tee(OUTPUT, v_header_line);
            -- Write header to file, and open/close if not default log file
            if log_file_name = C_LOG_FILE_NAME then
              writeline(LOG_FILE, v_header_line);
            else
              write_to_file(log_file_name, open_mode, v_header_line);
            end if;
            -- Write header message to specified destination
            log(msg_id, msg_header, scope, msg_id_panel, CONSOLE_AND_LOG, log_file_name, append_mode);
            -- Write log body to console
            tee(OUTPUT, v_log_body);
            -- Write log body to specified file
            if log_file_name = C_LOG_FILE_NAME then
              writeline(LOG_FILE, v_log_body);
            else
              write_to_file(log_file_name, append_mode, v_log_body);
            end if;

          when CONSOLE_ONLY =>
            -- Write to console and deallocate all lines
            writeline(OUTPUT, v_header_line);
            log(msg_id, msg_header, scope, msg_id_panel, CONSOLE_ONLY);
            writeline(OUTPUT, v_log_body);

          when LOG_ONLY =>
            -- Write to log and deallocate text_block. Open specified file if not open.
            if log_file_name = C_LOG_FILE_NAME then
              writeline(LOG_FILE, v_header_line);
              log(msg_id, msg_header, scope, msg_id_panel, LOG_ONLY);
              writeline(LOG_FILE, v_log_body);
            else
              write_to_file(log_file_name, open_mode, v_header_line);
              log(msg_id, msg_header, scope, msg_id_panel, LOG_ONLY, log_file_name, append_mode);
              write_to_file(log_file_name, append_mode, v_log_body);
            end if;
        end case;

        -- Deallocate text block to give writeline()-like behaviour
        -- for formatted output
        deallocate(v_header_line);
        deallocate(v_log_body);
        deallocate(text_block);
      end if;
    end if;
  end procedure;

  procedure enable_log_msg(
    constant msg_id       : t_msg_id;
    variable msg_id_panel : inout t_msg_id_panel;
    constant msg          : string      := "";
    constant scope        : string      := C_TB_SCOPE_DEFAULT;
    constant quietness    : t_quietness := NON_QUIET
  ) is
  begin
    case msg_id is
      when ID_NEVER =>
        null; -- Shall not be possible to enable
        tb_warning("enable_log_msg() ignored for " & to_upper(to_string(msg_id)) & " (not allowed). " & add_msg_delimiter(msg), scope);
      when ALL_MESSAGES =>
        for i in t_msg_id'left to t_msg_id'right loop
          msg_id_panel(i) := ENABLED;
        end loop;
        msg_id_panel(ID_NEVER)        := DISABLED;
        msg_id_panel(ID_BITVIS_DEBUG) := DISABLED;
        if quietness = NON_QUIET then
          log(ID_LOG_MSG_CTRL, "enable_log_msg(" & to_upper(to_string(msg_id)) & "). " & add_msg_delimiter(msg), scope);
        end if;
      when others =>
        msg_id_panel(msg_id) := ENABLED;
        if quietness = NON_QUIET then
          log(ID_LOG_MSG_CTRL, "enable_log_msg(" & to_upper(to_string(msg_id)) & "). " & add_msg_delimiter(msg), scope);
        end if;
    end case;
  end procedure;

  procedure enable_log_msg(
    msg_id    : t_msg_id;
    msg       : string;
    quietness : t_quietness := NON_QUIET;
    scope     : string      := C_TB_SCOPE_DEFAULT
  ) is
  begin
    enable_log_msg(msg_id, shared_msg_id_panel, msg, scope, quietness);
  end procedure;

  procedure enable_log_msg(
    msg_id    : t_msg_id;
    quietness : t_quietness := NON_QUIET;
    scope     : string      := C_TB_SCOPE_DEFAULT
  ) is
  begin
    enable_log_msg(msg_id, shared_msg_id_panel, "", scope, quietness);
  end procedure;

  procedure disable_log_msg(
    constant msg_id       : t_msg_id;
    variable msg_id_panel : inout t_msg_id_panel;
    constant msg          : string      := "";
    constant scope        : string      := C_TB_SCOPE_DEFAULT;
    constant quietness    : t_quietness := NON_QUIET
  ) is
  begin
    case msg_id is
      when ALL_MESSAGES =>
        if quietness = NON_QUIET then
          log(ID_LOG_MSG_CTRL, "disable_log_msg(" & to_upper(to_string(msg_id)) & "). " & add_msg_delimiter(msg), scope);
        end if;
        for i in t_msg_id'left to t_msg_id'right loop
          msg_id_panel(i) := DISABLED;
        end loop;
        msg_id_panel(ID_LOG_MSG_CTRL) := ENABLED; -- keep
      when others =>
        msg_id_panel(msg_id) := DISABLED;
        if quietness = NON_QUIET then
          log(ID_LOG_MSG_CTRL, "disable_log_msg(" & to_upper(to_string(msg_id)) & "). " & add_msg_delimiter(msg), scope);
        end if;
    end case;
  end procedure;

  procedure disable_log_msg(
    msg_id    : t_msg_id;
    msg       : string;
    quietness : t_quietness := NON_QUIET;
    scope     : string      := C_TB_SCOPE_DEFAULT
  ) is
  begin
    disable_log_msg(msg_id, shared_msg_id_panel, msg, scope, quietness);
  end procedure;

  procedure disable_log_msg(
    msg_id    : t_msg_id;
    quietness : t_quietness := NON_QUIET;
    scope     : string      := C_TB_SCOPE_DEFAULT
  ) is
  begin
    disable_log_msg(msg_id, shared_msg_id_panel, "", scope, quietness);
  end procedure;

  impure function is_log_msg_enabled(
    msg_id       : t_msg_id;
    msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) return boolean is
  begin
    if msg_id_panel(msg_id) = ENABLED then
      return true;
    else
      return false;
    end if;
  end function;

  procedure set_log_destination(
    constant log_destination : t_log_destination;
    constant quietness       : t_quietness := NON_QUIET
  ) is
  begin
    if quietness = NON_QUIET then
      log(ID_LOG_MSG_CTRL, "Changing log destination to " & to_string(log_destination) & ". Was " & to_string(shared_default_log_destination) & ". ", C_TB_SCOPE_DEFAULT);
    end if;
    shared_default_log_destination := log_destination;
  end procedure;

  -- Function for getting time unit
  function get_time_unit(
    constant value : time
  ) return time is
    variable v_time_unit : time;
  begin
    if (value >= 1 hr) then
      v_time_unit := hr;
    elsif (value >= 1 min) then
      v_time_unit := min;
    elsif (value >= 1 sec) then
      v_time_unit := sec;
    elsif (value >= 1 ms) then
      v_time_unit := ms;
    elsif (value >= 1 us) then
      v_time_unit := us;
    elsif (value >= 1 ns) then
      v_time_unit := ns;
    elsif (value >= 1 ps) then
      v_time_unit := ps;
    else
      v_time_unit := fs;
    end if;
    return v_time_unit;
  end function;

  -- ============================================================================
  -- Check counters related
  -- ============================================================================
  -- Shared variable for all the check counters
  shared variable protected_check_counters : t_protected_check_counters;

  -- ============================================================================
  -- Alert-related
  -- ============================================================================
  -- Shared variable for all the alert counters for different attention
  shared variable protected_alert_attention_counters : t_protected_alert_attention_counters;

  procedure alert(
    constant alert_level : t_alert_level;
    constant msg         : string;
    constant scope       : string := C_TB_SCOPE_DEFAULT
  ) is
    variable v_msg       : line; -- msg after pot. replacement of \n
    variable v_info      : line;
    constant C_ATTENTION : t_attention := get_alert_attention(alert_level);
  begin
    if alert_level /= NO_ALERT then
      pot_initialise_util(VOID); -- Only executed the first time called

      if C_ENABLE_HIERARCHICAL_ALERTS then
        -- Call the hierarchical alert function
        hierarchical_alert(alert_level, to_string(msg), to_string(scope), C_ATTENTION);
      else
        -- Perform the non-hierarchical alert function
        write(v_msg, replace_backslash_n_with_lf(to_string(msg)));

        -- 1. Increase relevant alert counter. Exit if ignore is set for this alert type.
        if get_alert_attention(alert_level) = IGNORE then
          --       protected_alert_counters.increment(alert_level, IGNORE);
          increment_alert_counter(alert_level, IGNORE);
          deallocate(v_msg);
        else
          --protected_alert_counters.increment(alert_level, REGARD);
          increment_alert_counter(alert_level, REGARD);

          -- 2. Write first part of alert message
          --    Serious alerts need more attention - thus more space and lines
          if (alert_level > MANUAL_CHECK) then
            write(v_info, LF & fill_string('=', C_LOG_INFO_WIDTH));
          end if;

          write(v_info, LF & "***  ");

          -- 3. Remove line feed character (LF)
          --    if single line alert enabled.
          if not C_SINGLE_LINE_ALERT then
            write(v_info, to_upper(to_string(alert_level)) & " #" & to_string(get_alert_counter(alert_level)) & "  ***" & LF & justify(to_string(now, C_LOG_TIME_BASE), right, C_LOG_TIME_WIDTH) & "   " & to_string(scope) & LF & wrap_lines(v_msg.all, C_LOG_TIME_WIDTH + 4, C_LOG_TIME_WIDTH + 4, C_LOG_INFO_WIDTH));
          else
            replace(v_msg, LF, ' ');
            write(v_info, to_upper(to_string(alert_level)) & " #" & to_string(get_alert_counter(alert_level)) & "  ***" & justify(to_string(now, C_LOG_TIME_BASE), right, C_LOG_TIME_WIDTH) & "   " & to_string(scope) & "        " & v_msg.all);
          end if;
          deallocate(v_msg);

          -- 4. Write stop message if stop-limit is reached for number of this alert
          if (get_alert_stop_limit(alert_level) /= 0) and (get_alert_counter(alert_level) >= get_alert_stop_limit(alert_level)) then
            write(v_info, LF & LF & "Simulator has been paused as requested after " & to_string(get_alert_counter(alert_level)) & " " & to_upper(to_string(alert_level)) & LF);
            if (alert_level = MANUAL_CHECK) then
              write(v_info, "Carry out above check." & LF & "Then continue simulation from within simulator." & LF);
            else
              write(v_info, string'("*** To find the root cause of this alert, " & "step out the HDL calling stack in your simulator. ***" & LF & "*** For example, step out until you reach the call from the test sequencer. ***"));
            end if;
          end if;

          -- 5. Write last part of alert message
          if (alert_level > MANUAL_CHECK) then
            write(v_info, LF & fill_string('=', C_LOG_INFO_WIDTH) & LF & LF);
          else
            write(v_info, LF);
          end if;

          prefix_lines(v_info);
          tee(OUTPUT, v_info);
          tee(ALERT_FILE, v_info);
          writeline(LOG_FILE, v_info);
          deallocate(v_info);

          -- 6. Stop simulation if stop-limit is reached for number of this alert
          if (get_alert_stop_limit(alert_level) /= 0) then
            if (get_alert_counter(alert_level) >= get_alert_stop_limit(alert_level)) then
              if C_USE_STD_STOP_ON_ALERT_STOP_LIMIT then
                std.env.stop(1);
              else
                assert false report "This single Failure line has been provoked to stop the simulation. See alert-message above" severity failure;
              end if;
            end if;
          end if;
        end if;
      end if;

    end if;
  end procedure;

  -- Dedicated alert-procedures all alert levels (less verbose - as 2 rather than 3 parameters...)
  procedure note(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(note, msg, scope);
  end procedure;

  procedure tb_note(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(tb_note, msg, scope);
  end procedure;

  procedure warning(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(warning, msg, scope);
  end procedure;

  procedure tb_warning(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(tb_warning, msg, scope);
  end procedure;

  procedure manual_check(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(manual_check, msg, scope);
  end procedure;

  procedure error(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(error, msg, scope);
  end procedure;

  procedure tb_error(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(tb_error, msg, scope);
  end procedure;

  procedure failure(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(failure, msg, scope);
  end procedure;

  procedure tb_failure(
    constant msg   : string;
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    alert(tb_failure, msg, scope);
  end procedure;

  procedure increment_expected_alerts(
    constant alert_level : t_alert_level;
    constant number      : natural := 1;
    constant msg         : string  := "";
    constant scope       : string  := C_TB_SCOPE_DEFAULT
  ) is
  begin
    if alert_level = NO_ALERT then
      alert(TB_WARNING, "increment_expected_alerts not allowed for alert_level NO_ALERT. " & add_msg_delimiter(msg), scope);
    else
      if not C_ENABLE_HIERARCHICAL_ALERTS then
        increment_alert_counter(alert_level, EXPECT, number);
        log(ID_UTIL_SETUP, "incremented expected " & to_upper(to_string(alert_level)) & "s by " & to_string(number) & ". " & add_msg_delimiter(msg), scope);
      else
        increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, alert_level, number);
      end if;
    end if;
  end procedure;

  -- Arguments:
  -- - order = FINAL : print out Simulation Success/Fail
  procedure report_alert_counters(
    constant order : in t_order
  ) is
  begin
    pot_initialise_util(VOID); -- Only executed the first time called
    if not C_ENABLE_HIERARCHICAL_ALERTS then
      protected_alert_attention_counters.to_string(order);
    else
      print_hierarchical_log(order);
    end if;

  end procedure;

  -- This version (with the t_void argument) is kept for backwards compatibility
  procedure report_alert_counters(
    constant dummy : in t_void
  ) is
  begin
    report_alert_counters(FINAL); -- Default when calling this old method is order=FINAL
  end procedure;

  procedure report_global_ctrl(
    constant dummy : in t_void
  ) is
    constant C_PREFIX : string := C_LOG_PREFIX & "     ";
    variable v_line   : line;
  begin
    pot_initialise_util(VOID); -- Only executed the first time called
    write(v_line,
    LF &
    fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
    "***  REPORT OF GLOBAL CTRL ***" & LF &
    fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
    "                          IGNORE    STOP_LIMIT" & LF);
    for i in note to t_alert_level'right loop
      write(v_line, "          " & to_upper(to_string(i, 13, left)) & ": "); -- Severity

      write(v_line, to_string(get_alert_attention(i), 7, right) & "    "); -- column 1
      write(v_line, to_string(integer'(get_alert_stop_limit(i)), 6, right, KEEP_LEADING_SPACE) & LF); -- column 2
    end loop;
    write(v_line, fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

    wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
    prefix_lines(v_line, C_PREFIX);

    -- Write the info string to the target file
    tee(OUTPUT, v_line);
    writeline(LOG_FILE, v_line);
    deallocate(v_line);
  end procedure;

  procedure report_msg_id_panel(
    constant dummy : in t_void
  ) is
    constant C_PREFIX : string := C_LOG_PREFIX & "     ";
    variable v_line   : line;
  begin
    pot_initialise_util(VOID); -- Only executed the first time called
    write(v_line,
    LF &
    fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
    "***  REPORT OF MSG ID PANEL ***" & LF &
    fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
    "          " & justify("ID", left, C_LOG_MSG_ID_WIDTH) & "       Status" & LF &
    "          " & fill_string('-', C_LOG_MSG_ID_WIDTH) & " ------" & LF);
    for i in t_msg_id'left to t_msg_id'right loop
      if ((i /= ALL_MESSAGES) and ((i /= NO_ID) and (i /= ID_NEVER))) then -- report all but ID_NEVER, NO_ID and ALL_MESSAGES
        write(v_line, "          " & to_upper(to_string(i, C_LOG_MSG_ID_WIDTH + 5, left)) & ": "); -- MSG_ID
        write(v_line, to_upper(to_string(shared_msg_id_panel(i))) & LF); -- Enabled/disabled
      end if;
    end loop;
    write(v_line, fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

    wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
    prefix_lines(v_line, C_PREFIX);

    -- Write the info string to the target file
    tee(OUTPUT, v_line);
    writeline(LOG_FILE, v_line);
    deallocate(v_line);
  end procedure;

  procedure set_alert_attention(
    alert_level : t_alert_level;
    attention   : t_attention;
    msg         : string := ""
  ) is
  begin
    if alert_level = NO_ALERT then
      tb_warning("set_alert_attention not allowed for alert_level NO_ALERT (always IGNORE).");
    else
      check_value(attention = IGNORE or attention = REGARD, TB_ERROR,
      "set_alert_attention only supported for IGNORE and REGARD", C_BURIED_SCOPE, ID_NEVER);
      shared_alert_attention(alert_level) := attention;
      log(ID_ALERT_CTRL, "set_alert_attention(" & to_upper(to_string(alert_level)) & ", " & to_string(attention) & "). " & add_msg_delimiter(msg));
    end if;
  end procedure;

  impure function get_alert_attention(
    alert_level : t_alert_level
  ) return t_attention is
  begin
    if alert_level = NO_ALERT then
      return IGNORE;
    else
      return shared_alert_attention(alert_level);
    end if;
  end function;

  procedure set_alert_stop_limit(
    alert_level : t_alert_level;
    value       : natural
  ) is
  begin
    if alert_level = NO_ALERT then
      tb_warning("set_alert_stop_limit not allowed for alert_level NO_ALERT (stop limit always 0).");
    else
      if not C_ENABLE_HIERARCHICAL_ALERTS then
        shared_stop_limit(alert_level) := value;

        -- Evaluate new stop limit in case it is less than or equal to the current alert counter for this alert level
        -- If that is the case, a new alert with the same alert level shall be triggered.
        if (get_alert_stop_limit(alert_level) /= 0) and (get_alert_counter(alert_level) >= get_alert_stop_limit(alert_level)) then
          alert(alert_level, "Alert stop limit for " & to_upper(to_string(alert_level)) & " set to " & to_string(value) & ", which is lower than the current " & to_upper(to_string(alert_level)) & " count (" & to_string(get_alert_counter(alert_level)) & ").");
        end if;
      else
        -- If hierarchical alerts enabled, update top level
        -- alert stop limit.
        set_hierarchical_alert_top_level_stop_limit(alert_level, value);
      end if;
    end if;
  end procedure;

  impure function get_alert_stop_limit(
    alert_level : t_alert_level
  ) return natural is
  begin
    if alert_level = NO_ALERT then
      return 0;
    else
      if not C_ENABLE_HIERARCHICAL_ALERTS then
        return shared_stop_limit(alert_level);
      else
        return get_hierarchical_alert_top_level_stop_limit(alert_level);
      end if;
    end if;
  end function;

  impure function get_alert_counter(
    alert_level : t_alert_level;
    attention   : t_attention := REGARD
  ) return natural is
  begin
    if alert_level = NO_ALERT then
      return 0;
    else
      return protected_alert_attention_counters.get(alert_level, attention);
    end if;
  end function;

  procedure increment_alert_counter(
    alert_level : t_alert_level;
    attention   : t_attention := REGARD; -- regard, expect, ignore
    number      : natural     := 1
  ) is
    type alert_array is array (1 to 6) of t_alert_level;
    constant C_ALERT_CHECK_ARRAY : alert_array := (warning, TB_WARNING, error, TB_ERROR, failure, TB_FAILURE);
    alias found_unexpected_simulation_warnings_or_worse is shared_uvvm_status.found_unexpected_simulation_warnings_or_worse;
    alias found_unexpected_simulation_errors_or_worse is shared_uvvm_status.found_unexpected_simulation_errors_or_worse;
    alias mismatch_on_expected_simulation_warnings_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_warnings_or_worse;
    alias mismatch_on_expected_simulation_errors_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_errors_or_worse;
  begin
    protected_alert_attention_counters.increment(alert_level, attention, number);

    -- Update simulation status
    if (attention = REGARD) or (attention = EXPECT) then
      if (alert_level /= NO_ALERT) and (alert_level /= note) and (alert_level /= TB_NOTE) and (alert_level /= MANUAL_CHECK) then
        found_unexpected_simulation_warnings_or_worse     := 0; -- default
        found_unexpected_simulation_errors_or_worse       := 0; -- default
        mismatch_on_expected_simulation_warnings_or_worse := 0; -- default
        mismatch_on_expected_simulation_errors_or_worse   := 0; -- default

        -- Compare expected and current allerts
        for i in 1 to C_ALERT_CHECK_ARRAY'high loop
          if (get_alert_counter(C_ALERT_CHECK_ARRAY(i), REGARD) /= get_alert_counter(C_ALERT_CHECK_ARRAY(i), EXPECT)) then

            -- MISMATCH
            -- warning or worse
            mismatch_on_expected_simulation_warnings_or_worse := 1;
            -- error or worse
            if not (C_ALERT_CHECK_ARRAY(i) = warning) and not (C_ALERT_CHECK_ARRAY(i) = TB_WARNING) then
              mismatch_on_expected_simulation_errors_or_worse := 1;
            end if;

            -- FOUND UNEXPECTED ALERT
            if (get_alert_counter(C_ALERT_CHECK_ARRAY(i), REGARD) > get_alert_counter(C_ALERT_CHECK_ARRAY(i), EXPECT)) then
              -- warning and worse
              found_unexpected_simulation_warnings_or_worse := 1;
              -- error and worse
              if not (C_ALERT_CHECK_ARRAY(i) = warning) and not (C_ALERT_CHECK_ARRAY(i) = TB_WARNING) then
                found_unexpected_simulation_errors_or_worse := 1;
              end if;
            end if;

          end if;
        end loop;

      end if;
    end if;
  end procedure;

  procedure increment_expected_alerts_and_stop_limit(
    constant alert_level : t_alert_level;
    constant number      : natural := 1;
    constant msg         : string  := "";
    constant scope       : string  := C_TB_SCOPE_DEFAULT
  ) is
    variable v_alert_stop_limit : natural := get_alert_stop_limit(alert_level);
  begin
    increment_expected_alerts(alert_level, number, msg, scope);
    set_alert_stop_limit(alert_level, v_alert_stop_limit + number);
  end procedure;

  procedure report_check_counters(
    constant order : in t_order
  ) is
  begin
    protected_check_counters.to_string(order);
  end procedure;

  procedure report_check_counters(
    constant dummy : in t_void
  ) is
  begin
    report_check_counters(FINAL);
  end procedure;

  -- Lists all the scoreboards and whether they are enabled or not
  procedure report_scoreboards(
    constant void : in t_void
  ) is
    constant C_PREFIX : string := C_LOG_PREFIX & "     ";
    variable v_line   : line;
  begin
    -- Print report header
    write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
    write(v_line, timestamp_header(now, justify("*** SUMMARY OF SCOREBOARDS***", LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF);
    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

    -- Print scoreboards
    if protected_sb_activity_register.get_num_registered_sb(void) = 0 then
      write(v_line, "     " & "No UVVM scoreboards to report." & LF);
    else
      for idx in 0 to protected_sb_activity_register.get_num_registered_sb(void) - 1 loop
        write(v_line, "     " & to_string(protected_sb_activity_register.get_sb_name(idx)) & "," & to_string(protected_sb_activity_register.get_sb_instance(idx)) &
        "," & return_string1_if_true_otherwise_string2("ENABLED", "DISABLED", protected_sb_activity_register.is_enabled(idx)) & LF);
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

  -- ============================================================================
  -- Deprecation message
  -- ============================================================================
  procedure deprecate(
    caller_name  : string;
    constant msg : string := ""
  ) is
    variable v_found : boolean;
  begin
    v_found := false;
    if C_DEPRECATE_SETTING /= NO_DEPRECATE then -- only perform if deprecation enabled
      l_find_caller_name_in_list : for i in deprecated_subprogram_list'range loop
        if deprecated_subprogram_list(i) = justify(caller_name, right, 100) then
          v_found := true;
          exit l_find_caller_name_in_list;
        end if;
      end loop;

      if v_found then
        -- Has already been printed.
        if C_DEPRECATE_SETTING = ALWAYS_DEPRECATE then
          log(ID_UTIL_SETUP, "Sub-program " & caller_name & " is outdated and has been replaced by another sub-program." & LF & msg);
        else -- C_DEPRECATE_SETTING = DEPRECATE_ONCE
          null;
        end if;
      else
        -- Has not been printed yet.
        l_insert_caller_name_in_first_available : for i in deprecated_subprogram_list'range loop
          if deprecated_subprogram_list(i) = justify("", right, 100) then
            deprecated_subprogram_list(i) := justify(caller_name, right, 100);
            exit l_insert_caller_name_in_first_available;
          end if;
        end loop;

        log(ID_UTIL_SETUP, "Sub-program " & caller_name & " is outdated and has been replaced by another sub-program." & LF & msg);
      end if;
    end if;
  end procedure;

  -- ============================================================================
  -- Non time consuming checks
  -- ============================================================================
  -- NOTE: Index in range N downto 0, with -1 meaning not found
  function idx_leftmost_p1_in_p2(
    target : std_logic;
    vector : std_logic_vector
  ) return integer is
    alias a_vector                 : std_logic_vector(vector'length - 1 downto 0) is vector;
    constant C_RESULT_IF_NOT_FOUND : integer := - 1; -- To indicate not found
  begin
    bitvis_assert(vector'length > 0, error, "idx_leftmost_p1_in_p2()", "String input is empty");
    for i in a_vector'left downto a_vector'right loop
      if (a_vector(i) = target) then
        return i;
      end if;
    end loop;
    return C_RESULT_IF_NOT_FOUND;
  end function;

  -- Matching if same width or only zeros in "extended width"
  function matching_widths(
    value1 : std_logic_vector;
    value2 : std_logic_vector
  ) return boolean is
    -- Normalize vectors to (N downto 0)
    alias a_value1 : std_logic_vector(value1'length - 1 downto 0) is value1;
    alias a_value2 : std_logic_vector(value2'length - 1 downto 0) is value2;

  begin
    if (a_value1'left >= maximum(idx_leftmost_p1_in_p2('1', a_value2), 0) and a_value1'left >= maximum(idx_leftmost_p1_in_p2('H', a_value2), 0) and a_value1'left >= maximum(idx_leftmost_p1_in_p2('Z', a_value2), 0)) and (a_value2'left >= maximum(idx_leftmost_p1_in_p2('1', a_value1), 0) and a_value2'left >= maximum(idx_leftmost_p1_in_p2('H', a_value1), 0) and a_value2'left >= maximum(idx_leftmost_p1_in_p2('Z', a_value1), 0)) then
      return true;
    else
      return false;
    end if;
  end function;

  function matching_widths(
    value1 : unsigned;
    value2 : unsigned
  ) return boolean is
  begin
    return matching_widths(std_logic_vector(value1), std_logic_vector(value2));
  end function;

  function matching_widths(
    value1 : signed;
    value2 : signed
  ) return boolean is
  begin
    return matching_widths(std_logic_vector(value1), std_logic_vector(value2));
  end function;

  -- Compare values, but ignore any leading zero's at higher indexes than v_min_length-1.
  function matching_values(
    constant value1           : in std_logic_vector;
    constant value2           : in std_logic_vector;
    constant match_strictness : in t_match_strictness := MATCH_STD
  ) return boolean is
    -- Normalize vectors to (N downto 0)
    alias a_value1        : std_logic_vector(value1'length - 1 downto 0) is value1;
    alias a_value2        : std_logic_vector(value2'length - 1 downto 0) is value2;
    variable v_min_length : natural := minimum(a_value1'length, a_value2'length);
    variable v_match      : boolean := true; -- as default prior to checking
  begin
    if matching_widths(a_value1, a_value2) then

      case match_strictness is

        when MATCH_STD =>
          if not std_match(a_value1(v_min_length - 1 downto 0), a_value2(v_min_length - 1 downto 0)) then
            v_match := false;
          end if;

        when MATCH_STD_INCL_Z =>
          for i in v_min_length - 1 downto 0 loop
            if not (std_match(a_value1(i), a_value2(i)) or
              (a_value1(i) = 'Z' and a_value2(i) = 'Z') or
              (a_value1(i) = '-' or a_value2(i) = '-')) then
              v_match := false;
              exit;
            end if;
          end loop;

        when MATCH_STD_INCL_ZXUW =>
          for i in v_min_length - 1 downto 0 loop
            if not (std_match(a_value1(i), a_value2(i)) or
              (a_value1(i) = 'Z' and a_value2(i) = 'Z') or
              (a_value1(i) = 'X' and a_value2(i) = 'X') or
              (a_value1(i) = 'U' and a_value2(i) = 'U') or
              (a_value1(i) = 'W' and a_value2(i) = 'W') or
              (a_value1(i) = '-' or a_value2(i) = '-')) then
              v_match := false;
              exit;
            end if;
          end loop;

        when others =>
          if a_value1(v_min_length - 1 downto 0) /= a_value2(v_min_length - 1 downto 0) then
            v_match := false;
          end if;

      end case;

    else
      v_match := false;
    end if;
    return v_match;
  end function;

  function matching_values(
    value1 : unsigned;
    value2 : unsigned
  ) return boolean is
  begin
    return matching_values(std_logic_vector(value1), std_logic_vector(value2));
  end function;

  function matching_values(
    value1 : signed;
    value2 : signed
  ) return boolean is
  begin
    return matching_values(std_logic_vector(value1), std_logic_vector(value2));
  end function;

  -- Function check_value,
  -- returning 'true' if OK
  impure function check_value(
    constant value        : boolean;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
  begin
    protected_check_counters.increment(CHECK_VALUE);

    if value then
      log(msg_id, caller_name & " => OK, for boolean true. " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, caller_name & " => Failed. Boolean was false. " & add_msg_delimiter(msg), scope);
    end if;
    return value;
  end function;

  impure function check_value(
    constant value        : boolean;
    constant exp          : boolean;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    constant C_VALUE_STR : string := to_string(value);
    constant C_EXP_STR   : string := to_string(exp);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    if value = exp then
      log(msg_id, caller_name & " => OK, for boolean " & C_VALUE_STR & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. Boolean was " & C_VALUE_STR & ". Expected " & C_EXP_STR & ". " & LF & msg, scope);
      return false;
    end if;
  end function;

  impure function check_value(
    constant value            : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()"
  ) return boolean is
    constant C_VALUE_TYPE : string  := "std_logic";
    constant C_VALUE_STR  : string  := to_string(value);
    constant C_EXP_STR    : string  := to_string(exp);
    variable v_failed     : boolean := false;
  begin
    protected_check_counters.increment(CHECK_VALUE);

    case match_strictness is

      when MATCH_STD =>
        if std_match(value, exp) then
          log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " '" & C_VALUE_STR & "' (exp: '" & C_EXP_STR & "'). " & add_msg_delimiter(msg), scope, msg_id_panel);
        else
          v_failed := true;
        end if;

      when MATCH_STD_INCL_Z =>
        if (value = 'Z' and exp = 'Z') or std_match(value, exp) then
          log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " '" & C_VALUE_STR & "' (exp: '" & C_EXP_STR & "'). " & add_msg_delimiter(msg), scope, msg_id_panel);
        else
          v_failed := true;
        end if;

      when MATCH_STD_INCL_ZXUW =>
        if (value = 'Z' and exp = 'Z') or (value = 'X' and exp = 'X') or (value = 'U' and exp = 'U') or (value = 'W' and exp = 'W') or std_match(value, exp) then
          log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " '" & C_VALUE_STR & "' (exp: '" & C_EXP_STR & "'). " & add_msg_delimiter(msg), scope, msg_id_panel);
        else
          v_failed := true;
        end if;

      when others =>
        if value = exp then
          log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " '" & C_VALUE_STR & "'. " & add_msg_delimiter(msg), scope, msg_id_panel);
        else
          v_failed := true;
        end if;

    end case;

    if v_failed = true then
      alert(alert_level, caller_name & " => Failed. " & C_VALUE_TYPE & "  Was '" & C_VALUE_STR & "'. Expected '" & C_EXP_STR & "'" & LF & msg, scope);
      return false;
    else
      return true;
    end if;
  end function;

  impure function check_value(
    constant value        : std_logic;
    constant exp          : std_logic;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
  begin
    return check_value(value, exp, MATCH_STD, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end function;

  impure function check_value(
    constant value            : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "slv"
  ) return boolean is
    -- Normalise vectors to (N downto 0)

    alias a_value            : std_logic_vector(value'length - 1 downto 0) is value;
    alias a_exp              : std_logic_vector(exp'length - 1 downto 0) is exp;
    variable v_check_ok      : boolean := true; -- as default prior to checking
    variable v_trigger_alert : boolean := false; -- trigger alert and log message

    -- Match length of short string with long string
    function pad_short_string(short, long : string) return string is
      constant C_SHORT_NORMALISED : string(1 to short'length) := short;
      variable v_padding          : string(1 to (long'length - short'length)) := (others => '0');
    begin
      -- Include leading 'x"'
      return C_SHORT_NORMALISED(1 to 2) & v_padding & C_SHORT_NORMALISED(3 to short'length);
    end function;

    -- Function to represent signed value as string if value_type is "signed"
    function signed_string_check(
      constant slv_value  : std_logic_vector;
      constant radix      : t_radix;
      constant format     : t_format_zeros;
      constant value_type : string
    ) return string is
    begin
      if value_type = "signed" then
        return to_string(signed(slv_value), radix, format, INCL_RADIX);
      else
        return to_string(slv_value, radix, format, INCL_RADIX);
      end if;
    end function signed_string_check;

    constant C_VALUE_STR : string := signed_string_check(a_value, radix, format, value_type);
    constant C_EXP_STR   : string := signed_string_check(a_exp, radix, format, value_type);

  begin
    protected_check_counters.increment(CHECK_VALUE);

    -- AS_IS format has been deprecated and will be removed in the near future
    if format = AS_IS then
      deprecate(get_procedure_name_from_instance_name(value'instance_name), "format 'AS_IS' has been deprecated. Use KEEP_LEADING_0.");
    end if;

    v_check_ok := matching_values(a_value, a_exp, match_strictness);

    if v_check_ok then
      if C_VALUE_STR = C_EXP_STR then
        log(msg_id, caller_name & " => OK, for " & value_type & " " & C_VALUE_STR & "'. " & add_msg_delimiter(msg), scope, msg_id_panel);
      else
        -- H,L or - is present in C_EXP_STR
        if match_strictness = MATCH_STD then
          log(msg_id, caller_name & " => OK, for " & value_type & " " & C_VALUE_STR & "' (exp: " & C_EXP_STR & "'). " & add_msg_delimiter(msg),
          scope, msg_id_panel);
        else
          v_trigger_alert := true; -- alert and log
        end if;
      end if;
    else
      v_trigger_alert := true; -- alert and log
    end if;
    -- trigger alert and log message
    if v_trigger_alert then
      if C_VALUE_STR'length > C_EXP_STR'length then
        if radix = HEX_BIN_IF_INVALID then
          alert(alert_level, caller_name & " => Failed. " & value_type & "  Was " & C_VALUE_STR & ". Expected " & C_EXP_STR & "." & LF & msg, scope);
        else
          alert(alert_level, caller_name & " => Failed. " & value_type & "  Was " & C_VALUE_STR & ". Expected " & pad_short_string(C_EXP_STR, C_VALUE_STR) & "." & LF & msg, scope);
        end if;
      elsif C_VALUE_STR'length < C_EXP_STR'length then
        if radix = HEX_BIN_IF_INVALID then
          alert(alert_level, caller_name & " => Failed. " & value_type & "  Was " & C_VALUE_STR & ". Expected " & C_EXP_STR & "." & LF & msg, scope);
        else
          alert(alert_level, caller_name & " => Failed. " & value_type & "  Was " & pad_short_string(C_VALUE_STR, C_EXP_STR) & ". Expected " & C_EXP_STR & "." & LF & msg, scope);
        end if;
      else
        alert(alert_level, caller_name & " => Failed. " & value_type & "  Was " & C_VALUE_STR & ". Expected " & C_EXP_STR & "." & LF & msg, scope);
      end if;
    end if;

    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : std_logic_vector;
    constant exp          : std_logic_vector;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "slv"
  ) return boolean is
    -- Normalise vectors to (N downto 0)
    alias a_value       : std_logic_vector(value'length - 1 downto 0) is value;
    alias a_exp         : std_logic_vector(exp'length - 1 downto 0) is exp;
    variable v_check_ok : boolean := true; -- as default prior to checking
  begin
    return check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end function;

  impure function check_value(
    constant value            : unsigned;
    constant exp              : unsigned;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "unsigned"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(std_logic_vector(value), std_logic_vector(exp), match_strictness, alert_level, msg, scope,
      radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : unsigned;
    constant exp          : unsigned;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "unsigned"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(std_logic_vector(value), std_logic_vector(exp), MATCH_STD, alert_level, msg, scope,
      radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : signed;
    constant exp              : signed;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "signed"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(std_logic_vector(value), std_logic_vector(exp), match_strictness, alert_level, msg, scope,
      radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : signed;
    constant exp          : signed;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "signed"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(std_logic_vector(value), std_logic_vector(exp), MATCH_STD, alert_level, msg, scope,
      radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : integer;
    constant exp          : integer;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    constant C_VALUE_TYPE : string := "int";
    constant C_VALUE_STR  : string := to_string(value);
    constant C_EXP_STR    : string := to_string(exp);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    if value = exp then
      log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " " & C_VALUE_STR & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. " & C_VALUE_TYPE & "  Was " & C_VALUE_STR & ". Expected " & C_EXP_STR & LF & msg, scope);
      return false;
    end if;
  end function;

  impure function check_value(
    constant value        : real;
    constant exp          : real;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    constant C_VALUE_TYPE : string := "real";
    constant C_VALUE_STR  : string := to_string(value);
    constant C_EXP_STR    : string := to_string(exp);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    if value = exp then
      log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " " & C_VALUE_STR & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. " & C_VALUE_TYPE & "  Was " & C_VALUE_STR & ". Expected " & C_EXP_STR & LF & msg, scope);
      return false;
    end if;
  end function;

  impure function check_value(
    constant value        : time;
    constant exp          : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    constant C_VALUE_TYPE : string := "time";
    variable v_value_line : line;
    variable v_exp_line   : line;
    variable v_time_unit  : time;
    variable v_return_val : boolean;
  begin
    protected_check_counters.increment(CHECK_VALUE);

    v_time_unit := get_time_unit(exp);
    write(v_value_line, value, right, 0, v_time_unit);
    write(v_exp_line, exp, right, 0, v_time_unit);

    if value = exp then
      log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " " & v_value_line.all & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      v_return_val := true;
    else
      alert(alert_level, caller_name & " => Failed. " & C_VALUE_TYPE & "  Was " & v_value_line.all & ". Expected " & v_exp_line.all & LF & msg, scope);
      v_return_val := false;
    end if;
    DEALLOCATE(v_value_line);
    DEALLOCATE(v_exp_line);
    return v_return_val;
  end function;

  impure function check_value(
    constant value        : string;
    constant exp          : string;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    constant C_VALUE_TYPE : string := "string";
  begin
    protected_check_counters.increment(CHECK_VALUE);

    if value = exp then
      log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " '" & value & "'. " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. " & C_VALUE_TYPE & "  Was '" & value & "'. Expected '" & exp & "'" & LF & msg, scope);
      return false;
    end if;
  end function;

  impure function check_value(
    constant value            : t_slv_array;
    constant exp              : t_slv_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_slv_array"
  ) return boolean is
    variable v_len_check_ok : boolean := (value'length = exp'length);
    variable v_dir_check_ok : boolean := (value'ascending = exp'ascending);
    -- adjust for array index differences
    variable v_adj_idx : integer := (value'low - exp'low);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    check_value(v_dir_check_ok = true, TB_WARNING, "array directions do not match", scope, ID_NEVER, msg_id_panel);
    check_value(v_len_check_ok = true, TB_ERROR, "array lengths do not match", scope, ID_NEVER, msg_id_panel);

    if v_len_check_ok and v_dir_check_ok then
      for idx in exp'range loop
        -- do not count CHECK_VALUE multiple times
        protected_check_counters.decrement(CHECK_VALUE);
        if not (check_value(value(idx + v_adj_idx), exp(idx), match_strictness, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type)) then
          return false;
        end if;
      end loop;
    else -- lenght or direction check not ok 
      return false;
    end if;

    return true;
  end function;

  impure function check_value(
    constant value        : t_slv_array;
    constant exp          : t_slv_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_slv_array"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : t_signed_array;
    constant exp              : t_signed_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_signed_array"
  ) return boolean is
    variable v_len_check_ok : boolean := (value'length = exp'length);
    variable v_dir_check_ok : boolean := (value'ascending = exp'ascending);
    -- adjust for array index differences
    variable v_adj_idx : integer := (value'low - exp'low);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    check_value(v_dir_check_ok = true, TB_WARNING, "array directions do not match", scope, ID_NEVER, msg_id_panel);
    check_value(v_len_check_ok = true, TB_ERROR, "array lengths do not match", scope, ID_NEVER, msg_id_panel);

    if v_len_check_ok and v_dir_check_ok then
      for idx in exp'range loop
        -- do not count CHECK_VALUE multiple times
        protected_check_counters.decrement(CHECK_VALUE);
        if not (check_value(std_logic_vector(value(idx + v_adj_idx)), std_logic_vector(exp(idx)), alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type)) then
          return false;
        end if;
      end loop;
    else -- length or direction check not ok
      return false;
    end if;

    return true;
  end function;

  impure function check_value(
    constant value        : t_signed_array;
    constant exp          : t_signed_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_signed_array"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : t_unsigned_array;
    constant exp              : t_unsigned_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_unsigned_array"
  ) return boolean is
    variable v_len_check_ok : boolean := (value'length = exp'length);
    variable v_dir_check_ok : boolean := (value'ascending = exp'ascending);
    -- adjust for array index differences
    variable v_adj_idx : integer := (value'low - exp'low);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    check_value(v_dir_check_ok = true, TB_WARNING, "array directions do not match", scope, ID_NEVER, msg_id_panel);
    check_value(v_len_check_ok = true, TB_ERROR, "array lengths do not match", scope, ID_NEVER, msg_id_panel);

    for idx in exp'range loop
      -- do not count CHECK_VALUE multiple times
      protected_check_counters.decrement(CHECK_VALUE);
      if not (check_value(std_logic_vector(value(idx + v_adj_idx)), std_logic_vector(exp(idx)), alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type)) then
        return false;
      end if;
    end loop;
    return true;
  end function;

  impure function check_value(
    constant value        : t_unsigned_array;
    constant exp          : t_unsigned_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_unsigned_array"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  ----------------------------------------------------------------------
  -- Overloads for impure function check_value methods,
  -- to allow optional alert_level
  ----------------------------------------------------------------------
  impure function check_value(
    constant value        : boolean;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : boolean;
    constant exp          : boolean;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking
  begin
    v_check_ok := check_value(value, exp, match_strictness, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : std_logic;
    constant exp          : std_logic;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "slv"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking
  begin
    v_check_ok := check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : std_logic_vector;
    constant exp          : std_logic_vector;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "slv"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : unsigned;
    constant exp              : unsigned;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "unsigned"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(std_logic_vector(value), std_logic_vector(exp), match_strictness, error, msg, scope,
      radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : unsigned;
    constant exp          : unsigned;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "unsigned"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(std_logic_vector(value), std_logic_vector(exp), MATCH_STD, error, msg, scope,
      radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : signed;
    constant exp              : signed;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "signed"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking
  begin
    v_check_ok := check_value(std_logic_vector(value), std_logic_vector(exp), match_strictness, error, msg, scope,
      radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : signed;
    constant exp          : signed;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "signed"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking
  begin
    v_check_ok := check_value(std_logic_vector(value), std_logic_vector(exp), MATCH_STD, error, msg, scope,
      radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : integer;
    constant exp          : integer;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking
  begin
    v_check_ok := check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : real;
    constant exp          : real;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking     
  begin
    v_check_ok := check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : time;
    constant exp          : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking     
  begin
    v_check_ok := check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : string;
    constant exp          : string;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking     
  begin
    v_check_ok := check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : t_slv_array;
    constant exp              : t_slv_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_slv_array"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking      
  begin
    v_check_ok := check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : t_slv_array;
    constant exp          : t_slv_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_slv_array"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking      
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : t_signed_array;
    constant exp              : t_signed_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_signed_array"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking      
  begin
    v_check_ok := check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : t_signed_array;
    constant exp          : t_signed_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_signed_array"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking      
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value            : t_unsigned_array;
    constant exp              : t_unsigned_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_unsigned_array"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking      
  begin
    v_check_ok := check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value(
    constant value        : t_unsigned_array;
    constant exp          : t_unsigned_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_unsigned_array"
  ) return boolean is
    variable v_check_ok : boolean := true; -- as default prior to checking      
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  ----------------------------------------------------------------------
  -- Overloads for procedural check_value methods,
  -- to allow for no return value
  ----------------------------------------------------------------------
  procedure check_value(
    constant value        : boolean;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : boolean;
    constant exp          : boolean;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value            : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, match_strictness, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : std_logic;
    constant exp          : std_logic;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value            : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "slv"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, match_strictness, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : std_logic_vector;
    constant exp          : std_logic_vector;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "slv"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value            : unsigned;
    constant exp              : unsigned;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "unsigned"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, match_strictness, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : unsigned;
    constant exp          : unsigned;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "unsigned"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value            : signed;
    constant exp              : signed;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "signed"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, match_strictness, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : signed;
    constant exp          : signed;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "signed"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : integer;
    constant exp          : integer;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : real;
    constant exp          : real;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : time;
    constant exp          : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : string;
    constant exp          : string;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value            : t_slv_array;
    constant exp              : t_slv_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_slv_array"
  ) is
    variable v_check_ok     : boolean;
    variable v_len_check_ok : boolean := (value'length = exp'length);
    variable v_dir_check_ok : boolean := (value'ascending = exp'ascending);
    -- adjust for array index differences
    variable v_adj_idx : integer := (value'low - exp'low);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    check_value(v_dir_check_ok = true, TB_WARNING, "array directions do not match", scope, ID_NEVER, msg_id_panel);
    check_value(v_len_check_ok = true, TB_ERROR, "array lengths do not match", scope, ID_NEVER, msg_id_panel);
    -- do not count called CHECK_VALUE
    protected_check_counters.decrement(CHECK_VALUE, 2);

    if v_len_check_ok and v_dir_check_ok then
      for idx in exp'range loop
        v_check_ok := check_value(value(idx + v_adj_idx), exp(idx), match_strictness, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
        -- do not count called CHECK_VALUE
        protected_check_counters.decrement(CHECK_VALUE);
      end loop;
    end if;
  end procedure;

  procedure check_value(
    constant value        : t_slv_array;
    constant exp          : t_slv_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_slv_array"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value            : t_signed_array;
    constant exp              : t_signed_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_signed_array"
  ) is
    variable v_check_ok     : boolean;
    variable v_len_check_ok : boolean := (value'length = exp'length);
    variable v_dir_check_ok : boolean := (value'ascending = exp'ascending);
    -- adjust for array index differences
    variable v_adj_idx : integer := (value'low - exp'low);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    check_value(v_dir_check_ok = true, warning, "array directions do not match", scope, ID_NEVER, msg_id_panel);
    check_value(v_len_check_ok = true, warning, "array lengths do not match", scope, ID_NEVER, msg_id_panel);
    -- do not count called CHECK_VALUE
    protected_check_counters.decrement(CHECK_VALUE, 2);

    if v_len_check_ok and v_dir_check_ok then
      for idx in exp'range loop
        v_check_ok := check_value(std_logic_vector(value(idx + v_adj_idx)), std_logic_vector(exp(idx)), match_strictness, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
        -- do not count called CHECK_VALUE
        protected_check_counters.decrement(CHECK_VALUE);
      end loop;
    end if;
  end procedure;

  procedure check_value(
    constant value        : t_signed_array;
    constant exp          : t_signed_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_signed_array"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value            : t_unsigned_array;
    constant exp              : t_unsigned_array;
    constant match_strictness : t_match_strictness;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_unsigned_array"
  ) is
    variable v_check_ok     : boolean;
    variable v_len_check_ok : boolean := (value'length = exp'length);
    variable v_dir_check_ok : boolean := (value'ascending = exp'ascending);
    -- adjust for array index differences
    variable v_adj_idx : integer := (value'low - exp'low);
  begin
    protected_check_counters.increment(CHECK_VALUE);

    check_value(v_dir_check_ok = true, warning, "array directions do not match", scope, ID_NEVER, msg_id_panel);
    check_value(v_len_check_ok = true, warning, "array lengths do not match", scope, ID_NEVER, msg_id_panel);
    -- do not count called CHECK_VALUE
    protected_check_counters.decrement(CHECK_VALUE, 2);

    if v_len_check_ok and v_dir_check_ok then
      for idx in exp'range loop
        v_check_ok := check_value(std_logic_vector(value(idx + v_adj_idx)), std_logic_vector(exp(idx)), match_strictness, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
        -- do not count called CHECK_VALUE
        protected_check_counters.decrement(CHECK_VALUE);
      end loop;
    end if;
  end procedure;

  procedure check_value(
    constant value        : t_unsigned_array;
    constant exp          : t_unsigned_array;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_unsigned_array"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value(value, exp, MATCH_STD, alert_level, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  ----------------------------------------------------------------------
  -- Overloads to allow check_value to be called without alert_level
  ----------------------------------------------------------------------
  procedure check_value(
    constant value        : boolean;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
  begin
    check_value(value, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : boolean;
    constant exp          : boolean;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
  begin
    check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value            : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()"
  ) is
  begin
    check_value(value, exp, match_strictness, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : std_logic;
    constant exp          : std_logic;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
  begin
    check_value(value, exp, MATCH_STD, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value            : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "slv"
  ) is
  begin
    check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : std_logic_vector;
    constant exp          : std_logic_vector;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "slv"
  ) is
  begin
    check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value            : unsigned;
    constant exp              : unsigned;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "unsigned"
  ) is
  begin
    check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : unsigned;
    constant exp          : unsigned;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "unsigned"
  ) is
  begin
    check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value            : signed;
    constant exp              : signed;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "signed"
  ) is
  begin
    check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : signed;
    constant exp          : signed;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "signed"
  ) is
  begin
    check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : integer;
    constant exp          : integer;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
  begin
    check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : real;
    constant exp          : real;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
  begin
    check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : time;
    constant exp          : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
  begin
    check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value        : string;
    constant exp          : string;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
  ) is
  begin
    check_value(value, exp, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  procedure check_value(
    constant value            : t_slv_array;
    constant exp              : t_slv_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_slv_array"
  ) is
  begin
    check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : t_slv_array;
    constant exp          : t_slv_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_slv_array"
  ) is
  begin
    check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value            : t_signed_array;
    constant exp              : t_signed_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_signed_array"
  ) is
  begin
    check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : t_signed_array;
    constant exp          : t_signed_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_signed_array"
  ) is
  begin
    check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value            : t_unsigned_array;
    constant exp              : t_unsigned_array;
    constant match_strictness : t_match_strictness;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := KEEP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : string         := "check_value()";
    constant value_type       : string         := "t_unsigned_array"
  ) is
  begin
    check_value(value, exp, match_strictness, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_value(
    constant value        : t_unsigned_array;
    constant exp          : t_unsigned_array;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := KEEP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()";
    constant value_type   : string         := "t_unsigned_array"
  ) is
  begin
    check_value(value, exp, MATCH_STD, error, msg, scope, radix, format, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  ------------------------------------------------------------------------
  -- check_value_in_range
  ------------------------------------------------------------------------
  impure function check_value_in_range(
    constant value        : integer;
    constant min_value    : integer;
    constant max_value    : integer;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "integer"
  ) return boolean is
    constant C_VALUE_STR     : string := to_string(value);
    constant C_MIN_VALUE_STR : string := to_string(min_value);
    constant C_MAX_VALUE_STR : string := to_string(max_value);
    variable v_check_ok      : boolean;
  begin
    protected_check_counters.increment(CHECK_VALUE_IN_RANGE);

    -- Sanity check
    check_value(max_value >= min_value, TB_ERROR, scope,
    " => min_value (" & C_MIN_VALUE_STR & ") must be less than max_value(" & C_MAX_VALUE_STR & ")" & LF & msg, ID_NEVER, msg_id_panel, caller_name);
    -- do not count CHECK_VALUE from CHECK_VALUE_IN_RANGE
    protected_check_counters.decrement(CHECK_VALUE);

    if (value >= min_value and value <= max_value) then
      log(msg_id, caller_name & " => OK, for " & value_type & " " & C_VALUE_STR & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. " & value_type & "  Was " & C_VALUE_STR & ". Expected between " & C_MIN_VALUE_STR & " and " & C_MAX_VALUE_STR & LF & msg, scope);
      return false;
    end if;
  end function;

  impure function check_value_in_range(
    constant value        : unsigned;
    constant min_value    : unsigned;
    constant max_value    : unsigned;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "unsigned"
  ) return boolean is
    constant C_VALUE_STR     : string := to_string(value);
    constant C_MIN_VALUE_STR : string := to_string(min_value);
    constant C_MAX_VALUE_STR : string := to_string(max_value);
  begin
    protected_check_counters.increment(CHECK_VALUE_IN_RANGE);

    -- Sanity check
    check_value(max_value >= min_value, TB_ERROR, scope,
    " => min_value (" & C_MIN_VALUE_STR & ") must be less than max_value(" & C_MAX_VALUE_STR & ")" & LF & msg, ID_NEVER, msg_id_panel, caller_name);
    -- do not count CHECK_VALUE from CHECK_VALUE_IN_RANGE
    protected_check_counters.decrement(CHECK_VALUE);

    if (value >= min_value and value <= max_value) then
      log(msg_id, caller_name & " => OK, for " & value_type & " " & C_VALUE_STR & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. " & value_type & "  Was " & C_VALUE_STR & ". Expected between " & C_MIN_VALUE_STR & " and " & C_MAX_VALUE_STR & LF & msg, scope);
      return false;
    end if;
  end function;

  impure function check_value_in_range(
    constant value        : signed;
    constant min_value    : signed;
    constant max_value    : signed;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "signed"
  ) return boolean is
    constant C_VALUE_STR     : string := to_string(value);
    constant C_MIN_VALUE_STR : string := to_string(min_value);
    constant C_MAX_VALUE_STR : string := to_string(max_value);
  begin
    protected_check_counters.increment(CHECK_VALUE_IN_RANGE);

    -- Sanity check
    check_value(max_value >= min_value, TB_ERROR, scope,
    " => min_value (" & C_MIN_VALUE_STR & ") must be less than max_value(" & C_MAX_VALUE_STR & ")" & LF & msg, ID_NEVER, msg_id_panel, caller_name);
    -- do not count CHECK_VALUE from CHECK_VALUE_IN_RANGE
    protected_check_counters.decrement(CHECK_VALUE);

    if (value >= min_value and value <= max_value) then
      log(msg_id, caller_name & " => OK, for " & value_type & " " & C_VALUE_STR & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. " & value_type & "  Was " & C_VALUE_STR & ". Expected between " & C_MIN_VALUE_STR & " and " & C_MAX_VALUE_STR & LF & msg, scope);
      return false;
    end if;
  end function;

  impure function check_value_in_range(
    constant value        : time;
    constant min_value    : time;
    constant max_value    : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) return boolean is
    constant C_VALUE_TYPE     : string := "time";
    variable v_value_line     : line;
    variable v_min_value_line : line;
    variable v_max_value_line : line;
    variable v_check_ok       : boolean;
    variable v_time_unit      : time;
    variable v_return_val     : boolean;
  begin
    protected_check_counters.increment(CHECK_VALUE_IN_RANGE);

    v_time_unit := get_time_unit(max_value);
    write(v_value_line, value, right, 0, v_time_unit);
    write(v_min_value_line, min_value, right, 0, v_time_unit);
    write(v_max_value_line, max_value, right, 0, v_time_unit);

    -- Sanity check
    check_value(max_value >= min_value, TB_ERROR, scope,
    " => min_value (" & v_min_value_line.all & ") must be less than max_value(" & v_max_value_line.all & ")" & LF & msg, ID_NEVER, msg_id_panel, caller_name);
    -- do not count CHECK_VALUE from CHECK_VALUE_IN_RANGE
    protected_check_counters.decrement(CHECK_VALUE);

    if (value >= min_value and value <= max_value) then
      log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " " & v_value_line.all & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      v_return_val := true;
    else
      alert(alert_level, caller_name & " => Failed. " & C_VALUE_TYPE & "  Was " & v_value_line.all & ". Expected between " & v_min_value_line.all & " and " & v_max_value_line.all & LF & msg, scope);
      v_return_val := false;
    end if;
    DEALLOCATE(v_value_line);
    DEALLOCATE(v_min_value_line);
    DEALLOCATE(v_max_value_line);
    return v_return_val;
  end function;

  impure function check_value_in_range(
    constant value        : real;
    constant min_value    : real;
    constant max_value    : real;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) return boolean is
    constant C_VALUE_TYPE    : string := "real";
    constant C_VALUE_STR     : string := to_string(value);
    constant C_MIN_VALUE_STR : string := to_string(min_value);
    constant C_MAX_VALUE_STR : string := to_string(max_value);
    variable v_check_ok      : boolean;
  begin
    protected_check_counters.increment(CHECK_VALUE_IN_RANGE);

    -- Sanity check
    check_value(max_value >= min_value, TB_ERROR,
    " => min_value (" & C_MIN_VALUE_STR & ") must be less than max_value(" & C_MAX_VALUE_STR & ")" & LF & msg, scope,
    ID_NEVER, msg_id_panel, caller_name);
    -- do not count CHECK_VALUE from CHECK_VALUE_IN_RANGE
    protected_check_counters.decrement(CHECK_VALUE);

    if (value >= min_value and value <= max_value) then
      log(msg_id, caller_name & " => OK, for " & C_VALUE_TYPE & " " & C_VALUE_STR & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. " & C_VALUE_TYPE & "  Was " & C_VALUE_STR & ". Expected between " & C_MIN_VALUE_STR & " and " & C_MAX_VALUE_STR & LF & msg, scope);
      return false;
    end if;
  end function;

  -- check_value_in_range without mandatory alert_level
  impure function check_value_in_range(
    constant value        : integer;
    constant min_value    : integer;
    constant max_value    : integer;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "integer"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value_in_range(
    constant value        : unsigned;
    constant min_value    : unsigned;
    constant max_value    : unsigned;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "unsigned"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value_in_range(
    constant value        : signed;
    constant min_value    : signed;
    constant max_value    : signed;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()";
    constant value_type   : string         := "signed"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
    return v_check_ok;
  end function;

  impure function check_value_in_range(
    constant value        : time;
    constant min_value    : time;
    constant max_value    : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;

  impure function check_value_in_range(
    constant value        : real;
    constant min_value    : real;
    constant max_value    : real;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) return boolean is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name);
    return v_check_ok;
  end function;
  --------------------------------------------------------------------------------
  -- check_value_in_range procedures :
  -- Call the corresponding function and discard the return value
  --------------------------------------------------------------------------------
  procedure check_value_in_range(
    constant value        : integer;
    constant min_value    : integer;
    constant max_value    : integer;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  procedure check_value_in_range(
    constant value        : unsigned;
    constant min_value    : unsigned;
    constant max_value    : unsigned;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  procedure check_value_in_range(
    constant value        : signed;
    constant min_value    : signed;
    constant max_value    : signed;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  procedure check_value_in_range(
    constant value        : time;
    constant min_value    : time;
    constant max_value    : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  procedure check_value_in_range(
    constant value        : real;
    constant min_value    : real;
    constant max_value    : real;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_value_in_range(value, min_value, max_value, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- check_value_in_range procedures without mandatory alert_level
  procedure check_value_in_range(
    constant value        : integer;
    constant min_value    : integer;
    constant max_value    : integer;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
  begin
    check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  procedure check_value_in_range(
    constant value        : unsigned;
    constant min_value    : unsigned;
    constant max_value    : unsigned;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
  begin
    check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  procedure check_value_in_range(
    constant value        : signed;
    constant min_value    : signed;
    constant max_value    : signed;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
  begin
    check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  procedure check_value_in_range(
    constant value        : time;
    constant min_value    : time;
    constant max_value    : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
  begin
    check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;
  procedure check_value_in_range(
    constant value        : real;
    constant min_value    : real;
    constant max_value    : real;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value_in_range()"
  ) is
  begin
    check_value_in_range(value, min_value, max_value, error, msg, scope, msg_id, msg_id_panel, caller_name);
  end procedure;

  --------------------------------------------------------------------------------
  -- check_stable
  --------------------------------------------------------------------------------
  procedure check_stable(
    signal target         : boolean;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "boolean"
  ) is
    constant C_VALUE_STRING       : string := to_string(target);
    constant C_LAST_VALUE_STRING  : string := to_string(target'last_value);
    constant C_LAST_CHANGE        : time   := target'last_event;
    constant C_LAST_CHANGE_STRING : string := to_string(C_LAST_CHANGE, ns);
  begin
    protected_check_counters.increment(CHECK_STABLE);

    if (C_LAST_CHANGE >= stable_req) then
      log(msg_id, caller_name & " => OK. Stable at " & C_VALUE_STRING & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, caller_name & " => Failed. Switched from " & C_LAST_VALUE_STRING & " to " & C_VALUE_STRING & " " & C_LAST_CHANGE_STRING & " ago. Expected stable for " & to_string(stable_req) & LF & msg, scope);
    end if;
  end procedure;

  procedure check_stable(
    signal target         : in std_logic_vector;
    constant stable_req   : in time;
    constant alert_level  : in t_alert_level;
    variable success      : out boolean;
    constant msg          : in string;
    constant scope        : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : in string         := "check_stable()";
    constant value_type   : in string         := "slv"
  ) is
    constant C_VALUE_STRING       : string := 'x' & to_string(target, HEX);
    constant C_LAST_VALUE_STRING  : string := 'x' & to_string(target'last_value, HEX);
    constant C_LAST_CHANGE        : time   := target'last_event;
    constant C_LAST_CHANGE_STRING : string := to_string(C_LAST_CHANGE, ns);
  begin
    protected_check_counters.increment(CHECK_STABLE);
    success := true;

    if (C_LAST_CHANGE >= stable_req) then
      log(msg_id, caller_name & " => OK. Stable at " & C_VALUE_STRING & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, caller_name & " => Failed. Switched from " & C_LAST_VALUE_STRING & " to " & C_VALUE_STRING & " " & C_LAST_CHANGE_STRING & " ago. Expected stable for " & to_string(stable_req) & LF & msg, scope);
      success := false;
    end if;
  end procedure;

  procedure check_stable(
    signal target         : std_logic_vector;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "slv"
  ) is
    variable v_success : boolean;
  begin
    check_stable(target, stable_req, alert_level, v_success, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_stable(
    signal target         : unsigned;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "unsigned"
  ) is
    constant C_VALUE_STRING       : string := 'x' & to_string(target, HEX);
    constant C_LAST_VALUE_STRING  : string := 'x' & to_string(target'last_value, HEX);
    constant C_LAST_CHANGE        : time   := target'last_event;
    constant C_LAST_CHANGE_STRING : string := to_string(C_LAST_CHANGE, ns);
  begin
    protected_check_counters.increment(CHECK_STABLE);

    if (C_LAST_CHANGE >= stable_req) then
      log(msg_id, caller_name & " => OK. Stable at " & C_VALUE_STRING & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, caller_name & " => Failed. Switched from " & C_LAST_VALUE_STRING & " to " & C_VALUE_STRING & " " & C_LAST_CHANGE_STRING & " ago. Expected stable for " & to_string(stable_req) & LF & msg, scope);
    end if;
  end procedure;

  procedure check_stable(
    signal target         : signed;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "signed"
  ) is
    constant C_VALUE_STRING       : string := 'x' & to_string(target, HEX);
    constant C_LAST_VALUE_STRING  : string := 'x' & to_string(target'last_value, HEX);
    constant C_LAST_CHANGE        : time   := target'last_event;
    constant C_LAST_CHANGE_STRING : string := to_string(C_LAST_CHANGE, ns);
  begin
    protected_check_counters.increment(CHECK_STABLE);

    if (C_LAST_CHANGE >= stable_req) then
      log(msg_id, caller_name & " => OK. Stable at " & C_VALUE_STRING & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, caller_name & " => Failed. Switched from " & C_LAST_VALUE_STRING & " to " & C_VALUE_STRING & " " & C_LAST_CHANGE_STRING & " ago. Expected stable for " & to_string(stable_req) & LF & msg, scope);
    end if;
  end procedure;

  procedure check_stable(
    signal target         : std_logic;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "std_logic"
  ) is
    constant C_VALUE_STRING       : string := to_string(target);
    constant C_LAST_VALUE_STRING  : string := to_string(target'last_value);
    constant C_LAST_CHANGE        : time   := target'last_event;
    constant C_LAST_CHANGE_STRING : string := to_string(C_LAST_CHANGE, ns);
  begin
    protected_check_counters.increment(CHECK_STABLE);

    if (C_LAST_CHANGE >= stable_req) then
      log(msg_id, caller_name & " => OK. Stable at " & C_VALUE_STRING & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, caller_name & " => Failed. Switched from " & C_LAST_VALUE_STRING & " to " & C_VALUE_STRING & " " & C_LAST_CHANGE_STRING & " ago. Expected stable for " & to_string(stable_req) & LF & msg, scope);
    end if;
  end procedure;

  procedure check_stable(
    signal target         : integer;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "integer"
  ) is
    constant C_VALUE_STRING       : string := to_string(target);
    constant C_LAST_VALUE_STRING  : string := to_string(target'last_value);
    constant C_LAST_CHANGE        : time   := target'last_event;
    constant C_LAST_CHANGE_STRING : string := to_string(C_LAST_CHANGE, ns);
  begin
    protected_check_counters.increment(CHECK_STABLE);

    if (C_LAST_CHANGE >= stable_req) then
      log(msg_id, caller_name & " => OK." & C_VALUE_STRING & " stable at " & C_VALUE_STRING & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, caller_name & " => Failed. Switched from " & C_LAST_VALUE_STRING & " to " & C_VALUE_STRING & " " & C_LAST_CHANGE_STRING & " ago. Expected stable for " & to_string(stable_req) & LF & msg, scope);
    end if;
  end procedure;

  procedure check_stable(
    signal target         : real;
    constant stable_req   : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "real"
  ) is
    constant C_VALUE_STRING       : string := to_string(target);
    constant C_LAST_VALUE_STRING  : string := to_string(target'last_value);
    constant C_LAST_CHANGE        : time   := target'last_event;
    constant C_LAST_CHANGE_STRING : string := to_string(C_LAST_CHANGE, ns);
  begin
    protected_check_counters.increment(CHECK_STABLE);

    if (C_LAST_CHANGE >= stable_req) then
      log(msg_id, caller_name & " => OK." & C_VALUE_STRING & " stable at " & C_VALUE_STRING & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, caller_name & " => Failed. Switched from " & C_LAST_VALUE_STRING & " to " & C_VALUE_STRING & " " & C_LAST_CHANGE_STRING & " ago. Expected stable for " & to_string(stable_req) & LF & msg, scope);
    end if;
  end procedure;

  -- check stable overloads without mandatory alert level
  procedure check_stable(
    signal target         : boolean;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "boolean"
  ) is
  begin
    check_stable(target, stable_req, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_stable(
    signal target         : std_logic_vector;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "slv"
  ) is
  begin
    check_stable(target, stable_req, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_stable(
    signal target         : unsigned;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "unsigned"
  ) is
  begin
    check_stable(target, stable_req, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_stable(
    signal target         : signed;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "signed"
  ) is
  begin
    check_stable(target, stable_req, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_stable(
    signal target         : std_logic;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "std_logic"
  ) is
  begin
    check_stable(target, stable_req, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_stable(
    signal target         : integer;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "integer"
  ) is
  begin
    check_stable(target, stable_req, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure check_stable(
    signal target         : real;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_stable()";
    constant value_type   : string         := "real"
  ) is
  begin
    check_stable(target, stable_req, error, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure await_stable_value(
    signal target         : boolean;
    constant expected     : boolean;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "boolean"
  ) is
  begin
    check_value(target, expected, error, caller_name & " (" & value_type & ") => initial value was incorrect" & LF & msg, scope, msg_id, msg_id_panel, caller_name);
    wait for stable_req;
    check_value(target, expected, error, caller_name & " (" & value_type & ") => value was incorrect after " & to_string(stable_req) & "." & LF & msg, scope, msg_id, msg_id_panel, caller_name);
    check_stable(target, stable_req, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure await_stable_value(
    signal target         : std_logic_vector;
    constant expected     : std_logic_vector;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "slv"
  ) is
  begin
    check_value(target, expected, error, caller_name & " (" & value_type & ") => initial value was incorrect" & LF & msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, msg_id, msg_id_panel, caller_name);
    wait for stable_req;
    check_value(target, expected, error, caller_name & " (" & value_type & ") => value was incorrect after " & to_string(stable_req) & "." & LF & msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, msg_id, msg_id_panel, caller_name);
    check_stable(target, stable_req, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure await_stable_value(
    signal target         : unsigned;
    constant expected     : unsigned;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "unsigned"
  ) is
  begin
    check_value(target, expected, error, caller_name & " (" & value_type & ") => initial value was incorrect" & LF & msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, msg_id, msg_id_panel, caller_name);
    wait for stable_req;
    check_value(target, expected, error, caller_name & " (" & value_type & ") => value was incorrect after " & to_string(stable_req) & "." & LF & msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, msg_id, msg_id_panel, caller_name);
    check_stable(target, stable_req, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure await_stable_value(
    signal target         : signed;
    constant expected     : signed;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "signed"
  ) is
  begin
    check_value(target, expected, error, caller_name & " (" & value_type & ") => initial value was incorrect" & LF & msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, msg_id, msg_id_panel, caller_name);
    wait for stable_req;
    check_value(target, expected, error, caller_name & " (" & value_type & ") => value was incorrect after " & to_string(stable_req) & "." & LF & msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, msg_id, msg_id_panel, caller_name);
    check_stable(target, stable_req, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure await_stable_value(
    signal target         : std_logic;
    constant expected     : std_logic;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "std_logic"
  ) is
  begin
    check_value(target, expected, error, caller_name & " (" & value_type & ") => initial value was incorrect" & LF & msg, scope, msg_id, msg_id_panel, caller_name);
    wait for stable_req;
    check_value(target, expected, error, caller_name & " (" & value_type & ") => value was incorrect after " & to_string(stable_req) & "." & LF & msg, scope, msg_id, msg_id_panel, caller_name);
    check_stable(target, stable_req, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure await_stable_value(
    signal target         : integer;
    constant expected     : integer;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "integer"
  ) is
  begin
    check_value(target, expected, error, caller_name & " (" & value_type & ") => initial value was incorrect" & LF & msg, scope, msg_id, msg_id_panel, caller_name);
    wait for stable_req;
    check_value(target, expected, error, caller_name & " (" & value_type & ") => value was incorrect after " & to_string(stable_req) & "." & LF & msg, scope, msg_id, msg_id_panel, caller_name);
    check_stable(target, stable_req, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  procedure await_stable_value(
    signal target         : real;
    constant expected     : real;
    constant stable_req   : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "await_stable_value()";
    constant value_type   : string         := "real"
  ) is
  begin
    check_value(target, expected, error, caller_name & " (" & value_type & ") => initial value was incorrect" & LF & msg, scope, msg_id, msg_id_panel, caller_name);
    wait for stable_req;
    check_value(target, expected, error, caller_name & " (" & value_type & ") => value was incorrect after " & to_string(stable_req) & "." & LF & msg, scope, msg_id, msg_id_panel, caller_name);
    check_stable(target, stable_req, msg, scope, msg_id, msg_id_panel, caller_name, value_type);
  end procedure;

  ----------------------------------------------------------------------------
  -- check_time_window is used to check if a given condition occurred between
  -- min_time and max_time
  -- Usage: wait for requested condition until max_time is reached, then call check_time_window().
  -- The input 'success' is needed to distinguish between the following cases:
  --      - the signal reached success condition at max_time,
  --      - max_time was reached with no success condition
  ----------------------------------------------------------------------------
  procedure check_time_window(
    constant success      : in boolean; -- F.ex target'event, or target=exp
    constant elapsed_time : in time;
    constant min_time     : in time;
    constant max_time     : in time;
    constant alert_level  : in t_alert_level;
    constant name         : in string;
    variable check_is_ok  : out boolean;
    constant msg          : in string;
    constant scope        : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    protected_check_counters.increment(CHECK_TIME_WINDOW);
    check_is_ok := true;

    -- Sanity check
    check_value(max_time >= min_time, TB_ERROR, name & " => min_time must be less than max_time." & LF & msg, scope, ID_NEVER, msg_id_panel, name);
    -- do not count CHECK_VALUE from CHECK_TIME_WINDOW
    protected_check_counters.decrement(CHECK_VALUE);

    if elapsed_time < min_time then
      alert(alert_level, name & " => Failed. Condition occurred too early, after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      check_is_ok := false;
    elsif success then
      log(msg_id, name & " => OK. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else -- max_time reached with no success
      alert(alert_level, name & " => Failed. Timed out after " & to_string(max_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      check_is_ok := false;
    end if;
  end procedure;

  procedure check_time_window(
    constant success      : boolean; -- F.ex target'event, or target=exp
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
    variable v_check_is_ok : boolean;
  begin
    check_time_window(success, elapsed_time, min_time, max_time, alert_level, name, v_check_is_ok, msg, scope, msg_id, msg_id_panel);
  end procedure;

  ----------------------------------------------------------------------------
  -- Random functions
  ----------------------------------------------------------------------------
  -- Return a random std_logic_vector, using overload for the integer version of random()
  impure function random(
    constant length : integer
  ) return std_logic_vector is
    variable v_random_vec : std_logic_vector(length - 1 downto 0);
  begin
    -- Iterate through each bit and randomly set to 0 or 1
    for i in 0 to length - 1 loop
      v_random_vec(i downto i) := std_logic_vector(to_unsigned(random(0, 1), 1));
    end loop;
    return v_random_vec;
  end function;

  -- Return a random std_logic, using overload for the SLV version of random()
  impure function random(
    constant VOID : t_void
  ) return std_logic is
    variable v_random_bit : std_logic_vector(0 downto 0);
  begin
    -- randomly set bit to 0 or 1
    v_random_bit := random(1);
    return v_random_bit(0);
  end function;

  -- Return a random integer between min_value and max_value
  -- Use global seeds
  impure function random(
    constant min_value : integer;
    constant max_value : integer
  ) return integer is
    variable v_rand_scaled : integer;
    variable v_seed1       : positive := shared_seed1;
    variable v_seed2       : positive := shared_seed2;
  begin
    random(min_value, max_value, v_seed1, v_seed2, v_rand_scaled);
    -- Write back seeds
    shared_seed1 := v_seed1;
    shared_seed2 := v_seed2;
    return v_rand_scaled;
  end function;

  -- Return a random real between min_value and max_value
  -- Use global seeds
  impure function random(
    constant min_value : real;
    constant max_value : real
  ) return real is
    variable v_rand_scaled : real;
    variable v_seed1       : positive := shared_seed1;
    variable v_seed2       : positive := shared_seed2;
  begin
    random(min_value, max_value, v_seed1, v_seed2, v_rand_scaled);
    -- Write back seeds
    shared_seed1 := v_seed1;
    shared_seed2 := v_seed2;
    return v_rand_scaled;
  end function;

  -- Return a random time between min time and max time using the given time resolution
  -- Use global seeds
  impure function random(
    constant min_value       : time;
    constant max_value       : time;
    constant time_resolution : time
  ) return time is
    variable v_rand_scaled : time;
    variable v_seed1       : positive := shared_seed1;
    variable v_seed2       : positive := shared_seed2;
  begin
    random(min_value, max_value, time_resolution, v_seed1, v_seed2, v_rand_scaled);
    -- Write back seeds
    shared_seed1 := v_seed1;
    shared_seed2 := v_seed2;
    return v_rand_scaled;
  end function;

  -- Overload with default time resolution
  impure function random(
    constant min_value : time;
    constant max_value : time
  ) return time is
    variable v_rand_scaled : time;
    variable v_seed1       : positive := shared_seed1;
    variable v_seed2       : positive := shared_seed2;
  begin
    random(min_value, max_value, std.env.resolution_limit, v_seed1, v_seed2, v_rand_scaled, "overload");
    -- Write back seeds
    shared_seed1 := v_seed1;
    shared_seed2 := v_seed2;
    return v_rand_scaled;
  end function;

  --
  -- Procedure versions of random(), where seeds can be specified
  --
  -- Set target to a random SLV, using overload for the integer version of random().
  procedure random(
    variable v_seed1  : inout positive;
    variable v_seed2  : inout positive;
    variable v_target : inout std_logic_vector
  ) is
    variable v_length : integer := v_target'length;
    variable v_rand   : integer;
    variable v_bit    : std_logic_vector(0 downto 0);
  begin
    -- Iterate through each bit and randomly set to 0 or 1
    for i in 0 to v_length - 1 loop
      random(0, 1, v_seed1, v_seed2, v_rand);
      v_bit       := std_logic_vector(to_unsigned(v_rand, 1));
      v_target(i) := v_bit(0);
    end loop;
  end procedure;

  -- Set target to a random SL, using overload for the SLV version of random().
  procedure random(
    variable v_seed1  : inout positive;
    variable v_seed2  : inout positive;
    variable v_target : inout std_logic
  ) is
    variable v_random_slv : std_logic_vector(0 downto 0);
  begin
    random(v_seed1, v_seed2, v_random_slv);
    v_target := v_random_slv(0);
  end procedure;

  -- Set target to a random integer between min_value and max_value
  procedure random(
    constant min_value : integer;
    constant max_value : integer;
    variable v_seed1   : inout positive;
    variable v_seed2   : inout positive;
    variable v_target  : inout integer
  ) is
    variable v_rand : real;
  begin
    -- Random real-number value in range 0 to 1.0
    uniform(v_seed1, v_seed2, v_rand);
    -- Scale to a random integer between min_value and max_value
    v_target := integer(real(min_value) + trunc(v_rand * (1.0 + real(max_value) - real(min_value))));
  end procedure;

  -- Set target to a random integer between min_value and max_value
  procedure random(
    constant min_value : real;
    constant max_value : real;
    variable v_seed1   : inout positive;
    variable v_seed2   : inout positive;
    variable v_target  : inout real
  ) is
    variable v_rand : real;
  begin
    -- Random real-number value in range 0 to 1.0
    uniform(v_seed1, v_seed2, v_rand);
    -- Scale to a random integer between min_value and max_value
    v_target := min_value + v_rand * (max_value - min_value);
  end procedure;

  -- Set target to a random integer between min_value and max_value using the given time resolution
  procedure random(
    constant min_value       : time;
    constant max_value       : time;
    constant time_resolution : time;
    variable v_seed1         : inout positive;
    variable v_seed2         : inout positive;
    variable v_target        : inout time;
    constant ext_proc_call   : string := "" -- External proc_call. Overwrite if called from random() overload
  ) is
    constant C_MAX_INT_VAL : real := real(integer'right);
    variable v_time_unit   : time := time_resolution;
    variable v_rand        : real;
    variable v_rand_int    : integer;
    function get_range(constant max : in time; constant min : in time; constant unit : in time) return real is
    begin
      return (1.0 + real(max / unit) - real(min / unit));
    end function;
  begin
    -- Adjust the time resolution so that the random value does not overflow the integer range
    if get_range(max_value, min_value, v_time_unit) > C_MAX_INT_VAL then
      while (get_range(max_value, min_value, v_time_unit) > C_MAX_INT_VAL) loop
        v_time_unit := v_time_unit * 1000;
      end loop;
      if not (shared_warned_rand_time_res) and ext_proc_call'length = 0 then
        alert(TB_WARNING,
        "random(" & to_string(min_value) & "," & to_string(max_value) & "," & to_string(time_resolution) & ") => time_resolution is too small for the given range. It has been increased to " & to_string(v_time_unit),
        C_TB_SCOPE_DEFAULT);
        shared_warned_rand_time_res := true;
      end if;
    end if;

    -- Random real-number value in range 0 to 1.0
    uniform(v_seed1, v_seed2, v_rand);
    -- Scale to a random integer between min_value and max_value
    v_rand_int := integer(real(min_value / v_time_unit) + trunc(v_rand * get_range(max_value, min_value, v_time_unit)));
    v_target   := v_rand_int * v_time_unit;
  end procedure;

  -- Overload with default time resolution
  procedure random(
    constant min_value : time;
    constant max_value : time;
    variable v_seed1   : inout positive;
    variable v_seed2   : inout positive;
    variable v_target  : inout time
  ) is
  begin
    random(min_value, max_value, std.env.resolution_limit, v_seed1, v_seed2, v_target, "overload");
  end procedure;

  -- Set global seeds
  procedure randomize(
    constant seed1 : positive;
    constant seed2 : positive;
    constant msg   : string := "randomizing seeds";
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    log(ID_UTIL_SETUP, "Setting global seeds to " & to_string(seed1) & ", " & to_string(seed2), scope);
    shared_seed1 := seed1;
    shared_seed2 := seed2;
  end procedure;

  -- Set global seeds
  procedure randomise(
    constant seed1 : positive;
    constant seed2 : positive;
    constant msg   : string := "randomising seeds";
    constant scope : string := C_TB_SCOPE_DEFAULT
  ) is
  begin
    deprecate(get_procedure_name_from_instance_name(seed1'instance_name), "Use randomize().");
    log(ID_UTIL_SETUP, "Setting global seeds to " & to_string(seed1) & ", " & to_string(seed2), scope);
    shared_seed1 := seed1;
    shared_seed2 := seed2;
  end procedure;

  -- Converts a t_byte_array (ascending) to a std_logic_vector
  function convert_byte_array_to_slv(
    constant byte_array      : t_byte_array;
    constant byte_endianness : t_byte_endianness
  ) return std_logic_vector is
    constant C_NUM_BYTES        : integer := byte_array'length;
    alias normalized_byte_array : t_byte_array(0 to C_NUM_BYTES - 1) is byte_array;
    variable v_slv              : std_logic_vector(8 * C_NUM_BYTES - 1 downto 0);
  begin
    assert byte_array'ascending report "byte_array must be ascending" severity error;

    for byte_idx in 0 to C_NUM_BYTES - 1 loop
      if (byte_endianness = LOWER_BYTE_LEFT) or (byte_endianness = FIRST_BYTE_LEFT) then
        v_slv(8 * (C_NUM_BYTES - byte_idx) - 1 downto 8 * (C_NUM_BYTES - 1 - byte_idx)) := normalized_byte_array(byte_idx);
      else -- LOWER_BYTE_RIGHT or FIRST_BYTE_RIGHT
        v_slv(8 * (byte_idx + 1) - 1 downto 8 * byte_idx) := normalized_byte_array(byte_idx);
      end if;
    end loop;
    return v_slv;
  end function;

  -- Converts a std_logic_vector to a t_byte_array (ascending)
  function convert_slv_to_byte_array(
    constant slv             : std_logic_vector;
    constant byte_endianness : t_byte_endianness
  ) return t_byte_array is
    variable v_num_bytes   : integer := slv'length / 8 + 1; -- +1 in case there's a division remainder
    alias normalized_slv   : std_logic_vector(slv'length - 1 downto 0) is slv;
    variable v_byte_array  : t_byte_array(0 to v_num_bytes - 1);
    variable v_slv_idx     : integer := normalized_slv'high;
    variable v_slv_idx_min : integer;
  begin
    -- Adjust value if there was no remainder
    if (slv'length mod 8) = 0 then
      v_num_bytes := v_num_bytes - 1;
    end if;

    for byte_idx in 0 to v_num_bytes - 1 loop
      for bit_idx in 7 downto 0 loop
        if v_slv_idx =- 1 then
          v_byte_array(byte_idx)(bit_idx) := 'Z'; -- Pads 'Z'
        else
          if (byte_endianness = LOWER_BYTE_LEFT) or (byte_endianness = FIRST_BYTE_LEFT) then
            v_byte_array(byte_idx)(bit_idx) := normalized_slv(v_slv_idx);
          else -- LOWER_BYTE_RIGHT or FIRST_BYTE_RIGHT
            v_slv_idx_min                   := MINIMUM(8 * byte_idx + bit_idx, normalized_slv'high); -- avoid indexing outside the slv
            v_byte_array(byte_idx)(bit_idx) := normalized_slv(v_slv_idx_min);
          end if;
          v_slv_idx := v_slv_idx - 1;
        end if;
      end loop;
    end loop;
    return v_byte_array(0 to v_num_bytes - 1);
  end function;

  -- Converts a t_byte_array (any direction) to a t_slv_array (same direction)
  function convert_byte_array_to_slv_array(
    constant byte_array      : t_byte_array;
    constant bytes_in_word   : natural;
    constant byte_endianness : t_byte_endianness := LOWER_BYTE_LEFT
  ) return t_slv_array is
    constant C_NUM_WORDS        : integer := byte_array'length / bytes_in_word;
    variable v_ascending_array  : t_slv_array(0 to C_NUM_WORDS - 1)((8 * bytes_in_word) - 1 downto 0);
    variable v_descending_array : t_slv_array(C_NUM_WORDS - 1 downto 0)((8 * bytes_in_word) - 1 downto 0);
    variable v_byte_idx         : integer := 0;
  begin
    for slv_idx in 0 to C_NUM_WORDS - 1 loop
      if (byte_endianness = LOWER_BYTE_LEFT) or (byte_endianness = FIRST_BYTE_LEFT) then
        for byte_in_word in bytes_in_word downto 1 loop
          v_ascending_array(slv_idx)((8 * byte_in_word) - 1 downto (byte_in_word - 1) * 8)  := byte_array(v_byte_idx);
          v_descending_array(slv_idx)((8 * byte_in_word) - 1 downto (byte_in_word - 1) * 8) := byte_array(v_byte_idx);
          v_byte_idx                                                                        := v_byte_idx + 1;
        end loop;
      else -- LOWER_BYTE_RIGHT or FIRST_BYTE_RIGHT
        for byte_in_word in 1 to bytes_in_word loop
          v_ascending_array(slv_idx)((8 * byte_in_word) - 1 downto (byte_in_word - 1) * 8)  := byte_array(v_byte_idx);
          v_descending_array(slv_idx)((8 * byte_in_word) - 1 downto (byte_in_word - 1) * 8) := byte_array(v_byte_idx);
          v_byte_idx                                                                        := v_byte_idx + 1;
        end loop;
      end if;
    end loop;

    if byte_array'ascending then
      return v_ascending_array;
    else -- byte array is descending
      return v_descending_array;
    end if;
  end function;

  -- Converts a t_slv_array (any direction) to a t_byte_array (same direction)
  function convert_slv_array_to_byte_array(
    constant slv_array       : t_slv_array;
    constant byte_endianness : t_byte_endianness := LOWER_BYTE_LEFT
  ) return t_byte_array is
    constant C_NUM_BYTES_IN_WORD   : integer := (slv_array(slv_array'low)'length / 8);
    constant C_BYTE_ARRAY_LENGTH   : integer := (slv_array'length * C_NUM_BYTES_IN_WORD);
    constant C_VECTOR_IS_ASCENDING : boolean := slv_array(slv_array'low)'ascending;
    variable v_ascending_array     : t_byte_array(0 to C_BYTE_ARRAY_LENGTH - 1);
    variable v_descending_array    : t_byte_array(C_BYTE_ARRAY_LENGTH - 1 downto 0);
    variable v_byte_idx            : integer := 0;
    variable v_offset              : natural := 0;
  begin
    -- Use this offset in case the slv_array doesn't start at 0
    v_offset := slv_array'low;

    for slv_idx in 0 to slv_array'length - 1 loop
      if (byte_endianness = LOWER_BYTE_LEFT) or (byte_endianness = FIRST_BYTE_LEFT) then
        for byte in C_NUM_BYTES_IN_WORD downto 1 loop
          if C_VECTOR_IS_ASCENDING then
            v_ascending_array(v_byte_idx)  := slv_array(slv_idx + v_offset)((byte - 1) * 8 to (8 * byte) - 1);
            v_descending_array(v_byte_idx) := slv_array(slv_idx + v_offset)((byte - 1) * 8 to (8 * byte) - 1);
          else -- SLV vector is descending
            v_ascending_array(v_byte_idx)  := slv_array(slv_idx + v_offset)((8 * byte) - 1 downto (byte - 1) * 8);
            v_descending_array(v_byte_idx) := slv_array(slv_idx + v_offset)((8 * byte) - 1 downto (byte - 1) * 8);
          end if;
          v_byte_idx := v_byte_idx + 1;
        end loop;
      else -- LOWER_BYTE_RIGHT or FIRST_BYTE_RIGHT
        for byte in 1 to C_NUM_BYTES_IN_WORD loop
          if C_VECTOR_IS_ASCENDING then
            v_ascending_array(v_byte_idx)  := slv_array(slv_idx + v_offset)((byte - 1) * 8 to (8 * byte) - 1);
            v_descending_array(v_byte_idx) := slv_array(slv_idx + v_offset)((byte - 1) * 8 to (8 * byte) - 1);
          else -- SLV vector is descending
            v_ascending_array(v_byte_idx)  := slv_array(slv_idx + v_offset)((8 * byte) - 1 downto (byte - 1) * 8);
            v_descending_array(v_byte_idx) := slv_array(slv_idx + v_offset)((8 * byte) - 1 downto (byte - 1) * 8);
          end if;
          v_byte_idx := v_byte_idx + 1;
        end loop;
      end if;
    end loop;

    if slv_array'ascending then
      return v_ascending_array;
    else -- SLV array is descending
      return v_descending_array;
    end if;
  end function;

  function convert_slv_array_to_byte_array(
    constant slv_array       : t_slv_array;
    constant ascending       : boolean           := false;
    constant byte_endianness : t_byte_endianness := LOWER_BYTE_LEFT
  ) return t_byte_array is
    variable v_bytes_in_word     : integer := (slv_array(0)'length / 8);
    variable v_byte_array_length : integer := (slv_array'length * v_bytes_in_word);
    variable v_ascending_array   : t_byte_array(0 to v_byte_array_length - 1);
    variable v_descending_array  : t_byte_array(v_byte_array_length - 1 downto 0);
    variable v_ascending_vector  : boolean := false;
    variable v_byte_number       : integer := 0;
  begin
    -- The ascending parameter should match the array direction. We could also just remove the ascending
    -- parameter and use the t'ascending attribute.
    bitvis_assert((slv_array'ascending and ascending) or (not (slv_array'ascending) and not (ascending)), ERROR,
    "convert_slv_array_to_byte_array()", "slv_array direction doesn't match ascending parameter");

    v_ascending_vector := slv_array(0)'ascending;

    if (byte_endianness = LOWER_BYTE_LEFT) or (byte_endianness = FIRST_BYTE_LEFT) then
      for slv_idx in 0 to slv_array'length - 1 loop
        for byte in v_bytes_in_word downto 1 loop
          if v_ascending_vector then
            v_ascending_array(v_byte_number)  := slv_array(slv_idx)((byte - 1) * 8 to (8 * byte) - 1);
            v_descending_array(v_byte_number) := slv_array(slv_idx)((byte - 1) * 8 to (8 * byte) - 1);
          else -- SLV vector is descending
            v_ascending_array(v_byte_number)  := slv_array(slv_idx)((8 * byte) - 1 downto (byte - 1) * 8);
            v_descending_array(v_byte_number) := slv_array(slv_idx)((8 * byte) - 1 downto (byte - 1) * 8);
          end if;
          v_byte_number := v_byte_number + 1;
        end loop;
      end loop;
    else -- LOWER_BYTE_RIGHT or FIRST_BYTE_RIGHT
      for slv_idx in 0 to slv_array'length - 1 loop
        for byte in 1 to v_bytes_in_word loop
          if v_ascending_vector then
            v_ascending_array(v_byte_number)  := slv_array(slv_idx)((byte - 1) * 8 to (8 * byte) - 1);
            v_descending_array(v_byte_number) := slv_array(slv_idx)((byte - 1) * 8 to (8 * byte) - 1);
          else -- SLV vector is descending
            v_ascending_array(v_byte_number)  := slv_array(slv_idx)((8 * byte) - 1 downto (byte - 1) * 8);
            v_descending_array(v_byte_number) := slv_array(slv_idx)((8 * byte) - 1 downto (byte - 1) * 8);
          end if;
          v_byte_number := v_byte_number + 1;
        end loop;
      end loop;
    end if;

    if ascending then
      return v_ascending_array;
    else -- descending
      return v_descending_array;
    end if;
  end function;

  function reverse_vector(
    constant value : std_logic_vector
  ) return std_logic_vector is
    variable return_val : std_logic_vector(value'range);
  begin
    for i in 0 to value'length - 1 loop
      return_val(value'low + i) := value(value'high - i);
    end loop;
    return return_val;
  end function;

  impure function reverse_vectors_in_array(
    constant value : t_slv_array
  ) return t_slv_array is
    variable return_val : t_slv_array(value'range)(value(value'low)'range);
  begin
    for i in value'range loop
      return_val(i) := reverse_vector(value(i));
    end loop;
    return return_val;
  end function;

  function log2(
    constant num : positive)
    return natural is
    variable return_val : natural := 0;
  begin
    while (2 ** return_val < num) and (return_val < 31) loop
      return_val := return_val + 1;
    end loop;
    return return_val;
  end function;

  -- ============================================================================
  -- Time consuming checks
  -- ============================================================================
  --------------------------------------------------------------------------------
  -- await_change
  -- A signal change is required, but may happen already after 1 delta if min_time = 0 ns
  --------------------------------------------------------------------------------
  procedure await_change(
    signal target         : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "boolean"
  ) is
    constant C_NAME       : string := "await_change(" & value_type & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    constant C_START_TIME : time   := now;
  begin
    wait on target for max_time;
    check_time_window(target'event, now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_change(
    signal target         : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "std_logic"
  ) is
    constant C_NAME       : string := "await_change(" & value_type & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    constant C_START_TIME : time   := now;
  begin
    wait on target for max_time;
    check_time_window(target'event, now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_change(
    signal target         : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "slv"
  ) is
    constant C_NAME       : string := "await_change(" & value_type & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    constant C_START_TIME : time   := now;
  begin
    wait on target for max_time;
    check_time_window(target'event, now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_change(
    signal target         : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "unsigned"
  ) is
    constant C_NAME       : string := "await_change(" & value_type & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    constant C_START_TIME : time   := now;
  begin
    -- Note that overloading by casting target to slv without creating a new signal doesn't work
    wait on target for max_time;
    check_time_window(target'event, now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_change(
    signal target         : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "signed"
  ) is
    constant C_NAME       : string := "await_change(" & value_type & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    constant C_START_TIME : time   := now;
  begin
    wait on target for max_time;
    check_time_window(target'event, now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_change(
    signal target         : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "integer"
  ) is
    constant C_NAME       : string := "await_change(" & value_type & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    constant C_START_TIME : time   := now;
  begin
    wait on target for max_time;
    check_time_window(target'event, now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_change(
    signal target         : real;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "real"
  ) is
    constant C_NAME       : string := "await_change(" & value_type & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    constant C_START_TIME : time   := now;
  begin
    wait on target for max_time;
    check_time_window(target'event, now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  -- Await Change overloads without mandatory alert level
  procedure await_change(
    signal target         : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "boolean"
  ) is
  begin
    await_change(target, min_time, max_time, error, msg, scope, msg_id, msg_id_panel, value_type);
  end procedure;

  procedure await_change(
    signal target         : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "std_logic"
  ) is
  begin
    await_change(target, min_time, max_time, error, msg, scope, msg_id, msg_id_panel, value_type);
  end procedure;

  procedure await_change(
    signal target         : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "slv"
  ) is
  begin
    await_change(target, min_time, max_time, error, msg, scope, msg_id, msg_id_panel, value_type);
  end procedure;

  procedure await_change(
    signal target         : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "unsigned"
  ) is
  begin
    await_change(target, min_time, max_time, error, msg, scope, msg_id, msg_id_panel, value_type);
  end procedure;

  procedure await_change(
    signal target         : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "signed"
  ) is
  begin
    await_change(target, min_time, max_time, error, msg, scope, msg_id, msg_id_panel, value_type);
  end procedure;

  procedure await_change(
    signal target         : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "integer"
  ) is
  begin
    await_change(target, min_time, max_time, error, msg, scope, msg_id, msg_id_panel, value_type);
  end procedure;

  procedure await_change(
    signal target         : real;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "real"
  ) is
  begin
    await_change(target, min_time, max_time, error, msg, scope, msg_id, msg_id_panel, value_type);
  end procedure;

  --------------------------------------------------------------------------------
  -- await_value
  --------------------------------------------------------------------------------
  -- Potential improvements
  --  - Adding an option that the signal must last for more than one delta cycle
  --    or a specified time
  --  - Adding an "AS_IS" option that does not allow the signal to change to other values
  --    before it changes to the expected value
  --
  -- The input signal is allowed to change to other values before ending up on the expected value,
  -- as long as it changes to the expected value within the time window (min_time to max_time).
  -- Wait for target = expected or timeout after max_time.
  -- Then check if (and when) the value changed to the expected
  procedure await_value(
    signal target         : boolean;
    constant exp          : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE : string := "boolean";
    constant C_START_TIME : time   := now;
    constant C_NAME       : string := "await_value(" & C_VALUE_TYPE & " " & to_string(exp) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
  begin
    if (target /= exp) then
      wait until (target = exp) for max_time;
    end if;
    check_time_window((target = exp), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target             : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE : string  := "std_logic";
    constant C_START_TIME : time    := now;
    constant C_NAME       : string  := "await_value(" & C_VALUE_TYPE & " " & to_string(exp) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_success    : boolean := false;
  begin
    v_success := false;

    if match_strictness = MATCH_EXACT then
      if (target /= exp) then
        wait until (target = exp) for max_time;
      end if;
      if (target = exp) then
        v_success := true;
      end if;

    elsif match_strictness = MATCH_STD_INCL_Z then
      if not (std_match(target, exp) or (target = 'Z' and exp = 'Z')) then
        wait until (std_match(target, exp) or (target = 'Z' and exp = 'Z')) for max_time;
      end if;
      if std_match(target, exp) or (target = 'Z' and exp = 'Z') then
        v_success := true;
      end if;

    elsif match_strictness = MATCH_STD_INCL_ZXUW then
      if not (std_match(target, exp) or (target = 'Z' and exp = 'Z') or (target = 'X' and exp = 'X') or (target = 'U' and exp = 'U') or (target = 'W' and exp = 'W')) then
        wait until (std_match(target, exp) or (target = 'Z' and exp = 'Z') or (target = 'X' and exp = 'X') or (target = 'U' and exp = 'U') or (target = 'W' and exp = 'W')) for max_time;
      end if;
      if std_match(target, exp) or (target = 'Z' and exp = 'Z') or (target = 'X' and exp = 'X') or (target = 'U' and exp = 'U') or (target = 'W' and exp = 'W') then
        v_success := true;
      end if;

    else
      if ((exp = '1' or exp = 'H') and (target /= '1') and (target /= 'H')) then
        wait until (target = '1' or target = 'H') for max_time;
      elsif ((exp = '0' or exp = 'L') and (target /= '0') and (target /= 'L')) then
        wait until (target = '0' or target = 'L') for max_time;
      end if;

      if ((exp = '1' or exp = 'H') and (target = '1' or target = 'H')) then
        v_success := true;
      elsif ((exp = '0' or exp = 'L') and (target = '0' or target = 'L')) then
        v_success := true;
      end if;
    end if;
    check_time_window(v_success, now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : std_logic;
    constant exp          : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, MATCH_EXACT, min_time, max_time, alert_level, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target             : in std_logic_vector;
    constant exp              : in std_logic_vector;
    constant match_strictness : in t_match_strictness;
    constant min_time         : in time;
    constant max_time         : in time;
    constant alert_level      : in t_alert_level;
    variable success          : out boolean;
    constant msg              : in string;
    constant scope            : in string         := C_TB_SCOPE_DEFAULT;
    constant radix            : in t_radix        := HEX_BIN_IF_INVALID;
    constant format           : in t_format_zeros := SKIP_LEADING_0;
    constant msg_id           : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : in t_msg_id_panel := shared_msg_id_panel;
    constant caller_name      : in string         := ""
  ) is
    constant C_VALUE_TYPE : string := "slv";
    constant C_START_TIME : time   := now;
    constant C_EXP_STR    : string := to_string(exp, radix, format, INCL_RADIX);
    constant C_NAME       : string := "await_value(" & C_VALUE_TYPE & " " & C_EXP_STR & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_proc_call  : line;
  begin
    if caller_name'length = 0 then
      write(v_proc_call, C_NAME);
    else
      write(v_proc_call, caller_name);
    end if;

    -- AS_IS format has been deprecated and will be removed in the near future
    if format = AS_IS then
      deprecate(get_procedure_name_from_instance_name(target'instance_name), "format 'AS_IS' has been deprecated. Use KEEP_LEADING_0.");
    end if;

    if matching_widths(target, exp) then
      if match_strictness = MATCH_STD then
        if not matching_values(target, exp) then
          wait until matching_values(target, exp) for max_time;
        end if;
        check_time_window(matching_values(target, exp), now - C_START_TIME, min_time, max_time, alert_level, v_proc_call.all, success, msg, scope, msg_id, msg_id_panel);
      elsif match_strictness = MATCH_STD_INCL_Z then
        if not matching_values(target, exp, MATCH_STD_INCL_Z) then
          wait until matching_values(target, exp, MATCH_STD_INCL_Z) for max_time;
        end if;
        check_time_window(matching_values(target, exp, MATCH_STD_INCL_Z), now - C_START_TIME, min_time, max_time, alert_level, v_proc_call.all, success, msg, scope, msg_id, msg_id_panel);
      elsif match_strictness = MATCH_STD_INCL_ZXUW then
        if not matching_values(target, exp, MATCH_STD_INCL_ZXUW) then
          wait until matching_values(target, exp, MATCH_STD_INCL_ZXUW) for max_time;
        end if;
        check_time_window(matching_values(target, exp, MATCH_STD_INCL_ZXUW), now - C_START_TIME, min_time, max_time, alert_level, v_proc_call.all, success, msg, scope, msg_id, msg_id_panel);

      else
        if (target /= exp) then
          wait until (target = exp) for max_time;
        end if;
        check_time_window((target = exp), now - C_START_TIME, min_time, max_time, alert_level, v_proc_call.all, success, msg, scope, msg_id, msg_id_panel);
      end if;

    else
      alert(alert_level, v_proc_call.all & " => Failed. Widths did not match. " & add_msg_delimiter(msg), scope);
      success := false;
    end if;
    DEALLOCATE(v_proc_call);
  end procedure;

  procedure await_value(
    signal target             : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := SKIP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  ) is
    variable v_success : boolean;
  begin
    await_value(target, exp, match_strictness, min_time, max_time, alert_level, v_success, msg, scope, radix, format, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : std_logic_vector;
    constant exp          : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, MATCH_STD, min_time, max_time, alert_level, msg, scope, radix, format, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : unsigned;
    constant exp          : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE : string := "unsigned";
    constant C_START_TIME : time   := now;
    constant C_EXP_STR    : string := to_string(exp, radix, format, INCL_RADIX);
    constant C_NAME       : string := "await_value(" & C_VALUE_TYPE & " " & C_EXP_STR & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
  begin
    -- AS_IS format has been deprecated and will be removed in the near future
    if format = AS_IS then
      deprecate(get_procedure_name_from_instance_name(target'instance_name), "format 'AS_IS' has been deprecated. Use KEEP_LEADING_0.");
    end if;

    if matching_widths(target, exp) then
      if not matching_values(target, exp) then
        wait until matching_values(target, exp) for max_time;
      end if;
      check_time_window(matching_values(target, exp), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
    else
      alert(alert_level, C_NAME & " => Failed. Widths did not match. " & add_msg_delimiter(msg), scope);
    end if;
  end procedure;

  procedure await_value(
    signal target         : signed;
    constant exp          : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE : string := "signed";
    constant C_START_TIME : time   := now;
    constant C_EXP_STR    : string := to_string(exp, radix, format, INCL_RADIX);
    constant C_NAME       : string := "await_value(" & C_VALUE_TYPE & " " & C_EXP_STR & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
  begin
    -- AS_IS format has been deprecated and will be removed in the near future
    if format = AS_IS then
      deprecate(get_procedure_name_from_instance_name(target'instance_name), "format 'AS_IS' has been deprecated. Use KEEP_LEADING_0.");
    end if;

    if matching_widths(target, exp) then
      if not matching_values(target, exp) then
        wait until matching_values(target, exp) for max_time;
      end if;
      check_time_window(matching_values(target, exp), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
    else
      alert(alert_level, C_NAME & " => Failed. Widths did not match. " & add_msg_delimiter(msg), scope);
    end if;
  end procedure;

  procedure await_value(
    signal target         : integer;
    constant exp          : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE : string := "integer";
    constant C_START_TIME : time   := now;
    constant C_NAME       : string := "await_value(" & C_VALUE_TYPE & " " & to_string(exp) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
  begin
    if (target /= exp) then
      wait until (target = exp) for max_time;
    end if;
    check_time_window((target = exp), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : real;
    constant exp          : real;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE : string := "real";
    constant C_START_TIME : time   := now;
    constant C_NAME       : string := "await_value(" & C_VALUE_TYPE & " " & to_string(exp) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
  begin
    if (target /= exp) then
      wait until (target = exp) for max_time;
    end if;
    check_time_window((target = exp), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure;

  -- Await Value Overloads without alert_level
  procedure await_value(
    signal target         : boolean;
    constant exp          : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target             : std_logic;
    constant exp              : std_logic;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, match_strictness, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : std_logic;
    constant exp          : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target             : std_logic_vector;
    constant exp              : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant radix            : t_radix        := HEX_BIN_IF_INVALID;
    constant format           : t_format_zeros := SKIP_LEADING_0;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, match_strictness, min_time, max_time, error, msg, scope, radix, format, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : std_logic_vector;
    constant exp          : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, min_time, max_time, error, msg, scope, radix, format, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : unsigned;
    constant exp          : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, min_time, max_time, error, msg, scope, radix, format, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : signed;
    constant exp          : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant radix        : t_radix        := HEX_BIN_IF_INVALID;
    constant format       : t_format_zeros := SKIP_LEADING_0;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, min_time, max_time, error, msg, scope, radix, format, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : integer;
    constant exp          : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_value(
    signal target         : real;
    constant exp          : real;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_value(target, exp, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  -- Await Change to Value
  -- Wait until target to change (regardless of value) and then wait until it changes to the expected value
  -- Unlike await_value, this procedure is a non fall-through procedure and requires the signal to change before it can check the value  

  -- main std_logic version (cannot be sendt into std_logic_vector bc of signal)
  procedure await_change_to_value(
    signal target             : std_logic;
    constant exp_value        : std_logic;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant value_type       : string         := "std_logic"
  ) is
    constant C_START_TIME        : time    := now;
    constant C_NAME              : string  := "await_change_to_value(" & value_type & " " & to_string(exp_value) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_no_alert_min_time : boolean := true;
    variable v_ch_to_exp_value   : boolean := false;
    variable v_match             : boolean := false;
  begin
    while (now - C_START_TIME) < min_time loop
      wait on target for min_time - (now - C_START_TIME);
      v_match             := check_value(target, exp_value, match_strictness, NO_ALERT, "check_value within: " & C_NAME, scope);
      v_no_alert_min_time := not (target'event and v_match); -- false (alert) if change to exp_value occurred before min_time
      exit when (target'event and v_match);
    end loop;

    if v_no_alert_min_time then -- only check for value if no change before min_time
      -- loops until target changes to exp_value or max_time is reached (breaks loop if target changes to exp_value)
      while (max_time - (now - C_START_TIME)) > 0 ns loop
        wait on target for max_time - (now - C_START_TIME);
        v_match := check_value(target, exp_value, match_strictness, NO_ALERT, "check_value within: " & C_NAME, scope);
        if target'event and v_match then
          v_ch_to_exp_value := true;
          exit;
        end if;
      end loop;
    end if;

    -- logging
    check_time_window((v_no_alert_min_time and v_ch_to_exp_value), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non strict match version
  procedure await_change_to_value(
    signal target         : std_logic;
    constant exp_value    : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, MATCH_EXACT, min_time, max_time, alert_level, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non strict match & alert_level version
  procedure await_change_to_value(
    signal target         : std_logic;
    constant exp_value    : std_logic;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, MATCH_EXACT, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non alert_level version
  procedure await_change_to_value(
    signal target             : std_logic;
    constant exp_value        : std_logic;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, match_strictness, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- main std_logic_vector version
  procedure await_change_to_value(
    signal target             : std_logic_vector;
    constant exp_value        : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant alert_level      : t_alert_level;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel;
    constant value_type       : string         := "std_logic_vector"
  ) is
    constant C_START_TIME        : time    := now;
    constant C_NAME              : string  := "await_change_to_value(" & value_type & " " & to_string(exp_value) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_no_alert_min_time : boolean := true;
    variable v_ch_to_exp_value   : boolean := false;
    variable v_match             : boolean := false;
  begin
    while (now - C_START_TIME) < min_time loop
      wait on target for min_time;
      v_match             := check_value(target, exp_value, match_strictness, NO_ALERT, "check_value within: " & C_NAME, scope);
      v_no_alert_min_time := not (target'event and v_match); -- false (alert) if change to exp_value occurred before min_time
      exit when (target'event and (target = exp_value));
    end loop;

    if v_no_alert_min_time then -- only check for value if no change before min_time
      -- loops until target changes to exp_value or max_time is reached (breaks loop if target changes to exp_value)
      while (max_time - (now - C_START_TIME)) > 0 ns loop
        wait on target for max_time - (now - C_START_TIME);
        v_match := check_value(target, exp_value, match_strictness, NO_ALERT, "check_value within: " & C_NAME, scope);
        if target'event and v_match then
          v_ch_to_exp_value := true;
          exit;
        end if;
      end loop;
    end if;

    -- logging
    check_time_window((v_no_alert_min_time and v_ch_to_exp_value), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non strict match version
  procedure await_change_to_value(
    signal target         : std_logic_vector;
    constant exp_value    : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, MATCH_EXACT, min_time, max_time, alert_level, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non alert_level version
  procedure await_change_to_value(
    signal target             : std_logic_vector;
    constant exp_value        : std_logic_vector;
    constant match_strictness : t_match_strictness;
    constant min_time         : time;
    constant max_time         : time;
    constant msg              : string;
    constant scope            : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id           : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel     : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, match_strictness, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non strict match & alert_level version
  procedure await_change_to_value(
    signal target         : std_logic_vector;
    constant exp_value    : std_logic_vector;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, MATCH_EXACT, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- main boolean version
  procedure await_change_to_value(
    signal target      : boolean;
    constant exp_value : boolean;
    -- match_strictness does not apply to boolean (and will result in an error if used on boolean)
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "boolean"
  ) is
    constant C_START_TIME        : time    := now;
    constant C_NAME              : string  := "await_change_to_value(" & value_type & " " & to_string(exp_value) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_no_alert_min_time : boolean := true;
    variable v_ch_to_exp_value   : boolean := false;
    variable v_match             : boolean := false;
  begin
    while (now - C_START_TIME) < min_time loop
      wait on target for min_time - (now - C_START_TIME);
      v_match             := (target = exp_value);
      v_no_alert_min_time := not (target'event and v_match); -- false (alert) if change to exp_value occurred before min_time
      exit when (target'event and (target = exp_value));
    end loop;

    if v_no_alert_min_time then
      while (max_time - (now - C_START_TIME)) > 0 ns loop
        wait on target for max_time - (now - C_START_TIME);
        v_match := (target = exp_value);
        if target'event and v_match then
          v_ch_to_exp_value := true;
          exit;
        end if;
      end loop;
    end if;

    -- logging
    check_time_window((v_no_alert_min_time and v_ch_to_exp_value), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non alert_level version
  procedure await_change_to_value(
    signal target         : boolean;
    constant exp_value    : boolean;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- main unsigned version
  procedure await_change_to_value(
    signal target         : unsigned;
    constant exp_value    : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "unsigned"
  ) is
    constant C_START_TIME        : time    := now;
    constant C_NAME              : string  := "await_change_to_value(" & value_type & " " & to_string(exp_value) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_no_alert_min_time : boolean := true;
    variable v_ch_to_exp_value   : boolean := false;
    variable v_match             : boolean := false;
  begin
    while (now - C_START_TIME) < min_time loop
      wait on target for min_time - (now - C_START_TIME);
      v_match             := matching_values(target, exp_value);
      v_no_alert_min_time := not (target'event and v_match); -- false (alert) if change to exp_value occurred before min_time
      exit when (target'event and v_match);
    end loop;

    if v_no_alert_min_time then
      while (max_time - (now - C_START_TIME)) > 0 ns loop
        wait on target for max_time - (now - C_START_TIME);
        v_match := matching_values(target, exp_value);
        if target'event and v_match then
          v_ch_to_exp_value := true;
          exit;
        end if;
      end loop;
    end if;

    -- logging
    check_time_window((v_no_alert_min_time and v_ch_to_exp_value), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non alert_level version
  procedure await_change_to_value(
    signal target         : unsigned;
    constant exp_value    : unsigned;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- main signed version
  procedure await_change_to_value(
    signal target         : signed;
    constant exp_value    : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "signed"
  ) is
    constant C_START_TIME        : time    := now;
    constant C_NAME              : string  := "await_change_to_value(" & value_type & " " & to_string(exp_value) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_no_alert_min_time : boolean := true;
    variable v_ch_to_exp_value   : boolean := false;
    variable v_match             : boolean := false;
  begin
    while (now - C_START_TIME) < min_time loop
      wait on target for min_time - (now - C_START_TIME);
      v_match             := matching_values(target, exp_value);
      v_no_alert_min_time := not (target'event and v_match); -- false (alert) if change to exp_value occurred before min_time
      exit when (target'event and v_match);
    end loop;

    if v_no_alert_min_time then
      while (max_time - (now - C_START_TIME)) > 0 ns loop
        wait on target for max_time - (now - C_START_TIME);
        v_match := matching_values(target, exp_value);
        if target'event and v_match then
          v_ch_to_exp_value := true;
          exit;
        end if;
      end loop;
    end if;

    -- logging
    check_time_window((v_no_alert_min_time and v_ch_to_exp_value), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non alert_level version
  procedure await_change_to_value(
    signal target         : signed;
    constant exp_value    : signed;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- main integer version
  procedure await_change_to_value(
    signal target         : integer;
    constant exp_value    : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "integer"
  ) is
    constant C_START_TIME        : time    := now;
    constant C_NAME              : string  := "await_change_to_value(" & value_type & " " & to_string(exp_value) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_no_alert_min_time : boolean := true;
    variable v_ch_to_exp_value   : boolean := false;
    variable v_match             : boolean := false;
  begin
    while (now - C_START_TIME) < min_time loop
      wait on target for min_time - (now - C_START_TIME);
      v_match             := (target = exp_value);
      v_no_alert_min_time := not (target'event and v_match); -- false (alert) if change to exp_value occurred before min_time
      exit when (target'event and v_match);
    end loop;

    if v_no_alert_min_time then -- only check for value if no change before min_time
      -- loops until target changes to exp_value or max_time is reached (breaks loop if target changes to exp_value)
      while (max_time - (now - C_START_TIME)) > 0 ns loop
        wait on target for max_time - (now - C_START_TIME);
        v_match := (target = exp_value);
        if target'event and v_match then
          v_ch_to_exp_value := true;
          exit;
        end if;
      end loop;
    end if;

    -- logging
    check_time_window((v_no_alert_min_time and v_ch_to_exp_value), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non alert_level version
  procedure await_change_to_value(
    signal target         : integer;
    constant exp_value    : integer;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- main real version
  procedure await_change_to_value(
    signal target         : real;
    constant exp_value    : real;
    constant min_time     : time;
    constant max_time     : time;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant value_type   : string         := "real"
  ) is
    constant C_START_TIME        : time    := now;
    constant C_NAME              : string  := "await_change_to_value(" & value_type & " " & to_string(exp_value) & ", " & to_string(min_time, ns) & ", " & to_string(max_time, ns) & ")";
    variable v_no_alert_min_time : boolean := true;
    variable v_ch_to_exp_value   : boolean := false;
    variable v_match             : boolean := false;
  begin
    while (now - C_START_TIME) < min_time loop
      wait on target for min_time - (now - C_START_TIME);
      v_match             := (target = exp_value);
      v_no_alert_min_time := not (target'event and v_match); -- false (alert) if change to exp_value occurred before min_time
      exit when (target'event and v_match);
    end loop;

    if v_no_alert_min_time then -- only check for value if no change before min_time
      -- loops until target changes to exp_value or max_time is reached (breaks loop if target changes to exp_value)
      while (max_time - (now - C_START_TIME)) > 0 ns loop
        wait on target for max_time - (now - C_START_TIME);
        v_match := (target = exp_value);
        if target'event and v_match then
          v_ch_to_exp_value := true;
          exit;
        end if;
      end loop;
    end if;

    -- logging
    check_time_window((v_no_alert_min_time and v_ch_to_exp_value), now - C_START_TIME, min_time, max_time, alert_level, C_NAME, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- non alert_level version
  procedure await_change_to_value(
    signal target         : real;
    constant exp_value    : real;
    constant min_time     : time;
    constant max_time     : time;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_change_to_value(target, exp_value, min_time, max_time, error, msg, scope, msg_id, msg_id_panel);
  end procedure await_change_to_value;

  -- Helper procedure:
  -- Convert time from 'FROM_LAST_EVENT' to 'FROM_NOW'
  procedure await_stable_calc_time(
    constant target_last_event               : in time;
    constant stable_req                      : in time; -- Minimum stable requirement
    constant stable_req_from                 : in t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout                         : in time; -- Timeout if stable_req not achieved
    constant timeout_from                    : in t_from_point_in_time; -- Which point in time the timeout starts
    variable stable_req_from_now             : inout time; -- Calculated stable requirement from now
    variable timeout_from_await_stable_entry : inout time; -- Calculated timeout from procedure entry
    constant alert_level                     : in t_alert_level;
    constant msg                             : in string;
    constant scope                           : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id                          : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel                    : in t_msg_id_panel := shared_msg_id_panel;
    constant caller_name                     : in string         := "await_stable_calc_time()";
    variable stable_req_met                  : inout boolean; -- When true, the stable requirement is satisfied
    variable stable_req_success              : out boolean
  ) is
  begin
    stable_req_met     := false;
    stable_req_success := true;

    -- Convert stable_req so that it points to "time_from_now"
    if stable_req_from = FROM_NOW then
      stable_req_from_now := stable_req;
    elsif stable_req_from = FROM_LAST_EVENT then
      -- Signal has already been stable for target'last_event,
      -- so we can subtract this in the FROM_NOW version.
      stable_req_from_now := stable_req - target_last_event;
    else
      alert(tb_error, caller_name & " => Unknown stable_req_from. " & add_msg_delimiter(msg), scope);
      stable_req_success := false;
    end if;

    -- Convert timeout so that it points to "time_from_now"
    if timeout_from = FROM_NOW then
      timeout_from_await_stable_entry := timeout;
    elsif timeout_from = FROM_LAST_EVENT then
      timeout_from_await_stable_entry := timeout - target_last_event;
    else
      alert(tb_error, caller_name & " => Unknown timeout_from. " & add_msg_delimiter(msg), scope);
      stable_req_success := false;
    end if;

    -- Check if requirement is already OK
    if (stable_req_from_now <= 0 ns) then
      log(msg_id, caller_name & " => OK. Condition occurred immediately. " & add_msg_delimiter(msg), scope, msg_id_panel);
      stable_req_met := true;
    end if;

    -- Check if it is impossible to achieve stable_req before timeout
    if (stable_req_from_now > timeout_from_await_stable_entry) then
      alert(alert_level, caller_name & " => Failed immediately: Stable for stable_req = " & to_string(stable_req_from_now, ns) & " is not possible before timeout = " & to_string(timeout_from_await_stable_entry, ns) & ". " & add_msg_delimiter(msg), scope);
      stable_req_met     := true;
      stable_req_success := false;
    end if;
  end procedure;

  procedure await_stable_calc_time(
    constant target_last_event               : time;
    constant stable_req                      : time; -- Minimum stable requirement
    constant stable_req_from                 : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout                         : time; -- Timeout if stable_req not achieved
    constant timeout_from                    : t_from_point_in_time; -- Which point in time the timeout starts
    variable stable_req_from_now             : inout time; -- Calculated stable requirement from now
    variable timeout_from_await_stable_entry : inout time; -- Calculated timeout from procedure entry
    constant alert_level                     : t_alert_level;
    constant msg                             : string;
    constant scope                           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id                          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel                    : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name                     : string         := "await_stable_calc_time()";
    variable stable_req_met                  : inout boolean -- When true, the stable requirement is satisfied
  ) is
    variable v_stable_req_success : boolean;
  begin
    await_stable_calc_time(target_last_event, stable_req, stable_req_from, timeout, timeout_from, stable_req_from_now,
    timeout_from_await_stable_entry, alert_level, msg, scope, msg_id, msg_id_panel, caller_name, stable_req_met, v_stable_req_success);
  end procedure;

  -- Helper procedure:
  procedure await_stable_checks(
    constant start_time                      : in time; -- Time at await_stable() procedure entry
    constant stable_req                      : in time; -- Minimum stable requirement
    variable stable_req_from_now             : inout time; -- Minimum stable requirement from now
    variable timeout_from_await_stable_entry : inout time; -- Timeout value converted to FROM_NOW
    constant time_since_last_event           : in time; -- Time since previous event
    constant alert_level                     : in t_alert_level;
    constant msg                             : in string;
    constant scope                           : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id                          : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel                    : in t_msg_id_panel := shared_msg_id_panel;
    constant caller_name                     : in string         := "await_stable_checks()";
    variable stable_req_met                  : inout boolean; -- When true, the stable requirement is satisfied
    variable stable_req_success              : out boolean
  ) is
    variable v_time_left    : time; -- Remaining time until timeout
    variable v_elapsed_time : time := 0 ns; -- Time since procedure entry
  begin
    stable_req_met := false;
    v_elapsed_time := now - start_time;
    v_time_left    := timeout_from_await_stable_entry - v_elapsed_time;

    -- Check if target has been stable for stable_req
    if (time_since_last_event >= stable_req_from_now) then
      log(msg_id, caller_name & " => OK. Condition occurred after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      stable_req_met     := true;
      stable_req_success := true;
    end if;

    --
    -- Prepare for the next iteration in the loop in await_stable() procedure:
    --
    if not stable_req_met then

      -- Now that an event has occurred, the stable requirement is stable_req from now (regardless of stable_req_from)
      stable_req_from_now := stable_req;

      -- Check if it is impossible to achieve stable_req before timeout
      if (stable_req_from_now > v_time_left) then
        alert(alert_level, caller_name & " => Failed. After " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ", stable for stable_req = " & to_string(stable_req_from_now, ns) & " is not possible before timeout = " & to_string(timeout_from_await_stable_entry, ns) & "(time since last event = " & to_string(time_since_last_event, ns) & ". " & add_msg_delimiter(msg), scope);
        stable_req_met     := true;
        stable_req_success := false;
      end if;
    end if;
  end procedure;

  procedure await_stable_checks(
    constant start_time                      : time; -- Time at await_stable() procedure entry
    constant stable_req                      : time; -- Minimum stable requirement
    variable stable_req_from_now             : inout time; -- Minimum stable requirement from now
    variable timeout_from_await_stable_entry : inout time; -- Timeout value converted to FROM_NOW
    constant time_since_last_event           : time; -- Time since previous event
    constant alert_level                     : t_alert_level;
    constant msg                             : string;
    constant scope                           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id                          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel                    : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name                     : string         := "await_stable_checks()";
    variable stable_req_met                  : inout boolean -- When true, the stable requirement is satisfied
  ) is
    variable v_stable_req_success : boolean;
  begin
    await_stable_checks(start_time, stable_req, stable_req_from_now, timeout_from_await_stable_entry, time_since_last_event,
    alert_level, msg, scope, msg_id, msg_id_panel, caller_name, stable_req_met, v_stable_req_success);
  end procedure;

  -- Await Stable Procedures
  -- Wait until the target signal has been stable for at least 'stable_req'
  -- Report an error if this does not occurr within the time specified by 'timeout'.
  -- Note : 'Stable' refers to that the signal has not had an event (i.e. not changed value).
  -- Description of arguments:
  -- stable_req_from = FROM_NOW        : Target must be stable 'stable_req' from now
  -- stable_req_from = FROM_LAST_EVENT : Target must be stable 'stable_req' from the last event of target.
  -- timeout_from    = FROM_NOW        : The timeout argument is given in time from now
  -- timeout_from    = FROM_LAST_EVENT : The timeout argument is given in time the last event of target.
  procedure await_stable(
    signal target            : boolean;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE              : string := "boolean";
    constant C_START_TIME              : time   := now;
    constant C_NAME                    : string := "await_stable(" & C_VALUE_TYPE & ", " & to_string(stable_req, ns) & ", " & to_string(timeout, ns) & ")";
    variable v_stable_req_from_now     : time; -- Stable_req relative to now.
    variable v_timeout_from_proc_entry : time; -- Timeout relative to time of procedure entry
    variable v_stable_req_met          : boolean := false; -- When true, the procedure is done and has logged a conclusion.
  begin
    -- Use a helper procedure to simplify overloading
    await_stable_calc_time(
    target_last_event               => target'last_event,
    stable_req                      => stable_req,
    stable_req_from                 => stable_req_from,
    timeout                         => timeout,
    timeout_from                    => timeout_from,
    stable_req_from_now             => v_stable_req_from_now,
    timeout_from_await_stable_entry => v_timeout_from_proc_entry,
    alert_level                     => alert_level,
    msg                             => msg,
    scope                           => scope,
    msg_id                          => msg_id,
    msg_id_panel                    => msg_id_panel,
    caller_name                     => C_NAME,
    stable_req_met                  => v_stable_req_met);

    -- Start waiting for target'event or stable_req time, unless :
    --  - stable_req already achieved, or
    --  - it is already too late to be stable for stable_req before timeout will occurr
    while not v_stable_req_met loop
      wait until target'event for v_stable_req_from_now;

      -- Use a helper procedure to simplify overloading
      await_stable_checks(
      start_time                      => C_START_TIME,
      stable_req                      => stable_req,
      stable_req_from_now             => v_stable_req_from_now,
      timeout_from_await_stable_entry => v_timeout_from_proc_entry,
      time_since_last_event           => target'last_event,
      alert_level                     => alert_level,
      msg                             => msg,
      scope                           => scope,
      msg_id                          => msg_id,
      msg_id_panel                    => msg_id_panel,
      caller_name                     => C_NAME,
      stable_req_met                  => v_stable_req_met);

    end loop;
  end procedure;

  -- Note that the waiting for target'event can't be called from overloaded procedures where 'target' is a different type.
  -- Instead, the common code is put in helper procedures
  procedure await_stable(
    signal target            : std_logic;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE              : string := "std_logic";
    constant C_START_TIME              : time   := now;
    constant C_NAME                    : string := "await_stable(" & C_VALUE_TYPE & ", " & to_string(stable_req, ns) & ", " & to_string(timeout, ns) & ")";
    variable v_stable_req_from_now     : time; -- Stable_req relative to now.
    variable v_timeout_from_proc_entry : time; -- Timeout relative to time of procedure entry
    variable v_stable_req_met          : boolean := false; -- When true, the procedure is done and has logged a conclusion.
  begin
    -- Use a helper procedure to simplify overloading
    await_stable_calc_time(
    target_last_event               => target'last_event,
    stable_req                      => stable_req,
    stable_req_from                 => stable_req_from,
    timeout                         => timeout,
    timeout_from                    => timeout_from,
    stable_req_from_now             => v_stable_req_from_now,
    timeout_from_await_stable_entry => v_timeout_from_proc_entry,
    alert_level                     => alert_level,
    msg                             => msg,
    scope                           => scope,
    msg_id                          => msg_id,
    msg_id_panel                    => msg_id_panel,
    caller_name                     => C_NAME,
    stable_req_met                  => v_stable_req_met);

    -- Start waiting for target'event or stable_req time, unless :
    --  - stable_req already achieved, or
    --  - it is already too late to be stable for stable_req before timeout will occurr
    while not v_stable_req_met loop
      wait until target'event for v_stable_req_from_now;

      -- Use a helper procedure to simplify overloading
      await_stable_checks(
      start_time                      => C_START_TIME,
      stable_req                      => stable_req,
      stable_req_from_now             => v_stable_req_from_now,
      timeout_from_await_stable_entry => v_timeout_from_proc_entry,
      time_since_last_event           => target'last_event,
      alert_level                     => alert_level,
      msg                             => msg,
      scope                           => scope,
      msg_id                          => msg_id,
      msg_id_panel                    => msg_id_panel,
      caller_name                     => C_NAME,
      stable_req_met                  => v_stable_req_met);

    end loop;
  end procedure;

  procedure await_stable(
    signal target            : in std_logic_vector;
    constant stable_req      : in time; -- Minimum stable requirement
    constant stable_req_from : in t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : in time; -- Timeout if stable_req not achieved
    constant timeout_from    : in t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : in t_alert_level;
    variable success         : out boolean;
    constant msg             : in string;
    constant scope           : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : in t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : in t_msg_id_panel := shared_msg_id_panel;
    constant caller_name     : in string         := ""
  ) is
    constant C_VALUE_TYPE              : string := "std_logic_vector";
    constant C_START_TIME              : time   := now;
    constant C_NAME                    : string := "await_stable(" & C_VALUE_TYPE & ", " & to_string(stable_req, ns) & ", " & to_string(timeout, ns) & ")";
    variable v_stable_req_from_now     : time; -- Stable_req relative to now.
    variable v_timeout_from_proc_entry : time; -- Timeout relative to time of procedure entry
    variable v_stable_req_met          : boolean := false; -- When true, the procedure is done and has logged a conclusion.
    variable v_proc_call               : line;
  begin
    if caller_name'length = 0 then
      write(v_proc_call, C_NAME);
    else
      write(v_proc_call, caller_name);
    end if;

    -- Use a helper procedure to simplify overloading
    await_stable_calc_time(
    target_last_event               => target'last_event,
    stable_req                      => stable_req,
    stable_req_from                 => stable_req_from,
    timeout                         => timeout,
    timeout_from                    => timeout_from,
    stable_req_from_now             => v_stable_req_from_now,
    timeout_from_await_stable_entry => v_timeout_from_proc_entry,
    alert_level                     => alert_level,
    msg                             => msg,
    scope                           => scope,
    msg_id                          => msg_id,
    msg_id_panel                    => msg_id_panel,
    caller_name                     => v_proc_call.all,
    stable_req_met                  => v_stable_req_met,
    stable_req_success              => success);

    -- Start waiting for target'event or stable_req time, unless :
    --  - stable_req already achieved, or
    --  - it is already too late to be stable for stable_req before timeout will occurr
    while not v_stable_req_met loop
      wait until target'event for v_stable_req_from_now;
      -- Use a helper procedure to simplify overloading
      await_stable_checks(
      start_time                      => C_START_TIME,
      stable_req                      => stable_req,
      stable_req_from_now             => v_stable_req_from_now,
      timeout_from_await_stable_entry => v_timeout_from_proc_entry,
      time_since_last_event           => target'last_event,
      alert_level                     => alert_level,
      msg                             => msg,
      scope                           => scope,
      msg_id                          => msg_id,
      msg_id_panel                    => msg_id_panel,
      caller_name                     => v_proc_call.all,
      stable_req_met                  => v_stable_req_met,
      stable_req_success              => success);
    end loop;

    DEALLOCATE(v_proc_call);
  end procedure;

  procedure await_stable(
    signal target            : std_logic_vector;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
    variable v_success : boolean;
  begin
    await_stable(target, stable_req, stable_req_from, timeout, timeout_from, alert_level, v_success, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_stable(
    signal target            : unsigned;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE              : string := "unsigned";
    constant C_START_TIME              : time   := now;
    constant C_NAME                    : string := "await_stable(" & C_VALUE_TYPE & ", " & to_string(stable_req, ns) & ", " & to_string(timeout, ns) & ")";
    variable v_stable_req_from_now     : time; -- Stable_req relative to now.
    variable v_timeout_from_proc_entry : time; -- Timeout relative to time of procedure entry
    variable v_stable_req_met          : boolean := false; -- When true, the procedure is done and has logged a conclusion.
  begin
    -- Use a helper procedure to simplify overloading
    await_stable_calc_time(
    target_last_event               => target'last_event,
    stable_req                      => stable_req,
    stable_req_from                 => stable_req_from,
    timeout                         => timeout,
    timeout_from                    => timeout_from,
    stable_req_from_now             => v_stable_req_from_now,
    timeout_from_await_stable_entry => v_timeout_from_proc_entry,
    alert_level                     => alert_level,
    msg                             => msg,
    scope                           => scope,
    msg_id                          => msg_id,
    msg_id_panel                    => msg_id_panel,
    caller_name                     => C_NAME,
    stable_req_met                  => v_stable_req_met);

    -- Start waiting for target'event or stable_req time, unless :
    --  - stable_req already achieved, or
    --  - it is already too late to be stable for stable_req before timeout will occurr
    while not v_stable_req_met loop
      wait until target'event for v_stable_req_from_now;

      -- Use a helper procedure to simplify overloading
      await_stable_checks(
      start_time                      => C_START_TIME,
      stable_req                      => stable_req,
      stable_req_from_now             => v_stable_req_from_now,
      timeout_from_await_stable_entry => v_timeout_from_proc_entry,
      time_since_last_event           => target'last_event,
      alert_level                     => alert_level,
      msg                             => msg,
      scope                           => scope,
      msg_id                          => msg_id,
      msg_id_panel                    => msg_id_panel,
      caller_name                     => C_NAME,
      stable_req_met                  => v_stable_req_met);

    end loop;
  end procedure;

  procedure await_stable(
    signal target            : signed;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE              : string := "signed";
    constant C_START_TIME              : time   := now;
    constant C_NAME                    : string := "await_stable(" & C_VALUE_TYPE & ", " & to_string(stable_req, ns) & ", " & to_string(timeout, ns) & ")";
    variable v_stable_req_from_now     : time; -- Stable_req relative to now.
    variable v_timeout_from_proc_entry : time; -- Timeout relative to time of procedure entry
    variable v_stable_req_met          : boolean := false; -- When true, the procedure is done and has logged a conclusion.
  begin
    -- Use a helper procedure to simplify overloading
    await_stable_calc_time(
    target_last_event               => target'last_event,
    stable_req                      => stable_req,
    stable_req_from                 => stable_req_from,
    timeout                         => timeout,
    timeout_from                    => timeout_from,
    stable_req_from_now             => v_stable_req_from_now,
    timeout_from_await_stable_entry => v_timeout_from_proc_entry,
    alert_level                     => alert_level,
    msg                             => msg,
    scope                           => scope,
    msg_id                          => msg_id,
    msg_id_panel                    => msg_id_panel,
    caller_name                     => C_NAME,
    stable_req_met                  => v_stable_req_met);

    -- Start waiting for target'event or stable_req time, unless :
    --  - stable_req already achieved, or
    --  - it is already too late to be stable for stable_req before timeout will occurr
    while not v_stable_req_met loop
      wait until target'event for v_stable_req_from_now;

      -- Use a helper procedure to simplify overloading
      await_stable_checks(
      start_time                      => C_START_TIME,
      stable_req                      => stable_req,
      stable_req_from_now             => v_stable_req_from_now,
      timeout_from_await_stable_entry => v_timeout_from_proc_entry,
      time_since_last_event           => target'last_event,
      alert_level                     => alert_level,
      msg                             => msg,
      scope                           => scope,
      msg_id                          => msg_id,
      msg_id_panel                    => msg_id_panel,
      caller_name                     => C_NAME,
      stable_req_met                  => v_stable_req_met);

    end loop;
  end procedure;

  procedure await_stable(
    signal target            : integer;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE              : string := "integer";
    constant C_START_TIME              : time   := now;
    constant C_NAME                    : string := "await_stable(" & C_VALUE_TYPE & ", " & to_string(stable_req, ns) & ", " & to_string(timeout, ns) & ")";
    variable v_stable_req_from_now     : time; -- Stable_req relative to now.
    variable v_timeout_from_proc_entry : time; -- Timeout relative to time of procedure entry
    variable v_stable_req_met          : boolean := false; -- When true, the procedure is done and has logged a conclusion.
  begin
    -- Use a helper procedure to simplify overloading
    await_stable_calc_time(
    target_last_event               => target'last_event,
    stable_req                      => stable_req,
    stable_req_from                 => stable_req_from,
    timeout                         => timeout,
    timeout_from                    => timeout_from,
    stable_req_from_now             => v_stable_req_from_now,
    timeout_from_await_stable_entry => v_timeout_from_proc_entry,
    alert_level                     => alert_level,
    msg                             => msg,
    scope                           => scope,
    msg_id                          => msg_id,
    msg_id_panel                    => msg_id_panel,
    caller_name                     => C_NAME,
    stable_req_met                  => v_stable_req_met);

    -- Start waiting for target'event or stable_req time, unless :
    --  - stable_req already achieved, or
    --  - it is already too late to be stable for stable_req before timeout will occur
    while not v_stable_req_met loop
      wait until target'event for v_stable_req_from_now;

      -- Use a helper procedure to simplify overloading
      await_stable_checks(
      start_time                      => C_START_TIME,
      stable_req                      => stable_req,
      stable_req_from_now             => v_stable_req_from_now,
      timeout_from_await_stable_entry => v_timeout_from_proc_entry,
      time_since_last_event           => target'last_event,
      alert_level                     => alert_level,
      msg                             => msg,
      scope                           => scope,
      msg_id                          => msg_id,
      msg_id_panel                    => msg_id_panel,
      caller_name                     => C_NAME,
      stable_req_met                  => v_stable_req_met);

    end loop;
  end procedure;

  procedure await_stable(
    signal target            : real;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant alert_level     : t_alert_level;
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_VALUE_TYPE              : string := "real";
    constant C_START_TIME              : time   := now;
    constant C_NAME                    : string := "await_stable(" & C_VALUE_TYPE & ", " & to_string(stable_req, ns) & ", " & to_string(timeout, ns) & ")";
    variable v_stable_req_from_now     : time; -- Stable_req relative to now.
    variable v_timeout_from_proc_entry : time; -- Timeout relative to time of procedure entry
    variable v_stable_req_met          : boolean := false; -- When true, the procedure is done and has logged a conclusion.
  begin
    -- Use a helper procedure to simplify overloading
    await_stable_calc_time(
    target_last_event               => target'last_event,
    stable_req                      => stable_req,
    stable_req_from                 => stable_req_from,
    timeout                         => timeout,
    timeout_from                    => timeout_from,
    stable_req_from_now             => v_stable_req_from_now,
    timeout_from_await_stable_entry => v_timeout_from_proc_entry,
    alert_level                     => alert_level,
    msg                             => msg,
    scope                           => scope,
    msg_id                          => msg_id,
    msg_id_panel                    => msg_id_panel,
    caller_name                     => C_NAME,
    stable_req_met                  => v_stable_req_met);

    -- Start waiting for target'event or stable_req time, unless :
    --  - stable_req already achieved, or
    --  - it is already too late to be stable for stable_req before timeout will occur
    while not v_stable_req_met loop
      wait until target'event for v_stable_req_from_now;

      -- Use a helper procedure to simplify overloading
      await_stable_checks(
      start_time                      => C_START_TIME,
      stable_req                      => stable_req,
      stable_req_from_now             => v_stable_req_from_now,
      timeout_from_await_stable_entry => v_timeout_from_proc_entry,
      time_since_last_event           => target'last_event,
      alert_level                     => alert_level,
      msg                             => msg,
      scope                           => scope,
      msg_id                          => msg_id,
      msg_id_panel                    => msg_id_panel,
      caller_name                     => C_NAME,
      stable_req_met                  => v_stable_req_met);

    end loop;
  end procedure;

  -- Procedure overloads for await_stable() without mandatory Alert_Level
  procedure await_stable(
    signal target            : boolean;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_stable(target, stable_req, stable_req_from, timeout, timeout_from, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_stable(
    signal target            : std_logic;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_stable(target, stable_req, stable_req_from, timeout, timeout_from, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_stable(
    signal target            : std_logic_vector;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_stable(target, stable_req, stable_req_from, timeout, timeout_from, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_stable(
    signal target            : unsigned;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_stable(target, stable_req, stable_req_from, timeout, timeout_from, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_stable(
    signal target            : signed;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_stable(target, stable_req, stable_req_from, timeout, timeout_from, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_stable(
    signal target            : integer;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_stable(target, stable_req, stable_req_from, timeout, timeout_from, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  procedure await_stable(
    signal target            : real;
    constant stable_req      : time; -- Minimum stable requirement
    constant stable_req_from : t_from_point_in_time; -- Which point in time stable_req starts
    constant timeout         : time; -- Timeout if stable_req not achieved
    constant timeout_from    : t_from_point_in_time; -- Which point in time the timeout starts
    constant msg             : string;
    constant scope           : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id          : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    await_stable(target, stable_req, stable_req_from, timeout, timeout_from, error, msg, scope, msg_id, msg_id_panel);
  end procedure;

  -- Checks whether the enabled scoreboards still have pending data, returns true if none of them have pending data
  impure function check_sb_completion(
    constant alert_level          : t_alert_level;
    constant print_alert_counters : t_report_alert_counters := NO_REPORT;
    constant print_sbs            : t_report_sb             := NO_REPORT;
    constant scope                : string                  := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel         : t_msg_id_panel          := shared_msg_id_panel;
    constant ext_proc_call        : string                  := ""
  ) return boolean is
    constant C_NAME      : string  := "check_sb_completion()";
    constant C_PRINT_LOG : boolean := ext_proc_call = ""; -- Only print log messages when called directly from sequencer
    variable v_line      : line;
    variable v_check_ok  : boolean := true;
  begin
    -- Iterate through all the enabled scoreboards
    for idx in 0 to protected_sb_activity_register.get_num_registered_sb(void) - 1 loop
      if protected_sb_activity_register.is_enabled(idx) and protected_sb_activity_register.get_sb_element_cnt(idx) > 0 then
        if C_PRINT_LOG then
          write(v_line, "  " & to_string(protected_sb_activity_register.get_sb_name(idx)) & "," & to_string(protected_sb_activity_register.get_sb_instance(idx)) & LF);
          v_check_ok := false;
        else
          return false;
        end if;
      end if;
    end loop;

    if C_PRINT_LOG then
      if not v_check_ok then
        alert(alert_level, C_NAME & " => Failed. The following UVVM scoreboard(s) still have pending data:\n" & v_line.all, scope);
        DEALLOCATE(v_line);
        return false;
      else
        if protected_sb_activity_register.get_num_enabled_sb(void) = 0 then
          log(ID_POS_ACK, C_NAME & " => OK. There are no UVVM scoreboards enabled.", scope, msg_id_panel);
        else
          log(ID_POS_ACK, C_NAME & " => OK. All UVVM scoreboards are empty.", scope, msg_id_panel);
        end if;

        -- Print reports
        if print_sbs = REPORT_SCOREBOARDS then
          report_scoreboards(void);
        end if;
        if print_alert_counters = REPORT_ALERT_COUNTERS then
          report_alert_counters(INTERMEDIATE);
        elsif print_alert_counters = REPORT_ALERT_COUNTERS_FINAL then
          report_alert_counters(FINAL);
        end if;
        deallocate(v_line);
        return true;
      end if;
    else
      return true;
    end if;
  end function;

  -- Overload
  impure function check_sb_completion(
    constant void : t_void
  ) return boolean is
  begin
    return check_sb_completion(TB_ERROR);
  end function;

  -- Overload
  procedure check_sb_completion(
    constant alert_level          : t_alert_level;
    constant print_alert_counters : t_report_alert_counters := NO_REPORT;
    constant print_sbs            : t_report_sb             := NO_REPORT;
    constant scope                : string                  := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel         : t_msg_id_panel          := shared_msg_id_panel
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_sb_completion(alert_level, print_alert_counters, print_sbs, scope, msg_id_panel);
  end procedure;

  -- Overload
  procedure check_sb_completion(
    constant void : t_void
  ) is
    variable v_check_ok : boolean;
  begin
    v_check_ok := check_sb_completion(void);
  end procedure;

  -- Waits until all the enabled scoreboards have no pending data or a timeout occurs
  procedure await_sb_completion(
    constant timeout              : time;
    constant alert_level          : t_alert_level           := TB_ERROR;
    constant sb_poll_time         : time                    := 100 us;
    constant print_alert_counters : t_report_alert_counters := NO_REPORT;
    constant print_sbs            : t_report_sb             := NO_REPORT;
    constant scope                : string                  := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel         : t_msg_id_panel          := shared_msg_id_panel;
    constant ext_proc_call        : string                  := ""
  ) is
    constant C_NAME         : string := "await_sb_completion()";
    variable v_elapsed_time : time   := 0 ns;
    variable v_line         : line;
    variable v_proc_call    : line;
  begin
    -- Called directly from sequencer
    if ext_proc_call = "" then
      write(v_proc_call, C_NAME);
      -- Called from another procedure
    else
      write(v_proc_call, ext_proc_call);
    end if;

    -- Sanity checks
    check_value(timeout > 0 ns, TB_FAILURE, "timeout must be greater than 0", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(sb_poll_time > 0 ns, TB_FAILURE, "sb_poll_time must be greater than 0", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    if timeout <= 0 ns or sb_poll_time <= 0 ns then
      return;
    end if;

    -- Wait until the scoreboards are empty or a timeout occurs
    loop
      if check_sb_completion(TB_ERROR, ext_proc_call => v_proc_call.all) or v_elapsed_time >= timeout then
        exit;
      else
        wait for sb_poll_time;
        v_elapsed_time := v_elapsed_time + sb_poll_time;
      end if;
    end loop;

    -- Print success/fail log message
    if v_elapsed_time >= timeout then
      for idx in 0 to protected_sb_activity_register.get_num_registered_sb(void) - 1 loop
        if protected_sb_activity_register.is_enabled(idx) and protected_sb_activity_register.get_sb_element_cnt(idx) > 0 then
          write(v_line, "  " & to_string(protected_sb_activity_register.get_sb_name(idx)) & "," & to_string(protected_sb_activity_register.get_sb_instance(idx)) & LF);
        end if;
      end loop;
      alert(alert_level, v_proc_call.all & " => Failed. The following UVVM scoreboard(s) still have pending data after " & to_string(v_elapsed_time, get_time_unit(v_elapsed_time)) & ":\n" & v_line.all, scope);
    else
      if protected_sb_activity_register.get_num_enabled_sb(void) = 0 then
        log(ID_AWAIT_UVVM_COMPLETION, v_proc_call.all & " => OK. There are no UVVM scoreboards enabled.", scope, msg_id_panel);
      else
        log(ID_AWAIT_UVVM_COMPLETION, v_proc_call.all & " => OK. All UVVM scoreboards are empty. Condition occurred after " & to_string(v_elapsed_time, get_time_unit(v_elapsed_time)), scope, msg_id_panel);
      end if;

      -- Print reports
      if print_sbs = REPORT_SCOREBOARDS then
        report_scoreboards(void);
      end if;
      if print_alert_counters = REPORT_ALERT_COUNTERS then
        report_alert_counters(INTERMEDIATE);
      elsif print_alert_counters = REPORT_ALERT_COUNTERS_FINAL then
        report_alert_counters(FINAL);
      end if;
    end if;
    DEALLOCATE(v_line);
    DEALLOCATE(v_proc_call);
  end procedure;

  -----------------------------------------------------------------------------------
  -- gen_pulse(sl)
  -- Generate a pulse on a std_logic for a certain amount of time
  --
  -- If blocking_mode = BLOCKING     : Procedure waits until the pulse is done before returning to the caller.
  -- If blocking_mode = NON_BLOCKING : Procedure starts the pulse, schedules the end of the pulse, then returns to the caller immediately.
  --
  procedure gen_pulse(
    signal target           : inout std_logic;
    constant pulse_value    : std_logic;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_INIT_VALUE : std_logic := target;
  begin
    check_value(target /= pulse_value, TB_ERROR, "gen_pulse: target was already " & to_string(pulse_value) & ". " & add_msg_delimiter(msg), scope, ID_NEVER);
    target <= pulse_value; -- Generate pulse

    if (blocking_mode = BLOCKING) then
      wait for pulse_duration;
      target <= C_INIT_VALUE;
    else
      check_value(pulse_duration /= 0 ns, TB_ERROR, "gen_pulse: The combination of NON_BLOCKING mode and 0 ns pulse duration results in the pulse being ignored.", scope, ID_NEVER);
      target <= transport C_INIT_VALUE after pulse_duration;
    end if;
    log(msg_id, "Pulsed to " & to_string(pulse_value) & " for " & to_string(pulse_duration) & ". " & add_msg_delimiter(msg), scope);
    wait for 0 ns; -- wait a delta cycle for signal to update
  end procedure;

  -- Overload to allow excluding the pulse_value argument:
  -- Make pulse_value = '1' by default
  procedure gen_pulse(
    signal target           : inout std_logic;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, '1', pulse_duration, blocking_mode, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- Overload to allow excluding the blocking_mode and pulse_value arguments:
  -- Make blocking_mode = BLOCKING and pulse_value = '1' by default
  procedure gen_pulse(
    signal target           : inout std_logic;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, '1', pulse_duration, BLOCKING, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- Overload to allow excluding the blocking_mode argument:
  -- Make blocking_mode = BLOCKING by default
  procedure gen_pulse(
    signal target           : inout std_logic;
    constant pulse_value    : std_logic;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, pulse_value, pulse_duration, BLOCKING, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- gen_pulse(sl)
  -- Generate a pulse on a std_logic for a certain number of clock cycles
  procedure gen_pulse(
    signal target         : inout std_logic;
    constant pulse_value  : std_logic;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_INIT_VALUE : std_logic := target;
  begin
    wait until falling_edge(clock_signal);
    check_value(target /= pulse_value, TB_ERROR, "gen_pulse: target was already " & to_string(pulse_value) & ". " & add_msg_delimiter(msg), scope, ID_NEVER);

    target <= pulse_value; -- Generate pulse
    if (num_periods > 0) then
      for i in 1 to num_periods loop
        wait until falling_edge(clock_signal);
      end loop;
    end if;

    target <= C_INIT_VALUE;
    log(msg_id, "Pulsed to " & to_string(pulse_value) & " for " & to_string(num_periods) & " clk cycles. " & add_msg_delimiter(msg), scope);
  end procedure;

  -- Overload to allow excluding the pulse_value argument:
  -- Make pulse_value = '1' by default
  procedure gen_pulse(
    signal target         : inout std_logic;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, '1', clock_signal, num_periods, msg, scope, msg_id, msg_id_panel); -- pulse_value = '1' by default
  end procedure;

  procedure gen_pulse(
    signal target           : inout boolean;
    constant pulse_value    : boolean;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_INIT_VALUE : boolean := target;
  begin
    check_value(target /= pulse_value, TB_ERROR, "gen_pulse: target was already " & to_string(pulse_value) & ". " & add_msg_delimiter(msg), scope, ID_NEVER);

    target <= pulse_value; -- Generate pulse
    if (blocking_mode = BLOCKING) then
      wait for pulse_duration;
      target <= C_INIT_VALUE;
    else
      check_value(pulse_duration /= 0 ns, TB_ERROR, "gen_pulse: The combination of NON_BLOCKING mode and 0 ns pulse duration results in the pulse being ignored.", scope, ID_NEVER);
      target <= transport C_INIT_VALUE after pulse_duration;
    end if;
    log(msg_id, "Pulsed to " & to_string(pulse_value) & " for " & to_string(pulse_duration) & ". " & add_msg_delimiter(msg), scope);
    wait for 0 ns; -- wait a delta cycle for signal to update
  end procedure;

  -- Overload to allow excluding the pulse_value argument:
  -- Make pulse_value = true by default
  procedure gen_pulse(
    signal target           : inout boolean;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, true, pulse_duration, blocking_mode, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- Overload to allow excluding the blocking_mode and pulse_value arguments:
  -- Make blocking_mode = BLOCKING and pulse_value = true by default
  procedure gen_pulse(
    signal target           : inout boolean;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, true, pulse_duration, BLOCKING, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- Overload to allow excluding the blocking_mode argument:
  -- Make blocking_mode = BLOCKING by default
  procedure gen_pulse(
    signal target           : inout boolean;
    constant pulse_value    : boolean;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, pulse_value, pulse_duration, BLOCKING, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- Generate a pulse on a boolean for a certain number of clock cycles
  procedure gen_pulse(
    signal target         : inout boolean;
    constant pulse_value  : boolean;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_INIT_VALUE : boolean := target;
  begin
    wait until falling_edge(clock_signal);
    check_value(target /= pulse_value, TB_ERROR, "gen_pulse: target was already " & to_string(pulse_value) & ". " & add_msg_delimiter(msg), scope, ID_NEVER);

    target <= pulse_value; -- Generate pulse
    if (num_periods > 0) then
      for i in 1 to num_periods loop
        wait until falling_edge(clock_signal);
      end loop;
    end if;

    target <= C_INIT_VALUE;
    log(msg_id, "Pulsed to " & to_string(pulse_value) & " for " & to_string(num_periods) & " clk cycles. " & add_msg_delimiter(msg), scope);
  end procedure;

  -- Overload to allow excluding the pulse_value argument:
  -- Make pulse_value = true by default
  procedure gen_pulse(
    signal target         : inout boolean;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, true, clock_signal, num_periods, msg, scope, msg_id, msg_id_panel); -- pulse_value = '1' by default
  end procedure;

  -- gen_pulse(slv)
  -- Generate a pulse on a std_logic_vector for a certain amount of time
  --
  -- If blocking_mode = BLOCKING     : Procedure waits until the pulse is done before returning to the caller.
  -- If blocking_mode = NON_BLOCKING : Procedure starts the pulse, schedules the end of the pulse, then returns to the caller immediately.
  --
  procedure gen_pulse(
    signal target           : inout std_logic_vector;
    constant pulse_value    : std_logic_vector;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_INIT_VALUE : std_logic_vector(target'range)                    := target;
    variable v_target     : std_logic_vector(target'length - 1 downto 0)      := target;
    variable v_pulse      : std_logic_vector(pulse_value'length - 1 downto 0) := pulse_value;
  begin
    check_value(target /= pulse_value, TB_ERROR, "gen_pulse: target was already " & to_string(pulse_value) & ". " & add_msg_delimiter(msg), scope, ID_NEVER);

    for i in 0 to (v_target'length - 1) loop
      if v_pulse(i) /= '-' then
        v_target(i) := v_pulse(i); -- Generate pulse
      end if;
    end loop;
    target <= v_target;

    if (blocking_mode = BLOCKING) then
      wait for pulse_duration;
      target <= C_INIT_VALUE;
    else
      check_value(pulse_duration /= 0 ns, TB_ERROR, "gen_pulse: The combination of NON_BLOCKING mode and 0 ns pulse duration results in the pulse being ignored.", scope, ID_NEVER);
      target <= transport C_INIT_VALUE after pulse_duration;
    end if;
    log(msg_id, "Pulsed to " & to_string(pulse_value, HEX, AS_IS, INCL_RADIX) & " for " & to_string(pulse_duration) & ". " & add_msg_delimiter(msg), scope);
    wait for 0 ns; -- wait a delta cycle for signal to update
  end procedure;

  -- Overload to allow excluding the pulse_value argument:
  -- Make pulse_value = (others => '1') by default
  procedure gen_pulse(
    signal target           : inout std_logic_vector;
    constant pulse_duration : time;
    constant blocking_mode  : t_blocking_mode;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_PULSE_VALUE : std_logic_vector(target'range) := (others => '1');
  begin
    gen_pulse(target, C_PULSE_VALUE, pulse_duration, blocking_mode, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- Overload to allow excluding the blocking_mode and pulse_value arguments:
  -- Make blocking_mode = BLOCKING and pulse_value = (others => '1') by default
  procedure gen_pulse(
    signal target           : inout std_logic_vector;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_PULSE_VALUE : std_logic_vector(target'range) := (others => '1');
  begin
    gen_pulse(target, C_PULSE_VALUE, pulse_duration, BLOCKING, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- Overload to allow excluding the blocking_mode argument:
  -- Make blocking_mode = BLOCKING by default
  procedure gen_pulse(
    signal target           : inout std_logic_vector;
    constant pulse_value    : std_logic_vector;
    constant pulse_duration : time;
    constant msg            : string;
    constant scope          : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id         : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
  begin
    gen_pulse(target, pulse_value, pulse_duration, BLOCKING, msg, scope, msg_id, msg_id_panel); -- Blocking mode by default
  end procedure;

  -- gen_pulse(slv)
  -- Generate a pulse on a std_logic_vector for a certain number of clock cycles
  procedure gen_pulse(
    signal target         : inout std_logic_vector;
    constant pulse_value  : std_logic_vector;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_INIT_VALUE : std_logic_vector(target'range)                    := target;
    constant C_PULSE      : std_logic_vector(pulse_value'length - 1 downto 0) := pulse_value;
    variable v_target     : std_logic_vector(target'length - 1 downto 0)      := target;
  begin
    wait until falling_edge(clock_signal);
    check_value(target /= pulse_value, TB_ERROR, "gen_pulse: target was already " & to_string(pulse_value) & ". " & add_msg_delimiter(msg), scope, ID_NEVER);

    for i in 0 to (v_target'length - 1) loop
      if C_PULSE(i) /= '-' then
        v_target(i) := C_PULSE(i); -- Generate pulse
      end if;
    end loop;
    target <= v_target;

    if (num_periods > 0) then
      for i in 1 to num_periods loop
        wait until falling_edge(clock_signal);
      end loop;
    end if;

    target <= C_INIT_VALUE;
    log(msg_id, "Pulsed to " & to_string(pulse_value, HEX, AS_IS, INCL_RADIX) & " for " & to_string(num_periods) & " clk cycles. " & add_msg_delimiter(msg), scope);
    wait for 0 ns; -- wait a delta cycle for signal to update
  end procedure;

  -- Overload to allow excluding the pulse_value argument:
  -- Make pulse_value = (others => '1') by default
  procedure gen_pulse(
    signal target         : inout std_logic_vector;
    signal clock_signal   : std_logic;
    constant num_periods  : natural;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_GEN_PULSE;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_PULSE_VALUE : std_logic_vector(target'range) := (others => '1');
  begin
    gen_pulse(target, C_PULSE_VALUE, clock_signal, num_periods, msg, scope, msg_id, msg_id_panel); -- C_PULSE_VALUE = (others => '1') by default
  end procedure;

  --------------------------------------------
  -- Clock generators :
  -- Include this as a concurrent procedure from your test bench.
  -- ( Including this procedure call as a concurrent statement directly in your architecture
  --   is in fact identical to a process, where the procedure parameters is the sensitivity list )
  --   Set duty cycle by setting clock_high_percentage from 1 to 99. Beware of rounding errors.
  --------------------------------------------
  procedure clock_generator(
    signal clock_signal            : inout std_logic;
    constant clock_period          : in time;
    constant clock_high_percentage : in natural range 1 to 99 := 50
  ) is
    -- Making sure any rounding error after calculating period/2 is not accumulated.
    constant C_FIRST_HALF_CLK_PERIOD : time := clock_period * clock_high_percentage / 100;
  begin
    loop
      clock_signal <= '1';
      wait for C_FIRST_HALF_CLK_PERIOD;
      clock_signal <= '0';
      wait for (clock_period - C_FIRST_HALF_CLK_PERIOD);
    end loop;
  end procedure;

  --------------------------------------------
  -- Clock generator overload:
  -- Include this as a concurrent procedure from your test bench.
  -- ( Including this procedure call as a concurrent statement directly in your architecture
  --   is in fact identical to a process, where the procedure parameters is the sensitivity list )
  --   Set duty cycle by setting clock_high_time.
  --------------------------------------------
  procedure clock_generator(
    signal clock_signal      : inout std_logic;
    constant clock_period    : in time;
    constant clock_high_time : in time
  ) is
  begin
    check_value(clock_high_time < clock_period, TB_ERROR, "clock_generator: parameter clock_high_time must be lower than parameter clock_period!", C_TB_SCOPE_DEFAULT, ID_NEVER);
    loop
      clock_signal <= '1';
      wait for clock_high_time;
      clock_signal <= '0';
      wait for (clock_period - clock_high_time);
    end loop;
  end procedure;

  --------------------------------------------
  -- Clock generator overload:
  -- - Count variable (clock_count) is added as an output. Wraps when reaching max value of
  --   natural type.
  -- - Set duty cycle by setting clock_high_percentage from 1 to 99. Beware of rounding errors.
  --------------------------------------------
  procedure clock_generator(
    signal clock_signal            : inout std_logic;
    signal clock_count             : inout natural;
    constant clock_period          : in time;
    constant clock_high_percentage : in natural range 1 to 99 := 50
  ) is
    -- Making sure any rounding error after calculating period/2 is not accumulated.
    constant C_FIRST_HALF_CLK_PERIOD : time := clock_period * clock_high_percentage / 100;
  begin
    clock_count <= 0;

    loop
      clock_signal <= '0'; -- Should start on 0
      wait for C_FIRST_HALF_CLK_PERIOD;

      -- Update clock_count when clock_signal is set to '1'
      if clock_count < natural'right then
        clock_count <= clock_count + 1;
      else -- Wrap when reached max value of natural
        clock_count <= 0;
      end if;
      clock_signal <= '1';
      wait for (clock_period - C_FIRST_HALF_CLK_PERIOD);

    end loop;
  end procedure;

  --------------------------------------------
  -- Clock generator overload:
  -- - Counter clock_count is given as an output. Wraps when reaching max value of
  --   natural type.
  -- - Set duty cycle by setting clock_high_time.
  --------------------------------------------
  procedure clock_generator(
    signal clock_signal      : inout std_logic;
    signal clock_count       : inout natural;
    constant clock_period    : in time;
    constant clock_high_time : in time
  ) is
  begin
    clock_count <= 0;
    check_value(clock_high_time < clock_period, TB_ERROR, "clock_generator: parameter clock_high_time must be lower than parameter clock_period!", C_TB_SCOPE_DEFAULT, ID_NEVER);

    loop
      clock_signal <= '0';
      wait for (clock_period - clock_high_time);

      if clock_count < natural'right then
        clock_count <= clock_count + 1;
      else -- Wrap when reached max value of natural
        clock_count <= 0;
      end if;
      clock_signal <= '1';
      wait for clock_high_time;

    end loop;
  end procedure;

  --------------------------------------------
  -- Clock generator overload:
  -- - Enable signal (clock_ena) is added as a parameter
  -- - The clock goes to '1' immediately when the clock is enabled (clock_ena = true)
  -- - Log when the clock_ena changes. clock_name is used in the log message.
  -- - Set duty cycle by setting clock_high_percentage from 1 to 99. Beware of rounding errors.
  --------------------------------------------
  procedure clock_generator(
    signal clock_signal            : inout std_logic;
    signal clock_ena               : in boolean;
    constant clock_period          : in time;
    constant clock_name            : in string;
    constant clock_high_percentage : in natural range 1 to 99 := 50
  ) is
    -- Making sure any rounding error after calculating period/2 is not accumulated.
    constant C_FIRST_HALF_CLK_PERIOD : time := clock_period * clock_high_percentage / 100;
  begin
    loop
      if not clock_ena then
        if now /= 0 ps then
          log(ID_CLOCK_GEN, "Stopping clock " & clock_name);
        end if;
        clock_signal <= '0';
        wait until clock_ena;
        log(ID_CLOCK_GEN, "Starting clock " & clock_name);
      end if;

      clock_signal <= '1';
      wait for C_FIRST_HALF_CLK_PERIOD;
      clock_signal <= '0';
      wait for (clock_period - C_FIRST_HALF_CLK_PERIOD);

    end loop;
  end procedure;

  --------------------------------------------
  -- Clock generator overload:
  -- - Enable signal (clock_ena) is added as a parameter
  -- - The clock goes to '1' immediately when the clock is enabled (clock_ena = true)
  -- - Log when the clock_ena changes. clock_name is used in the log message.
  --   inferred to be low time.
  -- - Set duty cycle by setting clock_high_time.
  --------------------------------------------
  procedure clock_generator(
    signal clock_signal      : inout std_logic;
    signal clock_ena         : in boolean;
    constant clock_period    : in time;
    constant clock_name      : in string;
    constant clock_high_time : in time
  ) is
  begin
    check_value(clock_high_time < clock_period, TB_ERROR, "clock_generator: parameter clock_high_time must be lower than parameter clock_period!", C_TB_SCOPE_DEFAULT, ID_NEVER);
    loop
      if not clock_ena then
        if now /= 0 ps then
          log(ID_CLOCK_GEN, "Stopping clock " & clock_name);
        end if;
        clock_signal <= '0';
        wait until clock_ena;
        log(ID_CLOCK_GEN, "Starting clock " & clock_name);
      end if;
      clock_signal <= '1';
      wait for clock_high_time;
      clock_signal <= '0';
      wait for (clock_period - clock_high_time);
    end loop;
  end procedure;

  --------------------------------------------
  -- Clock generator overload:
  -- - Enable signal (clock_ena) is added as a parameter
  -- - The clock goes to '1' immediately when the clock is enabled (clock_ena = true)
  -- - Log when the clock_ena changes. clock_name is used in the log message.
  -- - Count variable (clock_count) is added as an output. Wraps when reaching max value of
  --   natural type.
  -- - Set duty cycle by setting clock_high_percentage from 1 to 99. Beware of rounding errors.
  --------------------------------------------
  procedure clock_generator(
    signal clock_signal            : inout std_logic;
    signal clock_ena               : in boolean;
    signal clock_count             : out natural;
    constant clock_period          : in time;
    constant clock_name            : in string;
    constant clock_high_percentage : in natural range 1 to 99 := 50
  ) is
    -- Making sure any rounding error after calculating period/2 is not accumulated.
    constant C_FIRST_HALF_CLK_PERIOD : time    := clock_period * clock_high_percentage / 100;
    variable v_clock_count           : natural := 0;
  begin
    clock_count <= v_clock_count;

    loop
      if not clock_ena then
        if now /= 0 ps then
          log(ID_CLOCK_GEN, "Stopping clock " & clock_name);
        end if;
        clock_signal <= '0';
        wait until clock_ena;
        log(ID_CLOCK_GEN, "Starting clock " & clock_name);
      end if;
      clock_signal <= '1';
      wait for C_FIRST_HALF_CLK_PERIOD;
      clock_signal <= '0';
      wait for (clock_period - C_FIRST_HALF_CLK_PERIOD);

      if v_clock_count < natural'right then
        v_clock_count := v_clock_count + 1;
      else -- Wrap when reached max value of natural
        v_clock_count := 0;
      end if;

      clock_count <= v_clock_count;
    end loop;
  end procedure;

  --------------------------------------------
  -- Clock generator overload:
  -- - Enable signal (clock_ena) is added as a parameter
  -- - The clock goes to '1' immediately when the clock is enabled (clock_ena = true)
  -- - Log when the clock_ena changes. clock_name is used in the log message.
  --   inferred to be low time.
  -- - Count variable (clock_count) is added as an output. Wraps when reaching max value of
  --   natural type.
  -- - Set duty cycle by setting clock_high_time.
  --------------------------------------------
  procedure clock_generator(
    signal clock_signal      : inout std_logic;
    signal clock_ena         : in boolean;
    signal clock_count       : out natural;
    constant clock_period    : in time;
    constant clock_name      : in string;
    constant clock_high_time : in time
  ) is
    variable v_clock_count : natural := 0;
  begin
    clock_count <= v_clock_count;

    check_value(clock_high_time < clock_period, TB_ERROR, "clock_generator: parameter clock_high_time must be lower than parameter clock_period!", C_TB_SCOPE_DEFAULT, ID_NEVER);

    loop
      if not clock_ena then
        if now /= 0 ps then
          log(ID_CLOCK_GEN, "Stopping clock " & clock_name);
        end if;
        clock_signal <= '0';
        wait until clock_ena;
        log(ID_CLOCK_GEN, "Starting clock " & clock_name);
      end if;
      clock_signal <= '1';
      wait for clock_high_time;
      clock_signal <= '0';
      wait for (clock_period - clock_high_time);

      if v_clock_count < natural'right then
        v_clock_count := v_clock_count + 1;
      else -- Wrap when reached max value of natural
        v_clock_count := 0;
      end if;

      clock_count <= v_clock_count;
    end loop;
  end procedure;

  --------------------------------------------
  -- Adjustable clock generators :
  -- Include this as a concurrent procedure from your test bench.
  -- ( Including this procedure call as a concurrent statement directly in your architecture
  --   is in fact identical to a process, where the procedure parameters is the sensitivity list )
  --   Set duty cycle by setting clock_high_percentage from 1 to 99. Beware of rounding errors.
  --------------------------------------------
  procedure adjustable_clock_generator(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in boolean;
    constant clock_period        : in time;
    constant clock_name          : in string;
    signal clock_high_percentage : in natural range 0 to 100
  ) is
    -- Making sure any rounding error after calculating period/2 is not accumulated.
    variable v_first_half_clk_period : time := clock_period * clock_high_percentage / 100;
  begin
    -- alert if init value is not set
    check_value(clock_high_percentage /= 0, TB_ERROR, "clock_generator: parameter clock_high_percentage must be set!", C_TB_SCOPE_DEFAULT, ID_NEVER);

    loop
      if not clock_ena then
        if now /= 0 ps then
          log(ID_CLOCK_GEN, "Stopping clock: " & clock_name);
        end if;
        clock_signal <= '0';
        wait until clock_ena;
        log(ID_CLOCK_GEN, "Starting clock: " & clock_name);
        -- alert if unvalid value is set
        check_value_in_range(clock_high_percentage, 1, 99, TB_ERROR, "adjustable_clock_generator: parameter clock_high_percentage must be in range 1 to 99!", C_TB_SCOPE_DEFAULT, ID_NEVER);
      end if;

      v_first_half_clk_period := clock_period * clock_high_percentage / 100;

      clock_signal <= '1';
      wait for v_first_half_clk_period;
      clock_signal <= '0';
      wait for (clock_period - v_first_half_clk_period);

    end loop;
  end procedure;

  procedure adjustable_clock_generator(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in boolean;
    constant clock_period        : in time;
    signal clock_high_percentage : in natural range 0 to 100
  ) is
    constant C_CLOCK_NAME : string := "";
  begin
    adjustable_clock_generator(clock_signal, clock_ena, clock_period, C_CLOCK_NAME, clock_high_percentage);
  end procedure;

  -- Overloaded version with clock enable, clock name
  -- and clock count
  procedure adjustable_clock_generator(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in boolean;
    signal clock_count           : out natural;
    constant clock_period        : in time;
    constant clock_name          : in string;
    signal clock_high_percentage : in natural range 0 to 100
  ) is
    -- Making sure any rounding error after calculating period/2 is not accumulated.
    variable v_first_half_clk_period : time    := clock_period * clock_high_percentage / 100;
    variable v_clock_count           : natural := 0;
  begin
    -- alert if init value is not set
    check_value(clock_high_percentage /= 0, TB_ERROR, "clock_generator: parameter clock_high_percentage must be set!", C_TB_SCOPE_DEFAULT, ID_NEVER);

    clock_count <= v_clock_count;
    loop
      if not clock_ena then
        if now /= 0 ps then
          log(ID_CLOCK_GEN, "Stopping clock: " & clock_name);
        end if;
        clock_signal <= '0';
        wait until clock_ena;
        log(ID_CLOCK_GEN, "Starting clock: " & clock_name);
        -- alert if unvalid value is set
        check_value_in_range(clock_high_percentage, 1, 99, TB_ERROR, "adjustable_clock_generator: parameter clock_high_percentage must be in range 1 to 99!", C_TB_SCOPE_DEFAULT, ID_NEVER);
      end if;

      v_first_half_clk_period := clock_period * clock_high_percentage / 100;

      clock_signal <= '1';
      wait for v_first_half_clk_period;
      clock_signal <= '0';
      wait for (clock_period - v_first_half_clk_period);

      if v_clock_count < natural'right then
        v_clock_count := v_clock_count + 1;
      else -- Wrap when reached max value of natural
        v_clock_count := 0;
      end if;

      clock_count <= v_clock_count;
    end loop;
  end procedure;

  -- ============================================================================
  -- Synchronization methods
  -- ============================================================================
  -- Local type used in synchronization methods
  type t_flag_array_idx_and_status_record is record
    flag_idx        : integer;
    flag_is_new     : boolean;
    flag_array_full : boolean;
  end record;

  -- Local function used in synchronization methods to search through shared_flag_array for flag_name or available index
  -- Returns:
  --          Flag index in the shared array
  --          If the flag is new or already in the array
  --          If the array is full, and the flag can not be added (alerts an error).
  impure function find_or_add_sync_flag(
    constant flag_name : string
  ) return t_flag_array_idx_and_status_record is
    variable v_idx           : integer := 0;
    variable v_is_new        : boolean := false;
    variable v_is_array_full : boolean := true;
  begin
    for i in shared_flag_array'range loop
      -- Search for empty index. If found add a new flag
      if (shared_flag_array(i).flag_name = (shared_flag_array(i).flag_name'range => NUL)) then
        shared_flag_array(i).flag_name(flag_name'range) := flag_name;
        v_is_new                                        := true;
      end if;
      -- Check if flag exists in the array
      if (shared_flag_array(i).flag_name(flag_name'range) = flag_name) then
        v_idx           := i;
        v_is_array_full := false;
        exit;
      end if;
    end loop;
    return (v_idx, v_is_new, v_is_array_full);
  end function;

  procedure block_flag(
    constant flag_name                : in string;
    constant msg                      : in string;
    constant already_blocked_severity : in t_alert_level := warning;
    constant scope                    : in string        := C_TB_SCOPE_DEFAULT
  ) is
    variable v_idx           : integer := 0;
    variable v_is_new        : boolean := false;
    variable v_is_array_full : boolean := true;
  begin
    -- Find flag, or add a new provided the array is not full.
    (v_idx, v_is_new, v_is_array_full) := find_or_add_sync_flag(flag_name);
    if (v_is_array_full = true) then
      alert(TB_ERROR, "The flag " & flag_name & " was not found and the maximum number of flags (" & to_string(C_NUM_SYNC_FLAGS) & ") have been used. Configure in adaptations_pkg. " & add_msg_delimiter(msg), scope);
    else -- Block flag
      if (v_is_new = true) then
        log(ID_BLOCKING, flag_name & ": New blocked synchronization flag added. " & add_msg_delimiter(msg), scope);
      else
        -- Check if the flag to be blocked already is blocked
        if (shared_flag_array(v_idx).is_blocked = true) then
          alert(already_blocked_severity, "The flag " & flag_name & " was already blocked. " & add_msg_delimiter(msg), scope);
        else
          log(ID_BLOCKING, flag_name & ": Blocking flag. " & add_msg_delimiter(msg), scope);
        end if;
      end if;
      shared_flag_array(v_idx).is_blocked := true;
    end if;
  end procedure;

  procedure unblock_flag(
    constant flag_name : in string;
    constant msg       : in string;
    signal trigger     : inout std_logic; -- Parameter must be global_trigger as method await_unblock_flag() uses that global signal to detect unblocking.
    constant scope     : in string := C_TB_SCOPE_DEFAULT
  ) is
    variable v_idx           : integer := 0;
    variable v_is_new        : boolean := false;
    variable v_is_array_full : boolean := true;
  begin
    -- Find flag, or add a new provided the array is not full.
    (v_idx, v_is_new, v_is_array_full) := find_or_add_sync_flag(flag_name);
    if (v_is_array_full = true) then
      alert(TB_ERROR, "The flag " & flag_name & " was not found and the maximum number of flags (" & to_string(C_NUM_SYNC_FLAGS) & ") have been used. Configure in adaptations_pkg. " & add_msg_delimiter(msg), scope);
    else -- Unblock flag
      if (v_is_new = true) then
        log(ID_BLOCKING, flag_name & ": New unblocked synchronization flag added. " & add_msg_delimiter(msg), scope);
      else
        log(ID_BLOCKING, flag_name & ": Unblocking flag. " & add_msg_delimiter(msg), scope);
      end if;
      shared_flag_array(v_idx).is_blocked := false;
      -- Triggers a signal to allow await_unblock_flag() to detect unblocking.
      gen_pulse(trigger, 0 ns, "pulsing global_trigger. " & add_msg_delimiter(msg), C_TB_SCOPE_DEFAULT, ID_NEVER);
    end if;
  end procedure;

  procedure await_unblock_flag(
    constant flag_name        : in string;
    constant timeout          : in time;
    constant msg              : in string;
    constant flag_returning   : in t_flag_returning := KEEP_UNBLOCKED;
    constant timeout_severity : in t_alert_level    := error;
    constant scope            : in string           := C_TB_SCOPE_DEFAULT
  ) is
    variable v_idx             : integer := 0;
    variable v_is_new          : boolean := false;
    variable v_is_array_full   : boolean := true;
    variable v_flag_is_blocked : boolean := true;
    constant C_START_TIME      : time    := now;

  begin
    -- Find flag, or add a new provided the array is not full.
    (v_idx, v_is_new, v_is_array_full) := find_or_add_sync_flag(flag_name);
    if (v_is_array_full = true) then
      alert(TB_ERROR, "The flag " & flag_name & " was not found and the maximum number of flags (" & to_string(C_NUM_SYNC_FLAGS) & ") have been used. Configure in adaptations_pkg. " & add_msg_delimiter(msg), scope);
    else -- Waits only if the flag is found and is blocked. Will wait when a new flag is added, as it is default blocked.
      v_flag_is_blocked := shared_flag_array(v_idx).is_blocked;
      if (v_flag_is_blocked = false) then
        if (flag_returning = RETURN_TO_BLOCK) then
          -- wait for all sequencer that are waiting for that flag before reseting it
          wait for 0 ns;
          shared_flag_array(v_idx).is_blocked := true;
          log(ID_BLOCKING, flag_name & ": Was already unblocked. Returned to blocked. " & add_msg_delimiter(msg), scope);
        else
          log(ID_BLOCKING, flag_name & ": Was already unblocked. " & add_msg_delimiter(msg), scope);
        end if;
      else -- Flag is blocked (or a new flag was added), starts waiting. log before while loop. Otherwise the message will be printed everytime the global_trigger was triggered.
        if (v_is_new = true) then
          log(ID_BLOCKING, flag_name & ": New blocked synchronization flag added. Waiting to be unblocked. " & add_msg_delimiter(msg), scope);
        else
          log(ID_BLOCKING, flag_name & ": Waiting to be unblocked. " & add_msg_delimiter(msg), scope);
        end if;
      end if;

      -- Waiting for flag to be unblocked
      while v_flag_is_blocked = true loop
        if (timeout /= 0 ns) then
          wait until rising_edge(global_trigger) for ((C_START_TIME + timeout) - now);
          check_value(global_trigger = '1', timeout_severity, flag_name & " timed out. " & add_msg_delimiter(msg), scope, ID_NEVER);
          if global_trigger /= '1' then
            exit;
          end if;
        else
          wait until rising_edge(global_trigger);
        end if;

        v_flag_is_blocked := shared_flag_array(v_idx).is_blocked;
        if (v_flag_is_blocked = false) then
          if flag_returning = KEEP_UNBLOCKED then
            log(ID_BLOCKING, flag_name & ": Has been unblocked. ", scope);
          else
            log(ID_BLOCKING, flag_name & ": Has been unblocked. Returned to blocked. ", scope);
            -- wait for all sequencer that are waiting for that flag before reseting it
            wait for 0 ns;
            shared_flag_array(v_idx).is_blocked := true;
          end if;
        end if;

      end loop;
    end if;
  end procedure;

  procedure await_barrier(
    signal barrier_signal     : inout std_logic;
    constant timeout          : in time;
    constant msg              : in string;
    constant timeout_severity : in t_alert_level := error;
    constant scope            : in string        := C_TB_SCOPE_DEFAULT
  ) is
  begin
    -- set barrier signal to 0
    barrier_signal <= '0';
    log(ID_BLOCKING, "Waiting for barrier. " & add_msg_delimiter(msg), scope);
    -- wait until all sequencer using that barrier_signal wait for it
    if timeout = 0 ns then
      wait until barrier_signal = '0';
    else
      wait until barrier_signal = '0' for timeout;
    end if;
    if barrier_signal /= '0' then
      -- timeout
      alert(timeout_severity, "Timeout while waiting for barrier signal. " & add_msg_delimiter(msg), scope);
    else
      log(ID_BLOCKING, "Barrier received. " & add_msg_delimiter(msg), scope);
    end if;
    barrier_signal <= '1';
  end procedure;

  procedure await_semaphore_in_delta_cycles(
    variable semaphore : inout t_protected_semaphore
  ) is
    variable v_cnt_lock_tries : natural := 0;
  begin
    while semaphore.get_semaphore = false and v_cnt_lock_tries < C_NUM_SEMAPHORE_LOCK_TRIES loop
      wait for 0 ns;
      v_cnt_lock_tries := v_cnt_lock_tries + 1;
    end loop;
    if v_cnt_lock_tries = C_NUM_SEMAPHORE_LOCK_TRIES then
      tb_error("Failed to acquire semaphore when sending command to VVC", C_SCOPE);
    end if;

  end procedure;

  procedure release_semaphore(
    variable semaphore : inout t_protected_semaphore
  ) is
  begin
    semaphore.release_semaphore;
  end procedure;

  -- ============================================================================
  -- General Watchdog-related
  -- ============================================================================
  -------------------------------------------------------------------------------
  -- General Watchdog timer:
  -- Include this as a concurrent procedure from your testbench.
  -- Use extend_watchdog(), reinitialize_watchdog() or terminate_watchdog() to
  -- modify the watchdog timer from the test sequencer.
  -------------------------------------------------------------------------------
  procedure watchdog_timer(
    signal watchdog_ctrl : in t_watchdog_ctrl;
    constant timeout     : time;
    constant alert_level : t_alert_level := error;
    constant msg         : string        := ""
  ) is
    variable v_timeout      : time;
    variable v_prev_timeout : time;
  begin
    -- This delta cycle is needed due to a problem with external tools that
    -- without it, they wouldn't print the first log message.
    wait for 0 ns;

    log(ID_WATCHDOG, "Starting general watchdog: " & to_string(timeout) & ". " & msg);
    v_prev_timeout := 0 ns;
    v_timeout      := timeout;

    loop
      wait until (watchdog_ctrl.extend or watchdog_ctrl.restart or watchdog_ctrl.terminate) for v_timeout;
      -- Watchdog was extended
      if watchdog_ctrl.extend then
        if watchdog_ctrl.extension = 0 ns then
          log(ID_WATCHDOG, "Extending general watchdog by default value: " & to_string(timeout) & ". " & msg);
          v_timeout := (v_prev_timeout + v_timeout - now) + timeout;
        else
          log(ID_WATCHDOG, "Extending general watchdog by " & to_string(watchdog_ctrl.extension) & ". " & msg);
          v_timeout := (v_prev_timeout + v_timeout - now) + watchdog_ctrl.extension;
        end if;
        v_prev_timeout := now;
        -- Watchdog was reinitialized
      elsif watchdog_ctrl.restart then
        log(ID_WATCHDOG, "Reinitializing general watchdog: " & to_string(watchdog_ctrl.new_timeout) & ". " & msg);
        v_timeout      := watchdog_ctrl.new_timeout;
        v_prev_timeout := now;
      else
        -- Watchdog was terminated
        if watchdog_ctrl.terminate then
          log(ID_WATCHDOG, "Terminating general watchdog. " & msg);
          -- Watchdog has timed out
        else
          alert(alert_level, "General watchdog timer ended! " & msg);
        end if;
        exit;
      end if;
    end loop;
    wait;
  end procedure;

  procedure extend_watchdog(
    signal watchdog_ctrl : inout t_watchdog_ctrl;
    constant time_extend : time := 0 ns
  ) is
  begin
    if not watchdog_ctrl.terminate then
      watchdog_ctrl.extension <= time_extend;
      watchdog_ctrl.extend    <= true;
      wait for 0 ns; -- delta cycle to propagate signal
      watchdog_ctrl.extend <= false;
    end if;
  end procedure;

  procedure reinitialize_watchdog(
    signal watchdog_ctrl : inout t_watchdog_ctrl;
    constant timeout     : time
  ) is
  begin
    if not watchdog_ctrl.terminate then
      watchdog_ctrl.new_timeout <= timeout;
      watchdog_ctrl.restart     <= true;
      wait for 0 ns; -- delta cycle to propagate signal
      watchdog_ctrl.restart <= false;
    end if;
  end procedure;

  procedure terminate_watchdog(
    signal watchdog_ctrl : inout t_watchdog_ctrl
  ) is
  begin
    watchdog_ctrl.terminate <= true;
    wait for 0 ns; -- delta cycle to propagate signal
  end procedure;

  -- ============================================================================
  -- generate_crc
  -- ============================================================================
  impure function generate_crc(
    constant data       : in std_logic_vector;
    constant crc_in     : in std_logic_vector;
    constant polynomial : in std_logic_vector
  ) return std_logic_vector is
    variable v_crc_out : std_logic_vector(crc_in'range) := crc_in;
  begin
    -- Sanity checks
    check_value(not data'ascending, TB_FAILURE, "data have to be decending", C_SCOPE, ID_NEVER);
    check_value(not crc_in'ascending, TB_FAILURE, "crc_in have to be decending", C_SCOPE, ID_NEVER);
    check_value(not polynomial'ascending, TB_FAILURE, "polynomial have to be decending", C_SCOPE, ID_NEVER);
    check_value(crc_in'length, polynomial'length - 1, TB_FAILURE, "crc_in have to be one bit shorter than polynomial", C_SCOPE, ID_NEVER);

    for i in data'high downto data'low loop
      if v_crc_out(v_crc_out'high) xor data(i) then
        v_crc_out := v_crc_out sll 1;
        v_crc_out := v_crc_out xor polynomial(polynomial'high - 1 downto polynomial'low);
      else
        v_crc_out := v_crc_out sll 1;
      end if;
    end loop;
    return v_crc_out;
  end function;

  impure function generate_crc(
    constant data       : in t_slv_array;
    constant crc_in     : in std_logic_vector;
    constant polynomial : in std_logic_vector
  ) return std_logic_vector is
    variable v_crc_out : std_logic_vector(crc_in'range) := crc_in;
  begin
    -- Sanity checks
    check_value(data'ascending, TB_FAILURE, "slv array have to be acending", C_SCOPE, ID_NEVER);

    for i in data'low to data'high loop
      v_crc_out := generate_crc(data(i), v_crc_out, polynomial);
    end loop;
    return v_crc_out;
  end function;

end package body;
