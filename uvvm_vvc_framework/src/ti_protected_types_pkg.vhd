--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;


package ti_protected_types_pkg is


  type t_inactivity_watchdog is protected

    impure function priv_are_all_vvc_inactive return boolean;

    impure function priv_register_vvc(
      constant name                   : in string;
      constant instance               : in natural;
      constant channel                : in t_channel
    ) return integer;

    procedure priv_report_vvc_activity(
      constant vvc_idx                : natural;
      constant busy                   : boolean;
      constant last_executed_cmd_idx  : integer
    );

  end protected;



end package ti_protected_types_pkg;

--=============================================================================
--=============================================================================

package body ti_protected_types_pkg is


  type t_inactivity_watchdog is protected body

    type t_vvc_id is record
      name      : string(1 to C_MAX_VVC_NAME_LENGTH);
      instance  : natural;
      channel   : t_channel;
    end record;
    constant C_VVC_ID_DEFAULT : t_vvc_id := (
      name      => (others => ' '),
      instance  => 0,
      channel   => NA
    );

    type t_vvc_status is record
      busy                  : boolean;
      last_executed_cmd_idx : integer; -- last_executed_cmd
    end record;
    constant  C_VVC_STATUS_DEFAULT : t_vvc_status := (
      busy                  => false,
      last_executed_cmd_idx => -1
    );

    type t_vvc_item is record
      vvc_id      : t_vvc_id;
      vvc_status  : t_vvc_status;
    end record;
    constant C_VVC_ITEM_DEFAULT : t_vvc_item := (
      vvc_id      => C_VVC_ID_DEFAULT,
      vvc_status  => C_VVC_STATUS_DEFAULT
    );

    -- Array holding all registered VVCs
    type t_registered_vvc_array   is array (natural range <>) of t_vvc_item;

    variable priv_registered_vvc  : t_registered_vvc_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_VVC_ITEM_DEFAULT);

    -- Counter for the number of VVCs that has registered
    variable priv_last_registered_vvc_idx : integer := -1;


    impure function priv_are_all_vvc_inactive return boolean is
    begin
      for idx in 0 to priv_last_registered_vvc_idx loop
        if priv_registered_vvc(idx).vvc_status.busy = true then
          return false;
        end if;
      end loop;
      return true;
    end function priv_are_all_vvc_inactive;

    impure function priv_register_vvc(
      constant name                   : in string;
      constant instance               : in natural;
      constant channel                : in t_channel
    ) return integer is
    begin
      -- Set registered VVC index
      priv_last_registered_vvc_idx := priv_last_registered_vvc_idx + 1;
      -- Update register
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.name                      := name;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.instance                  := instance;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.channel                   := channel;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_status.busy                  := false;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_status.last_executed_cmd_idx := -1;
      -- Return index
      return priv_last_registered_vvc_idx;
    end function priv_register_vvc;


    procedure priv_report_vvc_activity(
      constant vvc_idx                : natural;
      constant busy                   : boolean;
      constant last_executed_cmd_idx  : integer
    ) is
    begin
      -- Update VVC status
      priv_registered_vvc(vvc_idx).vvc_status.busy                  := busy;
      priv_registered_vvc(vvc_idx).vvc_status.last_executed_cmd_idx := last_executed_cmd_idx;
    end procedure priv_report_vvc_activity;

  end protected body t_inactivity_watchdog;




end package body ti_protected_types_pkg;