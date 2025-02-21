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
-- Description   : Package for accessing each AXI channel separately. Used by the VVC
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.axi_bfm_pkg.all;
use work.axi_read_data_queue_pkg.all;
use work.vvc_cmd_pkg.all;

--=================================================================================================
package axi_channel_handler_pkg is

  --===============================================================================================
  -- Types and constants
  --===============================================================================================
  constant C_SCOPE : string := "AXI_CHANNEL_HANDLER";

  --===============================================================================================
  -- Procedures
  --===============================================================================================

  ------------------------------------------
  -- write_address_channel_write
  ------------------------------------------
  -- This procedure writes adress on the write address channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure write_address_channel_write(
    constant awid_value     : in std_logic_vector;
    constant awaddr_value   : in unsigned;
    constant awlen_value    : in unsigned(7 downto 0);
    constant awsize_value   : in integer range 1 to 128;
    constant awburst_value  : in t_axburst;
    constant awlock_value   : in t_axlock;
    constant awcache_value  : in std_logic_vector(3 downto 0);
    constant awprot_value   : in t_axprot;
    constant awqos_value    : in std_logic_vector(3 downto 0);
    constant awregion_value : in std_logic_vector(3 downto 0);
    constant awuser_value   : in std_logic_vector;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   awid           : inout std_logic_vector;
    signal   awaddr         : inout std_logic_vector;
    signal   awlen          : inout std_logic_vector(7 downto 0);
    signal   awsize         : inout std_logic_vector(2 downto 0);
    signal   awburst        : inout std_logic_vector(1 downto 0);
    signal   awlock         : inout std_logic;
    signal   awcache        : inout std_logic_vector(3 downto 0);
    signal   awprot         : inout std_logic_vector(2 downto 0);
    signal   awqos          : inout std_logic_vector(3 downto 0);
    signal   awregion       : inout std_logic_vector(3 downto 0);
    signal   awuser         : inout std_logic_vector;
    signal   awvalid        : inout std_logic;
    signal   awready        : in std_logic;
    constant scope          : in string           := C_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- write_data_channel_write
  ------------------------------------------
  -- This procedure writes data on the write data channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure write_data_channel_write(
    constant wdata_value  : in t_slv_array;
    constant wstrb_value  : in t_slv_array;
    constant wuser_value  : in t_slv_array;
    constant awlen_value  : in unsigned(7 downto 0);
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   wdata        : inout std_logic_vector;
    signal   wstrb        : inout std_logic_vector;
    signal   wlast        : inout std_logic;
    signal   wuser        : inout std_logic_vector;
    signal   wvalid       : inout std_logic;
    signal   wready       : in std_logic;
    constant scope        : in string           := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- write_response_channel_receive
  ------------------------------------------
  -- This procedure receives the write response on the write response channel
  -- and returns the response data
  -- - When completed, a log message with ID id_for_bfm is issued.
  procedure write_response_channel_receive(
    variable bid_value     : out std_logic_vector;
    variable bresp_value   : out t_xresp;
    variable buser_value   : out std_logic_vector;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   bid           : in std_logic_vector;
    signal   bresp         : in std_logic_vector(1 downto 0);
    signal   buser         : in std_logic_vector;
    signal   bvalid        : in std_logic;
    signal   bready        : inout std_logic;
    constant alert_level   : in t_alert_level    := error;
    constant scope         : in string           := C_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- read_address_channel_write
  ------------------------------------------
  -- This procedure writes adress on the read address channel
  -- - When the write is completed, a log message is issued with ID_CHANNEL_BFM
  procedure read_address_channel_write(
    constant arid_value     : in std_logic_vector;
    constant araddr_value   : in unsigned;
    constant arlen_value    : in unsigned(7 downto 0);
    constant arsize_value   : in integer range 1 to 128;
    constant arburst_value  : in t_axburst;
    constant arlock_value   : in t_axlock;
    constant arcache_value  : in std_logic_vector(3 downto 0);
    constant arprot_value   : in t_axprot;
    constant arqos_value    : in std_logic_vector(3 downto 0);
    constant arregion_value : in std_logic_vector(3 downto 0);
    constant aruser_value   : in std_logic_vector;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   arid           : inout std_logic_vector;
    signal   araddr         : inout std_logic_vector;
    signal   arlen          : inout std_logic_vector(7 downto 0);
    signal   arsize         : inout std_logic_vector(2 downto 0);
    signal   arburst        : inout std_logic_vector(1 downto 0);
    signal   arlock         : inout std_logic;
    signal   arcache        : inout std_logic_vector(3 downto 0);
    signal   arprot         : inout std_logic_vector(2 downto 0);
    signal   arqos          : inout std_logic_vector(3 downto 0);
    signal   arregion       : inout std_logic_vector(3 downto 0);
    signal   aruser         : inout std_logic_vector;
    signal   arvalid        : inout std_logic;
    signal   arready        : in std_logic;
    constant scope          : in string           := C_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- read_data_channel_receive
  ------------------------------------------
  -- This procedure receives read data on the read data channel,
  -- and returns the read data
  -- - When completed, a log message with ID id_for_bfm is issued.
  procedure read_data_channel_receive(
    variable read_result     : out t_vvc_result;
    variable read_data_queue : inout t_axi_read_data_queue;
    constant msg             : in string;
    signal   clk             : in std_logic;
    signal   rid             : in std_logic_vector;
    signal   rdata           : in std_logic_vector;
    signal   rresp           : in std_logic_vector(1 downto 0);
    signal   rlast           : in std_logic;
    signal   ruser           : in std_logic_vector;
    signal   rvalid          : in std_logic;
    signal   rready          : inout std_logic;
    constant scope           : in string           := C_SCOPE;
    constant msg_id_panel    : in t_msg_id_panel   := shared_msg_id_panel;
    constant config          : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call   : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

end package axi_channel_handler_pkg;

package body axi_channel_handler_pkg is

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  procedure write_address_channel_write(
    constant awid_value     : in std_logic_vector;
    constant awaddr_value   : in unsigned;
    constant awlen_value    : in unsigned(7 downto 0);
    constant awsize_value   : in integer range 1 to 128;
    constant awburst_value  : in t_axburst;
    constant awlock_value   : in t_axlock;
    constant awcache_value  : in std_logic_vector(3 downto 0);
    constant awprot_value   : in t_axprot;
    constant awqos_value    : in std_logic_vector(3 downto 0);
    constant awregion_value : in std_logic_vector(3 downto 0);
    constant awuser_value   : in std_logic_vector;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   awid           : inout std_logic_vector;
    signal   awaddr         : inout std_logic_vector;
    signal   awlen          : inout std_logic_vector(7 downto 0);
    signal   awsize         : inout std_logic_vector(2 downto 0);
    signal   awburst        : inout std_logic_vector(1 downto 0);
    signal   awlock         : inout std_logic;
    signal   awcache        : inout std_logic_vector(3 downto 0);
    signal   awprot         : inout std_logic_vector(2 downto 0);
    signal   awqos          : inout std_logic_vector(3 downto 0);
    signal   awregion       : inout std_logic_vector(3 downto 0);
    signal   awuser         : inout std_logic_vector;
    signal   awvalid        : inout std_logic;
    signal   awready        : in std_logic;
    constant scope          : in string           := C_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call              : string                                       := "write_address_channel_write(" & to_string(awaddr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_awready        : boolean                                      := true;
    -- Normalizing unconstrained inputs
    variable v_normalized_awid      : std_logic_vector(awid'length - 1 downto 0);
    variable v_normalized_awaddr    : std_logic_vector(awaddr'length - 1 downto 0) := normalize_and_check(std_logic_vector(awaddr_value), awaddr, ALLOW_WIDER, "awaddr_value", "awaddr", msg);
    variable v_normalized_awuser    : std_logic_vector(awuser'length - 1 downto 0);
    -- Helper variables
    variable v_time_of_rising_edge  : time                                         := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                         := -1 ns; -- time stamp for clk period checking
  begin
    if awid'length > 0 then
      v_normalized_awid := normalize_and_check(awid_value, awid, ALLOW_WIDER, "awid_value", "awid", msg);
    end if;
    if awuser'length > 0 then
      v_normalized_awuser := normalize_and_check(awuser_value, awuser, ALLOW_WIDER, "awuser_value", "awuser", msg);
    end if;
    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write data channel outputs
      if cycle = config.num_aw_pipe_stages then
        awid     <= v_normalized_awid;
        awaddr   <= v_normalized_awaddr;
        awlen    <= std_logic_vector(awlen_value);
        awsize   <= bytes_to_axsize(awsize_value);
        awburst  <= axburst_to_slv(awburst_value);
        awlock   <= axlock_to_sl(awlock_value);
        awcache  <= awcache_value;
        awprot   <= axprot_to_slv(awprot_value);
        awqos    <= awqos_value;
        awregion <= awregion_value;
        awuser   <= v_normalized_awuser;
        awvalid  <= '1';
      end if;
      wait until rising_edge(clk);
      -- Checking clock behavior
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write address channel access is done
      if awready = '1' and cycle >= config.num_aw_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        awid            <= (awid'range => '0');
        awaddr          <= (awaddr'range => '0');
        awlen           <= (others => '0');
        awsize          <= (others => '0');
        awburst         <= (others => '0');
        awlock          <= '0';
        awcache         <= (others => '0');
        awprot          <= (others => '0');
        awqos           <= (others => '0');
        awregion        <= (others => '0');
        awuser          <= (awuser'range => '0');
        awvalid         <= '0';
        v_await_awready := false;
        exit;
      end if;
    end loop;
    check_value(not v_await_awready, config.max_wait_cycles_severity, ": Timeout waiting for AWREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure write_address_channel_write;

  procedure write_data_channel_write(
    constant wdata_value  : in t_slv_array;
    constant wstrb_value  : in t_slv_array;
    constant wuser_value  : in t_slv_array;
    constant awlen_value  : in unsigned(7 downto 0);
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   wdata        : inout std_logic_vector;
    signal   wstrb        : inout std_logic_vector;
    signal   wlast        : inout std_logic;
    signal   wuser        : inout std_logic_vector;
    signal   wvalid       : inout std_logic;
    signal   wready       : in std_logic;
    constant scope        : in string           := C_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call              : string                                      := "write_data_channel_write(" & to_string(wdata_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(wstrb_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_wready         : boolean                                     := true;
    variable v_normalized_wdata     : std_logic_vector(wdata'length - 1 downto 0) := normalize_and_check(wdata_value(0), wdata, ALLOW_NARROWER, "WDATA", "wdata", msg);
    variable v_normalized_wstrb     : std_logic_vector(wstrb'length - 1 downto 0) := normalize_and_check(wstrb_value(0), wstrb, ALLOW_EXACT_ONLY, "WSTRB", "wstrb", msg);
    variable v_normalized_wuser     : std_logic_vector(wuser'length - 1 downto 0);
    -- Helper variables
    variable v_time_of_rising_edge  : time                                        := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                        := -1 ns; -- time stamp for clk period checking
  begin
    if wuser'length > 0 then
      v_normalized_wuser := normalize_and_check(wuser_value(0), wuser, ALLOW_NARROWER, "WSTRB", "wstrb", msg);
    end if;
    for write_transfer_num in 0 to to_integer(unsigned(awlen_value)) loop
      for cycle in 0 to config.max_wait_cycles loop
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
        -- Assigning the write data channel outputs
        if cycle = config.num_w_pipe_stages then
          v_normalized_wdata := normalize_and_check(wdata_value(write_transfer_num), wdata, ALLOW_NARROWER, "wdata_value", "axi_if.wdata", msg);
          v_normalized_wstrb := normalize_and_check(wstrb_value(write_transfer_num), wstrb, ALLOW_EXACT_ONLY, "wstrb_value", "wstrb", msg);
          if wuser'length > 0 then
            v_normalized_wuser := normalize_and_check(wuser_value(write_transfer_num), wuser, ALLOW_NARROWER, "wuser_value", "wuser", msg);
          end if;
          wdata              <= v_normalized_wdata;
          wstrb              <= v_normalized_wstrb;
          wuser              <= v_normalized_wuser;
          wvalid             <= '1';
          if write_transfer_num = unsigned(awlen_value) then
            wlast <= '1';
          end if;
        end if;
        wait until rising_edge(clk);
        -- Checking clock behavior
        if v_time_of_rising_edge = -1 ns then
          v_time_of_rising_edge := now;
        end if;
        check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                  config.clock_period, config.clock_period_margin, config.clock_margin_severity);
        -- Checking if the write data channel access is done
        if wready = '1' and cycle >= config.num_w_pipe_stages then
          -- Wait according to config.bfm_sync setup
          wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
          wdata          <= (wdata'range => '0');
          wstrb          <= (wstrb'range => '0');
          wuser          <= (wuser'range => '0');
          wlast          <= '0';
          wvalid         <= '0';
          v_await_wready := false;
          exit;
        end if;
      end loop;
      check_value(not v_await_wready, config.max_wait_cycles_severity, ": Timeout waiting for WREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    end loop;
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure write_data_channel_write;

  procedure write_response_channel_receive(
    variable bid_value     : out std_logic_vector;
    variable bresp_value   : out t_xresp;
    variable buser_value   : out std_logic_vector;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   bid           : in std_logic_vector;
    signal   bresp         : in std_logic_vector(1 downto 0);
    signal   buser         : in std_logic_vector;
    signal   bvalid        : in std_logic;
    signal   bready        : inout std_logic;
    constant alert_level   : in t_alert_level    := error;
    constant scope         : in string           := C_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name        : string  := "write_response_channel_receive";
    constant local_proc_call        : string  := local_proc_name & "()";
    variable v_proc_call            : line;
    variable v_await_bvalid         : boolean := true;
    variable v_time_of_rising_edge  : time    := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time    := -1 ns; -- time stamp for clk period checking
    variable v_alert_radix          : t_radix;
  begin
    -- Setting procedure name for logging
    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'axi_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing axi_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write response channel ready signal
      if cycle = config.num_b_pipe_stages then
        bready <= '1';
      end if;
      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write response channel access is done
      if bvalid = '1' and cycle >= config.num_b_pipe_stages then
        -- Receiving response
        if bid'length > 0 then
          bid_value := normalize_and_check(bid, bid_value, ALLOW_EXACT_ONLY, "bid", "bid_value", msg);
        end if;
        if buser'length > 0 then
          buser_value := normalize_and_check(buser, buser_value, ALLOW_EXACT_ONLY, "buser", "buser_value", msg);
        end if;
        bresp_value    := slv_to_xresp(bresp);
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        bready         <= '0';
        v_await_bvalid := false;
      end if;
      if not v_await_bvalid then
        exit;
      end if;
    end loop;
    check_value(not v_await_bvalid, config.max_wait_cycles_severity, ": Timeout waiting for BVALID", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & " " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. read_data_channel_check)
    end if;
    DEALLOCATE(v_proc_call);
  end procedure write_response_channel_receive;

  procedure read_address_channel_write(
    constant arid_value     : in std_logic_vector;
    constant araddr_value   : in unsigned;
    constant arlen_value    : in unsigned(7 downto 0);
    constant arsize_value   : in integer range 1 to 128;
    constant arburst_value  : in t_axburst;
    constant arlock_value   : in t_axlock;
    constant arcache_value  : in std_logic_vector(3 downto 0);
    constant arprot_value   : in t_axprot;
    constant arqos_value    : in std_logic_vector(3 downto 0);
    constant arregion_value : in std_logic_vector(3 downto 0);
    constant aruser_value   : in std_logic_vector;
    constant msg            : in string;
    signal   clk            : in std_logic;
    signal   arid           : inout std_logic_vector;
    signal   araddr         : inout std_logic_vector;
    signal   arlen          : inout std_logic_vector(7 downto 0);
    signal   arsize         : inout std_logic_vector(2 downto 0);
    signal   arburst        : inout std_logic_vector(1 downto 0);
    signal   arlock         : inout std_logic;
    signal   arcache        : inout std_logic_vector(3 downto 0);
    signal   arprot         : inout std_logic_vector(2 downto 0);
    signal   arqos          : inout std_logic_vector(3 downto 0);
    signal   arregion       : inout std_logic_vector(3 downto 0);
    signal   aruser         : inout std_logic_vector;
    signal   arvalid        : inout std_logic;
    signal   arready        : in std_logic;
    constant scope          : in string           := C_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call              : string                                       := "read_address_channel_write(" & to_string(araddr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_arready        : boolean                                      := true;
    -- Normalizing unconstrained inputs
    variable v_normalized_arid      : std_logic_vector(arid'length - 1 downto 0);
    variable v_normalized_araddr    : std_logic_vector(araddr'length - 1 downto 0) := normalize_and_check(std_logic_vector(araddr_value), araddr, ALLOW_WIDER, "araddr_value", "araddr", msg);
    variable v_normalized_aruser    : std_logic_vector(aruser'length - 1 downto 0);
    -- Helper variables
    variable v_time_of_rising_edge  : time                                         := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                         := -1 ns; -- time stamp for clk period checking
  begin
    if arid'length > 0 then
      v_normalized_arid := normalize_and_check(arid_value, arid, ALLOW_WIDER, "arid_value", "arid", msg);
    end if;
    if aruser'length > 0 then
      v_normalized_aruser := normalize_and_check(aruser_value, aruser, ALLOW_WIDER, "aruser_value", "awuser", msg);
    end if;
    for cycle in 0 to config.max_wait_cycles loop
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      -- Assigning the write data channel outputs
      if cycle = config.num_ar_pipe_stages then
        arid     <= v_normalized_arid;
        araddr   <= v_normalized_araddr;
        arlen    <= std_logic_vector(arlen_value);
        arsize   <= bytes_to_axsize(arsize_value);
        arburst  <= axburst_to_slv(arburst_value);
        arlock   <= axlock_to_sl(arlock_value);
        arcache  <= arcache_value;
        arprot   <= axprot_to_slv(arprot_value);
        arqos    <= arqos_value;
        arregion <= arregion_value;
        aruser   <= v_normalized_aruser;
        arvalid  <= '1';
      end if;
      wait until rising_edge(clk);
      -- Checking clock behavior
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Checking if the write address channel access is done
      if arready = '1' and cycle >= config.num_ar_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        arid            <= (arid'range => '0');
        araddr          <= (araddr'range => '0');
        arlen           <= (others => '0');
        arsize          <= (others => '0');
        arburst         <= (others => '0');
        arlock          <= '0';
        arcache         <= (others => '0');
        arprot          <= (others => '0');
        arqos           <= (others => '0');
        arregion        <= (others => '0');
        aruser          <= (aruser'range => '0');
        arvalid         <= '0';
        v_await_arready := false;
        exit;
      end if;
    end loop;
    check_value(not v_await_arready, config.max_wait_cycles_severity, ": Timeout waiting for ARREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    log(ID_CHANNEL_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure read_address_channel_write;

  procedure read_data_channel_receive(
    variable read_result     : out t_vvc_result;
    variable read_data_queue : inout t_axi_read_data_queue;
    constant msg             : in string;
    signal   clk             : in std_logic;
    signal   rid             : in std_logic_vector;
    signal   rdata           : in std_logic_vector;
    signal   rresp           : in std_logic_vector(1 downto 0);
    signal   rlast           : in std_logic;
    signal   ruser           : in std_logic_vector;
    signal   rvalid          : in std_logic;
    signal   rready          : inout std_logic;
    constant scope           : in string           := C_SCOPE;
    constant msg_id_panel    : in t_msg_id_panel   := shared_msg_id_panel;
    constant config          : in t_axi_bfm_config := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call   : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name        : string  := "read_data_channel_receive"; -- Local proc_name; used if called from sequncer or VVC
    constant local_proc_call        : string  := local_proc_name & "()"; -- Local proc_call; used if called from sequncer or VVC
    variable v_proc_call            : line;
    variable v_await_rvalid         : boolean := true;
    variable v_time_of_rising_edge  : time    := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time    := -1 ns; -- time stamp for clk period checking
    variable v_rlast_detected       : boolean := false;
    variable v_returning_rid        : std_logic_vector(rid'length - 1 downto 0);
    variable v_read_data            : t_vvc_result;
    variable v_ret                  : boolean := true;
  begin

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'axi_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing axi_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    loop
      for cycle in 0 to config.max_wait_cycles loop
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
        -- Assigning the read data channel ready signal
        if cycle = config.num_r_pipe_stages then
          rready <= '1';
        end if;
        wait until rising_edge(clk);
        -- Checking clock behavior
        if v_time_of_rising_edge = -1 ns then
          v_time_of_rising_edge := now;
        end if;
        check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                  config.clock_period, config.clock_period_margin, config.clock_margin_severity);
        -- Checking if the read data channel access is done
        if rvalid = '1' and cycle >= config.num_r_pipe_stages then
          v_await_rvalid := false;
          -- Storing response
          read_data_queue.add_to_queue(rid, rdata, slv_to_xresp(rresp), ruser);
          -- Checking if the transfer is done
          if rlast = '1' then
            v_rlast_detected := true;
            v_returning_rid  := rid;
          end if;
          -- Wait according to config.bfm_sync setup
          wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
          rready         <= '0';
        end if;
        if not v_await_rvalid then
          exit;
        end if;
      end loop;
      v_ret := check_value(not v_await_rvalid, config.max_wait_cycles_severity, ": Timeout waiting for RVALID", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      if (v_ret = false) then
        exit;
      end if;
      if v_rlast_detected then
        read_result := read_data_queue.fetch_from_queue(v_returning_rid);
        exit;
      end if;
      v_await_rvalid := true;
    end loop;

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & " " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. read_data_channel_check)
    end if;
    DEALLOCATE(v_proc_call);
  end procedure read_data_channel_receive;

end package body axi_channel_handler_pkg;
