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

use std.textio.all;

use work.csv_file_reader_pkg.all;

package spec_cov_pkg is

  type t_requirement_type is (NA, SUB_REQ, COMPOUND_REQ);

  type t_spec_cov_config is record
    missing_req_label_severity    : t_alert_level; -- Alert level used when the tick_off_req_cov() procedure does not find the specified
                                                   -- requirement label in the requirement list.
    compound_req_tickoff_severity : t_alert_level; -- Alert level used when tickoff is performed on a requirement that has sub requirements.
    csv_delimiter                 : character;     -- Character used as delimiter in the CSV files. Default is ",".
    max_requirement_lines         : natural;       -- Maximum number of requirement lines in the req list file used in initialize_req_cov().
    max_testcases_per_req         : natural;       -- Max number of testcases allowed per requirement.
    csv_max_line_length           : positive;      -- Max length of each line in any CSV file.
  end record;

  constant C_SPEC_COV_CONFIG_DEFAULT : t_spec_cov_config := (
    missing_req_label_severity    => C_MISSING_REQ_LABEL_SEVERITY,
    compound_req_tickoff_severity => C_COMPOUND_REQ_TICKOFF_SEVERITY,
    csv_delimiter                 => C_CSV_DELIMITER,
    max_requirement_lines         => C_MAX_REQUIREMENT_LINES,
    max_testcases_per_req         => C_MAX_TESTCASES_PER_REQ,
    csv_max_line_length           => C_CSV_FILE_MAX_LINE_LENGTH
  );

  -- Shared variable for configuring the Spec Cov VIP from the testbench sequencer.
  shared variable shared_spec_cov_config : t_spec_cov_config := C_SPEC_COV_CONFIG_DEFAULT;

  file RESULT_FILE : text;

  procedure initialize_req_cov(
    constant testcase         : string;
    constant req_list_file    : string;
    constant partial_cov_file : string;
    constant map_list_file    : string := ""
  );
  -- Overloading procedure
  procedure initialize_req_cov(
    constant testcase         : string;
    constant partial_cov_file : string
  );

  procedure tick_off_req_cov(
    constant requirement        : string;
    constant requirement_status : t_test_status    := NA;
    constant msg                : string           := "";
    constant tickoff_extent     : t_extent_tickoff := LIST_SINGLE_TICKOFF;
    constant scope              : string           := C_SCOPE
  );

  procedure cond_tick_off_req_cov(
    constant requirement        : string;
    constant requirement_status : t_test_status    := NA;
    constant msg                : string           := "";
    constant tickoff_extent     : t_extent_tickoff := LIST_SINGLE_TICKOFF;
    constant scope              : string           := C_SCOPE
  );

  procedure disable_cond_tick_off_req_cov(
    constant requirement : string
  );

  procedure enable_cond_tick_off_req_cov(
    constant requirement : string
  );

  procedure finalize_req_cov(
    constant VOID : t_void
  );

  --=================================================================================================  
  -- Functions and procedures declared below this line are intended as private internal functions
  --=================================================================================================  

  procedure priv_log_entry(
    constant index : natural
  );

  procedure priv_read_and_parse_req_csv_file(
    constant req_list_file : string
  );

  procedure priv_read_and_parse_map_csv_file(
    constant map_list_file : string
  );

  procedure priv_initialize_result_file(
    constant file_name : string
  );

  impure function priv_get_description(
    requirement : string
  ) return string;

  procedure priv_set_description(
    constant requirement : string;
    constant description : string
  );

  impure function priv_get_requirement_type(
    requirement : string
  ) return t_requirement_type;

  procedure priv_set_requirement_type(
    constant requirement : string;
    constant req_type    : t_requirement_type
  );

  impure function priv_requirement_exists(
    requirement : string
  ) return boolean;

  impure function priv_get_num_requirement_tick_offs(
    requirement : string
  ) return natural;

  impure function priv_get_requirement_status(
    requirement : string
  ) return t_test_status;

  procedure priv_set_requirement_status(
    constant requirement : string;
    constant status      : t_test_status
  );

  impure function priv_get_requirement_index(
    requirement : string
  ) return natural;

  procedure priv_inc_num_requirement_tick_offs(
    constant requirement : string
  );

  function priv_test_status_to_string(
    test_status : t_test_status
  ) return string;

  impure function priv_get_summary_string
  return string;

  procedure priv_set_default_testcase_name(
    constant testcase : string
  );

  impure function priv_get_default_testcase_name
  return string;

  impure function priv_find_string_length(
    search_string : string
  ) return natural;

  impure function priv_get_requirement_name_length(
    requirement : string)
  return natural;

  impure function priv_req_listed_in_disabled_tick_off_array(
    requirement : string
  ) return boolean;

