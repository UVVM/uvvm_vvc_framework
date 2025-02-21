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
-- Inspired by similar functionality in SystemVerilog and OSVVM.
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.string_methods_pkg.all;
use work.global_signals_and_shared_variables_pkg.all;
use work.methods_pkg.all;

package rand_pkg is

  ------------------------------------------------------------
  -- Types
  ------------------------------------------------------------
  type t_rand_dist is (UNIFORM, GAUSSIAN);
  type t_value_specifier is (ONLY, ADD, EXCL);
  type t_uniqueness is (UNIQUE, NON_UNIQUE);
  type t_weight_mode is (NA, COMBINED_WEIGHT, INDIVIDUAL_WEIGHT);
  type t_cyclic is (CYCLIC, NON_CYCLIC);

  type t_val_weight_int is record
    value  : integer;
    weight : natural;
  end record;
  type t_range_weight_int is record
    min_value : integer;
    max_value : integer;
    weight    : natural;
  end record;
  type t_range_weight_mode_int is record
    min_value : integer;
    max_value : integer;
    weight    : natural;
    mode      : t_weight_mode;
  end record;

  type t_val_weight_real is record
    value  : real;
    weight : natural;
  end record;
  type t_range_weight_real is record
    min_value : real;
    max_value : real;
    weight    : natural;
  end record;
  type t_range_weight_mode_real is record
    min_value : real;
    max_value : real;
    weight    : natural;
    mode      : t_weight_mode;
  end record;

  type t_val_weight_time is record
    value  : time;
    weight : natural;
  end record;
  type t_range_weight_time is record
    min_value : time;
    max_value : time;
    weight    : natural;
  end record;
  type t_range_weight_mode_time is record
    min_value : time;
    max_value : time;
    weight    : natural;
    mode      : t_weight_mode;
  end record;

  type t_val_weight_int_vec is array (natural range <>) of t_val_weight_int;
  type t_range_weight_int_vec is array (natural range <>) of t_range_weight_int;
  type t_range_weight_mode_int_vec is array (natural range <>) of t_range_weight_mode_int;

  type t_val_weight_real_vec is array (natural range <>) of t_val_weight_real;
  type t_range_weight_real_vec is array (natural range <>) of t_range_weight_real;
  type t_range_weight_mode_real_vec is array (natural range <>) of t_range_weight_mode_real;

  type t_val_weight_time_vec is array (natural range <>) of t_val_weight_time;
  type t_range_weight_time_vec is array (natural range <>) of t_range_weight_time;
  type t_range_weight_mode_time_vec is array (natural range <>) of t_range_weight_mode_time;

  ------------------------------------------------------------
  -- Base procedures
  ------------------------------------------------------------
  alias random_uniform is random[integer, integer, positive, positive, integer];
  alias random_uniform is random[real, real, positive, positive, real];
  alias random_uniform is random[time, time, positive, positive, time];

  -- Returns a real pseudo-random number with Gaussian distribution.
  -- It uses the Marsaglia polar method to generate a normally distributed
  -- random number from uniformly distributed random numbers.
  procedure gaussian(
    constant mean          : in real;
    constant std_deviation : in real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real);

  -- Returns an integer pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in integer;
    constant max_value     : in integer;
    constant mean          : in real;
    constant std_deviation : in real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout integer);

  -- Returns a real pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in real;
    constant max_value     : in real;
    constant mean          : in real;
    constant std_deviation : in real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real);

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_rand is protected

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_name(
      constant name : in string);

    impure function get_name(
      constant VOID : t_void)
    return string;

    procedure set_scope(
      constant scope : in string);

    impure function get_scope(
      constant VOID : t_void)
    return string;

    procedure set_rand_dist(
      constant rand_dist    : in t_rand_dist;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_rand_dist(
      constant VOID : t_void)
    return t_rand_dist;

    procedure set_rand_dist_mean(
      constant mean         : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_rand_dist_mean(
      constant VOID : t_void)
    return real;

    procedure clear_rand_dist_mean(
      constant VOID : in t_void);

    procedure clear_rand_dist_mean(
      constant msg_id_panel : in t_msg_id_panel);

    procedure set_rand_dist_std_deviation(
      constant std_deviation : in real;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_rand_dist_std_deviation(
      constant VOID : t_void)
    return real;

    procedure clear_rand_dist_std_deviation(
      constant VOID : in t_void);

    procedure clear_rand_dist_std_deviation(
      constant msg_id_panel : in t_msg_id_panel);

    procedure set_range_weight_default_mode(
      constant mode         : in t_weight_mode;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_range_weight_default_mode(
      constant VOID : t_void)
    return t_weight_mode;

    procedure clear_rand_cyclic(
      constant VOID : in t_void);

    procedure clear_rand_cyclic(
      constant msg_id_panel : in t_msg_id_panel);

    procedure report_config(
      constant VOID : in t_void);

    ------------------------------------------------------------
    -- Randomization seeds
    ------------------------------------------------------------
    procedure set_rand_seeds(
      constant str : in string);

    procedure set_rand_seeds(
      constant seed1 : in positive;
      constant seed2 : in positive);

    procedure set_rand_seeds(
      constant seeds : in t_positive_vector(0 to 1));

    procedure get_rand_seeds(
      variable seed1 : out positive;
      variable seed2 : out positive);

    impure function get_rand_seeds(
      constant VOID : t_void)
    return t_positive_vector;

    ------------------------------------------------------------------------------------------------------------------------------
    -- ***************************************************************************************************************************
    -- Single-method rand() implementation
    -- ***************************************************************************************************************************
    ------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------
    -- Random integer
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier    : t_value_specifier;
      constant value        : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier1   : t_value_specifier;
      constant value1       : integer;
      constant specifier2   : t_value_specifier;
      constant value2       : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand(
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant value1         : integer;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand(
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : integer_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call  : string         := "")
    return integer;

    ------------------------------------------------------------
    -- Random real
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant specifier     : t_value_specifier;
      constant set_of_values : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value    : real;
      constant max_value    : real;
      constant specifier    : t_value_specifier;
      constant value        : real;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant specifier     : t_value_specifier;
      constant set_of_values : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value      : real;
      constant max_value      : real;
      constant specifier1     : t_value_specifier;
      constant value1         : real;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : real_vector;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return real;

    impure function rand(
      constant min_value    : real;
      constant max_value    : real;
      constant specifier1   : t_value_specifier;
      constant value1       : real;
      constant specifier2   : t_value_specifier;
      constant value2       : real;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real;

    impure function rand(
      constant min_value      : real;
      constant max_value      : real;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : real_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : real_vector;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call  : string         := "")
    return real;

    ------------------------------------------------------------
    -- Random time
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant specifier     : t_value_specifier;
      constant set_of_values : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value    : time;
      constant max_value    : time;
      constant specifier    : t_value_specifier;
      constant value        : time;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant specifier     : t_value_specifier;
      constant set_of_values : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value      : time;
      constant max_value      : time;
      constant specifier1     : t_value_specifier;
      constant value1         : time;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : time_vector;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return time;

    impure function rand(
      constant min_value    : time;
      constant max_value    : time;
      constant specifier1   : t_value_specifier;
      constant value1       : time;
      constant specifier2   : t_value_specifier;
      constant value2       : time;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time;

    impure function rand(
      constant min_value      : time;
      constant max_value      : time;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : time_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : time_vector;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call  : string         := "")
    return time;

    ------------------------------------------------------------
    -- Random integer_vector
    ------------------------------------------------------------
    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier    : t_value_specifier;
      constant value        : integer;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant length         : positive;
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant value1         : integer;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier1   : t_value_specifier;
      constant value1       : integer;
      constant specifier2   : t_value_specifier;
      constant value2       : integer;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant length         : positive;
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : integer_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    ------------------------------------------------------------
    -- Random real_vector
    ------------------------------------------------------------
    impure function rand(
      constant length       : positive;
      constant min_value    : real;
      constant max_value    : real;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : real;
      constant max_value    : real;
      constant specifier    : t_value_specifier;
      constant value        : real;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant specifier     : t_value_specifier;
      constant set_of_values : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant length         : positive;
      constant min_value      : real;
      constant max_value      : real;
      constant specifier1     : t_value_specifier;
      constant value1         : real;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : real_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : real;
      constant max_value    : real;
      constant specifier1   : t_value_specifier;
      constant value1       : real;
      constant specifier2   : t_value_specifier;
      constant value2       : real;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant length         : positive;
      constant min_value      : real;
      constant max_value      : real;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : real_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : real_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    ------------------------------------------------------------
    -- Random time_vector
    ------------------------------------------------------------
    impure function rand(
      constant length       : positive;
      constant min_value    : time;
      constant max_value    : time;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : time;
      constant max_value    : time;
      constant specifier    : t_value_specifier;
      constant value        : time;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant specifier     : t_value_specifier;
      constant set_of_values : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant length         : positive;
      constant min_value      : time;
      constant max_value      : time;
      constant specifier1     : t_value_specifier;
      constant value1         : time;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : time_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : time;
      constant max_value    : time;
      constant specifier1   : t_value_specifier;
      constant value1       : time;
      constant specifier2   : t_value_specifier;
      constant value2       : time;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant length         : positive;
      constant min_value      : time;
      constant max_value      : time;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : time_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : time_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    ------------------------------------------------------------
    -- Random unsigned
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant min_value    : unsigned;
      constant max_value    : unsigned;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : unsigned;
      constant max_value     : unsigned;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant specifier    : t_value_specifier;
      constant value        : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant specifier     : t_value_specifier;
      constant set_of_values : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length         : positive;
      constant min_value      : natural;
      constant max_value      : natural;
      constant specifier1     : t_value_specifier;
      constant value1         : natural;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : t_natural_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant specifier1   : t_value_specifier;
      constant value1       : natural;
      constant specifier2   : t_value_specifier;
      constant value2       : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length         : positive;
      constant min_value      : natural;
      constant max_value      : natural;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : t_natural_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : t_natural_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    ------------------------------------------------------------
    -- Random signed
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant min_value    : signed;
      constant max_value    : signed;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : signed;
      constant max_value     : signed;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier    : t_value_specifier;
      constant value        : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length         : positive;
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant value1         : integer;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier1   : t_value_specifier;
      constant value1       : integer;
      constant specifier2   : t_value_specifier;
      constant value2       : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length         : positive;
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : integer_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    ------------------------------------------------------------
    -- Random std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand(
      constant length       : positive;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant min_value    : std_logic_vector;
      constant max_value    : std_logic_vector;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : std_logic_vector;
      constant max_value     : std_logic_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant specifier    : t_value_specifier;
      constant value        : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant specifier     : t_value_specifier;
      constant set_of_values : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length         : positive;
      constant min_value      : natural;
      constant max_value      : natural;
      constant specifier1     : t_value_specifier;
      constant value1         : natural;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : t_natural_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant specifier1   : t_value_specifier;
      constant value1       : natural;
      constant specifier2   : t_value_specifier;
      constant value2       : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length         : positive;
      constant min_value      : natural;
      constant max_value      : natural;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : t_natural_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : t_natural_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    ------------------------------------------------------------
    -- Random std_logic & boolean
    ------------------------------------------------------------
    impure function rand(
      constant VOID : t_void)
    return std_logic;

    impure function rand(
      constant msg_id_panel : t_msg_id_panel)
    return std_logic;

    impure function rand(
      constant VOID : t_void)
    return boolean;

    impure function rand(
      constant msg_id_panel : t_msg_id_panel)
    return boolean;

    ------------------------------------------------------------
    -- Random weighted integer
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weighted_vector : t_val_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand_range_weight(
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand_range_weight_mode(
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call   : string         := "")
    return integer;

    ------------------------------------------------------------
    -- Random weighted real
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weighted_vector : t_val_weight_real_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return real;

    impure function rand_range_weight(
      constant weighted_vector : t_range_weight_real_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return real;

    impure function rand_range_weight_mode(
      constant weighted_vector : t_range_weight_mode_real_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call   : string         := "")
    return real;

    ------------------------------------------------------------
    -- Random weighted time
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weighted_vector : t_val_weight_time_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return time;

    impure function rand_range_weight(
      constant weighted_vector : t_range_weight_time_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return time;

    impure function rand_range_weight_mode(
      constant weighted_vector : t_range_weight_mode_time_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call   : string         := "")
    return time;

    ------------------------------------------------------------
    -- Random weighted unsigned
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length          : positive;
      constant weighted_vector : t_val_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    ------------------------------------------------------------
    -- Random weighted signed
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length          : positive;
      constant weighted_vector : t_val_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    ------------------------------------------------------------
    -- Random weighted std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length          : positive;
      constant weighted_vector : t_val_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    ------------------------------------------------------------------------------------------------------------------------------
    -- ***************************************************************************************************************************
    -- Multi-method rand() implementation
    -- ***************************************************************************************************************************
    ------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------
    -- Integer constraints
    ------------------------------------------------------------
    procedure add_range(
      constant min_value    : in integer;
      constant max_value    : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val(
      constant set_of_values : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val(
      constant set_of_values : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val_weight(
      constant value        : in integer;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_range_weight(
      constant min_value    : in integer;
      constant max_value    : in integer;
      constant weight       : in natural;
      constant mode         : in t_weight_mode  := NA;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Real constraints
    ------------------------------------------------------------
    procedure add_range_real(
      constant min_value    : in real;
      constant max_value    : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val_real(
      constant value        : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val_real(
      constant set_of_values : in real_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val_real(
      constant value        : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val_real(
      constant set_of_values : in real_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val_weight_real(
      constant value        : in real;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_range_weight_real(
      constant min_value    : in real;
      constant max_value    : in real;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Time constraints
    ------------------------------------------------------------
    procedure add_range_time(
      constant min_value    : in time;
      constant max_value    : in time;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val_time(
      constant value        : in time;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val_time(
      constant set_of_values : in time_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val_time(
      constant value        : in time;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val_time(
      constant set_of_values : in time_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val_weight_time(
      constant value        : in time;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_range_weight_time(
      constant min_value    : in time;
      constant max_value    : in time;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Unsigned constraints
    ------------------------------------------------------------
    procedure add_range_unsigned(
      constant min_value    : in unsigned;
      constant max_value    : in unsigned;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Signed constraints
    ------------------------------------------------------------
    procedure add_range_signed(
      constant min_value    : in signed;
      constant max_value    : in signed;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_cyclic_mode(
      constant cyclic_mode  : in t_cyclic;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure set_uniqueness(
      constant uniqueness   : in t_uniqueness;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure clear_constraints(
      constant VOID : in t_void);

    procedure clear_constraints(
      constant msg_id_panel  : in t_msg_id_panel;
      constant ext_proc_call : in string := "");

    procedure clear_config(
      constant VOID : in t_void);

    procedure clear_config(
      constant msg_id_panel : in t_msg_id_panel);

    ------------------------------------------------------------
    -- Randomization
    ------------------------------------------------------------
    impure function randm(
      constant VOID : t_void)
    return integer;

    impure function randm(
      constant msg_id_panel  : t_msg_id_panel;
      constant ext_proc_call : string := "")
    return integer;

    impure function randm(
      constant VOID : t_void)
    return real;

    impure function randm(
      constant msg_id_panel  : t_msg_id_panel;
      constant ext_proc_call : string := "")
    return real;

    impure function randm(
      constant VOID : t_void)
    return time;

    impure function randm(
      constant msg_id_panel  : t_msg_id_panel;
      constant ext_proc_call : string := "")
    return time;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function randm(
      constant length        : positive;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_type : string         := "unsigned")
    return unsigned;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

  end protected t_rand;

end package rand_pkg;

package body rand_pkg is

  -- This package is used by the random cyclic queue
  package cyclic_queue_pkg is new work.generic_queue_pkg
    generic map(
      t_generic_element        => integer,
      GC_QUEUE_COUNT_MAX       => natural'right,
      GC_QUEUE_COUNT_THRESHOLD => 0);

  use cyclic_queue_pkg.all;

  ------------------------------------------------------------
  -- Internal Types
  ------------------------------------------------------------
  type t_cyclic_list is array (integer range <>) of std_logic;
  type t_cyclic_list_ptr is access t_cyclic_list;

  type t_range_int is record
    min_value : integer;
    max_value : integer;
    range_len : signed(32 downto 0);
  end record;
  type t_range_real is record
    min_value : real;
    max_value : real;
    range_len : real;
  end record;
  type t_range_time is record
    min_value : time;
    max_value : time;
    range_len : time;
  end record;
  type t_range_uns is record
    min_value : unsigned(C_RAND_MM_MAX_LONG_VECTOR_LENGTH - 1 downto 0);
    max_value : unsigned(C_RAND_MM_MAX_LONG_VECTOR_LENGTH - 1 downto 0);
    range_len : unsigned(C_RAND_MM_MAX_LONG_VECTOR_LENGTH downto 0);
  end record;
  type t_range_sig is record
    min_value : signed(C_RAND_MM_MAX_LONG_VECTOR_LENGTH - 1 downto 0);
    max_value : signed(C_RAND_MM_MAX_LONG_VECTOR_LENGTH - 1 downto 0);
    range_len : signed(C_RAND_MM_MAX_LONG_VECTOR_LENGTH downto 0);
  end record;

  type t_range_int_vec is array (natural range <>) of t_range_int;
  type t_range_real_vec is array (natural range <>) of t_range_real;
  type t_range_time_vec is array (natural range <>) of t_range_time;
  type t_range_uns_vec is array (natural range <>) of t_range_uns;
  type t_range_sig_vec is array (natural range <>) of t_range_sig;

  type t_range_int_vec_ptr is access t_range_int_vec;
  type t_range_real_vec_ptr is access t_range_real_vec;
  type t_range_time_vec_ptr is access t_range_time_vec;
  type t_range_uns_vec_ptr is access t_range_uns_vec;
  type t_range_sig_vec_ptr is access t_range_sig_vec;

  type t_integer_vector_ptr is access integer_vector;
  type t_real_vector_ptr is access real_vector;
  type t_time_vector_ptr is access time_vector;

  type t_range_weight_mode_int_vec_ptr is access t_range_weight_mode_int_vec;
  type t_range_weight_mode_real_vec_ptr is access t_range_weight_mode_real_vec;
  type t_range_weight_mode_time_vec_ptr is access t_range_weight_mode_time_vec;

  type t_int_constraints is record
    ran_incl        : t_range_int_vec_ptr;
    val_incl        : t_integer_vector_ptr;
    val_excl        : t_integer_vector_ptr;
    weighted        : t_range_weight_mode_int_vec_ptr;
    weighted_config : boolean;
  end record;

  type t_real_constraints is record
    ran_incl        : t_range_real_vec_ptr;
    val_incl        : t_real_vector_ptr;
    val_excl        : t_real_vector_ptr;
    weighted        : t_range_weight_mode_real_vec_ptr;
    weighted_config : boolean;
  end record;

  type t_time_constraints is record
    ran_incl        : t_range_time_vec_ptr;
    val_incl        : t_time_vector_ptr;
    val_excl        : t_time_vector_ptr;
    weighted        : t_range_weight_mode_time_vec_ptr;
    weighted_config : boolean;
  end record;

  type t_uns_constraints is record
    ran_incl : t_range_uns_vec_ptr;
  end record;

  type t_sig_constraints is record
    ran_incl : t_range_sig_vec_ptr;
  end record;

  -- These subtypes are used to initialize a vector with zero elements
  subtype t_null_integer_vector             is integer_vector(1 to 0);
  subtype t_null_real_vector                is real_vector(1 to 0);
  subtype t_null_time_vector                is time_vector(1 to 0);
  subtype t_null_range_int_vec              is t_range_int_vec(1 to 0);
  subtype t_null_range_weight_mode_int_vec  is t_range_weight_mode_int_vec(1 to 0);
  subtype t_null_range_real_vec             is t_range_real_vec(1 to 0);
  subtype t_null_range_weight_mode_real_vec is t_range_weight_mode_real_vec(1 to 0);
  subtype t_null_range_time_vec             is t_range_time_vec(1 to 0);
  subtype t_null_range_weight_mode_time_vec is t_range_weight_mode_time_vec(1 to 0);
  subtype t_null_range_uns_vec              is t_range_uns_vec(1 to 0);
  subtype t_null_range_sig_vec              is t_range_sig_vec(1 to 0);

  ------------------------------------------------------------
  -- Base procedures
  ------------------------------------------------------------
  -- Returns a real pseudo-random number with Gaussian distribution.
  -- It uses the Marsaglia polar method to generate a normally distributed
  -- random number from uniformly distributed random numbers.
  procedure gaussian(
    constant mean          : in real;
    constant std_deviation : in real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real) is
    variable v_u     : real;
    variable v_v     : real;
    variable v_s     : real;
    variable v_valid : boolean := false;
  begin
    while not (v_valid) loop
      random_uniform(-1.0, 1.0, seed1, seed2, v_u);
      random_uniform(-1.0, 1.0, seed1, seed2, v_v);
      v_s     := v_u * v_u + v_v * v_v;
      v_valid := v_s > 0.0 and v_s < 1.0;
    end loop;
    target := mean + std_deviation * v_u * sqrt((-2.0 * log(v_s)) / v_s);
  end procedure;

  -- Returns an integer pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in integer;
    constant max_value     : in integer;
    constant mean          : in real;
    constant std_deviation : in real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout integer) is
    variable v_rand  : real;
    variable v_valid : boolean := false;
  begin
    if mean < real(min_value) or mean > real(max_value) then
      alert(TB_ERROR, "random_gaussian()=> Mean: " & to_string(mean, 2) & " must be inside min/max range: " & to_string(min_value) & "," & to_string(max_value));
      target := 0;
      return;
    end if;
    while not (v_valid) loop
      gaussian(mean, std_deviation, seed1, seed2, v_rand);
      target  := integer(round(v_rand));
      v_valid := target >= min_value and target <= max_value;
    end loop;
  end procedure;

  -- Returns a real pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in real;
    constant max_value     : in real;
    constant mean          : in real;
    constant std_deviation : in real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real) is
    variable v_valid : boolean := false;
  begin
    if mean < min_value or mean > max_value then
      alert(TB_ERROR, "random_gaussian()=> Mean: " & to_string(mean, 2) & " must be inside min/max range: " & to_string(min_value, 2) & "," & to_string(max_value, 2));
      target := 0.0;
      return;
    end if;
    while not (v_valid) loop
      gaussian(mean, std_deviation, seed1, seed2, target);
      v_valid := target >= min_value and target <= max_value;
    end loop;
  end procedure;

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_rand is protected body
    variable priv_name                    : string(1 to C_RAND_MAX_NAME_LENGTH) := "**unnamed**" & fill_string(NUL, C_RAND_MAX_NAME_LENGTH - 11);
    variable priv_scope                   : string(1 to C_LOG_SCOPE_WIDTH)      := C_TB_SCOPE_DEFAULT & fill_string(NUL, C_LOG_SCOPE_WIDTH - C_TB_SCOPE_DEFAULT'length);
    variable priv_seed1                   : positive                            := C_RAND_INIT_SEED_1;
    variable priv_seed2                   : positive                            := C_RAND_INIT_SEED_2;
    variable priv_rand_dist               : t_rand_dist                         := UNIFORM;
    variable priv_weight_mode             : t_weight_mode                       := COMBINED_WEIGHT;
    variable priv_warned_same_specifier   : boolean                             := false;
    variable priv_warned_simulation_slow  : boolean                             := false;
    variable priv_ret_valid               : boolean                             := true;
    variable priv_cyclic_current_function : line                                := new string'("");
    variable priv_cyclic_list             : t_cyclic_list_ptr                   := NULL;
    variable priv_cyclic_list_num_items   : natural                             := 0;
    variable priv_cyclic_queue            : t_generic_queue;
    variable priv_mean_configured         : boolean                             := false;
    variable priv_std_dev_configured      : boolean                             := false;
    -- Default values for the mean and standard deviation are relative to the given range, i.e. default values below are ignored
    variable priv_mean                    : real                                := 0.0;
    variable priv_std_dev                 : real                                := 0.0;
    -- Multi-method rand() configuration
    variable priv_cyclic_mode             : t_cyclic                            := NON_CYCLIC;
    variable priv_uniqueness              : t_uniqueness                        := NON_UNIQUE;
    variable priv_int_constraints         : t_int_constraints                   := (ran_incl        => new t_null_range_int_vec,
                                                                                    val_incl        => new t_null_integer_vector,
                                                                                    val_excl        => new t_null_integer_vector,
                                                                                    weighted        => new t_null_range_weight_mode_int_vec,
                                                                                    weighted_config => false);
    variable priv_real_constraints        : t_real_constraints                  := (ran_incl        => new t_null_range_real_vec,
                                                                                    val_incl        => new t_null_real_vector,
                                                                                    val_excl        => new t_null_real_vector,
                                                                                    weighted        => new t_null_range_weight_mode_real_vec,
                                                                                    weighted_config => false);
    variable priv_time_constraints        : t_time_constraints                  := (ran_incl        => new t_null_range_time_vec,
                                                                                    val_incl        => new t_null_time_vector,
                                                                                    val_excl        => new t_null_time_vector,
                                                                                    weighted        => new t_null_range_weight_mode_time_vec,
                                                                                    weighted_config => false);
    variable priv_uns_constraints         : t_uns_constraints                   := (ran_incl => new t_null_range_uns_vec);
    variable priv_sig_constraints         : t_sig_constraints                   := (ran_incl => new t_null_range_sig_vec);

    -- The number of attempts for a random value to be generated with exclude constraints is multiplied by this constant
    constant C_NUM_INVALID_TRIES : natural := 10;

    ------------------------------------------------------------
    -- Internal functions and procedures
    ------------------------------------------------------------
    -- Returns the string representation of a real value with the number of
    -- decimals configured in C_RAND_REAL_NUM_DECIMAL_DIGITS in adaptations_pkg.
    -- If there are not any significant digits within the integer part or the
    -- number of decimals, the scientific representation is returned.
    function format_real(
      constant value : real)
    return string is
      constant C_SIGNIFICANT_VALUE : real := abs (value * (10.0 ** C_RAND_REAL_NUM_DECIMAL_DIGITS));
    begin
      if integer(C_SIGNIFICANT_VALUE) > 0 or value = 0.0 then
        return to_string(value, C_RAND_REAL_NUM_DECIMAL_DIGITS);
      else
        return to_string(value);
      end if;
    end function;

    -- Overload
    function format_real(
      constant values : real_vector)
    return string is
      variable v_line   : line;
      variable v_width  : natural;
      variable v_result : string(1 to 2 + -- parentheses
      2 * (values'length - 1) +         -- commas
      32 * values'length);              -- values
    begin
      if values'length = 0 then
        return "";
      else
        write(v_line, '(');
        for i in values'range loop
          write(v_line, format_real(values(i)));
          if (i < values'right) and (values'ascending) then
            write(v_line, string'(", "));
          elsif (i > values'right) and not (values'ascending) then
            write(v_line, string'(", "));
          end if;
        end loop;
        write(v_line, ')');

        v_width                := v_line'length;
        v_result(1 to v_width) := v_line.all;
        DEALLOCATE(v_line);
        return v_result(1 to v_width);
      end if;
    end function;

    -- Returns the string representation of the weight vector, e.g.
    --   (10,30),([20:30],30,COMBINED),(40,50)
    impure function to_string(
      constant weighted_vector : t_range_weight_mode_int_vec)
    return string is
      alias normalized_weighted_vector : t_range_weight_mode_int_vec(0 to weighted_vector'length-1) is weighted_vector;
      variable v_line                  : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in normalized_weighted_vector'range loop
        if normalized_weighted_vector(i).min_value = normalized_weighted_vector(i).max_value then
          write(v_line, '(' & to_string(normalized_weighted_vector(i).min_value) & ',' & to_string(normalized_weighted_vector(i).weight) & ')');
        else
          write(v_line, string'("([") & to_string(normalized_weighted_vector(i).min_value) & ':' & to_string(normalized_weighted_vector(i).max_value) & string'("],") & to_string(normalized_weighted_vector(i).weight));
          if normalized_weighted_vector(i).mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif normalized_weighted_vector(i).mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          elsif priv_weight_mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif priv_weight_mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          end if;
          write(v_line, ')');
        end if;
        if i < normalized_weighted_vector'length - 1 then
          write(v_line, ',');
        end if;
      end loop;
      if v_line /= NULL then
        return return_and_deallocate;
      else
        return "";
      end if;
    end function;

    -- Overload
    impure function to_string(
      constant weighted_vector : t_range_weight_mode_real_vec)
    return string is
      alias normalized_weighted_vector : t_range_weight_mode_real_vec(0 to weighted_vector'length-1) is weighted_vector;
      variable v_line                  : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in normalized_weighted_vector'range loop
        if normalized_weighted_vector(i).min_value = normalized_weighted_vector(i).max_value then
          write(v_line, '(' & format_real(normalized_weighted_vector(i).min_value) & ',' & to_string(normalized_weighted_vector(i).weight) & ')');
        else
          write(v_line, string'("([") & format_real(normalized_weighted_vector(i).min_value) & ':' & format_real(normalized_weighted_vector(i).max_value) & string'("],") & to_string(normalized_weighted_vector(i).weight));
          if normalized_weighted_vector(i).mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif normalized_weighted_vector(i).mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          elsif priv_weight_mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif priv_weight_mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          end if;
          write(v_line, ')');
        end if;
        if i < normalized_weighted_vector'length - 1 then
          write(v_line, ',');
        end if;
      end loop;
      if v_line /= NULL then
        return return_and_deallocate;
      else
        return "";
      end if;
    end function;

    -- Overload
    impure function to_string(
      constant weighted_vector : t_range_weight_mode_time_vec)
    return string is
      alias normalized_weighted_vector : t_range_weight_mode_time_vec(0 to weighted_vector'length-1) is weighted_vector;
      variable v_line                  : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in normalized_weighted_vector'range loop
        if normalized_weighted_vector(i).min_value = normalized_weighted_vector(i).max_value then
          write(v_line, '(' & to_string(normalized_weighted_vector(i).min_value) & ',' & to_string(normalized_weighted_vector(i).weight) & ')');
        else
          write(v_line, string'("([") & to_string(normalized_weighted_vector(i).min_value) & ':' & to_string(normalized_weighted_vector(i).max_value) & string'("],") & to_string(normalized_weighted_vector(i).weight));
          if normalized_weighted_vector(i).mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif normalized_weighted_vector(i).mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          elsif priv_weight_mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif priv_weight_mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          end if;
          write(v_line, ')');
        end if;
        if i < normalized_weighted_vector'length - 1 then
          write(v_line, ',');
        end if;
      end loop;
      if v_line /= NULL then
        return return_and_deallocate;
      else
        return "";
      end if;
    end function;

    -- Returns the string representation of the integer range constraints for randomization
    impure function get_int_range_constraints(
      constant VOID : t_void)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in 0 to priv_int_constraints.ran_incl'length - 1 loop
        write(v_line, '[' & to_string(priv_int_constraints.ran_incl(i).min_value) & ':' & to_string(priv_int_constraints.ran_incl(i).max_value) & ']');
        if i < priv_int_constraints.ran_incl'length - 1 then
          write(v_line, ',');
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    -- Returns the string representation of the real range constraints for randomization
    impure function get_real_range_constraints(
      constant VOID : t_void)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in 0 to priv_real_constraints.ran_incl'length - 1 loop
        write(v_line, '[' & format_real(priv_real_constraints.ran_incl(i).min_value) & ':' & format_real(priv_real_constraints.ran_incl(i).max_value) & ']');
        if i < priv_real_constraints.ran_incl'length - 1 then
          write(v_line, ',');
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    -- Returns the string representation of the time range constraints for randomization
    impure function get_time_range_constraints(
      constant VOID : t_void)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in 0 to priv_time_constraints.ran_incl'length - 1 loop
        write(v_line, '[' & to_string(priv_time_constraints.ran_incl(i).min_value) & ':' & to_string(priv_time_constraints.ran_incl(i).max_value) & ']');
        if i < priv_time_constraints.ran_incl'length - 1 then
          write(v_line, ',');
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    -- Returns the string representation of the unsigned range constraints for randomization
    impure function get_uns_range_constraints(
      constant length : natural)
    return string is
      variable v_len  : natural;
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in 0 to priv_uns_constraints.ran_incl'length - 1 loop
        write(v_line, '[');
        v_len := MAXIMUM(length, find_leftmost(priv_uns_constraints.ran_incl(i).min_value, '1') + 1);
        write(v_line, to_string(priv_uns_constraints.ran_incl(i).min_value(v_len - 1 downto 0), HEX, KEEP_LEADING_0, INCL_RADIX) & ':');
        v_len := MAXIMUM(length, find_leftmost(priv_uns_constraints.ran_incl(i).max_value, '1') + 1);
        write(v_line, to_string(priv_uns_constraints.ran_incl(i).max_value(v_len - 1 downto 0), HEX, KEEP_LEADING_0, INCL_RADIX) & ']');
        if i < priv_uns_constraints.ran_incl'length - 1 then
          write(v_line, string'(", "));
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    -- Returns the string representation of the signed range constraints for randomization
    impure function get_sig_range_constraints(
      constant length : natural)
    return string is
      variable v_len  : natural;
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in 0 to priv_sig_constraints.ran_incl'length - 1 loop
        write(v_line, '[');
        if priv_sig_constraints.ran_incl(i).min_value(priv_sig_constraints.ran_incl(i).min_value'high) /= '1' then
          v_len := MAXIMUM(length, find_leftmost(priv_sig_constraints.ran_incl(i).min_value, '1') + 1);
        elsif length > 1 then
          v_len := MAXIMUM(length, find_leftmost(priv_sig_constraints.ran_incl(i).min_value, '0') + 2);
        else
          v_len := C_RAND_MM_MAX_LONG_VECTOR_LENGTH;
        end if;
        write(v_line, to_string(priv_sig_constraints.ran_incl(i).min_value(v_len - 1 downto 0), HEX, KEEP_LEADING_0, INCL_RADIX) & ':');
        if priv_sig_constraints.ran_incl(i).max_value(priv_sig_constraints.ran_incl(i).max_value'high) /= '1' then
          v_len := MAXIMUM(length, find_leftmost(priv_sig_constraints.ran_incl(i).max_value, '1') + 1);
        elsif length > 1 then
          v_len := MAXIMUM(length, find_leftmost(priv_sig_constraints.ran_incl(i).max_value, '0') + 2);
        else
          v_len := C_RAND_MM_MAX_LONG_VECTOR_LENGTH;
        end if;
        write(v_line, to_string(priv_sig_constraints.ran_incl(i).max_value(v_len - 1 downto 0), HEX, KEEP_LEADING_0, INCL_RADIX) & ']');
        if i < priv_sig_constraints.ran_incl'length - 1 then
          write(v_line, string'(", "));
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    -- Returns the string representation of the mode when it is enabled, otherwise returns an empty string
    function to_string_if_enabled(
      constant cyclic_mode : t_cyclic)
    return string is
    begin
      if cyclic_mode = CYCLIC then
        return ", " & to_upper(to_string(cyclic_mode));
      else
        return "";
      end if;
    end function;

    -- Returns the string representation of the mode when it is enabled, otherwise returns an empty string
    function to_string_if_enabled(
      constant uniqueness : t_uniqueness)
    return string is
    begin
      if uniqueness = UNIQUE then
        return ", " & to_upper(to_string(uniqueness));
      else
        return "";
      end if;
    end function;

    -- Returns true if a value is contained in a vector
    function check_value_in_vector(
      constant value  : integer;
      constant vector : integer_vector)
    return boolean is
      variable v_found : boolean := false;
    begin
      for i in vector'range loop
        if value = vector(i) then
          v_found := true;
          exit;
        end if;
      end loop;
      return v_found;
    end function;

    -- Overload
    function check_value_in_vector(
      constant value  : real;
      constant vector : real_vector)
    return boolean is
      variable v_found : boolean := false;
    begin
      for i in vector'range loop
        if value = vector(i) then
          v_found := true;
          exit;
        end if;
      end loop;
      return v_found;
    end function;

    -- Overload
    function check_value_in_vector(
      constant value  : time;
      constant vector : time_vector)
    return boolean is
      variable v_found : boolean := false;
    begin
      for i in vector'range loop
        if value = vector(i) then
          v_found := true;
          exit;
        end if;
      end loop;
      return v_found;
    end function;

    -- Logs the procedure call unless it is called from another
    -- procedure to avoid duplicate logs. It also generates the
    -- correct procedure call to be used for logging or alerts.
    procedure log_proc_call(
      constant msg_id        : in t_msg_id;
      constant proc_call     : in string;
      constant ext_proc_call : in string;
      variable new_proc_call : inout line;
      constant msg_id_panel  : in t_msg_id_panel) is
    begin
      -- Called directly from sequencer/VVC
      if ext_proc_call = "" then
        log(msg_id, proc_call, priv_scope, msg_id_panel);
        write(new_proc_call, proc_call);
      -- Called from another procedure
      else
        write(new_proc_call, ext_proc_call);
      end if;
    end procedure;

    -- Generates the correct procedure call to be used for logging or alerts
    procedure create_proc_call(
      constant proc_call     : in string;
      constant ext_proc_call : in string;
      variable new_proc_call : inout line) is
    begin
      log_proc_call(ID_NEVER, proc_call, ext_proc_call, new_proc_call, shared_msg_id_panel);
    end procedure;

    -- Checks that the parameters are within a valid range for the given length
    impure function check_parameters_within_range(
      constant length        : natural;
      constant min_value     : integer;
      constant max_value     : integer;
      constant proc_call     : string;
      constant signed_values : boolean)
    return boolean is
      variable v_min : integer;
      variable v_max : integer;
    begin
      -- Constraint length is limited by 32-bit integer size
      if signed_values then
        v_min := -2 ** (length - 1)     when length < 32 else integer'low;
        v_max :=  2 ** (length - 1) - 1 when length < 32 else integer'high;
      else
        v_min := 0;
        v_max := 2 ** length - 1 when length < 31 else integer'high;
      end if;

      if (min_value < v_min or min_value > v_max) or (max_value < v_min or max_value > v_max) then
        alert(TB_ERROR, proc_call & "=> constraints must be within range [" & to_string(v_min) & ":" & to_string(v_max) & "] due to length parameter", priv_scope);
        return false;
      end if;
      return true;
    end function;

    -- Overload
    impure function check_parameters_within_range(
      constant length        : natural;
      constant set_of_values : integer_vector;
      constant proc_call     : string;
      constant signed_values : boolean)
    return boolean is
      variable v_min : integer;
      variable v_max : integer;
    begin
      -- Constraint length is limited by 32-bit integer size
      if signed_values then
        v_min := -2 ** (length - 1)     when length < 32 else integer'low;
        v_max :=  2 ** (length - 1) - 1 when length < 32 else integer'high;
      else
        v_min := 0;
        v_max := 2 ** length - 1 when length < 31 else integer'high;
      end if;

      for i in set_of_values'range loop
        if set_of_values(i) < v_min or set_of_values(i) > v_max then
          alert(TB_ERROR, proc_call & "=> constraints must be within range [" & to_string(v_min) & ":" & to_string(v_max) & "] due to length parameter", priv_scope);
          return false;
        end if;
      end loop;
      return true;
    end function;

    -- Overload
    impure function check_parameters_within_range(
      constant length    : natural;
      constant min_value : unsigned;
      constant max_value : unsigned;
      constant proc_call : string)
    return boolean is
    begin
      if find_leftmost(min_value, '1') >= length or find_leftmost(max_value, '1') >= length then
        alert(TB_ERROR, proc_call & "=> unsigned min_value and max_value lengths must be less or equal than length", priv_scope);
        return false;
      end if;
      return true;
    end function;

    -- Overload
    impure function check_parameters_within_range(
      constant length    : natural;
      constant min_value : signed;
      constant max_value : signed;
      constant proc_call : string)
    return boolean is
    begin
      if (min_value(min_value'high) /= '1' and find_leftmost(min_value, '1') >= length - 1) or
         (min_value(min_value'high) = '1' and find_leftmost(min_value, '0') >= length - 1) or
         (max_value(max_value'high) /= '1' and find_leftmost(max_value, '1') >= length - 1) or
         (max_value(max_value'high) = '1' and find_leftmost(max_value, '0') >= length - 1)
      then
        alert(TB_ERROR, proc_call & "=> signed min_value and max_value lengths must be less or equal than length", priv_scope);
        return false;
      end if;
      return true;
    end function;

    -- Generates an alert (only once)
    procedure alert_same_specifier(
      constant specifier : in t_value_specifier;
      constant proc_call : in string) is
    begin
      if not (priv_warned_same_specifier) then
        alert(TB_WARNING, proc_call & "=> Used same specifier for both set of values: " & to_upper(to_string(specifier)), priv_scope);
        priv_warned_same_specifier := true;
      end if;
    end procedure;

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_name(
      constant name : in string
    ) is
      constant C_NAME_NORMALISED : string(1 to name'length) := name;
    begin
      if C_NAME_NORMALISED'length > C_RAND_MAX_NAME_LENGTH then
        priv_name := C_NAME_NORMALISED(1 to C_RAND_MAX_NAME_LENGTH);
      else
        priv_name := C_NAME_NORMALISED & fill_string(NUL, C_RAND_MAX_NAME_LENGTH - C_NAME_NORMALISED'length);
      end if;
    end procedure;

    impure function get_name(
      constant VOID : t_void)
    return string is
    begin
      return to_string(priv_name);
    end function;

    procedure set_scope(
      constant scope : in string
    ) is
      constant C_SCOPE_NORMALISED : string(1 to scope'length) := scope;
    begin
      if C_SCOPE_NORMALISED'length > C_LOG_SCOPE_WIDTH then
        priv_scope := C_SCOPE_NORMALISED(1 to C_LOG_SCOPE_WIDTH);
      else
        priv_scope := C_SCOPE_NORMALISED & fill_string(NUL, C_LOG_SCOPE_WIDTH - C_SCOPE_NORMALISED'length);
      end if;
    end procedure;

    impure function get_scope(
      constant VOID : t_void)
    return string is
    begin
      return to_string(priv_scope);
    end function;

    procedure set_rand_dist(
      constant rand_dist    : in t_rand_dist;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_rand_dist(" & to_upper(to_string(rand_dist)) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_rand_dist := rand_dist;
    end procedure;

    impure function get_rand_dist(
      constant VOID : t_void)
    return t_rand_dist is
    begin
      return priv_rand_dist;
    end function;

    procedure set_rand_dist_mean(
      constant mean         : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_rand_dist_mean(" & to_string(mean, 2) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_mean            := mean;
      priv_mean_configured := true;
    end procedure;

    impure function get_rand_dist_mean(
      constant VOID : t_void)
    return real is
    begin
      if not (priv_mean_configured) then
        alert(TB_NOTE, "get_rand_dist_mean()=> mean has not been configured, using default", priv_scope);
      end if;
      return priv_mean;
    end function;

    procedure clear_rand_dist_mean(
      constant VOID : in t_void) is
    begin
      clear_rand_dist_mean(shared_msg_id_panel);
    end procedure;

    procedure clear_rand_dist_mean(
      constant msg_id_panel : in t_msg_id_panel) is
      constant C_LOCAL_CALL : string := "clear_rand_dist_mean()";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_mean            := 0.0;
      priv_mean_configured := false;
    end procedure;

    procedure set_rand_dist_std_deviation(
      constant std_deviation : in real;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_rand_dist_std_deviation(" & to_string(std_deviation, 2) & ")";
    begin
      if std_deviation > 0.0 then
        log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
        priv_std_dev            := std_deviation;
        priv_std_dev_configured := true;
      else
        alert(TB_ERROR, C_LOCAL_CALL & "=> Must use positive values", priv_scope);
      end if;
    end procedure;

    impure function get_rand_dist_std_deviation(
      constant VOID : t_void)
    return real is
    begin
      if not (priv_std_dev_configured) then
        alert(TB_NOTE, "get_rand_dist_std_deviation()=> std_deviation has not been configured, using default", priv_scope);
      end if;
      return priv_std_dev;
    end function;

    procedure clear_rand_dist_std_deviation(
      constant VOID : in t_void) is
    begin
      clear_rand_dist_std_deviation(shared_msg_id_panel);
    end procedure;

    procedure clear_rand_dist_std_deviation(
      constant msg_id_panel : in t_msg_id_panel) is
      constant C_LOCAL_CALL : string := "clear_rand_dist_std_deviation()";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_std_dev            := 0.0;
      priv_std_dev_configured := false;
    end procedure;

    procedure set_range_weight_default_mode(
      constant mode         : in t_weight_mode;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_range_weight_default_mode(" & to_upper(to_string(mode)) & ")";
    begin
      if mode = COMBINED_WEIGHT or mode = INDIVIDUAL_WEIGHT then
        log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
        priv_weight_mode := mode;
      else
        alert(TB_ERROR, C_LOCAL_CALL & "=> Mode not supported", priv_scope);
      end if;
    end procedure;

    impure function get_range_weight_default_mode(
      constant VOID : t_void)
    return t_weight_mode is
    begin
      return priv_weight_mode;
    end function;

    procedure clear_rand_cyclic(
      constant VOID : in t_void) is
    begin
      clear_rand_cyclic(shared_msg_id_panel);
    end procedure;

    procedure clear_rand_cyclic(
      constant msg_id_panel : in t_msg_id_panel) is
      constant C_LOCAL_CALL : string := "clear_rand_cyclic()";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL & "=> Deallocating cyclic list/queue", priv_scope, msg_id_panel);
      DEALLOCATE(priv_cyclic_current_function);
      priv_cyclic_current_function := new string'("");
      DEALLOCATE(priv_cyclic_list);
      priv_cyclic_queue.reset(VOID);
    end procedure;

    procedure report_config(
      constant VOID : in t_void) is
      constant C_PREFIX                  : string   := C_LOG_PREFIX & "     ";
      constant C_COLUMN1_WIDTH           : positive := 19;
      constant C_COLUMN2_WIDTH           : positive := C_LOG_SCOPE_WIDTH;
      variable v_line                    : line;
      variable v_multi_method_configured : boolean;
    begin
      -- Print report header
      write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
        "***  REPORT OF RANDOM GENERATOR CONFIGURATION ***" & LF &
        fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

      -- Print report config
      write(v_line, "          " & justify("NAME", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_name), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("SCOPE", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_scope), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("SEED 1", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_seed1), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("SEED 2", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_seed2), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("DISTRIBUTION", left, C_COLUMN1_WIDTH) & ": " & justify(to_upper(to_string(priv_rand_dist)), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("WEIGHT MODE", left, C_COLUMN1_WIDTH) & ": " & justify(to_upper(to_string(priv_weight_mode)), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("MEAN CONFIGURED", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_mean_configured), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("MEAN", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_mean, 2), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("STD_DEV CONFIGURED", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_std_dev_configured), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("STD_DEV", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_std_dev, 2), right, C_COLUMN2_WIDTH) & LF);

      -- Print multi-method config
      v_multi_method_configured := priv_int_constraints.ran_incl'length > 0 or priv_int_constraints.val_incl'length > 0 or
                                   priv_int_constraints.val_excl'length > 0 or priv_int_constraints.weighted_config or
                                   priv_real_constraints.ran_incl'length > 0 or priv_real_constraints.val_incl'length > 0 or
                                   priv_real_constraints.val_excl'length > 0 or priv_real_constraints.weighted_config or
                                   priv_time_constraints.ran_incl'length > 0 or priv_time_constraints.val_incl'length > 0 or
                                   priv_time_constraints.val_excl'length > 0 or priv_time_constraints.weighted_config or
                                   priv_uns_constraints.ran_incl'length > 0 or priv_sig_constraints.ran_incl'length > 0;
      if v_multi_method_configured then
        write(v_line, fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
        write(v_line, "          MULTI-METHOD CONSTRAINTS" & LF);
        write(v_line, fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
        write(v_line, "          CYCLIC MODE             : " & to_upper(to_string(priv_cyclic_mode)) & LF);
        write(v_line, "          UNIQUENESS              : " & to_upper(to_string(priv_uniqueness)) & LF);
      end if;
      if priv_int_constraints.ran_incl'length > 0 and not (priv_int_constraints.weighted_config) then
        write(v_line, "          RANGE INTEGER VALUES    : " & get_int_range_constraints(VOID) & LF);
      end if;
      if priv_int_constraints.val_incl'length > 0 and not (priv_int_constraints.weighted_config) then
        write(v_line, "          INCLUDED INTEGER VALUES : " & to_string(priv_int_constraints.val_incl.all) & LF);
      end if;
      if priv_int_constraints.val_excl'length > 0 then
        write(v_line, "          EXCLUDED INTEGER VALUES : " & to_string(priv_int_constraints.val_excl.all) & LF);
      end if;
      if priv_int_constraints.weighted_config then
        write(v_line, "          WEIGHTED INTEGER VALUES : " & to_string(priv_int_constraints.weighted.all) & LF);
      end if;
      if priv_real_constraints.ran_incl'length > 0 and not (priv_real_constraints.weighted_config) then
        write(v_line, "          RANGE REAL VALUES       : " & get_real_range_constraints(VOID) & LF);
      end if;
      if priv_real_constraints.val_incl'length > 0 and not (priv_real_constraints.weighted_config) then
        write(v_line, "          INCLUDED REAL VALUES    : " & format_real(priv_real_constraints.val_incl.all) & LF);
      end if;
      if priv_real_constraints.val_excl'length > 0 then
        write(v_line, "          EXCLUDED REAL VALUES    : " & format_real(priv_real_constraints.val_excl.all) & LF);
      end if;
      if priv_real_constraints.weighted_config then
        write(v_line, "          WEIGHTED REAL VALUES    : " & to_string(priv_real_constraints.weighted.all) & LF);
      end if;
      if priv_time_constraints.ran_incl'length > 0 and not (priv_time_constraints.weighted_config) then
        write(v_line, "          RANGE TIME VALUES       : " & get_time_range_constraints(VOID) & LF);
      end if;
      if priv_time_constraints.val_incl'length > 0 and not (priv_time_constraints.weighted_config) then
        write(v_line, "          INCLUDED TIME VALUES    : " & to_string(priv_time_constraints.val_incl.all) & LF);
      end if;
      if priv_time_constraints.val_excl'length > 0 then
        write(v_line, "          EXCLUDED TIME VALUES    : " & to_string(priv_time_constraints.val_excl.all) & LF);
      end if;
      if priv_time_constraints.weighted_config then
        write(v_line, "          WEIGHTED TIME VALUES    : " & to_string(priv_time_constraints.weighted.all) & LF);
      end if;
      if priv_uns_constraints.ran_incl'length > 0 then
        write(v_line, "          RANGE UNSIGNED VALUES   : " & get_uns_range_constraints(1) & LF);
      end if;
      if priv_sig_constraints.ran_incl'length > 0 then
        write(v_line, "          RANGE SIGNED VALUES     : " & get_sig_range_constraints(1) & LF);
      end if;

      -- Print report bottom line
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

      -- Write the info string to transcript
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
      prefix_lines(v_line, C_PREFIX);
      write_line_to_log_destination(v_line);
      DEALLOCATE(v_line);
    end procedure;

    ------------------------------------------------------------
    -- Randomization seeds
    ------------------------------------------------------------
    procedure set_rand_seeds(
      constant str : in string) is
      constant C_STR_LEN : natural := str'length;
      constant C_MAX_POS : natural := integer'right;
    begin
      -- Create the seeds by accumulating the ASCII values of the string,
      -- multiplied by a factor so they are widely spread, and making sure
      -- they don't overflow the positive range.
      for i in 1 to C_STR_LEN / 2 loop
        priv_seed1 := (priv_seed1 + char_to_ascii(str(i)) * 128) mod C_MAX_POS;
      end loop;
      priv_seed2 := (priv_seed2 + priv_seed1) mod C_MAX_POS;
      for i in C_STR_LEN / 2 + 1 to C_STR_LEN loop
        priv_seed2 := (priv_seed2 + char_to_ascii(str(i)) * 128) mod C_MAX_POS;
      end loop;
    end procedure;

    procedure set_rand_seeds(
      constant seed1 : in positive;
      constant seed2 : in positive) is
    begin
      priv_seed1 := seed1;
      priv_seed2 := seed2;
    end procedure;

    procedure set_rand_seeds(
      constant seeds : in t_positive_vector(0 to 1)) is
    begin
      priv_seed1 := seeds(0);
      priv_seed2 := seeds(1);
    end procedure;

    procedure get_rand_seeds(
      variable seed1 : out positive;
      variable seed2 : out positive) is
    begin
      seed1 := priv_seed1;
      seed2 := priv_seed2;
    end procedure;

    impure function get_rand_seeds(
      constant VOID : t_void)
    return t_positive_vector is
      variable v_ret : t_positive_vector(0 to 1);
    begin
      v_ret(0) := priv_seed1;
      v_ret(1) := priv_seed2;
      return v_ret;
    end function;

    ------------------------------------------------------------------------------------------------------------------------------
    -- ***************************************************************************************************************************
    -- Single-method rand() implementation
    -- ***************************************************************************************************************************
    ------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------
    -- Random integer
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL    : string                := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" & to_string_if_enabled(cyclic_mode) & ")";
      constant C_NUM_VALUES    : unsigned(32 downto 0) := unsigned(to_signed(max_value, 33) - to_signed(min_value, 33) + to_signed(1, 33));
      constant C_USE_LIST      : boolean               := C_NUM_VALUES <= C_RAND_CYCLIC_LIST_MAX_NUM_VALUES;
      constant C_PREVIOUS_DIST : t_rand_dist           := priv_rand_dist;
      variable v_proc_call     : line;
      variable v_mean          : real;
      variable v_std_dev       : real;
      variable v_ret           : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      priv_ret_valid := true;

      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        priv_ret_valid := false;
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if cyclic_mode = CYCLIC and priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and cyclic mode cannot be combined. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      case priv_rand_dist is
        when UNIFORM =>
          random_uniform(min_value, max_value, priv_seed1, priv_seed2, v_ret);

          -- The cyclic implementation uses a dynamic list with the size of the range (min/max)
          -- and marks each element after it is randomly generated. This approach is fast but
          -- requires a lot of memory for very big ranges which can cause problems for the simulator.
          -- Therefore, a secondary approach is also used which stores the generated random values
          -- in a queue so that the size of the range (min/max) doesn't affect its performance.
          -- However the search algorithm for this approach will slow down considerably after a
          -- certain number of iterations.
          if cyclic_mode = CYCLIC then
            -- If a different function in cyclic mode is called, regenerate the list/queue
            if v_proc_call.all /= priv_cyclic_current_function.all then
              DEALLOCATE(priv_cyclic_current_function);
              priv_cyclic_current_function := new string'(v_proc_call.all);
              priv_warned_simulation_slow  := false;
              if C_USE_LIST then
                DEALLOCATE(priv_cyclic_list);
                priv_cyclic_list           := new t_cyclic_list(min_value to max_value);
                priv_cyclic_list_num_items := 0;
              else
                if priv_cyclic_queue.get_scope(VOID) = "" then
                  priv_cyclic_queue.set_scope("RAND_CYCLIC_QUEUE");
                end if;
                priv_cyclic_queue.reset(VOID);
              end if;
            end if;
            -- Generate unique values within the constraints
            if C_USE_LIST then
              while priv_cyclic_list(v_ret) = '1' loop
                random_uniform(min_value, max_value, priv_seed1, priv_seed2, v_ret);
              end loop;
              priv_cyclic_list(v_ret) := '1';
            else
              while priv_cyclic_queue.exists(v_ret) loop -- Each call iterates through the whole queue which will be innefficient for many elements
                random_uniform(min_value, max_value, priv_seed1, priv_seed2, v_ret);
              end loop;
              priv_cyclic_queue.add(v_ret);
              if priv_cyclic_queue.get_count(VOID) > C_RAND_CYCLIC_QUEUE_MAX_ALERT and not (priv_warned_simulation_slow) and not (C_RAND_CYCLIC_QUEUE_MAX_ALERT_DISABLE) then
                alert(TB_WARNING, v_proc_call.all & "=> Simulation might slow down due to the cyclic queue and the large number of cyclic iterations.\n" & "To disable this alert set C_RAND_CYCLIC_QUEUE_MAX_ALERT_DISABLE to true in adaptations_pkg.", priv_scope);
                priv_warned_simulation_slow := true;
              end if;
            end if;
            -- Reset the list/queue after generating all possible values
            if C_USE_LIST then
              priv_cyclic_list_num_items := priv_cyclic_list_num_items + 1;
              if priv_cyclic_list_num_items >= priv_cyclic_list'length then
                priv_cyclic_list.all       := (priv_cyclic_list'range => '0');
                priv_cyclic_list_num_items := 0;
              end if;
            else
              if priv_cyclic_queue.get_count(VOID) >= C_NUM_VALUES then
                priv_cyclic_queue.reset(VOID);
              end if;
            end if;
          end if;

        when GAUSSIAN =>
          -- Default values for the mean and standard deviation are relative to the given range
          v_mean    := priv_mean when priv_mean_configured else (real(min_value) + (real(max_value) - real(min_value)) / 2.0);
          v_std_dev := priv_std_dev when priv_std_dev_configured else ((real(max_value) - real(min_value)) / 6.0);
          random_gaussian(min_value, max_value, v_mean, v_std_dev, priv_seed1, priv_seed2, v_ret);

        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
      end case;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL       : string      := "rand(" & to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST    : t_rand_dist := priv_rand_dist;
      variable v_proc_call        : line;
      alias normalized_set_values : integer_vector(0 to set_of_values'length-1) is set_of_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if specifier /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier)), priv_scope);
        priv_ret_valid := false;
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value within the set of values
      v_ret := rand(0, set_of_values'length - 1, cyclic_mode, msg_id_panel, v_proc_call.all);

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier    : t_value_specifier;
      constant value        : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      variable v_set_values : integer_vector(0 to 0) := (0 => value);
    begin
      return rand(min_value, max_value, specifier, v_set_values, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL       : string      := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " & to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST    : t_rand_dist := priv_rand_dist;
      variable v_proc_call        : line;
      alias normalized_set_values : integer_vector(0 to set_of_values'length-1) is set_of_values;
      variable v_gen_new_random   : boolean     := true;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      if specifier = ADD then
        -- Avoid an integer overflow by adding the set_of_values to the max_value or subtracting them from the min_value
        if max_value <= integer'right - set_of_values'length then
          v_ret := rand(min_value, max_value + set_of_values'length, cyclic_mode, msg_id_panel, v_proc_call.all);
          if v_ret > max_value then
            v_ret := normalized_set_values(v_ret - max_value - 1);
          end if;
        elsif min_value >= integer'left + set_of_values'length then
          v_ret := rand(min_value - set_of_values'length, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
          if v_ret < min_value then
            v_ret := normalized_set_values(min_value - v_ret - 1);
          end if;
        else
          alert(TB_ERROR, v_proc_call.all & "=> Constraints are greater than integer's range", priv_scope);
          priv_ret_valid := false;
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif specifier = EXCL then
        for i in 0 to (set_of_values'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values);
          exit when not v_gen_new_random;
          if i = (set_of_values'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier)), priv_scope);
        priv_ret_valid := false;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier1   : t_value_specifier;
      constant value1       : integer;
      constant specifier2   : t_value_specifier;
      constant value2       : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => value2);
    begin
      return rand(min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant value1         : integer;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => value1);
    begin
      return rand(min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : integer_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call  : string         := "")
    return integer is
      constant C_LOCAL_CALL          : string      := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier1)) & ":" & to_string(set_of_values1) & ", " &
        to_upper(to_string(specifier2)) & ":" & to_string(set_of_values2) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_combined_set_values : integer_vector(0 to set_of_values1'length + set_of_values2'length - 1);
      variable v_gen_new_random      : boolean     := true;
      variable v_ret                 : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Create a new set of values in case both are the same type
      if (specifier1 = ADD and specifier2 = ADD) or (specifier1 = EXCL and specifier2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_of_values1'length then
            v_combined_set_values(i) := set_of_values1(i);
          else
            v_combined_set_values(i) := set_of_values2(i - set_of_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if specifier1 = ADD and specifier2 = ADD then
        alert_same_specifier(specifier1, v_proc_call.all);
        v_ret := rand(min_value, max_value, ADD, v_combined_set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif specifier1 = EXCL and specifier2 = EXCL then
        alert_same_specifier(specifier1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif specifier1 = ADD and specifier2 = EXCL then
        for i in 0 to (set_of_values2'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, ADD, set_of_values1, cyclic_mode, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values2);
          exit when not v_gen_new_random;
          if i = (set_of_values2'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif specifier1 = EXCL and specifier2 = ADD then
        for i in 0 to (set_of_values1'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, ADD, set_of_values2, cyclic_mode, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values1);
          exit when not v_gen_new_random;
          if i = (set_of_values1'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      else
        if not (specifier1 = ADD or specifier1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier1)), priv_scope);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier2)), priv_scope);
        end if;
        priv_ret_valid := false;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random real
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "])";
      variable v_proc_call  : line;
      variable v_mean       : real;
      variable v_std_dev    : real;
      variable v_ret        : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      priv_ret_valid := true;

      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        priv_ret_valid := false;
        deallocate(v_proc_call);
        return v_ret;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      case priv_rand_dist is
        when UNIFORM =>
          random_uniform(min_value, max_value, priv_seed1, priv_seed2, v_ret);
        when GAUSSIAN =>
          -- Default values for the mean and standard deviation are relative to the given range
          v_mean    := priv_mean when priv_mean_configured else (min_value + (max_value - min_value) / 2.0);
          v_std_dev := priv_std_dev when priv_std_dev_configured else ((max_value - min_value) / 6.0);
          random_gaussian(min_value, max_value, v_mean, v_std_dev, priv_seed1, priv_seed2, v_ret);
        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant specifier     : t_value_specifier;
      constant set_of_values : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL       : string      := "rand(" & to_upper(to_string(specifier)) & ":" & format_real(set_of_values) & ")";
      constant C_PREVIOUS_DIST    : t_rand_dist := priv_rand_dist;
      variable v_proc_call        : line;
      alias normalized_set_values : real_vector(0 to set_of_values'length-1) is set_of_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if specifier /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier)), priv_scope);
        priv_ret_valid := false;
        deallocate(v_proc_call);
        return real'left;
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value within the set of values
      v_ret := rand(0, set_of_values'length - 1, NON_CYCLIC, msg_id_panel, v_proc_call.all);

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value    : real;
      constant max_value    : real;
      constant specifier    : t_value_specifier;
      constant value        : real;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real is
      variable v_set_values : real_vector(0 to 0) := (0 => value);
    begin
      return rand(min_value, max_value, specifier, v_set_values, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant specifier     : t_value_specifier;
      constant set_of_values : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL     : string      := "rand(RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "], " & to_upper(to_string(specifier)) & ":" & format_real(set_of_values) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_proc_call      : line;
      variable v_gen_new_random : boolean     := true;
      variable v_offset         : real;
      variable v_ret            : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      -- It is impossible to give the same weight to an added value than to a single value in the real range,
      -- therefore we split the probability to 50% range and 50% added values.
      if specifier = ADD then
        v_offset := (max_value - min_value) when (max_value - min_value) > 0.0 else 1.0;
        v_ret    := rand(min_value, max_value + v_offset, msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := rand(ONLY, set_of_values, msg_id_panel, v_proc_call.all);
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif specifier = EXCL then
        for i in 0 to (set_of_values'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values);
          exit when not v_gen_new_random;
          if i = (set_of_values'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier)), priv_scope);
        priv_ret_valid := false;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value    : real;
      constant max_value    : real;
      constant specifier1   : t_value_specifier;
      constant value1       : real;
      constant specifier2   : t_value_specifier;
      constant value2       : real;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real is
      variable v_set_values1 : real_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : real_vector(0 to 0) := (0 => value2);
    begin
      return rand(min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, msg_id_panel);
    end function;

    impure function rand(
      constant min_value      : real;
      constant max_value      : real;
      constant specifier1     : t_value_specifier;
      constant value1         : real;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : real_vector;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return real is
      variable v_set_values1 : real_vector(0 to 0) := (0 => value1);
    begin
      return rand(min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, msg_id_panel);
    end function;

    impure function rand(
      constant min_value      : real;
      constant max_value      : real;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : real_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : real_vector;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call  : string         := "")
    return real is
      constant C_LOCAL_CALL          : string      := "rand(RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "], " &
        to_upper(to_string(specifier1)) & ":" & format_real(set_of_values1) & ", " &
        to_upper(to_string(specifier2)) & ":" & format_real(set_of_values2) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_combined_set_values : real_vector(0 to set_of_values1'length + set_of_values2'length - 1);
      variable v_gen_new_random      : boolean     := true;
      variable v_ret                 : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Create a new set of values in case both are the same type
      if (specifier1 = ADD and specifier2 = ADD) or (specifier1 = EXCL and specifier2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_of_values1'length then
            v_combined_set_values(i) := set_of_values1(i);
          else
            v_combined_set_values(i) := set_of_values2(i - set_of_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if specifier1 = ADD and specifier2 = ADD then
        alert_same_specifier(specifier1, v_proc_call.all);
        v_ret := rand(min_value, max_value, ADD, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif specifier1 = EXCL and specifier2 = EXCL then
        alert_same_specifier(specifier1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif specifier1 = ADD and specifier2 = EXCL then
        for i in 0 to (set_of_values2'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, ADD, set_of_values1, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values2);
          exit when not v_gen_new_random;
          if i = (set_of_values2'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif specifier1 = EXCL and specifier2 = ADD then
        for i in 0 to (set_of_values1'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, ADD, set_of_values2, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values1);
          exit when not v_gen_new_random;
          if i = (set_of_values1'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      else
        if not (specifier1 = ADD or specifier1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier1)), priv_scope);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier2)), priv_scope);
        end if;
        priv_ret_valid := false;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random time
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "])";
      variable v_proc_call  : line;
      variable v_ret        : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      priv_ret_valid := true;

      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        priv_ret_valid := false;
        deallocate(v_proc_call);
        return v_ret;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      case priv_rand_dist is
        when UNIFORM =>
          random_uniform(min_value, max_value, priv_seed1, priv_seed2, v_ret);
        when GAUSSIAN =>
          alert(TB_ERROR, v_proc_call.all & "=> Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant specifier     : t_value_specifier;
      constant set_of_values : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL       : string := "rand(" & to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & ")";
      variable v_proc_call        : line;
      alias normalized_set_values : time_vector(0 to set_of_values'length-1) is set_of_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if specifier /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier)), priv_scope);
        priv_ret_valid := false;
        deallocate(v_proc_call);
        return time'left;
      end if;

      -- Generate a random value within the set of values
      v_ret := rand(0, set_of_values'length - 1, NON_CYCLIC, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value    : time;
      constant max_value    : time;
      constant specifier    : t_value_specifier;
      constant value        : time;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time is
      variable v_set_values : time_vector(0 to 0) := (0 => value);
    begin
      return rand(min_value, max_value, specifier, v_set_values, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant specifier     : t_value_specifier;
      constant set_of_values : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL       : string  := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " & to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & ")";
      constant C_TIME_UNIT        : time    := std.env.resolution_limit;
      variable v_proc_call        : line;
      alias normalized_set_values : time_vector(0 to set_of_values'length-1) is set_of_values;
      variable v_gen_new_random   : boolean := true;
      variable v_ret              : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      if specifier = ADD then
        v_ret := rand(min_value, max_value + (set_of_values'length * C_TIME_UNIT), msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values((v_ret - max_value) / C_TIME_UNIT - 1);
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif specifier = EXCL then
        for i in 0 to (set_of_values'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values);
          exit when not v_gen_new_random;
          if i = (set_of_values'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier)), priv_scope);
        priv_ret_valid := false;
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value    : time;
      constant max_value    : time;
      constant specifier1   : t_value_specifier;
      constant value1       : time;
      constant specifier2   : t_value_specifier;
      constant value2       : time;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time is
      variable v_set_values1 : time_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : time_vector(0 to 0) := (0 => value2);
    begin
      return rand(min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, msg_id_panel);
    end function;

    impure function rand(
      constant min_value      : time;
      constant max_value      : time;
      constant specifier1     : t_value_specifier;
      constant value1         : time;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : time_vector;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return time is
      variable v_set_values1 : time_vector(0 to 0) := (0 => value1);
    begin
      return rand(min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, msg_id_panel);
    end function;

    impure function rand(
      constant min_value      : time;
      constant max_value      : time;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : time_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : time_vector;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call  : string         := "")
    return time is
      constant C_LOCAL_CALL          : string  := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier1)) & ":" & to_string(set_of_values1) & ", " &
        to_upper(to_string(specifier2)) & ":" & to_string(set_of_values2) & ")";
      variable v_proc_call           : line;
      variable v_combined_set_values : time_vector(0 to set_of_values1'length + set_of_values2'length - 1);
      variable v_gen_new_random      : boolean := true;
      variable v_ret                 : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Create a new set of values in case both are the same type
      if (specifier1 = ADD and specifier2 = ADD) or (specifier1 = EXCL and specifier2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_of_values1'length then
            v_combined_set_values(i) := set_of_values1(i);
          else
            v_combined_set_values(i) := set_of_values2(i - set_of_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if specifier1 = ADD and specifier2 = ADD then
        alert_same_specifier(specifier1, v_proc_call.all);
        v_ret := rand(min_value, max_value, ADD, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif specifier1 = EXCL and specifier2 = EXCL then
        alert_same_specifier(specifier1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif specifier1 = ADD and specifier2 = EXCL then
        for i in 0 to (set_of_values2'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, ADD, set_of_values1, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values2);
          exit when not v_gen_new_random;
          if i = (set_of_values2'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif specifier1 = EXCL and specifier2 = ADD then
        for i in 0 to (set_of_values1'length) * C_NUM_INVALID_TRIES loop
          v_ret            := rand(min_value, max_value, ADD, set_of_values2, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_of_values1);
          exit when not v_gen_new_random;
          if i = (set_of_values1'length) * C_NUM_INVALID_TRIES then
            alert(TB_ERROR, v_proc_call.all & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
            priv_ret_valid := false;
          end if;
        end loop;
      else
        if not (specifier1 = ADD or specifier1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier1)), priv_scope);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier2)), priv_scope);
        end if;
        priv_ret_valid := false;
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random integer_vector
    ------------------------------------------------------------
    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL     : string      := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" & to_string_if_enabled(uniqueness) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_cyclic_mode    : t_cyclic    := cyclic_mode;
      variable v_ret            : integer_vector(0 to length - 1);
    begin
      if cyclic_mode = CYCLIC and priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and cyclic mode cannot be combined. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;
      if uniqueness = UNIQUE and priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and uniqueness cannot be combined. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;
      if uniqueness = UNIQUE and cyclic_mode = CYCLIC then
        alert(TB_WARNING, C_LOCAL_CALL & "=> Uniqueness and cyclic mode cannot be combined. Using NON_CYCLIC instead.", priv_scope);
        v_cyclic_mode := NON_CYCLIC;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL     : string      := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(uniqueness) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_cyclic_mode    : t_cyclic    := cyclic_mode;
      variable v_ret            : integer_vector(0 to length - 1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;
      if uniqueness = UNIQUE and cyclic_mode = CYCLIC then
        alert(TB_WARNING, C_LOCAL_CALL & "=> Uniqueness and cyclic mode cannot be combined. Using NON_CYCLIC instead.", priv_scope);
        v_cyclic_mode := NON_CYCLIC;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value within the set of values for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(specifier, set_of_values, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value within the set of values for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(specifier, set_of_values, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier    : t_value_specifier;
      constant value        : integer;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      variable v_set_values : integer_vector(0 to 0) := (0 => value);
    begin
      return rand(length, min_value, max_value, specifier, v_set_values, uniqueness, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL     : string      := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(uniqueness) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_cyclic_mode    : t_cyclic    := cyclic_mode;
      variable v_ret            : integer_vector(0 to length - 1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;
      if uniqueness = UNIQUE and cyclic_mode = CYCLIC then
        alert(TB_WARNING, C_LOCAL_CALL & "=> Uniqueness and cyclic mode cannot be combined. Using NON_CYCLIC instead.", priv_scope);
        v_cyclic_mode := NON_CYCLIC;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, specifier, set_of_values, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, specifier, set_of_values, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier1   : t_value_specifier;
      constant value1       : integer;
      constant specifier2   : t_value_specifier;
      constant value2       : integer;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => value2);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, uniqueness, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant value1         : integer;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => value1);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, uniqueness, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : integer_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL     : string      := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier1)) & ":" & to_string(set_of_values1) & ", " &
        to_upper(to_string(specifier2)) & ":" & to_string(set_of_values2) & to_string_if_enabled(uniqueness) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_cyclic_mode    : t_cyclic    := cyclic_mode;
      variable v_ret            : integer_vector(0 to length - 1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;
      if uniqueness = UNIQUE and cyclic_mode = CYCLIC then
        alert(TB_WARNING, C_LOCAL_CALL & "=> Uniqueness and cyclic mode cannot be combined. Using NON_CYCLIC instead.", priv_scope);
        v_cyclic_mode := NON_CYCLIC;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random real_vector
    ------------------------------------------------------------
    impure function rand(
      constant length       : positive;
      constant min_value    : real;
      constant max_value    : real;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL     : string      := "rand(LEN:" & to_string(length) & ", RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "]" & to_string_if_enabled(uniqueness) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_ret            : real_vector(0 to length - 1);
    begin
      if uniqueness = UNIQUE and priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and uniqueness cannot be combined. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL     : string      := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(specifier)) & ":" & format_real(set_of_values) & to_string_if_enabled(uniqueness) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_ret            : real_vector(0 to length - 1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value within the set of values for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(specifier, set_of_values, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value within the set of values for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(specifier, set_of_values, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : real;
      constant max_value    : real;
      constant specifier    : t_value_specifier;
      constant value        : real;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      variable v_set_values : real_vector(0 to 0) := (0 => value);
    begin
      return rand(length, min_value, max_value, specifier, v_set_values, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant specifier     : t_value_specifier;
      constant set_of_values : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL     : string      := "rand(LEN:" & to_string(length) & ", RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "], " &
        to_upper(to_string(specifier)) & ":" & format_real(set_of_values) & to_string_if_enabled(uniqueness) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_ret            : real_vector(0 to length - 1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, specifier, set_of_values, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, specifier, set_of_values, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : real;
      constant max_value    : real;
      constant specifier1   : t_value_specifier;
      constant value1       : real;
      constant specifier2   : t_value_specifier;
      constant value2       : real;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      variable v_set_values1 : real_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : real_vector(0 to 0) := (0 => value2);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : real;
      constant max_value      : real;
      constant specifier1     : t_value_specifier;
      constant value1         : real;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : real_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      variable v_set_values1 : real_vector(0 to 0) := (0 => value1);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : real;
      constant max_value      : real;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : real_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : real_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL     : string      := "rand(LEN:" & to_string(length) & ", RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "], " &
        to_upper(to_string(specifier1)) & ":" & format_real(set_of_values1) & ", " &
        to_upper(to_string(specifier2)) & ":" & format_real(set_of_values2) & to_string_if_enabled(uniqueness) & ")";
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_ret            : real_vector(0 to length - 1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random time_vector
    ------------------------------------------------------------
    impure function rand(
      constant length       : positive;
      constant min_value    : time;
      constant max_value    : time;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL     : string  := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" & to_string_if_enabled(uniqueness) & ")";
      variable v_gen_new_random : boolean := true;
      variable v_ret            : time_vector(0 to length - 1);
    begin
      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL     : string  := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(uniqueness) & ")";
      variable v_gen_new_random : boolean := true;
      variable v_ret            : time_vector(0 to length - 1);
    begin
      if uniqueness = NON_UNIQUE then
        -- Generate a random value within the set of values for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(specifier, set_of_values, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value within the set of values for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(specifier, set_of_values, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : time;
      constant max_value    : time;
      constant specifier    : t_value_specifier;
      constant value        : time;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      variable v_set_values : time_vector(0 to 0) := (0 => value);
    begin
      return rand(length, min_value, max_value, specifier, v_set_values, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant specifier     : t_value_specifier;
      constant set_of_values : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL     : string  := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(uniqueness) & ")";
      variable v_gen_new_random : boolean := true;
      variable v_ret            : time_vector(0 to length - 1);
    begin
      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, specifier, set_of_values, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, specifier, set_of_values, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : time;
      constant max_value    : time;
      constant specifier1   : t_value_specifier;
      constant value1       : time;
      constant specifier2   : t_value_specifier;
      constant value2       : time;
      constant uniqueness   : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      variable v_set_values1 : time_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : time_vector(0 to 0) := (0 => value2);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : time;
      constant max_value      : time;
      constant specifier1     : t_value_specifier;
      constant value1         : time;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : time_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      variable v_set_values1 : time_vector(0 to 0) := (0 => value1);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : time;
      constant max_value      : time;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : time_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : time_vector;
      constant uniqueness     : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL     : string  := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier1)) & ":" & to_string(set_of_values1) & ", " &
        to_upper(to_string(specifier2)) & ":" & to_string(set_of_values2) & to_string_if_enabled(uniqueness) & ")";
      variable v_gen_new_random : boolean := true;
      variable v_ret            : time_vector(0 to length - 1);
    begin
      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := rand(min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, msg_id_panel, C_LOCAL_CALL);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := rand(min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, msg_id_panel, C_LOCAL_CALL);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random unsigned
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      constant C_LOCAL_CALL    : string      := "rand(LEN:" & to_string(length) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      variable v_proc_call     : line;
      variable v_ret_int       : integer;
      variable v_ret           : unsigned(length - 1 downto 0);
      variable v_max           : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if length <= 31 then
        -- Generate a random value in the range [min_value:max_value]
        v_max     := 2 ** length - 1 when length < 31 else integer'high;
        v_ret_int := rand(0, v_max, cyclic_mode, msg_id_panel, v_proc_call.all);
        v_ret     := to_unsigned(v_ret_int, length);

      -- Long vectors use different randomization (does not support distributions or cyclic)
      else
        if priv_rand_dist = GAUSSIAN then
          alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for long vectors. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        end if;
        if cyclic_mode = CYCLIC then
          alert(TB_WARNING, v_proc_call.all & "=> Vector is too big for cyclic mode. Ignoring cyclic configuration.", priv_scope);
        end if;

        -- Generate a random value for each bit of the vector
        for i in 0 to length - 1 loop
          v_ret(i downto i) := to_unsigned(rand(0, 1, NON_CYCLIC, msg_id_panel, v_proc_call.all), 1);
        end loop;

        -- Restore previous distribution
        priv_rand_dist := C_PREVIOUS_DIST;
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value    : unsigned;
      constant max_value    : unsigned;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) & ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      variable v_ret        : unsigned(MAXIMUM(min_value'length, max_value'length) - 1 downto 0);
    begin
      -- Generate a random value in the range [min_value:max_value]
      v_ret := rand(v_ret'length, min_value, max_value, msg_id_panel, C_LOCAL_CALL);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : unsigned;
      constant max_value     : unsigned;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      constant C_LOCAL_CALL    : string      := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) & ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      constant C_LEFTMOST_BIT  : natural     := find_leftmost(max_value - min_value, '1') + 1;
      variable v_proc_call     : line;
      variable v_valid         : boolean     := false;
      variable v_ret           : unsigned(length - 1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if min_value >= max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if min_value'length > length or max_value'length > length then
        alert(TB_ERROR, v_proc_call.all & "=> unsigned min_value and max_value lengths must be less or equal than length", priv_scope);
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for unsigned constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      while not (v_valid) loop
        v_ret   := resize(min_value + rand(C_LEFTMOST_BIT, NON_CYCLIC, msg_id_panel, v_proc_call.all), length);
        v_valid := v_ret >= min_value and v_ret <= max_value;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret_int    : integer;
      variable v_ret        : unsigned(length - 1 downto 0);
    begin
      -- Generate a random value in the range [min_value:max_value]
      if not check_parameters_within_range(length, min_value, max_value, C_LOCAL_CALL, signed_values => false) then
        return v_ret;
      end if;
      v_ret_int := rand(min_value, max_value, cyclic_mode, msg_id_panel, C_LOCAL_CALL);
      if not priv_ret_valid then
        v_ret := (others => '0');
      else
        v_ret := to_unsigned(v_ret_int, length);
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      constant C_LOCAL_CALL     : string  := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_proc_call      : line;
      variable v_gen_new_random : boolean := true;
      variable v_unsigned       : unsigned(length - 1 downto 0);
      variable v_ret_int        : integer;
      variable v_ret            : unsigned(length - 1 downto 0);
      variable v_max            : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if not check_parameters_within_range(length, integer_vector(set_of_values), C_LOCAL_CALL, signed_values => false) then
        deallocate(v_proc_call);
        return v_ret;
      end if;
      -- Generate a random value within the set of values
      if specifier = ONLY then
        v_ret_int := rand(ONLY, integer_vector(set_of_values), cyclic_mode, msg_id_panel, v_proc_call.all);
        v_ret     := to_unsigned(v_ret_int, length);
      -- Generate a random value in the vector's range minus the set of values
      elsif specifier = EXCL then
        -- Check whether the vector's range can handle cyclic mode
        if length <= 31 then
          v_max     := 2 ** length - 1 when length < 31 else integer'high;
          v_ret_int := rand(0, v_max, EXCL, integer_vector(set_of_values), cyclic_mode, msg_id_panel, v_proc_call.all);
          v_ret     := to_unsigned(v_ret_int, length);
        else
          if cyclic_mode = CYCLIC then
            alert(TB_WARNING, v_proc_call.all & "=> Range is too big for cyclic mode (min: 0, max: 2**" & to_string(length) & "-1)", priv_scope);
          end if;
          while v_gen_new_random loop   -- It is safe to assume the loop won't be infinite since the number of possible values is > 2**31
            v_unsigned := rand(length, NON_CYCLIC, msg_id_panel, v_proc_call.all);
            -- If the random value is outside the integer range it cannot be in the exclude list
            if v_unsigned > integer'right then
              v_gen_new_random := false;
            else
              v_gen_new_random := check_value_in_vector(to_integer(v_unsigned), integer_vector(set_of_values));
            end if;
          end loop;
          v_ret := v_unsigned;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier)), priv_scope);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant specifier    : t_value_specifier;
      constant value        : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_set_values : t_natural_vector(0 to 0) := (0 => value);
    begin
      return rand(length, min_value, max_value, specifier, v_set_values, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant specifier     : t_value_specifier;
      constant set_of_values : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string  := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret_int    : integer;
      variable v_ret        : unsigned(length - 1 downto 0);
      variable v_check_ok   : boolean := true;
    begin
      -- Generate a random value in the range [min_value:max_value], plus or minus the set of values
      v_check_ok := v_check_ok and check_parameters_within_range(length, min_value, max_value, C_LOCAL_CALL, signed_values => false);
      v_check_ok := v_check_ok and check_parameters_within_range(length, integer_vector(set_of_values), C_LOCAL_CALL, signed_values => false);
      if not v_check_ok then
        return v_ret;
      end if;
      v_ret_int  := rand(min_value, max_value, specifier, integer_vector(set_of_values), cyclic_mode, msg_id_panel, C_LOCAL_CALL);
      v_ret      := to_unsigned(v_ret_int, length);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant specifier1   : t_value_specifier;
      constant value1       : natural;
      constant specifier2   : t_value_specifier;
      constant value2       : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : t_natural_vector(0 to 0) := (0 => value2);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : natural;
      constant max_value      : natural;
      constant specifier1     : t_value_specifier;
      constant value1         : natural;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : t_natural_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => value1);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : natural;
      constant max_value      : natural;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : t_natural_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : t_natural_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string  := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier1)) & ":" & to_string(set_of_values1) & ", " &
        to_upper(to_string(specifier2)) & ":" & to_string(set_of_values2) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret_int    : integer;
      variable v_ret        : unsigned(length - 1 downto 0);
      variable v_check_ok   : boolean := true;
    begin
      -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values
      v_check_ok := v_check_ok and check_parameters_within_range(length, min_value, max_value, C_LOCAL_CALL, signed_values => false);
      v_check_ok := v_check_ok and check_parameters_within_range(length, integer_vector(set_of_values1), C_LOCAL_CALL, signed_values => false);
      v_check_ok := v_check_ok and check_parameters_within_range(length, integer_vector(set_of_values2), C_LOCAL_CALL, signed_values => false);
      if not v_check_ok then
        return v_ret;
      end if;
      v_ret_int  := rand(min_value, max_value, specifier1, integer_vector(set_of_values1), specifier2, integer_vector(set_of_values2), cyclic_mode, msg_id_panel, C_LOCAL_CALL);
      v_ret      := to_unsigned(v_ret_int, length);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random signed
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_proc_call  : line;
      variable v_ret_int    : integer;
      variable v_ret_uns    : unsigned(length - 1 downto 0);
      variable v_ret        : signed(length - 1 downto 0);
      variable v_min        : integer;
      variable v_max        : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if length <= 32 then
        -- Generate a random value in the range [min_value:max_value]
        v_min     := -2 ** (length - 1)     when length < 32 else integer'low;
        v_max     :=  2 ** (length - 1) - 1 when length < 32 else integer'high;
        v_ret_int := rand(v_min, v_max, cyclic_mode, msg_id_panel, v_proc_call.all);
        v_ret     := to_signed(v_ret_int, length);

      -- Long vectors use different randomization (does not support distributions or cyclic)
      else
        v_ret_uns := rand(length, cyclic_mode, msg_id_panel, v_proc_call.all);
        v_ret     := signed(v_ret_uns);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value    : signed;
      constant max_value    : signed;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) & ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      variable v_ret        : signed(MAXIMUM(min_value'length, max_value'length) - 1 downto 0);
    begin
      -- Generate a random value in the range [min_value:max_value]
      v_ret := rand(v_ret'length, min_value, max_value, msg_id_panel, C_LOCAL_CALL);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : signed;
      constant max_value     : signed;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      constant C_LOCAL_CALL    : string      := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) & ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      constant C_LEFTMOST_BIT  : natural     := find_leftmost(max_value - min_value, '1') + 1;
      variable v_proc_call     : line;
      variable v_valid         : boolean     := false;
      variable v_uns           : unsigned(length - 1 downto 0);
      variable v_ret           : signed(length - 1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if min_value >= max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if min_value'length > length or max_value'length > length then
        alert(TB_ERROR, v_proc_call.all & "=> signed min_value and max_value lengths must be less or equal than length", priv_scope);
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for unsigned constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      while not (v_valid) loop
        v_uns   := resize(rand(C_LEFTMOST_BIT, NON_CYCLIC, msg_id_panel, v_proc_call.all), length);
        v_ret   := resize(min_value + signed(v_uns), length);
        v_valid := v_ret >= min_value and v_ret <= max_value;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret        : integer;
    begin
      -- Generate a random value in the range [min_value:max_value]
      if not check_parameters_within_range(length, min_value, max_value, C_LOCAL_CALL, signed_values => true) then
        return to_signed(v_ret, length);
      end if;
      v_ret := rand(min_value, max_value, cyclic_mode, msg_id_panel, C_LOCAL_CALL);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return to_signed(v_ret, length);
    end function;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      constant C_LOCAL_CALL     : string  := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_proc_call      : line;
      variable v_gen_new_random : boolean := true;
      variable v_signed         : signed(length - 1 downto 0);
      variable v_ret_int        : integer;
      variable v_ret            : signed(length - 1 downto 0);
      variable v_min            : integer;
      variable v_max            : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if not check_parameters_within_range(length, set_of_values, v_proc_call.all, signed_values => true) then
        deallocate(v_proc_call);
        return v_ret;
      end if;
      -- Generate a random value within the set of values
      if specifier = ONLY then
        v_ret_int := rand(ONLY, integer_vector(set_of_values), cyclic_mode, msg_id_panel, v_proc_call.all);
        v_ret     := to_signed(v_ret_int, length);
      -- Generate a random value in the vector's range minus the set of values
      elsif specifier = EXCL then
        -- Check whether the vector's range can handle cyclic mode
        if length <= 32 then
          v_min     := -2 ** (length - 1)     when length < 32 else integer'low;
          v_max     :=  2 ** (length - 1) - 1 when length < 32 else integer'high;
          v_ret_int := rand(v_min, v_max, EXCL, integer_vector(set_of_values), cyclic_mode, msg_id_panel, v_proc_call.all);
          v_ret     := to_signed(v_ret_int, length);
        else
          if cyclic_mode = CYCLIC then
            alert(TB_WARNING, v_proc_call.all & "=> Range is too big for cyclic mode (min: -2**" & to_string(length - 1) & ", max: 2**" & to_string(length - 1) & "-1)", priv_scope);
          end if;
          while v_gen_new_random loop   -- It is safe to assume the loop won't be infinite since the number of possible values is > 2**32
            v_signed := rand(length, NON_CYCLIC, msg_id_panel, v_proc_call.all);
            -- If the random value is outside the integer range it cannot be in the exclude list
            if v_signed > integer'right or v_signed < integer'left then
              v_gen_new_random := false;
            else
              v_gen_new_random := check_value_in_vector(to_integer(v_signed), set_of_values);
            end if;
          end loop;
          v_ret := v_signed;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(specifier)), priv_scope);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier    : t_value_specifier;
      constant value        : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_set_values : integer_vector(0 to 0) := (0 => value);
    begin
      return rand(length, min_value, max_value, specifier, v_set_values, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant specifier     : t_value_specifier;
      constant set_of_values : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string  := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier)) & ":" & to_string(set_of_values) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret        : integer;
      variable v_check_ok   : boolean := true;
    begin
      -- Generate a random value in the range [min_value:max_value], plus or minus the set of values
      v_check_ok := v_check_ok and check_parameters_within_range(length, min_value, max_value, C_LOCAL_CALL, signed_values => true);
      v_check_ok := v_check_ok and check_parameters_within_range(length, set_of_values, C_LOCAL_CALL, signed_values => true);
      if not v_check_ok then
        return to_signed(v_ret, length);
      end if;
      v_ret      := rand(min_value, max_value, specifier, integer_vector(set_of_values), cyclic_mode, msg_id_panel, C_LOCAL_CALL);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return to_signed(v_ret, length);
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : integer;
      constant max_value    : integer;
      constant specifier1   : t_value_specifier;
      constant value1       : integer;
      constant specifier2   : t_value_specifier;
      constant value2       : integer;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => value2);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant value1         : integer;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => value1);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : integer;
      constant max_value      : integer;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : integer_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : integer_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string  := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(specifier1)) & ":" & to_string(set_of_values1) & ", " &
        to_upper(to_string(specifier2)) & ":" & to_string(set_of_values2) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret        : integer;
      variable v_check_ok   : boolean := true;
    begin
      -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values
      v_check_ok := v_check_ok and check_parameters_within_range(length, min_value, max_value, C_LOCAL_CALL, signed_values => true);
      v_check_ok := v_check_ok and check_parameters_within_range(length, set_of_values1, C_LOCAL_CALL, signed_values => true);
      v_check_ok := v_check_ok and check_parameters_within_range(length, set_of_values2, C_LOCAL_CALL, signed_values => true);
      if not v_check_ok then
        return to_signed(v_ret, length);
      end if;
      v_ret      := rand(min_value, max_value, specifier1, integer_vector(set_of_values1), specifier2, integer_vector(set_of_values2), cyclic_mode, msg_id_panel, C_LOCAL_CALL);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return to_signed(v_ret, length);
    end function;

    ------------------------------------------------------------
    -- Random std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand(
      constant length       : positive;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length - 1 downto 0);
    begin
      v_ret := rand(length, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant min_value    : std_logic_vector;
      constant max_value    : std_logic_vector;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(max_value'length - 1 downto 0);
    begin
      v_ret := rand(unsigned(min_value), unsigned(max_value), msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : std_logic_vector;
      constant max_value     : std_logic_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(length - 1 downto 0);
    begin
      v_ret := rand(length, unsigned(min_value), unsigned(max_value), msg_id_panel, ext_proc_call);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length - 1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant specifier     : t_value_specifier;
      constant set_of_values : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length - 1 downto 0);
    begin
      v_ret := rand(length, specifier, set_of_values, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant specifier    : t_value_specifier;
      constant value        : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_set_values : t_natural_vector(0 to 0) := (0 => value);
    begin
      return rand(length, min_value, max_value, specifier, v_set_values, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant specifier     : t_value_specifier;
      constant set_of_values : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length - 1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, specifier, set_of_values, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length       : positive;
      constant min_value    : natural;
      constant max_value    : natural;
      constant specifier1   : t_value_specifier;
      constant value1       : natural;
      constant specifier2   : t_value_specifier;
      constant value2       : natural;
      constant cyclic_mode  : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => value1);
      variable v_set_values2 : t_natural_vector(0 to 0) := (0 => value2);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, v_set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : natural;
      constant max_value      : natural;
      constant specifier1     : t_value_specifier;
      constant value1         : natural;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : t_natural_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => value1);
    begin
      return rand(length, min_value, max_value, specifier1, v_set_values1, specifier2, set_of_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length         : positive;
      constant min_value      : natural;
      constant max_value      : natural;
      constant specifier1     : t_value_specifier;
      constant set_of_values1 : t_natural_vector;
      constant specifier2     : t_value_specifier;
      constant set_of_values2 : t_natural_vector;
      constant cyclic_mode    : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length - 1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    ------------------------------------------------------------
    -- Random std_logic & boolean
    ------------------------------------------------------------
    impure function rand(
      constant VOID : t_void)
    return std_logic is
      variable v_ret : std_logic;
    begin
      v_ret := rand(shared_msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant msg_id_panel : t_msg_id_panel)
    return std_logic is
      constant C_LOCAL_CALL    : string      := "rand(STD_LOGIC)";
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      variable v_ret           : unsigned(0 downto 0);
    begin
      -- Always use Uniform distribution
      priv_rand_dist := UNIFORM;

      -- Generate a random bit
      v_ret := rand(1, NON_CYCLIC, msg_id_panel, C_LOCAL_CALL);

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret(0);
    end function;

    impure function rand(
      constant VOID : t_void)
    return boolean is
      variable v_ret : boolean;
    begin
      v_ret := rand(shared_msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant msg_id_panel : t_msg_id_panel)
    return boolean is
      constant C_LOCAL_CALL    : string      := "rand(BOOL)";
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      variable v_ret           : unsigned(0 downto 0);
    begin
      -- Always use Uniform distribution
      priv_rand_dist := UNIFORM;

      -- Generate a random bit
      v_ret := rand(1, NON_CYCLIC, msg_id_panel, C_LOCAL_CALL);

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret(0) = '1';
    end function;

    ------------------------------------------------------------
    -- Random weighted integer
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weighted_vector : t_val_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      variable v_local_call      : line;
      variable v_weighted_vector : t_range_weight_mode_int_vec(weighted_vector'range);
      variable v_ret             : integer;
    begin
      -- Convert the weight vector to base type
      for i in weighted_vector'range loop
        v_weighted_vector(i) := (weighted_vector(i).value, weighted_vector(i).value, weighted_vector(i).weight, NA);
      end loop;
      v_local_call := new string'("rand_val_weight(" & to_string(v_weighted_vector) & ")");

      v_ret := rand_range_weight_mode(v_weighted_vector, msg_id_panel, v_local_call.all);

      log(ID_RAND_GEN, v_local_call.all & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      DEALLOCATE(v_local_call);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      variable v_local_call      : line;
      variable v_weighted_vector : t_range_weight_mode_int_vec(weighted_vector'range);
      variable v_ret             : integer;
    begin
      -- Convert the weight vector to base type
      for i in weighted_vector'range loop
        v_weighted_vector(i) := (weighted_vector(i).min_value, weighted_vector(i).max_value, weighted_vector(i).weight, priv_weight_mode);
      end loop;
      v_local_call := new string'("rand_range_weight(" & to_string(v_weighted_vector) & ")");

      v_ret := rand_range_weight_mode(v_weighted_vector, msg_id_panel, v_local_call.all);

      log(ID_RAND_GEN, v_local_call.all & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      DEALLOCATE(v_local_call);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call   : string         := "")
    return integer is
      constant C_LOCAL_CALL_1        : string      := "rand(" & to_string(weighted_vector) & ")";
      constant C_LOCAL_CALL_2        : string      := "rand_range_weight_mode(" & to_string(weighted_vector) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_mode                : t_weight_mode;
      variable v_acc_weight          : natural     := 0;
      variable v_acc_weighted_vector : t_natural_vector(0 to weighted_vector'length - 1);
      variable v_weight_idx          : natural     := 0;
      variable v_values_in_range     : natural     := 0;
      variable v_ret                 : integer;
    begin
      if priv_int_constraints.weighted_config then
        create_proc_call(C_LOCAL_CALL_1, ext_proc_call, v_proc_call);
      else
        create_proc_call(C_LOCAL_CALL_2, ext_proc_call, v_proc_call);
      end if;

      -- Create a new vector with the accumulated weights
      for i in weighted_vector'range loop
        if weighted_vector(i).min_value > weighted_vector(i).max_value then
          alert(TB_ERROR, v_proc_call.all & "=> The min_value parameter must be less or equal than max_value", priv_scope);
          return v_ret;
        end if;
        v_mode := weighted_vector(i).mode when weighted_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weighted_vector(i).weight;
        -- Use the same weight for each value in the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          v_values_in_range := weighted_vector(i).max_value - weighted_vector(i).min_value + 1;
          v_acc_weight      := v_acc_weight + weighted_vector(i).weight * v_values_in_range;
        end if;
        v_acc_weighted_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope);
        return v_ret;
      end if;

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and weighted randomization cannot be combined. Ignoring " & to_upper(to_string(priv_rand_dist)) & " configuration.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value between 1 and the total accumulated weight
      v_weight_idx := rand(1, v_acc_weight, NON_CYCLIC, msg_id_panel, v_proc_call.all);
      -- Associate the random value to the original value in the vector based on the weight
      for i in v_acc_weighted_vector'range loop
        if v_weight_idx <= v_acc_weighted_vector(i) then
          v_ret := rand(weighted_vector(i).min_value, weighted_vector(i).max_value, NON_CYCLIC, msg_id_panel, v_proc_call.all);
          exit;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted real
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weighted_vector : t_val_weight_real_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return real is
      variable v_local_call      : line;
      variable v_weighted_vector : t_range_weight_mode_real_vec(weighted_vector'range);
      variable v_ret             : real;
    begin
      -- Convert the weight vector to base type
      for i in weighted_vector'range loop
        v_weighted_vector(i) := (weighted_vector(i).value, weighted_vector(i).value, weighted_vector(i).weight, NA);
      end loop;
      v_local_call := new string'("rand_val_weight(" & to_string(v_weighted_vector) & ")");

      v_ret := rand_range_weight_mode(v_weighted_vector, msg_id_panel, v_local_call.all);

      log(ID_RAND_GEN, v_local_call.all & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      DEALLOCATE(v_local_call);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant weighted_vector : t_range_weight_real_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return real is
      variable v_local_call      : line;
      variable v_weighted_vector : t_range_weight_mode_real_vec(weighted_vector'range);
      variable v_ret             : real;
    begin
      -- Convert the weight vector to base type
      for i in weighted_vector'range loop
        v_weighted_vector(i) := (weighted_vector(i).min_value, weighted_vector(i).max_value, weighted_vector(i).weight, priv_weight_mode);
      end loop;
      v_local_call := new string'("rand_range_weight(" & to_string(v_weighted_vector) & ")");

      v_ret := rand_range_weight_mode(v_weighted_vector, msg_id_panel, v_local_call.all);

      log(ID_RAND_GEN, v_local_call.all & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      DEALLOCATE(v_local_call);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant weighted_vector : t_range_weight_mode_real_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call   : string         := "")
    return real is
      constant C_LOCAL_CALL_1        : string      := "rand(" & to_string(weighted_vector) & ")";
      constant C_LOCAL_CALL_2        : string      := "rand_range_weight_mode(" & to_string(weighted_vector) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_mode                : t_weight_mode;
      variable v_acc_weight          : natural     := 0;
      variable v_acc_weighted_vector : t_natural_vector(0 to weighted_vector'length - 1);
      variable v_weight_idx          : natural     := 0;
      variable v_ret                 : real;
    begin
      if priv_int_constraints.weighted_config then
        create_proc_call(C_LOCAL_CALL_1, ext_proc_call, v_proc_call);
      else
        create_proc_call(C_LOCAL_CALL_2, ext_proc_call, v_proc_call);
      end if;

      -- Create a new vector with the accumulated weights
      for i in weighted_vector'range loop
        if weighted_vector(i).min_value > weighted_vector(i).max_value then
          alert(TB_ERROR, v_proc_call.all & "=> The min_value parameter must be less or equal than max_value", priv_scope);
          deallocate(v_proc_call);
          return v_ret;
        end if;
        v_mode := weighted_vector(i).mode when weighted_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weighted_vector(i).weight;
        -- Use the same weight for each value in the range -> Not possible to know every value within the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          alert(TB_ERROR, v_proc_call.all & "=> INDIVIDUAL_WEIGHT not supported for real type", priv_scope);
          deallocate(v_proc_call);
          return v_ret;
        end if;
        v_acc_weighted_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope);
        deallocate(v_proc_call);
        return v_ret;
      end if;

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and weighted randomization cannot be combined. Ignoring " & to_upper(to_string(priv_rand_dist)) & " configuration.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value between 1 and the total accumulated weight
      v_weight_idx := rand(1, v_acc_weight, NON_CYCLIC, msg_id_panel, v_proc_call.all);
      -- Associate the random value to the original value in the vector based on the weight
      for i in v_acc_weighted_vector'range loop
        if v_weight_idx <= v_acc_weighted_vector(i) then
          v_ret := rand(weighted_vector(i).min_value, weighted_vector(i).max_value, msg_id_panel, v_proc_call.all);
          exit;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted time
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weighted_vector : t_val_weight_time_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return time is
      variable v_local_call      : line;
      variable v_weighted_vector : t_range_weight_mode_time_vec(weighted_vector'range);
      variable v_ret             : time;
    begin
      -- Convert the weight vector to base type
      for i in weighted_vector'range loop
        v_weighted_vector(i) := (weighted_vector(i).value, weighted_vector(i).value, weighted_vector(i).weight, NA);
      end loop;
      v_local_call := new string'("rand_val_weight(" & to_string(v_weighted_vector) & ")");

      v_ret := rand_range_weight_mode(v_weighted_vector, msg_id_panel, v_local_call.all);

      log(ID_RAND_GEN, v_local_call.all & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      DEALLOCATE(v_local_call);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant weighted_vector : t_range_weight_time_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return time is
      variable v_local_call      : line;
      variable v_weighted_vector : t_range_weight_mode_time_vec(weighted_vector'range);
      variable v_ret             : time;
    begin
      -- Convert the weight vector to base type
      for i in weighted_vector'range loop
        v_weighted_vector(i) := (weighted_vector(i).min_value, weighted_vector(i).max_value, weighted_vector(i).weight, priv_weight_mode);
      end loop;
      v_local_call := new string'("rand_range_weight(" & to_string(v_weighted_vector) & ")");

      v_ret := rand_range_weight_mode(v_weighted_vector, msg_id_panel, v_local_call.all);

      log(ID_RAND_GEN, v_local_call.all & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      DEALLOCATE(v_local_call);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant weighted_vector : t_range_weight_mode_time_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call   : string         := "")
    return time is
      constant C_LOCAL_CALL_1        : string      := "rand(" & to_string(weighted_vector) & ")";
      constant C_LOCAL_CALL_2        : string      := "rand_range_weight_mode(" & to_string(weighted_vector) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_mode                : t_weight_mode;
      variable v_acc_weight          : natural     := 0;
      variable v_acc_weighted_vector : t_natural_vector(0 to weighted_vector'length - 1);
      variable v_weight_idx          : natural     := 0;
      variable v_ret                 : time;
    begin
      if priv_int_constraints.weighted_config then
        create_proc_call(C_LOCAL_CALL_1, ext_proc_call, v_proc_call);
      else
        create_proc_call(C_LOCAL_CALL_2, ext_proc_call, v_proc_call);
      end if;

      -- Create a new vector with the accumulated weights
      for i in weighted_vector'range loop
        if weighted_vector(i).min_value > weighted_vector(i).max_value then
          alert(TB_ERROR, v_proc_call.all & "=> The min_value parameter must be less or equal than max_value", priv_scope);
          deallocate(v_proc_call);
          return v_ret;
        end if;
        v_mode := weighted_vector(i).mode when weighted_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weighted_vector(i).weight;
        -- Use the same weight for each value in the range -> Not possible to know every value within the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          alert(TB_ERROR, v_proc_call.all & "=> INDIVIDUAL_WEIGHT not supported for time type", priv_scope);
          deallocate(v_proc_call);
          return v_ret;
        end if;
        v_acc_weighted_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope);
        deallocate(v_proc_call);
        return v_ret;
      end if;

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and weighted randomization cannot be combined. Ignoring " & to_upper(to_string(priv_rand_dist)) & " configuration.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value between 1 and the total accumulated weight
      v_weight_idx := rand(1, v_acc_weight, NON_CYCLIC, msg_id_panel, v_proc_call.all);
      -- Associate the random value to the original value in the vector based on the weight
      for i in v_acc_weighted_vector'range loop
        if v_weight_idx <= v_acc_weighted_vector(i) then
          v_ret := rand(weighted_vector(i).min_value, weighted_vector(i).max_value, msg_id_panel, v_proc_call.all);
          exit;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted unsigned
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length          : positive;
      constant weighted_vector : t_val_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_ret : unsigned(0 to length - 1);
    begin
      v_ret := to_unsigned(rand_val_weight(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_ret : unsigned(0 to length - 1);
    begin
      v_ret := to_unsigned(rand_range_weight(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_ret : unsigned(0 to length - 1);
    begin
      v_ret := to_unsigned(rand_range_weight_mode(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted signed
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length          : positive;
      constant weighted_vector : t_val_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_ret : signed(0 to length - 1);
    begin
      v_ret := to_signed(rand_val_weight(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_ret : signed(0 to length - 1);
    begin
      v_ret := to_signed(rand_range_weight(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_ret : signed(0 to length - 1);
    begin
      v_ret := to_signed(rand_range_weight_mode(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length          : positive;
      constant weighted_vector : t_val_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(0 to length - 1);
    begin
      v_ret := to_unsigned(rand_val_weight(weighted_vector, msg_id_panel), length);
      return std_logic_vector(v_ret);
    end function;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(0 to length - 1);
    begin
      v_ret := to_unsigned(rand_range_weight(weighted_vector, msg_id_panel), length);
      return std_logic_vector(v_ret);
    end function;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(0 to length - 1);
    begin
      v_ret := to_unsigned(rand_range_weight_mode(weighted_vector, msg_id_panel), length);
      return std_logic_vector(v_ret);
    end function;

    ------------------------------------------------------------------------------------------------------------------------------
    -- ***************************************************************************************************************************
    -- Multi-method rand() implementation
    -- ***************************************************************************************************************************
    ------------------------------------------------------------------------------------------------------------------------------
    -- Increases the size of the vector pointer variable
    procedure increment_vec_size(
      variable ran_vector : inout t_range_int_vec_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_range_int_vec_ptr;
    begin
      v_copy_ptr                             := ran_vector;
      ran_vector                             := new t_range_int_vec(0 to v_copy_ptr'length-1 + increment);
      ran_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_integer_vector_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_integer_vector_ptr;
    begin
      v_copy_ptr                             := val_vector;
      val_vector                             := new integer_vector(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_range_weight_mode_int_vec_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_range_weight_mode_int_vec_ptr;
    begin
      v_copy_ptr                             := val_vector;
      val_vector                             := new t_range_weight_mode_int_vec(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable ran_vector : inout t_range_real_vec_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_range_real_vec_ptr;
    begin
      v_copy_ptr                             := ran_vector;
      ran_vector                             := new t_range_real_vec(0 to v_copy_ptr'length-1 + increment);
      ran_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_real_vector_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_real_vector_ptr;
    begin
      v_copy_ptr                             := val_vector;
      val_vector                             := new real_vector(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_range_weight_mode_real_vec_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_range_weight_mode_real_vec_ptr;
    begin
      v_copy_ptr                             := val_vector;
      val_vector                             := new t_range_weight_mode_real_vec(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable ran_vector : inout t_range_time_vec_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_range_time_vec_ptr;
    begin
      v_copy_ptr                             := ran_vector;
      ran_vector                             := new t_range_time_vec(0 to v_copy_ptr'length-1 + increment);
      ran_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_time_vector_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_time_vector_ptr;
    begin
      v_copy_ptr                             := val_vector;
      val_vector                             := new time_vector(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_range_weight_mode_time_vec_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_range_weight_mode_time_vec_ptr;
    begin
      v_copy_ptr                             := val_vector;
      val_vector                             := new t_range_weight_mode_time_vec(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_range_uns_vec_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_range_uns_vec_ptr;
    begin
      v_copy_ptr                             := val_vector;
      val_vector                             := new t_range_uns_vec(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_range_sig_vec_ptr;
      constant increment  : in natural) is
      variable v_copy_ptr : t_range_sig_vec_ptr;
    begin
      v_copy_ptr                             := val_vector;
      val_vector                             := new t_range_sig_vec(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Returns the string representation of the integer constraints for randomization
    impure function get_int_constraints(
      constant length    : natural;
      constant is_vector : boolean := false)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      if length > 0 then
        write(v_line, string'("LEN:") & to_string(length));
        if priv_int_constraints.ran_incl'length > 0 or priv_int_constraints.val_incl'length > 0 then
          write(v_line, string'(", "));
        end if;
      end if;
      if priv_int_constraints.ran_incl'length > 0 then
        write(v_line, string'("RANGE:") & get_int_range_constraints(VOID));
      end if;
      if priv_int_constraints.val_incl'length > 0 then
        if priv_int_constraints.ran_incl'length = 0 then
          write(v_line, string'("ONLY:"));
        else
          write(v_line, string'(", ADD:"));
        end if;
        write(v_line, to_string(priv_int_constraints.val_incl.all));
      end if;
      if priv_int_constraints.val_excl'length > 0 then
        if v_line /= NULL then
          write(v_line, string'(", "));
        end if;
        write(v_line, string'("EXCL:") & to_string(priv_int_constraints.val_excl.all));
      end if;
      if v_line = NULL then
        write(v_line, string'("UNCONSTRAINED"));
      end if;
      if priv_cyclic_mode = CYCLIC then
        write(v_line, string'(", ") & to_upper(to_string(priv_cyclic_mode)));
      end if;
      if is_vector and priv_uniqueness = UNIQUE then
        write(v_line, string'(", ") & to_upper(to_string(priv_uniqueness)));
      end if;
      return return_and_deallocate;
    end function;

    -- Overload
    impure function get_int_constraints(
      constant VOID : t_void)
    return string is
    begin
      return get_int_constraints(0, false);
    end function;

    -- Returns the string representation of the real constraints for randomization
    impure function get_real_constraints(
      constant length    : natural;
      constant is_vector : boolean)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      if length > 0 then
        write(v_line, string'("LEN:") & to_string(length));
        if priv_real_constraints.ran_incl'length > 0 or priv_real_constraints.val_incl'length > 0 then
          write(v_line, string'(", "));
        end if;
      end if;
      if priv_real_constraints.ran_incl'length > 0 then
        write(v_line, string'("RANGE:") & get_real_range_constraints(VOID));
      end if;
      if priv_real_constraints.val_incl'length > 0 then
        if priv_real_constraints.ran_incl'length = 0 then
          write(v_line, string'("ONLY:"));
        else
          write(v_line, string'(", ADD:"));
        end if;
        write(v_line, format_real(priv_real_constraints.val_incl.all));
      end if;
      if priv_real_constraints.val_excl'length > 0 then
        write(v_line, string'(", EXCL:") & format_real(priv_real_constraints.val_excl.all));
      end if;
      if v_line = NULL then
        write(v_line, string'("UNCONSTRAINED"));
      end if;
      if is_vector and priv_uniqueness = UNIQUE then
        write(v_line, string'(", ") & to_upper(to_string(priv_uniqueness)));
      end if;
      return return_and_deallocate;
    end function;

    -- Overload
    impure function get_real_constraints(
      constant VOID : t_void)
    return string is
    begin
      return get_real_constraints(0, false);
    end function;

    -- Returns the string representation of the time constraints for randomization
    impure function get_time_constraints(
      constant length    : natural;
      constant is_vector : boolean)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      if length > 0 then
        write(v_line, string'("LEN:") & to_string(length));
        if priv_time_constraints.ran_incl'length > 0 or priv_time_constraints.val_incl'length > 0 then
          write(v_line, string'(", "));
        end if;
      end if;
      if priv_time_constraints.ran_incl'length > 0 then
        write(v_line, string'("RANGE:") & get_time_range_constraints(VOID));
      end if;
      if priv_time_constraints.val_incl'length > 0 then
        if priv_time_constraints.ran_incl'length = 0 then
          write(v_line, string'("ONLY:"));
        else
          write(v_line, string'(", ADD:"));
        end if;
        write(v_line, to_string(priv_time_constraints.val_incl.all));
      end if;
      if priv_time_constraints.val_excl'length > 0 then
        write(v_line, string'(", EXCL:") & to_string(priv_time_constraints.val_excl.all));
      end if;
      if v_line = NULL then
        write(v_line, string'("UNCONSTRAINED"));
      end if;
      if is_vector and priv_uniqueness = UNIQUE then
        write(v_line, string'(", ") & to_upper(to_string(priv_uniqueness)));
      end if;
      return return_and_deallocate;
    end function;

    -- Overload
    impure function get_time_constraints(
      constant VOID : t_void)
    return string is
    begin
      return get_time_constraints(0, false);
    end function;

    -- Returns the string representation of the unsigned constraints for randomization
    impure function get_uns_constraints(
      constant length : natural)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      write(v_line, string'("LEN:") & to_string(length) & string'(", "));
      if priv_uns_constraints.ran_incl'length > 0 then
        write(v_line, string'("RANGE:") & get_uns_range_constraints(length));
      end if;
      return return_and_deallocate;
    end function;

    -- Returns the string representation of the signed constraints for randomization
    impure function get_sig_constraints(
      constant length : natural)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      write(v_line, string'("LEN:") & to_string(length) & string'(", "));
      if priv_sig_constraints.ran_incl'length > 0 then
        write(v_line, string'("RANGE:") & get_sig_range_constraints(length));
      end if;
      return return_and_deallocate;
    end function;

    -- Returns true if only the correct type of constraints are configured
    impure function check_configured_constraints(
      constant value_type : string;
      constant proc_call  : string;
      constant is_config  : boolean)
    return boolean is
      constant C_MSG_CONFIG      : string  := "constraints are already configured. Cannot add " & value_type & " constraints.";
      constant C_MSG_RETURN      : string  := "constraints are configured. Cannot return " & value_type & " value.";
      variable v_int_configured  : boolean := priv_int_constraints.ran_incl'length > 0 or priv_int_constraints.val_incl'length > 0 or priv_int_constraints.val_excl'length > 0 or priv_int_constraints.weighted'length > 0;
      variable v_real_configured : boolean := priv_real_constraints.ran_incl'length > 0 or priv_real_constraints.val_incl'length > 0 or priv_real_constraints.val_excl'length > 0 or priv_real_constraints.weighted'length > 0;
      variable v_time_configured : boolean := priv_time_constraints.ran_incl'length > 0 or priv_time_constraints.val_incl'length > 0 or priv_time_constraints.val_excl'length > 0 or priv_time_constraints.weighted'length > 0;
      variable v_uns_configured  : boolean := priv_uns_constraints.ran_incl'length > 0;
      variable v_sig_configured  : boolean := priv_sig_constraints.ran_incl'length > 0;
    begin
      if not (value_type = "INTEGER" or value_type = "REAL" or value_type = "TIME" or value_type = "UNSIGNED" or value_type = "SLV" or value_type = "SIGNED") then
        alert(TB_FAILURE, proc_call & "=> Undefined value type: " & value_type, priv_scope);
      end if;

      if v_int_configured and (value_type = "REAL" or value_type = "TIME" or (is_config and value_type = "UNSIGNED") or (is_config and value_type = "SIGNED")) then
        if is_config then
          alert(TB_ERROR, proc_call & "=> Integer " & C_MSG_CONFIG, priv_scope);
        else
          alert(TB_ERROR, proc_call & "=> Integer " & C_MSG_RETURN, priv_scope);
        end if;
        return false;
      end if;

      if v_real_configured and (value_type = "INTEGER" or value_type = "TIME" or value_type = "UNSIGNED" or value_type = "SLV" or value_type = "SIGNED") then
        if is_config then
          alert(TB_ERROR, proc_call & "=> Real " & C_MSG_CONFIG, priv_scope);
        else
          alert(TB_ERROR, proc_call & "=> Real " & C_MSG_RETURN, priv_scope);
        end if;
        return false;
      end if;

      if v_time_configured and (value_type = "INTEGER" or value_type = "REAL" or value_type = "UNSIGNED" or value_type = "SLV" or value_type = "SIGNED") then
        if is_config then
          alert(TB_ERROR, proc_call & "=> Time " & C_MSG_CONFIG, priv_scope);
        else
          alert(TB_ERROR, proc_call & "=> Time " & C_MSG_RETURN, priv_scope);
        end if;
        return false;
      end if;

      if v_uns_configured and (value_type = "INTEGER" or value_type = "REAL" or value_type = "TIME" or value_type = "SIGNED") then
        if is_config then
          alert(TB_ERROR, proc_call & "=> Unsigned " & C_MSG_CONFIG, priv_scope);
        else
          alert(TB_ERROR, proc_call & "=> Unsigned " & C_MSG_RETURN, priv_scope);
        end if;
        return false;
      end if;

      if v_sig_configured and (value_type = "INTEGER" or value_type = "REAL" or value_type = "TIME" or value_type = "UNSIGNED" or value_type = "SLV") then
        if is_config then
          alert(TB_ERROR, proc_call & "=> Signed " & C_MSG_CONFIG, priv_scope);
        else
          alert(TB_ERROR, proc_call & "=> Signed " & C_MSG_RETURN, priv_scope);
        end if;
        return false;
      end if;

      return true;
    end function;

    -- Returns an integer random value supporting multiple range constraints
    impure function randm_ranges(
      constant msg_id_panel : t_msg_id_panel;
      constant proc_call    : string)
    return integer is
      constant C_MIN_RANGE      : integer     := integer'left;
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_max_range      : signed(32 downto 0);
      variable v_max_value      : signed(32 downto 0);
      variable v_acc_range_len  : signed(33 downto 0);
      variable v_prev_offset    : signed(33 downto 0);
      variable v_gen_new_random : boolean     := true;
      variable v_ret_long       : signed(32 downto 0);
      variable v_ret            : integer;
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, proc_call & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for a single range(min/max) constraint. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      for i in 0 to (priv_int_constraints.val_excl'length) * C_NUM_INVALID_TRIES loop
        -- Concatenate all ranges first and then the added values into a single continuous range to call rand(min,max)
        v_max_range := to_signed(C_MIN_RANGE, 33);
        for j in 0 to priv_int_constraints.ran_incl'length - 1 loop
          v_max_range := v_max_range + priv_int_constraints.ran_incl(j).range_len;
        end loop;
        v_max_range := v_max_range - 1;
        v_max_value := v_max_range + priv_int_constraints.val_incl'length;
        if v_max_range > to_signed(integer'right, 33) or v_max_value > to_signed(integer'right, 33) then
          alert(TB_ERROR, proc_call & "=> Constraints are greater than integer's range", priv_scope);
          priv_ret_valid := false;
          priv_rand_dist := C_PREVIOUS_DIST; -- Restore previous distribution
          return v_ret;
        end if;

        v_ret := rand(C_MIN_RANGE, to_integer(v_max_value(31 downto 0)), priv_cyclic_mode, msg_id_panel, proc_call);

        -- Convert the random value to the correct range
        if v_ret <= v_max_range then
          v_ret_long      := to_signed(v_ret, 33) - to_signed(C_MIN_RANGE, 33); -- Remove offset
          v_acc_range_len := (others => '0');
          for j in 0 to priv_int_constraints.ran_incl'length - 1 loop
            v_acc_range_len := v_acc_range_len + priv_int_constraints.ran_incl(j).range_len;
            if v_ret_long < v_acc_range_len then
              v_prev_offset := v_acc_range_len - priv_int_constraints.ran_incl(j).range_len;
              v_ret         := to_integer(resize(v_ret_long + priv_int_constraints.ran_incl(j).min_value - v_prev_offset, 32));
              exit;
            end if;
          end loop;
        -- If random value isn't a range, convert it to the corresponding added value
        else
          v_ret := priv_int_constraints.val_incl(v_ret - to_integer(v_max_range(31 downto 0)) - 1);
        end if;

        -- Check if the random value is in the exclusion list
        v_gen_new_random := check_value_in_vector(v_ret, priv_int_constraints.val_excl.all);
        exit when not v_gen_new_random;
        if i = (priv_int_constraints.val_excl'length) * C_NUM_INVALID_TRIES then
          alert(TB_ERROR, proc_call & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
          priv_ret_valid := false;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      return v_ret;
    end function;

    -- Returns a real random value supporting multiple range constraints
    impure function randm_ranges(
      constant msg_id_panel : t_msg_id_panel;
      constant proc_call    : string)
    return real is
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_max_range      : real;
      variable v_max_value      : real;
      variable v_acc_range_len  : real;
      variable v_gen_new_random : boolean     := true;
      variable v_ret            : real;
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, proc_call & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for a single range(min/max) constraint. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      for i in 0 to (priv_real_constraints.val_excl'length) * C_NUM_INVALID_TRIES loop
        -- Concatenate all ranges first and then the added values into a single continuous range to call rand(min,max)
        v_max_range := 0.0;
        for j in 0 to priv_real_constraints.ran_incl'length - 1 loop
          v_max_range := v_max_range + priv_real_constraints.ran_incl(j).range_len;
        end loop;
        -- It is impossible to give the same weight to an included value than to a single value in the real range,
        -- therefore we split the probability to 50% ranges and 50% included values.
        v_max_value := v_max_range * 2.0 when priv_real_constraints.val_incl'length > 0 else v_max_range;

        v_ret := rand(0.0, v_max_value, msg_id_panel, proc_call);

        -- Convert the random value to the correct range
        if v_ret <= v_max_range then
          v_acc_range_len := 0.0;
          for j in 0 to priv_real_constraints.ran_incl'length - 1 loop
            v_acc_range_len := v_acc_range_len + priv_real_constraints.ran_incl(j).range_len;
            if v_ret <= v_acc_range_len then
              v_ret := v_ret + priv_real_constraints.ran_incl(j).min_value - (v_acc_range_len - priv_real_constraints.ran_incl(j).range_len);
              exit;
            end if;
          end loop;
        -- If random value isn't a range, randomize within the added values
        else
          v_ret := rand(ONLY, priv_real_constraints.val_incl.all, msg_id_panel, proc_call);
        end if;

        -- Check if the random value is in the exclusion list
        v_gen_new_random := check_value_in_vector(v_ret, priv_real_constraints.val_excl.all);
        exit when not v_gen_new_random;
        if i = (priv_real_constraints.val_excl'length) * C_NUM_INVALID_TRIES then
          alert(TB_ERROR, proc_call & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
          priv_ret_valid := false;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      return v_ret;
    end function;

    -- Returns a time random value supporting multiple range constraints
    impure function randm_ranges(
      constant msg_id_panel : t_msg_id_panel;
      constant proc_call    : string)
    return time is
      constant C_TIME_UNIT      : time    := std.env.resolution_limit;
      variable v_max_range      : time;
      variable v_max_value      : time;
      variable v_acc_range_len  : time;
      variable v_gen_new_random : boolean := true;
      variable v_ret            : time;
    begin
      -- Invalid distributions checked in randm() procedure

      for i in 0 to (priv_time_constraints.val_excl'length) * C_NUM_INVALID_TRIES loop
        -- Concatenate all ranges first and then the added values into a single continuous range to call rand(min,max)
        v_max_range := 0 ns;
        for j in 0 to priv_time_constraints.ran_incl'length - 1 loop
          v_max_range := v_max_range + priv_time_constraints.ran_incl(j).range_len;
        end loop;
        v_max_range := v_max_range - C_TIME_UNIT;
        -- It is impossible to give the same weight to an included value than to a single value in the time range,
        -- therefore we split the probability to 50% ranges and 50% included values.
        v_max_value := v_max_range * 2 when priv_time_constraints.val_incl'length > 0 else v_max_range;

        v_ret := rand(0 ns, v_max_value, msg_id_panel, proc_call);

        -- Convert the random value to the correct range
        if v_ret <= v_max_range then
          v_acc_range_len := 0 ns;
          for j in 0 to priv_time_constraints.ran_incl'length - 1 loop
            v_acc_range_len := v_acc_range_len + priv_time_constraints.ran_incl(j).range_len;
            if v_ret < v_acc_range_len then
              v_ret := v_ret + priv_time_constraints.ran_incl(j).min_value - (v_acc_range_len - priv_time_constraints.ran_incl(j).range_len);
              exit;
            end if;
          end loop;
        -- If random value isn't a range, randomize within the added values
        else
          v_ret := rand(ONLY, priv_time_constraints.val_incl.all, msg_id_panel, proc_call);
        end if;

        -- Check if the random value is in the exclusion list
        v_gen_new_random := check_value_in_vector(v_ret, priv_time_constraints.val_excl.all);
        exit when not v_gen_new_random;
        if i = (priv_time_constraints.val_excl'length) * C_NUM_INVALID_TRIES then
          alert(TB_ERROR, proc_call & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
          priv_ret_valid := false;
        end if;
      end loop;

      return v_ret;
    end function;

    -- Returns an unsigned random value supporting multiple range constraints
    impure function randm_ranges(
      constant length       : natural;
      constant msg_id_panel : t_msg_id_panel;
      constant proc_call    : string)
    return unsigned is
      alias C_MAX_LENGTH is C_RAND_MM_MAX_LONG_VECTOR_LENGTH;
      constant C_MIN_RANGE     : unsigned(C_MAX_LENGTH downto 0) := (others => '0');
      constant C_PREVIOUS_DIST : t_rand_dist                     := priv_rand_dist;
      variable v_max_range     : unsigned(C_MAX_LENGTH downto 0);
      variable v_acc_range_len : unsigned(C_MAX_LENGTH downto 0);
      variable v_ret           : unsigned(C_MAX_LENGTH downto 0);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, proc_call & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for unsigned constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Concatenate all ranges first and then the added values into a single continuous range to call rand(min,max)
      v_max_range := C_MIN_RANGE;
      for i in 0 to priv_uns_constraints.ran_incl'length - 1 loop
        v_max_range := v_max_range + priv_uns_constraints.ran_incl(i).range_len;
      end loop;
      v_max_range := v_max_range - 1;

      v_ret := rand(v_ret'length, C_MIN_RANGE, v_max_range, msg_id_panel, proc_call);

      -- Convert the random value to the correct range
      v_acc_range_len := (others => '0');
      for i in 0 to priv_uns_constraints.ran_incl'length - 1 loop
        v_acc_range_len := v_acc_range_len + priv_uns_constraints.ran_incl(i).range_len;
        if v_ret < v_acc_range_len then
          v_ret := v_ret + priv_uns_constraints.ran_incl(i).min_value - (v_acc_range_len - priv_uns_constraints.ran_incl(i).range_len);
          exit;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      return v_ret(length - 1 downto 0);
    end function;

    -- Returns a signed random value supporting multiple range constraints
    impure function randm_ranges(
      constant length       : natural;
      constant msg_id_panel : t_msg_id_panel;
      constant proc_call    : string)
    return signed is
      alias C_MAX_LENGTH is C_RAND_MM_MAX_LONG_VECTOR_LENGTH;
      constant C_MIN_RANGE     : signed(C_MAX_LENGTH downto 0) := (C_MAX_LENGTH => '1', others => '0');
      constant C_PREVIOUS_DIST : t_rand_dist                   := priv_rand_dist;
      variable v_max_range     : signed(C_MAX_LENGTH downto 0);
      variable v_acc_range_len : signed(C_MAX_LENGTH downto 0);
      variable v_ret           : signed(C_MAX_LENGTH downto 0);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, proc_call & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for signed constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Concatenate all ranges first and then the added values into a single continuous range to call rand(min,max)
      v_max_range := C_MIN_RANGE;
      for i in 0 to priv_sig_constraints.ran_incl'length - 1 loop
        v_max_range := v_max_range + priv_sig_constraints.ran_incl(i).range_len;
      end loop;
      v_max_range := v_max_range - 1;

      v_ret := rand(v_ret'length, C_MIN_RANGE, v_max_range, msg_id_panel, proc_call);

      -- Convert the random value to the correct range
      v_ret           := v_ret - C_MIN_RANGE; -- Remove offset
      v_acc_range_len := (others => '0');
      for i in 0 to priv_sig_constraints.ran_incl'length - 1 loop
        v_acc_range_len := v_acc_range_len + priv_sig_constraints.ran_incl(i).range_len;
        if v_ret < v_acc_range_len then
          v_ret := v_ret + priv_sig_constraints.ran_incl(i).min_value - (v_acc_range_len - priv_sig_constraints.ran_incl(i).range_len);
          exit;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      return v_ret(length - 1 downto 0);
    end function;

    -- Returns an integer random value with ADD and EXCL constraints
    impure function randm_add_excl(
      constant msg_id_panel : t_msg_id_panel;
      constant proc_call    : string)
    return integer is
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_ret            : integer;
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, proc_call & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      for i in 0 to (priv_int_constraints.val_excl'length) * C_NUM_INVALID_TRIES loop
        v_ret            := rand(ONLY, priv_int_constraints.val_incl.all, priv_cyclic_mode, msg_id_panel, proc_call);
        v_gen_new_random := check_value_in_vector(v_ret, priv_int_constraints.val_excl.all);
        exit when not v_gen_new_random;
        if i = (priv_int_constraints.val_excl'length) * C_NUM_INVALID_TRIES then
          alert(TB_ERROR, proc_call & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
          priv_ret_valid := false;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      return v_ret;
    end function;

    -- Returns a real random value with ADD and EXCL constraints
    impure function randm_add_excl(
      constant msg_id_panel : t_msg_id_panel;
      constant proc_call    : string)
    return real is
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random : boolean     := true;
      variable v_ret            : real;
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, proc_call & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      for i in 0 to (priv_real_constraints.val_excl'length) * C_NUM_INVALID_TRIES loop
        v_ret            := rand(ONLY, priv_real_constraints.val_incl.all, msg_id_panel, proc_call);
        v_gen_new_random := check_value_in_vector(v_ret, priv_real_constraints.val_excl.all);
        exit when not v_gen_new_random;
        if i = (priv_real_constraints.val_excl'length) * C_NUM_INVALID_TRIES then
          alert(TB_ERROR, proc_call & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
          priv_ret_valid := false;
        end if;
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      return v_ret;
    end function;

    -- Returns a time random value with ADD and EXCL constraints
    impure function randm_add_excl(
      constant msg_id_panel : t_msg_id_panel;
      constant proc_call    : string)
    return time is
      variable v_gen_new_random : boolean := true;
      variable v_ret            : time;
    begin
      -- Invalid distributions checked in randm() procedure

      for i in 0 to (priv_time_constraints.val_excl'length) * C_NUM_INVALID_TRIES loop
        v_ret            := rand(ONLY, priv_time_constraints.val_incl.all, msg_id_panel, proc_call);
        v_gen_new_random := check_value_in_vector(v_ret, priv_time_constraints.val_excl.all);
        exit when not v_gen_new_random;
        if i = (priv_time_constraints.val_excl'length) * C_NUM_INVALID_TRIES then
          alert(TB_ERROR, proc_call & "=> Random generator cannot find a legal value within the given constraints", priv_scope);
          priv_ret_valid := false;
        end if;
      end loop;

      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Integer constraints
    ------------------------------------------------------------
    procedure add_range(
      constant min_value    : in integer;
      constant max_value    : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range([" & to_string(min_value) & ":" & to_string(max_value) & "])";
    begin
      -- Check only integer constraints have been configured
      if not (check_configured_constraints("INTEGER", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.ran_incl, 1);
      increment_vec_size(priv_int_constraints.weighted, 1);
      priv_int_constraints.ran_incl(priv_int_constraints.ran_incl'length - 1).min_value := min_value;
      priv_int_constraints.ran_incl(priv_int_constraints.ran_incl'length - 1).max_value := max_value;
      priv_int_constraints.ran_incl(priv_int_constraints.ran_incl'length - 1).range_len := to_signed(max_value, 33) - to_signed(min_value, 33) + to_signed(1, 33);
      priv_int_constraints.weighted(priv_int_constraints.weighted'length - 1)           := (min_value, max_value, 1, COMBINED_WEIGHT);
    end procedure;

    procedure add_val(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      add_val((0 => value), msg_id_panel);
    end procedure;

    procedure add_val(
      constant set_of_values : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val" & to_string(set_of_values);
    begin
      -- Check only integer constraints have been configured
      if not (check_configured_constraints("INTEGER", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.val_incl, set_of_values'length);
      increment_vec_size(priv_int_constraints.weighted, set_of_values'length);
      priv_int_constraints.val_incl(priv_int_constraints.val_incl'length - 1 - (set_of_values'length - 1) to priv_int_constraints.val_incl'length - 1) := set_of_values;
      for i in 0 to set_of_values'length - 1 loop
        priv_int_constraints.weighted(priv_int_constraints.weighted'length - 1 - (set_of_values'length - 1) + i) := (set_of_values(i), set_of_values(i), 1, NA);
      end loop;
    end procedure;

    procedure excl_val(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      excl_val((0 => value), msg_id_panel);
    end procedure;

    procedure excl_val(
      constant set_of_values : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "excl_val" & to_string(set_of_values);
    begin
      -- Check only integer constraints have been configured
      if not (check_configured_constraints("INTEGER", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.val_excl, set_of_values'length);
      priv_int_constraints.val_excl(priv_int_constraints.val_excl'length - 1 - (set_of_values'length - 1) to priv_int_constraints.val_excl'length - 1) := set_of_values;
    end procedure;

    procedure add_val_weight(
      constant value        : in integer;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_weight(" & to_string(value) & "," & to_string(weight) & ")";
    begin
      -- Check only integer constraints have been configured
      if not (check_configured_constraints("INTEGER", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.weighted, 1);
      priv_int_constraints.weighted(priv_int_constraints.weighted'length - 1) := (value, value, weight, NA);
      priv_int_constraints.weighted_config                                    := true;
    end procedure;

    procedure add_range_weight(
      constant min_value    : in integer;
      constant max_value    : in integer;
      constant weight       : in natural;
      constant mode         : in t_weight_mode  := NA;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL  : string := "add_range_weight([" & to_string(min_value) & ":" & to_string(max_value) & "]," & to_string(weight) & return_string1_if_true_otherwise_string2("," & to_upper(to_string(mode)), "", mode /= NA) & ")";
      variable v_weight_mode : t_weight_mode;
    begin
      -- Check only integer constraints have been configured
      if not (check_configured_constraints("INTEGER", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      v_weight_mode                                                           := mode when mode /= NA else priv_weight_mode;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.weighted, 1);
      priv_int_constraints.weighted(priv_int_constraints.weighted'length - 1) := (min_value, max_value, weight, v_weight_mode);
      priv_int_constraints.weighted_config                                    := true;
    end procedure;

    ------------------------------------------------------------
    -- Real constraints
    ------------------------------------------------------------
    procedure add_range_real(
      constant min_value    : in real;
      constant max_value    : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range_real([" & format_real(min_value) & ":" & format_real(max_value) & "])";
    begin
      -- Check only real constraints have been configured
      if not (check_configured_constraints("REAL", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.ran_incl, 1);
      increment_vec_size(priv_real_constraints.weighted, 1);
      priv_real_constraints.ran_incl(priv_real_constraints.ran_incl'length - 1) := (min_value, max_value, max_value - min_value); -- NOTE: range is different for real than integer
      priv_real_constraints.weighted(priv_real_constraints.weighted'length - 1) := (min_value, max_value, 1, COMBINED_WEIGHT);
    end procedure;

    procedure add_val_real(
      constant value        : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      add_val_real((0 => value), msg_id_panel);
    end procedure;

    procedure add_val_real(
      constant set_of_values : in real_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_real" & format_real(set_of_values);
    begin
      -- Check only real constraints have been configured
      if not (check_configured_constraints("REAL", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.val_incl, set_of_values'length);
      increment_vec_size(priv_real_constraints.weighted, set_of_values'length);
      priv_real_constraints.val_incl(priv_real_constraints.val_incl'length - 1 - (set_of_values'length - 1) to priv_real_constraints.val_incl'length - 1) := set_of_values;
      for i in 0 to set_of_values'length - 1 loop
        priv_real_constraints.weighted(priv_real_constraints.weighted'length - 1 - (set_of_values'length - 1) + i) := (set_of_values(i), set_of_values(i), 1, NA);
      end loop;
    end procedure;

    procedure excl_val_real(
      constant value        : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      excl_val_real((0 => value), msg_id_panel);
    end procedure;

    procedure excl_val_real(
      constant set_of_values : in real_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "excl_val_real" & format_real(set_of_values);
    begin
      -- Check only real constraints have been configured
      if not (check_configured_constraints("REAL", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.val_excl, set_of_values'length);
      priv_real_constraints.val_excl(priv_real_constraints.val_excl'length - 1 - (set_of_values'length - 1) to priv_real_constraints.val_excl'length - 1) := set_of_values;
    end procedure;

    procedure add_val_weight_real(
      constant value        : in real;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_weight_real(" & format_real(value) & "," & to_string(weight) & ")";
    begin
      -- Check only real constraints have been configured
      if not (check_configured_constraints("REAL", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.weighted, 1);
      priv_real_constraints.weighted(priv_real_constraints.weighted'length - 1) := (value, value, weight, NA);
      priv_real_constraints.weighted_config                                     := true;
    end procedure;

    procedure add_range_weight_real(
      constant min_value    : in real;
      constant max_value    : in real;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range_weight_real([" & format_real(min_value) & ":" & format_real(max_value) & "]," & to_string(weight) & ")";
    begin
      -- Check only real constraints have been configured
      if not (check_configured_constraints("REAL", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.weighted, 1);
      priv_real_constraints.weighted(priv_real_constraints.weighted'length - 1) := (min_value, max_value, weight, COMBINED_WEIGHT);
      priv_real_constraints.weighted_config                                     := true;
    end procedure;

    ------------------------------------------------------------
    -- Time constraints
    ------------------------------------------------------------
    procedure add_range_time(
      constant min_value    : in time;
      constant max_value    : in time;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range_time([" & to_string(min_value) & ":" & to_string(max_value) & "])";
      constant C_TIME_UNIT  : time   := std.env.resolution_limit;
    begin
      -- Check only time constraints have been configured
      if not (check_configured_constraints("TIME", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_time_constraints.ran_incl, 1);
      increment_vec_size(priv_time_constraints.weighted, 1);
      priv_time_constraints.ran_incl(priv_time_constraints.ran_incl'length - 1) := (min_value, max_value, max_value - min_value + C_TIME_UNIT);
      priv_time_constraints.weighted(priv_time_constraints.weighted'length - 1) := (min_value, max_value, 1, COMBINED_WEIGHT);
    end procedure;

    procedure add_val_time(
      constant value        : in time;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      add_val_time((0 => value), msg_id_panel);
    end procedure;

    procedure add_val_time(
      constant set_of_values : in time_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_time" & to_string(set_of_values);
    begin
      -- Check only time constraints have been configured
      if not (check_configured_constraints("TIME", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_time_constraints.val_incl, set_of_values'length);
      increment_vec_size(priv_time_constraints.weighted, set_of_values'length);
      priv_time_constraints.val_incl(priv_time_constraints.val_incl'length - 1 - (set_of_values'length - 1) to priv_time_constraints.val_incl'length - 1) := set_of_values;
      for i in 0 to set_of_values'length - 1 loop
        priv_time_constraints.weighted(priv_time_constraints.weighted'length - 1 - (set_of_values'length - 1) + i) := (set_of_values(i), set_of_values(i), 1, NA);
      end loop;
    end procedure;

    procedure excl_val_time(
      constant value        : in time;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      excl_val_time((0 => value), msg_id_panel);
    end procedure;

    procedure excl_val_time(
      constant set_of_values : in time_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "excl_val_time" & to_string(set_of_values);
    begin
      -- Check only time constraints have been configured
      if not (check_configured_constraints("TIME", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_time_constraints.val_excl, set_of_values'length);
      priv_time_constraints.val_excl(priv_time_constraints.val_excl'length - 1 - (set_of_values'length - 1) to priv_time_constraints.val_excl'length - 1) := set_of_values;
    end procedure;

    procedure add_val_weight_time(
      constant value        : in time;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_weight_time(" & to_string(value) & "," & to_string(weight) & ")";
    begin
      -- Check only time constraints have been configured
      if not (check_configured_constraints("TIME", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_time_constraints.weighted, 1);
      priv_time_constraints.weighted(priv_time_constraints.weighted'length - 1) := (value, value, weight, NA);
      priv_time_constraints.weighted_config                                     := true;
    end procedure;

    procedure add_range_weight_time(
      constant min_value    : in time;
      constant max_value    : in time;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range_weight_time([" & to_string(min_value) & ":" & to_string(max_value) & "]," & to_string(weight) & ")";
    begin
      -- Check only time constraints have been configured
      if not (check_configured_constraints("TIME", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_time_constraints.weighted, 1);
      priv_time_constraints.weighted(priv_time_constraints.weighted'length - 1) := (min_value, max_value, weight, COMBINED_WEIGHT);
      priv_time_constraints.weighted_config                                     := true;
    end procedure;

    ------------------------------------------------------------
    -- Unsigned constraints
    ------------------------------------------------------------
    procedure add_range_unsigned(
      constant min_value    : in unsigned;
      constant max_value    : in unsigned;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range_unsigned([" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) & ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      alias C_MAX_LENGTH is C_RAND_MM_MAX_LONG_VECTOR_LENGTH;
    begin
      -- Check only unsigned constraints have been configured
      if not (check_configured_constraints("UNSIGNED", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      if min_value'length > C_RAND_MM_MAX_LONG_VECTOR_LENGTH or max_value'length > C_RAND_MM_MAX_LONG_VECTOR_LENGTH then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value and max_value lengths must be less or equal than C_RAND_MM_MAX_LONG_VECTOR_LENGTH. " & "Increase C_RAND_MM_MAX_LONG_VECTOR_LENGTH in adaptations package.", priv_scope);
        return;
      end if;
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_uns_constraints.ran_incl, 1);
      priv_uns_constraints.ran_incl(priv_uns_constraints.ran_incl'length - 1).min_value := resize(min_value, C_MAX_LENGTH);
      priv_uns_constraints.ran_incl(priv_uns_constraints.ran_incl'length - 1).max_value := resize(max_value, C_MAX_LENGTH);
      priv_uns_constraints.ran_incl(priv_uns_constraints.ran_incl'length - 1).range_len := resize(max_value, C_MAX_LENGTH + 1) - resize(min_value, C_MAX_LENGTH + 1) + 1;
    end procedure;

    ------------------------------------------------------------
    -- Signed constraints
    ------------------------------------------------------------
    procedure add_range_signed(
      constant min_value    : in signed;
      constant max_value    : in signed;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range_signed([" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) & ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      alias C_MAX_LENGTH is C_RAND_MM_MAX_LONG_VECTOR_LENGTH;
    begin
      -- Check only signed constraints have been configured
      if not (check_configured_constraints("SIGNED", C_LOCAL_CALL, is_config => true)) then
        return;
      end if;
      if min_value'length > C_RAND_MM_MAX_LONG_VECTOR_LENGTH or max_value'length > C_RAND_MM_MAX_LONG_VECTOR_LENGTH then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value and max_value lengths must be less or equal than C_RAND_MM_MAX_LONG_VECTOR_LENGTH. " & "Increase C_RAND_MM_MAX_LONG_VECTOR_LENGTH in adaptations package.", priv_scope);
        return;
      end if;
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_sig_constraints.ran_incl, 1);
      priv_sig_constraints.ran_incl(priv_sig_constraints.ran_incl'length - 1).min_value := resize(min_value, C_MAX_LENGTH);
      priv_sig_constraints.ran_incl(priv_sig_constraints.ran_incl'length - 1).max_value := resize(max_value, C_MAX_LENGTH);
      priv_sig_constraints.ran_incl(priv_sig_constraints.ran_incl'length - 1).range_len := resize(max_value, C_MAX_LENGTH + 1) - resize(min_value, C_MAX_LENGTH + 1) + 1;
    end procedure;

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_cyclic_mode(
      constant cyclic_mode  : in t_cyclic;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_cyclic_mode(" & to_upper(to_string(cyclic_mode)) & ")";
    begin
      if cyclic_mode = CYCLIC and priv_rand_dist = GAUSSIAN then
        alert(TB_ERROR, C_LOCAL_CALL & "=> Cyclic mode and " & to_upper(to_string(priv_rand_dist)) & " distribution cannot be combined.", priv_scope);
      elsif cyclic_mode = CYCLIC and priv_uniqueness = UNIQUE then
        alert(TB_ERROR, C_LOCAL_CALL & "=> Cyclic mode and uniqueness cannot be combined.", priv_scope);
      else
        log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
        priv_cyclic_mode := cyclic_mode;
      end if;
    end procedure;

    procedure set_uniqueness(
      constant uniqueness   : in t_uniqueness;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_uniqueness(" & to_upper(to_string(uniqueness)) & ")";
    begin
      if uniqueness = UNIQUE and priv_rand_dist = GAUSSIAN then
        alert(TB_ERROR, C_LOCAL_CALL & "=> Uniqueness and " & to_upper(to_string(priv_rand_dist)) & " distribution cannot be combined.", priv_scope);
      elsif uniqueness = UNIQUE and priv_cyclic_mode = CYCLIC then
        alert(TB_ERROR, C_LOCAL_CALL & "=> Uniqueness and cyclic mode cannot be combined.", priv_scope);
      else
        log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
        priv_uniqueness := uniqueness;
      end if;
    end procedure;

    procedure clear_constraints(
      constant VOID : in t_void) is
    begin
      clear_constraints(shared_msg_id_panel);
    end procedure;

    procedure clear_constraints(
      constant msg_id_panel  : in t_msg_id_panel;
      constant ext_proc_call : in string := "") is
      constant C_LOCAL_CALL : string := "clear_constraints()";
      variable v_proc_call  : line;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      log_proc_call(ID_RAND_CONF, v_proc_call.all, ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);

      DEALLOCATE(priv_int_constraints.ran_incl);
      DEALLOCATE(priv_int_constraints.val_incl);
      DEALLOCATE(priv_int_constraints.val_excl);
      DEALLOCATE(priv_int_constraints.weighted);
      priv_int_constraints.ran_incl        := new t_null_range_int_vec;
      priv_int_constraints.val_incl        := new t_null_integer_vector;
      priv_int_constraints.val_excl        := new t_null_integer_vector;
      priv_int_constraints.weighted        := new t_null_range_weight_mode_int_vec;
      priv_int_constraints.weighted_config := false;

      DEALLOCATE(priv_real_constraints.ran_incl);
      DEALLOCATE(priv_real_constraints.val_incl);
      DEALLOCATE(priv_real_constraints.val_excl);
      DEALLOCATE(priv_real_constraints.weighted);
      priv_real_constraints.ran_incl        := new t_null_range_real_vec;
      priv_real_constraints.val_incl        := new t_null_real_vector;
      priv_real_constraints.val_excl        := new t_null_real_vector;
      priv_real_constraints.weighted        := new t_null_range_weight_mode_real_vec;
      priv_real_constraints.weighted_config := false;

      DEALLOCATE(priv_time_constraints.ran_incl);
      DEALLOCATE(priv_time_constraints.val_incl);
      DEALLOCATE(priv_time_constraints.val_excl);
      DEALLOCATE(priv_time_constraints.weighted);
      priv_time_constraints.ran_incl        := new t_null_range_time_vec;
      priv_time_constraints.val_incl        := new t_null_time_vector;
      priv_time_constraints.val_excl        := new t_null_time_vector;
      priv_time_constraints.weighted        := new t_null_range_weight_mode_time_vec;
      priv_time_constraints.weighted_config := false;

      DEALLOCATE(priv_uns_constraints.ran_incl);
      priv_uns_constraints.ran_incl := new t_null_range_uns_vec;
      DEALLOCATE(priv_sig_constraints.ran_incl);
      priv_sig_constraints.ran_incl := new t_null_range_sig_vec;
    end procedure;

    procedure clear_config(
      constant VOID : in t_void) is
    begin
      clear_config(shared_msg_id_panel);
    end procedure;

    procedure clear_config(
      constant msg_id_panel : in t_msg_id_panel) is
      constant C_LOCAL_CALL : string := "clear_config()";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_name               := "**unnamed**" & fill_string(NUL, C_RAND_MAX_NAME_LENGTH - 11);
      priv_scope              := C_TB_SCOPE_DEFAULT & fill_string(NUL, C_LOG_SCOPE_WIDTH - C_TB_SCOPE_DEFAULT'length);
      priv_rand_dist          := UNIFORM;
      priv_weight_mode        := COMBINED_WEIGHT;
      priv_mean_configured    := false;
      priv_std_dev_configured := false;
      priv_mean               := 0.0;
      priv_std_dev            := 0.0;
      priv_cyclic_mode        := NON_CYCLIC;
      priv_uniqueness         := NON_UNIQUE;
      clear_constraints(msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Randomization
    ------------------------------------------------------------
    impure function randm(
      constant VOID : t_void)
    return integer is
    begin
      return randm(shared_msg_id_panel);
    end function;

    impure function randm(
      constant msg_id_panel  : t_msg_id_panel;
      constant ext_proc_call : string := "")
    return integer is
      constant C_LOCAL_CALL_1        : string  := "randm(" & get_int_constraints(VOID) & ")";
      constant C_LOCAL_CALL_2        : string  := "randm(" & to_string(priv_int_constraints.weighted.all) & ")";
      variable v_proc_call           : line;
      variable v_ran_incl_configured : std_logic;
      variable v_val_incl_configured : std_logic;
      variable v_val_excl_configured : std_logic;
      variable v_num_ranges          : natural := priv_int_constraints.ran_incl'length;
      variable v_ret                 : integer;
    begin
      create_proc_call(C_LOCAL_CALL_1, ext_proc_call, v_proc_call);
      v_ran_incl_configured := '1' when v_num_ranges > 0 else '0';
      v_val_incl_configured := '1' when priv_int_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_int_constraints.val_excl'length > 0 else '0';

      -- Check only integer constraints are configured
      if not (check_configured_constraints("INTEGER", v_proc_call.all, is_config => false)) then
        deallocate(v_proc_call);
        return v_ret;
      end if;

      ----------------------------------------
      -- WEIGHTED
      ----------------------------------------
      if priv_int_constraints.weighted_config then
        check_value(v_val_excl_configured = '0', TB_WARNING, "Exclude constraint and weighted randomization cannot be combined. Ignoring exclude constraint.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        check_value(priv_cyclic_mode /= CYCLIC, TB_WARNING, "Cyclic mode and weighted randomization cannot be combined. Ignoring cyclic configuration.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        check_value(priv_uniqueness /= UNIQUE, TB_WARNING, "Uniqueness and weighted randomization cannot be combined. Ignoring uniqueness configuration.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        v_ret := rand_range_weight_mode(priv_int_constraints.weighted.all, msg_id_panel, C_LOCAL_CALL_2);
        log(ID_RAND_GEN, C_LOCAL_CALL_2 & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
        deallocate(v_proc_call);
        return v_ret;
      end if;

      -- Assuming function is being called directly from sequencer when ext_proc_call is empty
      if ext_proc_call = "" and priv_uniqueness = UNIQUE then
        alert(TB_WARNING, v_proc_call.all & "=> Uniqueness not supported for integer type. Ignoring uniqueness configuration.", priv_scope);
      end if;

      case unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured) is
        ----------------------------------------
        -- RANGE
        ----------------------------------------
        when "100" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_int_constraints.ran_incl(0).min_value, priv_int_constraints.ran_incl(0).max_value, priv_cyclic_mode, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- SET OF VALUES
        ----------------------------------------
        when "010" =>
          v_ret := rand(ONLY, priv_int_constraints.val_incl.all, priv_cyclic_mode, msg_id_panel, v_proc_call.all);
        ----------------------------------------
        -- EXCLUDE
        ----------------------------------------
        when "001" =>
          v_ret := rand(integer'left, integer'right, EXCL, priv_int_constraints.val_excl.all, priv_cyclic_mode, msg_id_panel, v_proc_call.all);
        ----------------------------------------
        -- RANGE + SET OF VALUES
        ----------------------------------------
        when "110" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_int_constraints.ran_incl(0).min_value, priv_int_constraints.ran_incl(0).max_value, ADD,
                          priv_int_constraints.val_incl.all, priv_cyclic_mode, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- RANGE + EXCLUDE
        ----------------------------------------
        when "101" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_int_constraints.ran_incl(0).min_value, priv_int_constraints.ran_incl(0).max_value, EXCL,
                          priv_int_constraints.val_excl.all, priv_cyclic_mode, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "011" =>
          v_ret := randm_add_excl(msg_id_panel, v_proc_call.all);
        ----------------------------------------
        -- RANGE + SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "111" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_int_constraints.ran_incl(0).min_value, priv_int_constraints.ran_incl(0).max_value, ADD,
                          priv_int_constraints.val_incl.all, EXCL, priv_int_constraints.val_excl.all, priv_cyclic_mode, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- NO CONSTRAINTS
        ----------------------------------------
        when "000" =>
          v_ret := rand(integer'left, integer'right, priv_cyclic_mode, msg_id_panel, v_proc_call.all);

        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Unexpected constraints: " & to_string(unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured)), priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function randm(
      constant VOID : t_void)
    return real is
    begin
      return randm(shared_msg_id_panel);
    end function;

    impure function randm(
      constant msg_id_panel  : t_msg_id_panel;
      constant ext_proc_call : string := "")
    return real is
      constant C_LOCAL_CALL_1        : string  := "randm(" & get_real_constraints(VOID) & ")";
      constant C_LOCAL_CALL_2        : string  := "randm(" & to_string(priv_real_constraints.weighted.all) & ")";
      variable v_proc_call           : line;
      variable v_ran_incl_configured : std_logic;
      variable v_val_incl_configured : std_logic;
      variable v_val_excl_configured : std_logic;
      variable v_num_ranges          : natural := priv_real_constraints.ran_incl'length;
      variable v_ret                 : real;
    begin
      create_proc_call(C_LOCAL_CALL_1, ext_proc_call, v_proc_call);
      v_ran_incl_configured := '1' when v_num_ranges > 0 else '0';
      v_val_incl_configured := '1' when priv_real_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_real_constraints.val_excl'length > 0 else '0';

      -- Check only real constraints are configured
      if not (check_configured_constraints("REAL", v_proc_call.all, is_config => false)) then
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if priv_cyclic_mode = CYCLIC then
        alert(TB_WARNING, v_proc_call.all & "=> Cyclic mode not supported for real type. Ignoring cyclic configuration.", priv_scope);
      end if;

      ----------------------------------------
      -- WEIGHTED
      ----------------------------------------
      if priv_real_constraints.weighted_config then
        check_value(v_val_excl_configured = '0', TB_WARNING, "Exclude constraint and weighted randomization cannot be combined. Ignoring exclude constraint.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        check_value(priv_uniqueness /= UNIQUE, TB_WARNING, "Uniqueness and weighted randomization cannot be combined. Ignoring uniqueness configuration.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        v_ret := rand_range_weight_mode(priv_real_constraints.weighted.all, msg_id_panel, C_LOCAL_CALL_2);
        log(ID_RAND_GEN, C_LOCAL_CALL_2 & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
        deallocate(v_proc_call);
        return v_ret;
      end if;

      -- Assuming function is being called directly from sequencer when ext_proc_call is empty
      if ext_proc_call = "" and priv_uniqueness = UNIQUE then
        alert(TB_WARNING, v_proc_call.all & "=> Uniqueness not supported for real type. Ignoring uniqueness configuration.", priv_scope);
      end if;

      case unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured) is
        ----------------------------------------
        -- RANGE
        ----------------------------------------
        when "100" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_real_constraints.ran_incl(0).min_value, priv_real_constraints.ran_incl(0).max_value, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- SET OF VALUES
        ----------------------------------------
        when "010" =>
          v_ret := rand(ONLY, priv_real_constraints.val_incl.all, msg_id_panel, v_proc_call.all);
        ----------------------------------------
        -- EXCLUDE
        ----------------------------------------
        when "001" =>
          alert(TB_ERROR, v_proc_call.all & "=> Real random generator needs ""include"" constraints", priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
        ----------------------------------------
        -- RANGE + SET OF VALUES
        ----------------------------------------
        when "110" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_real_constraints.ran_incl(0).min_value, priv_real_constraints.ran_incl(0).max_value, ADD,
                          priv_real_constraints.val_incl.all, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- RANGE + EXCLUDE
        ----------------------------------------
        when "101" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_real_constraints.ran_incl(0).min_value, priv_real_constraints.ran_incl(0).max_value, EXCL,
                          priv_real_constraints.val_excl.all, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "011" =>
          v_ret := randm_add_excl(msg_id_panel, v_proc_call.all);
        ----------------------------------------
        -- RANGE + SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "111" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_real_constraints.ran_incl(0).min_value, priv_real_constraints.ran_incl(0).max_value, ADD,
                          priv_real_constraints.val_incl.all, EXCL, priv_real_constraints.val_excl.all, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- NO CONSTRAINTS
        ----------------------------------------
        when "000" =>
          alert(TB_ERROR, v_proc_call.all & "=> Real random generator must be constrained", priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;

        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Unexpected constraints: " & to_string(unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured)), priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function randm(
      constant VOID : t_void)
    return time is
    begin
      return randm(shared_msg_id_panel);
    end function;

    impure function randm(
      constant msg_id_panel  : t_msg_id_panel;
      constant ext_proc_call : string := "")
    return time is
      constant C_LOCAL_CALL_1        : string  := "randm(" & get_time_constraints(VOID) & ")";
      constant C_LOCAL_CALL_2        : string  := "randm(" & to_string(priv_time_constraints.weighted.all) & ")";
      variable v_proc_call           : line;
      variable v_ran_incl_configured : std_logic;
      variable v_val_incl_configured : std_logic;
      variable v_val_excl_configured : std_logic;
      variable v_num_ranges          : natural := priv_time_constraints.ran_incl'length;
      variable v_ret                 : time;
    begin
      create_proc_call(C_LOCAL_CALL_1, ext_proc_call, v_proc_call);
      v_ran_incl_configured := '1' when v_num_ranges > 0 else '0';
      v_val_incl_configured := '1' when priv_time_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_time_constraints.val_excl'length > 0 else '0';

      -- Check only time constraints are configured
      if not (check_configured_constraints("TIME", v_proc_call.all, is_config => false)) then
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_ERROR, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for time type.", priv_scope);
        deallocate(v_proc_call);
        return v_ret;
      end if;
      if priv_cyclic_mode = CYCLIC then
        alert(TB_WARNING, v_proc_call.all & "=> Cyclic mode not supported for time type. Ignoring cyclic configuration.", priv_scope);
      end if;

      ----------------------------------------
      -- WEIGHTED
      ----------------------------------------
      if priv_time_constraints.weighted_config then
        check_value(v_val_excl_configured = '0', TB_WARNING, "Exclude constraint and weighted randomization cannot be combined. Ignoring exclude constraint.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        check_value(priv_uniqueness /= UNIQUE, TB_WARNING, "Uniqueness and weighted randomization cannot be combined. Ignoring uniqueness configuration.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        v_ret := rand_range_weight_mode(priv_time_constraints.weighted.all, msg_id_panel, C_LOCAL_CALL_2);
        log(ID_RAND_GEN, C_LOCAL_CALL_2 & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
        deallocate(v_proc_call);
        return v_ret;
      end if;

      -- Assuming function is being called directly from sequencer when ext_proc_call is empty
      if ext_proc_call = "" and priv_uniqueness = UNIQUE then
        alert(TB_WARNING, v_proc_call.all & "=> Uniqueness not supported for time type. Ignoring uniqueness configuration.", priv_scope);
      end if;

      case unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured) is
        ----------------------------------------
        -- RANGE
        ----------------------------------------
        when "100" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_time_constraints.ran_incl(0).min_value, priv_time_constraints.ran_incl(0).max_value, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- SET OF VALUES
        ----------------------------------------
        when "010" =>
          v_ret := rand(ONLY, priv_time_constraints.val_incl.all, msg_id_panel, v_proc_call.all);
        ----------------------------------------
        -- EXCLUDE
        ----------------------------------------
        when "001" =>
          alert(TB_ERROR, v_proc_call.all & "=> Time random generator needs ""include"" constraints", priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
        ----------------------------------------
        -- RANGE + SET OF VALUES
        ----------------------------------------
        when "110" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_time_constraints.ran_incl(0).min_value, priv_time_constraints.ran_incl(0).max_value, ADD,
                          priv_time_constraints.val_incl.all, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- RANGE + EXCLUDE
        ----------------------------------------
        when "101" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_time_constraints.ran_incl(0).min_value, priv_time_constraints.ran_incl(0).max_value, EXCL,
                          priv_time_constraints.val_excl.all, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "011" =>
          v_ret := randm_add_excl(msg_id_panel, v_proc_call.all);
        ----------------------------------------
        -- RANGE + SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "111" =>
          if v_num_ranges = 1 then
            v_ret := rand(priv_time_constraints.ran_incl(0).min_value, priv_time_constraints.ran_incl(0).max_value, ADD,
                          priv_time_constraints.val_incl.all, EXCL, priv_time_constraints.val_excl.all, msg_id_panel, v_proc_call.all);
          else
            v_ret := randm_ranges(msg_id_panel, v_proc_call.all);
          end if;
        ----------------------------------------
        -- NO CONSTRAINTS
        ----------------------------------------
        when "000" =>
          alert(TB_ERROR, v_proc_call.all & "=> Time random generator must be constrained", priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;

        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Unexpected constraints: " & to_string(unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured)), priv_scope);
          priv_ret_valid := false;
          deallocate(v_proc_call);
          return v_ret;
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL_1        : string      := "randm(" & get_int_constraints(length, is_vector => true) & ")";
      constant C_LOCAL_CALL_2        : string      := "randm(" & to_string(priv_int_constraints.weighted.all) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_val_incl_configured : std_logic;
      variable v_val_excl_configured : std_logic;
      variable v_num_ranges          : natural     := priv_int_constraints.ran_incl'length;
      variable v_gen_new_random      : boolean     := true;
      variable v_ret                 : integer_vector(0 to length - 1);
    begin
      v_val_incl_configured := '1' when priv_int_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_int_constraints.val_excl'length > 0 else '0';

      -- Check only integer constraints are configured
      if not (check_configured_constraints("INTEGER", C_LOCAL_CALL_1, is_config => false)) then
        return v_ret;
      end if;

      if priv_int_constraints.weighted_config then
        alert(TB_ERROR, C_LOCAL_CALL_2 & "=> Weighted randomization not supported for integer_vector type.", priv_scope);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        if priv_uniqueness = UNIQUE then
          alert(TB_WARNING, C_LOCAL_CALL_1 & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and uniqueness cannot be combined. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        elsif priv_cyclic_mode = CYCLIC then
          alert(TB_WARNING, C_LOCAL_CALL_1 & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and cyclic mode cannot be combined. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        elsif (v_num_ranges > 1 or v_val_incl_configured = '1' or v_val_excl_configured = '1') then
          alert(TB_WARNING, C_LOCAL_CALL_1 & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for a single range(min/max) constraint. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        end if;
      end if;

      if priv_uniqueness = NON_UNIQUE then
        -- Generate a random value for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := randm(msg_id_panel, C_LOCAL_CALL_1);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := randm(msg_id_panel, C_LOCAL_CALL_1);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL_1 & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL_1 & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL_1         : string      := "randm(" & get_real_constraints(length, is_vector => true) & ")";
      constant C_LOCAL_CALL_2         : string      := "randm(" & to_string(priv_real_constraints.weighted.all) & ")";
      constant C_PREVIOUS_DIST        : t_rand_dist := priv_rand_dist;
      constant C_PREVIOUS_CYCLIC_MODE : t_cyclic    := priv_cyclic_mode;
      variable v_val_incl_configured  : std_logic;
      variable v_val_excl_configured  : std_logic;
      variable v_num_ranges           : natural     := priv_real_constraints.ran_incl'length;
      variable v_gen_new_random       : boolean     := true;
      variable v_ret                  : real_vector(0 to length - 1);
    begin
      v_val_incl_configured := '1' when priv_real_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_real_constraints.val_excl'length > 0 else '0';

      -- Check only real constraints are configured
      if not (check_configured_constraints("REAL", C_LOCAL_CALL_1, is_config => false)) then
        return v_ret;
      end if;

      if priv_real_constraints.weighted_config then
        alert(TB_ERROR, C_LOCAL_CALL_2 & "=> Weighted randomization not supported for real_vector type.", priv_scope);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        if priv_uniqueness = UNIQUE then
          alert(TB_WARNING, C_LOCAL_CALL_1 & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and uniqueness cannot be combined. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        elsif priv_cyclic_mode = CYCLIC then
          alert(TB_WARNING, C_LOCAL_CALL_1 & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and cyclic mode cannot be combined. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        elsif (v_num_ranges > 1 or v_val_incl_configured = '1' or v_val_excl_configured = '1') then
          alert(TB_WARNING, C_LOCAL_CALL_1 & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for a single range(min/max) constraint. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        end if;
      end if;
      if priv_cyclic_mode = CYCLIC then
        alert(TB_WARNING, C_LOCAL_CALL_1 & "=> Cyclic mode not supported for real_vector type. Ignoring cyclic configuration.", priv_scope);
        priv_cyclic_mode := NON_CYCLIC;
      end if;

      if priv_uniqueness = NON_UNIQUE then
        -- Generate a random value for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := randm(msg_id_panel, C_LOCAL_CALL_1);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := randm(msg_id_panel, C_LOCAL_CALL_1);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL_1 & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous config
      priv_rand_dist   := C_PREVIOUS_DIST;
      priv_cyclic_mode := C_PREVIOUS_CYCLIC_MODE;

      log(ID_RAND_GEN, C_LOCAL_CALL_1 & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL_1         : string   := "randm(" & get_time_constraints(length, is_vector => true) & ")";
      constant C_LOCAL_CALL_2         : string   := "randm(" & to_string(priv_time_constraints.weighted.all) & ")";
      constant C_PREVIOUS_CYCLIC_MODE : t_cyclic := priv_cyclic_mode;
      variable v_val_incl_configured  : std_logic;
      variable v_val_excl_configured  : std_logic;
      variable v_num_ranges           : natural  := priv_time_constraints.ran_incl'length;
      variable v_gen_new_random       : boolean  := true;
      variable v_ret                  : time_vector(0 to length - 1);
    begin
      v_val_incl_configured := '1' when priv_time_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_time_constraints.val_excl'length > 0 else '0';

      -- Check only time constraints are configured
      if not (check_configured_constraints("TIME", C_LOCAL_CALL_1, is_config => false)) then
        return v_ret;
      end if;

      if priv_time_constraints.weighted_config then
        alert(TB_ERROR, C_LOCAL_CALL_2 & "=> Weighted randomization not supported for time_vector type.", priv_scope);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_ERROR, C_LOCAL_CALL_1 & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for time_vector type.", priv_scope);
        return v_ret;
      end if;
      if priv_cyclic_mode = CYCLIC then
        alert(TB_WARNING, C_LOCAL_CALL_1 & "=> Cyclic mode not supported for time_vector type. Ignoring cyclic configuration.", priv_scope);
        priv_cyclic_mode := NON_CYCLIC;
      end if;

      if priv_uniqueness = NON_UNIQUE then
        -- Generate a random value for each element of the vector
        for i in 0 to length - 1 loop
          v_ret(i) := randm(msg_id_panel, C_LOCAL_CALL_1);
          exit when not priv_ret_valid;
        end loop;
      else                              -- UNIQUE
        -- Generate an unique random value for each element of the vector
        l_vector : for i in 0 to length - 1 loop
          l_unique : for j in 0 to length * C_NUM_INVALID_TRIES loop
            v_ret(i)         := randm(msg_id_panel, C_LOCAL_CALL_1);
            exit l_vector when not priv_ret_valid;
            v_gen_new_random := false when i = 0 else check_value_in_vector(v_ret(i), v_ret(0 to i - 1));
            exit l_unique when not v_gen_new_random;
            if j = length * C_NUM_INVALID_TRIES then
              alert(TB_ERROR, C_LOCAL_CALL_1 & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
              exit l_vector;
            end if;
          end loop;
        end loop;
      end if;

      -- Restore previous config
      priv_cyclic_mode := C_PREVIOUS_CYCLIC_MODE;

      log(ID_RAND_GEN, C_LOCAL_CALL_1 & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function randm(
      constant length        : positive;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_type : string         := "unsigned")
    return unsigned is
      constant C_LOCAL_CALL_1            : string  := "randm(" & string'(get_int_constraints(length)) & ")";
      constant C_LOCAL_CALL_2            : string  := "randm(" & to_string(priv_int_constraints.weighted.all) & ")";
      constant C_LOCAL_CALL_3            : string  := "randm(" & get_uns_constraints(length) & ")";
      variable v_ran_incl_configured     : std_logic;
      variable v_val_incl_configured     : std_logic;
      variable v_val_excl_configured     : std_logic;
      variable v_uns_ran_incl_configured : std_logic;
      variable v_ret_int                 : integer;
      variable v_ret                     : unsigned(length - 1 downto 0);
      variable v_check_ok                : boolean := true;
    begin
      v_ran_incl_configured     := '1' when priv_int_constraints.ran_incl'length > 0 else '0';
      v_val_incl_configured     := '1' when priv_int_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured     := '1' when priv_int_constraints.val_excl'length > 0 else '0';
      v_uns_ran_incl_configured := '1' when priv_uns_constraints.ran_incl'length > 0 else '0';

      -- Check only unsigned constraints are configured
      if not (check_configured_constraints(to_upper(ext_proc_type), C_LOCAL_CALL_1, is_config => false)) then
        return v_ret;
      end if;

      ----------------------------------------
      -- WEIGHTED
      ----------------------------------------
      if priv_int_constraints.weighted_config then
        for i in 0 to priv_int_constraints.weighted'length - 1 loop
          if priv_int_constraints.weighted(i).min_value = priv_int_constraints.weighted(i).max_value then
            v_check_ok := v_check_ok and check_parameters_within_range(length, (0 => priv_int_constraints.weighted(i).min_value), C_LOCAL_CALL_2, signed_values => false);
          else
            v_check_ok := v_check_ok and check_parameters_within_range(length, priv_int_constraints.weighted(i).min_value, priv_int_constraints.weighted(i).max_value, C_LOCAL_CALL_2, signed_values => false);
          end if;
        end loop;
        if not v_check_ok then
          return v_ret;
        end if;
        check_value(v_val_excl_configured = '0', TB_WARNING, "Exclude constraint and weighted randomization cannot be combined. Ignoring exclude constraint.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        check_value(priv_cyclic_mode /= CYCLIC, TB_WARNING, "Cyclic mode and weighted randomization cannot be combined. Ignoring cyclic configuration.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        check_value(priv_uniqueness /= UNIQUE, TB_WARNING, "Uniqueness and weighted randomization cannot be combined. Ignoring uniqueness configuration.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        v_ret_int := rand_range_weight_mode(priv_int_constraints.weighted.all, msg_id_panel, C_LOCAL_CALL_2);
        v_ret     := to_unsigned(v_ret_int, length);
        log(ID_RAND_GEN, C_LOCAL_CALL_2 & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
        return v_ret;
      end if;

      ----------------------------------------
      -- UNSIGNED CONSTRAINTS
      ----------------------------------------
      if v_uns_ran_incl_configured then
        for i in 0 to priv_uns_constraints.ran_incl'length - 1 loop
          v_check_ok := v_check_ok and check_parameters_within_range(length, priv_uns_constraints.ran_incl(i).min_value, priv_uns_constraints.ran_incl(i).max_value, C_LOCAL_CALL_3);
        end loop;
        if not v_check_ok then
          return v_ret;
        end if;
        if priv_cyclic_mode = CYCLIC then
          alert(TB_WARNING, C_LOCAL_CALL_3 & "=> Cyclic mode not supported for " & ext_proc_type & " constraints. Ignoring cyclic configuration.", priv_scope);
        end if;
        if priv_uniqueness = UNIQUE then
          alert(TB_WARNING, C_LOCAL_CALL_3 & "=> Uniqueness not supported for " & ext_proc_type & " type. Ignoring uniqueness configuration.", priv_scope);
        end if;
        v_ret := randm_ranges(length, msg_id_panel, C_LOCAL_CALL_3);
        log(ID_RAND_GEN, C_LOCAL_CALL_3 & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);

      ----------------------------------------
      -- INTEGER CONSTRAINTS
      ----------------------------------------
      else
        for i in 0 to priv_int_constraints.ran_incl'length - 1 loop
          v_check_ok := v_check_ok and check_parameters_within_range(length, priv_int_constraints.ran_incl(i).min_value, priv_int_constraints.ran_incl(i).max_value, C_LOCAL_CALL_1, signed_values => false);
        end loop;
        v_check_ok := v_check_ok and check_parameters_within_range(length, priv_int_constraints.val_incl.all, C_LOCAL_CALL_1, signed_values => false);
        v_check_ok := v_check_ok and check_parameters_within_range(length, priv_int_constraints.val_excl.all, C_LOCAL_CALL_1, signed_values => false);
        if not v_check_ok then
          return v_ret;
        end if;
        if priv_uniqueness = UNIQUE then
          alert(TB_WARNING, C_LOCAL_CALL_1 & "=> Uniqueness not supported for " & ext_proc_type & " type. Ignoring uniqueness configuration.", priv_scope);
        end if;

        case unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured) is
          ----------------------------------------
          -- RANGE | SET OF VALUES | RANGE + SET OF VALUES | RANGE + EXCLUDE | SET OF VALUES + EXCLUDE | RANGE + SET OF VALUES + EXCLUDE
          ----------------------------------------
          when "100" | "010" | "110" | "101" | "011" | "111" =>
            v_ret_int := randm(msg_id_panel, C_LOCAL_CALL_1);
            v_ret     := to_unsigned(v_ret_int, length);
          ----------------------------------------
          -- EXCLUDE
          ----------------------------------------
          when "001" =>
            v_ret := rand(length, EXCL, t_natural_vector(priv_int_constraints.val_excl.all), priv_cyclic_mode, msg_id_panel, C_LOCAL_CALL_1);
          ----------------------------------------
          -- NO CONSTRAINTS
          ----------------------------------------
          when "000" =>
            v_ret := rand(length, priv_cyclic_mode, msg_id_panel, C_LOCAL_CALL_1);

          when others =>
            alert(TB_ERROR, C_LOCAL_CALL_1 & "=> Unexpected constraints: " & to_string(unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured)), priv_scope);
            return v_ret;
        end case;
        log(ID_RAND_GEN, C_LOCAL_CALL_1 & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      end if;

      return v_ret;
    end function;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL_1            : string  := "randm(" & get_int_constraints(length) & ")";
      constant C_LOCAL_CALL_2            : string  := "randm(" & to_string(priv_int_constraints.weighted.all) & ")";
      constant C_LOCAL_CALL_3            : string  := "randm(" & get_sig_constraints(length) & ")";
      variable v_ran_incl_configured     : std_logic;
      variable v_val_incl_configured     : std_logic;
      variable v_val_excl_configured     : std_logic;
      variable v_sig_ran_incl_configured : std_logic;
      variable v_ret_int                 : integer;
      variable v_ret                     : signed(length - 1 downto 0);
      variable v_check_ok                : boolean := true;
    begin
      v_ran_incl_configured     := '1' when priv_int_constraints.ran_incl'length > 0 else '0';
      v_val_incl_configured     := '1' when priv_int_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured     := '1' when priv_int_constraints.val_excl'length > 0 else '0';
      v_sig_ran_incl_configured := '1' when priv_sig_constraints.ran_incl'length > 0 else '0';

      -- Check only signed constraints are configured
      if not (check_configured_constraints("SIGNED", C_LOCAL_CALL_1, is_config => false)) then
        return v_ret;
      end if;

      ----------------------------------------
      -- WEIGHTED
      ----------------------------------------
      if priv_int_constraints.weighted_config then
        for i in 0 to priv_int_constraints.weighted'length - 1 loop
          if priv_int_constraints.weighted(i).min_value = priv_int_constraints.weighted(i).max_value then
            v_check_ok := v_check_ok and check_parameters_within_range(length, (0 => priv_int_constraints.weighted(i).min_value), C_LOCAL_CALL_2, signed_values => true);
          else
            v_check_ok := v_check_ok and check_parameters_within_range(length, priv_int_constraints.weighted(i).min_value, priv_int_constraints.weighted(i).max_value, C_LOCAL_CALL_2, signed_values => true);
          end if;
        end loop;
        if not v_check_ok then
          return v_ret;
        end if;
        check_value(v_val_excl_configured = '0', TB_WARNING, "Exclude constraint and weighted randomization cannot be combined. Ignoring exclude constraint.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        check_value(priv_cyclic_mode /= CYCLIC, TB_WARNING, "Cyclic mode and weighted randomization cannot be combined. Ignoring cyclic configuration.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        check_value(priv_uniqueness /= UNIQUE, TB_WARNING, "Uniqueness and weighted randomization cannot be combined. Ignoring uniqueness configuration.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL_2);
        v_ret_int := rand_range_weight_mode(priv_int_constraints.weighted.all, msg_id_panel, C_LOCAL_CALL_2);
        v_ret     := to_signed(v_ret_int, length);
        log(ID_RAND_GEN, C_LOCAL_CALL_2 & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
        return v_ret;
      end if;

      ----------------------------------------
      -- SIGNED CONSTRAINTS
      ----------------------------------------
      if v_sig_ran_incl_configured then
        for i in 0 to priv_sig_constraints.ran_incl'length - 1 loop
          v_check_ok := v_check_ok and check_parameters_within_range(length, priv_sig_constraints.ran_incl(i).min_value, priv_sig_constraints.ran_incl(i).max_value, C_LOCAL_CALL_3);
        end loop;
        if not v_check_ok then
          return v_ret;
        end if;
        if priv_cyclic_mode = CYCLIC then
          alert(TB_WARNING, C_LOCAL_CALL_3 & "=> Cyclic mode not supported for signed constraints. Ignoring cyclic configuration.", priv_scope);
        end if;
        if priv_uniqueness = UNIQUE then
          alert(TB_WARNING, C_LOCAL_CALL_3 & "=> Uniqueness not supported for signed type. Ignoring uniqueness configuration.", priv_scope);
        end if;
        v_ret := randm_ranges(length, msg_id_panel, C_LOCAL_CALL_3);
        log(ID_RAND_GEN, C_LOCAL_CALL_3 & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);

      ----------------------------------------
      -- INTEGER CONSTRAINTS
      ----------------------------------------
      else
        for i in 0 to priv_int_constraints.ran_incl'length - 1 loop
          v_check_ok := v_check_ok and check_parameters_within_range(length, priv_int_constraints.ran_incl(i).min_value, priv_int_constraints.ran_incl(i).max_value, C_LOCAL_CALL_1, signed_values => true);
        end loop;
        v_check_ok := v_check_ok and check_parameters_within_range(length, priv_int_constraints.val_incl.all, C_LOCAL_CALL_1, signed_values => true);
        v_check_ok := v_check_ok and check_parameters_within_range(length, priv_int_constraints.val_excl.all, C_LOCAL_CALL_1, signed_values => true);
        if not v_check_ok then
          return v_ret;
        end if;
        if priv_uniqueness = UNIQUE then
          alert(TB_WARNING, C_LOCAL_CALL_1 & "=> Uniqueness not supported for signed type. Ignoring uniqueness configuration.", priv_scope);
        end if;

        case unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured) is
          ----------------------------------------
          -- RANGE | SET OF VALUES | RANGE + SET OF VALUES | RANGE + EXCLUDE | SET OF VALUES + EXCLUDE | RANGE + SET OF VALUES + EXCLUDE
          ----------------------------------------
          when "100" | "010" | "110" | "101" | "011" | "111" =>
            v_ret_int := randm(msg_id_panel, C_LOCAL_CALL_1);
            v_ret     := to_signed(v_ret_int, length);
          ----------------------------------------
          -- EXCLUDE
          ----------------------------------------
          when "001" =>
            v_ret := rand(length, EXCL, priv_int_constraints.val_excl.all, priv_cyclic_mode, msg_id_panel, C_LOCAL_CALL_1);
          ----------------------------------------
          -- NO CONSTRAINTS
          ----------------------------------------
          when "000" =>
            v_ret := rand(length, priv_cyclic_mode, msg_id_panel, C_LOCAL_CALL_1);

          when others =>
            alert(TB_ERROR, C_LOCAL_CALL_1 & "=> Unexpected constraints: " & to_string(signed'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured)), priv_scope);
            return v_ret;
        end case;
        log(ID_RAND_GEN, C_LOCAL_CALL_1 & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      end if;

      return v_ret;
    end function;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length - 1 downto 0);
    begin
      v_ret := randm(length, msg_id_panel, "slv");
      return std_logic_vector(v_ret);
    end function;

  end protected body t_rand;

end package body rand_pkg;
