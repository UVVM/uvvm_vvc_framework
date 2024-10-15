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
use std.textio.all;

use work.types_pkg.all;
use work.string_methods_pkg.all;
use work.adaptations_pkg.all;
use work.global_signals_and_shared_variables_pkg.all;

package hierarchy_linked_list_pkg is

  type t_hierarchy_linked_list is protected
    procedure initialize_hierarchy(
      base_scope : string := "";
      stop_limit : t_alert_counters);
    procedure insert_in_tree(
      hierarchy_node : t_hierarchy_node;
      parent_scope   : string);
    impure function is_empty
    return boolean;
    impure function is_not_empty
    return boolean;
    impure function get_size
    return natural;
    procedure clear;
    impure function contains_scope(
      scope : string
    ) return boolean;
    procedure contains_scope_return_data(
      scope                   : string;
      variable result         : out boolean;
      variable hierarchy_node : out t_hierarchy_node);
    procedure alert(
      constant scope       : string;
      constant alert_level : t_alert_level;
      constant attention   : t_attention := REGARD;
      constant msg         : string      := "");
    procedure increment_expected_alerts(
      scope       : string;
      alert_level : t_alert_level;
      amount      : natural := 1);
    procedure set_expected_alerts(
      scope           : string;
      alert_level     : t_alert_level;
      expected_alerts : natural);
    impure function get_expected_alerts(
      scope       : string;
      alert_level : t_alert_level
    ) return natural;
    procedure increment_stop_limit(
      scope       : string;
      alert_level : t_alert_level;
      amount      : natural := 1);
    procedure set_stop_limit(
      scope       : string;
      alert_level : t_alert_level;
      stop_limit  : natural);
    impure function get_stop_limit(
      scope       : string;
      alert_level : t_alert_level
    ) return natural;
    procedure print_hierarchical_log(
      order : t_order := FINAL);
    impure function get_parent_scope(
      scope : string(1 to C_HIERARCHY_NODE_NAME_LENGTH))
    return string;
    procedure change_parent(
      scope        : string;
      parent_scope : string
    );
    procedure set_top_level_stop_limit(
      alert_level : t_alert_level;
      value       : natural
    );
    impure function get_top_level_stop_limit(
      alert_level : t_alert_level
    ) return natural;
    procedure enable_alert_level(
      scope       : string;
      alert_level : t_alert_level
    );
    procedure disable_alert_level(
      scope       : string;
      alert_level : t_alert_level
    );
    procedure enable_all_alert_levels(
      scope : string
    );
    procedure disable_all_alert_levels(
      scope : string
    );
  end protected;
end package hierarchy_linked_list_pkg;

