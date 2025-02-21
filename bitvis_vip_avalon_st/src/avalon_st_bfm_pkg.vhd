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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--================================================================================================================================
--================================================================================================================================
package avalon_st_bfm_pkg is

  --==========================================================================================
  -- Types and constants for AVALON_ST BFM
  --==========================================================================================
  constant C_BFM_SCOPE : string := "AVALON_ST BFM";

  -- Constants for the maximum sizes to use in this BFM. Can be modified in adaptations_pkg.
  constant C_MAX_BITS_PER_SYMBOL  : positive := C_AVALON_ST_BFM_MAX_BITS_PER_SYMBOL;
  constant C_MAX_SYMBOLS_PER_BEAT : positive := C_AVALON_ST_BFM_MAX_SYMBOLS_PER_BEAT;

  -- Interface record for BFM signals
  type t_avalon_st_if is record
    channel         : std_logic_vector; -- Channel number for data being transferred on the current cycle.
    data            : std_logic_vector; -- Data. Width is constrained when the procedure is called.
    data_error      : std_logic_vector; -- Bit mask to mark errors affecting the data on the current cycle. (NOT IMPLEMENTED)
    ready           : std_logic;        -- Backpressure.
    valid           : std_logic;        -- Data valid.
    empty           : std_logic_vector; -- Number of symbols that are empty (not valid).
    end_of_packet   : std_logic;        -- Active during the last symbol of the packet.
    start_of_packet : std_logic;        -- Active during the first symbol of the packet.
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_avalon_st_bfm_config is record
    max_wait_cycles          : natural; -- Used for setting the maximum cycles to wait before an alert is issued when
                                        -- waiting for ready or valid signals from the DUT.
    max_wait_cycles_severity : t_alert_level; -- Severity if max_wait_cycles expires.
    clock_period             : time;    -- Period of the clock signal.
    clock_period_margin      : time;    -- Input clock period margin to specified clock_period
    clock_margin_severity    : t_alert_level; -- The above margin will have this severity
    setup_time               : time;    -- Setup time for generated signals, set to clock_period/4
    hold_time                : time;    -- Hold time for generated signals, set to clock_period/4
    bfm_sync                 : t_bfm_sync; -- Synchronisation of the BFM procedures, i.e. using clock signals, using setup_time and hold_time.
    match_strictness         : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    symbol_width             : natural; -- Number of data bits per symbol.
    first_symbol_in_msb      : boolean; -- Symbol ordering. When true, first-order symbol is in most significant bits.
    max_channel              : natural; -- Maximum number of channels that the interface supports.
    use_packet_transfer      : boolean; -- When true, packet signals are enabled: start_of_packet, end_of_packet & empty.
    id_for_bfm               : t_msg_id; -- The message ID used as a general message ID in the BFM
  end record;

  -- Define the default value for the BFM config
  constant C_AVALON_ST_BFM_CONFIG_DEFAULT : t_avalon_st_bfm_config := (
    max_wait_cycles          => 100,
    max_wait_cycles_severity => ERROR,
    clock_period             => -1 ns,
    clock_period_margin      => 0 ns,
    clock_margin_severity    => TB_ERROR,
    setup_time               => -1 ns,
    hold_time                => -1 ns,
    bfm_sync                 => SYNC_ON_CLOCK_ONLY,
    match_strictness         => MATCH_EXACT,
    symbol_width             => 8,
    first_symbol_in_msb      => true,
    max_channel              => 0,
    use_packet_transfer      => true,
    id_for_bfm               => ID_BFM
  );

  --==========================================================================================
  -- BFM procedures
  --==========================================================================================
  -- This function returns an Avalon-ST interface with initialized signals.
  -- All BFM output signals are initialized to 0
  -- All BFM input signals are initialized to Z
  function init_avalon_st_if_signals(
    is_master        : boolean;         -- When true, this BFM drives data signals
    channel_width    : natural;
    data_width       : natural;
    data_error_width : natural;
    empty_width      : natural
  ) return t_avalon_st_if;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Transmit
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_transmit(
    constant channel_value : in std_logic_vector;
    constant data_array    : in t_slv_array;
    constant msg           : in string                 := "";
    signal   clk           : in std_logic;
    signal   avalon_st_if  : inout t_avalon_st_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
  );

  procedure avalon_st_transmit(
    constant data_array   : in t_slv_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   avalon_st_if : inout t_avalon_st_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Receive
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_receive(
    variable channel_value : out std_logic_vector;
    variable data_array    : out t_slv_array;
    constant msg           : in string                 := "";
    signal   clk           : in std_logic;
    signal   avalon_st_if  : inout t_avalon_st_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  procedure avalon_st_receive(
    variable data_array    : out t_slv_array;
    constant msg           : in string                 := "";
    signal   clk           : in std_logic;
    signal   avalon_st_if  : inout t_avalon_st_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Expect
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_expect(
    constant channel_exp  : in std_logic_vector;
    constant data_exp     : in t_slv_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   avalon_st_if : inout t_avalon_st_if;
    constant alert_level  : in t_alert_level          := error;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
  );

  procedure avalon_st_expect(
    constant data_exp     : in t_slv_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   avalon_st_if : inout t_avalon_st_if;
    constant alert_level  : in t_alert_level          := error;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
  );

end package avalon_st_bfm_pkg;

--================================================================================================================================
--================================================================================================================================
package body avalon_st_bfm_pkg is

  function init_avalon_st_if_signals(
    is_master        : boolean;         -- When true, this BFM drives data signals
    channel_width    : natural;
    data_width       : natural;
    data_error_width : natural;
    empty_width      : natural
  ) return t_avalon_st_if is
    variable init_if : t_avalon_st_if(channel(channel_width - 1 downto 0),
                                      data(data_width - 1 downto 0),
                                      data_error(data_error_width - 1 downto 0),
                                      empty(empty_width - 1 downto 0));
  begin
    if is_master then
      -- from slave to master
      init_if.ready           := 'Z';
      -- from master to slave
      init_if.channel         := (init_if.channel'range => '0');
      init_if.data            := (init_if.data'range => '0');
      init_if.data_error      := (init_if.data_error'range => '0');
      init_if.valid           := '0';
      init_if.empty           := (init_if.empty'range => '0');
      init_if.end_of_packet   := '0';
      init_if.start_of_packet := '0';
    else
      -- from slave to master
      init_if.ready           := '0';
      -- from master to slave
      init_if.channel         := (init_if.channel'range => 'Z');
      init_if.data            := (init_if.data'range => 'Z');
      init_if.data_error      := (init_if.data_error'range => 'Z');
      init_if.valid           := 'Z';
      init_if.empty           := (init_if.empty'range => 'Z');
      init_if.end_of_packet   := 'Z';
      init_if.start_of_packet := 'Z';
    end if;
    return init_if;
  end function;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Transmit
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_transmit(
    constant channel_value : in std_logic_vector;
    constant data_array    : in t_slv_array;
    constant msg           : in string                 := "";
    signal   clk           : in std_logic;
    signal   avalon_st_if  : inout t_avalon_st_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
  ) is
    constant c_data_word_size       : natural                                                                := data_array(data_array'low)'length;
    constant c_sym_width            : natural                                                                := config.symbol_width;
    constant c_symbols_per_beat     : natural                                                                := avalon_st_if.data'length / config.symbol_width; -- Number of symbols transferred per cycle
    constant proc_name              : string                                                                 := "avalon_st_transmit";
    constant proc_call              : string                                                                 := proc_name & "(" & to_string(data_array'length) & " words/" & to_string(data_array'length * c_symbols_per_beat) & " sym, ch:" & to_string(channel_value, DEC, AS_IS) & ")";
    -- Normalize to the DUT channel/data widths
    variable v_normalized_chan      : std_logic_vector(avalon_st_if.channel'length - 1 downto 0)             := normalize_and_check(channel_value, avalon_st_if.channel, ALLOW_NARROWER, "channel", "avalon_st_if.channel", msg);
    variable v_normalized_data      : t_slv_array(0 to data_array'length - 1)(c_data_word_size - 1 downto 0) := data_array;
    -- Helper variables
    variable v_symbol_array         : t_slv_array_ptr;
    variable v_sym_in_beat          : natural                                                                := 0;
    variable v_data_offset          : natural                                                                := 0;
    variable v_time_of_rising_edge  : time                                                                   := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                                                   := -1 ns; -- time stamp for clk period checking
    variable v_wait_for_transfer    : boolean                                                                := false;
    variable v_wait_count           : natural                                                                := 0;
    variable v_timeout              : boolean                                                                := false;
    variable v_ready                : std_logic; -- Sampled ready for the current clock cycle
  begin

    check_value(c_sym_width <= C_MAX_BITS_PER_SYMBOL, TB_FAILURE, "Sanity check: Check that symbol_width doesn't exceed C_MAX_BITS_PER_SYMBOL.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(c_symbols_per_beat <= C_MAX_SYMBOLS_PER_BEAT, TB_FAILURE, "Sanity check: Check that c_symbols_per_beat doesn't exceed C_MAX_SYMBOLS_PER_BEAT.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(to_integer(unsigned(v_normalized_chan)) <= config.max_channel, TB_FAILURE, "Sanity check: Check that channel number is supported.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(avalon_st_if.data'length mod c_sym_width = 0, TB_FAILURE, "Sanity check: Check that data width is a multiple of symbol_width.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(avalon_st_if.empty'length = maximum(log2(c_symbols_per_beat), 1), TB_FAILURE, "Sanity check: Check that empty width equals log2(symbols_per_beat).", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value((c_data_word_size = c_sym_width) or (c_data_word_size = avalon_st_if.data'length), TB_FAILURE, "Sanity check: Check that data_array elements have either the size of the data bus or the configured symbol.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(data_array'ascending, TB_FAILURE, "Sanity check: Check that data_array is ascending (defined with 'to'), for symbol order clarity.", scope, ID_NEVER, msg_id_panel, proc_call);
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    end if;

    -- Use a symbol array to make it easier to iterate through the data
    if c_data_word_size = c_sym_width then
      v_symbol_array     := new t_slv_array(0 to v_normalized_data'length-1)(c_sym_width-1 downto 0);
      v_symbol_array.all := v_normalized_data;
    else
      v_symbol_array := new t_slv_array(0 to v_normalized_data'length*c_symbols_per_beat-1)(c_sym_width-1 downto 0);
      for i in 0 to v_normalized_data'length - 1 loop
        for j in 0 to c_symbols_per_beat - 1 loop
          if config.first_symbol_in_msb then
            v_data_offset := (c_symbols_per_beat - 1 - j) * c_sym_width;
          else
            v_data_offset := j * c_sym_width;
          end if;
          v_symbol_array(i * c_symbols_per_beat + j) := v_normalized_data(i)(v_data_offset + c_sym_width - 1 downto v_data_offset);
        end loop;
      end loop;
    end if;

    avalon_st_if <= init_avalon_st_if_signals(is_master        => true, -- this BFM drives data signals
                                              channel_width    => avalon_st_if.channel'length,
                                              data_width       => avalon_st_if.data'length,
                                              data_error_width => avalon_st_if.data_error'length,
                                              empty_width      => avalon_st_if.empty'length);

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    log(ID_PACKET_INITIATE, proc_call & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    ------------------------------------------------------------
    -- Send all the symbols in the symbol array
    ------------------------------------------------------------
    for symbol in 0 to v_symbol_array'high loop
      v_wait_for_transfer := false;

      -- Set the basic interface signals
      avalon_st_if.valid                                                      <= '1';
      avalon_st_if.channel                                                    <= v_normalized_chan;
      -- Insert the symbols into the data bus according to the configured order
      if config.first_symbol_in_msb then
        v_data_offset := (c_symbols_per_beat - 1 - v_sym_in_beat) * c_sym_width;
      else
        v_data_offset := v_sym_in_beat * c_sym_width;
      end if;
      avalon_st_if.data(v_data_offset + c_sym_width - 1 downto v_data_offset) <= v_symbol_array(symbol);
      log(ID_PACKET_DATA, proc_call & "=> " & to_string(v_symbol_array(symbol), HEX, AS_IS, INCL_RADIX) & " (symbol# " & to_string(symbol) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);

      -- Set the packet transfer signals
      if config.use_packet_transfer then
        avalon_st_if.start_of_packet <= '1' when symbol / c_symbols_per_beat = 0 else '0';
        avalon_st_if.end_of_packet   <= '1' when symbol = v_symbol_array'high else '0';
        if c_symbols_per_beat > 1 then
          avalon_st_if.empty <= std_logic_vector(to_unsigned(c_symbols_per_beat - 1 - v_sym_in_beat, avalon_st_if.empty'length));
        end if;
      end if;

      -- Counter for the symbol index within the current cycle
      if v_sym_in_beat = c_symbols_per_beat - 1 then
        v_sym_in_beat       := 0;
        v_wait_for_transfer := true;
      else
        v_sym_in_beat := v_sym_in_beat + 1;
      end if;

      -- Always transfer the data on the last cycle
      if symbol = v_symbol_array'high then
        v_wait_for_transfer := true;
      end if;

      if v_wait_for_transfer then
        wait until rising_edge(clk);
        if v_time_of_rising_edge = -1 ns then
          v_time_of_rising_edge := now;
        end if;
        v_ready := avalon_st_if.ready;
        check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                  config.clock_period, config.clock_period_margin, config.clock_margin_severity);

        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

        v_wait_count := 1;
        -- Check ready signal is asserted (sampled at rising_edge)
        while v_ready = '0' loop
          wait until rising_edge(clk);
          v_ready := avalon_st_if.ready;

          -- Wait according to config.bfm_sync setup
          wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

          v_wait_count := v_wait_count + 1;
          -- If timeout then exit procedure
          if v_wait_count >= config.max_wait_cycles then
            v_timeout := true;
            exit;
          end if;
        end loop;
        if v_timeout then
          exit;
        end if;

        -- Default values for the next clk cycle
        avalon_st_if <= init_avalon_st_if_signals(is_master        => true, -- this BFM drives data signals
                                                  channel_width    => avalon_st_if.channel'length,
                                                  data_width       => avalon_st_if.data'length,
                                                  data_error_width => avalon_st_if.data_error'length,
                                                  empty_width      => avalon_st_if.empty'length);
      end if;
    end loop;

    -- Done. Check if there was a timeout or it was successful
    if v_timeout then
      alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout while waiting for ready. " & add_msg_delimiter(msg), scope);
    else
      log(ID_PACKET_COMPLETE, proc_call & " DONE. " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
    deallocate(v_symbol_array);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Transmit
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_transmit(
    constant data_array   : in t_slv_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   avalon_st_if : inout t_avalon_st_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
  ) is
    variable v_channel : std_logic_vector(avalon_st_if.channel'range) := (others => '0');
  begin
    avalon_st_transmit(v_channel, data_array, msg, clk, avalon_st_if, scope, msg_id_panel, config);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Receive
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_receive(
    variable channel_value : out std_logic_vector;
    variable data_array    : out t_slv_array;
    constant msg           : in string                 := "";
    signal   clk           : in std_logic;
    signal   avalon_st_if  : inout t_avalon_st_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant c_data_word_size       : natural                                             := data_array(data_array'low)'length;
    constant c_sym_width            : natural                                             := config.symbol_width;
    constant c_symbols_per_beat     : natural                                             := avalon_st_if.data'length / config.symbol_width; -- Number of symbols transferred per cycle
    constant local_proc_name        : string                                              := "avalon_st_receive"; -- Internal proc_name; Used if called from sequencer or VVC
    constant local_proc_call        : string                                              := local_proc_name & "(" & to_string(data_array'length) & " words/" & to_string(data_array'length * c_symbols_per_beat) & " sym)";
    -- Normalize to the DUT channel/data widths
    variable v_normalized_chan      : std_logic_vector(channel_value'length - 1 downto 0) := (others => '0');
    variable v_normalized_data      : t_slv_array(0 to data_array'length - 1)(c_data_word_size - 1 downto 0);
    -- Helper variables
    variable v_proc_call            : line; -- Current proc_call, external or local
    variable v_symbol_array         : t_slv_array_ptr;
    variable v_sym_in_beat          : natural                                             := 0;
    variable v_sym_cnt              : natural                                             := 0;
    variable v_invalid_count        : natural                                             := 0; -- # cycles without valid being asserted
    variable v_done                 : boolean                                             := false;
    variable v_timeout              : boolean                                             := false;
    variable v_empty_symbols        : natural                                             := 0;
    variable v_data_offset          : natural                                             := 0;
    variable v_time_of_rising_edge  : time                                                := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                                := -1 ns; -- time stamp for clk period checking
  begin

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'avalon_st_receive()...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing avalon_st_receive()...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    check_value(c_sym_width <= C_MAX_BITS_PER_SYMBOL, TB_FAILURE, "Sanity check: Check that symbol_width doesn't exceed C_MAX_BITS_PER_SYMBOL.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(c_symbols_per_beat <= C_MAX_SYMBOLS_PER_BEAT, TB_FAILURE, "Sanity check: Check that c_symbols_per_beat doesn't exceed C_MAX_SYMBOLS_PER_BEAT.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(avalon_st_if.data'length mod c_sym_width = 0, TB_FAILURE, "Sanity check: Check that data width is a multiple of symbol_width.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(avalon_st_if.empty'length = maximum(log2(c_symbols_per_beat), 1), TB_FAILURE, "Sanity check: Check that empty width equals log2(symbols_per_beat).", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value((c_data_word_size = c_sym_width) or (c_data_word_size = avalon_st_if.data'length), TB_FAILURE, "Sanity check: Check that data_array elements have either the size of the data bus or the configured symbol.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(data_array'ascending, TB_FAILURE, "Sanity check: Check that data_array is ascending (defined with 'to'), for symbol order clarity.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    end if;

    -- Use a symbol array to make it easier to iterate through the data
    if c_data_word_size = c_sym_width then
      v_symbol_array := new t_slv_array(0 to v_normalized_data'length-1)(c_sym_width-1 downto 0);
    else
      v_symbol_array := new t_slv_array(0 to v_normalized_data'length*c_symbols_per_beat-1)(c_sym_width-1 downto 0);
    end if;

    avalon_st_if <= init_avalon_st_if_signals(is_master        => false,
                                              channel_width    => avalon_st_if.channel'length,
                                              data_width       => avalon_st_if.data'length,
                                              data_error_width => avalon_st_if.data_error'length,
                                              empty_width      => avalon_st_if.empty'length);

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    log(ID_PACKET_INITIATE, v_proc_call.all & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    while not (v_done) loop
      ------------------------------------------------------------
      -- Wait for the rising_edge of the clock to sample the data
      ------------------------------------------------------------
      if v_sym_in_beat = 0 then
        avalon_st_if.ready <= '1';
        wait until rising_edge(clk);
        if v_time_of_rising_edge = -1 ns then
          v_time_of_rising_edge := now;
        end if;
      end if;

      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);

      ------------------------------------------------------------
      -- Receive the data
      ------------------------------------------------------------
      if avalon_st_if.valid = '1' and avalon_st_if.ready = '1' then
        v_invalid_count := 0;

        -- Sample the symbols from the data bus according to the configured order
        if config.first_symbol_in_msb then
          v_data_offset := (c_symbols_per_beat - 1 - v_sym_in_beat) * c_sym_width;
        else
          v_data_offset := v_sym_in_beat * c_sym_width;
        end if;
        v_normalized_chan         := avalon_st_if.channel;
        v_symbol_array(v_sym_cnt) := avalon_st_if.data(v_data_offset + c_sym_width - 1 downto v_data_offset);
        log(ID_PACKET_DATA, v_proc_call.all & "=> " & to_string(v_symbol_array(v_sym_cnt), HEX, AS_IS, INCL_RADIX) & " (symbol# " & to_string(v_sym_cnt) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);

        -- Sample the packet transfer signals
        if config.use_packet_transfer then
          -- Check that start of packet is received only on the first data transfer
          if v_sym_cnt = 0 and avalon_st_if.start_of_packet = '0' then
            alert(error, v_proc_call.all & "=> Failed. Start of packet not set at first valid transfer. " & add_msg_delimiter(msg), scope);
          elsif v_sym_cnt / c_symbols_per_beat > 0 and v_sym_in_beat = 0 and avalon_st_if.start_of_packet = '1' then
            alert(error, v_proc_call.all & "=> Failed. Start of packet set at symbol #" & to_string(v_sym_cnt) & ". " & add_msg_delimiter(msg), scope);
          end if;
          -- Check the number of empty symbols on the last data transfer
          if c_symbols_per_beat > 1 then
            v_empty_symbols := to_integer(unsigned(avalon_st_if.empty));
          end if;
          -- Check that end of packet is received only on the last data transfer
          if v_sym_cnt = v_symbol_array'length - 1 and avalon_st_if.end_of_packet = '0' then
            alert(error, v_proc_call.all & "=> Failed. End of packet not set at last valid transfer. " & add_msg_delimiter(msg), scope);
            v_done := true;
          elsif v_sym_cnt / c_symbols_per_beat < v_symbol_array'length / c_symbols_per_beat - 1 and v_sym_in_beat = 0 and avalon_st_if.end_of_packet = '1' then
            alert(error, v_proc_call.all & "=> Failed. End of packet set at symbol #" & to_string(v_sym_cnt) & ". " & add_msg_delimiter(msg), scope);
            v_done := true;
          end if;
        end if;

        -- Finish receiving data when the symbol array ends
        if v_sym_cnt = v_symbol_array'length - 1 then
          v_done := true;
          -- Check that empty signal is set on the last data transfer
          if v_sym_in_beat /= c_symbols_per_beat - 1 - v_empty_symbols then
            alert(error, v_proc_call.all & "=> Failed. Empty signal not set correctly for the last transfer. " & add_msg_delimiter(msg), scope);
          end if;
        end if;

        -- Counter for the symbol index within the current cycle
        if v_sym_in_beat = c_symbols_per_beat - 1 then
          v_sym_in_beat := 0;
          -- Don't wait on the last cycle
          if not (v_done) then
            wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
          end if;
        else
          v_sym_in_beat := v_sym_in_beat + 1;
        end if;
        -- Counter for the symbols received
        v_sym_cnt := v_sym_cnt + 1;

      ------------------------------------------------------------
      -- Data couldn't be sampled, wait until next cycle
      ------------------------------------------------------------
      else
        -- Check for timeout
        if v_invalid_count >= config.max_wait_cycles then
          v_timeout := true;
          v_done    := true;
        else
          v_invalid_count := v_invalid_count + 1;
        end if;
        wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      end if;
    end loop;

    -- Wait according to bfm_sync config
    if not (v_timeout) then
      wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
    end if;

    -- Send the data with the matching interface width
    if c_data_word_size = c_sym_width then
      v_normalized_data := v_symbol_array.all;
    else
      for i in 0 to v_normalized_data'length - 1 loop
        for j in 0 to c_symbols_per_beat - 1 loop
          if config.first_symbol_in_msb then
            v_data_offset := (c_symbols_per_beat - 1 - j) * c_sym_width;
          else
            v_data_offset := j * c_sym_width;
          end if;
          v_normalized_data(i)(v_data_offset + c_sym_width - 1 downto v_data_offset) := v_symbol_array(i * c_symbols_per_beat + j);
        end loop;
      end loop;
    end if;
    data_array    := v_normalized_data;
    check_value(to_integer(unsigned(v_normalized_chan)) <= config.max_channel, TB_FAILURE,
                "Sanity check: Check that channel number is supported.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    channel_value := v_normalized_chan;

    avalon_st_if <= init_avalon_st_if_signals(is_master        => false,
                                              channel_width    => avalon_st_if.channel'length,
                                              data_width       => avalon_st_if.data'length,
                                              data_error_width => avalon_st_if.data_error'length,
                                              empty_width      => avalon_st_if.empty'length);

    -- Done. Check if there was a timeout or it was successful
    if v_timeout then
      alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout while waiting for valid data. " & add_msg_delimiter(msg), scope);
    else
      if ext_proc_call = "" then
        log(ID_PACKET_COMPLETE, v_proc_call.all & " DONE. " & add_msg_delimiter(msg), scope, msg_id_panel);
      else
      -- Log will be handled by calling procedure (e.g. avalon_st_expect)
      end if;
    end if;

    DEALLOCATE(v_proc_call);
    deallocate(v_symbol_array);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Receive
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_receive(
    variable data_array    : out t_slv_array;
    constant msg           : in string                 := "";
    signal   clk           : in std_logic;
    signal   avalon_st_if  : inout t_avalon_st_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    variable v_channel : std_logic_vector(avalon_st_if.channel'range);
  begin
    avalon_st_receive(v_channel, data_array, msg, clk, avalon_st_if, scope, msg_id_panel, config, ext_proc_call);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Expect
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_expect(
    constant channel_exp  : in std_logic_vector;
    constant data_exp     : in t_slv_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   avalon_st_if : inout t_avalon_st_if;
    constant alert_level  : in t_alert_level          := error;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
  ) is
    constant c_data_word_size     : natural                                                              := data_exp(data_exp'low)'length;
    constant c_symbols_per_beat   : natural                                                              := avalon_st_if.data'length / config.symbol_width; -- Number of symbols transferred per cycle
    constant proc_name            : string                                                               := "avalon_st_expect";
    constant proc_call            : string                                                               := proc_name & "(" & to_string(data_exp'length) & " words/" & to_string(data_exp'length * c_symbols_per_beat) & " sym, ch:" & to_string(channel_exp, DEC, AS_IS) & ")";
    -- Helper variables
    variable v_normalized_chan    : std_logic_vector(avalon_st_if.channel'length - 1 downto 0)           := normalize_and_check(channel_exp, avalon_st_if.channel, ALLOW_NARROWER, "channel", "avalon_st_if.channel", msg);
    variable v_normalized_data    : t_slv_array(0 to data_exp'length - 1)(c_data_word_size - 1 downto 0) := data_exp;
    variable v_rx_channel         : std_logic_vector(v_normalized_chan'length - 1 downto 0);
    variable v_rx_data_array      : t_slv_array(0 to data_exp'length - 1)(c_data_word_size - 1 downto 0);
    variable v_channel_error      : boolean                                                              := false;
    variable v_data_error_cnt     : natural                                                              := 0;
    variable v_first_wrong_symbol : natural;
    variable v_alert_radix        : t_radix;
  begin

    check_value(data_exp'ascending, TB_FAILURE, "Sanity check: Check that data_exp is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, proc_call);

    -- Receive data
    avalon_st_receive(v_rx_channel, v_rx_data_array, msg, clk, avalon_st_if, scope, msg_id_panel, config, proc_call);

    -- Check the received channel
    if v_rx_channel /= v_normalized_chan then
      v_channel_error := true;
    end if;

    -- Check if each received bit matches the expected.
    -- Report the first wrong symbol (iterate from the last to the first)
    for symbol in v_rx_data_array'high downto 0 loop
      for i in v_rx_data_array(symbol)'range loop
        -- Allow don't care in expected value and use match strictness from config for comparison
        if v_normalized_data(symbol)(i) = '-' or check_value(v_rx_data_array(symbol)(i), v_normalized_data(symbol)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        -- Check is OK
        else
          -- Received symbol doesn't match
          v_data_error_cnt     := v_data_error_cnt + 1;
          v_first_wrong_symbol := symbol;
        end if;
      end loop;
    end loop;

    -- Done. Report result
    if C_ERROR_REPORT_EXTENT = EXTENDED then
      if v_data_error_cnt /= 0 then
        -- Use binary representation when mismatch is due to weak signals
        v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_data_array(v_first_wrong_symbol), v_normalized_data(v_first_wrong_symbol), MATCH_STD, 
          NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
        alert(alert_level, proc_call & "=> Failed in " & to_string(v_data_error_cnt) & " data bits. First mismatch in symbol# " & to_string(v_first_wrong_symbol+1) & ". Was " & 
          to_string(v_rx_data_array(v_first_wrong_symbol), v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data(v_first_wrong_symbol), v_alert_radix, AS_IS, INCL_RADIX) & 
          "." & LF & "Was:" & LF & to_string(v_rx_data_array, v_alert_radix, AS_IS) & LF & "Expected:" & LF & to_string(v_normalized_data, v_alert_radix, AS_IS) & LF & 
          add_msg_delimiter(msg), scope);
      elsif v_channel_error then
        alert(alert_level, proc_call & "=> Failed. Wrong channel. Was " & to_string(v_rx_channel, HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_chan, HEX, AS_IS, INCL_RADIX) & 
        ". " & msg, scope);
      else
        log(config.id_for_bfm, proc_call & "=> OK, received " & to_string(v_rx_data_array'length) & " symbols. " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    elsif C_ERROR_REPORT_EXTENT = BRIEF then
      if v_data_error_cnt /= 0 then
        -- Use binary representation when mismatch is due to weak signals
        v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_data_array(v_first_wrong_symbol), v_normalized_data(v_first_wrong_symbol), MATCH_STD, 
          NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
        alert(alert_level, proc_call & "=> Failed in " & to_string(v_data_error_cnt) & " data bits. First mismatch in symbol# " & to_string(v_first_wrong_symbol+1) & ". Was " & 
          to_string(v_rx_data_array(v_first_wrong_symbol), v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data(v_first_wrong_symbol), v_alert_radix, AS_IS, INCL_RADIX) & 
          "." & LF & add_msg_delimiter(msg), scope);
      elsif v_channel_error then
        alert(alert_level, proc_call & "=> Failed. Wrong channel. Was " & to_string(v_rx_channel, HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_chan, HEX, AS_IS, INCL_RADIX) & 
        ". " & msg, scope);
      else
        log(config.id_for_bfm, proc_call & "=> OK, received " & to_string(v_rx_data_array'length) & " symbols. " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Expect
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_expect(
    constant data_exp     : in t_slv_array;
    constant msg          : in string                 := "";
    signal   clk          : in std_logic;
    signal   avalon_st_if : inout t_avalon_st_if;
    constant alert_level  : in t_alert_level          := error;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
  ) is
    variable v_channel : std_logic_vector(avalon_st_if.channel'range) := (others => '0');
  begin
    avalon_st_expect(v_channel, data_exp, msg, clk, avalon_st_if, alert_level, scope, msg_id_panel, config);
  end procedure;

end package body avalon_st_bfm_pkg;
