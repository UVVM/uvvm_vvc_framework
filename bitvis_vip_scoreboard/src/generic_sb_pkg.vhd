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
-- Inspired by similar functionality in SystemVerilog/UVM and OSVVM.
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.generic_sb_support_pkg.all;

package generic_sb_pkg is

  generic(type t_element;
          function element_match(received_element : t_element;
                                 expected_element : t_element) return boolean;
          function to_string_element(element : t_element) return string;
          constant sb_config_default        : t_sb_config := C_SB_CONFIG_DEFAULT;
          constant GC_QUEUE_COUNT_MAX       : natural     := 1000;
          constant GC_QUEUE_COUNT_THRESHOLD : natural     := 950);

  type t_generic_sb is protected

    procedure config(
      constant sb_config_array : in t_sb_config_array;
      constant msg             : in string := "");

    procedure config(
      constant instance      : in integer;
      constant sb_config     : in t_sb_config;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure config(
      constant sb_config : in t_sb_config;
      constant msg       : in string := "");

    procedure enable(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure enable(
      constant msg : in string);

    procedure enable(
      constant void : in t_void);

    procedure disable(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure disable(
      constant msg : in string);

    procedure disable(
      constant void : in t_void);

    procedure set_queue_count_max(
      constant instance        : in integer;
      constant queue_count_max : in natural
    );

    procedure set_queue_count_max(
      constant queue_count_max : in natural
    );

    procedure set_queue_count_threshold(
      constant instance                : in integer;
      constant queue_count_alert_level : in natural
    );

    procedure set_queue_count_threshold(
      constant queue_count_alert_level : in natural
    );

    procedure add_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant source           : in string := "";
      constant ext_proc_call    : in string := "");

    procedure add_expected(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant source           : in string := "");

    procedure add_expected(
      constant expected_element : in t_element;
      constant msg              : in string := "";
      constant source           : in string := "");

    procedure add_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant msg              : in string := "";
      constant source           : in string := "");

    procedure check_received(
      constant instance         : in integer;
      constant received_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := "");

    procedure check_received(
      constant received_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "");

    procedure check_received(
      constant instance         : in integer;
      constant received_element : in t_element;
      constant msg              : in string := "");

    procedure check_received(
      constant received_element : in t_element;
      constant msg              : in string := "");

    procedure flush(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure flush(
      constant msg : in string);

    procedure flush(
      constant void : in t_void);

    procedure reset(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure reset(
      constant msg : in string);

    procedure reset(
      constant void : in t_void);

    impure function is_empty(
      constant instance : in integer) return boolean;

    impure function is_empty(
      constant void : in t_void) return boolean;

    impure function get_entered_count(
      constant instance : in integer) return integer;

    impure function get_entered_count(
      constant void : in t_void) return integer;

    impure function get_pending_count(
      constant instance : in integer) return integer;

    impure function get_pending_count(
      constant void : in t_void) return integer;

    impure function get_match_count(
      constant instance : in integer) return integer;

    impure function get_match_count(
      constant void : in t_void) return integer;

    impure function get_mismatch_count(
      constant instance : in integer) return integer;

    impure function get_mismatch_count(
      constant void : in t_void) return integer;

    impure function get_drop_count(
      constant instance : in integer) return integer;

    impure function get_drop_count(
      constant void : in t_void) return integer;

    impure function get_initial_garbage_count(
      constant instance : in integer) return integer;

    impure function get_initial_garbage_count(
      constant void : in t_void) return integer;

    impure function get_delete_count(
      constant instance : in integer) return integer;

    impure function get_delete_count(
      constant void : in t_void) return integer;

    impure function get_overdue_check_count(
      constant instance : in integer) return integer;

    impure function get_overdue_check_count(
      constant void : in t_void) return integer;

    procedure set_scope(
      constant scope : in string);

    impure function get_scope(
      constant void : in t_void) return string;

    procedure enable_log_msg(
      constant instance      : in integer;
      constant msg_id        : in t_msg_id;
      constant ext_proc_call : in string := "");

    procedure enable_log_msg(
      constant msg_id : in t_msg_id);

    procedure disable_log_msg(
      constant instance      : in integer;
      constant msg_id        : in t_msg_id;
      constant ext_proc_call : in string := "");

    procedure disable_log_msg(
      constant msg_id : in t_msg_id);

    procedure report_counters(
      constant instance      : in integer;
      constant ext_proc_call : in string := "");

    procedure report_counters(
      constant void : in t_void);

    procedure insert_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant tag_usage         : in t_tag_usage;
      constant tag               : in string;
      constant msg               : in string := "";
      constant source            : in string := "";
      constant ext_proc_call     : in string := "");

    procedure insert_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant tag_usage         : in t_tag_usage;
      constant tag               : in string;
      constant msg               : in string := "";
      constant source            : in string := "");

    procedure insert_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant msg               : in string := "";
      constant source            : in string := "");

    procedure insert_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant msg               : in string := "";
      constant source            : in string := "");

    procedure delete_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := "");

    procedure delete_expected(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "");

    procedure delete_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant msg              : in string := "");

    procedure delete_expected(
      constant expected_element : in t_element;
      constant msg              : in string := "");

    procedure delete_expected(
      constant instance      : in integer;
      constant tag_usage     : in t_tag_usage;
      constant tag           : in string;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure delete_expected(
      constant tag_usage : in t_tag_usage;
      constant tag       : in string;
      constant msg       : in string := "");

    procedure delete_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive;
      constant msg               : in string := "";
      constant ext_proc_call     : in string := "");

    procedure delete_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive;
      constant msg               : in string := "");

    procedure delete_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option;
      constant msg               : in string := "";
      constant ext_proc_call     : in string := "");

    procedure delete_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option;
      constant msg               : in string := "");

    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_entry_num(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant expected_element : in t_element) return integer;

    impure function find_expected_entry_num(
      constant expected_element : in t_element) return integer;

    impure function find_expected_entry_num(
      constant instance  : in integer;
      constant tag_usage : in t_tag_usage;
      constant tag       : in string) return integer;

    impure function find_expected_entry_num(
      constant tag_usage : in t_tag_usage;
      constant tag       : in string) return integer;

    impure function find_expected_position(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_position(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_position(
      constant instance         : in integer;
      constant expected_element : in t_element) return integer;

    impure function find_expected_position(
      constant expected_element : in t_element) return integer;

    impure function find_expected_position(
      constant instance  : in integer;
      constant tag_usage : in t_tag_usage;
      constant tag       : in string) return integer;

    impure function find_expected_position(
      constant tag_usage : in t_tag_usage;
      constant tag       : in string) return integer;

    impure function peek_expected(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return t_element;

    impure function peek_expected(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return t_element;

    impure function peek_expected(
      constant instance : integer) return t_element;

    impure function peek_expected(
      constant void : t_void) return t_element;

    impure function peek_source(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return string;

    impure function peek_source(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return string;

    impure function peek_source(
      constant instance : integer) return string;

    impure function peek_source(
      constant void : t_void) return string;

    impure function peek_tag(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return string;

    impure function peek_tag(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return string;

    impure function peek_tag(
      constant instance : integer) return string;

    impure function peek_tag(
      constant void : t_void) return string;

    impure function fetch_expected(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := "") return t_element;

    impure function fetch_expected(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "") return t_element;

    impure function fetch_expected(
      constant instance : integer;
      constant msg      : string := "") return t_element;

    impure function fetch_expected(
      constant msg : string) return t_element;

    impure function fetch_expected(
      constant void : t_void) return t_element;

    impure function fetch_source(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := "") return string;

    impure function fetch_source(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "") return string;

    impure function fetch_source(
      constant instance : integer;
      constant msg      : string := "") return string;

    impure function fetch_source(
      constant msg : string) return string;

    impure function fetch_source(
      constant void : t_void) return string;

    impure function fetch_tag(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := "") return string;

    impure function fetch_tag(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "") return string;

    impure function fetch_tag(
      constant instance : integer;
      constant msg      : string := "") return string;

    impure function fetch_tag(
      constant msg : string) return string;

    impure function fetch_tag(
      constant void : t_void) return string;

    impure function exists(
      constant instance         : integer;
      constant expected_element : t_element;
      constant tag_usage        : t_tag_usage := NO_TAG;
      constant tag              : string      := "") return boolean;

    impure function exists(
      constant expected_element : t_element;
      constant tag_usage        : t_tag_usage := NO_TAG;
      constant tag              : string      := "") return boolean;

    impure function exists(
      constant instance  : integer;
      constant tag_usage : t_tag_usage;
      constant tag       : string) return boolean;

    impure function exists(
      constant tag_usage : t_tag_usage;
      constant tag       : string) return boolean;

  end protected t_generic_sb;

end package generic_sb_pkg;

package body generic_sb_pkg is

  -- SB type declaration
  type t_sb_entry is record
    expected_element : t_element;
    source           : string(1 to C_SB_SOURCE_WIDTH);
    tag              : string(1 to C_SB_TAG_WIDTH);
    entry_time       : time;
  end record;

  -- Declaration of sb_queue_pkg used to store all entries
  package sb_queue_pkg is new uvvm_util.generic_queue_pkg
    generic map(
      t_generic_element        => t_sb_entry,
      scope                    => "SB_queue",
      GC_QUEUE_COUNT_MAX       => GC_QUEUE_COUNT_MAX,
      GC_QUEUE_COUNT_THRESHOLD => GC_QUEUE_COUNT_THRESHOLD);

  use sb_queue_pkg.all;

  type t_generic_sb is protected body

    ----------------------------------------------------------------------------------------------------
    -- Variables
    ----------------------------------------------------------------------------------------------------
    variable priv_scope            : string(1 to C_LOG_SCOPE_WIDTH)                := (1 to 4 => "?_SB", others => NUL);
    variable priv_config           : t_sb_config_array(0 to C_MAX_SB_INSTANCE_IDX) := (others => sb_config_default);
    variable priv_instance_enabled : boolean_vector(0 to C_MAX_SB_INSTANCE_IDX)    := (others => false);
    variable priv_sb_queue         : sb_queue_pkg.t_generic_queue;
    variable priv_index            : integer_vector(0 to C_MAX_SB_INSTANCE_IDX)    := (others => -1);

    type t_msg_id_panel_array is array (0 to C_MAX_SB_INSTANCE_IDX) of t_msg_id_panel;
    variable priv_msg_id_panel_array : t_msg_id_panel_array := (others => C_SB_MSG_ID_PANEL_DEFAULT);

    -- Counters
    variable priv_entered_cnt         : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable priv_match_cnt           : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable priv_mismatch_cnt        : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable priv_drop_cnt            : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable priv_initial_garbage_cnt : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable priv_delete_cnt          : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable priv_overdue_check_cnt   : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);

    --==================================================================================================
    -- NON PUBLIC METHODS
    --==================================================================================================
    procedure check_instance_in_range(
      constant instance : in integer
    ) is
    begin
      check_value_in_range(instance, 0, C_MAX_SB_INSTANCE_IDX, TB_ERROR,
                           "Instance must be within range 0 to C_MAX_SB_INSTANCE_IDX, " & to_string(C_MAX_SB_INSTANCE_IDX) & ".", priv_scope, ID_NEVER);
    end procedure check_instance_in_range;

    procedure check_instance_enabled(
      constant instance : in integer
    ) is
    begin
      check_value(priv_instance_enabled(instance), TB_ERROR, "The instance is not enabled", priv_scope, ID_NEVER);
    end procedure check_instance_enabled;

    procedure check_queue_empty(
      constant instance : in natural
    ) is
    begin
      check_value(not priv_sb_queue.is_empty(instance), TB_ERROR, "The queue is empty", priv_scope, ID_NEVER);
    end procedure check_queue_empty;

    procedure check_config_validity(
      constant config : in t_sb_config
    ) is
    begin
      check_value(config.allow_out_of_order and config.allow_lossy, false, TB_ERROR,
                  "allow_out_of_order and allow_lossy cannot both be enabled. Se documentation for how to handle both modes.", priv_scope, ID_NEVER);
      check_value(config.overdue_check_time_limit >= 0 ns, TB_ERROR,
                  "overdue_check_time_limit cannot be less than 0 ns.", priv_scope, ID_NEVER);
    end procedure;

    impure function match_received_vs_entry(
      constant received_element : in t_element;
      constant sb_entry         : in t_sb_entry;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return boolean is
    begin
      -- If TAG then check if tag match
      if tag_usage = uvvm_util.types_pkg.TAG then
        if pad_string(tag, NUL, C_SB_TAG_WIDTH) /= sb_entry.tag then
          return false;
        end if;
      end if;
      return element_match(received_element, sb_entry.expected_element);
    end function match_received_vs_entry;

    impure function match_expected_vs_entry(
      constant expected_element : in t_element;
      constant sb_entry         : in t_sb_entry;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return boolean is
    begin
      -- If TAG then check if tag match
      if tag_usage = uvvm_util.types_pkg.TAG then
        if pad_string(tag, NUL, C_SB_TAG_WIDTH) /= sb_entry.tag then
          return false;
        end if;
      end if;
      return expected_element = sb_entry.expected_element;
    end function match_expected_vs_entry;

    procedure log(
      instance : natural;
      msg_id   : t_msg_id;
      msg      : string;
      scope    : string
    ) is
    begin
      if priv_msg_id_panel_array(instance)(msg_id) = ENABLED then
        log(msg_id, msg, scope, C_MSG_ID_PANEL_DEFAULT);
      end if;
    end procedure;

    --==================================================================================================
    -- PUBLIC METHODS
    --==================================================================================================

    ----------------------------------------------------------------------------------------------------
    --
    --  config
    --
    --    Sets config for each instance, by array or instance parameter
    --
    ----------------------------------------------------------------------------------------------------
    procedure config(
      constant sb_config_array : in t_sb_config_array;
      constant msg             : in string := ""
    ) is
      constant proc_name : string := "config";
    begin

      -- Check if range is within limits
      check_value(sb_config_array'low >= 0 and sb_config_array'high <= C_MAX_SB_INSTANCE_IDX, TB_ERROR,
                  "Configuration array must be within range 0 to C_MAX_SB_INSTANCE_IDX, " & to_string(C_MAX_SB_INSTANCE_IDX) & ".", priv_scope, ID_NEVER);

      -- Apply config to the defined range
      for i in sb_config_array'low to sb_config_array'high loop
        check_config_validity(sb_config_array(i));
        log(i, ID_CTRL, proc_name & "() => config applied to SB. " & add_msg_delimiter(msg), priv_scope & "," & to_string(i));
        priv_config(i) := sb_config_array(i);
      end loop;
    end procedure config;

    procedure config(
      constant instance      : in integer;
      constant sb_config     : in t_sb_config;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "" -- not proc???
    ) is
      constant proc_name : string := "config";
    begin
      -- Sanity checks
      check_instance_in_range(instance);
      check_config_validity(sb_config);

      if ext_proc_call = "" then
        -- Called directly from sequencer/VVC.
        log(instance, ID_CTRL, proc_name & "() => config applied to SB. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      else
        -- Called from other SB method
        log(instance, ID_CTRL, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      end if;

      priv_config(instance) := sb_config;
    end procedure config;

    procedure config(
      constant sb_config : in t_sb_config;
      constant msg       : in string := ""
    ) is
    begin
      config(1, sb_config, msg, "config() => config applied to SB. ");
    end procedure config;

    ----------------------------------------------------------------------------------------------------
    --
    --  enable
    --
    --    Enable one instance or all instances. Counters is set froom -1 to 0 When enabled for the
    --    first time.
    --
    ----------------------------------------------------------------------------------------------------
    procedure enable(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "" -- not proc???
    ) is
      constant proc_name : string := "enable";
    begin
      -- Check if instance is within range and not already enabled
      if instance /= ALL_INSTANCES then
        check_instance_in_range(instance);
        check_value(not priv_instance_enabled(instance), TB_WARNING, "Instance " & to_string(instance) & " is already enabled", priv_scope, ID_NEVER);
      end if;

      if ext_proc_call = "" then
        -- Called directly from sequencer/VVC.
        if instance = ALL_INSTANCES then
          log(ID_CTRL, proc_name & "() => all instances enabled. " & add_msg_delimiter(msg), priv_scope);
        else
          log(instance, ID_CTRL, proc_name & "() => SB enabled. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
      else
        -- Called from other SB method
        log(instance, ID_CTRL, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      end if;

      if instance = ALL_INSTANCES then
        priv_instance_enabled := (others => true);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if priv_entered_cnt(i) = -1 then
            priv_entered_cnt(i)         := 0;
            priv_match_cnt(i)           := 0;
            priv_mismatch_cnt(i)        := 0;
            priv_drop_cnt(i)            := 0;
            priv_initial_garbage_cnt(i) := 0;
            priv_delete_cnt(i)          := 0;
            priv_overdue_check_cnt(i)   := 0;
            priv_index(i)               := protected_sb_activity_register.register_sb(priv_scope, i);
            check_value(priv_index(i) /= -1, TB_ERROR, "Number of registered Scoreboards exceed C_MAX_SB_INDEX.\n" & "Increase C_MAX_TB_SB_NUM in adaptations package.", priv_scope, ID_NEVER);
          end if;
          protected_sb_activity_register.enable_sb(priv_index(i));
        end loop;
      else
        priv_instance_enabled(instance) := true;
        if priv_entered_cnt(instance) = -1 then
          priv_entered_cnt(instance)         := 0;
          priv_match_cnt(instance)           := 0;
          priv_mismatch_cnt(instance)        := 0;
          priv_drop_cnt(instance)            := 0;
          priv_initial_garbage_cnt(instance) := 0;
          priv_delete_cnt(instance)          := 0;
          priv_overdue_check_cnt(instance)   := 0;
          priv_index(instance)               := protected_sb_activity_register.register_sb(priv_scope, instance);
          check_value(priv_index(instance) /= -1, TB_ERROR, "Number of registered Scoreboards exceed C_MAX_SB_INDEX.\n" & "Increase C_MAX_TB_SB_NUM in adaptations package.", priv_scope, ID_NEVER);
        end if;
        protected_sb_activity_register.enable_sb(priv_index(instance));
      end if;

      priv_sb_queue.set_scope(instance, "SB queue");
    end procedure enable;

    procedure enable(
      constant msg : in string
    ) is
    begin
      enable(1, msg, "enable() => SB enabled. ");
    end procedure enable;

    procedure enable(
      constant void : in t_void
    ) is
    begin
      enable(1, "", "enable() => SB enabled. ");
    end procedure enable;

    ----------------------------------------------------------------------------------------------------
    --
    --  disable
    --
    --    Disable one instance or all instances.
    --
    ----------------------------------------------------------------------------------------------------
    procedure disable(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "" -- not proc???
    ) is
      constant proc_name : string := "disable";
    begin
      -- Check if instance is within range and not already disabled
      if instance /= ALL_INSTANCES then
        check_instance_in_range(instance);
        check_value(priv_instance_enabled(instance), TB_WARNING, "Instance " & to_string(instance) & " is already disabled", priv_scope, ID_NEVER);
      end if;

      if instance = ALL_INSTANCES then
        priv_instance_enabled := (others => false);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          protected_sb_activity_register.disable_sb(priv_index(i));
        end loop;
      else
        priv_instance_enabled(instance) := false;
        protected_sb_activity_register.disable_sb(priv_index(instance));
      end if;

      if ext_proc_call = "" then
        -- Called directly from sequencer/VVC.
        if instance = ALL_INSTANCES then
          log(ID_CTRL, proc_name & "() => all instances disabled. " & add_msg_delimiter(msg), priv_scope);
        else
          log(instance, ID_CTRL, proc_name & "() => SB disabled. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
      else
        -- Called from other SB method
        log(instance, ID_CTRL, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      end if;
    end procedure disable;

    procedure disable(
      constant msg : in string
    ) is
    begin
      disable(1, msg, "disable() => SB disabled. ");
    end procedure disable;

    procedure disable(
      constant void : in t_void
    ) is
    begin
      disable(1, "", "disable() => SB disabled. ");
    end procedure disable;

    ----------------------------------------------------------------------------------------------------
    --
    --  set_queue_count_max
    --
    --    Resize the internal generic queue
    --
    ----------------------------------------------------------------------------------------------------

    procedure set_queue_count_max(
      constant instance        : in integer;
      constant queue_count_max : in natural
    ) is
    begin
      priv_sb_queue.set_queue_count_max(instance, queue_count_max);
    end procedure;

    procedure set_queue_count_max(
      constant queue_count_max : in natural
    ) is
    begin
      priv_sb_queue.set_queue_count_max(queue_count_max);
    end procedure;

    ----------------------------------------------------------------------------------------------------
    --
    --  set_queue_count_threshold
    --
    --    Set the internal generic queue warning threshold value
    --
    ----------------------------------------------------------------------------------------------------

    procedure set_queue_count_threshold(
      constant instance                : in integer;
      constant queue_count_alert_level : in natural
    ) is
    begin
      priv_sb_queue.set_queue_count_threshold(instance, queue_count_alert_level);
    end procedure;

    procedure set_queue_count_threshold(
      constant queue_count_alert_level : in natural
    ) is
    begin
      priv_sb_queue.set_queue_count_threshold(queue_count_alert_level);
    end procedure;

    ----------------------------------------------------------------------------------------------------
    --
    --  add_expected
    --
    --    Adds expected element at the back of queue. Optional tag and source.
    --
    ----------------------------------------------------------------------------------------------------
    procedure add_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant source           : in string := "";
      constant ext_proc_call    : in string := ""
    ) is
      constant proc_name  : string := "add_expected";
      variable v_sb_entry : t_sb_entry;
    begin

      v_sb_entry := (expected_element => expected_element,
                     source           => pad_string(source, NUL, C_SB_SOURCE_WIDTH),
                     tag              => pad_string(tag, NUL, C_SB_TAG_WIDTH),
                     entry_time       => now);

      if instance = ALL_INSTANCES then
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if priv_instance_enabled(i) then
            -- add entry
            priv_sb_queue.add(i, v_sb_entry);
            -- increment counters
            priv_entered_cnt(i) := priv_entered_cnt(i) + 1;
            protected_sb_activity_register.increment_sb_element_cnt(priv_index(i));

            if tag_usage = NO_TAG then
              log(i, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(i));
            else
              log(i, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) & ", tag: " & to_string(tag) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(i));
            end if;
          end if;
        end loop;
      else
        -- Sanity checks
        check_instance_in_range(instance);
        check_instance_enabled(instance);

        -- add entry
        priv_sb_queue.add(instance, v_sb_entry);
        -- increment counters
        priv_entered_cnt(instance) := priv_entered_cnt(instance) + 1;
        protected_sb_activity_register.increment_sb_element_cnt(priv_index(instance));

        if ext_proc_call = "" then
          if tag_usage = NO_TAG then
            log(instance, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
          else
            log(instance, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) & ", tag: " & to_string(tag) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
          end if;
        else
          -- Called from other SB method
          log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
      end if;
    end procedure add_expected;

    procedure add_expected(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant source           : in string := ""
    ) is
    begin
      if tag_usage = NO_TAG then
        add_expected(1, expected_element, tag_usage, tag, msg, source, "add_expected() => expected: " & to_string_element(expected_element) & ". ");
      else
        add_expected(1, expected_element, tag_usage, tag, msg, source, "add_expected() => expected: " & to_string_element(expected_element) & ", tag: " & to_string(tag) & ". ");
      end if;
    end procedure add_expected;

    procedure add_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant msg              : in string := "";
      constant source           : in string := ""
    ) is
    begin
      add_expected(instance, expected_element, NO_TAG, "", msg, source);
    end procedure add_expected;

    procedure add_expected(
      constant expected_element : in t_element;
      constant msg              : in string := "";
      constant source           : in string := ""
    ) is
    begin
      add_expected(expected_element, NO_TAG, "", msg, source);
    end procedure add_expected;

    ----------------------------------------------------------------------------------------------------
    --
    --  check_received
    --
    --    Checks received against expected. Updates counters acording to match/mismatch and configuration.
    --
    ----------------------------------------------------------------------------------------------------
    procedure check_received(
      constant instance         : in integer;
      constant received_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := ""
    ) is

      constant proc_name : string := "check_received";

      procedure check_pending_exists(
        constant instance : in integer
      ) is
      begin
        check_value(not priv_sb_queue.is_empty(instance), TB_ERROR, "No pending entries to check.", priv_scope & "," & to_string(instance), ID_NEVER);
      end procedure check_pending_exists;

      procedure check_received_instance(
        constant instance : in integer
      ) is
        variable v_matched     : boolean := false;
        variable v_entry       : t_sb_entry;
        variable v_dropped_num : natural := 0;
      begin
        check_pending_exists(instance);

        -- If OOB
        if priv_config(instance).allow_out_of_order then

          -- Loop through entries in queue until match
          for i in 1 to get_pending_count(instance) loop
            v_entry := priv_sb_queue.peek(instance, POSITION, i);
            if match_received_vs_entry(received_element, v_entry, tag_usage, tag) then
              v_matched := true;

              -- Delete entry
              priv_sb_queue.delete(instance, POSITION, i, SINGLE);
              protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance));

              exit;
            end if;
          end loop;

        -- If LOSSY
        elsif priv_config(instance).allow_lossy then

          -- Loop through entries in queue until match
          for i in 1 to get_pending_count(instance) loop
            v_entry := priv_sb_queue.peek(instance, POSITION, i);
            if match_received_vs_entry(received_element, v_entry, tag_usage, tag) then
              v_matched := true;

              -- Delete matching entry and preceding entries
              for j in i downto 1 loop
                priv_sb_queue.delete(instance, POSITION, j, SINGLE);
                protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance));
              end loop;
              v_dropped_num := i - 1;
              exit;
            end if;
          end loop;

        -- Not OOB or LOSSY
        else
          v_entry := priv_sb_queue.peek(instance);
          if match_received_vs_entry(received_element, v_entry, tag_usage, tag) then
            v_matched := true;
            -- delete entry
            priv_sb_queue.delete(instance, POSITION, 1, SINGLE);
            protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance));
          elsif not (priv_match_cnt(instance) = 0 and priv_config(instance).ignore_initial_garbage) then
            priv_sb_queue.delete(instance, POSITION, 1, SINGLE);
            protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance));
          end if;
        end if;

        -- Update counters
        priv_drop_cnt(instance) := priv_drop_cnt(instance) + v_dropped_num;
        if v_matched then
          priv_match_cnt(instance) := priv_match_cnt(instance) + 1;
        elsif priv_match_cnt(instance) = 0 and priv_config(instance).ignore_initial_garbage then
          priv_initial_garbage_cnt(instance) := priv_initial_garbage_cnt(instance) + 1;
        else
          priv_mismatch_cnt(instance) := priv_mismatch_cnt(instance) + 1;
        end if;

        -- Check if overdue time
        if v_matched and (priv_config(instance).overdue_check_time_limit /= 0 ns) and (now - v_entry.entry_time > priv_config(instance).overdue_check_time_limit) then
          if ext_proc_call = "" then
            alert(priv_config(instance).overdue_check_alert_level, proc_name & "() => TIME LIMIT OVERDUE: time limit is " & to_string(priv_config(instance).overdue_check_time_limit) & ", time from entry is " & to_string(now - v_entry.entry_time) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
          else
            alert(priv_config(instance).overdue_check_alert_level, ext_proc_call & " => TIME LIMIT OVERDUE: time limit is " & to_string(priv_config(instance).overdue_check_time_limit) & ", time from entry is " & to_string(now - v_entry.entry_time) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
          end if;
          -- Update counter
          priv_overdue_check_cnt(instance) := priv_overdue_check_cnt(instance) + 1;
        end if;

        -- Logging
        if v_matched then
          if ext_proc_call = "" then
            if tag_usage = NO_TAG then
              log(instance, ID_DATA, proc_name & "() => MATCH, for value: " & to_string_element(v_entry.expected_element) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
            else
              log(instance, ID_DATA, proc_name & "() => MATCH, for value: " & to_string_element(v_entry.expected_element) & ". tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
            end if;
          -- Called from other SB method
          else
            if tag_usage = NO_TAG then
              log(instance, ID_DATA, ext_proc_call & " => MATCH, for received: " & to_string_element(received_element) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
            else
              log(instance, ID_DATA, ext_proc_call & " => MATCH, for received: " & to_string_element(received_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
            end if;
          end if;
        -- Initial garbage
        elsif not (priv_match_cnt(instance) = 0 and priv_config(instance).ignore_initial_garbage) then
          if ext_proc_call = "" then
            if tag_usage = NO_TAG then
              alert(priv_config(instance).mismatch_alert_level, proc_name & "() => MISMATCH, expected: " & to_string_element(v_entry.expected_element) & "; received: " & to_string_element(received_element) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
            else
              alert(priv_config(instance).mismatch_alert_level, proc_name & "() => MISMATCH, expected: " & to_string_element(v_entry.expected_element) & ", tag: '" & to_string(v_entry.tag) & "'; received: " & to_string_element(received_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
            end if;
          else
            if tag_usage = NO_TAG then
              alert(priv_config(instance).mismatch_alert_level, ext_proc_call & " => MISMATCH, expected: " & to_string_element(v_entry.expected_element) & "; received: " & to_string_element(received_element) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
            else
              alert(priv_config(instance).mismatch_alert_level, ext_proc_call & " => MISMATCH, expected: " & to_string_element(v_entry.expected_element) & ", tag: " & to_string(v_entry.tag) & "; received: " & to_string_element(received_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
            end if;
          end if;
        end if;
      end procedure check_received_instance;

    begin

      if instance = ALL_INSTANCES then
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if priv_instance_enabled(i) then
            check_received_instance(i);
          end if;
        end loop;
      else
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        check_received_instance(instance);
      end if;

    end procedure check_received;

    procedure check_received(
      constant received_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := ""
    ) is
    begin
      check_received(1, received_element, tag_usage, tag, msg, "check_received()");
    end procedure check_received;

    procedure check_received(
      constant instance         : in integer;
      constant received_element : in t_element;
      constant msg              : in string := ""
    ) is
    begin
      check_received(instance, received_element, NO_TAG, "", msg);
    end procedure check_received;

    procedure check_received(
      constant received_element : in t_element;
      constant msg              : in string := ""
    ) is
    begin
      check_received(received_element, NO_TAG, "", msg);
    end procedure check_received;

    ----------------------------------------------------------------------------------------------------
    --
    --  flush
    --
    --    Deletes all entries in queue and updates delete counter.
    --
    ----------------------------------------------------------------------------------------------------
    procedure flush(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := ""
    ) is
      constant proc_name : string := "flush";
    begin
      if instance = ALL_INSTANCES then
        log(ID_DATA, proc_name & "() => flushing all instances. " & add_msg_delimiter(msg), priv_scope);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          -- update counters
          priv_delete_cnt(i) := priv_delete_cnt(i) + priv_sb_queue.get_count(i);
          -- flush queue
          priv_sb_queue.flush(i);
          protected_sb_activity_register.reset_sb_element_cnt(priv_index(i));
        end loop;
      else
        if ext_proc_call = "" then
          log(instance, ID_DATA, proc_name & "() => flushing SB. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        else
          log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        -- update counters
        priv_delete_cnt(instance) := priv_delete_cnt(instance) + priv_sb_queue.get_count(instance);
        -- flush queue
        priv_sb_queue.flush(instance);
        protected_sb_activity_register.reset_sb_element_cnt(priv_index(instance));
      end if;
    end procedure flush;

    procedure flush(
      constant msg : in string
    ) is
    begin
      flush(1, msg, "flush() => flushing SB. ");
    end procedure flush;

    procedure flush(
      constant void : in t_void
    ) is
    begin
      flush("");
    end procedure flush;

    ----------------------------------------------------------------------------------------------------
    --
    --  reset
    --
    --    Resets all counters and flushes queue. Also resets entry number count.
    --
    ----------------------------------------------------------------------------------------------------
    procedure reset(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := ""
    ) is
      constant proc_name : string := "reset";

      procedure reset_instance(
        constant instance : natural
      ) is
      begin
        -- reset instance 0 only if it is used
        if not (priv_sb_queue.is_empty(0)) or (instance > 0) then
          priv_sb_queue.reset(instance);
          priv_entered_cnt(instance)         := 0;
          priv_match_cnt(instance)           := 0;
          priv_mismatch_cnt(instance)        := 0;
          priv_drop_cnt(instance)            := 0;
          priv_initial_garbage_cnt(instance) := 0;
          priv_delete_cnt(instance)          := 0;
          priv_overdue_check_cnt(instance)   := 0;
          protected_sb_activity_register.reset_sb_element_cnt(priv_index(instance));
        end if;
      end procedure reset_instance;

    begin
      if instance = ALL_INSTANCES then
        log(ID_CTRL, proc_name & "() => reseting all instances. " & add_msg_delimiter(msg), priv_scope);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          reset_instance(i);
        end loop;
      else
        if ext_proc_call = "" then
          log(instance, ID_CTRL, proc_name & "() => reseting SB. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        else
          log(instance, ID_CTRL, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        reset_instance(instance);
      end if;
    end procedure reset;

    procedure reset(
      constant msg : in string
    ) is
    begin
      reset(1, msg, "reset() => reseting SB. ");
    end procedure reset;

    procedure reset(
      constant void : in t_void
    ) is
    begin
      reset("");
    end procedure reset;

    ----------------------------------------------------------------------------------------------------
    --
    --  is_empty
    --
    --    Returns true if scoreboard instance is empty, false if not.
    --
    ----------------------------------------------------------------------------------------------------
    impure function is_empty(
      constant instance : in integer
    ) return boolean is
      variable v_is_empty : boolean := true;
    begin
      if instance /= ALL_INSTANCES then
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        v_is_empty := priv_sb_queue.is_empty(instance);
      else
        for idx in 0 to C_MAX_SB_INSTANCE_IDX loop
          -- an instance is not empty
          if priv_instance_enabled(idx) then
            if not (priv_sb_queue.is_empty(idx)) then
              v_is_empty := false;
            end if;
          end if;
        end loop;
      end if;

      return v_is_empty;
    end function is_empty;

    impure function is_empty(
      constant void : in t_void
    ) return boolean is
    begin
      return is_empty(1);
    end function is_empty;

    ----------------------------------------------------------------------------------------------------
    --
    --  get_entered_count
    --
    --    Returns total number of entries made to scoreboard instance.
    --    Added + inserted.
    --
    ----------------------------------------------------------------------------------------------------
    impure function get_entered_count(
      constant instance : in integer
    ) return integer is
    begin
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      return priv_entered_cnt(instance);
    end function get_entered_count;

    impure function get_entered_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_entered_count(1);
    end function get_entered_count;

    ----------------------------------------------------------------------------------------------------
    --
    --  get_pending_count
    --
    --    Returns number of entries en scoreboard instance at the moment.
    --    Added + inserted - checked - deleted.
    --
    ----------------------------------------------------------------------------------------------------
    impure function get_pending_count(
      constant instance : in integer
    ) return integer is
    begin
      if priv_entered_cnt(instance) = -1 then
        return -1;
      else
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        return priv_sb_queue.get_count(instance);
      end if;
    end function get_pending_count;

    impure function get_pending_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_pending_count(1);
    end function get_pending_count;

    ----------------------------------------------------------------------------------------------------
    --
    --  get_match_count
    --
    --    Returns number of entries checked and matched against a received.
    --
    ----------------------------------------------------------------------------------------------------
    impure function get_match_count(
      constant instance : in integer
    ) return integer is
    begin
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      return priv_match_cnt(instance);
    end function get_match_count;

    impure function get_match_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_match_count(1);
    end function get_match_count;

    ----------------------------------------------------------------------------------------------------
    --
    --  get_mismatch_count
    --
    --    Returns number of entries checked and not matched against a received.
    --
    ----------------------------------------------------------------------------------------------------
    impure function get_mismatch_count(
      constant instance : in integer
    ) return integer is
    begin
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      return priv_mismatch_cnt(instance);
    end function get_mismatch_count;

    impure function get_mismatch_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_mismatch_count(1);
    end function get_mismatch_count;

    ----------------------------------------------------------------------------------------------------
    --
    --  get_drop_count
    --
    --    Returns number of entries dropped, total number of preceding entries before match.
    --    Only relevant during lossy mode.
    --
    ----------------------------------------------------------------------------------------------------
    impure function get_drop_count(
      constant instance : in integer
    ) return integer is
    begin
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      return priv_drop_cnt(instance);
    end function get_drop_count;

    impure function get_drop_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_drop_count(1);
    end function get_drop_count;

    ----------------------------------------------------------------------------------------------------
    --
    --  get_initial_garbage_count
    --
    --    Returns number of received checked before first match.
    --    Only relevant when allow_initial_garbage is enabled.
    --
    ----------------------------------------------------------------------------------------------------
    impure function get_initial_garbage_count(
      constant instance : in integer
    ) return integer is
    begin
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      return priv_initial_garbage_cnt(instance);
    end function get_initial_garbage_count;

    impure function get_initial_garbage_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_initial_garbage_count(1);
    end function get_initial_garbage_count;

    ----------------------------------------------------------------------------------------------------
    --
    --  get_delete_count
    --
    --    Returns number of deleted entries.
    --    Delete + fetch + flush.
    --
    ----------------------------------------------------------------------------------------------------
    impure function get_delete_count(
      constant instance : in integer
    ) return integer is
    begin
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      return priv_delete_cnt(instance);
    end function get_delete_count;

    impure function get_delete_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_delete_count(1);
    end function get_delete_count;

    ----------------------------------------------------------------------------------------------------
    --
    --  get_overdue_check_count
    --
    --    Returns number of received checked when time limit is overdue.
    --    Only relevant when overdue_check_time_limit is set.
    --
    ----------------------------------------------------------------------------------------------------
    impure function get_overdue_check_count(
      constant instance : in integer
    ) return integer is
    begin
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      return priv_overdue_check_cnt(instance);
    end function get_overdue_check_count;

    impure function get_overdue_check_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_overdue_check_count(1);
    end function get_overdue_check_count;

    ----------------------------------------------------------------------------------------------------
    --
    --  set_scope / get_scope
    --
    --    Set/Get the scope of the scoreboard.
    --
    ----------------------------------------------------------------------------------------------------
    procedure set_scope(
      constant scope : in string
    ) is
    begin
      priv_scope := pad_string(scope, NUL, C_LOG_SCOPE_WIDTH);
    end procedure set_scope;

    impure function get_scope(
      constant void : in t_void
    ) return string is
    begin
      return priv_scope;
    end function get_scope;

    ----------------------------------------------------------------------------------------------------
    --
    --  enable_log_msg
    --
    --    Enables the specified message id for the instance.
    --
    ----------------------------------------------------------------------------------------------------
    procedure enable_log_msg(
      constant instance      : in integer;
      constant msg_id        : in t_msg_id;
      constant ext_proc_call : in string := ""
    ) is
      constant proc_name : string := "enable_log_msg";
    begin
      if instance = ALL_INSTANCES then
        log(ID_CTRL, proc_name & "() => message id " & to_string(msg_id) & " enabled for all instances.", priv_scope);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          priv_msg_id_panel_array(i)(msg_id) := ENABLED;
        end loop;
      else
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        if ext_proc_call = "" then
          log(instance, ID_CTRL, proc_name & "() => message id " & to_string(msg_id) & " enabled.", priv_scope & "," & to_string(instance));
        else
          log(instance, ID_CTRL, ext_proc_call, priv_scope & "," & to_string(instance));
        end if;
        priv_msg_id_panel_array(instance)(msg_id) := ENABLED;
      end if;
    end procedure enable_log_msg;

    procedure enable_log_msg(
      constant msg_id : in t_msg_id
    ) is
    begin
      enable_log_msg(1, msg_id, "enable_log_msg() => message id " & to_string(msg_id) & " enabled. ");
    end procedure enable_log_msg;

    ----------------------------------------------------------------------------------------------------
    --
    --  disable_log_msg
    --
    --    Disables the specified message id for the instance.
    --
    ----------------------------------------------------------------------------------------------------
    procedure disable_log_msg(
      constant instance      : in integer;
      constant msg_id        : in t_msg_id;
      constant ext_proc_call : in string := ""
    ) is
      constant proc_name : string := "disable_log_msg";
    begin
      if instance = ALL_INSTANCES then
        log(ID_CTRL, proc_name & "() => message id " & to_string(msg_id) & " disabled for all instances.", priv_scope);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          priv_msg_id_panel_array(i)(msg_id) := DISABLED;
        end loop;
      else
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        if ext_proc_call = "" then
          log(instance, ID_CTRL, proc_name & "() => message id " & to_string(msg_id) & " disabled.", priv_scope & "," & to_string(instance));
        else
          log(instance, ID_CTRL, ext_proc_call, priv_scope & "," & to_string(instance));
        end if;
        priv_msg_id_panel_array(instance)(msg_id) := DISABLED;
      end if;
    end procedure disable_log_msg;

    procedure disable_log_msg(
      constant msg_id : in t_msg_id
    ) is
    begin
      disable_log_msg(1, msg_id, "disable_log_msg() => message id " & to_string(msg_id) & " disabled. ");
    end procedure disable_log_msg;

    ----------------------------------------------------------------------------------------------------
    --
    --  report_conters
    --
    --    Prints a report of all counters to transcript for either specified instance, all enabled
    --    instances or all instances.
    --
    ----------------------------------------------------------------------------------------------------
    procedure report_counters(
      constant instance      : in integer;
      constant ext_proc_call : in string := ""
    ) is
      variable v_line                           : line;
      variable v_status_failed                  : boolean  := true;
      variable v_mismatch                       : boolean  := false;
      variable v_no_enabled_instances           : boolean  := true;
      constant C_HEADER                         : string   := "*** SCOREBOARD COUNTERS SUMMARY: " & to_string(priv_scope) & " ***";
      constant prefix                           : string   := C_LOG_PREFIX & "     ";
      constant log_counter_width                : positive := 8; -- shouldn't be smaller than 8 due to the counters names
      variable v_log_extra_space                : integer  := 0;
      constant C_MAX_SB_INSTANCE_IDX_STRING     : string   := to_string(C_MAX_SB_INSTANCE_IDX);
      constant C_MAX_SB_INSTANCE_IDX_STRING_LEN : natural  := C_MAX_SB_INSTANCE_IDX_STRING'length;

    begin
      -- Calculate how much space we can insert between the columns of the report
      v_log_extra_space := (C_LOG_LINE_WIDTH - prefix'length - 20 - log_counter_width * 6 - 15 - 13) / 8;
      if v_log_extra_space < 1 then
        alert(TB_WARNING, "C_LOG_LINE_WIDTH is too small, the report will not be properly aligned.", priv_scope);
        v_log_extra_space := 1;
      end if;

      write(v_line,
            LF &
            fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF &
            timestamp_header(now, justify(C_HEADER, LEFT, C_LOG_LINE_WIDTH - prefix'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF &
            fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF);

      write(v_line,
            justify(
              fill_string(' ', 16) &
              justify("ENTERED", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("PENDING", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("MATCH", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("MISMATCH", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("DROP", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("INITIAL_GARBAGE", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("DELETE", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("OVERDUE_CHECK", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
              left, C_LOG_LINE_WIDTH - prefix'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);

      if instance = ALL_INSTANCES THEN
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if (instance = ALL_INSTANCES and priv_instance_enabled(i)) then
            v_no_enabled_instances := false;

            write(v_line,
                  justify(
                    "instance: " &
                    justify(to_string(i), right, C_MAX_SB_INSTANCE_IDX_STRING_LEN, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                    fill_string(' ', 20 - 4 - 10 - C_MAX_SB_INSTANCE_IDX_STRING_LEN) &
                    justify(to_string(get_entered_count(i)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                    justify(to_string(get_pending_count(i)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                    justify(to_string(get_match_count(i)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                    justify(to_string(get_mismatch_count(i)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                    justify(to_string(get_drop_count(i)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                    justify(to_string(get_initial_garbage_count(i)), center, 15, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                    justify(to_string(get_delete_count(i)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                    justify(to_string(get_overdue_check_count(i)), center, 13, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
                    left, C_LOG_LINE_WIDTH - prefix'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
          end if;
        end loop;

        -- report if no enabled instances was found
        if v_no_enabled_instances then
          write(v_line, "No enabled instances was found." & LF);
        end if;

      else
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        write(v_line,
              justify(
                "instance: " &
                justify(to_string(instance), right, C_MAX_SB_INSTANCE_IDX_STRING_LEN, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                fill_string(' ', 20 - 4 - 10 - C_MAX_SB_INSTANCE_IDX_STRING_LEN) &
                justify(to_string(get_entered_count(instance)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                justify(to_string(get_pending_count(instance)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                justify(to_string(get_match_count(instance)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                justify(to_string(get_mismatch_count(instance)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                justify(to_string(get_drop_count(instance)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                justify(to_string(get_initial_garbage_count(instance)), center, 15, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                justify(to_string(get_delete_count(instance)), center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
                justify(to_string(get_overdue_check_count(instance)), center, 13, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
                left, C_LOG_LINE_WIDTH - prefix'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
      end if;

      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF & LF);
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - prefix'length);
      prefix_lines(v_line, prefix);

      -- Write the info string to transcript
      tee(OUTPUT, v_line);
      writeline(LOG_FILE, v_line);
      deallocate(v_line);
    end procedure report_counters;

    procedure report_counters(
      constant void : in t_void
    ) is
    begin
      report_counters(1, "no instance label");
    end procedure report_counters;

    --==================================================================================================
    -- ADVANCED METHODS
    --==================================================================================================

    ----------------------------------------------------------------------------------------------------
    --
    --  insert_expected
    --
    --    Inserts expected element to the queue based on position or entry number
    --
    ----------------------------------------------------------------------------------------------------
    procedure insert_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant tag_usage         : in t_tag_usage;
      constant tag               : in string;
      constant msg               : in string := "";
      constant source            : in string := "";
      constant ext_proc_call     : in string := ""
    ) is
      constant proc_name  : string := "insert_expected";
      variable v_sb_entry : t_sb_entry;
    begin
      -- Check if instance is within range
      if instance /= ALL_INSTANCES then
        check_instance_in_range(instance);
      end if;

      v_sb_entry := (expected_element => expected_element,
                     source           => pad_string(source, NUL, C_SB_SOURCE_WIDTH),
                     tag              => pad_string(tag, NUL, C_SB_TAG_WIDTH),
                     entry_time       => now);

      if instance = ALL_INSTANCES then
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if priv_instance_enabled(i) then
            check_queue_empty(i);
            -- add entry
            priv_sb_queue.insert(i, identifier_option, identifier, v_sb_entry);
            -- increment counters
            priv_entered_cnt(i) := priv_entered_cnt(i) + 1;
            protected_sb_activity_register.increment_sb_element_cnt(priv_index(i));
          end if;
        end loop;
      else
        -- Check that instance is in valid range and enabled
        check_instance_in_range(instance);
        check_instance_enabled(instance);
        -- insert_expected to POSITION 1 is allowed  
        if identifier_option /= POSITION and identifier /= 1 then
          check_queue_empty(instance);
        end if;
        -- add entry
        priv_sb_queue.insert(instance, identifier_option, identifier, v_sb_entry);
        -- increment counters
        priv_entered_cnt(instance) := priv_entered_cnt(instance) + 1;
        protected_sb_activity_register.increment_sb_element_cnt(priv_index(instance));
      end if;

      -- Logging
      if ext_proc_call = "" then
        if instance = ALL_INSTANCES then
          if identifier_option = POSITION then
            if tag_usage = NO_TAG then
              log(ID_DATA, proc_name & "() => inserted expected after entry with position " & to_string(identifier) & " for all enabled instances. Expected: " & to_string_element(expected_element) & ". " & add_msg_delimiter(msg), priv_scope);
            else
              log(ID_DATA, proc_name & "() => inserted expected after entry with position " & to_string(identifier) & " for all enabled instances. Expected: " & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope);
            end if;
          else
            if tag_usage = NO_TAG then
              log(ID_DATA, proc_name & "() => inserted expected after entry with entry number " & to_string(identifier) & " for all enabled instances. Expected: " & to_string_element(expected_element) & ". " & add_msg_delimiter(msg), priv_scope);
            else
              log(ID_DATA, proc_name & "() => inserted expected after entry with entry number " & to_string(identifier) & " for all enabled instances. Expected: " & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope);
            end if;
          end if;
        else
          if identifier_option = POSITION then
            log(instance, ID_DATA, proc_name & "() => inserted expected after entry with position " & to_string(identifier) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
          else
            log(instance, ID_DATA, proc_name & "() => inserted expected after entry with entry number " & to_string(identifier) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
          end if;
        end if;
      else
        if tag_usage = NO_TAG then
          log(instance, ID_DATA, ext_proc_call & " Expected: " & to_string_element(expected_element) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        else
          log(instance, ID_DATA, ext_proc_call & " Expected: " & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
      end if;
    end procedure insert_expected;

    procedure insert_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant tag_usage         : in t_tag_usage;
      constant tag               : in string;
      constant msg               : in string := "";
      constant source            : in string := ""
    ) is
    begin
      if identifier_option = POSITION then
        insert_expected(1, identifier_option, identifier, expected_element, tag_usage, tag, msg, source, "insert_expected() => inserted expected after entry with position " & to_string(identifier) & ". ");
      else
        insert_expected(1, identifier_option, identifier, expected_element, tag_usage, tag, msg, source, "insert_expected() => inserted expected after entry with entry number " & to_string(identifier) & ". ");
      end if;
    end procedure insert_expected;

    procedure insert_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant msg               : in string := "";
      constant source            : in string := ""
    ) is
    begin
      insert_expected(instance, identifier_option, identifier, expected_element, NO_TAG, "", msg, source, "insert_expected() => inserted expected without TAG in position " & to_string(identifier) & ". ");
    end procedure insert_expected;

    procedure insert_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant msg               : in string := "";
      constant source            : in string := ""
    ) is
    begin
      insert_expected(1, identifier_option, identifier, expected_element, NO_TAG, "", msg, source, "insert_expected() => inserted expected without TAG in position " & to_string(identifier) & ". ");
    end procedure insert_expected;

    ----------------------------------------------------------------------------------------------------
    --
    --  find_expected_entry_num
    --
    --    Returns entry number of matching entry, no match returns -1
    --
    ----------------------------------------------------------------------------------------------------
    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      check_queue_empty(instance);

      for i in 1 to get_pending_count(instance) loop
        -- get entry i
        v_sb_entry := priv_sb_queue.peek(instance, POSITION, i);

        -- check if match
        if match_expected_vs_entry(expected_element, v_sb_entry, tag_usage, tag) then
          return priv_sb_queue.get_entry_num(instance, i);
        end if;
      end loop;

      return -1;
    end function find_expected_entry_num;

    impure function find_expected_entry_num(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
    begin
      return find_expected_entry_num(1, expected_element, tag_usage, tag);
    end function find_expected_entry_num;

    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant expected_element : in t_element
    ) return integer is
    begin
      return find_expected_entry_num(instance, expected_element, NO_TAG, "");
    end function find_expected_entry_num;

    impure function find_expected_entry_num(
      constant expected_element : in t_element
    ) return integer is
    begin
      return find_expected_entry_num(1, expected_element, NO_TAG, "");
    end function find_expected_entry_num;

    impure function find_expected_entry_num(
      constant instance  : in integer;
      constant tag_usage : in t_tag_usage;
      constant tag       : in string
    ) return integer is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      check_queue_empty(instance);

      for i in 1 to get_pending_count(instance) loop
        -- get entry i
        v_sb_entry := priv_sb_queue.peek(instance, POSITION, i);

        -- check if match
        if v_sb_entry.tag = pad_string(tag, NUL, C_SB_TAG_WIDTH) then
          return priv_sb_queue.get_entry_num(instance, i);
        end if;
      end loop;

      return -1;
    end function find_expected_entry_num;

    impure function find_expected_entry_num(
      constant tag_usage : in t_tag_usage;
      constant tag       : in string
    ) return integer is
    begin
      return find_expected_entry_num(1, tag_usage, tag);
    end function find_expected_entry_num;

    ----------------------------------------------------------------------------------------------------
    --
    --  find_expected_position
    --
    --    Returns position of matching entry, no match returns -1
    --
    ----------------------------------------------------------------------------------------------------
    impure function find_expected_position(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      check_queue_empty(instance);

      for i in 1 to get_pending_count(instance) loop
        -- get entry i
        v_sb_entry := priv_sb_queue.peek(instance, POSITION, i);

        -- check if match
        if match_expected_vs_entry(expected_element, v_sb_entry, tag_usage, tag) then
          return i;
        end if;
      end loop;

      return -1;
    end function find_expected_position;

    impure function find_expected_position(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
    begin
      return find_expected_position(1, expected_element, tag_usage, tag);
    end function find_expected_position;

    impure function find_expected_position(
      constant instance         : in integer;
      constant expected_element : in t_element
    ) return integer is
    begin
      return find_expected_position(instance, expected_element, NO_TAG, "");
    end function find_expected_position;

    impure function find_expected_position(
      constant expected_element : in t_element
    ) return integer is
    begin
      return find_expected_position(1, expected_element, NO_TAG, "");
    end function find_expected_position;

    impure function find_expected_position(
      constant instance  : in integer;
      constant tag_usage : in t_tag_usage;
      constant tag       : in string
    ) return integer is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      check_queue_empty(instance);

      for i in 1 to get_pending_count(instance) loop
        -- get entry i
        v_sb_entry := priv_sb_queue.peek(instance, POSITION, i);

        -- check if match
        if v_sb_entry.tag = pad_string(tag, NUL, C_SB_TAG_WIDTH) then
          return i;
        end if;
      end loop;

      return -1;
    end function find_expected_position;

    impure function find_expected_position(
      constant tag_usage : in t_tag_usage;
      constant tag       : in string
    ) return integer is
    begin
      return find_expected_position(1, tag_usage, tag);
    end function find_expected_position;

    ----------------------------------------------------------------------------------------------------
    --
    --  delete_expected
    --
    --    Deletes expected element in queue based on specified element, position or entry number
    --
    ----------------------------------------------------------------------------------------------------
    procedure delete_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := ""
    ) is
      constant proc_name  : string := "delete_expected";
      variable v_position : integer;
    begin
      -- Sanity checks done in find_expected_position

      v_position := find_expected_position(instance, expected_element, tag_usage, tag);

      if v_position /= -1 then
        priv_sb_queue.delete(instance, POSITION, v_position, SINGLE);
        priv_delete_cnt(instance) := priv_delete_cnt(instance) + 1;
        protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance));

        if ext_proc_call = "" then
          log(instance, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        else
          log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
      else
        log(instance, ID_DATA, proc_name & "() => NO DELETION. Did not find matching entry. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      end if;
    end procedure delete_expected;

    procedure delete_expected(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := ""
    ) is
    begin
      delete_expected(1, expected_element, tag_usage, tag, msg, "delete_expected() => value: " & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. ");
    end procedure delete_expected;

    procedure delete_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant msg              : in string := ""
    ) is
    begin
      delete_expected(instance, expected_element, NO_TAG, "", msg, "delete_expected() => value: " & to_string_element(expected_element) & ". ");
    end procedure delete_expected;

    procedure delete_expected(
      constant expected_element : in t_element;
      constant msg              : in string := ""
    ) is
    begin
      delete_expected(1, expected_element, NO_TAG, "", msg, "delete_expected() => value: " & to_string_element(expected_element) & ". ");
    end procedure delete_expected;

    procedure delete_expected(
      constant instance      : in integer;
      constant tag_usage     : in t_tag_usage;
      constant tag           : in string;
      constant msg           : in string := "";
      constant ext_proc_call : in string := ""
    ) is
      constant proc_name  : string := "delete_expected";
      variable v_position : integer;
    begin
      -- Sanity checks done in find_expected_position

      v_position := find_expected_position(instance, tag_usage, tag);

      if v_position /= -1 then
        priv_sb_queue.delete(instance, POSITION, v_position, SINGLE);
        priv_delete_cnt(instance) := priv_delete_cnt(instance) + 1;
        protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance));

        if ext_proc_call = "" then
          log(instance, ID_DATA, proc_name & "() => tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        else
          log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope);
        end if;
      else
        log(instance, ID_DATA, proc_name & "() => NO DELETION. Did not find matching entry. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      end if;
    end procedure delete_expected;

    procedure delete_expected(
      constant tag_usage : in t_tag_usage;
      constant tag       : in string;
      constant msg       : in string := ""
    ) is
    begin
      delete_expected(1, tag_usage, tag, msg, "delete_expected() => tag: '" & to_string(tag) & "'. ");
    end procedure delete_expected;

    procedure delete_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive;
      constant msg               : in string := "";
      constant ext_proc_call     : in string := ""
    ) is
      constant proc_name                : string  := "delete_expected";
      constant C_PRE_DELETE_PENDING_CNT : natural := priv_sb_queue.get_count(instance);
      variable v_num_deleted            : natural;
    begin
      -- Sanity check
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      check_queue_empty(instance);

      -- Delete entries
      priv_sb_queue.delete(instance, identifier_option, identifier_min, identifier_max);
      v_num_deleted             := C_PRE_DELETE_PENDING_CNT - priv_sb_queue.get_count(instance);
      priv_delete_cnt(instance) := priv_delete_cnt(instance) + v_num_deleted;
      protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance), v_num_deleted);

      -- If error
      if v_num_deleted = 0 then
        log(instance, ID_DATA, proc_name & "() => NO DELETION. Did not find matching entry. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      else
        if ext_proc_call = "" then
          log(instance, ID_DATA, proc_name & "() => entries with identifier " & to_string(identifier_option) & " range " & to_string(identifier_min) & " to " & to_string(identifier_max) & " deleted. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        else
          log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
      end if;
    end procedure delete_expected;

    procedure delete_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive;
      constant msg               : in string := ""
    ) is
    begin
      delete_expected(1, identifier_option, identifier_min, identifier_max, msg, "delete_expected() => entries with identifier " & to_string(identifier_option) & " range " & to_string(identifier_min) & " to " & to_string(identifier_max) & " deleted. ");
    end procedure delete_expected;

    procedure delete_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option;
      constant msg               : in string := "";
      constant ext_proc_call     : in string := ""
    ) is
      constant proc_name                : string  := "delete_expected";
      constant C_PRE_DELETE_PENDING_CNT : natural := priv_sb_queue.get_count(instance);
      variable v_num_deleted            : natural;
    begin
      -- Sanity check
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      check_queue_empty(instance);

      -- Delete entries
      priv_sb_queue.delete(instance, identifier_option, identifier, range_option);
      v_num_deleted             := C_PRE_DELETE_PENDING_CNT - priv_sb_queue.get_count(instance);
      priv_delete_cnt(instance) := priv_delete_cnt(instance) + v_num_deleted;
      protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance), v_num_deleted);

      -- If error
      if v_num_deleted = 0 then
        log(instance, ID_DATA, proc_name & "() => NO DELETION. Did not find matching entry. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      else
        if ext_proc_call = "" then
          if range_option = SINGLE then
            log(instance, ID_DATA, proc_name & "() => entry with identifier " & to_string(identifier_option) & " " & to_string(identifier) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
          else
            log(instance, ID_DATA, proc_name & "() => entries with identifier " & to_string(identifier_option) & " range " & to_string(identifier) & " " & to_string(range_option) & " deleted. " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
          end if;
        else
          log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
        end if;
      end if;
    end procedure delete_expected;

    procedure delete_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option;
      constant msg               : in string := ""
    ) is
    begin
      if range_option = SINGLE then
        delete_expected(1, identifier_option, identifier, range_option, msg, "delete_expected() => entry with identifier '" & to_string(identifier_option) & " " & to_string(identifier) & " deleted. ");
      else
        delete_expected(1, identifier_option, identifier, range_option, msg, "delete_expected() => entries with identifier '" & to_string(identifier_option) & " range " & to_string(identifier) & " to " & to_string(range_option) & " deleted. ");
      end if;
    end procedure delete_expected;

    ----------------------------------------------------------------------------------------------------
    --  non public local_entry
    --    Used by all peek functions
    ----------------------------------------------------------------------------------------------------
    impure function peek_entry(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return t_sb_entry is
    begin
      -- Check that instance is in valid range and enabled
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      check_queue_empty(instance);

      return priv_sb_queue.peek(instance, identifier_option, identifier);

    end function peek_entry;

    ----------------------------------------------------------------------------------------------------
    --
    --  peek_expected
    --
    --    Returns expected element from queue entry based on position or entry number without deleting entry
    --
    ----------------------------------------------------------------------------------------------------
    impure function peek_expected(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return t_element is
    begin
      return peek_entry(instance, identifier_option, identifier).expected_element;
    end function peek_expected;

    impure function peek_expected(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return t_element is
    begin
      return peek_entry(1, identifier_option, identifier).expected_element;
    end function peek_expected;

    impure function peek_expected(
      constant instance : integer
    ) return t_element is
    begin
      return peek_entry(instance, POSITION, 1).expected_element;
    end function peek_expected;

    impure function peek_expected(
      constant void : t_void
    ) return t_element is
    begin
      return peek_entry(1, POSITION, 1).expected_element;
    end function peek_expected;

    ----------------------------------------------------------------------------------------------------
    --
    --  peek_source
    --
    --    Returns source element from queue entry based on position or entry number without deleting entry
    --
    ----------------------------------------------------------------------------------------------------
    impure function peek_source(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return string is
    begin
      return to_string(peek_entry(instance, identifier_option, identifier).source);
    end function peek_source;

    impure function peek_source(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return string is
    begin
      return peek_source(1, identifier_option, identifier);
    end function peek_source;

    impure function peek_source(
      constant instance : integer
    ) return string is
    begin
      return peek_source(instance, POSITION, 1);
    end function peek_source;

    impure function peek_source(
      constant void : t_void
    ) return string is
    begin
      return peek_source(1, POSITION, 1);
    end function peek_source;

    ----------------------------------------------------------------------------------------------------
    --
    --  peek_tag
    --
    --    Returns tag from queue entry based on position or entry number without deleting entry
    --
    ----------------------------------------------------------------------------------------------------
    impure function peek_tag(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return string is
    begin
      return to_string(peek_entry(instance, identifier_option, identifier).tag);
    end function peek_tag;

    impure function peek_tag(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return string is
    begin
      return peek_tag(1, identifier_option, identifier);
    end function peek_tag;

    impure function peek_tag(
      constant instance : integer
    ) return string is
    begin
      return peek_tag(instance, POSITION, 1);
    end function peek_tag;

    impure function peek_tag(
      constant void : t_void
    ) return string is
    begin
      return peek_tag(1, POSITION, 1);
    end function peek_tag;

    ----------------------------------------------------------------------------------------------------
    --  Non public fetch_entry
    --    Used by all fetch functions
    ----------------------------------------------------------------------------------------------------
    impure function fetch_entry(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return t_sb_entry is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      check_instance_in_range(instance);
      check_instance_enabled(instance);
      check_queue_empty(instance);

      v_sb_entry := priv_sb_queue.fetch(instance, identifier_option, identifier);

      priv_delete_cnt(instance) := priv_delete_cnt(instance) + 1;
      protected_sb_activity_register.decrement_sb_element_cnt(priv_index(instance));

      return v_sb_entry;

    end function fetch_entry;

    ----------------------------------------------------------------------------------------------------
    --
    --  fetch_expected
    --
    --    Returns expected element from queue entry based on position or entry number and deleting entry
    --
    ----------------------------------------------------------------------------------------------------
    impure function fetch_expected(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := ""
    ) return t_element is
      constant proc_name : string := "fetch_expected";
    begin
      -- Sanity checks in fetch entry
      -- Logging
      if ext_proc_call = "" then
        log(instance, ID_DATA, proc_name & "() => fetching expected by " & to_string(identifier_option) & " " & to_string(identifier) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      else
        log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      end if;
      return fetch_entry(instance, identifier_option, identifier).expected_element;
    end function fetch_expected;

    impure function fetch_expected(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := ""
    ) return t_element is
    begin
      return fetch_expected(1, identifier_option, identifier, msg, "fetch_expected() => fetching expected by " & to_string(identifier_option) & " " & to_string(identifier) & ". ");
    end function fetch_expected;

    impure function fetch_expected(
      constant instance : integer;
      constant msg      : string := ""
    ) return t_element is
    begin
      return fetch_expected(instance, POSITION, 1, msg);
    end function fetch_expected;

    impure function fetch_expected(
      constant msg : string
    ) return t_element is
    begin
      return fetch_expected(POSITION, 1, msg);
    end function fetch_expected;

    impure function fetch_expected(
      constant void : t_void
    ) return t_element is
    begin
      return fetch_expected(POSITION, 1);
    end function fetch_expected;

    ----------------------------------------------------------------------------------------------------
    --
    --  fetch_source
    --
    --    Returns source element from queue entry based on position or entry number and deleting entry
    --
    ----------------------------------------------------------------------------------------------------
    impure function fetch_source(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := ""
    ) return string is
      constant proc_name : string := "fetch_source";
    begin
      -- Sanity checks in fetch entry
      -- Logging
      if ext_proc_call = "" then
        log(instance, ID_DATA, proc_name & "() => fetching source by " & to_string(identifier_option) & " " & to_string(identifier) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      else
        log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      end if;
      return to_string(fetch_entry(instance, identifier_option, identifier).source);
    end function fetch_source;

    impure function fetch_source(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := ""
    ) return string is
    begin
      return fetch_source(1, identifier_option, identifier, msg, "fetch_source() => fetching source by " & to_string(identifier_option) & " " & to_string(identifier) & ". ");
    end function fetch_source;

    impure function fetch_source(
      constant instance : integer;
      constant msg      : string := ""
    ) return string is
    begin
      return fetch_source(instance, POSITION, 1, msg);
    end function fetch_source;

    impure function fetch_source(
      constant msg : string
    ) return string is
    begin
      return fetch_source(POSITION, 1, msg);
    end function fetch_source;

    impure function fetch_source(
      constant void : t_void
    ) return string is
    begin
      return fetch_source(POSITION, 1);
    end function fetch_source;

    ----------------------------------------------------------------------------------------------------
    --
    --  fetch_tag
    --
    --    Returns tag from queue entry based on position or entry number and deleting entry
    --
    ----------------------------------------------------------------------------------------------------
    impure function fetch_tag(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := ""
    ) return string is
      constant proc_name : string := "fetch_tag";
    begin
      -- Sanity checks in fetch entry
      -- Logging
      if ext_proc_call = "" then
        log(instance, ID_DATA, proc_name & "() => fetching tag by " & to_string(identifier_option) & " " & to_string(identifier) & ". " & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      else
        log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), priv_scope & "," & to_string(instance));
      end if;
      return to_string(fetch_entry(instance, identifier_option, identifier).tag);
    end function fetch_tag;

    impure function fetch_tag(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := ""
    ) return string is
    begin
      return fetch_tag(1, identifier_option, identifier, msg, "fetch_tag() => fetching tag by " & to_string(identifier_option) & " " & to_string(identifier) & ". ");
    end function fetch_tag;

    impure function fetch_tag(
      constant instance : integer;
      constant msg      : string := ""
    ) return string is
    begin
      return fetch_tag(instance, POSITION, 1, msg);
    end function fetch_tag;

    impure function fetch_tag(
      constant msg : string
    ) return string is
    begin
      return fetch_tag(POSITION, 1, msg);
    end function fetch_tag;

    impure function fetch_tag(
      constant void : t_void
    ) return string is
    begin
      return fetch_tag(POSITION, 1);
    end function fetch_tag;

    ----------------------------------------------------------------------------------------------------
    --
    --  exists
    --
    --    Returns true if entry exists, false if not.
    --
    ----------------------------------------------------------------------------------------------------
    impure function exists(
      constant instance         : integer;
      constant expected_element : t_element;
      constant tag_usage        : t_tag_usage := NO_TAG;
      constant tag              : string      := ""
    ) return boolean is
    begin
      return (find_expected_position(instance, expected_element, tag_usage, tag) /= C_NO_MATCH);
    end function exists;

    impure function exists(
      constant expected_element : t_element;
      constant tag_usage        : t_tag_usage := NO_TAG;
      constant tag              : string      := ""
    ) return boolean is
    begin
      return exists(1, expected_element, tag_usage, tag);
    end function exists;

    impure function exists(
      constant instance  : integer;
      constant tag_usage : t_tag_usage;
      constant tag       : string
    ) return boolean is
    begin
      return (find_expected_position(instance, tag_usage, tag) /= C_NO_MATCH);
    end function exists;

    impure function exists(
      constant tag_usage : t_tag_usage;
      constant tag       : string
    ) return boolean is
    begin
      return exists(1, tag_usage, tag);
    end function exists;

  end protected body;

end package body generic_sb_pkg;