package body hierarchy_linked_list_pkg is

  type t_hierarchy_linked_list is protected body

    -- Types and control variables for the linked list implementation
    type t_element;
    type t_element_ptr is access t_element;
    type t_element is record
      first_child     : t_element_ptr;  -- Pointer to the first element in a linked list of children
      next_sibling    : t_element_ptr;  -- Pointer to the next element in a linked list of siblings
      prev_sibling    : t_element_ptr;  -- Pointer to the previous element in a linked list of siblings
      parent          : t_element_ptr;
      element_data    : t_hierarchy_node;
      hierarchy_level : natural;        -- How far down the tree this node is. Used when printing summary.
    end record;

    variable priv_top_element_ptr      : t_element_ptr;
    variable priv_num_elements_in_tree : natural := 0;

    variable priv_max_hierarchy_level : natural := 0;

    -- Initialization variables
    variable priv_has_been_initialized : boolean := false;
    variable priv_base_scope           : string(1 to C_HIERARCHY_NODE_NAME_LENGTH);

    procedure initialize_hierarchy(
      base_scope : string := "";
      stop_limit : t_alert_counters) is
      variable priv_base_scope : string(1 to C_HIERARCHY_NODE_NAME_LENGTH)                 := justify(base_scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
      variable base_node    : t_hierarchy_node(name(1 to C_HIERARCHY_NODE_NAME_LENGTH)) := (
        priv_base_scope,
        (others => (others => 0)),
        stop_limit,
        (others => true));
    begin
      if not priv_has_been_initialized then
        -- Generate a base node.
        insert_in_tree(base_node, "");
        priv_base_scope           := priv_base_scope;
        priv_has_been_initialized := true;
      end if;
    end procedure;

    procedure search_for_scope(
      variable starting_node : in t_element_ptr;
      scope                  : string;
      variable result_node   : out t_element_ptr;
      variable found         : out boolean
    ) is
      variable v_current_ptr : t_element_ptr                             := null;
      variable v_found       : boolean                                   := false;
      variable v_scope       : string(1 to C_HIERARCHY_NODE_NAME_LENGTH) := justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
    begin
      found := false;
      -- is this the correct scope?
      if starting_node.element_data.name = v_scope then
        result_node := starting_node;
        found       := true;
        return;
      end if;

      -- Go downwards in the tree.
      if starting_node.first_child /= null then
        search_for_scope(starting_node.first_child, v_scope, v_current_ptr, v_found);
        if v_found then
          result_node := v_current_ptr;
          found       := true;
          return;
        end if;
      end if;

      -- Go sideways in the tree
      if starting_node.next_sibling /= null then
        search_for_scope(starting_node.next_sibling, v_scope, v_current_ptr, v_found);
        if v_found then
          result_node := v_current_ptr;
          found       := true;
          return;
        end if;
      end if;

      -- No candidate found
    end procedure;

    procedure search_for_scope(
      variable starting_node : in t_element_ptr;
      hierarchy_node         : t_hierarchy_node;
      variable result_node   : out t_element_ptr;
      variable found         : out boolean
    ) is
      variable v_current_ptr : t_element_ptr := null;
      variable v_found       : boolean       := false;
    begin
      found := false;
      -- is this the correct node?
      if starting_node.element_data = hierarchy_node then
        result_node := starting_node;
        found       := true;
        return;
      end if;

      -- Go downwards in the tree.
      if starting_node.first_child /= null then
        search_for_scope(starting_node.first_child, hierarchy_node, v_current_ptr, v_found);
        if v_found then
          result_node := v_current_ptr;
          found       := true;
          return;
        end if;
      end if;

      -- Go sideways in the tree
      if starting_node.next_sibling /= null then
        search_for_scope(starting_node.next_sibling, hierarchy_node, v_current_ptr, v_found);
        if v_found then
          result_node := v_current_ptr;
          found       := true;
          return;
        end if;
      end if;

      -- No candidate found
    end procedure;

    procedure update_uvvm_sim_status is
      type alert_array is array (1 to 6) of t_alert_level;
      constant alert_check_array       : alert_array := (WARNING, TB_WARNING, ERROR, TB_ERROR, FAILURE, TB_FAILURE);
      variable v_traverse_children_ptr : t_element_ptr;
      variable v_traverse_siblings_ptr : t_element_ptr;
      -- uvvm simulation status
      alias found_unexpected_simulation_warnings_or_worse is shared_uvvm_status.found_unexpected_simulation_warnings_or_worse;
      alias found_unexpected_simulation_errors_or_worse is shared_uvvm_status.found_unexpected_simulation_errors_or_worse;
      alias mismatch_on_expected_simulation_warnings_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_warnings_or_worse;
      alias mismatch_on_expected_simulation_errors_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_errors_or_worse;
    begin
      -- set default values for uvvm simulation status
      found_unexpected_simulation_warnings_or_worse     := 0;
      found_unexpected_simulation_errors_or_worse       := 0;
      mismatch_on_expected_simulation_warnings_or_worse := 0;
      mismatch_on_expected_simulation_errors_or_worse   := 0;
      v_traverse_children_ptr                           := priv_top_element_ptr;
      -- Update uvvm simulation status
      while v_traverse_children_ptr /= null loop -- loop through children
        v_traverse_siblings_ptr := v_traverse_children_ptr;
        while v_traverse_siblings_ptr /= null loop -- loop through siblings
          -- Compare expected and current allerts
          for i in 1 to alert_check_array'high loop
            if (v_traverse_siblings_ptr.element_data.alert_attention_counters(alert_check_array(i))(REGARD) /= v_traverse_siblings_ptr.element_data.alert_attention_counters(alert_check_array(i))(EXPECT)) then

              -- MISMATCH
              -- warning or worse
              mismatch_on_expected_simulation_warnings_or_worse := 1;
              -- error or worse
              if not (alert_check_array(i) = WARNING) and not (alert_check_array(i) = TB_WARNING) then
                mismatch_on_expected_simulation_errors_or_worse := 1;
              end if;

              -- FOUND UNEXPECTED ALERT
              if (v_traverse_siblings_ptr.element_data.alert_attention_counters(alert_check_array(i))(REGARD) > v_traverse_siblings_ptr.element_data.alert_attention_counters(alert_check_array(i))(EXPECT)) then
                -- warning and worse
                found_unexpected_simulation_warnings_or_worse := 1;
                -- error and worse
                if not (alert_check_array(i) = WARNING) and not (alert_check_array(i) = TB_WARNING) then
                  found_unexpected_simulation_errors_or_worse := 1;
                end if;
              end if;

            end if;
          end loop;
          if (mismatch_on_expected_simulation_warnings_or_worse = 1) and (mismatch_on_expected_simulation_errors_or_worse = 1) and (found_unexpected_simulation_warnings_or_worse = 1) and (found_unexpected_simulation_errors_or_worse = 1) then
            exit;
          end if;
          v_traverse_siblings_ptr := v_traverse_siblings_ptr.next_sibling;
        end loop;
        if (mismatch_on_expected_simulation_warnings_or_worse = 1) and (mismatch_on_expected_simulation_errors_or_worse = 1) and (found_unexpected_simulation_warnings_or_worse = 1) and (found_unexpected_simulation_errors_or_worse = 1) then
          exit;
        end if;
        v_traverse_children_ptr := v_traverse_children_ptr.first_child;
      end loop;
    end procedure update_uvvm_sim_status;

    --
    -- insert_in_tree
    --
    --  Insert a new element in the tree.
    --
    --

    procedure insert_in_tree(
      hierarchy_node : t_hierarchy_node;
      parent_scope   : string
    ) is
      variable v_parent_ptr     : t_element_ptr;
      variable v_child_ptr      : t_element_ptr;
      variable v_found          : boolean                                   := false;
      variable v_parent_scope   : string(1 to C_HIERARCHY_NODE_NAME_LENGTH) := justify(parent_scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
      variable v_hierarchy_node : t_hierarchy_node(name(1 to C_HIERARCHY_NODE_NAME_LENGTH));
    begin
      v_hierarchy_node      := hierarchy_node;
      v_hierarchy_node.name := justify(hierarchy_node.name, LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
      -- Set read and write pointers when appending element to existing list
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then

        -- Search for the parent.
        search_for_scope(priv_top_element_ptr, v_parent_scope, v_parent_ptr, v_found);
        if v_found then
          -- Parent found.
          if v_parent_ptr.first_child = null then
            -- Parent has no children. This node shall be the first child.
            v_parent_ptr.first_child := new t_element'(first_child => null, next_sibling => null, prev_sibling => null, parent => v_parent_ptr, element_data => v_hierarchy_node, hierarchy_level => v_parent_ptr.hierarchy_level + 1);
          else
            -- Parent has at least one child. This node shall be a sibling of the other child(ren).
            v_child_ptr := v_parent_ptr.first_child;

            -- Find last current sibling
            while v_child_ptr.next_sibling /= null loop
              v_child_ptr := v_child_ptr.next_sibling;
            end loop;

            -- Insert this node as a new sibling
            v_child_ptr.next_sibling := new t_element'(first_child => null, next_sibling => null, prev_sibling => v_child_ptr, parent => v_parent_ptr, element_data => v_hierarchy_node, hierarchy_level => v_parent_ptr.hierarchy_level + 1);

          end if;

          -- Update max hierarchy level
          if priv_max_hierarchy_level < v_parent_ptr.hierarchy_level + 1 then
            priv_max_hierarchy_level := v_parent_ptr.hierarchy_level + 1;
          end if;
        else
          -- parent not in tree
          -- Register to top level
          insert_in_tree(v_hierarchy_node, C_BASE_HIERARCHY_LEVEL);
        end if;

      else
        -- tree is empty, create top element in tree
        priv_top_element_ptr := new t_element'(first_child => null, next_sibling => null, prev_sibling => null, parent => null, element_data => v_hierarchy_node, hierarchy_level => 0);
      end if;

      -- Increment number of elements
      priv_num_elements_in_tree := priv_num_elements_in_tree + 1;
    end procedure;

    procedure clear_recursively(variable element_ptr : inout t_element_ptr) is
    begin
      assert element_ptr /= null report "Attempting to clear null pointer!" severity error;

      if element_ptr.first_child /= null then
        clear_recursively(element_ptr.first_child);
      end if;

      if element_ptr.next_sibling /= null then
        clear_recursively(element_ptr.next_sibling);
      end if;

      DEALLOCATE(element_ptr);
    end procedure;

    procedure clear is
      variable v_to_be_deallocated_ptr : t_element_ptr;
    begin

      -- Deallocate all nodes in the tree
      if priv_top_element_ptr /= null then
        clear_recursively(priv_top_element_ptr);
      end if;

      -- Reset the linked_list counter
      priv_num_elements_in_tree := 0;

      -- Reset the hierarchy variables
      priv_max_hierarchy_level  := 0;
      priv_has_been_initialized := false;

      update_uvvm_sim_status;

    end procedure;

    impure function is_empty
    return boolean is
    begin
      if priv_num_elements_in_tree = 0 then
        return true;
      else
        return false;
      end if;
    end function;

    impure function is_not_empty
    return boolean is
    begin
      return not is_empty;
    end function;

    impure function get_size
    return natural is
    begin
      return priv_num_elements_in_tree;
    end function;

    impure function contains_scope(
      scope : string
    ) return boolean is
      variable v_candidate_ptr : t_element_ptr := null;
      variable v_found         : boolean       := false;
    begin
      search_for_scope(priv_top_element_ptr, scope, v_candidate_ptr, v_found);
      return v_found;
    end function;

    procedure contains_scope_return_data(
      scope                   : string;
      variable result         : out boolean;
      variable hierarchy_node : out t_hierarchy_node
    ) is
      variable v_candidate_ptr : t_element_ptr := null;
      variable v_found         : boolean       := false;
    begin
      search_for_scope(priv_top_element_ptr, scope, v_candidate_ptr, v_found);
      result := v_found;
      if v_found then
        hierarchy_node := v_candidate_ptr.element_data;
      end if;
    end procedure;

    procedure tee(
      file     file_handle : text;
      variable my_line     : inout line
    ) is
      variable v_line : line;
    begin
      write(v_line, my_line.all);
      writeline(file_handle, v_line);
    end procedure tee;

    procedure alert(
      constant scope       : string;
      constant alert_level : t_alert_level;
      constant attention   : t_attention := REGARD;
      constant msg         : string      := ""
    ) is
      variable v_starting_node_ptr : t_element_ptr;
      variable v_current_ptr       : t_element_ptr;
      variable v_found             : boolean := false;
      variable v_is_in_tree        : boolean := false;
      variable v_msg               : line; -- msg after pot. replacement of \n
      variable v_info              : line;
      variable v_hierarchy         : line; -- stores the hierarchy propagation
      variable v_parent_node       : t_hierarchy_node(name(1 to C_HIERARCHY_NODE_NAME_LENGTH));
      variable v_do_print          : boolean := false; -- Enable/disable print of alert message
    begin
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then
        -- search for tree node that contains scope
        search_for_scope(priv_top_element_ptr, scope, v_starting_node_ptr, v_found);

        if not v_found then
          -- If the scope was not found, register automatically
          -- with the default base level scope as parent.
          -- Stop limit set to default.
          insert_in_tree((scope, (others => (others => 0)), (others => 0), (others => true)), justify(C_BASE_HIERARCHY_LEVEL, LEFT, C_HIERARCHY_NODE_NAME_LENGTH));
          -- Search again to get ptr
          search_for_scope(priv_top_element_ptr, scope, v_starting_node_ptr, v_found);
        end if;

        v_current_ptr := v_starting_node_ptr;

        assert v_found
        report "Node not found!"
        severity failure;

        write(v_msg, replace_backslash_n_with_lf(msg));

        -- Only print of alert level print is enabled for this alert level
        -- for the node where the alert is called.
        if attention /= IGNORE then
          if v_current_ptr.element_data.alert_level_print(alert_level) = true then
            v_do_print := true;
          end if;

          --    Write first part of alert message
          --    Serious alerts need more attention - thus more space and lines
          if (alert_level > MANUAL_CHECK) then
            write(v_info, LF & fill_string('=', C_LOG_INFO_WIDTH));
          end if;

          write(v_info, LF & "***  ");

        end if;

        -- 4. Propagate alert and build alert message
        while v_current_ptr /= null loop

          if attention = IGNORE then
            -- Increment alert counter for this node at alert attention IGNORE
            v_current_ptr.element_data.alert_attention_counters(alert_level)(IGNORE) := v_current_ptr.element_data.alert_attention_counters(alert_level)(IGNORE) + 1;
          else
            -- Increment alert counter for this node at alert attention REGARD
            v_current_ptr.element_data.alert_attention_counters(alert_level)(REGARD) := v_current_ptr.element_data.alert_attention_counters(alert_level)(REGARD) + 1;

            write(v_hierarchy, v_current_ptr.element_data.name(1 to pos_of_rightmost_non_whitespace(v_current_ptr.element_data.name)));

            if v_current_ptr.parent /= null then
              write(v_hierarchy, string'(" -> "));
            end if;

            -- Exit loop if stop-limit is reached for number of this alert
            if (v_current_ptr.element_data.alert_stop_limit(alert_level) /= 0) and (v_current_ptr.element_data.alert_attention_counters(alert_level)(REGARD) >= v_current_ptr.element_data.alert_stop_limit(alert_level)) then

              exit;
            end if;

          end if;

          v_current_ptr := v_current_ptr.parent;
        end loop;

        if v_current_ptr = null then    -- Nothing went wrong in the previous loop
          v_current_ptr := v_starting_node_ptr;
        end if;

        if attention /= IGNORE then
          -- 3. Write body of alert message
          --    Remove line feed character (LF)
          --    if single line alert enabled.
          if not C_SINGLE_LINE_ALERT then
            write(v_info, to_upper(to_string(alert_level)) & " #" & to_string(v_current_ptr.element_data.alert_attention_counters(alert_level)(REGARD)) & "  ***" & LF & justify(to_string(now, C_LOG_TIME_BASE), RIGHT, C_LOG_TIME_WIDTH) & "   " & v_hierarchy.all & LF & wrap_lines(v_msg.all, C_LOG_TIME_WIDTH + 4, C_LOG_TIME_WIDTH + 4, C_LOG_INFO_WIDTH));
          else
            replace(v_msg, LF, ' ');
            write(v_info, to_upper(to_string(alert_level)) & " #" & to_string(v_current_ptr.element_data.alert_attention_counters(alert_level)(REGARD)) & "  ***" & justify(to_string(now, C_LOG_TIME_BASE), RIGHT, C_LOG_TIME_WIDTH) & "   " & v_hierarchy.all & "        " & v_msg.all);
          end if;
        end if;

        deallocate(v_msg);
        deallocate(v_hierarchy);

        -- Write stop message if stop-limit is reached for number of this alert
        if (v_current_ptr.element_data.alert_stop_limit(alert_level) /= 0) and (v_current_ptr.element_data.alert_attention_counters(alert_level)(REGARD) >= v_current_ptr.element_data.alert_stop_limit(alert_level)) then

          v_do_print := true;           -- If the alert limit has been reached, print alert message anyway.

          write(v_info, LF & LF & "Simulator has been paused as requested after " & to_string(v_current_ptr.element_data.alert_attention_counters(alert_level)(REGARD)) & " " & to_upper(to_string(alert_level)) & LF);
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

        if v_do_print then              -- Only print if alert level print enabled for this alert level.
          tee(OUTPUT, v_info);
          tee(ALERT_FILE, v_info);
          writeline(LOG_FILE, v_info);
        end if;

        deallocate(v_info);

        if (alert_level /= NO_ALERT) and (alert_level /= NOTE) and (alert_level /= TB_NOTE) and (alert_level /= MANUAL_CHECK) then
          update_uvvm_sim_status;
        end if;

        -- Stop simulation if stop-limit is reached for number of this alert
        if v_current_ptr /= null then
          if (v_current_ptr.element_data.alert_stop_limit(alert_level) /= 0) then
            if (v_current_ptr.element_data.alert_attention_counters(alert_level)(REGARD) >= v_current_ptr.element_data.alert_stop_limit(alert_level)) then
              assert false
              report "This single Failure line has been provoked to stop the simulation. See alert-message above"
              severity failure;
            end if;
          end if;
        end if;

      end if;

    end procedure;

    procedure increment_expected_alerts(
      scope       : string;
      alert_level : t_alert_level;
      amount      : natural := 1
    ) is
      variable v_current_ptr         : t_element_ptr;
      variable v_new_expected_alerts : natural;
      variable v_found               : boolean := false;
    begin
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then
        -- search for tree node that contains scope
        search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);
        assert v_found report "Scope not found!" severity warning;

        if v_found then
          -- Increment expected alerts for this node.
          v_new_expected_alerts                                                    := v_current_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) + amount;
          v_current_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) := v_new_expected_alerts;

          -- Change pointer to parent element
          v_current_ptr := v_current_ptr.parent;

          -- Propagate expected alerts
          while v_current_ptr /= null loop
            if v_current_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) < v_new_expected_alerts then
              v_current_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) := v_new_expected_alerts;
            end if;
            v_current_ptr := v_current_ptr.parent;
          end loop;
        end if;

        if (alert_level /= NO_ALERT) and (alert_level /= NOTE) and (alert_level /= TB_NOTE) and (alert_level /= MANUAL_CHECK) then
          update_uvvm_sim_status;
        end if;

      end if;

    end procedure;

    procedure set_expected_alerts(
      scope           : string;
      alert_level     : t_alert_level;
      expected_alerts : natural
    ) is
      variable v_current_ptr : t_element_ptr;
      variable v_found       : boolean                                   := false;
      variable v_scope       : string(1 to C_HIERARCHY_NODE_NAME_LENGTH) := justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
    begin
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then
        -- search for tree node that contains scope
        search_for_scope(priv_top_element_ptr, v_scope, v_current_ptr, v_found);

        assert v_found report "Scope not found!" severity warning;

        if v_found then
          -- Set stop limit for this node
          v_current_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) := expected_alerts;

          -- Change pointer to parent element
          v_current_ptr := v_current_ptr.parent;

          -- Propagate stop limit
          while v_current_ptr /= null loop
            if v_current_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) < expected_alerts then
              v_current_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) := expected_alerts;
            end if;
            v_current_ptr := v_current_ptr.parent;
          end loop;
        end if;

        if (alert_level /= NO_ALERT) and (alert_level /= NOTE) and (alert_level /= TB_NOTE) and (alert_level /= MANUAL_CHECK) then
          update_uvvm_sim_status;
        end if;

      end if;

    end procedure;

    impure function get_expected_alerts(
      scope       : string;
      alert_level : t_alert_level
    ) return natural is
      variable v_current_ptr : t_element_ptr;
      variable v_found       : boolean                                   := false;
      variable v_scope       : string(1 to C_HIERARCHY_NODE_NAME_LENGTH) := justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
    begin
      search_for_scope(priv_top_element_ptr, v_scope, v_current_ptr, v_found);

      if v_found then
        return v_current_ptr.element_data.alert_attention_counters(alert_level)(EXPECT);
      else
        return 0;
      end if;
    end function;

    procedure increment_stop_limit(
      scope       : string;
      alert_level : t_alert_level;
      amount      : natural := 1
    ) is
      variable v_current_ptr    : t_element_ptr;
      variable v_new_stop_limit : natural;
      variable v_found          : boolean := false;
    begin
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then
        -- search for tree node that contains scope
        search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);

        assert v_found report "Scope not found!" severity warning;

        if v_found then
          -- Increment stop limit for this node.
          v_new_stop_limit                                         := v_current_ptr.element_data.alert_stop_limit(alert_level) + amount;
          v_current_ptr.element_data.alert_stop_limit(alert_level) := v_new_stop_limit;

          -- Change pointer to parent element
          v_current_ptr := v_current_ptr.parent;

          -- Propagate stop limit
          while v_current_ptr /= null loop
            if v_current_ptr.element_data.alert_stop_limit(alert_level) < v_new_stop_limit then
              v_current_ptr.element_data.alert_stop_limit(alert_level) := v_new_stop_limit;
            end if;
            v_current_ptr := v_current_ptr.parent;
          end loop;
        end if;
      end if;

    end procedure;

    procedure set_stop_limit(
      scope       : string;
      alert_level : t_alert_level;
      stop_limit  : natural
    ) is
      variable v_current_ptr : t_element_ptr;
      variable v_found       : boolean := false;
    begin
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then
        -- search for tree node that contains scope
        search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);

        assert v_found report "Scope not found!" severity warning;

        if v_found then
          -- Set stop limit for this node
          v_current_ptr.element_data.alert_stop_limit(alert_level) := stop_limit;
          v_current_ptr                                            := v_current_ptr.parent;

          -- Propagate stop limit
          while v_current_ptr /= null loop
            if v_current_ptr.element_data.alert_stop_limit(alert_level) < stop_limit then
              v_current_ptr.element_data.alert_stop_limit(alert_level) := stop_limit;
            end if;
            v_current_ptr := v_current_ptr.parent;
          end loop;
        end if;
      end if;

    end procedure;

    impure function get_stop_limit(
      scope       : string;
      alert_level : t_alert_level
    ) return natural is
      variable v_current_ptr : t_element_ptr;
      variable v_found       : boolean := false;
    begin
      search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);

      if v_found then
        return v_current_ptr.element_data.alert_stop_limit(alert_level);
      else
        return 0;
      end if;
    end function;

    procedure generate_hierarchy_prefix(
      variable starting_node_ptr : in t_element_ptr;
      variable calling_node_ptr  : in t_element_ptr;
      variable origin_node_ptr   : in t_element_ptr;
      variable v_line            : inout line
    ) is
      variable v_indent_correction_amount : natural := 0;
    begin

      if starting_node_ptr.parent = null then
        -- This is the top level
        -- Write a '|' as first character if the calling node (child)
        -- has another sibling, else nothing.
        if origin_node_ptr.parent /= starting_node_ptr and calling_node_ptr.next_sibling /= null then
          write(v_line, string'("|"));
        end if;
      else
        -- This starting_node is not the top node

        -- Create prefix for parent first.
        generate_hierarchy_prefix(starting_node_ptr.parent, starting_node_ptr, origin_node_ptr, v_line);

        -- All that have received a '|' as the first character in the buffer
        -- has one space too many afterwards. Special case for the first character.
        if starting_node_ptr.parent.parent = null then
          if starting_node_ptr.next_sibling /= null then
            v_indent_correction_amount := 1;
          end if;
        end if;

        if starting_node_ptr.next_sibling /= null then
          -- Has another sibling
          if calling_node_ptr.next_sibling /= null then
            write(v_line, fill_string(' ', 2 - v_indent_correction_amount));
            write(v_line, string'("|"));
          else
            write(v_line, fill_string(' ', 3 - v_indent_correction_amount));
          end if;
        else
          -- No next sibling
          write(v_line, fill_string(' ', 3 - v_indent_correction_amount));
        end if;

      end if;

    end procedure;

    procedure print_node(
      variable starting_node_ptr : in t_element_ptr;
      variable v_status_ok       : inout boolean;
      variable v_minor_status_ok : inout boolean;
      variable v_mismatch        : inout boolean;
      variable v_minor_mismatch  : inout boolean;
      variable v_line            : inout line
    ) is
      variable v_current_ptr : t_element_ptr;
    begin

      -- Write indentation according to hierarchy level
      if starting_node_ptr.hierarchy_level > 0 then

        generate_hierarchy_prefix(starting_node_ptr.parent, starting_node_ptr, starting_node_ptr, v_line);

        if starting_node_ptr.next_sibling /= null then
          write(v_line, string'("|- "));
        else
          write(v_line, string'("`- "));
        end if;

      end if;

      -- Print name of node
      write(v_line, starting_node_ptr.element_data.name);

      -- Adjust the columns according to max hierarchy level
      if priv_max_hierarchy_level > 0 then
        if starting_node_ptr.hierarchy_level /= priv_max_hierarchy_level then
          write(v_line, fill_string(' ', (priv_max_hierarchy_level - starting_node_ptr.hierarchy_level) * 3));
        end if;
      end if;

      -- Print colon to signify the end of the name
      write(v_line, string'(":"));

      -- Print counters for each of the alert levels.
      for alert_level in NOTE to t_alert_level'right loop
        write(v_line, justify(integer'image(starting_node_ptr.element_data.alert_attention_counters(alert_level)(REGARD)) & "/" & integer'image(starting_node_ptr.element_data.alert_attention_counters(alert_level)(EXPECT)) & "/" & integer'image(starting_node_ptr.element_data.alert_attention_counters(alert_level)(IGNORE)), RIGHT, 11) & " ");
        if v_status_ok = true then
          if starting_node_ptr.element_data.alert_attention_counters(alert_level)(REGARD) /= starting_node_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) then
            if alert_level > MANUAL_CHECK then
              if starting_node_ptr.element_data.alert_attention_counters(alert_level)(REGARD) < starting_node_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) then
                v_mismatch := true;
              else
                v_status_ok := false;
              end if;
            else
              if starting_node_ptr.element_data.alert_attention_counters(alert_level)(REGARD) < starting_node_ptr.element_data.alert_attention_counters(alert_level)(EXPECT) then
                v_minor_mismatch := true;
              else
                v_minor_status_ok := false;
              end if;
            end if;
          end if;
        end if;
      end loop;

      write(v_line, LF);

      if starting_node_ptr.first_child /= null then
        print_node(starting_node_ptr.first_child, v_status_ok, v_minor_status_ok, v_mismatch, v_minor_mismatch, v_line);
      end if;

      if starting_node_ptr.next_sibling /= null then
        print_node(starting_node_ptr.next_sibling, v_status_ok, v_minor_status_ok, v_mismatch, v_minor_mismatch, v_line);
      end if;

    end procedure;

    procedure print_hierarchical_log(
      order : t_order := FINAL
    ) is
      variable v_header          : string(1 to 80);
      variable v_line            : line;
      variable v_line_copy       : line;
      constant prefix            : string  := C_LOG_PREFIX & "     ";
      variable v_status_ok       : boolean := true;
      variable v_minor_status_ok : boolean := true;
      variable v_mismatch        : boolean := false;
      variable v_minor_mismatch  : boolean := false;

    begin
      if order = INTERMEDIATE then
        v_header := "*** INTERMEDIATE SUMMARY OF ALL ALERTS ***     Format: REGARDED/EXPECTED/IGNORED";
      else                              -- order=FINAL
        v_header := "*** FINAL SUMMARY OF ALL ALERTS  ***     Format: REGARDED/EXPECTED/IGNORED      ";
      end if;

      -- Write header
      write(v_line,
            LF & fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF & v_header & LF & fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF & "     " & justify(" ", RIGHT, 3 + C_HIERARCHY_NODE_NAME_LENGTH + priv_max_hierarchy_level * 3) & "NOTE" & justify(" ", RIGHT, 6) & "TB_NOTE" & justify(" ", RIGHT, 5) & "WARNING" & justify(" ", RIGHT, 3) & "TB_WARNING" & justify(" ", RIGHT, 2) & "MANUAL_CHECK" & justify(" ", RIGHT, 3) & "ERROR" & justify(" ", RIGHT, 5) & "TB_ERROR" & justify(" ", RIGHT, 5) & "FAILURE" & justify(" ", RIGHT, 3) & "TB_FAILURE" & LF);

      -- Print all nodes
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then
        print_node(priv_top_element_ptr, v_status_ok, v_minor_status_ok, v_mismatch, v_minor_mismatch, v_line);
      end if;

      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF);

      -- Print a conclusion when called from the FINAL part of the test sequencer
      -- but not when called from in the middle of the test sequence (order=INTERMEDIATE)
      if order = FINAL then
        if not v_status_ok then
          write(v_line, ">> Simulation FAILED, with unexpected serious alert(s)" & LF);
        elsif v_mismatch then
          write(v_line, ">> Simulation FAILED: Mismatch between counted and expected serious alerts" & LF);
        elsif (v_minor_status_ok = false) or (v_minor_mismatch = true) then
          write(v_line, ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts, but mismatch in minor alerts" & LF);
        else
          write(v_line, ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts" & LF);
        end if;
        write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF & LF);
      end if;

      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - prefix'length);
      prefix_lines(v_line, prefix);

      -- Write the info string to the target file
      write(v_line_copy, v_line.all & lf); -- copy line
      writeline(OUTPUT, v_line);
      writeline(LOG_FILE, v_line_copy);
      deallocate(v_line);
      deallocate(v_line_copy);
    end procedure;

    impure function get_parent_scope(
      scope : string(1 to C_HIERARCHY_NODE_NAME_LENGTH))
    return string is
      variable v_current_ptr : t_element_ptr := null;
      variable v_found       : boolean       := false;
    begin
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then
        search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);
        assert v_found report "Scope not found. Exiting get_parent_scope()..." severity warning;
        if not v_found then
          return justify("", LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
        end if;

        if v_current_ptr.parent /= null then
          return v_current_ptr.parent.element_data.name;
        end if;

      end if;
      return "";
    end function;

    procedure propagate_hierarchy_level(
      variable node_ptr : inout t_element_ptr
    ) is
    begin
      if node_ptr /= null then
        if node_ptr.parent /= null then
          node_ptr.hierarchy_level := node_ptr.parent.hierarchy_level + 1;
        else                            -- No parent
          node_ptr.hierarchy_level := 0;
        end if;

        if priv_max_hierarchy_level < node_ptr.hierarchy_level then
          priv_max_hierarchy_level := node_ptr.hierarchy_level;
        end if;

        if node_ptr.next_sibling /= null then
          propagate_hierarchy_level(node_ptr.next_sibling);
        end if;

        if node_ptr.first_child /= null then
          propagate_hierarchy_level(node_ptr.first_child);
        end if;
      end if;
    end procedure;

    procedure change_parent(
      scope        : string;
      parent_scope : string
    ) is
      variable v_old_parent_ptr : t_element_ptr := null;
      variable v_new_parent_ptr : t_element_ptr := null;
      variable v_child_ptr      : t_element_ptr := null;
      variable v_current_ptr    : t_element_ptr := null;
      variable v_found          : boolean       := false;
    begin
      if priv_num_elements_in_tree > 0 and priv_has_been_initialized then

        search_for_scope(priv_top_element_ptr, scope, v_child_ptr, v_found);
        assert v_found report "Child not found. Exiting change_parent()..." severity warning;
        if not v_found then
          return;
        end if;

        search_for_scope(priv_top_element_ptr, parent_scope, v_new_parent_ptr, v_found);
        assert v_found report "Parent not found. Exiting change_parent()..." severity warning;
        if not v_found then
          return;
        end if;

        if v_child_ptr.first_child /= null then
          search_for_scope(v_child_ptr.first_child, parent_scope, v_current_ptr, v_found);
          assert not v_found report "New parent is the descendant of the node that shall be moved! Illegal operation!" severity failure;
        end if;

        -- Clean up
        -- Need to check the current parent of the child for any other children,
        -- then clean up the next_sibling, prev_sibling and first_child pointers.

        v_old_parent_ptr := v_child_ptr.parent;
        if v_old_parent_ptr /= null then
          if v_old_parent_ptr.first_child = v_child_ptr then
            -- First_child is this child. Check if any siblings.

            -- Prev_sibling is null since this is first child.
            -- Next sibling can be something else.

            -- Correct first_child for old parent
            if v_child_ptr.next_sibling /= null then
              -- Set next_sibling to be first child
              v_old_parent_ptr.first_child          := v_child_ptr.next_sibling;
              -- Clear prev_sibling for the sibling that will now be first_child of old_parent
              v_child_ptr.next_sibling.prev_sibling := null;
            else
              -- No siblings, clear first_child
              v_old_parent_ptr.first_child := null;
            end if;
          else
            -- This child must be one of the siblings.
            -- Remove this child and glue together the other siblings

            -- Create pointer from previous sibling to next sibling
            v_child_ptr.prev_sibling.next_sibling := v_child_ptr.next_sibling;

            -- Create pointer from next sibling to previous sibling
            if v_child_ptr.next_sibling /= null then
              v_child_ptr.next_sibling.prev_sibling := v_child_ptr.prev_sibling;
            end if;
          end if;

          -- Clear siblings to prepare for another parent
          v_child_ptr.prev_sibling := null;
          v_child_ptr.next_sibling := null;
        end if;

        -- Set new parent and prev_sibling for the child.
        if v_new_parent_ptr.first_child = null then
          -- No children previously created for this parent
          v_new_parent_ptr.first_child := v_child_ptr;

        else
          -- There is at least 1 child belonging to the new parent
          v_current_ptr              := v_new_parent_ptr.first_child;
          while v_current_ptr.next_sibling /= null loop
            v_current_ptr := v_current_ptr.next_sibling;
          end loop;
          -- v_current_ptr is now the final sibling belonging to
          -- the new parent
          v_current_ptr.next_sibling := v_child_ptr;
          v_child_ptr.prev_sibling   := v_current_ptr;
        end if;

        -- Set parent correctly
        v_child_ptr.parent    := v_new_parent_ptr;
        -- Update hierarchy levels for the whole tree
        priv_max_hierarchy_level := 0;
        propagate_hierarchy_level(priv_top_element_ptr);
      end if;
    end procedure;

    procedure set_top_level_stop_limit(
      alert_level : t_alert_level;
      value       : natural
    ) is
    begin
      --
      --

      priv_top_element_ptr.element_data.alert_stop_limit(alert_level) := value;

      -- Evaluate new stop limit in case it is less than or equal to the current alert counter for this alert level
      -- If that is the case, a new alert with the same alert level shall be triggered.
      if priv_top_element_ptr.element_data.alert_stop_limit(alert_level) /= 0 and (priv_top_element_ptr.element_data.alert_attention_counters(alert_level)(REGARD) >= priv_top_element_ptr.element_data.alert_stop_limit(alert_level)) then
        assert false
        report "Alert stop limit for scope " & priv_top_element_ptr.element_data.name & " at alert level " & to_upper(to_string(alert_level)) & " set to " & to_string(value) & ", which is lower than the current " & to_upper(to_string(alert_level)) & " count (" & to_string(priv_top_element_ptr.element_data.alert_attention_counters(alert_level)(REGARD)) & ")."
        severity failure;

      end if;

    end procedure;

    impure function get_top_level_stop_limit(
      alert_level : t_alert_level
    ) return natural is
    begin
      return priv_top_element_ptr.element_data.alert_stop_limit(alert_level);
    end function;

    procedure propagate_alert_level(
      variable node_ptr    : inout t_element_ptr;
      constant alert_level : t_alert_level;
      constant setting     : boolean
    ) is
    begin
      if node_ptr /= null then
        node_ptr.element_data.alert_level_print(alert_level) := setting;

        if node_ptr.next_sibling /= null then
          propagate_alert_level(node_ptr.next_sibling, alert_level, setting);
        end if;

        if node_ptr.first_child /= null then
          propagate_alert_level(node_ptr.first_child, alert_level, setting);
        end if;
      end if;
    end procedure;

    procedure enable_alert_level(
      scope       : string;
      alert_level : t_alert_level
    ) is
      variable v_current_ptr : t_element_ptr := null;
      variable v_found       : boolean       := false;
    begin
      search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);
      if v_found then
        propagate_alert_level(v_current_ptr, alert_level, true);
      end if;
    end procedure;

    procedure disable_alert_level(
      scope       : string;
      alert_level : t_alert_level
    ) is
      variable v_current_ptr : t_element_ptr := null;
      variable v_found       : boolean       := false;
    begin
      search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);
      if v_found then
        propagate_alert_level(v_current_ptr, alert_level, false);
      end if;
    end procedure;

    procedure enable_all_alert_levels(
      scope : string
    ) is
      variable v_current_ptr : t_element_ptr := null;
      variable v_found       : boolean       := false;
    begin
      search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);
      if v_found then
        for alert_level in NOTE to t_alert_level'right loop
          propagate_alert_level(v_current_ptr, alert_level, true);
        end loop;
      end if;
    end procedure;

    procedure disable_all_alert_levels(
      scope : string
    ) is
      variable v_current_ptr : t_element_ptr := null;
      variable v_found       : boolean       := false;
    begin
      search_for_scope(priv_top_element_ptr, scope, v_current_ptr, v_found);
      if v_found then
        for alert_level in NOTE to t_alert_level'right loop
          propagate_alert_level(v_current_ptr, alert_level, false);
        end loop;
      end if;
    end procedure;

  end protected body;

end package body hierarchy_linked_list_pkg;
