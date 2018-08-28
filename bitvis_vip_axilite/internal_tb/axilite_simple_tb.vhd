--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- A free license is hereby granted, free of charge, to any person obtaining
-- a copy of this VHDL code and associated documentation files (for 'UVVM Utility Library'),
-- to use, copy, modify, merge, publish and/or distribute - subject to the following conditions:
--  - This copyright notice shall be included as is in all copies or substantial portions of the code and documentation
--  - The files included in UVVM Utility Library may only be used as a part of this library as a whole
--  - The License file may not be modified
--  - The calls in the code to the license file ('show_license') may not be removed or modified.
--  - No other conditions whatsoever may be added to those of this License

-- BITVIS UTILITY LIBRARY AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH BITVIS UTILITY LIBRARY.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- VHDL unit     : Bitvis AXILITE Library : axilite_simple_tb
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_run_context;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_axilite;
context bitvis_vip_axilite.vvc_context;

-- Test case entity
entity axilite_simple_tb is
  generic (
    -- This generic is used to configure the testbench from run.py, e.g. what
    -- test case to run. The default value is used when not running from script
    -- and in that case all test cases are run.
    runner_cfg : runner_cfg_t := runner_cfg_default);
end entity;

-- Test case architecture
architecture func of axilite_simple_tb is

  constant C_CLK_PERIOD : time := 10 ns;
  constant C_ADDR_WIDTH_1 : natural := 32;
  constant C_DATA_WIDTH_1 : natural := 32;
  constant C_ADDR_WIDTH_2 : natural := 32;
  constant C_DATA_WIDTH_2 : natural := 64;

  constant C_INTERFACE_1  : natural := 1;
  constant C_INTERFACE_2  : natural := 2;


  signal clk        : std_logic := '0';
  signal areset     : std_logic := '0';
  signal clock_ena  : boolean   := false;

  -- signals
  -- The axilite interface is gathered in one record, so procedures that use the
  -- axilite interface have less arguments
  signal axilite_if_1       : t_axilite_if( write_address_channel(  awaddr( C_ADDR_WIDTH_1    -1 downto 0)),
                                            write_data_channel(     wdata(  C_DATA_WIDTH_1    -1 downto 0),
                                                                    wstrb(( C_DATA_WIDTH_1/8) -1 downto 0)),
                                            read_address_channel(   araddr( C_ADDR_WIDTH_1    -1 downto 0)),
                                            read_data_channel(      rdata(  C_DATA_WIDTH_1    -1 downto 0))) := init_axilite_if_signals(C_ADDR_WIDTH_1, C_DATA_WIDTH_1);


  signal axilite_if_2       : t_axilite_if( write_address_channel(  awaddr( C_ADDR_WIDTH_2    -1 downto 0)),
                                            write_data_channel(     wdata(  C_DATA_WIDTH_2    -1 downto 0),
                                                                    wstrb(( C_DATA_WIDTH_2/8) -1 downto 0)),
                                            read_address_channel(   araddr( C_ADDR_WIDTH_2    -1 downto 0)),
                                            read_data_channel(      rdata(  C_DATA_WIDTH_2    -1 downto 0))) := init_axilite_if_signals(C_ADDR_WIDTH_2, C_DATA_WIDTH_2);