end package spec_cov_pkg;

--=================================================================================================
--=================================================================================================
--=================================================================================================

package body spec_cov_pkg is

  constant C_FAIL_STRING : string := "FAIL";
  constant C_PASS_STRING : string := "PASS";

  type t_line_vector is array (0 to shared_spec_cov_config.max_testcases_per_req - 1) of line;
  type t_requirement_entry is record
    valid        : boolean;
    requirement  : line;
    description  : line;
    num_tcs      : natural;
    tc_list      : t_line_vector;
    num_tickoffs : natural;
    status       : t_test_status;
    req_type     : t_requirement_type;
  end record;
  type t_requirement_entry_array is array (natural range <>) of t_requirement_entry;

  -- Shared variables used internally in this context
  shared variable priv_csv_file                : csv_file_reader_type;
  shared variable priv_requirement_array       : t_requirement_entry_array(0 to shared_spec_cov_config.max_requirement_lines);
  shared variable priv_requirements_in_array   : natural                                 := 0;
  shared variable priv_testcase_name           : string(1 to C_CSV_FILE_MAX_LINE_LENGTH) := (others => NUL);
  shared variable priv_testcase_passed         : boolean;
  shared variable priv_requirement_file_exists : boolean;
  shared variable priv_result_file_exists      : boolean;
  shared variable priv_req_cov_initialized     : boolean                                 := false;

  type t_disabled_tick_off_array is array (0 to shared_spec_cov_config.max_requirement_lines) of string(1 to C_CSV_FILE_MAX_LINE_LENGTH);
  shared variable priv_disabled_tick_off_array : t_disabled_tick_off_array := (others => (others => NUL));

  --
  -- Initialize testcase requirement coverage
  --
  procedure initialize_req_cov(
    constant testcase         : string;
    constant req_list_file    : string;
    constant partial_cov_file : string;
    constant map_list_file    : string := ""
  ) is
  begin
    log(ID_SPEC_COV_INIT, "Initializing requirement coverage with requirement file: " & req_list_file, C_SCOPE);
    priv_set_default_testcase_name(testcase);

    -- Update pkg local variables
    priv_testcase_passed         := true;
    priv_requirement_file_exists := true;

    -- Read requirements from CSV file and save to array. TB_ERROR alert will be raised if file is emtpy.
    priv_read_and_parse_req_csv_file(req_list_file);
    if map_list_file /= "" then
      priv_read_and_parse_map_csv_file(map_list_file);
    end if;

    -- Initialize PC file (open file and write info/settings to top of file)
    priv_initialize_result_file(partial_cov_file);

    -- Flag that initialization has been done
    priv_req_cov_initialized := true;
  end procedure initialize_req_cov;

  -- Overloading procedure
  procedure initialize_req_cov(
    constant testcase         : string;
    constant partial_cov_file : string
  ) is
  begin
    log(ID_SPEC_COV_INIT, "Initializing requirement coverage without requirement file.", C_SCOPE);
    priv_set_default_testcase_name(testcase);
    -- update pkg local variables
    priv_testcase_passed         := true;
    priv_requirement_file_exists := false;

    priv_initialize_result_file(partial_cov_file);

    -- Flag that initialization has been done
    priv_req_cov_initialized     := true;
  end procedure initialize_req_cov;

  --
  -- Log the requirement and testcase
  --
  procedure tick_off_req_cov(
    constant requirement        : string;
    constant requirement_status : t_test_status    := NA;
    constant msg                : string           := "";
    constant tickoff_extent     : t_extent_tickoff := LIST_SINGLE_TICKOFF;
    constant scope              : string           := C_SCOPE
  ) is
    variable v_requirement_to_file_line : line;
    variable v_requirement_status       : t_test_status;
    variable v_prev_requirement_status  : t_test_status;
  begin
    -- Raise TB_ERROR alert if tick_off_req_cov() is called before initialize_req_cov()
    if not priv_req_cov_initialized  then
      alert(TB_ERROR, "Requirement coverage has not been initialized. Please use initialize_req_cov() before calling tick_off_req_cov().", scope);
      return;
    end if;

    -- Check if requirement exists
    if priv_requirement_file_exists and not priv_requirement_exists(requirement) then
      alert(shared_spec_cov_config.missing_req_label_severity, "Requirement not found in requirement list: " & to_string(requirement), C_SCOPE);
    end if;

    -- Issue TB_WARNING if requirement is a compound requirement (supposed to be tested through sub-requirements)
    if priv_get_requirement_type(requirement) = COMPOUND_REQ then
      alert(TB_WARNING, "Requirement " & to_string(requirement) & " has been specified for testing through sub-requirements." , C_SCOPE);
    end if;

    ---- Check if there were any errors globally or testcase was explicit set to FAIL
    if shared_uvvm_status.found_unexpected_simulation_errors_or_worse = 1 then
      v_requirement_status := FAIL;
      -- Set failing testcase for finishing summary line
      priv_testcase_passed := false;
    elsif requirement_status = FAIL then
        v_requirement_status := FAIL;
    else
      v_requirement_status := PASS;
    end if;

    -- Get previous requirement status (used for checking for PASS to FAIL transition)
    v_prev_requirement_status := priv_get_requirement_status(requirement);   

    -- Save requirement status
    priv_set_requirement_status(requirement, v_requirement_status);

    -- Check if requirement tick-off should be written
    if (tickoff_extent = LIST_EVERY_TICKOFF) or (priv_get_num_requirement_tick_offs(requirement) = 0) or (v_prev_requirement_status = PASS and v_requirement_status = FAIL) then
      -- Log result to transcript
      log(ID_SPEC_COV, "Logging requirement " & requirement & " [" & priv_test_status_to_string(v_requirement_status) & "]. '" & priv_get_description(requirement) & "'. " & msg, scope);
      -- Log to file
      if priv_result_file_exists then
        write(v_requirement_to_file_line, requirement & C_CSV_DELIMITER & priv_get_default_testcase_name & C_CSV_DELIMITER & priv_test_status_to_string(v_requirement_status));
        writeline(RESULT_FILE, v_requirement_to_file_line);
        deallocate(v_requirement_to_file_line);
      end if;
      -- Increment number of tick off for this requirement
      priv_inc_num_requirement_tick_offs(requirement);
    end if;
  end procedure tick_off_req_cov;

  --
  -- Conditional tick_off_req_cov() for selected requirement.
  --   If the requirement has been enabled for conditional tick_off_req_cov()
  --   with enable_cond_tick_off_req_cov() it will not be ticked off.
  procedure cond_tick_off_req_cov(
    constant requirement        : string;
    constant requirement_status : t_test_status    := NA;
    constant msg                : string           := "";
    constant tickoff_extent     : t_extent_tickoff := LIST_SINGLE_TICKOFF;
    constant scope              : string           := C_SCOPE
  ) is
  begin
    -- Check: is requirement listed in the conditional tick off array?
    if priv_req_listed_in_disabled_tick_off_array(requirement) = false then
      -- requirement was not listed, call tick off method.
      tick_off_req_cov(requirement, requirement_status, msg, tickoff_extent, scope);
    end if;
  end procedure cond_tick_off_req_cov;

  --
  -- Disable conditional tick_off_req_cov() setting for
  --   selected requirement.
  --
  procedure disable_cond_tick_off_req_cov(
    constant requirement : string
  ) is
    constant c_requirement_length : natural := priv_get_requirement_name_length(requirement);
  begin
    -- Check: is requirement already tracked?
    --        method will also check if the requirement exist in the requirement file.
    if priv_req_listed_in_disabled_tick_off_array(requirement) = true then
      alert(TB_WARNING, "Requirement " & requirement & " is already listed in the conditional tick off array.", C_SCOPE);
      return;
    end if;

    -- add requirement to conditional tick off array.
    for idx in 0 to priv_disabled_tick_off_array'length - 1 loop
      -- find a free entry, add requirement and exit loop
      if priv_disabled_tick_off_array(idx)(1) = NUL then
        priv_disabled_tick_off_array(idx)(1 to c_requirement_length) := to_upper(requirement);
        exit;
      end if;
    end loop;
  end procedure disable_cond_tick_off_req_cov;

  --
  -- Enable conditional tick_off_req_cov() setting for
  --   selected requirement.
  --
  procedure enable_cond_tick_off_req_cov(
    constant requirement : string
  ) is
    constant c_requirement_length : natural := priv_get_requirement_name_length(requirement);
  begin
    -- Check: is requirement not tracked?
    --        method will also check if the requirement exist in the requirement file.
    if priv_req_listed_in_disabled_tick_off_array(requirement) = false then
      alert(TB_WARNING, "Requirement " & requirement & " is not listed in the conditional tick off array.", C_SCOPE);

    else                                -- requirement is tracked
      -- find the requirement and wipe it out from conditional tick off array
      for idx in 0 to priv_disabled_tick_off_array'length - 1 loop
        -- found requirement, wipe the entry and exit
        if priv_disabled_tick_off_array(idx)(1 to c_requirement_length) = to_upper(requirement) then
          priv_disabled_tick_off_array(idx) := (others => NUL);
          exit;
        end if;
      end loop;
    end if;
  end procedure enable_cond_tick_off_req_cov;

  --
  -- Deallocate memory usage and write summary line to partial_cov file
  --
  procedure finalize_req_cov(
    constant VOID : t_void
  ) is
    variable v_checksum_string : line;
  begin
    -- Free used memory
    log(ID_SPEC_COV, "Finalizing requirement coverage", C_SCOPE);

    for i in 0 to priv_requirements_in_array - 1 loop
      deallocate(priv_requirement_array(i).requirement);
      deallocate(priv_requirement_array(i).description);
      for tc in 0 to priv_requirement_array(i).num_tcs - 1 loop
        deallocate(priv_requirement_array(i).tc_list(tc));
      end loop;
      priv_requirement_array(i).num_tcs      := 0;
      priv_requirement_array(i).valid        := false;
      priv_requirement_array(i).num_tickoffs := 0;
    end loop;
    priv_requirements_in_array := 0;

    -- Add closing line
    if priv_result_file_exists then
      write(v_checksum_string, priv_get_summary_string);
      writeline(RESULT_FILE, v_checksum_string);
      deallocate(v_checksum_string);
      file_close(RESULT_FILE);
    end if;

    -- Clear initialization flag. initialize_req_cov() must be called again before another tickoff can be done
    priv_req_cov_initialized := false;
  end procedure finalize_req_cov;

  --=================================================================================================  
  -- Functions and procedures declared below this line are intended as private internal functions
  --=================================================================================================  

  --
  -- Initialize the partial_cov result file
  --
  procedure priv_initialize_result_file(
    constant file_name : string
  ) is
    variable v_file_open_status      : FILE_OPEN_STATUS;
    variable v_settings_to_file_line : line;
  begin
    file_open(v_file_open_status, RESULT_FILE, file_name, write_mode);
    check_file_open_status(v_file_open_status, file_name);

    if v_file_open_status = open_ok then
      priv_result_file_exists := true;
    else
      priv_result_file_exists := false;
      return;
    end if;

    -- Write info and settings to CSV file for Python post-processing script
    log(ID_SPEC_COV_INIT, "Adding test and configuration information to coverage file: " & file_name, C_SCOPE);
    write(v_settings_to_file_line, "NOTE: This coverage file is only valid when the last line is 'SUMMARY, " & priv_get_default_testcase_name & ", PASS'" & LF);
    write(v_settings_to_file_line, "TESTCASE_NAME: " & priv_get_default_testcase_name & LF);
    write(v_settings_to_file_line, "DELIMITER: " & shared_spec_cov_config.csv_delimiter & LF);
    writeline(RESULT_FILE, v_settings_to_file_line);
    deallocate(v_settings_to_file_line);
  end procedure priv_initialize_result_file;

  --
  -- Read requirement CSV file
  --
  procedure priv_read_and_parse_req_csv_file(
    constant req_list_file : string
  ) is
    variable v_tc_valid : boolean;
    variable v_file_ok  : boolean;
    variable v_requirement : string(1 to C_CSV_FILE_MAX_LINE_LENGTH) := (others => NUL);
  begin
    if priv_requirements_in_array > 0 then
      alert(TB_ERROR, "Requirements have already been read from file, please call finalize_req_cov before starting a new requirement coverage process.", C_SCOPE);
      return;
    end if;

    -- Open file and check status, return if failing
    v_file_ok := priv_csv_file.initialize(req_list_file, C_CSV_DELIMITER);
    if v_file_ok = false then
      return;
    end if;

    -- File ok, read file
    while not priv_csv_file.end_of_file loop
      priv_csv_file.readline;

      if priv_requirements_in_array >= shared_spec_cov_config.max_requirement_lines then -- Too many requirement lines
        alert(TB_FAILURE, "Number of requirement lines in requirement list file exceeds maximum limit set by C_MAX_REQUIREMENT_LINES in adaptations_pkg.", C_SCOPE);
        exit;

      else
        -- Read requirement
        v_requirement := priv_csv_file.read_string;
        if (v_requirement(1) /= '#')  and (v_requirement(1) /= NUL) then -- Ignore if comment or empty line
          priv_requirement_array(priv_requirements_in_array).requirement := new string'(v_requirement);
          -- Read description
          priv_requirement_array(priv_requirements_in_array).description := new string'(priv_csv_file.read_string);
          -- Read testcases
          v_tc_valid                                                     := true;
          priv_requirement_array(priv_requirements_in_array).num_tcs     := 0;
          while v_tc_valid loop
            priv_requirement_array(priv_requirements_in_array).tc_list(priv_requirement_array(priv_requirements_in_array).num_tcs) := new string'(priv_csv_file.read_string);
            if (priv_requirement_array(priv_requirements_in_array).tc_list(priv_requirement_array(priv_requirements_in_array).num_tcs).all(1) /= NUL) then
              priv_requirement_array(priv_requirements_in_array).num_tcs := priv_requirement_array(priv_requirements_in_array).num_tcs + 1;
            else
              v_tc_valid := false;
            end if;
          end loop;
          priv_requirement_array(priv_requirements_in_array).req_type    := NA;
          -- Validate entry
          priv_requirement_array(priv_requirements_in_array).valid       := true;

          -- Set number of tickoffs for this requirement to 0
          priv_requirement_array(priv_requirements_in_array).num_tickoffs := 0;

          priv_log_entry(priv_requirements_in_array);
          priv_requirements_in_array := priv_requirements_in_array + 1;
        end if;
      end if;
    end loop;

    priv_csv_file.dispose;
  end procedure priv_read_and_parse_req_csv_file;

  --
  -- Read map CSV file
  --
  procedure priv_read_and_parse_map_csv_file(
    constant map_list_file : string
  ) is
    variable v_tc_valid          : boolean;
    variable v_req_valid         : boolean;
    variable v_file_ok           : boolean;
    variable v_requirement       : string(1 to C_CSV_FILE_MAX_LINE_LENGTH) := (others => NUL);
    variable v_sub_requirement   : line;
    variable v_requirement_index : natural;
  begin

    -- Open file and check status, return if failing
    v_file_ok := priv_csv_file.initialize(map_list_file, C_CSV_DELIMITER);
    if v_file_ok = false then
      return;
    end if;

    -- File ok, read file
    while not priv_csv_file.end_of_file loop
      priv_csv_file.readline;

      -- Read requirement
      v_requirement := priv_csv_file.read_string;
      if (v_requirement(1) /= '#') and (v_requirement(1) /= NUL) then -- Ignore if comment or empty line

        -- Check if requirement already exist in requirement list
        if priv_requirement_exists(v_requirement) then
          v_requirement_index := priv_get_requirement_index(v_requirement);

          -- If the requirement has been marked as a sub requirement, it means that this is a line specifying description and testcases
          -- for a sub-requirement previously defined in a sub-req mappling line.
          if priv_get_requirement_type(v_requirement) = SUB_REQ then
            -- Add description if existing requirement entry doesn't have one
            if priv_get_description(v_requirement) = "" then
              priv_set_description(v_requirement, priv_csv_file.read_string);
            end if;
            -- Add testcases
            v_tc_valid := true;
            while v_tc_valid loop
              priv_requirement_array(v_requirement_index).tc_list(priv_requirement_array(v_requirement_index).num_tcs) := new string'(priv_csv_file.read_string);
              if (priv_requirement_array(v_requirement_index).tc_list(priv_requirement_array(v_requirement_index).num_tcs).all(1) /= NUL) then
                priv_requirement_array(v_requirement_index).num_tcs := priv_requirement_array(v_requirement_index).num_tcs + 1;
              else
                v_tc_valid := false;
              end if;
            end loop;
            priv_log_entry(v_requirement_index); -- Write log entry for requirement

          -- If requirement exists in requirement list, but is not marked as a sub requirement, it means that the line is a
          -- requirement to sub-requirement mapping line, where the compound requirement was previously defined in the requirement file.
          else
            -- Mark the requirement as compound requirement
            priv_set_requirement_type(v_requirement, COMPOUND_REQ);
            -- Add sub requirements to requirement list
            v_req_valid := true;
            while v_req_valid loop
              v_sub_requirement := new string'(priv_csv_file.read_string);
              if v_sub_requirement.all(1) /= NUL  then
                priv_requirement_array(priv_requirements_in_array).requirement  := v_sub_requirement;
                priv_requirement_array(priv_requirements_in_array).req_type     := SUB_REQ;
                priv_requirement_array(priv_requirements_in_array).valid        := true;
                priv_requirement_array(priv_requirements_in_array).num_tickoffs := 0;

                priv_requirements_in_array := priv_requirements_in_array + 1;
              else
                v_req_valid := false;
              end if;
            end loop;
          end if;



        -- If the requirement doesn't exist in requirement list, it means that the line is a requirement to sub requirement mapping
        -- line, where the sub-requirements have previously been defined in the requirement list, and the compound requirement has not
        -- previously been defined anywhere.
        else
          -- Add compound requirement to list
          priv_requirement_array(priv_requirements_in_array).requirement  := new string'(v_requirement);
          priv_requirement_array(priv_requirements_in_array).req_type     := COMPOUND_REQ;
          priv_requirement_array(priv_requirements_in_array).valid        := true;
          priv_requirement_array(priv_requirements_in_array).num_tickoffs := 0;
          priv_log_entry(priv_requirements_in_array);
          priv_requirements_in_array := priv_requirements_in_array + 1;
        end if;
      end if;
    end loop;

    priv_csv_file.dispose;
  end procedure priv_read_and_parse_map_csv_file;


  --
  -- Log CSV readout to terminal
  --
  procedure priv_log_entry(
    constant index : natural
  ) is
    variable v_line : line;
    variable v_description : line;
  begin
    if priv_requirement_array(index).valid then
      -- log requirement and description to terminal
      -- If requirement doesn't have a description (might occur if old input format, with compound req first seen in map file), set a
      -- replacement text ("no description")
      v_description := priv_requirement_array(index).description;
      if v_description = NULL then
        v_description := new string'("no description");
      end if;
      log(ID_SPEC_COV_REQS, "Requirement: " & priv_requirement_array(index).requirement.all & ", " & v_description.all, C_SCOPE);
      -- log testcases to terminal
      if priv_requirement_array(index).num_tcs > 0 then
        write(v_line, string'("  TC: "));
        for i in 0 to priv_requirement_array(index).num_tcs - 1 loop
          if i > 0 then
            write(v_line, string'(", "));
          end if;
          write(v_line, priv_requirement_array(index).tc_list(i).all);
        end loop;
        log(ID_SPEC_COV_REQS, v_line.all, C_SCOPE);
        deallocate(v_line);
      end if;
    else
      log(ID_SPEC_COV_REQS, "Requirement entry was not valid", C_SCOPE);
    end if;
  end procedure priv_log_entry;

  --
  -- Check if requirement exists, return boolean
  -- 
  impure function priv_requirement_exists(
    requirement : string
  ) return boolean is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_get_requirement_name_length(priv_requirement_array(i).requirement.all) = valid_length(requirement) then
        if to_upper(priv_requirement_array(i).requirement.all(1 to valid_length(requirement))) = to_upper(requirement(1 to valid_length(requirement))) then
          return true;
        end if;
      end if;
    end loop;
    return false;
  end function priv_requirement_exists;

  --
  -- Get number of tick offs for requirement
  --
  impure function priv_get_num_requirement_tick_offs(
    requirement : string
  ) return natural is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_get_requirement_name_length(priv_requirement_array(i).requirement.all) = valid_length(requirement) then
        if to_upper(priv_requirement_array(i).requirement.all(1 to valid_length(requirement))) = to_upper(requirement(1 to valid_length(requirement))) then
          return priv_requirement_array(i).num_tickoffs;
        end if;
      end if;
    end loop;
    return 0;
  end function priv_get_num_requirement_tick_offs;

  -- 
  -- Set tick off status for requirement
  --
  procedure priv_set_requirement_status(
    constant requirement : string;
    constant status      : t_test_status
  ) is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_get_requirement_name_length(priv_requirement_array(i).requirement.all) = valid_length(requirement) then
        if to_upper(priv_requirement_array(i).requirement.all(1 to valid_length(requirement))) = to_upper(requirement(1 to valid_length(requirement))) then
          priv_requirement_array(i).status := status;
        end if;
      end if;
    end loop;
  end procedure priv_set_requirement_status;

  --
  -- Get the most recent tick off status for requirement
  --
  impure function priv_get_requirement_status(
    requirement : string
  ) return t_test_status is
  begin 
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_get_requirement_name_length(priv_requirement_array(i).requirement.all) = valid_length(requirement) then
        if to_upper(priv_requirement_array(i).requirement.all(1 to valid_length(requirement))) = to_upper(requirement(1 to valid_length(requirement))) then
          return priv_requirement_array(i).status;
        end if;
      end if;
    end loop;
    return NA;
  end function priv_get_requirement_status;

  impure function priv_get_requirement_index(
    requirement : string
  ) return natural is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_get_requirement_name_length(priv_requirement_array(i).requirement.all) = valid_length(requirement) then
        if to_upper(priv_requirement_array(i).requirement.all(1 to valid_length(requirement))) = to_upper(requirement(1 to valid_length(requirement))) then
          return i;
        end if;
      end if;
    end loop;
    return 0;
  end function priv_get_requirement_index;

  --
  -- Increment number of tick offs for requirement
  --
  procedure priv_inc_num_requirement_tick_offs(
    constant requirement : string
  ) is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_get_requirement_name_length(priv_requirement_array(i).requirement.all) = valid_length(requirement) then
        if to_upper(priv_requirement_array(i).requirement.all(1 to valid_length(requirement))) = to_upper(requirement(1 to valid_length(requirement))) then
          priv_requirement_array(i).num_tickoffs := priv_requirement_array(i).num_tickoffs + 1;
        end if;
      end if;
    end loop;
  end procedure priv_inc_num_requirement_tick_offs;

  --
  -- Get description of requirement
  --
  impure function priv_get_description(
    requirement : string
  ) return string is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_requirement_array(i).requirement.all(1 to valid_length(requirement)) = requirement(1 to valid_length(requirement)) then
        -- Found requirement
        if priv_requirement_array(i).description = NULL then
          return "";
        else
          return priv_requirement_array(i).description.all;
        end if;
      end if;
    end loop;

    if priv_requirement_file_exists = false then
      return "";
    else
      return "DESCRIPTION NOT FOUND";
    end if;
  end function priv_get_description;

  --
  -- Set description for a requirement
  --
  procedure priv_set_description(
    constant requirement : string;
    constant description : string
  ) is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_requirement_array(i).requirement.all(1 to valid_length(requirement)) = requirement(1 to valid_length(requirement)) then
        -- Found requirement
        priv_requirement_array(i).description := new string'(description);
      end if;
    end loop;
  end procedure priv_set_description;

  impure function priv_get_requirement_type(
    requirement : string
  ) return t_requirement_type is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_requirement_array(i).requirement.all(1 to valid_length(requirement)) = requirement(1 to valid_length(requirement)) then
        -- Found requirement
        return priv_requirement_array(i).req_type;
      end if;
    end loop;

    return NA;
  end function priv_get_requirement_type;

  procedure priv_set_requirement_type(
    constant requirement : string;
    constant req_type    : t_requirement_type
  ) is
  begin
    for i in 0 to priv_requirements_in_array - 1 loop
      if priv_requirement_array(i).requirement.all(1 to valid_length(requirement)) = requirement(1 to valid_length(requirement)) then
        -- Found requirement
        priv_requirement_array(i).req_type := req_type;
      end if;
    end loop;
  end procedure priv_set_requirement_type;

  --
  -- Get the t_test_status parameter as string
  --
  function priv_test_status_to_string(
    test_status : t_test_status
  ) return string is
  begin
    if test_status = PASS then
      return C_PASS_STRING;
    else                                -- test_status = FAIL
      return C_FAIL_STRING;
    end if;
  end function priv_test_status_to_string;

  --
  -- Get a string for finalize summary in the partial_cov CSV file.
  --
  impure function priv_get_summary_string
  return string is
  begin
    -- Create a CSV coverage file summary string
    if (priv_testcase_passed = true) and (shared_uvvm_status.found_unexpected_simulation_errors_or_worse = 0) then
      return "SUMMARY, " & priv_get_default_testcase_name & ", " & C_PASS_STRING;
    else
      return "SUMMARY, " & priv_get_default_testcase_name & ", " & C_FAIL_STRING;
    end if;
  end function priv_get_summary_string;

  --
  -- Set the default testcase name.
  --
  procedure priv_set_default_testcase_name(
    constant testcase : string
  ) is
  begin
    priv_testcase_name := (others => NUL);
    priv_testcase_name(1 to testcase'length) := testcase;
  end procedure priv_set_default_testcase_name;

  --
  -- Return the default testcase name set when initialize_req_cov() was called.
  --
  impure function priv_get_default_testcase_name
  return string is
    variable v_testcase_length : natural := priv_find_string_length(priv_testcase_name);
  begin
    return priv_testcase_name(1 to v_testcase_length);
  end function priv_get_default_testcase_name;

  --
  -- Find the length of a string which will contain NUL characters.
  --
  impure function priv_find_string_length(
    search_string : string
  ) return natural is
    variable v_return : natural := 0;
  begin
    -- loop string until NUL is found and return idx-1
    for idx in 1 to search_string'length loop
      if search_string(idx) = NUL then
        return idx - 1;
      end if;
    end loop;

    -- NUL was not found, return full length
    return search_string'length;
  end function priv_find_string_length;

  --
  -- Get length of requirement name
  --
  impure function priv_get_requirement_name_length(
    requirement : string)
  return natural is
    variable v_length : natural := 0;
  begin
    for i in 1 to valid_length(requirement) loop
      if requirement(i) = NUL then
        exit;
      else
        v_length := v_length + 1;
      end if;
    end loop;
    return v_length;
  end function priv_get_requirement_name_length;

  --
  -- Check if requirement is listed in the priv_disabled_tick_off_array() array.
  --
  impure function priv_req_listed_in_disabled_tick_off_array(
    requirement : string
  ) return boolean is
    constant c_requirement_length : natural := priv_get_requirement_name_length(requirement);
  begin
    -- Check if requirement exists
    if (priv_requirement_exists(requirement) = false) and (priv_requirement_file_exists = true) then
      alert(shared_spec_cov_config.missing_req_label_severity, "Requirement not found in requirement list: " & to_string(requirement), C_SCOPE);
    end if;

    -- Check if requirement is listed in priv_disabled_tick_off_array() array
    for idx in 0 to priv_disabled_tick_off_array'length - 1 loop
      -- found
      if priv_disabled_tick_off_array(idx)(1 to c_requirement_length) = to_upper(requirement(1 to c_requirement_length)) then
        return true;
      end if;
    end loop;
    -- not found
    return false;
  end function priv_req_listed_in_disabled_tick_off_array;

end package body spec_cov_pkg;
