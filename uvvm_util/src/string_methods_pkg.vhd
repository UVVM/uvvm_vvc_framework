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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.math_real.all;

use work.types_pkg.all;
use work.adaptations_pkg.all;

package string_methods_pkg is

  -- Need a low level "alert" in the form of a simple assertion (as string handling may also fail)
  procedure bitvis_assert(
    val        : boolean;
    severeness : severity_level;
    msg        : string;
    scope      : string
  );

  -- DEPRECATED.
  -- Function will be removed in future versions of UVVM-Util
  function justify(
    val       : string;
    width     : natural         := 0;
    justified : side            := RIGHT;
    format    : t_format_string := AS_IS -- No defaults on 4 first param - to avoid ambiguity with std.textio
  ) return string;

  -- DEPRECATED.
  -- Function will be removed in future versions of UVVM-Util
  function justify(
    val           : string;
    justified     : side;
    width         : natural;
    format_spaces : t_format_spaces;
    truncate      : t_truncate_string
  ) return string;

  function justify(
    val           : string;
    justified     : t_justify_center;
    width         : natural;
    format_spaces : t_format_spaces;
    truncate      : t_truncate_string
  ) return string;

  function pos_of_leftmost(
    target              : character;
    vector              : string;
    result_if_not_found : natural := 1
  ) return natural;

  function pos_of_rightmost(
    target              : character;
    vector              : string;
    result_if_not_found : natural := 1
  ) return natural;

  function pos_of_leftmost_non_zero(
    vector              : string;
    result_if_not_found : natural := 1
  ) return natural;

  function pos_of_rightmost_non_whitespace(
    vector              : string;
    result_if_not_found : natural := 1
  ) return natural;

  function valid_length(                -- of string excluding trailing NULs
    vector : string
  ) return natural;

  function get_string_between_delimiters(
    val         : string;
    delim_left  : character;
    delim_right : character;
    start_from  : SIDE;                 -- search from left or right  (Only RIGHT implemented so far)
    occurrence  : positive := 1         -- stop on N'th occurrence of delimeter pair. Default first occurrence
  ) return string;

  impure function get_procedure_name_from_instance_name(
    val : string
  ) return string;

  impure function get_process_name_from_instance_name(
    val : string
  ) return string;

  impure function get_entity_name_from_instance_name(
    val : string
  ) return string;

  function return_string_if_true(
    val        : string;
    return_val : boolean
  ) return string;

  function return_string1_if_true_otherwise_string2(
    val1       : string;
    val2       : string;
    return_val : boolean
  ) return string;

  function to_upper(
    val : string
  ) return string;

  function fill_string(
    val   : character;
    width : natural
  ) return string;

  function pad_string(
    val   : string;
    char  : character;
    width : natural;
    side  : side := LEFT
  ) return string;

  function replace_backslash_n_with_lf(
    source : string
  ) return string;

  function replace_backslash_r_with_lf(
    source : string
  ) return string;

  function remove_initial_chars(
    source : string;
    num    : natural
  ) return string;

  function wrap_lines(
    constant text_string    : string;
    constant alignment_pos1 : natural;  -- Line position of first aligned character in line 1
    constant alignment_pos2 : natural;  -- Line position of first aligned character in line 2, etc...
    constant line_width     : natural
  ) return string;

  procedure wrap_lines(
    variable text_lines     : inout line;
    constant alignment_pos1 : natural;  -- Line position prior to first aligned character (incl. Prefix)
    constant alignment_pos2 : natural;
    constant line_width     : natural
  );

  procedure prefix_lines(
    variable text_lines : inout line;
    constant prefix     : string := C_LOG_PREFIX
  );

  function replace(
    val           : string;
    target_char   : character;
    exchange_char : character
  ) return string;

  procedure replace(
    variable text_line : inout line;
    target_char        : character;
    exchange_char      : character
  );

  --========================================================
  -- Handle missing overloads from 'standard_additions'
  --========================================================
  function to_string(
    val           : boolean;
    width         : natural;
    justified     : side;
    format_spaces : t_format_spaces;
    truncate      : t_truncate_string := DISALLOW_TRUNCATE
  ) return string;

  impure function to_string(
    val           : integer;
    width         : natural;
    justified     : side;
    format_spaces : t_format_spaces;
    truncate      : t_truncate_string := DISALLOW_TRUNCATE;
    radix         : t_radix           := DEC;
    prefix        : t_radix_prefix    := EXCL_RADIX;
    format        : t_format_zeros    := SKIP_LEADING_0 -- | KEEP_LEADING_0
  ) return string;

  impure function to_string(
    val    : integer;
    radix  : t_radix;
    prefix : t_radix_prefix;
    format : t_format_zeros := SKIP_LEADING_0 -- | KEEP_LEADING_0
  ) return string;

  -- This function has been deprecated and will be removed in the next major release
  -- DEPRECATED
  function to_string(
    val       : boolean;
    width     : natural;
    justified : side            := right;
    format    : t_format_string := AS_IS
  ) return string;

  -- This function has been deprecated and will be removed in the next major release
  -- DEPRECATED
  function to_string(
    val       : integer;
    width     : natural;
    justified : side            := right;
    format    : t_format_string := AS_IS
  ) return string;

  function to_string(
    val    : std_logic_vector;
    radix  : t_radix;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  function to_string(
    val    : unsigned;
    radix  : t_radix;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  function to_string(
    val    : signed;
    radix  : t_radix;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  function to_string(
    val    : t_slv_array;
    radix  : t_radix        := HEX_BIN_IF_INVALID;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  function to_string(
    val    : t_signed_array;
    radix  : t_radix        := HEX_BIN_IF_INVALID;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  function to_string(
    val    : t_unsigned_array;
    radix  : t_radix        := HEX_BIN_IF_INVALID;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  impure function to_string(
    val    : integer_vector;
    radix  : t_radix        := DEC;
    format : t_format_zeros := SKIP_LEADING_0; -- | KEEP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  impure function to_string(
    val    : t_natural_vector;
    radix  : t_radix        := DEC;
    format : t_format_zeros := SKIP_LEADING_0; -- | KEEP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  impure function to_string(
    val    : t_positive_vector;
    radix  : t_radix        := DEC;
    format : t_format_zeros := SKIP_LEADING_0; -- | KEEP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string;

  function to_string(
    val : real_vector
  ) return string;

  function to_string(
    val : time_vector
  ) return string;

  --========================================================
  -- Handle types defined at lower levels
  --========================================================
  function to_string(
    val       : t_alert_level;
    width     : natural;
    justified : side := right
  ) return string;

  function to_string(
    val       : t_msg_id;
    width     : natural;
    justified : side := right
  ) return string;

  function to_string(
    val       : t_attention;
    width     : natural;
    justified : side := right
  ) return string;

  function to_string(
    val       : t_check_type;
    width     : natural;
    justified : side := right
  ) return string;

  procedure to_string(
    val   : t_alert_attention_counters;
    order : t_order := FINAL
  );

  procedure to_string(
    val   : t_check_counters_array;
    order : t_order := FINAL
  );

  function ascii_to_char(
    ascii_pos   : integer range 0 to 255;
    ascii_allow : t_ascii_allow := ALLOW_ALL
  ) return character;

  function char_to_ascii(
    char : character
  ) return integer;

  -- return string with only valid ascii characters
  function to_string(
    val : string
  ) return string;

  function add_msg_delimiter(
    msg : string
  ) return string;

  -- Returns a string with a timestamp and a text. Used in report headers
  function timestamp_header(
    value : time;
    txt   : string) return string;

end package string_methods_pkg;

package body string_methods_pkg is

  -- Need a low level "alert" in the form of a simple assertion (as string handling may also fail)
  procedure bitvis_assert(
    val        : boolean;
    severeness : severity_level;
    msg        : string;
    scope      : string
  ) is
  begin
    assert val
    report LF & C_LOG_PREFIX & " *** " & to_string(severeness) & "*** caused by Bitvis Util > string handling > " & scope & LF & C_LOG_PREFIX & " " & add_msg_delimiter(msg) & LF
    severity severeness;
  end;

  function to_upper(
    val : string
  ) return string is
    variable v_result : string(val'range) := val;
  begin
    for i in val'range loop
      -- NOTE: Illegal characters are allowed and will pass through (check Mentor's std_developers_kit)
      if (v_result(i) >= 'a' and v_result(i) <= 'z') then
        v_result(i) := character'val(character'pos(v_result(i)) - character'pos('a') + character'pos('A'));
      end if;
    end loop;
    return v_result;
  end to_upper;

  function fill_string(
    val   : character;
    width : natural
  ) return string is
    variable v_result : string(1 to maximum(1, width));
  begin
    if (width = 0) then
      return "";
    else
      for i in 1 to width loop
        v_result(i) := val;
      end loop;
    end if;
    return v_result;
  end fill_string;

  function pad_string(
    val   : string;
    char  : character;
    width : natural;
    side  : side := LEFT
  ) return string is
    constant C_VAL_NORMALISED : string(1 to val'length) := val;
    variable v_result         : string(1 to maximum(1, width));
  begin
    if (width = 0) then
      return "";
    elsif (width <= C_VAL_NORMALISED'length) then
      return C_VAL_NORMALISED(1 to width);
    else
      v_result := (others => char);
      if side = LEFT then
        v_result(1 to C_VAL_NORMALISED'length) := C_VAL_NORMALISED;
      else
        v_result(v_result'length - C_VAL_NORMALISED'length + 1 to v_result'length) := C_VAL_NORMALISED;
      end if;
    end if;
    return v_result;
  end pad_string;

  -- This procedure has been deprecated, and will be removed in the near future.
  function justify(
    val       : string;
    width     : natural         := 0;
    justified : side            := RIGHT;
    format    : t_format_string := AS_IS -- No defaults on 4 first param - to avoid ambiguity with std.textio
  ) return string is
    constant C_VAL_LENGTH     : natural                   := val'length;
    constant C_VAL_NORMALISED : string(1 to C_VAL_LENGTH) := val;
    variable result           : string(1 to width)        := (others => ' ');
  begin
    -- return val if width is too small
    if C_VAL_LENGTH >= width then
      if (format = TRUNCATE) then
        return C_VAL_NORMALISED(1 to width);
      else
        return C_VAL_NORMALISED;
      end if;
    end if;
    if justified = left then
      result(1 to C_VAL_LENGTH) := C_VAL_NORMALISED;
    elsif justified = right then
      result(width - C_VAL_LENGTH + 1 to width) := C_VAL_NORMALISED;
    end if;
    return result;
  end function;

  -- This procedure has been deprecated, and will be removed in the near future.
  function justify(
    val           : string;
    justified     : side;
    width         : natural;
    format_spaces : t_format_spaces;
    truncate      : t_truncate_string
  ) return string is
    variable v_val_length        : natural            := val'length;
    variable v_formatted_val     : string(1 to val'length);
    variable v_num_leading_space : natural            := 0;
    variable v_result            : string(1 to width) := (others => ' ');
  begin
    -- Remove leading space if format_spaces is SKIP_LEADING_SPACE
    if format_spaces = SKIP_LEADING_SPACE then
      -- Find how many leading spaces there are
      while ((val(v_num_leading_space + 1) = ' ') and (v_num_leading_space < v_val_length)) loop
        v_num_leading_space := v_num_leading_space + 1;
      end loop;
      -- Remove leading space if any
      v_formatted_val := pad_string(remove_initial_chars(val, v_num_leading_space), ' ', v_formatted_val'length, LEFT);
      v_val_length    := v_val_length - v_num_leading_space;
    else
      v_formatted_val := val;
    end if;

    -- Truncate and return if the string is wider that allowed
    if v_val_length >= width then
      if (truncate = ALLOW_TRUNCATE) then
        return v_formatted_val(1 to width);
      else
        return v_formatted_val(1 to v_val_length);
      end if;
    end if;

    -- Justify if string is within the width specifications
    if justified = left then
      v_result(1 to v_val_length) := v_formatted_val(1 to v_val_length);
    elsif justified = right then
      v_result(width - v_val_length + 1 to width) := v_formatted_val(1 to v_val_length);
    end if;

    return v_result;
  end function;

  function justify(
    val           : string;
    justified     : t_justify_center;
    width         : natural;
    format_spaces : t_format_spaces;
    truncate      : t_truncate_string
  ) return string is
    variable v_val_length        : natural            := val'length;
    variable v_start_pos         : natural;
    variable v_formatted_val     : string(1 to val'length);
    variable v_num_leading_space : natural            := 0;
    variable v_result            : string(1 to width) := (others => ' ');
  begin
    -- Remove leading space if format_spaces is SKIP_LEADING_SPACE
    if format_spaces = SKIP_LEADING_SPACE then
      -- Find how many leading spaces there are
      while ((val(v_num_leading_space + 1) = ' ') and (v_num_leading_space < v_val_length)) loop
        v_num_leading_space := v_num_leading_space + 1;
      end loop;
      -- Remove leading space if any
      v_formatted_val := pad_string(remove_initial_chars(val, v_num_leading_space), ' ', v_formatted_val'length, LEFT);
      v_val_length    := v_val_length - v_num_leading_space;
    else
      v_formatted_val := val;
    end if;

    -- Truncate and return if the string is wider that allowed
    if v_val_length >= width then
      if (truncate = ALLOW_TRUNCATE) then
        return v_formatted_val(1 to width);
      else
        return v_formatted_val(1 to v_val_length);
      end if;
    end if;

    -- Justify if string is within the width specifications
    v_start_pos                                             := natural(ceil((real(width) - real(v_val_length)) / real(2))) + 1;
    v_result(v_start_pos to v_start_pos + v_val_length - 1) := v_formatted_val(1 to v_val_length);

    return v_result;
  end function;

  function pos_of_leftmost(
    target              : character;
    vector              : string;
    result_if_not_found : natural := 1
  ) return natural is
    alias a_vector : string(1 to vector'length) is vector;
  begin
    bitvis_assert(vector'length > 0, FAILURE, "String input is empty", "pos_of_leftmost()");
    bitvis_assert(vector'ascending, FAILURE, "Only implemented for string(N to M)", "pos_of_leftmost()");
    for i in a_vector'left to a_vector'right loop
      if (a_vector(i) = target) then
        return i;
      end if;
    end loop;
    return result_if_not_found;
  end;

  function pos_of_rightmost(
    target              : character;
    vector              : string;
    result_if_not_found : natural := 1
  ) return natural is
    alias a_vector : string(1 to vector'length) is vector;
  begin
    bitvis_assert(vector'length > 0, FAILURE, "String input is empty", "pos_of_rightmost()");
    bitvis_assert(vector'ascending, FAILURE, "Only implemented for string(N to M)", "pos_of_rightmost()");
    for i in a_vector'right downto a_vector'left loop
      if (a_vector(i) = target) then
        return i;
      end if;
    end loop;
    return result_if_not_found;
  end;

  function pos_of_leftmost_non_zero(
    vector              : string;
    result_if_not_found : natural := 1
  ) return natural is
    alias a_vector : string(1 to vector'length) is vector;
  begin
    bitvis_assert(vector'length > 0, FAILURE, "String input is empty", "pos_of_leftmost_non_zero()");
    for i in a_vector'left to a_vector'right loop
      if (a_vector(i) /= '0' and a_vector(i) /= ' ') then
        return i;
      end if;
    end loop;
    return result_if_not_found;
  end;

  function pos_of_rightmost_non_whitespace(
    vector              : string;
    result_if_not_found : natural := 1
  ) return natural is
    alias a_vector : string(1 to vector'length) is vector;
  begin
    bitvis_assert(vector'length > 0, FAILURE, "String input is empty", "pos_of_rightmost_non_whitespace()");
    for i in a_vector'right downto a_vector'left loop
      if a_vector(i) /= ' ' then
        return i;
      end if;
    end loop;
    return result_if_not_found;
  end;

  function valid_length(                -- of string excluding trailing NULs
    vector : string
  ) return natural is
  begin
    return pos_of_leftmost(NUL, vector, vector'length + 1) - 1;
  end;

  function string_contains_char(
    val  : string;
    char : character
  ) return boolean is
    alias a_val : string(1 to val'length) is val;
  begin
    if (val'length = 0) then
      return false;
    else
      for i in val'left to val'right loop
        if (val(i) = char) then
          return true;
        end if;
      end loop;
      -- falls through only if not found
      return false;
    end if;
  end;

  -- get_*_name
  -- Note: for sub-programs the following is given: library:package:procedure:object
  -- Note: for design hierachy the following is given: complete hierarchy from sim-object down to process object
  -- e.g.  'sbi_tb:i_test_harness:i2_sbi_vvc:p_constructor:v_msg'
  -- Attribute instance_name also gives [procedure signature] or @entity-name(architecture name)
  function get_string_between_delimiters(
    val         : string;
    delim_left  : character;
    delim_right : character;
    start_from  : SIDE;                 -- search from left or right  (Only RIGHT implemented so far)
    occurrence  : positive := 1         -- stop on N'th occurrence of delimeter pair. Default first occurrence
  ) return string is
    variable v_left       : natural := 0;
    variable v_right      : natural := 0;
    variable v_start      : natural := val'length;
    variable v_occurrence : natural := 0;
    alias a_val           : string(1 to val'length) is val;
  begin
    bitvis_assert(a_val'length > 2, FAILURE, "String input is not wide enough (<3)", "get_string_between_delimiters()");
    bitvis_assert(start_from = RIGHT, FAILURE, "Only search from RIGHT is implemented so far", "get_string_between_delimiters()");
    loop
      --      RIGHT
      v_left  := 0;                     -- default
      v_right := pos_of_rightmost(delim_right, a_val(1 to v_start), 0);
      if v_right > 0 then               -- i.e. found
        L1 : for i in v_right - 1 downto 1 loop -- searching backwards for delimeter
          if (a_val(i) = delim_left) then
            v_left       := i;
            v_start      := i;          -- Previous end delimeter could also be a start delimeter for next section
            v_occurrence := v_occurrence + 1;
            exit L1;
          end if;
        end loop;                       -- searching backwards
      end if;
      if v_right = 0 or v_left = 0 then
        return "";                      -- No delimeter pair found, and none can be found in the rest (with chars in between)
      end if;
      if v_occurrence = occurrence then
        -- Match
        if (v_right - v_left) < 2 then
          return "";                    -- no chars in between delimeters
        else
          return a_val(v_left + 1 to v_right - 1);
        end if;
      end if;
      if v_start < 3 then
        return "";                      -- No delimeter pair found, and none can be found in the rest (with chars in between)
      end if;
    end loop;                           -- Will continue until match or not found
  end;

  -- ':sbi_tb(func):i_test_harness@test_harness(struct):i2_sbi_vvc@sbi_vvc(struct):p_constructor:instance'
  -- ':sbi_tb:i_test_harness:i1_sbi_vvc:p_constructor:instance'
  -- - Process name: Search for 2nd last param in path name
  -- - Entity name: Search for 3nd last param in path name

  --':bitvis_vip_sbi:sbi_bfm_pkg:sbi_write[unsigned,std_logic_vector,string,std_logic,std_logic,unsigned,
  --     std_logic,std_logic,std_logic,std_logic_vector,time,string,t_msg_id_panel,t_sbi_config]:msg'
  -- - Procedure name: Search for 2nd last param in path name and remove all inside []

  impure function get_procedure_name_from_instance_name(
    val : string
  ) return string is
    variable v_line     : line;
    variable v_msg_line : line;
    impure function return_and_deallocate return string is
      constant C_RET : string := v_line.all;
    begin
      DEALLOCATE(v_line);
      return C_RET;
    end function;
  begin
    bitvis_assert(val'length > 2, FAILURE, "String input is not wide enough (<3)", "get_procedure_name_from_instance_name()");
    write(v_line, get_string_between_delimiters(val, ':', '[', RIGHT));
    if (string_contains_char(val, '@')) then
      write(v_msg_line, string'("Must be called with <sub-program object>'instance_name"));
    else
      write(v_msg_line, string'(" "));
    end if;
    bitvis_assert(v_line'length > 0, ERROR, "No procedure name found. " & v_msg_line.all, "get_procedure_name_from_instance_name()");
    DEALLOCATE(v_msg_line);
    return return_and_deallocate;
  end;

  impure function get_process_name_from_instance_name(
    val : string
  ) return string is
    variable v_line     : line;
    variable v_msg_line : line;
    impure function return_and_deallocate return string is
      constant C_RET : string := v_line.all;
    begin
      DEALLOCATE(v_line);
      return C_RET;
    end function;
  begin
    bitvis_assert(val'length > 2, FAILURE, "String input is not wide enough (<3)", "get_process_name_from_instance_name()");
    write(v_line, get_string_between_delimiters(val, ':', ':', RIGHT));
    if (string_contains_char(val, '[')) then
      write(v_msg_line, string'("Must be called with <process-local object>'instance_name"));
    else
      write(v_msg_line, string'(" "));
    end if;
    bitvis_assert(v_line'length > 0, ERROR, "No process name found", "get_process_name_from_instance_name()");
    deallocate(v_msg_line);
    return return_and_deallocate;
  end;

  impure function get_entity_name_from_instance_name(
    val : string
  ) return string is
    variable v_line     : line;
    variable v_msg_line : line;
    impure function return_and_deallocate return string is
      constant C_RET : string := v_line.all;
    begin
      DEALLOCATE(v_line);
      return C_RET;
    end function;
  begin
    bitvis_assert(val'length > 2, FAILURE, "String input is not wide enough (<3)", "get_entity_name_from_instance_name()");
    if string_contains_char(val, '@') then -- for path with instantiations
      write(v_line, get_string_between_delimiters(val, '@', '(', RIGHT));
    else                                -- for path with only a single entity
      write(v_line, get_string_between_delimiters(val, ':', '(', RIGHT));
    end if;
    if (string_contains_char(val, '[')) then
      write(v_msg_line, string'("Must be called with <Entity/arch-local object>'instance_name"));
    else
      write(v_msg_line, string'(" "));
    end if;
    bitvis_assert(v_line'length > 0, ERROR, "No entity name found", "get_entity_name_from_instance_name()");
    deallocate(v_msg_line);
    return return_and_deallocate;
  end;

  function adjust_leading_0(
    val    : string;
    format : t_format_zeros := SKIP_LEADING_0
  ) return string is
    alias a_val                  : string(1 to val'length) is val;
    constant C_LEFTMOST_NON_ZERO : natural := pos_of_leftmost_non_zero(a_val, 1);
  begin
    if val'length <= 1 then
      return val;
    end if;
    if format = SKIP_LEADING_0 then
      return a_val(C_LEFTMOST_NON_ZERO to val'length);
    else
      return a_val;
    end if;
  end function;

  function return_string_if_true(
    val        : string;
    return_val : boolean
  ) return string is
  begin
    if return_val then
      return val;
    else
      return "";
    end if;
  end function;

  function return_string1_if_true_otherwise_string2(
    val1       : string;
    val2       : string;
    return_val : boolean
  ) return string is
  begin
    if return_val then
      return val1;
    else
      return val2;
    end if;
  end function;

  function replace_backslash_n_with_lf(
    source : string
  ) return string is
    constant C_SOURCE_NORMALISED  : string(1 to source'length) := source;
    variable v_source_idx         : natural := 0;
    variable v_dest_idx           : natural := 0;
    variable v_dest               : string(1 to source'length);
  begin
    if C_SOURCE_NORMALISED'length = 0 then
      return "";
    else
      if C_USE_BACKSLASH_N_AS_LF then
        loop
          v_source_idx := v_source_idx + 1;
          v_dest_idx   := v_dest_idx + 1;
          if (v_source_idx < C_SOURCE_NORMALISED'length) then
            if (C_SOURCE_NORMALISED(v_source_idx to v_source_idx + 1) /= "\n") then
              v_dest(v_dest_idx) := C_SOURCE_NORMALISED(v_source_idx);
            else
              v_dest(v_dest_idx) := LF;
              v_source_idx       := v_source_idx + 1; -- Additional increment as two chars (\n) are consumed
              if (v_source_idx = C_SOURCE_NORMALISED'length) then
                exit;
              end if;
            end if;
          else
            -- Final character in string
            v_dest(v_dest_idx) := C_SOURCE_NORMALISED(v_source_idx);
            exit;
          end if;
        end loop;
      else
        v_dest     := C_SOURCE_NORMALISED;
        v_dest_idx := C_SOURCE_NORMALISED'length;
      end if;
      return v_dest(1 to v_dest_idx);
    end if;
  end;

  function replace_backslash_r_with_lf(
    source : string
  ) return string is
    constant C_SOURCE_NORMALISED  : string(1 to source'length) := source;
    variable v_source_idx         : natural := 0;
    variable v_dest_idx           : natural := 0;
    variable v_dest               : string(1 to source'length);
  begin
    if C_SOURCE_NORMALISED'length = 0 then
      return "";
    else
      if C_USE_BACKSLASH_R_AS_LF then
        loop
          if (C_SOURCE_NORMALISED(v_source_idx to v_source_idx + 1) = "\r") then
            v_dest_idx         := v_dest_idx + 1;
            v_dest(v_dest_idx) := LF;
            v_source_idx       := v_source_idx + 2;
          else
            exit;
          end if;
        end loop;
      else
        return "";
      end if;
    end if;
    return v_dest(1 to v_dest_idx);
  end;

  function remove_initial_chars(
    source : string;
    num    : natural
  ) return string is
    constant C_SOURCE_NORMALISED  : string(1 to source'length) := source;
  begin
    if C_SOURCE_NORMALISED'length <= num then
      return "";
    else
      return C_SOURCE_NORMALISED(1 + num to C_SOURCE_NORMALISED'right);
    end if;
  end;

  function wrap_lines(
    constant text_string    : string;
    constant alignment_pos1 : natural;  -- Line position of first aligned character in line 1
    constant alignment_pos2 : natural;  -- Line position of first aligned character in line 2
    constant line_width     : natural
  ) return string is
    variable v_text_lines   : line;
    variable v_result       : string(1 to 2 * text_string'length + alignment_pos1 + 100); -- Margin for aligns and LF insertions
    variable v_result_width : natural;
  begin
    write(v_text_lines, text_string);
    wrap_lines(v_text_lines, alignment_pos1, alignment_pos2, line_width);
    v_result_width                := v_text_lines'length;
    bitvis_assert(v_result_width <= v_result'length, FAILURE,
                  " String is too long after wrapping. Increase v_result string size.", "wrap_lines()");
    v_result(1 to v_result_width) := v_text_lines.all;
    deallocate(v_text_lines);
    return v_result(1 to v_result_width);
  end;

  procedure wrap_lines(
    variable text_lines     : inout line;
    constant alignment_pos1 : natural;  -- Line position of first aligned character in line 1
    constant alignment_pos2 : natural;  -- Line position of first aligned character in line 2
    constant line_width     : natural
  ) is
    constant C_TEXT_LINES_STR       : string(1 to text_lines'length) := text_lines.all;
    constant C_TEXT_LINES_STR_WIDTH : natural                        := text_lines'length;
    variable v_line_no              : natural                        := 0;
    variable v_last_string_wrap     : natural                        := 0;
    variable v_min_string_wrap      : natural;
    variable v_max_string_wrap      : natural;
  begin
    deallocate(text_lines);             -- empty the line prior to filling it up again
    l_line : loop                       -- For every tekstline found in text_lines
      v_line_no := v_line_no + 1;
      -- Find position to wrap in C_TEXT_LINES_STR
      if (v_line_no = 1) then
        v_min_string_wrap := 1;         -- Minimum 1 character of input line
        v_max_string_wrap := minimum(line_width - alignment_pos1 + 1, C_TEXT_LINES_STR_WIDTH);
        write(text_lines, fill_string(' ', alignment_pos1 - 1));
      else
        v_min_string_wrap := v_last_string_wrap + 1; -- Minimum 1 character further into the inpit line
        v_max_string_wrap := minimum(v_last_string_wrap + (line_width - alignment_pos2 + 1), C_TEXT_LINES_STR_WIDTH);
        write(text_lines, fill_string(' ', alignment_pos2 - 1));
      end if;

      -- 1. First handle any potential explicit line feed in the current maximum text line
      -- Search forward for potential LF
      for i in (v_last_string_wrap + 1) to minimum(v_max_string_wrap + 1, C_TEXT_LINES_STR_WIDTH) loop
        if (character(C_TEXT_LINES_STR(i)) = LF) then
          write(text_lines, C_TEXT_LINES_STR((v_last_string_wrap + 1) to i)); -- LF now terminates this part
          v_last_string_wrap := i;
          next l_line;                  -- next line
        end if;
      end loop;

      -- 2. Then check if remaining text fits into a single text line
      if (C_TEXT_LINES_STR_WIDTH <= v_max_string_wrap) then
        -- No (more) wrapping required
        write(text_lines, C_TEXT_LINES_STR((v_last_string_wrap + 1) to C_TEXT_LINES_STR_WIDTH));
        exit;                           -- No more lines
      end if;

      -- 3. Search for blanks from char after max msg width and downwards (in the left direction)
      for i in v_max_string_wrap + 1 downto (v_last_string_wrap + 1) loop
        if (character(C_TEXT_LINES_STR(i)) = ' ') then
          write(text_lines, C_TEXT_LINES_STR((v_last_string_wrap + 1) to i - 1)); -- Exchange last blank with LF
          v_last_string_wrap := i;
          if (i = C_TEXT_LINES_STR_WIDTH) then
            exit l_line;
          end if;
          -- Skip any potential extra blanks in the string
          for j in (i + 1) to C_TEXT_LINES_STR_WIDTH loop
            if (C_TEXT_LINES_STR(j) = ' ') then
              v_last_string_wrap := j;
              if (j = C_TEXT_LINES_STR_WIDTH) then
                exit l_line;
              end if;
            else
              write(text_lines, LF);    -- Exchange last blanks with LF, provided not at the end of the string
              exit;
            end if;
          end loop;
          next l_line;                  -- next line
        end if;
      end loop;

      -- 4. At this point no LF or blank is found in the searched section of the string.
      --    Hence just break the string - and continue.
      write(text_lines, C_TEXT_LINES_STR((v_last_string_wrap + 1) to v_max_string_wrap) & LF); -- Added LF termination
      v_last_string_wrap := v_max_string_wrap;
    end loop;
  end;

  procedure prefix_lines(
    variable text_lines : inout line;
    constant prefix     : string := C_LOG_PREFIX
  ) is
    constant C_TEXT_LINES_STR       : string(1 to text_lines'length) := text_lines.all;
    constant C_TEXT_LINES_STR_WIDTH : natural                        := text_lines'length;
    constant prefix_width           : natural                        := prefix'length;
    variable v_last_string_wrap     : natural                        := 0;
    variable v_i                    : natural                        := 0; -- for indexing text_lines_str
  begin
    deallocate(text_lines);             -- empty the line prior to filling it up again
    l_line : loop
      -- 1. Write prefix
      write(text_lines, prefix);
      -- 2. Write rest of text line (or rest of input line if no LF)
      l_char : loop
        v_i := v_i + 1;
        if (v_i < C_TEXT_LINES_STR_WIDTH) then
          if (character(C_TEXT_LINES_STR(v_i)) = LF) then
            write(text_lines, C_TEXT_LINES_STR((v_last_string_wrap + 1) to v_i));
            v_last_string_wrap := v_i;
            exit l_char;
          end if;
        else
          -- 3. Reached end of string. Hence just write the rest.
          write(text_lines, C_TEXT_LINES_STR((v_last_string_wrap + 1) to C_TEXT_LINES_STR_WIDTH));
          --    But ensure new line with prefix if ending with LF
          if (C_TEXT_LINES_STR(v_i) = LF) then
            write(text_lines, prefix);
          end if;
          exit l_char;
        end if;
      end loop;
      if (v_i = C_TEXT_LINES_STR_WIDTH) then
        exit;
      end if;
    end loop;
  end;

  function replace(
    val           : string;
    target_char   : character;
    exchange_char : character
  ) return string is
    variable v_result : string(1 to val'length) := val;
  begin
    for i in val'range loop
      if val(i) = target_char then
        v_result(i) := exchange_char;
      end if;
    end loop;
    return v_result;
  end;

  procedure replace(
    variable text_line : inout line;
    target_char        : character;
    exchange_char      : character
  ) is
    variable v_string       : string(1 to text_line'length) := text_line.all;
    variable v_string_width : natural                       := text_line'length;
    variable v_i            : natural                       := 0; -- for indexing v_string
  begin
    if v_string_width > 0 then
      deallocate(text_line);            -- empty the line prior to filling it up again
      -- 1. Loop through string and replace characters
      l_char : loop
        v_i := v_i + 1;
        if (v_i < v_string_width) then
          if (character(v_string(v_i)) = target_char) then
            v_string(v_i) := exchange_char;
          end if;
        else
          -- 2. Reached end of string. Hence just write the new string.
          write(text_line, v_string);
          exit l_char;
        end if;
      end loop;
    end if;
  end;

  --========================================================
  -- Handle missing overloads from 'standard_additions' + advanced overloads
  --========================================================

  function to_string(
    val           : boolean;
    width         : natural;
    justified     : side;
    format_spaces : t_format_spaces;
    truncate      : t_truncate_string := DISALLOW_TRUNCATE
  ) return string is
  begin
    return justify(to_string(val), justified, width, format_spaces, truncate);
  end;

  impure function to_string(
    val           : integer;
    width         : natural;
    justified     : side;
    format_spaces : t_format_spaces;
    truncate      : t_truncate_string := DISALLOW_TRUNCATE;
    radix         : t_radix           := DEC;
    prefix        : t_radix_prefix    := EXCL_RADIX;
    format        : t_format_zeros    := SKIP_LEADING_0 -- | KEEP_LEADING_0
  ) return string is
    variable v_val_slv      : std_logic_vector(31 downto 0) := std_logic_vector(to_signed(val, 32));
    variable v_line         : line;
    variable v_width        : natural;
    variable v_use_end_char : boolean                       := false;
    impure function return_and_deallocate return string is
      constant C_RET : string := v_line.all;
    begin
      DEALLOCATE(v_line);
      return C_RET;
    end function;

  begin
    if radix = DEC then
      if prefix = INCL_RADIX then
        write(v_line, string'("d"""));
        v_use_end_char := true;
      end if;
      write(v_line, justify(to_string(val), justified, width, format_spaces, truncate));
    elsif radix = BIN then
      if prefix = INCL_RADIX then
        write(v_line, string'("b"""));
        v_use_end_char := true;
      end if;
      write(v_line, adjust_leading_0(justify(to_string(v_val_slv), justified, width, format_spaces, truncate), format));
    else                                -- HEX
      if prefix = INCL_RADIX then
        write(v_line, string'("x"""));
        v_use_end_char := true;
      end if;
      write(v_line, adjust_leading_0(justify(to_hstring(v_val_slv), justified, width, format_spaces, truncate), format));
    end if;
    if v_use_end_char then
      write(v_line, string'(""""));
    end if;
    return return_and_deallocate;
  end;

  impure function to_string(
    val    : integer;
    radix  : t_radix;
    prefix : t_radix_prefix;
    format : t_format_zeros := SKIP_LEADING_0 -- | KEEP_LEADING_0
  ) return string is
    variable v_line : line;
    variable v_len  : natural;
  begin
    write(v_line, to_string(val));
    v_len := v_line'length;
    deallocate(v_line);
    return to_string(val, v_len, LEFT, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE, radix, prefix, format);
  end;

  -- This function has been deprecated and will be removed in the next major release
  function to_string(
    val       : boolean;
    width     : natural;
    justified : side            := right;
    format    : t_format_string := AS_IS
  ) return string is
  begin
    return justify(to_string(val), width, justified, format);
  end;

  -- This function has been deprecated and will be removed in the next major release
  function to_string(
    val       : integer;
    width     : natural;
    justified : side            := right;
    format    : t_format_string := AS_IS
  ) return string is
  begin
    return justify(to_string(val), width, justified, format);
  end;

  function to_string(
    val    : std_logic_vector;
    radix  : t_radix;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is
    variable v_line         : line;
    alias a_val             : std_logic_vector(val'length - 1 downto 0) is val;
    variable v_result       : string(1 to 10 + 2 * val'length); --
    variable v_width        : natural;
    variable v_use_end_char : boolean := false;
  begin
    if val'length = 0 then
      -- Value length is zero,
      -- return empty string.
      return "";
    end if;

    if radix = BIN then
      if prefix = INCL_RADIX then
        write(v_line, string'("b"""));
        v_use_end_char := true;
      end if;
      write(v_line, adjust_leading_0(to_string(val), format));
    elsif radix = HEX then
      if prefix = INCL_RADIX then
        write(v_line, string'("x"""));
        v_use_end_char := true;
      end if;
      write(v_line, adjust_leading_0(to_hstring(val), format));
    elsif radix = DEC then
      -- Assuming that val is not signed
      if (val'length > 31) then
        if prefix = INCL_RADIX then
          write(v_line, string'("x"""));
          v_use_end_char := true;
        end if;
        write(v_line, to_hstring(val) & " (too wide to be converted to integer)");
      else
        if prefix = INCL_RADIX then
          write(v_line, string'("d"""));
          v_use_end_char := true;
        end if;
        write(v_line, adjust_leading_0(to_string(to_integer(unsigned(val))), format));
      end if;
    elsif radix = HEX_BIN_IF_INVALID then
      if prefix = INCL_RADIX then
        write(v_line, string'("x"""));
      end if;
      if is_x(val) then
        write(v_line, adjust_leading_0(to_hstring(val), format));
        if prefix = INCL_RADIX then
          write(v_line, string'("""")); -- terminate hex value
        end if;
        write(v_line, string'(" (b"""));
        write(v_line, adjust_leading_0(to_string(val), format));
        write(v_line, string'(""""));
        write(v_line, string'(")"));
      else
        write(v_line, adjust_leading_0(to_hstring(val), format));
        if prefix = INCL_RADIX then
          write(v_line, string'(""""));
        end if;
      end if;
    end if;
    if v_use_end_char then
      write(v_line, string'(""""));
    end if;

    v_width                := v_line'length;
    v_result(1 to v_width) := v_line.all;
    deallocate(v_line);
    return v_result(1 to v_width);
  end;

  function to_string(
    val    : unsigned;
    radix  : t_radix;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is
  begin
    return to_string(std_logic_vector(val), radix, format, prefix);
  end;

  function to_string(
    val    : signed;
    radix  : t_radix;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is
    variable v_line         : line;
    variable v_result       : string(1 to 20 + 2 * val'length); --
    variable v_width        : natural;
    variable v_use_end_char : boolean := false;
  begin
    -- Support negative numbers by _not_ using the slv overload when converting to decimal
    if radix = DEC then
      if val'length = 0 then
        -- Value length is zero,
        -- return empty string.
        return "";
      end if;

      if (val'length > 32) then
        write(v_line, to_string(std_logic_vector(val), HEX, format, prefix) & " (too wide to be converted to integer)");
      else
        if prefix = INCL_RADIX then
          write(v_line, string'("d"""));
          v_use_end_char := true;
        end if;
        write(v_line, adjust_leading_0(to_string(to_integer(signed(val))), format));
      end if;

      if v_use_end_char then
        write(v_line, string'(""""));
      end if;

      v_width                := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);

    else                                -- No decimal convertion: May be treated as slv, so use the slv overload
      return to_string(std_logic_vector(val), radix, format, prefix);
    end if;
  end;

  function to_string(
    val    : t_slv_array;
    radix  : t_radix        := HEX_BIN_IF_INVALID;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is

    -- helper function to prevent null arrays
    function get_string_len(val : t_slv_array) return integer is
      variable v_parantheses           : integer := 2; -- Parentheses
      variable v_commas                : integer := 0; -- Commas (and spaces)
      variable v_radix_prefix          : integer := 0; -- Radix prefixes (and enclosing quotes)
      variable v_max_array_element_len : integer := 0; -- Maximum length of the array elements (accounts for radix size and message "(too wide to be converted to integer)")
      variable v_line                  : line;
    begin
      if val'length > 0 then
        v_commas       := 2 * (val'length - 1);
        v_radix_prefix := 3 * val'length;
        for i in val'range loop
          write(v_line, to_string(val(i), radix));
          v_max_array_element_len := v_max_array_element_len + v_line'length;
          deallocate(v_line);
        end loop;
      end if;
      return (v_parantheses + v_commas + v_radix_prefix + v_max_array_element_len);
    end function;

    variable v_line   : line;
    variable v_result : string(1 to get_string_len(val));
    variable v_width  : natural;
  begin
    if val'length = 0 then
      return "";
    else
      -- Comma-separate all array members and return
      write(v_line, string'("("));

      for idx in val'range loop
        write(v_line, to_string(val(idx), radix, format, prefix));

        if (idx < val'right) and (val'ascending) then
          write(v_line, string'(", "));
        elsif (idx > val'right) and not (val'ascending) then
          write(v_line, string'(", "));
        end if;

      end loop;
      write(v_line, string'(")"));

      v_width                := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);
    end if;
  end function;

  function to_string(
    val    : t_signed_array;
    radix  : t_radix        := HEX_BIN_IF_INVALID;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is

    -- helper function to prevent null arrays
    function get_string_len(val : t_signed_array) return integer is
      variable v_parantheses           : integer := 2; -- Parentheses
      variable v_commas                : integer := 0; -- Commas (and spaces)
      variable v_radix_prefix          : integer := 0; -- Radix prefixes (and enclosing quotes)
      variable v_max_array_element_len : integer := 0; -- Maximum length of the array elements (accounts for radix size and message "(too wide to be converted to integer)")
      variable v_line                  : line;
    begin
      if val'length > 0 then
        v_commas       := 2 * (val'length - 1);
        v_radix_prefix := 3 * val'length;
        for i in val'range loop
          write(v_line, to_string(val(i), radix));
          v_max_array_element_len := v_max_array_element_len + v_line'length;
          deallocate(v_line);
        end loop;
      end if;
      return (v_parantheses + v_commas + v_radix_prefix + v_max_array_element_len);
    end function;

    variable v_line   : line;
    variable v_result : string(1 to get_string_len(val));
    variable v_width  : natural;
  begin
    if val'length = 0 then
      return "";
    else
      -- Comma-separate all array members and return
      write(v_line, string'("("));

      for idx in val'range loop
        write(v_line, to_string(val(idx), radix, format, prefix));

        if (idx < val'right) and (val'ascending) then
          write(v_line, string'(", "));
        elsif (idx > val'right) and not (val'ascending) then
          write(v_line, string'(", "));
        end if;

      end loop;
      write(v_line, string'(")"));

      v_width                := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);
    end if;
  end function;

  function to_string(
    val    : t_unsigned_array;
    radix  : t_radix        := HEX_BIN_IF_INVALID;
    format : t_format_zeros := KEEP_LEADING_0; -- | SKIP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is

    -- helper function to prevent null arrays
    function get_string_len(val : t_unsigned_array) return integer is
      variable v_parantheses           : integer := 2; -- Parentheses
      variable v_commas                : integer := 0; -- Commas (and spaces)
      variable v_radix_prefix          : integer := 0; -- Radix prefixes (and enclosing quotes)
      variable v_max_array_element_len : integer := 0; -- Maximum length of the array elements (accounts for radix size and message "(too wide to be converted to integer)")
      variable v_line                  : line;
    begin
      if val'length > 0 then
        v_commas       := 2 * (val'length - 1);
        v_radix_prefix := 3 * val'length;
        for i in val'range loop
          write(v_line, to_string(val(i), radix));
          v_max_array_element_len := v_max_array_element_len + v_line'length;
          deallocate(v_line);
        end loop;
      end if;
      return (v_parantheses + v_commas + v_radix_prefix + v_max_array_element_len);
    end function;

    variable v_line   : line;
    variable v_result : string(1 to get_string_len(val));
    variable v_width  : natural;
  begin
    if val'length = 0 then
      return "";
    else
      -- Comma-separate all array members and return
      write(v_line, string'("("));

      for idx in val'range loop
        write(v_line, to_string(val(idx), radix, format, prefix));

        if (idx < val'right) and (val'ascending) then
          write(v_line, string'(", "));
        elsif (idx > val'right) and not (val'ascending) then
          write(v_line, string'(", "));
        end if;

      end loop;
      write(v_line, string'(")"));

      v_width                := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);
    end if;
  end function;

  impure function to_string(
    val    : integer_vector;
    radix  : t_radix        := DEC;
    format : t_format_zeros := SKIP_LEADING_0; -- | KEEP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is
    variable v_line   : line;
    variable v_result : string(1 to 2 + -- parentheses
    2 * (val'length - 1) +              -- commas
    32 * val'length);
    variable v_width : natural;
  begin
    if val'length = 0 then
      return "";
    else
      -- Comma-separate all array members and return
      write(v_line, string'("("));

      for idx in val'range loop
        write(v_line, to_string(val(idx), radix, prefix, format));

        if (idx < val'right) and (val'ascending) then
          write(v_line, string'(", "));
        elsif (idx > val'right) and not (val'ascending) then
          write(v_line, string'(", "));
        end if;

      end loop;
      write(v_line, string'(")"));

      v_width                := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);
    end if;
  end function;

  impure function to_string(
    val    : t_natural_vector;
    radix  : t_radix        := DEC;
    format : t_format_zeros := SKIP_LEADING_0; -- | KEEP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is
  begin
    return to_string(integer_vector(val), radix, format, prefix);
  end function;

  impure function to_string(
    val    : t_positive_vector;
    radix  : t_radix        := DEC;
    format : t_format_zeros := SKIP_LEADING_0; -- | KEEP_LEADING_0
    prefix : t_radix_prefix := EXCL_RADIX -- Insert radix prefix in string?
  ) return string is
  begin
    return to_string(integer_vector(val), radix, format, prefix);
  end function;

  function to_string(
    val : real_vector
  ) return string is
    variable v_line   : line;
    variable v_result : string(1 to 2 + -- parentheses
    2 * (val'length - 1) +              -- commas
    32 * val'length);
    variable v_width : natural;
  begin
    if val'length = 0 then
      return "";
    else
      -- Comma-separate all array members and return
      write(v_line, string'("("));

      for idx in val'range loop
        write(v_line, to_string(val(idx)));

        if (idx < val'right) and (val'ascending) then
          write(v_line, string'(", "));
        elsif (idx > val'right) and not (val'ascending) then
          write(v_line, string'(", "));
        end if;

      end loop;
      write(v_line, string'(")"));

      v_width                := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);
    end if;
  end function;

  function to_string(
    val : time_vector
  ) return string is
    variable v_line   : line;
    variable v_result : string(1 to 2 + -- parentheses
    2 * (val'length - 1) +              -- commas
    32 * val'length);
    variable v_width : natural;
  begin
    if val'length = 0 then
      return "";
    else
      -- Comma-separate all array members and return
      write(v_line, string'("("));

      for idx in val'range loop
        write(v_line, to_string(val(idx)));

        if (idx < val'right) and (val'ascending) then
          write(v_line, string'(", "));
        elsif (idx > val'right) and not (val'ascending) then
          write(v_line, string'(", "));
        end if;

      end loop;
      write(v_line, string'(")"));

      v_width                := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);
    end if;
  end function;

  --========================================================
  -- Handle types defined at lower levels
  --========================================================

  function to_string(
    val       : t_alert_level;
    width     : natural;
    justified : side := right
  ) return string is
    constant C_INNER_STRING : string := t_alert_level'image(val);
  begin
    return to_upper(justify(C_INNER_STRING, justified, width));
  end function;

  function to_string(
    val       : t_msg_id;
    width     : natural;
    justified : side := right
  ) return string is
    constant C_INNER_STRING : string := t_msg_id'image(val);
  begin
    return to_upper(justify(C_INNER_STRING, justified, width));
  end function;

  function to_string(
    val       : t_attention;
    width     : natural;
    justified : side := right
  ) return string is
  begin
    return to_upper(justify(t_attention'image(val), justified, width));
  end;

  function to_string(
    val       : t_check_type;
    width     : natural;
    justified : side := right
  ) return string is
    constant C_INNER_STRING : string := t_check_type'image(val);
  begin
    return to_upper(justify(C_INNER_STRING, justified, width));
  end function;

  procedure to_string(
    val   : t_alert_attention_counters;
    order : t_order := FINAL
  ) is
    variable v_line                            : line;
    variable v_line_copy                       : line;
    variable v_more_than_expected_alerts       : boolean := false;
    variable v_less_than_expected_alerts       : boolean := false;
    variable v_more_than_expected_minor_alerts : boolean := false;
    variable v_less_than_expected_minor_alerts : boolean := false;
    constant C_PREFIX                          : string  := C_LOG_PREFIX & "     ";

    -- NOTE, TB_NOTE, WARNING, TB_WARNING, MANUAL_CHECK
  begin
    if order = INTERMEDIATE then
      write(v_line,
            LF &
            fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
            "*** INTERMEDIATE SUMMARY OF ALL ALERTS ***" & LF &
            fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
            "                          REGARDED   EXPECTED  IGNORED      Comment?" & LF);
    else                                -- order=FINAL
      write(v_line,
            LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
            "*** FINAL SUMMARY OF ALL ALERTS ***" & LF &
            fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
            "                          REGARDED   EXPECTED  IGNORED      Comment?" & LF);
    end if;

    for i in NOTE to t_alert_level'right loop
      write(v_line, "          " & to_upper(to_string(i, 13, LEFT)) & ": "); -- Severity
      for j in t_attention'left to t_attention'right loop
        write(v_line, to_string(integer'(val(i)(j)), 6, RIGHT, KEEP_LEADING_SPACE) & "    ");
      end loop;
      if (val(i)(REGARD) = val(i)(EXPECT)) then
        write(v_line, "     ok" & LF);
      else
        write(v_line, "     *** " & to_string(i, 0) & " ***" & LF);
        if (i > MANUAL_CHECK) then
          if (val(i)(REGARD) < val(i)(EXPECT)) then
            v_less_than_expected_alerts := true;
          else
            v_more_than_expected_alerts := true;
          end if;
        else
          if (val(i)(REGARD) < val(i)(EXPECT)) then
            v_less_than_expected_minor_alerts := true;
          else
            v_more_than_expected_minor_alerts := true;
          end if;
        end if;
      end if;
    end loop;
    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
    -- Print a conclusion when called from the FINAL part of the test sequencer
    -- but not when called from in the middle of the test sequence (order=INTERMEDIATE)
    if order = FINAL then
      if v_more_than_expected_alerts then
        write(v_line, ">> Simulation FAILED, with unexpected serious alert(s)" & LF);
      elsif v_less_than_expected_alerts then
        write(v_line, ">> Simulation FAILED: Mismatch between counted and expected serious alerts" & LF);
      elsif v_more_than_expected_minor_alerts or v_less_than_expected_minor_alerts then
        write(v_line, ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts, but mismatch in minor alerts" & LF);
      else
        write(v_line, ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts" & LF);
      end if;
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);
    end if;

    wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
    prefix_lines(v_line, C_PREFIX);

    -- Write the info string to the target file
    write(v_line_copy, v_line.all);     -- copy line
    writeline(OUTPUT, v_line);
    writeline(LOG_FILE, v_line_copy);
    deallocate(v_line);
    deallocate(v_line_copy);
  end;

  procedure to_string(
    val   : t_check_counters_array;
    order : t_order := FINAL
  ) is
    variable v_line                      : line;
    variable v_line_copy                 : line;
    variable v_more_than_expected_alerts : boolean := false;
    variable v_less_than_expected_alerts : boolean := false;
    constant C_PREFIX                    : string  := C_LOG_PREFIX & "     ";
  begin
    if order = INTERMEDIATE then
      write(v_line,
            LF &
            fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
            "*** INTERMEDIATE SUMMARY OF ALL CHECK COUNTERS ***" & LF &
            fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
    else                                -- order=FINAL
      write(v_line,
            LF &
            fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
            "*** FINAL SUMMARY OF ALL CHECK COUNTERS ***" & LF &
            fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
    end if;

    for i in CHECK_VALUE to t_check_type'right loop
      write(v_line, "          " & to_upper(to_string(i, 22, LEFT)) & ": ");
      write(v_line, to_string(integer'(val(i)), 10, RIGHT, KEEP_LEADING_SPACE) & "    ");
      write(v_line, "" & LF);
    end loop;

    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

    wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
    prefix_lines(v_line, C_PREFIX);

    -- Write the info string to the target file
    write(v_line_copy, v_line.all);     -- copy line
    writeline(OUTPUT, v_line);
    writeline(LOG_FILE, v_line_copy);
    deallocate(v_line);
    deallocate(v_line_copy);
  end;

  -- Convert from ASCII to character
  -- Inputs:
  -- ascii_pos (integer) : ASCII number input
  -- ascii_allow (t_ascii_allow) : Decide what to do with invisible control characters:
  -- - If ascii_allow = ALLOW_ALL (default)  : return the character for any ascii_pos
  -- - If ascii_allow = ALLOW_PRINTABLE_ONLY : return the character only if it is printable
  function ascii_to_char(
    ascii_pos   : integer range 0 to 255; -- Supporting Extended ASCII
    ascii_allow : t_ascii_allow := ALLOW_ALL
  ) return character is
    variable v_printable : boolean := true;
  begin

    if ascii_pos < 32 or                -- NUL, SOH, STX etc
      (ascii_pos >= 128 and ascii_pos < 160) then -- C128 to C159
      v_printable := false;
    end if;

    if ascii_allow = ALLOW_ALL or (ascii_allow = ALLOW_PRINTABLE_ONLY and v_printable) then
      return character'val(ascii_pos);
    else
      return ' ';                       -- Must return something when invisible control signals
    end if;

  end;

  -- Convert from character to ASCII integer
  function char_to_ascii(
    char : character
  ) return integer is
  begin
    return character'pos(char);
  end;

  -- return string with only valid ascii characters
  function to_string(
    val : string
  ) return string is
    variable v_new_string : string(1 to val'length);
    variable v_char_idx   : natural := 0;
    variable v_ascii_pos  : natural;
  begin
    for i in val'range loop
      v_ascii_pos := character'pos(val(i));
      if (v_ascii_pos < 32 and v_ascii_pos /= 10) or -- NUL, SOH, STX etc, LF(10) is not removed.
        (v_ascii_pos >= 128 and v_ascii_pos < 160) then -- C128 to C159
        -- illegal char
        null;
      else
        -- legal char
        v_char_idx               := v_char_idx + 1;
        v_new_string(v_char_idx) := val(i);
      end if;
    end loop;

    if v_char_idx = 0 then
      return "";
    else
      return v_new_string(1 to v_char_idx);
    end if;
  end;

  function add_msg_delimiter(
    msg : string
  ) return string is
  begin
    if msg'length /= 0 then
      if valid_length(msg) /= 1 then
        if msg(1) = C_MSG_DELIMITER then
          return msg;
        else
          return C_MSG_DELIMITER & msg & C_MSG_DELIMITER;
        end if;
      end if;
    end if;
    return "";
  end;

  -- Returns a string with a timestamp and a text. Used in report headers
  function timestamp_header(
    value : time;
    txt   : string
  ) return string is
    constant C_TXT_NORMALISED  : string(1 to txt'length) := txt;
    variable v_line            : line;
    variable v_delimiter_pos   : natural;
    variable v_timestamp_width : natural;
    variable v_result          : string(1 to 50);
    variable v_return          : string(1 to txt'length) := txt;
  begin
    -- get a time stamp
    write(v_line, value, LEFT, 0, C_LOG_TIME_BASE);
    v_timestamp_width                := v_line'length;
    v_result(1 to v_timestamp_width) := v_line.all;
    deallocate(v_line);
    v_delimiter_pos                  := pos_of_leftmost('.', v_result(1 to v_timestamp_width), 0);

    -- truncate decimals and add units
    if v_delimiter_pos > 0 then
      if C_LOG_TIME_BASE = ns then
        v_result(v_delimiter_pos + 2 to v_delimiter_pos + 4) := " ns";
      else
        v_result(v_delimiter_pos + 2 to v_delimiter_pos + 4) := " ps";
      end if;
      v_timestamp_width := v_delimiter_pos + 4;
    end if;
    -- add a space after the timestamp
    v_timestamp_width                                := v_timestamp_width + 1;
    v_result(v_timestamp_width to v_timestamp_width) := " ";

    -- add time string to return string
    v_return := v_result(1 to v_timestamp_width) & C_TXT_NORMALISED(1 to C_TXT_NORMALISED'length - v_timestamp_width);
    return v_return(1 to C_TXT_NORMALISED'length);
  end function timestamp_header;

end package body string_methods_pkg;
