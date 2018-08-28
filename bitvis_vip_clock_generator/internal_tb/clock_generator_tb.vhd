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
use IEEE.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_run_context;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

-- Test case entity
entity clock_generator_tb is
  generic (
    -- This generic is used to configure the testbench from run.py, e.g. what
    -- test case to run. The default value is used when not running from script
    -- and in that case all test cases are run.
    runner_cfg : string := runner_cfg_default);
end entity;

-- Test case architecture
architecture func of clock_generator_tb is

  constant C_SCOPE        : string := "CLOCK_GENERATOR_VVC_TB";

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.test_harness;

  i_ti_uvvm_engine  : entity uvvm_vvc_framework.ti_uvvm_engine;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process

    variable v_is_ok              : boolean := false;
    variable v_timestamp          : time;
    variable v_alert_num_mismatch : boolean := false;

    alias clk_1 is << signal i_test_harness.clk_1 : std_logic >>;
    alias clk_2 is << signal i_test_harness.clk_2 : std_logic >>;
    alias clk_3 is << signal i_test_harness.clk_3 : std_logic >>;

      -- Check clock periods in clock_generator
    procedure check_clock_period_and_high_time(
      signal   clock               : std_logic;
      constant clk_period          : time;
      constant clk_high_time       : time;
      constant num_of_cycles       : positive
      ) is
      variable v_timestamp : time;
    begin
      -- Align with clock
      await_value(clock, '0', 0 ns, 20*clk_period, error, "Clock check, await falling edge", C_SCOPE, ID_NEVER);
      await_value(clock, '1', 0 ns, 20*clk_period, error, "Clock check, await rising edge", C_SCOPE, ID_NEVER);
      -- Check clock period (high and low duration)
      for i in 0 to num_of_cycles-1 loop
        v_timestamp := now;
        wait for clk_high_time;
        check_stable(clock, now-v_timestamp, error, "Clock check, check stable high time", C_SCOPE, ID_NEVER);
        await_value(clock, '0', 0 ns, clk_period, error, "Clock check, await falling edge", C_SCOPE, ID_NEVER);
        check_value(now-v_timestamp, clk_high_time, error, "Clock check, check clock high time", C_SCOPE, ID_NEVER);
        wait for clk_period - clk_high_time;
        check_stable(clock, clk_period - clk_high_time, error, "Clock check, check stable low time", C_SCOPE, ID_NEVER);
        await_value(clock, '1', 0 ns, clk_period, error, "Clock check, await rising edge", C_SCOPE, ID_NEVER);
        check_value(now-v_timestamp, clk_period, error, "Clock check, check clock period", C_SCOPE, ID_NEVER);
      end loop;
      log(ID_SEQUENCER, "Check of clock period and clock high time PASSED.", C_SCOPE);
    end procedure;

    procedure check_clock_not_running(
      signal   clock      : std_logic;
      constant clk_period : time
    ) is
      variable v_timestamp : time;
    begin
      v_timestamp := now;
      check_value(clock, '0', error, "Clock not runnig check, check that clock line is low", C_SCOPE, ID_NEVER);
      wait for clk_period*10;
      check_stable(clock, now-v_timestamp, error, "Clock not runnig check, check that clock line is not active", C_SCOPE, ID_NEVER);
      log(ID_SEQUENCER, "Check of clock of clock not running PASSED.", C_SCOPE);
    end procedure;


  begin

    -- Setup the VUnit runner with the input configuration.
    test_runner_setup(runner, runner_cfg);

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other run.py provides separate test case
    -- directories through the runner_cfg generic (<root>/vunit_out/tests/<test case
    -- name>). When not using run.py the default path is the current directory
    -- (<root>/vunit_out/<simulator>). These directories are used by VUnit
    -- itself and these lines make sure that BVUL do to.
    set_log_file_name(join(output_path(runner_cfg), "_Log.txt"));
    set_alert_file_name(join(output_path(runner_cfg), "_Alert.txt"));

    -- The default behavior for VUnit is to stop the simulation on a failing
    -- check when running from script but keep on running when running without
    -- script. The rationale for this and how you can change that behavior is
    -- described at the bottom of this file (see Stopping the Simulation on
    -- Failing Checks). The following if statement causes BVUL checks to behave
    -- in the same way.
    if not active_python_runner(runner_cfg) then
      set_alert_stop_limit(ERROR, 0);
    end if;

    await_uvvm_initialization(VOID);

    set_alert_stop_limit(TB_ERROR,4);

    --disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_BFM);
    enable_log_msg(ID_BFM_POLL);

    --disable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
    enable_log_msg(VVC_BROADCAST, ID_BFM);
    enable_log_msg(VVC_BROADCAST, ID_BFM_POLL);

    --disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    --enable_log_msg(SBI_VVCT, 1, ID_BFM);
    --enable_log_msg(SBI_VVCT, 1, ID_BFM_POLL);
    --
    --disable_log_msg(SBI_VVCT, 2, ALL_MESSAGES);
    --enable_log_msg(SBI_VVCT, 2, ID_BFM);
    --enable_log_msg(SBI_VVCT, 2, ID_BFM_POLL);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    log(ID_LOG_HDR_LARGE, "Sequencer starting", C_SCOPE);

    log(ID_LOG_HDR, "Check that clk_1, clk_2 and clk_3 is not running", C_SCOPE);
    check_value(clk_1, '0', error, "Check that clock 1 line is low");
    check_value(clk_2, '0', error, "Check that clock 2 line is low");
    check_value(clk_3, '0', error, "Check that clock 3 line is low");
    check_clock_not_running(clk_1, 10 ns);
    check_clock_not_running(clk_2, 20 ns);
    check_clock_not_running(clk_3, 40 ns);

    log(ID_LOG_HDR, "Activate clock 1", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock 1");
    await_completion(CLOCK_GENERATOR_VVCT, 1, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_1, 10 ns, 5 ns, 5);

    log(ID_LOG_HDR, "Deactivate clock 1", C_SCOPE);
    stop_clock(CLOCK_GENERATOR_VVCT, 1, "Stop clock 1");
    await_completion(CLOCK_GENERATOR_VVCT, 1, 1 us, "Await execution");
    check_clock_not_running(clk_1, 10 ns);

    log(ID_LOG_HDR, "Change clock period and clock high time of clock 1", C_SCOPE);
    set_clock_period(CLOCK_GENERATOR_VVCT, 1, 50 ns, "Change clock period to 50 ns");
    await_completion(CLOCK_GENERATOR_VVCT, 1, 1 us, "Await execution");
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 1, 35 ns, "Change clock high time to 35 ns");
    await_completion(CLOCK_GENERATOR_VVCT, 1, 1 us, "Await execution");

    log(ID_LOG_HDR, "Activate clock 1", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock 1");
    await_completion(CLOCK_GENERATOR_VVCT, 1, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_1, 50 ns, 35 ns, 5);

    log(ID_LOG_HDR, "Activate clock 2", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_2, 20 ns, 12 ns, 5);

    log(ID_LOG_HDR, "Deactivate clock 2", C_SCOPE);
    stop_clock(CLOCK_GENERATOR_VVCT, 2, "Stop clock 2");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_not_running(clk_2, 20 ns);

    log(ID_LOG_HDR, "Change clock period and clock high time of clock 2", C_SCOPE);
    set_clock_period(CLOCK_GENERATOR_VVCT, 2, 100 ns, "Set clock period to 100 ns");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 50 ns, "Set clock high time to 50 ns");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");

    log(ID_LOG_HDR, "Activate clock 2", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_2, 100 ns, 50 ns, 5);

    log(ID_LOG_HDR, "Deactivate clock 2", C_SCOPE);
    stop_clock(CLOCK_GENERATOR_VVCT, 2, "Stop clock 2");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_not_running(clk_2, 100 ns);

    log(ID_LOG_HDR, "Change clock high time of clock 2", C_SCOPE);
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 1 ns, "Set clock high time to 1 ns");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");

    log(ID_LOG_HDR, "Activate clock 2", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_2, 100 ns, 1 ns, 5);

    log(ID_LOG_HDR, "Change clock high time of clock 2", C_SCOPE);
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 99 ns, "Set clock high time to 99 ns");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_2, 100 ns, 99 ns, 5);

    log(ID_LOG_HDR, "Change clock period of clock 2", C_SCOPE);
    set_clock_period(CLOCK_GENERATOR_VVCT, 2, 40 ns, "Set clock period to 40 ns");
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 39.6 ns, "Set clock high time to 39.6 ns");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_2, 40 ns, 39.6 ns, 5);

    log(ID_LOG_HDR, "Deactivate clock 2", C_SCOPE);
    stop_clock(CLOCK_GENERATOR_VVCT, 2, "Stop clock 2");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_not_running(clk_2, 100 ns);

    log(ID_LOG_HDR, "Change clock period of clock 2", C_SCOPE);
    set_clock_period(CLOCK_GENERATOR_VVCT, 2, 70 ns, "Set clock period to 40 ns");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");

    log(ID_LOG_HDR, "Activate clock 2", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_2, 70 ns, 39.6 ns, 5);

    log(ID_LOG_HDR, "Set clock 2 high time to same as clock period, expect tb_error", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    increment_expected_alerts(tb_error, 1);
    check_clock_period_and_high_time(clk_2, 70 ns, 39.6 ns, 5);

    log(ID_LOG_HDR, "Activate clock 3", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 3, "Start clock 3");
    await_completion(CLOCK_GENERATOR_VVCT, 2, 1 us, "Await execution");
    check_clock_period_and_high_time(clk_3, 40 ns, 12 ns, 5);


    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;  -- to allow some time for completion
    report_alert_counters(VOID);
    log(ID_LOG_HDR, "SIMULATION COMPLETED");

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