begin
  -----------------------------
  -- Instantiate Testharness
  -----------------------------
  i_axilite_test_harness : entity bitvis_vip_axilite.test_harness(struct_simple)
      generic map(
        C_DATA_WIDTH_1  => C_DATA_WIDTH_1,
        C_ADDR_WIDTH_1  => C_ADDR_WIDTH_1,
        C_DATA_WIDTH_2  => C_DATA_WIDTH_2,
        C_ADDR_WIDTH_2  => C_ADDR_WIDTH_2
      )
      port map(
        clk          => clk,
        areset       => areset,
        axilite_if_1 => axilite_if_1,
        axilite_if_2 => axilite_if_2
      );


  -- Set up clock generator
  p_clock: clock_generator(clk, clock_ena, C_CLK_PERIOD, "Axilite CLK");

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    -- BFM config
    variable axilite_bfm_config   : t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;
    constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;

    -- overload for this testbench
    procedure axilite_write (
      signal axilite_if   : inout t_axilite_if;
      addr_value          : in unsigned;
      data_value          : in std_logic_vector
      ) is
    begin
      axilite_write(addr_value, data_value, "", clk, axilite_if, C_SCOPE, shared_msg_id_panel, axilite_bfm_config);
    end;

    -- overload for this testbench
    procedure axilite_write (
      signal axilite_if   : inout t_axilite_if;
      addr_value          : in unsigned;
      data_value          : in std_logic_vector;
      byte_enable         : in std_logic_vector
      ) is
    begin
      axilite_write(addr_value, data_value, byte_enable, "", clk, axilite_if, C_SCOPE, shared_msg_id_panel, axilite_bfm_config);
    end;

    -- overload for this testbench
    procedure axilite_read (
      signal axilite_if   : inout t_axilite_if;
      addr_value          : in unsigned;
      data_value          : in std_logic_vector
      ) is
      -- Normalize to the DUT addr_value/data widths
      variable v_normalized_data  : std_logic_vector(axilite_if.read_data_channel.rdata'length-1 downto 0) :=
        normalize_and_check(data_value, axilite_if.read_data_channel.rdata, ALLOW_NARROWER, "data", "axilite_if.read_data_channel.rdata", "");
    begin
      axilite_read(addr_value, v_normalized_data, "", clk, axilite_if, C_SCOPE, shared_msg_id_panel,axilite_bfm_config);
    end;

    -- axilite read and return read data
    impure function axilite_read(
      interface   : natural range 1 to 2;
      addr_value  : unsigned
    ) return std_logic_vector is
      variable v_read_data_if_1  : std_logic_vector(C_DATA_WIDTH_1-1 downto 0) := (others => '0');
      variable v_read_data_if_2  : std_logic_vector(C_DATA_WIDTH_2-1 downto 0) := (others => '0');
    begin
      case interface is
        when 1 =>
          axilite_read(addr_value, v_read_data_if_1, "", clk, axilite_if_1, C_SCOPE, shared_msg_id_panel, axilite_bfm_config);
          return v_read_data_if_1;
        when others => -- 2
          axilite_read(addr_value, v_read_data_if_2, "", clk, axilite_if_2, C_SCOPE, shared_msg_id_panel, axilite_bfm_config);
          return v_read_data_if_2;
      end case;
    end function;

    -- overload for this testbench
    procedure axilite_check (
      signal axilite_if    : inout t_axilite_if;
      addr_value           : in unsigned;
      data_exp             : in std_logic_vector
      ) is
    begin
      axilite_check(addr_value, data_exp, "", clk, axilite_if, ERROR, C_SCOPE, shared_msg_id_panel, axilite_bfm_config);
    end;


    variable v_irq_mask     : std_logic_vector(7 downto 0);
    variable v_irq_mask_inv : std_logic_vector(7 downto 0);
    variable i              : integer;
    variable v_alert_num_mismatch : boolean := false;
    -- returned read data
    variable v_read_data_1  : std_logic_vector(C_DATA_WIDTH_1-1 downto 0);
    variable v_read_data_2  : std_logic_vector(C_DATA_WIDTH_2-1 downto 0);

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other run.py provides separate test case
    -- directories through the runner_cfg generic (<root>/vunit_out/tests/<test case
    -- name>). When not using run.py the default path is the current directory
    -- (<root>/vunit_out/<simulator>). These directories are used by VUnit
    -- itself and these lines make sure that BVUL do to.
    set_log_file_name(join(output_path(runner_cfg), "_Log.txt"));
    set_alert_file_name(join(output_path(runner_cfg), "_Alert.txt"));

    -- Setup the VUnit runner with the input configuration.
    test_runner_setup(runner, runner_cfg);

    -- The default behavior for VUnit is to stop the simulation on a failing
    -- check when running from script but keep on running when running without
    -- script. The rationale for this and how you can change that behavior is
    -- described at the bottom of this file (see Stopping the Simulation on
    -- Failing Checks). The following if statement causes BVUL checks to behave
    -- in the same way.
    if not active_python_runner(runner_cfg) then
      set_alert_stop_limit(ERROR, 0);
    end if;

    -- override default config with settings for this testbench
    axilite_bfm_config.clock_period             := C_CLK_PERIOD;
    axilite_bfm_config.max_wait_cycles          := 10;
    axilite_bfm_config.max_wait_cycles_severity := ERROR;
    axilite_bfm_config.num_aw_pipe_stages       := 2;
    axilite_bfm_config.num_w_pipe_stages        := 1;
    axilite_bfm_config.num_ar_pipe_stages       := 2;
    axilite_bfm_config.num_r_pipe_stages        := 1;
    axilite_bfm_config.num_b_pipe_stages        := 2;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ALL_MESSAGES);
    --enable_log_msg(ID_LOG_HDR);

    log(ID_LOG_HDR, "Start Simulation of TB for AXILITE 1", C_SCOPE);
    ------------------------------------------------------------
    clock_ena <= true; -- the axilite_reset routine assumes the clock is running
    gen_pulse(areset, 10*C_CLK_PERIOD, "Pulsing reset for 10 clock periods");

    log("Do some axilite writes");
    -- write some data; the current axislave isn't very implemented - doesn't
    -- have FIFO, and just has one RW slave register at addr_valueess 0x6000
    axilite_write(axilite_if_1, x"0000", x"5555");
    axilite_write(axilite_if_1, x"1000", x"befbeef"); -- op0
    axilite_write(axilite_if_1, x"2000", x"efbeef");  -- op1
    axilite_write(axilite_if_1, x"3000", x"beef");    -- op2
    axilite_write(axilite_if_1, x"6000", x"54321");   -- rw reg

    v_read_data_1 := axilite_read(C_INTERFACE_1, x"3000");
    v_read_data_1 := axilite_read(C_INTERFACE_1, x"6000");
    check_value(v_read_data_1, x"54321", error, "verifying read data on interface 1.");

    log("Check the written data");
    -- check that is was correctly written (calls axilite_read)
    axilite_check(axilite_if_1, x"0006000", x"54321");
    axilite_write(axilite_if_1, x"0006000", x"abba1972");
    axilite_check(axilite_if_1, x"0006000", x"abba1972");

    -- verify that a warning arises if the data is not what is expected
    increment_expected_alerts(WARNING, 1);
    axilite_check(x"0006000", x"00000000", "", clk, axilite_if_1, WARNING, C_SCOPE, shared_msg_id_panel, axilite_bfm_config);

    -- Test byte_enable functionality
    log("Checking write with byte_enable");
    axilite_write(axilite_if_1, x"0006000", x"0");
    axilite_write(axilite_if_1, x"0006000", x"abba1972","0011");
    axilite_check(axilite_if_1, x"0006000", x"00001972");
    axilite_write(axilite_if_1, x"0006000", x"0");
    axilite_write(axilite_if_1, x"0006000", x"abba1972","1100");
    axilite_check(axilite_if_1, x"0006000", x"abba0000");


    log(ID_LOG_HDR, "Start Simulation of TB for AXILITE 2", C_SCOPE);
    ------------------------------------------------------------
    -- Change config to default
    --axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;


    log("Do some axilite writes");
    -- write some data; the current axislave isn't very implemented - doesn't
    -- have FIFO, and just has one RW slave register at addr_valueess 0x6000
    axilite_write(axilite_if_2, x"0000", x"5555");
    axilite_write(axilite_if_2, x"0010", x"befbeef"); -- op0
    axilite_write(axilite_if_2, x"0020", x"efbeef");  -- op1
    axilite_write(axilite_if_2, x"0030", x"beef");    -- op2
    axilite_write(axilite_if_2, x"0040", x"54321");   -- op3
    axilite_write(axilite_if_2, x"0060", x"54321");   -- rw reg

    v_read_data_2 := axilite_read(C_INTERFACE_2, x"0030");
    v_read_data_2 := axilite_read(C_INTERFACE_2, x"0040");
    v_read_data_2 := axilite_read(C_INTERFACE_2, x"0060");
    check_value(v_read_data_2, x"54321", error, "verifying read data on interface 2.");


    log("Check the written data");
    -- check that is was correctly written
    axilite_check(axilite_if_2, x"0000", x"5555");
    axilite_check(axilite_if_2, x"0010", x"befbeef");
    axilite_check(axilite_if_2, x"0020", x"efbeef");
    axilite_check(axilite_if_2, x"0030", x"beef");
    axilite_check(axilite_if_2, x"0040", x"54321");
    axilite_write(axilite_if_2, x"0000040", x"abba1972");
    axilite_check(axilite_if_2, x"0000040", x"abba1972");

    -- verify that a warning arises if the data is not what is expected
    increment_expected_alerts(WARNING, 1);
    axilite_check(x"0000040", x"00000000", "", clk, axilite_if_2, WARNING, C_SCOPE, shared_msg_id_panel, axilite_bfm_config);

    -- Test byte_enable functionality
    log("Checking write with byte_enable");

    axilite_write(axilite_if_2, x"0000040", x"0");
    axilite_write(axilite_if_2, x"0000040", x"afaf1191","00000011");
    axilite_check(axilite_if_2, x"0000040", x"00001191");
    axilite_write(axilite_if_2, x"0000040", x"0");
    axilite_write(axilite_if_2, x"0000040", x"afaf1191","00001100");
    axilite_check(axilite_if_2, x"0000040", x"afaf0000");


    -- Test expected response.
    axilite_bfm_config.expected_response            := SLVERR; -- Will always be OKAY in DUT.
    axilite_bfm_config.expected_response_severity   := TB_WARNING;
    increment_expected_alerts(TB_WARNING, 1);
    axilite_write(axilite_if_2, x"0000040", x"0");

    axilite_bfm_config.expected_response            := DECERR; -- Will always be OKAY in DUT.
    increment_expected_alerts(TB_WARNING, 1);
    axilite_write(axilite_if_2, x"0000040", x"afaf1191","00001100");
    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    -- allow some time for completion
    for i in 0 to 10 loop
      wait until rising_edge(clk);
    end loop;
    report_alert_counters(VOID); -- Report final counters and print conclusion for simulation (Success/Fail)
    log("SIMULATION COMPLETED");

    -- Cleanup VUnit. The UVVM-Util error status is imported into VUnit at this
    -- point. This is neccessary when the UVVM-Util alert stop limit is set such that
    -- UVVM-Util doesn't stop on the first error. In that case VUnit has no way of
    -- knowing the error status unless you tell it.
    for alert_level in NOTE to t_alert_level'right loop
      if alert_level /= MANUAL_CHECK and get_alert_counter(alert_level, REGARD) /= get_alert_counter(alert_level, EXPECT) then
        v_alert_num_mismatch := true;
      end if;
    end loop;

    test_runner_cleanup(runner, v_alert_num_mismatch);
    wait;

  end process p_main;
end func;