--================================================================================================================================
-- Copyright 2020 Bitvis
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
  type t_set_type is (ONLY, ADD, EXCL);
  type t_uniqueness is (UNIQUE, NON_UNIQUE);
  type t_weight_mode is (NA, COMBINED_WEIGHT, INDIVIDUAL_WEIGHT);
  type t_cyclic is (CYCLIC, NON_CYCLIC);

  type t_val_weight_int is record
    value     : integer;
    weight    : natural;
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
    value     : real;
    weight    : natural;
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
    value     : time;
    weight    : natural;
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

  type t_val_weight_int_vec         is array (natural range <>) of t_val_weight_int;
  type t_range_weight_int_vec       is array (natural range <>) of t_range_weight_int;
  type t_range_weight_mode_int_vec  is array (natural range <>) of t_range_weight_mode_int;

  type t_val_weight_real_vec         is array (natural range <>) of t_val_weight_real;
  type t_range_weight_real_vec       is array (natural range <>) of t_range_weight_real;
  type t_range_weight_mode_real_vec  is array (natural range <>) of t_range_weight_mode_real;

  type t_val_weight_time_vec         is array (natural range <>) of t_val_weight_time;
  type t_range_weight_time_vec       is array (natural range <>) of t_range_weight_time;
  type t_range_weight_mode_time_vec  is array (natural range <>) of t_range_weight_mode_time;

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
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real);

  -- Returns an integer pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in    integer;
    constant max_value     : in    integer;
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout integer);

  -- Returns a real pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in    real;
    constant max_value     : in    real;
    constant mean          : in    real;
    constant std_deviation : in    real;
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
    -- Single-line rand() implementation
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
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
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
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_value     : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_value2    : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_values1   : real_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
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
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_value     : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_value2    : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_values1   : time_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    ------------------------------------------------------------
    -- Random integer_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    ------------------------------------------------------------
    -- Random real_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_value     : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_value2    : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_values1   : real_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector;

    ------------------------------------------------------------
    -- Random time_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_value     : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_value2    : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_values1   : time_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
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
      constant min_value     : unsigned;
      constant max_value     : unsigned;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : unsigned;
      constant max_value     : unsigned;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_value2    : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_values1   : t_natural_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
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
      constant min_value     : signed;
      constant max_value     : signed;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : signed;
      constant max_value     : signed;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed;

    ------------------------------------------------------------
    -- Random std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant min_value     : std_logic_vector;
      constant max_value     : std_logic_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : std_logic_vector;
      constant max_value     : std_logic_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_value2    : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_values1   : t_natural_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
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
    -- Multi-line rand() implementation
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
      constant set_values   : in integer_vector;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val(
      constant set_values   : in integer_vector;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

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
      constant set_values   : in real_vector;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val_real(
      constant value        : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure excl_val_real(
      constant set_values   : in real_vector;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_val_weight_real(
      constant value        : in real;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_range_weight_real(
      constant min_value    : in real;
      constant max_value    : in real;
      constant weight       : in natural;
      constant mode         : in t_weight_mode  := NA;
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
      constant msg_id_panel : in t_msg_id_panel);

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
      constant size         : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned;

  end protected t_rand;

end package rand_pkg;

package body rand_pkg is

  -- This package is used by the random cyclic queue
  package cyclic_queue_pkg is new work.generic_queue_pkg
    generic map (
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

  type t_range_int_vec  is array (natural range <>) of t_range_int;
  type t_range_real_vec is array (natural range <>) of t_range_real;
  type t_range_time_vec is array (natural range <>) of t_range_time;

  type t_range_int_vec_ptr  is access t_range_int_vec;
  type t_range_real_vec_ptr is access t_range_real_vec;
  type t_range_time_vec_ptr is access t_range_time_vec;

  type t_integer_vector_ptr is access integer_vector;
  type t_real_vector_ptr    is access real_vector;
  type t_time_vector_ptr    is access time_vector;

  type t_range_weight_mode_int_vec_ptr  is access t_range_weight_mode_int_vec;
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

  ------------------------------------------------------------
  -- Base procedures
  ------------------------------------------------------------
  -- Returns a real pseudo-random number with Gaussian distribution.
  -- It uses the Marsaglia polar method to generate a normally distributed
  -- random number from uniformly distributed random numbers.
  procedure gaussian(
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real) is
    variable v_u     : real;
    variable v_v     : real;
    variable v_s     : real;
    variable v_valid : boolean := false;
  begin
    while not(v_valid) loop
      random_uniform(-1.0, 1.0, seed1, seed2, v_u);
      random_uniform(-1.0, 1.0, seed1, seed2, v_v);
      v_s     := v_u*v_u + v_v*v_v;
      v_valid := v_s > 0.0 and v_s < 1.0;
    end loop;
    target := mean + std_deviation * v_u * sqrt((-2.0 * log(v_s))/v_s);
  end procedure;

  -- Returns an integer pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in    integer;
    constant max_value     : in    integer;
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout integer) is
    variable v_rand  : real;
    variable v_valid : boolean := false;
  begin
    if mean < real(min_value) or mean > real(max_value) then
      alert(TB_ERROR, "random_gaussian()=> Mean: " & to_string(mean,2) & " must be inside min/max range: " &
        to_string(min_value) & "," & to_string(max_value));
      target := 0;
      return;
    end if;
    while not(v_valid) loop
      gaussian(mean, std_deviation, seed1, seed2, v_rand);
      target  := integer(round(v_rand));
      v_valid := target >= min_value and target <= max_value;
    end loop;
  end procedure;

  -- Returns a real pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in    real;
    constant max_value     : in    real;
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real) is
    variable v_valid : boolean := false;
  begin
    if mean < min_value or mean > max_value then
      alert(TB_ERROR, "random_gaussian()=> Mean: " & to_string(mean,2) & " must be inside min/max range: " &
        to_string(min_value, 2) & "," & to_string(max_value, 2));
      target := 0.0;
      return;
    end if;
    while not(v_valid) loop
      gaussian(mean, std_deviation, seed1, seed2, target);
      v_valid := target >= min_value and target <= max_value;
    end loop;
  end procedure;

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_rand is protected body
    variable priv_name                    : string(1 to C_RAND_MAX_NAME_LENGTH) := "**unnamed**" & fill_string(NUL, C_RAND_MAX_NAME_LENGTH-11);
    variable priv_scope                   : string(1 to C_LOG_SCOPE_WIDTH)      := C_TB_SCOPE_DEFAULT & fill_string(NUL, C_LOG_SCOPE_WIDTH-C_TB_SCOPE_DEFAULT'length);
    variable priv_seed1                   : positive                            := C_RAND_INIT_SEED_1;
    variable priv_seed2                   : positive                            := C_RAND_INIT_SEED_2;
    variable priv_rand_dist               : t_rand_dist                         := UNIFORM;
    variable priv_weight_mode             : t_weight_mode                       := COMBINED_WEIGHT;
    variable priv_warned_same_set_type    : boolean                             := false;
    variable priv_warned_simulation_slow  : boolean                             := false;
    variable priv_cyclic_current_function : line                                := new string'("");
    variable priv_cyclic_list             : t_cyclic_list_ptr                   := NULL;
    variable priv_cyclic_list_num_items   : natural                             := 0;
    variable priv_cyclic_queue            : t_generic_queue;
    variable priv_mean_configured         : boolean                             := false;
    variable priv_std_dev_configured      : boolean                             := false;
    -- Default values for the mean and standard deviation are relative to the given range, i.e. default values below are ignored
    variable priv_mean                    : real                                := 0.0;
    variable priv_std_dev                 : real                                := 0.0;
    -- Multi-line rand() configuration
    variable priv_cyclic_mode             : t_cyclic                            := NON_CYCLIC;
    variable priv_uniqueness              : t_uniqueness                        := NON_UNIQUE;
    variable priv_int_constraints         : t_int_constraints                   := (ran_incl        => new t_range_int_vec(1 to 0),
                                                                                    val_incl        => new integer_vector(1 to 0),
                                                                                    val_excl        => new integer_vector(1 to 0),
                                                                                    weighted        => new t_range_weight_mode_int_vec(1 to 0),
                                                                                    weighted_config => false);
    variable priv_real_constraints        : t_real_constraints                  := (ran_incl        => new t_range_real_vec(1 to 0),
                                                                                    val_incl        => new real_vector(1 to 0),
                                                                                    val_excl        => new real_vector(1 to 0),
                                                                                    weighted        => new t_range_weight_mode_real_vec(1 to 0),
                                                                                    weighted_config => false);

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
      constant C_SIGNIFICANT_VALUE : real := abs(value * (10.0**C_RAND_REAL_NUM_DECIMAL_DIGITS));
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
      variable v_result : string(1 to 2 +                -- parentheses
                                 2*(values'length - 1) + -- commas
                                 32*values'length);      -- values
    begin
      if values'length = 0 then
        return "";
      else
        write(v_line, '(');
        for i in values'range loop
          write(v_line, format_real(values(i)));
          if (i < values'right) and (values'ascending) then
            write(v_line, string'(", "));
          elsif (i > values'right) and not(values'ascending) then
            write(v_line, string'(", "));
          end if;
        end loop;
        write(v_line, ')');

        v_width := v_line'length;
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
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in normalized_weighted_vector'range loop
        if normalized_weighted_vector(i).min_value = normalized_weighted_vector(i).max_value then
          write(v_line, '(');
          write(v_line, to_string(normalized_weighted_vector(i).min_value));
          write(v_line, ',');
          write(v_line, to_string(normalized_weighted_vector(i).weight));
          write(v_line, ')');
        else
          write(v_line, string'("(["));
          write(v_line, to_string(normalized_weighted_vector(i).min_value));
          write(v_line, ':');
          write(v_line, to_string(normalized_weighted_vector(i).max_value));
          write(v_line, string'("],"));
          write(v_line, to_string(normalized_weighted_vector(i).weight));
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
        if i < normalized_weighted_vector'length-1 then
          write(v_line, ',');
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    -- Overload
    impure function to_string(
      constant weighted_vector : t_range_weight_mode_real_vec)
    return string is
      alias normalized_weighted_vector : t_range_weight_mode_real_vec(0 to weighted_vector'length-1) is weighted_vector;
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in normalized_weighted_vector'range loop
        if normalized_weighted_vector(i).min_value = normalized_weighted_vector(i).max_value then
          write(v_line, '(');
          write(v_line, format_real(normalized_weighted_vector(i).min_value));
          write(v_line, ',');
          write(v_line, to_string(normalized_weighted_vector(i).weight));
          write(v_line, ')');
        else
          write(v_line, string'("(["));
          write(v_line, format_real(normalized_weighted_vector(i).min_value));
          write(v_line, ':');
          write(v_line, format_real(normalized_weighted_vector(i).max_value));
          write(v_line, string'("],"));
          write(v_line, to_string(normalized_weighted_vector(i).weight));
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
        if i < normalized_weighted_vector'length-1 then
          write(v_line, ',');
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    -- Overload
    impure function to_string(
      constant weighted_vector : t_range_weight_mode_time_vec)
    return string is
      alias normalized_weighted_vector : t_range_weight_mode_time_vec(0 to weighted_vector'length-1) is weighted_vector;
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in normalized_weighted_vector'range loop
        if normalized_weighted_vector(i).min_value = normalized_weighted_vector(i).max_value then
          write(v_line, '(');
          write(v_line, to_string(normalized_weighted_vector(i).min_value));
          write(v_line, ',');
          write(v_line, to_string(normalized_weighted_vector(i).weight));
          write(v_line, ')');
        else
          write(v_line, string'("(["));
          write(v_line, to_string(normalized_weighted_vector(i).min_value));
          write(v_line, ':');
          write(v_line, to_string(normalized_weighted_vector(i).max_value));
          write(v_line, string'("],"));
          write(v_line, to_string(normalized_weighted_vector(i).weight));
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
        if i < normalized_weighted_vector'length-1 then
          write(v_line, ',');
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
      constant msg_id          : in    t_msg_id;
      constant proc_call       : in    string;
      constant ext_proc_call   : in    string;
      variable new_proc_call   : inout line;
      constant msg_id_panel    : in    t_msg_id_panel) is
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
      constant proc_call       : in    string;
      constant ext_proc_call   : in    string;
      variable new_proc_call   : inout line) is
    begin
      log_proc_call(ID_NEVER, proc_call, ext_proc_call, new_proc_call, shared_msg_id_panel);
    end procedure;

    -- Checks that the parameters are within a valid range
    -- for the given length
    procedure check_parameters_within_range(
      constant length        : in natural;
      constant min_value     : in integer;
      constant max_value     : in integer;
      constant msg_id_panel  : in t_msg_id_panel;
      constant signed_values : in boolean) is
      constant C_PROC_NAME : string := "check_parameters_within_range";
      variable v_len : natural;
    begin
      v_len := length when length < 32 else
               31 when not(signed_values) else 32; -- Length is limited by integer size
      if signed_values then
        check_value_in_range(min_value, -2**(v_len-1), 2**(v_len-1)-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope, ID_NEVER, msg_id_panel, C_PROC_NAME);
        check_value_in_range(max_value, -2**(v_len-1), 2**(v_len-1)-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope, ID_NEVER, msg_id_panel, C_PROC_NAME);
      else
        check_value_in_range(min_value, 0, 2**v_len-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope, ID_NEVER, msg_id_panel, C_PROC_NAME);
        check_value_in_range(max_value, 0, 2**v_len-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope, ID_NEVER, msg_id_panel, C_PROC_NAME);
      end if;
    end procedure;

    -- Overload
    procedure check_parameters_within_range(
      constant length        : in natural;
      constant set_values    : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel;
      constant signed_values : in boolean) is
      constant C_PROC_NAME : string := "check_parameters_within_range";
      variable v_len : natural;
    begin
      v_len := length when length < 32 else
               31 when not(signed_values) else 32; -- Length is limited by integer size
      for i in set_values'range loop
        if signed_values then
          check_value_in_range(set_values(i), -2**(v_len-1), 2**(v_len-1)-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope, ID_NEVER, msg_id_panel, C_PROC_NAME);
        else
          check_value_in_range(set_values(i), 0, 2**v_len-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope, ID_NEVER, msg_id_panel, C_PROC_NAME);
        end if;
      end loop;
    end procedure;

    -- Generates an alert (only once)
    procedure alert_same_set_type(
      constant set_type  : in t_set_type;
      constant proc_call : in string) is
    begin
      if not(priv_warned_same_set_type) then
        alert(TB_WARNING, proc_call & "=> Used same type for both set of values: " & to_upper(to_string(set_type)), priv_scope);
        priv_warned_same_set_type := true;
      end if;
    end procedure;

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_name(
      constant name : in string) is
    begin
      if name'length > C_RAND_MAX_NAME_LENGTH then
        priv_name := name(1 to C_RAND_MAX_NAME_LENGTH);
      else
        priv_name := name & fill_string(NUL, C_RAND_MAX_NAME_LENGTH-name'length);
      end if;
    end procedure;

    impure function get_name(
      constant VOID : t_void)
    return string is
    begin
      return to_string(priv_name);
    end function;

    procedure set_scope(
      constant scope : in string) is
    begin
      if scope'length > C_LOG_SCOPE_WIDTH then
        priv_scope := scope(1 to C_LOG_SCOPE_WIDTH);
      else
        priv_scope := scope & fill_string(NUL, C_LOG_SCOPE_WIDTH-scope'length);
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
      constant C_LOCAL_CALL : string := "set_rand_dist_mean(" & to_string(mean,2) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_mean := mean;
      priv_mean_configured := true;
    end procedure;

    impure function get_rand_dist_mean(
      constant VOID : t_void)
    return real is
    begin
      if not(priv_mean_configured) then
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
      priv_mean := 0.0;
      priv_mean_configured := false;
    end procedure;

    procedure set_rand_dist_std_deviation(
      constant std_deviation : in real;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_rand_dist_std_deviation(" & to_string(std_deviation,2) & ")";
    begin
      if std_deviation > 0.0 then
        log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
        priv_std_dev := std_deviation;
        priv_std_dev_configured := true;
      else
        alert(TB_ERROR, C_LOCAL_CALL & "=> Must use positive values", priv_scope);
      end if;
    end procedure;

    impure function get_rand_dist_std_deviation(
      constant VOID : t_void)
    return real is
    begin
      if not(priv_std_dev_configured) then
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
      priv_std_dev := 0.0;
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
      constant C_PREFIX        : string := C_LOG_PREFIX & "     ";
      constant C_COLUMN1_WIDTH : positive := 19;
      constant C_COLUMN2_WIDTH : positive := C_LOG_SCOPE_WIDTH;
      variable v_line          : line;
    begin
      -- Print report header
      write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
                    "***  REPORT OF RANDOM GENERATOR CONFIGURATION ***" & LF &
                    fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

      -- Print report config
      write(v_line, "          " & justify("NAME", left, C_COLUMN1_WIDTH)               & ": " & justify(to_string(priv_name), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("SCOPE", left, C_COLUMN1_WIDTH)              & ": " & justify(to_string(priv_scope), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("SEED 1", left, C_COLUMN1_WIDTH)             & ": " & justify(to_string(priv_seed1), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("SEED 2", left, C_COLUMN1_WIDTH)             & ": " & justify(to_string(priv_seed2), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("DISTRIBUTION", left, C_COLUMN1_WIDTH)       & ": " & justify(to_upper(to_string(priv_rand_dist)), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("WEIGHT MODE", left, C_COLUMN1_WIDTH)        & ": " & justify(to_upper(to_string(priv_weight_mode)), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("MEAN CONFIGURED", left, C_COLUMN1_WIDTH)    & ": " & justify(to_string(priv_mean_configured), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("MEAN", left, C_COLUMN1_WIDTH)               & ": " & justify(to_string(priv_mean,2), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("STD_DEV CONFIGURED", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_std_dev_configured), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("STD_DEV", left, C_COLUMN1_WIDTH)            & ": " & justify(to_string(priv_std_dev,2), right, C_COLUMN2_WIDTH) & LF);

      -- Print report bottom line
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

      -- Write the info string to transcript
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH-C_PREFIX'length);
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
      for i in 1 to C_STR_LEN/2 loop
        priv_seed1 := (priv_seed1 + char_to_ascii(str(i))*128) mod C_MAX_POS;
      end loop;
      priv_seed2 := (priv_seed2 + priv_seed1) mod C_MAX_POS;
      for i in C_STR_LEN/2+1 to C_STR_LEN loop
        priv_seed2 := (priv_seed2 + char_to_ascii(str(i))*128) mod C_MAX_POS;
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
    -- Single-line rand() implementation
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
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" & to_string_if_enabled(cyclic_mode) & ")";
      constant C_NUM_VALUES    : unsigned(32 downto 0) := unsigned(to_signed(max_value,33) - to_signed(min_value,33) + to_signed(1,33));
      constant C_USE_LIST      : boolean := C_NUM_VALUES <= C_RAND_CYCLIC_LIST_MAX_NUM_VALUES;
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      variable v_proc_call     : line;
      variable v_mean          : real;
      variable v_std_dev       : real;
      variable v_ret           : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        return 0;
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
              if priv_cyclic_queue.get_count(VOID) > C_RAND_CYCLIC_QUEUE_MAX_ALERT and not(priv_warned_simulation_slow) and not(C_RAND_CYCLIC_QUEUE_MAX_ALERT_DISABLE) then
                alert(TB_WARNING, v_proc_call.all & "=> Simulation might slow down due to the cyclic queue and the large number of cyclic iterations.\n" &
                  "To disable this alert set C_RAND_CYCLIC_QUEUE_MAX_ALERT_DISABLE to true in adaptations_pkg.", priv_scope);
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
          v_mean    := priv_mean when priv_mean_configured else (real(min_value) + (real(max_value) - real(min_value))/2.0);
          v_std_dev := priv_std_dev when priv_std_dev_configured else ((real(max_value) - real(min_value))/6.0);
          random_gaussian(min_value, max_value, v_mean, v_std_dev, priv_seed1, priv_seed2, v_ret);

        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope);
          return 0;
      end case;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL : string := "rand(" & to_upper(to_string(set_type)) & ":" & to_string(set_values) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST    : t_rand_dist := priv_rand_dist;
      variable v_proc_call        : line;
      alias normalized_set_values : integer_vector(0 to set_values'length-1) is set_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if set_type /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type)), priv_scope);
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value within the set of values
      v_ret := rand(0, set_values'length-1, cyclic_mode, msg_id_panel, v_proc_call.all);

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      variable v_set_values : integer_vector(0 to 0) := (0 => set_value);
    begin
      return rand(min_value, max_value, set_type, v_set_values, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST    : t_rand_dist := priv_rand_dist;
      variable v_proc_call        : line;
      alias normalized_set_values : integer_vector(0 to set_values'length-1) is set_values;
      variable v_gen_new_random   : boolean := true;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      if set_type = ADD then
        -- Avoid an integer overflow by adding the set_values to the max_value or subtracting them from the min_value
        if max_value <= integer'right-set_values'length then
          v_ret := rand(min_value, max_value+set_values'length, cyclic_mode, msg_id_panel, v_proc_call.all);
          if v_ret > max_value then
            v_ret := normalized_set_values(v_ret-max_value-1);
          end if;
        elsif min_value >= integer'left+set_values'length then
          v_ret := rand(min_value-set_values'length, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
          if v_ret < min_value then
            v_ret := normalized_set_values(min_value-v_ret-1);
          end if;
        else
          alert(TB_ERROR, v_proc_call.all & "=> Constraints are greater than integer's range", priv_scope);
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif set_type = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type)), priv_scope);
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_combined_set_values : integer_vector(0 to set_values1'length+set_values2'length-1);
      variable v_gen_new_random      : boolean := true;
      variable v_ret                 : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Create a new set of values in case both are the same type
      if (set_type1 = ADD and set_type2 = ADD) or (set_type1 = EXCL and set_type2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_values1'length then
            v_combined_set_values(i) := set_values1(i);
          else
            v_combined_set_values(i) := set_values2(i-set_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if set_type1 = ADD and set_type2 = ADD then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, ADD, v_combined_set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif set_type1 = EXCL and set_type2 = EXCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif set_type1 = ADD and set_type2 = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, ADD, set_values1, cyclic_mode, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values2);
        end loop;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif set_type1 = EXCL and set_type2 = ADD then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, ADD, set_values2, cyclic_mode, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values1);
        end loop;
      else
        if not(set_type1 = ADD or set_type1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type1)), priv_scope);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type2)), priv_scope);
        end if;
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
      variable v_proc_call : line;
      variable v_mean      : real;
      variable v_std_dev   : real;
      variable v_ret       : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        return 0.0;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      case priv_rand_dist is
        when UNIFORM =>
          random_uniform(min_value, max_value, priv_seed1, priv_seed2, v_ret);
        when GAUSSIAN =>
          -- Default values for the mean and standard deviation are relative to the given range
          v_mean    := priv_mean when priv_mean_configured else (min_value + (max_value - min_value)/2.0);
          v_std_dev := priv_std_dev when priv_std_dev_configured else ((max_value - min_value)/6.0);
          random_gaussian(min_value, max_value, v_mean, v_std_dev, priv_seed1, priv_seed2, v_ret);
        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope);
          return 0.0;
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand(" & to_upper(to_string(set_type)) & ":" & format_real(set_values) & ")";
      constant C_PREVIOUS_DIST    : t_rand_dist := priv_rand_dist;
      variable v_proc_call        : line;
      alias normalized_set_values : real_vector(0 to set_values'length-1) is set_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if set_type /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type)), priv_scope);
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value within the set of values
      v_ret := rand(0, set_values'length-1, NON_CYCLIC, msg_id_panel, v_proc_call.all);

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_value     : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real is
      variable v_set_values : real_vector(0 to 0) := (0 => set_value);
    begin
      return rand(min_value, max_value, set_type, v_set_values, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "], " &
        to_upper(to_string(set_type)) & ":" & format_real(set_values) & ")";
      constant C_PREVIOUS_DIST    : t_rand_dist := priv_rand_dist;
      variable v_proc_call        : line;
      variable v_gen_new_random   : boolean := true;
      variable v_ret              : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      -- It is impossible to give the same weight to an added value than to a single value in the real range,
      -- therefore we split the probability to 50% range and 50% added values.
      if set_type = ADD then
        v_ret := rand(min_value, max_value + (max_value-min_value), msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := rand(ONLY, set_values, msg_id_panel, v_proc_call.all);
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif set_type = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type)), priv_scope);
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_value2    : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real is
      variable v_set_values1 : real_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : real_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real is
      variable v_set_values1 : real_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_values1   : real_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "], " &
        to_upper(to_string(set_type1)) & ":" & format_real(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & format_real(set_values2) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_combined_set_values : real_vector(0 to set_values1'length+set_values2'length-1);
      variable v_gen_new_random      : boolean := true;
      variable v_ret                 : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Create a new set of values in case both are the same type
      if (set_type1 = ADD and set_type2 = ADD) or (set_type1 = EXCL and set_type2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_values1'length then
            v_combined_set_values(i) := set_values1(i);
          else
            v_combined_set_values(i) := set_values2(i-set_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if set_type1 = ADD and set_type2 = ADD then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, ADD, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif set_type1 = EXCL and set_type2 = EXCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif set_type1 = ADD and set_type2 = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, ADD, set_values1, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values2);
        end loop;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif set_type1 = EXCL and set_type2 = ADD then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, ADD, set_values2, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values1);
        end loop;
      else
        if not(set_type1 = ADD or set_type1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type1)), priv_scope);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type2)), priv_scope);
        end if;
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
      variable v_proc_call : line;
      variable v_ret       : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        return 0 ns;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      case priv_rand_dist is
        when UNIFORM =>
          random_uniform(min_value, max_value, priv_seed1, priv_seed2, v_ret);
        when GAUSSIAN =>
          alert(TB_ERROR, v_proc_call.all & "=> Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope);
          return 0 ns;
        when others =>
          alert(TB_ERROR, v_proc_call.all & "=> Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope);
          return 0 ns;
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand(" & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      variable v_proc_call        : line;
      alias normalized_set_values : time_vector(0 to set_values'length-1) is set_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if set_type /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type)), priv_scope);
      end if;

      -- Generate a random value within the set of values
      v_ret := rand(0, set_values'length-1, NON_CYCLIC, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_value     : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time is
      variable v_set_values : time_vector(0 to 0) := (0 => set_value);
    begin
      return rand(min_value, max_value, set_type, v_set_values, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_proc_call        : line;
      alias normalized_set_values : time_vector(0 to set_values'length-1) is set_values;
      variable v_gen_new_random   : boolean := true;
      variable v_ret              : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      if set_type = ADD then
        v_ret := rand(min_value, max_value+(set_values'length*C_TIME_UNIT), msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values((v_ret-max_value)/C_TIME_UNIT-1);
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif set_type = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type)), priv_scope);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_value2    : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time is
      variable v_set_values1 : time_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : time_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time is
      variable v_set_values1 : time_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, msg_id_panel);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_values1   : time_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_proc_call           : line;
      variable v_combined_set_values : time_vector(0 to set_values1'length+set_values2'length-1);
      variable v_gen_new_random      : boolean := true;
      variable v_ret                 : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Create a new set of values in case both are the same type
      if (set_type1 = ADD and set_type2 = ADD) or (set_type1 = EXCL and set_type2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_values1'length then
            v_combined_set_values(i) := set_values1(i);
          else
            v_combined_set_values(i) := set_values2(i-set_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if set_type1 = ADD and set_type2 = ADD then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, ADD, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif set_type1 = EXCL and set_type2 = EXCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif set_type1 = ADD and set_type2 = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, ADD, set_values1, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values2);
        end loop;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif set_type1 = EXCL and set_type2 = ADD then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, ADD, set_values2, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values1);
        end loop;
      else
        if not(set_type1 = ADD or set_type1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type1)), priv_scope);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Invalid parameter: " & to_upper(to_string(set_type2)), priv_scope);
        end if;
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random integer_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" &
        to_string_if_enabled(uniqueness) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST   : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random  : boolean     := true;
      variable v_cyclic_mode     : t_cyclic    := cyclic_mode;
      variable v_ret             : integer_vector(0 to size-1);
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
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        if (max_value - min_value + 1) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        to_string_if_enabled(uniqueness) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST   : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random  : boolean     := true;
      variable v_cyclic_mode     : t_cyclic    := cyclic_mode;
      variable v_ret             : integer_vector(0 to size-1);
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
        for i in 0 to size-1 loop
          v_ret(i) := rand(set_type, set_values, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        if (set_values'length) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value within the set of values for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(set_type, set_values, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      variable v_set_values : integer_vector(0 to 0) := (0 => set_value);
    begin
      return rand(size, min_value, max_value, set_type, v_set_values, uniqueness, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & to_string_if_enabled(uniqueness) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST   : t_rand_dist := priv_rand_dist;
      variable v_set_values_len  : integer     := 0;
      variable v_gen_new_random  : boolean     := true;
      variable v_cyclic_mode     : t_cyclic    := cyclic_mode;
      variable v_ret             : integer_vector(0 to size-1);
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
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type, set_values, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        v_set_values_len := (0-set_values'length) when set_type = EXCL else set_values'length;
        if (max_value - min_value + 1 + v_set_values_len) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type, set_values, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, uniqueness, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, uniqueness, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " & to_upper(to_string(set_type2)) & ":" & to_string(set_values2) &
        to_string_if_enabled(uniqueness) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST   : t_rand_dist := priv_rand_dist;
      variable v_set_values_len  : integer     := 0;
      variable v_gen_new_random  : boolean     := true;
      variable v_cyclic_mode     : t_cyclic    := cyclic_mode;
      variable v_ret             : integer_vector(0 to size-1);
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
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        v_set_values_len := (0-set_values1'length) when set_type1 = EXCL else set_values1'length;
        v_set_values_len := (v_set_values_len-set_values2'length) when set_type2 = EXCL else v_set_values_len+set_values2'length;
        if (max_value - min_value + 1 + v_set_values_len) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, v_cyclic_mode, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
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
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "]" &
        to_string_if_enabled(uniqueness) & ")";
      constant C_PREVIOUS_DIST   : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : real_vector(0 to size-1);
    begin
      if uniqueness = UNIQUE and priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and uniqueness cannot be combined. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to size-1 loop
          v_gen_new_random := true;
          while v_gen_new_random loop
            v_ret(i) := rand(min_value, max_value, msg_id_panel, C_LOCAL_CALL);
            if i > 0 then
              v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
            else
              v_gen_new_random := false;
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
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", " & to_upper(to_string(set_type)) & ":" & format_real(set_values) &
        to_string_if_enabled(uniqueness) & ")";
      constant C_PREVIOUS_DIST   : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : real_vector(0 to size-1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value within the set of values for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(set_type, set_values, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        if (set_values'length) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value within the set of values for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(set_type, set_values, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_value     : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      variable v_set_values : real_vector(0 to 0) := (0 => set_value);
    begin
      return rand(size, min_value, max_value, set_type, v_set_values, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "], " &
        to_upper(to_string(set_type)) & ":" & format_real(set_values) & to_string_if_enabled(uniqueness) & ")";
      constant C_PREVIOUS_DIST   : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : real_vector(0 to size-1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type, set_values, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to size-1 loop
          v_gen_new_random := true;
          while v_gen_new_random loop
            v_ret(i) := rand(min_value, max_value, set_type, set_values, msg_id_panel, C_LOCAL_CALL);
            if i > 0 then
              v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
            else
              v_gen_new_random := false;
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
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_value2    : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      variable v_set_values1 : real_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : real_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      variable v_set_values1 : real_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_values1   : real_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return real_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & format_real(min_value) & ":" & format_real(max_value) & "], " &
        to_upper(to_string(set_type1)) & ":" & format_real(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & format_real(set_values2) & to_string_if_enabled(uniqueness) & ")";
      constant C_PREVIOUS_DIST   : t_rand_dist := priv_rand_dist;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : real_vector(0 to size-1);
    begin
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to size-1 loop
          v_gen_new_random := true;
          while v_gen_new_random loop
            v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, msg_id_panel, C_LOCAL_CALL);
            if i > 0 then
              v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
            else
              v_gen_new_random := false;
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
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" &
        to_string_if_enabled(uniqueness) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : time_vector(0 to size-1);
    begin
      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        if ((max_value - min_value)/C_TIME_UNIT + 1) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        to_string_if_enabled(uniqueness) & ")";
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : time_vector(0 to size-1);
    begin
      if uniqueness = NON_UNIQUE then
        -- Generate a random value within the set of values for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(set_type, set_values, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        if (set_values'length) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value within the set of values for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(set_type, set_values, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_value     : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      variable v_set_values : time_vector(0 to 0) := (0 => set_value);
    begin
      return rand(size, min_value, max_value, set_type, v_set_values, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & to_string_if_enabled(uniqueness) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_set_values_len  : integer := 0;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : time_vector(0 to size-1);
    begin
      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type, set_values, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        v_set_values_len := (0-set_values'length) when set_type = EXCL else set_values'length;
        if ((max_value - min_value)/C_TIME_UNIT + 1 + v_set_values_len) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type, set_values, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_value2    : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      variable v_set_values1 : time_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : time_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      variable v_set_values1 : time_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, uniqueness, msg_id_panel);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_values1   : time_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return time_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & to_string_if_enabled(uniqueness) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_set_values_len  : integer := 0;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : time_vector(0 to size-1);
    begin
      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        v_set_values_len := (0-set_values1'length) when set_type1 = EXCL else set_values1'length;
        v_set_values_len := (v_set_values_len-set_values2'length) when set_type2 = EXCL else v_set_values_len+set_values2'length;
        if ((max_value - min_value)/C_TIME_UNIT + 1 + v_set_values_len) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
        else
          -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
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
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & to_string_if_enabled(cyclic_mode) & ")";
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      variable v_proc_call     : line;
      variable v_ret_int       : integer;
      variable v_ret           : unsigned(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if length <= 31 then
        -- Generate a random value in the range [min_value:max_value]
        v_ret_int := rand(0, 2**length-1, cyclic_mode, msg_id_panel, v_proc_call.all);
        v_ret     := to_unsigned(v_ret_int,length);

      -- Long vectors use different randomization (does not support distributions or cyclic)
      else
        if priv_rand_dist = GAUSSIAN then
          alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for long vectors. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        end if;
        if cyclic_mode = CYCLIC then
          alert(TB_WARNING, v_proc_call.all & "=> Vector is too big for cyclic mode", priv_scope);
        end if;

        -- Generate a random value for each bit of the vector
        for i in 0 to length-1 loop
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
      constant min_value     : unsigned;
      constant max_value     : unsigned;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) &
        ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      variable v_ret : unsigned(MAXIMUM(min_value'length,max_value'length)-1 downto 0);
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
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) &
        ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      constant C_LEFTMOST_BIT  : natural := find_leftmost(max_value - min_value, '1');
      variable v_proc_call     : line;
      variable v_valid         : boolean := false;
      variable v_ret           : unsigned(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if min_value >= max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        return v_ret;
      end if;
      if min_value'length > length or max_value'length > length then
        alert(TB_ERROR, v_proc_call.all & "=> min_value and max_value lengths must be less or equal than length", priv_scope);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for long vectors. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      while not(v_valid) loop
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
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" &
        to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret_int   : integer;
      variable v_ret       : unsigned(length-1 downto 0);
    begin
      -- Generate a random value in the range [min_value:max_value]
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => false);
      v_ret_int := rand(min_value, max_value, cyclic_mode, msg_id_panel, C_LOCAL_CALL);
      v_ret     := to_unsigned(v_ret_int,length);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        to_string_if_enabled(cyclic_mode) & ")";
      variable v_gen_new_random  : boolean := true;
      variable v_unsigned        : unsigned(length-1 downto 0);
      variable v_ret_int         : integer;
      variable v_ret             : unsigned(length-1 downto 0);
    begin
      check_parameters_within_range(length, integer_vector(set_values), msg_id_panel, signed_values => false);
      -- Generate a random value within the set of values
      if set_type = ONLY then
        v_ret_int := rand(ONLY, integer_vector(set_values), cyclic_mode, msg_id_panel, C_LOCAL_CALL);
        v_ret     := to_unsigned(v_ret_int,length);
      -- Generate a random value in the vector's range minus the set of values
      elsif set_type = EXCL then
        -- Check whether the vector's range can handle cyclic mode
        if length < 32 then
          v_ret_int := rand(0, 2**length-1, EXCL, integer_vector(set_values), cyclic_mode, msg_id_panel, C_LOCAL_CALL);
          v_ret     := to_unsigned(v_ret_int,length);
        else
          if cyclic_mode = CYCLIC then
            alert(TB_WARNING, C_LOCAL_CALL & "=> Range is too big for cyclic mode (min: 0, max: 2**" & to_string(length) & "-1)", priv_scope);
          end if;
          while v_gen_new_random loop
            v_unsigned := rand(length, NON_CYCLIC, msg_id_panel, C_LOCAL_CALL);
            -- If the random value is outside the integer range it cannot be in the exclude list
            if v_unsigned > integer'right then
              v_gen_new_random := false;
            else
              v_gen_new_random := check_value_in_vector(to_integer(v_unsigned), integer_vector(set_values));
            end if;
          end loop;
          v_ret := v_unsigned;
        end if;
      else
        alert(TB_ERROR, C_LOCAL_CALL & "=> Invalid parameter: " & to_upper(to_string(set_type)), priv_scope);
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_set_values : t_natural_vector(0 to 0) := (0 => set_value);
    begin
      return rand(length, min_value, max_value, set_type, v_set_values, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret_int   : integer;
      variable v_ret       : unsigned(length-1 downto 0);
    begin
      -- Generate a random value in the range [min_value:max_value], plus or minus the set of values
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => false);
      check_parameters_within_range(length, integer_vector(set_values), msg_id_panel, signed_values => false);
      v_ret_int := rand(min_value, max_value, set_type, integer_vector(set_values), cyclic_mode, msg_id_panel, C_LOCAL_CALL);
      v_ret     := to_unsigned(v_ret_int,length);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_value2    : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : t_natural_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_values1   : t_natural_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret_int : integer;
      variable v_ret     : unsigned(length-1 downto 0);
    begin
      -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => false);
      check_parameters_within_range(length, integer_vector(set_values1), msg_id_panel, signed_values => false);
      check_parameters_within_range(length, integer_vector(set_values2), msg_id_panel, signed_values => false);
      v_ret_int := rand(min_value, max_value, set_type1, integer_vector(set_values1), set_type2, integer_vector(set_values2), cyclic_mode, msg_id_panel, C_LOCAL_CALL);
      v_ret     := to_unsigned(v_ret_int,length);

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
      variable v_proc_call : line;
      variable v_ret_int   : integer;
      variable v_ret_uns   : unsigned(length-1 downto 0);
      variable v_ret       : signed(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if length <= 32 then
        -- Generate a random value in the range [min_value:max_value]
        v_ret_int := rand(-2**(length-1), 2**(length-1)-1, cyclic_mode, msg_id_panel, v_proc_call.all);
        v_ret     := to_signed(v_ret_int,length);

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
      constant min_value     : signed;
      constant max_value     : signed;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string := "rand(RANGE:[" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) &
        ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      variable v_ret : signed(MAXIMUM(min_value'length,max_value'length)-1 downto 0);
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
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value, HEX, KEEP_LEADING_0, INCL_RADIX) &
        ":" & to_string(max_value, HEX, KEEP_LEADING_0, INCL_RADIX) & "])";
      constant C_PREVIOUS_DIST : t_rand_dist := priv_rand_dist;
      constant C_LEFTMOST_BIT  : natural := find_leftmost(max_value - min_value, '1');
      variable v_proc_call     : line;
      variable v_valid         : boolean := false;
      variable v_ret           : signed(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if min_value >= max_value then
        alert(TB_ERROR, v_proc_call.all & "=> min_value must be less than max_value", priv_scope);
        return v_ret;
      end if;
      if min_value'length > length or max_value'length > length then
        alert(TB_ERROR, v_proc_call.all & "=> min_value and max_value lengths must be less or equal than length", priv_scope);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution not supported for long vectors. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      while not(v_valid) loop
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
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "]" &
        to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret : integer;
    begin
      -- Generate a random value in the range [min_value:max_value]
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => true);
      v_ret := rand(min_value, max_value, cyclic_mode, msg_id_panel, C_LOCAL_CALL);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return to_signed(v_ret,length);
    end function;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        to_string_if_enabled(cyclic_mode) & ")";
      variable v_gen_new_random  : boolean := true;
      variable v_signed          : signed(length-1 downto 0);
      variable v_ret_int         : integer;
      variable v_ret             : signed(length-1 downto 0);
    begin
      check_parameters_within_range(length, set_values, msg_id_panel, signed_values => true);
      -- Generate a random value within the set of values
      if set_type = ONLY then
        v_ret_int := rand(ONLY, integer_vector(set_values), cyclic_mode, msg_id_panel, C_LOCAL_CALL);
        v_ret     := to_signed(v_ret_int,length);
      -- Generate a random value in the vector's range minus the set of values
      elsif set_type = EXCL then
        -- Check whether the vector's range can handle cyclic mode
        if length < 33 then
          v_ret_int := rand(-2**(length-1), 2**(length-1)-1, EXCL, integer_vector(set_values), cyclic_mode, msg_id_panel, C_LOCAL_CALL);
          v_ret     := to_signed(v_ret_int,length);
        else
          if cyclic_mode = CYCLIC then
            alert(TB_WARNING, C_LOCAL_CALL & "=> Range is too big for cyclic mode (min: -2**" & to_string(length-1) & ", max: 2**" & to_string(length-1) & "-1)", priv_scope);
          end if;
          while v_gen_new_random loop
            v_signed := rand(length, NON_CYCLIC, msg_id_panel, C_LOCAL_CALL);
            -- If the random value is outside the integer range it cannot be in the exclude list
            if v_signed > integer'right or v_signed < integer'left then
              v_gen_new_random := false;
            else
              v_gen_new_random := check_value_in_vector(to_integer(v_signed), set_values);
            end if;
          end loop;
          v_ret := v_signed;
        end if;
      else
        alert(TB_ERROR, C_LOCAL_CALL & "=> Invalid parameter: " & to_upper(to_string(set_type)), priv_scope);
      end if;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_set_values : integer_vector(0 to 0) := (0 => set_value);
    begin
      return rand(length, min_value, max_value, set_type, v_set_values, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret : integer;
    begin
      -- Generate a random value in the range [min_value:max_value], plus or minus the set of values
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => true);
      check_parameters_within_range(length, set_values, msg_id_panel, signed_values => true);
      v_ret := rand(min_value, max_value, set_type, integer_vector(set_values), cyclic_mode, msg_id_panel, C_LOCAL_CALL);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return to_signed(v_ret,length);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", RANGE:[" & to_string(min_value) & ":" & to_string(max_value) & "], " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & to_string_if_enabled(cyclic_mode) & ")";
      variable v_ret : integer;
    begin
      -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => true);
      check_parameters_within_range(length, set_values1, msg_id_panel, signed_values => true);
      check_parameters_within_range(length, set_values2, msg_id_panel, signed_values => true);
      v_ret := rand(min_value, max_value, set_type1, integer_vector(set_values1), set_type2, integer_vector(set_values2), cyclic_mode, msg_id_panel, C_LOCAL_CALL);

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return to_signed(v_ret,length);
    end function;

    ------------------------------------------------------------
    -- Random std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant min_value     : std_logic_vector;
      constant max_value     : std_logic_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(max_value'length-1 downto 0);
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
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, unsigned(min_value), unsigned(max_value), msg_id_panel, ext_proc_call);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, set_type, set_values, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_set_values : t_natural_vector(0 to 0) := (0 => set_value);
    begin
      return rand(length, min_value, max_value, set_type, v_set_values, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, set_type, set_values, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_value2    : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : t_natural_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_values1   : t_natural_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, set_type1, set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel);
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
      constant C_LOCAL_CALL : string := "rand(STD_LOGIC)";
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
      constant C_LOCAL_CALL : string := "rand(BOOL)";
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
      constant C_LOCAL_CALL_1 : string := "rand(" & to_string(weighted_vector) & ")";
      constant C_LOCAL_CALL_2 : string := "rand_range_weight_mode(" & to_string(weighted_vector) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_mode                : t_weight_mode;
      variable v_acc_weight          : natural := 0;
      variable v_acc_weighted_vector : t_natural_vector(0 to weighted_vector'length-1);
      variable v_weight_idx          : natural := 0;
      variable v_values_in_range     : natural := 0;
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
          return 0;
        end if;
        v_mode := weighted_vector(i).mode when weighted_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weighted_vector(i).weight;
        -- Use the same weight for each value in the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          v_values_in_range := weighted_vector(i).max_value - weighted_vector(i).min_value + 1;
          v_acc_weight := v_acc_weight + weighted_vector(i).weight*v_values_in_range;
        end if;
        v_acc_weighted_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope);
        return 0;
      end if;

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and weighted randomization cannot be combined. Ignoring " &
          to_upper(to_string(priv_rand_dist)) & " configuration.", priv_scope);
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
      constant C_LOCAL_CALL_1 : string := "rand(" & to_string(weighted_vector) & ")";
      constant C_LOCAL_CALL_2 : string := "rand_range_weight_mode(" & to_string(weighted_vector) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_mode                : t_weight_mode;
      variable v_acc_weight          : natural := 0;
      variable v_acc_weighted_vector : t_natural_vector(0 to weighted_vector'length-1);
      variable v_weight_idx          : natural := 0;
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
          return 0.0;
        end if;
        v_mode := weighted_vector(i).mode when weighted_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weighted_vector(i).weight;
        -- Use the same weight for each value in the range -> Not possible to know every value within the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          alert(TB_ERROR, v_proc_call.all & "=> INDIVIDUAL_WEIGHT not supported for real type", priv_scope);
          return 0.0;
        end if;
        v_acc_weighted_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope);
        return 0.0;
      end if;

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and weighted randomization cannot be combined. Ignoring " &
          to_upper(to_string(priv_rand_dist)) & " configuration.", priv_scope);
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
      constant C_LOCAL_CALL_1 : string := "rand(" & to_string(weighted_vector) & ")";
      constant C_LOCAL_CALL_2 : string := "rand_range_weight_mode(" & to_string(weighted_vector) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_proc_call           : line;
      variable v_mode                : t_weight_mode;
      variable v_acc_weight          : natural := 0;
      variable v_acc_weighted_vector : t_natural_vector(0 to weighted_vector'length-1);
      variable v_weight_idx          : natural := 0;
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
          return std.env.resolution_limit;
        end if;
        v_mode := weighted_vector(i).mode when weighted_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weighted_vector(i).weight;
        -- Use the same weight for each value in the range -> Not possible to know every value within the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          alert(TB_ERROR, v_proc_call.all & "=> INDIVIDUAL_WEIGHT not supported for time type", priv_scope);
          return std.env.resolution_limit;
        end if;
        v_acc_weighted_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope);
        return std.env.resolution_limit;
      end if;

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and weighted randomization cannot be combined. Ignoring " &
          to_upper(to_string(priv_rand_dist)) & " configuration.", priv_scope);
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
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_val_weight(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_range_weight(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      variable v_ret : unsigned(0 to length-1);
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
      variable v_ret : signed(0 to length-1);
    begin
      v_ret := to_signed(rand_val_weight(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_ret : signed(0 to length-1);
    begin
      v_ret := to_signed(rand_range_weight(weighted_vector, msg_id_panel), length);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return signed is
      variable v_ret : signed(0 to length-1);
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
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_val_weight(weighted_vector, msg_id_panel), length);
      return std_logic_vector(v_ret);
    end function;

    impure function rand_range_weight(
      constant length          : positive;
      constant weighted_vector : t_range_weight_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_range_weight(weighted_vector, msg_id_panel), length);
      return std_logic_vector(v_ret);
    end function;

    impure function rand_range_weight_mode(
      constant length          : positive;
      constant weighted_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel    : t_msg_id_panel := shared_msg_id_panel)
    return std_logic_vector is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_range_weight_mode(weighted_vector, msg_id_panel), length);
      return std_logic_vector(v_ret);
    end function;

    ------------------------------------------------------------------------------------------------------------------------------
    -- ***************************************************************************************************************************
    -- Multi-line rand() implementation
    -- ***************************************************************************************************************************
    ------------------------------------------------------------------------------------------------------------------------------
    -- Increases the size of the vector pointer variable
    procedure increment_vec_size(
      variable ran_vector : inout t_range_int_vec_ptr;
      constant increment  : in    natural) is
      variable v_copy_ptr : t_range_int_vec_ptr;
    begin
      v_copy_ptr := ran_vector;
      ran_vector := new t_range_int_vec(0 to v_copy_ptr'length-1 + increment);
      ran_vector(0 to v_copy_ptr'length-1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_integer_vector_ptr;
      constant increment  : in    natural) is
      variable v_copy_ptr : t_integer_vector_ptr;
    begin
      v_copy_ptr := val_vector;
      val_vector := new integer_vector(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length-1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_range_weight_mode_int_vec_ptr;
      constant increment  : in    natural) is
      variable v_copy_ptr : t_range_weight_mode_int_vec_ptr;
    begin
      v_copy_ptr := val_vector;
      val_vector := new t_range_weight_mode_int_vec(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length-1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable ran_vector : inout t_range_real_vec_ptr;
      constant increment  : in    natural) is
      variable v_copy_ptr : t_range_real_vec_ptr;
    begin
      v_copy_ptr := ran_vector;
      ran_vector := new t_range_real_vec(0 to v_copy_ptr'length-1 + increment);
      ran_vector(0 to v_copy_ptr'length-1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_real_vector_ptr;
      constant increment  : in    natural) is
      variable v_copy_ptr : t_real_vector_ptr;
    begin
      v_copy_ptr := val_vector;
      val_vector := new real_vector(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length-1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Overload
    procedure increment_vec_size(
      variable val_vector : inout t_range_weight_mode_real_vec_ptr;
      constant increment  : in    natural) is
      variable v_copy_ptr : t_range_weight_mode_real_vec_ptr;
    begin
      v_copy_ptr := val_vector;
      val_vector := new t_range_weight_mode_real_vec(0 to v_copy_ptr'length-1 + increment);
      val_vector(0 to v_copy_ptr'length-1) := v_copy_ptr.all;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Returns the integer constraints for randomization
    impure function get_int_constraints(
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
      if length > 0 then
        write(v_line, string'("LEN:"));
        write(v_line, to_string(length));
        if priv_int_constraints.ran_incl'length > 0 or priv_int_constraints.val_incl'length > 0 or priv_int_constraints.val_excl'length > 0 then
          write(v_line, string'(", "));
        end if;
      end if;
      for i in 0 to priv_int_constraints.ran_incl'length-1 loop
        if i = 0 then
          write(v_line, string'("RANGE:"));
        end if;
        write(v_line, '[');
        write(v_line, to_string(priv_int_constraints.ran_incl(i).min_value));
        write(v_line, ':');
        write(v_line, to_string(priv_int_constraints.ran_incl(i).max_value));
        write(v_line, ']');
        if i < priv_int_constraints.ran_incl'length-1 then
          write(v_line, ',');
        end if;
      end loop;
      if priv_int_constraints.val_incl'length > 0 then
        if priv_int_constraints.ran_incl'length = 0 then
          write(v_line, string'("ONLY:"));
        else
          write(v_line, string'(", ADD:"));
        end if;
        write(v_line, to_string(priv_int_constraints.val_incl.all));
      end if;
      if priv_int_constraints.val_excl'length > 0 then
        write(v_line, string'(", EXCL:"));
        write(v_line, to_string(priv_int_constraints.val_excl.all));
      end if;
      if priv_cyclic_mode = CYCLIC then
        write(v_line, string'(", "));
        write(v_line, to_upper(to_string(priv_cyclic_mode)));
      end if;
      if priv_uniqueness = UNIQUE then
        write(v_line, string'(", "));
        write(v_line, to_upper(to_string(priv_uniqueness)));
      end if;
      if v_line = NULL then
        write(v_line, string'("UNCONSTRAINED"));
      end if;
      return return_and_deallocate;
    end function;

    -- Overload
    impure function get_int_constraints(
      constant VOID : t_void)
    return string is
    begin
      return get_int_constraints(0);
    end function;

    -- Returns the real constraints for randomization
    impure function get_real_constraints(
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
      for i in 0 to priv_real_constraints.ran_incl'length-1 loop
        if i = 0 then
          write(v_line, string'("RANGE:"));
        end if;
        write(v_line, '[');
        write(v_line, format_real(priv_real_constraints.ran_incl(i).min_value));
        write(v_line, ':');
        write(v_line, format_real(priv_real_constraints.ran_incl(i).max_value));
        write(v_line, ']');
        if i < priv_real_constraints.ran_incl'length-1 then
          write(v_line, ',');
        end if;
      end loop;
      if priv_real_constraints.val_incl'length > 0 then
        if priv_real_constraints.ran_incl'length = 0 then
          write(v_line, string'("ONLY:"));
        else
          write(v_line, string'(", ADD:"));
        end if;
        write(v_line, format_real(priv_real_constraints.val_incl.all));
      end if;
      if priv_real_constraints.val_excl'length > 0 then
        write(v_line, string'(", EXCL:"));
        write(v_line, format_real(priv_real_constraints.val_excl.all));
      end if;
      if priv_uniqueness = UNIQUE then
        write(v_line, string'(", "));
        write(v_line, to_upper(to_string(priv_uniqueness)));
      end if;
      if v_line = NULL then
        write(v_line, string'("UNCONSTRAINED"));
      end if;
      return return_and_deallocate;
    end function;

    -- Returns the number of values in the integer constraints
    impure function get_int_constraints_count(
      constant VOID : t_void)
    return natural is
      variable v_cnt : natural := 0;
    begin
      for i in 0 to priv_int_constraints.ran_incl'length-1 loop
        v_cnt := v_cnt + (priv_int_constraints.ran_incl(i).max_value - priv_int_constraints.ran_incl(i).min_value + 1);
      end loop;
      v_cnt := v_cnt + priv_int_constraints.val_incl'length;
      v_cnt := v_cnt - priv_int_constraints.val_excl'length;
      return v_cnt;
    end function;

    -- Returns an integer random value supporting multiple range constraints
    impure function randm_ranges(
      constant msg_id_panel  : t_msg_id_panel;
      constant proc_call     : string;
      constant ext_proc_call : string := "")
    return integer is
      constant C_MIN_RANGE      : integer := integer'left;
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_proc_call      : line;
      variable v_max_range      : signed(32 downto 0);
      variable v_max_value      : signed(32 downto 0);
      variable v_acc_range_len  : signed(32 downto 0);
      variable v_gen_new_random : boolean := true;
      variable v_ret            : integer;
    begin
      create_proc_call(proc_call, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for a single range(min/max) constraint. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      while v_gen_new_random loop
        -- Concatenate all ranges first and then the added values into a single continuous range to call rand(min,max)
        v_max_range := to_signed(C_MIN_RANGE,33);
        for i in 0 to priv_int_constraints.ran_incl'length-1 loop
          v_max_range := v_max_range + priv_int_constraints.ran_incl(i).range_len;
        end loop;
        v_max_range := v_max_range - 1;
        v_max_value := v_max_range + priv_int_constraints.val_incl'length;
        if v_max_value > to_signed(integer'right,33) then
          alert(TB_ERROR, v_proc_call.all & "=> Constraints are greater than integer's range", priv_scope);
          return 0;
        end if;

        v_ret := rand(C_MIN_RANGE, to_integer(v_max_value), priv_cyclic_mode, msg_id_panel, v_proc_call.all);

        -- Convert the random value to the correct range
        if v_ret <= v_max_range then
          v_ret := v_ret - C_MIN_RANGE; -- Remove offset
          v_acc_range_len := (others => '0');
          for i in 0 to priv_int_constraints.ran_incl'length-1 loop
            v_acc_range_len := v_acc_range_len + priv_int_constraints.ran_incl(i).range_len;
            if v_ret < v_acc_range_len then
              v_ret := v_ret + priv_int_constraints.ran_incl(i).min_value - to_integer(v_acc_range_len - priv_int_constraints.ran_incl(i).range_len);
              exit;
            end if;
          end loop;
        -- If random value isn't a range, convert it to the corresponding added value
        else
          v_ret := priv_int_constraints.val_incl(v_ret-to_integer(v_max_range)-1);
        end if;

        -- Check if the random value is in the exclusion list
        v_gen_new_random := check_value_in_vector(v_ret, priv_int_constraints.val_excl.all);
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    -- Returns a real random value supporting multiple range constraints
    impure function randm_ranges(
      constant msg_id_panel  : t_msg_id_panel;
      constant proc_call     : string;
      constant ext_proc_call : string := "")
    return real is
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_proc_call      : line;
      variable v_max_range      : real;
      variable v_max_value      : real;
      variable v_acc_range_len  : real;
      variable v_gen_new_random : boolean := true;
      variable v_ret            : real;
    begin
      create_proc_call(proc_call, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for a single range(min/max) constraint. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      while v_gen_new_random loop
        -- Concatenate all ranges first and then the added values into a single continuous range to call rand(min,max)
        v_max_range := 0.0;
        for i in 0 to priv_real_constraints.ran_incl'length-1 loop
          v_max_range := v_max_range + priv_real_constraints.ran_incl(i).range_len;
        end loop;
        -- It is impossible to give the same weight to an included value than to a single value in the real range,
        -- therefore we split the probability to 50% ranges and 50% included values.
        v_max_value := v_max_range*2.0 when priv_real_constraints.val_incl'length > 0 else v_max_range;

        v_ret := rand(0.0, v_max_value, msg_id_panel, proc_call);

        -- Convert the random value to the correct range
        if v_ret <= v_max_range then
          v_acc_range_len := 0.0;
          for i in 0 to priv_real_constraints.ran_incl'length-1 loop
            v_acc_range_len := v_acc_range_len + priv_real_constraints.ran_incl(i).range_len;
            if v_ret <= v_acc_range_len then
              v_ret := v_ret + priv_real_constraints.ran_incl(i).min_value - (v_acc_range_len - priv_real_constraints.ran_incl(i).range_len);
              exit;
            end if;
          end loop;
        -- If random value isn't a range, randomize within the added values
        else
          v_ret := rand(ONLY, priv_real_constraints.val_incl.all, msg_id_panel, proc_call);
        end if;

        -- Check if the random value is in the exclusion list
        v_gen_new_random := check_value_in_vector(v_ret, priv_real_constraints.val_excl.all);
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    -- Returns an integer random value with ADD and EXCL constraints
    impure function randm_add_excl(
      constant msg_id_panel  : t_msg_id_panel;
      constant proc_call     : string;
      constant ext_proc_call : string := "")
    return integer is
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_proc_call      : line;
      variable v_gen_new_random : boolean := true;
      variable v_ret            : integer;
    begin
      create_proc_call(proc_call, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      while v_gen_new_random loop
        v_ret := rand(ONLY, priv_int_constraints.val_incl.all, priv_cyclic_mode, msg_id_panel, v_proc_call.all);
        v_gen_new_random := check_value_in_vector(v_ret, priv_int_constraints.val_excl.all);
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    -- Returns a real random value with ADD and EXCL constraints
    impure function randm_add_excl(
      constant msg_id_panel  : t_msg_id_panel;
      constant proc_call     : string;
      constant ext_proc_call : string := "")
    return real is
      constant C_PREVIOUS_DIST  : t_rand_dist := priv_rand_dist;
      variable v_proc_call      : line;
      variable v_gen_new_random : boolean := true;
      variable v_ret            : real;
    begin
      create_proc_call(proc_call, ext_proc_call, v_proc_call);

      if priv_rand_dist = GAUSSIAN then
        alert(TB_WARNING, v_proc_call.all & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
        priv_rand_dist := UNIFORM;
      end if;

      while v_gen_new_random loop
        v_ret := rand(ONLY, priv_real_constraints.val_incl.all, msg_id_panel, v_proc_call.all);
        v_gen_new_random := check_value_in_vector(v_ret, priv_real_constraints.val_excl.all);
      end loop;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
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
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.ran_incl, 1);
      increment_vec_size(priv_int_constraints.weighted, 1);
      priv_int_constraints.ran_incl(priv_int_constraints.ran_incl'length-1).min_value := min_value;
      priv_int_constraints.ran_incl(priv_int_constraints.ran_incl'length-1).max_value := max_value;
      priv_int_constraints.ran_incl(priv_int_constraints.ran_incl'length-1).range_len := to_signed(max_value,33) - to_signed(min_value,33) + to_signed(1,33);
      priv_int_constraints.weighted(priv_int_constraints.weighted'length-1) := (min_value, max_value, 1, COMBINED_WEIGHT);
    end procedure;

    procedure add_val(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val(" & to_string(value) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.val_incl, 1);
      increment_vec_size(priv_int_constraints.weighted, 1);
      priv_int_constraints.val_incl(priv_int_constraints.val_incl'length-1) := value;
      priv_int_constraints.weighted(priv_int_constraints.weighted'length-1) := (value, value, 1, NA);
    end procedure;

    procedure add_val(
      constant set_values   : in integer_vector;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val" & to_string(set_values);
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.val_incl, set_values'length);
      increment_vec_size(priv_int_constraints.weighted, set_values'length);
      priv_int_constraints.val_incl(priv_int_constraints.val_incl'length-1-(set_values'length-1) to priv_int_constraints.val_incl'length-1) := set_values;
      for i in 0 to set_values'length-1 loop
        priv_int_constraints.weighted(priv_int_constraints.weighted'length-1-(set_values'length-1)+i) := (set_values(i), set_values(i), 1, NA);
      end loop;
    end procedure;

    procedure excl_val(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "excl_val(" & to_string(value) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.val_excl, 1);
      priv_int_constraints.val_excl(priv_int_constraints.val_excl'length-1) := value;
    end procedure;

    procedure excl_val(
      constant set_values   : in integer_vector;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "excl_val" & to_string(set_values);
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.val_excl, set_values'length);
      priv_int_constraints.val_excl(priv_int_constraints.val_excl'length-1-(set_values'length-1) to priv_int_constraints.val_excl'length-1) := set_values;
    end procedure;

    procedure add_val_weight(
      constant value        : in integer;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_weight(" & to_string(value) & "," & to_string(weight) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.weighted, 1);
      priv_int_constraints.weighted(priv_int_constraints.weighted'length-1) := (value, value, weight, NA);
      priv_int_constraints.weighted_config := true;
    end procedure;

    procedure add_range_weight(
      constant min_value    : in integer;
      constant max_value    : in integer;
      constant weight       : in natural;
      constant mode         : in t_weight_mode  := NA;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range_weight([" & to_string(min_value) & ":" & to_string(max_value) & "]," &
        to_string(weight) & return_string1_if_true_otherwise_string2("," & to_upper(to_string(mode)), "", mode /= NA) & ")";
      variable v_weight_mode : t_weight_mode;
    begin
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      v_weight_mode := mode when mode /= NA else priv_weight_mode;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_int_constraints.weighted, 1);
      priv_int_constraints.weighted(priv_int_constraints.weighted'length-1) := (min_value, max_value, weight, v_weight_mode);
      priv_int_constraints.weighted_config := true;
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
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.ran_incl, 1);
      increment_vec_size(priv_real_constraints.weighted, 1);
      priv_real_constraints.ran_incl(priv_real_constraints.ran_incl'length-1) := (min_value, max_value, max_value-min_value); -- NOTE: range is different for real than integer
      priv_real_constraints.weighted(priv_real_constraints.weighted'length-1) := (min_value, max_value, 1, COMBINED_WEIGHT);
    end procedure;

    procedure add_val_real(
      constant value        : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_real(" & format_real(value) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.val_incl, 1);
      increment_vec_size(priv_real_constraints.weighted, 1);
      priv_real_constraints.val_incl(priv_real_constraints.val_incl'length-1) := value;
      priv_real_constraints.weighted(priv_real_constraints.weighted'length-1) := (value, value, 1, NA);
    end procedure;

    procedure add_val_real(
      constant set_values   : in real_vector;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_real" & format_real(set_values);
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.val_incl, set_values'length);
      increment_vec_size(priv_real_constraints.weighted, set_values'length);
      priv_real_constraints.val_incl(priv_real_constraints.val_incl'length-1-(set_values'length-1) to priv_real_constraints.val_incl'length-1) := set_values;
      for i in 0 to set_values'length-1 loop
        priv_real_constraints.weighted(priv_real_constraints.weighted'length-1-(set_values'length-1)+i) := (set_values(i), set_values(i), 1, NA);
      end loop;
    end procedure;

    procedure excl_val_real(
      constant value        : in real;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "excl_val_real(" & format_real(value) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.val_excl, 1);
      priv_real_constraints.val_excl(priv_real_constraints.val_excl'length-1) := value;
    end procedure;

    procedure excl_val_real(
      constant set_values   : in real_vector;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "excl_val_real" & format_real(set_values);
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.val_excl, set_values'length);
      priv_real_constraints.val_excl(priv_real_constraints.val_excl'length-1-(set_values'length-1) to priv_real_constraints.val_excl'length-1) := set_values;
    end procedure;

    procedure add_val_weight_real(
      constant value        : in real;
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_val_weight_real(" & format_real(value) & "," & to_string(weight) & ")";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.weighted, 1);
      priv_real_constraints.weighted(priv_real_constraints.weighted'length-1) := (value, value, weight, NA);
      priv_real_constraints.weighted_config := true;
    end procedure;

    procedure add_range_weight_real(
      constant min_value    : in real;
      constant max_value    : in real;
      constant weight       : in natural;
      constant mode         : in t_weight_mode  := NA;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_range_weight_real([" & format_real(min_value) & ":" & format_real(max_value) & "]," &
        to_string(weight) & return_string1_if_true_otherwise_string2("," & to_upper(to_string(mode)), "", mode /= NA) & ")";
      variable v_weight_mode : t_weight_mode;
    begin
      if min_value >= max_value then
        alert(TB_ERROR, C_LOCAL_CALL & "=> min_value must be less than max_value", priv_scope);
        return;
      end if;
      v_weight_mode := mode when mode /= NA else priv_weight_mode;
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      increment_vec_size(priv_real_constraints.weighted, 1);
      priv_real_constraints.weighted(priv_real_constraints.weighted'length-1) := (min_value, max_value, weight, v_weight_mode);
      priv_real_constraints.weighted_config := true;
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
      constant msg_id_panel : in t_msg_id_panel) is
      constant C_LOCAL_CALL : string := "clear_constraints()";
    begin
      log(ID_RAND_CONF, C_LOCAL_CALL, priv_scope, msg_id_panel);
      DEALLOCATE(priv_int_constraints.ran_incl);
      DEALLOCATE(priv_int_constraints.val_incl);
      DEALLOCATE(priv_int_constraints.val_excl);
      DEALLOCATE(priv_int_constraints.weighted);
      priv_int_constraints.ran_incl := new t_range_int_vec(1 to 0);
      priv_int_constraints.val_incl := new integer_vector(1 to 0);
      priv_int_constraints.val_excl := new integer_vector(1 to 0);
      priv_int_constraints.weighted := new t_range_weight_mode_int_vec(1 to 0);
      priv_int_constraints.weighted_config := false;

      DEALLOCATE(priv_real_constraints.ran_incl);
      DEALLOCATE(priv_real_constraints.val_incl);
      DEALLOCATE(priv_real_constraints.val_excl);
      DEALLOCATE(priv_real_constraints.weighted);
      priv_real_constraints.ran_incl := new t_range_real_vec(1 to 0);
      priv_real_constraints.val_incl := new real_vector(1 to 0);
      priv_real_constraints.val_excl := new real_vector(1 to 0);
      priv_real_constraints.weighted := new t_range_weight_mode_real_vec(1 to 0);
      priv_real_constraints.weighted_config := false;
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
      priv_name               := "**unnamed**" & fill_string(NUL, C_RAND_MAX_NAME_LENGTH-11);
      priv_scope              := C_TB_SCOPE_DEFAULT & fill_string(NUL, C_LOG_SCOPE_WIDTH-C_TB_SCOPE_DEFAULT'length);
      priv_rand_dist          := UNIFORM;
      priv_weight_mode        := COMBINED_WEIGHT;
      priv_mean_configured    := false;
      priv_std_dev_configured := false;
      priv_mean               := 0.0;
      priv_std_dev            := 0.0;
      priv_cyclic_mode        := NON_CYCLIC;
      priv_uniqueness         := NON_UNIQUE;

      DEALLOCATE(priv_int_constraints.ran_incl);
      DEALLOCATE(priv_int_constraints.val_incl);
      DEALLOCATE(priv_int_constraints.val_excl);
      DEALLOCATE(priv_int_constraints.weighted);
      priv_int_constraints.ran_incl := new t_range_int_vec(1 to 0);
      priv_int_constraints.val_incl := new integer_vector(1 to 0);
      priv_int_constraints.val_excl := new integer_vector(1 to 0);
      priv_int_constraints.weighted := new t_range_weight_mode_int_vec(1 to 0);
      priv_int_constraints.weighted_config := false;

      DEALLOCATE(priv_real_constraints.ran_incl);
      DEALLOCATE(priv_real_constraints.val_incl);
      DEALLOCATE(priv_real_constraints.val_excl);
      DEALLOCATE(priv_real_constraints.weighted);
      priv_real_constraints.ran_incl := new t_range_real_vec(1 to 0);
      priv_real_constraints.val_incl := new real_vector(1 to 0);
      priv_real_constraints.val_excl := new real_vector(1 to 0);
      priv_real_constraints.weighted := new t_range_weight_mode_real_vec(1 to 0);
      priv_real_constraints.weighted_config := false;
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
      constant C_LOCAL_CALL : string := "randm(" & get_int_constraints(VOID) & ")";
      variable v_ran_incl_configured : std_logic;
      variable v_val_incl_configured : std_logic;
      variable v_val_excl_configured : std_logic;
      variable v_num_ranges          : natural := priv_int_constraints.ran_incl'length;
    begin
      v_ran_incl_configured := '1' when v_num_ranges > 0 else '0';
      v_val_incl_configured := '1' when priv_int_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_int_constraints.val_excl'length > 0 else '0';

      ----------------------------------------
      -- WEIGHTED
      ----------------------------------------
      if priv_int_constraints.weighted_config then
        check_value(v_val_excl_configured = '0', TB_WARNING, "Exclude constraint and weighted randomization cannot be combined. Ignoring exclude constraint.",
          priv_scope, ID_NEVER, caller_name => "randm(" & to_string(priv_int_constraints.weighted.all) & ")");
        check_value(priv_cyclic_mode /= CYCLIC, TB_WARNING, "Cyclic mode and weighted randomization cannot be combined. Ignoring cyclic configuration.",
          priv_scope, ID_NEVER, caller_name => "randm(" & to_string(priv_int_constraints.weighted.all) & ")");
        check_value(priv_uniqueness /= UNIQUE, TB_WARNING, "Uniqueness and weighted randomization cannot be combined. Ignoring uniqueness configuration.",
          priv_scope, ID_NEVER, caller_name => "randm(" & to_string(priv_int_constraints.weighted.all) & ")");
        return rand_range_weight_mode(priv_int_constraints.weighted.all, msg_id_panel);
      end if;

      case unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured) is
        ----------------------------------------
        -- RANGE
        ----------------------------------------
        when "100" =>
          if v_num_ranges = 1 then
            return rand(priv_int_constraints.ran_incl(0).min_value, priv_int_constraints.ran_incl(0).max_value, priv_cyclic_mode, msg_id_panel, ext_proc_call);
          else
            return randm_ranges(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
          end if;
        ----------------------------------------
        -- SET OF VALUES
        ----------------------------------------
        when "010" =>
          return rand(ONLY, priv_int_constraints.val_incl.all, priv_cyclic_mode, msg_id_panel, ext_proc_call);
        ----------------------------------------
        -- EXCLUDE
        ----------------------------------------
        when "001" =>
          return rand(integer'left, integer'right, EXCL, priv_int_constraints.val_excl.all, priv_cyclic_mode, msg_id_panel, ext_proc_call);
        ----------------------------------------
        -- RANGE + SET OF VALUES
        ----------------------------------------
        when "110" =>
          if v_num_ranges = 1 then
            return rand(priv_int_constraints.ran_incl(0).min_value, priv_int_constraints.ran_incl(0).max_value, ADD,
              priv_int_constraints.val_incl.all, priv_cyclic_mode, msg_id_panel, ext_proc_call);
          else
            return randm_ranges(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
          end if;
        ----------------------------------------
        -- RANGE + EXCLUDE
        ----------------------------------------
        when "101" =>
          if v_num_ranges = 1 then
            return rand(priv_int_constraints.ran_incl(0).min_value, priv_int_constraints.ran_incl(0).max_value, EXCL,
              priv_int_constraints.val_excl.all, priv_cyclic_mode, msg_id_panel, ext_proc_call);
          else
            return randm_ranges(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
          end if;
        ----------------------------------------
        -- SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "011" =>
          return randm_add_excl(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
        ----------------------------------------
        -- RANGE + SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "111" =>
          if v_num_ranges = 1 then
            return rand(priv_int_constraints.ran_incl(0).min_value, priv_int_constraints.ran_incl(0).max_value, ADD,
              priv_int_constraints.val_incl.all, EXCL, priv_int_constraints.val_excl.all, priv_cyclic_mode, msg_id_panel, ext_proc_call);
          else
            return randm_ranges(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
          end if;
        ----------------------------------------
        -- NO CONSTRAINTS
        ----------------------------------------
        when "000" =>
          return rand(integer'left, integer'right, priv_cyclic_mode, msg_id_panel, ext_proc_call);

        when others =>
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unexpected constraints: " & to_string(unsigned'(v_ran_incl_configured & v_val_incl_configured &
            v_val_excl_configured)), priv_scope);
          return 0;
      end case;
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
      constant C_LOCAL_CALL : string := "randm(" & get_real_constraints(VOID) & ")";
      variable v_ran_incl_configured : std_logic;
      variable v_val_incl_configured : std_logic;
      variable v_val_excl_configured : std_logic;
      variable v_num_ranges          : natural := priv_real_constraints.ran_incl'length;
    begin
      v_ran_incl_configured := '1' when v_num_ranges > 0 else '0';
      v_val_incl_configured := '1' when priv_real_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_real_constraints.val_excl'length > 0 else '0';

      if priv_cyclic_mode = CYCLIC then
        alert(TB_WARNING, C_LOCAL_CALL & "=> Cyclic mode not supported for real type. Ignoring cyclic configuration.", priv_scope);
      end if;

      ----------------------------------------
      -- WEIGHTED
      ----------------------------------------
      if priv_real_constraints.weighted_config then
        check_value(v_val_excl_configured = '0', TB_WARNING, "Exclude constraint and weighted randomization cannot be combined. Ignoring exclude constraint.",
          priv_scope, ID_NEVER, caller_name => "randm(" & to_string(priv_real_constraints.weighted.all) & ")");
        check_value(priv_uniqueness /= UNIQUE, TB_WARNING, "Uniqueness and weighted randomization cannot be combined. Ignoring uniqueness configuration.",
          priv_scope, ID_NEVER, caller_name => "randm(" & to_string(priv_real_constraints.weighted.all) & ")");
        return rand_range_weight_mode(priv_real_constraints.weighted.all, msg_id_panel);
      end if;

      case unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured) is
        ----------------------------------------
        -- RANGE
        ----------------------------------------
        when "100" =>
          if v_num_ranges = 1 then
            return rand(priv_real_constraints.ran_incl(0).min_value, priv_real_constraints.ran_incl(0).max_value, msg_id_panel, ext_proc_call);
          else
            return randm_ranges(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
          end if;
        ----------------------------------------
        -- SET OF VALUES
        ----------------------------------------
        when "010" =>
          return rand(ONLY, priv_real_constraints.val_incl.all, msg_id_panel, ext_proc_call);
        ----------------------------------------
        -- EXCLUDE
        ----------------------------------------
        when "001" =>
          alert(TB_ERROR, C_LOCAL_CALL & "=> Real random generator needs ""include"" constraints", priv_scope);
          return 0.0;
        ----------------------------------------
        -- RANGE + SET OF VALUES
        ----------------------------------------
        when "110" =>
          if v_num_ranges = 1 then
            return rand(priv_real_constraints.ran_incl(0).min_value, priv_real_constraints.ran_incl(0).max_value, ADD,
              priv_real_constraints.val_incl.all, msg_id_panel, ext_proc_call);
          else
            return randm_ranges(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
          end if;
        ----------------------------------------
        -- RANGE + EXCLUDE
        ----------------------------------------
        when "101" =>
          if v_num_ranges = 1 then
            return rand(priv_real_constraints.ran_incl(0).min_value, priv_real_constraints.ran_incl(0).max_value, EXCL,
              priv_real_constraints.val_excl.all, msg_id_panel, ext_proc_call);
          else
            return randm_ranges(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
          end if;
        ----------------------------------------
        -- SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "011" =>
          return randm_add_excl(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
        ----------------------------------------
        -- RANGE + SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "111" =>
          if v_num_ranges = 1 then
            return rand(priv_real_constraints.ran_incl(0).min_value, priv_real_constraints.ran_incl(0).max_value, ADD,
              priv_real_constraints.val_incl.all, EXCL, priv_real_constraints.val_excl.all, msg_id_panel, ext_proc_call);
          else
            return randm_ranges(msg_id_panel, C_LOCAL_CALL, ext_proc_call);
          end if;
        ----------------------------------------
        -- NO CONSTRAINTS
        ----------------------------------------
        when "000" =>
          alert(TB_ERROR, C_LOCAL_CALL & "=> Real random generator must be constrained", priv_scope);
          return 0.0;

        when others =>
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unexpected constraints: " & to_string(unsigned'(v_ran_incl_configured & v_val_incl_configured &
            v_val_excl_configured)), priv_scope);
          return 0.0;
      end case;
    end function;

    impure function randm(
      constant size         : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL : string := "randm(" & get_int_constraints(VOID) & ")";
      constant C_PREVIOUS_DIST       : t_rand_dist := priv_rand_dist;
      variable v_val_incl_configured : std_logic;
      variable v_val_excl_configured : std_logic;
      variable v_num_ranges          : natural := priv_int_constraints.ran_incl'length;
      variable v_gen_new_random      : boolean := true;
      variable v_ret                 : integer_vector(0 to size-1);
    begin
      v_val_incl_configured := '1' when priv_int_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_int_constraints.val_excl'length > 0 else '0';

      if priv_int_constraints.weighted_config then
        alert(TB_ERROR, "randm(" & to_string(priv_int_constraints.weighted.all) & ")=> Weighted randomization not supported for integer_vector type.", priv_scope);
        return v_ret;
      end if;
      if priv_rand_dist = GAUSSIAN then
        if priv_uniqueness = UNIQUE then
          alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and uniqueness cannot be combined. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        elsif priv_cyclic_mode = CYCLIC then
          alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution and cyclic mode cannot be combined. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        elsif (v_val_incl_configured = '1' or v_val_excl_configured = '1') then
          alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for range(min/max) constraints. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        elsif v_num_ranges > 1 then
          alert(TB_WARNING, C_LOCAL_CALL & "=> " & to_upper(to_string(priv_rand_dist)) & " distribution only supported for a single range(min/max) constraint. Using UNIFORM instead.", priv_scope);
          priv_rand_dist := UNIFORM;
        end if;
      end if;

      if priv_uniqueness = NON_UNIQUE then
        -- Generate a random value for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := randm(msg_id_panel, C_LOCAL_CALL);
        end loop;
      else -- UNIQUE
        -- Check if it is possible to generate unique values for the complete vector
        if get_int_constraints_count(VOID) < size then
          alert(TB_ERROR, C_LOCAL_CALL & "=> The given constraints are not enough to generate unique values for the whole vector", priv_scope);
          return v_ret;
        else
          -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := randm(msg_id_panel, C_LOCAL_CALL);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      end if;

      -- Restore previous distribution
      priv_rand_dist := C_PREVIOUS_DIST;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      return v_ret;
    end function;

    impure function randm(
      constant length       : positive;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return unsigned is
      constant C_LOCAL_CALL : string := "randm(" & get_int_constraints(length) & ")";
      variable v_ran_incl_configured : std_logic;
      variable v_val_incl_configured : std_logic;
      variable v_val_excl_configured : std_logic;
      variable v_ret_int             : integer;
      variable v_ret                 : unsigned(length-1 downto 0);
    begin
      v_ran_incl_configured := '1' when priv_int_constraints.ran_incl'length > 0 else '0';
      v_val_incl_configured := '1' when priv_int_constraints.val_incl'length > 0 else '0';
      v_val_excl_configured := '1' when priv_int_constraints.val_excl'length > 0 else '0';

      ----------------------------------------
      -- WEIGHTED
      ----------------------------------------
      if priv_int_constraints.weighted_config then
        check_value(v_val_excl_configured = '0', TB_WARNING, "Exclude constraint and weighted randomization cannot be combined. Ignoring exclude constraint.",
          priv_scope, ID_NEVER, caller_name => "randm(" & to_string(priv_int_constraints.weighted.all) & ")");
        check_value(priv_cyclic_mode /= CYCLIC, TB_WARNING, "Cyclic mode and weighted randomization cannot be combined. Ignoring cyclic configuration.",
          priv_scope, ID_NEVER, caller_name => "randm(" & to_string(priv_int_constraints.weighted.all) & ")");
        check_value(priv_uniqueness /= UNIQUE, TB_WARNING, "Uniqueness and weighted randomization cannot be combined. Ignoring uniqueness configuration.",
          priv_scope, ID_NEVER, caller_name => "randm(" & to_string(priv_int_constraints.weighted.all) & ")");
        v_ret_int := rand_range_weight_mode(priv_int_constraints.weighted.all, msg_id_panel);
        v_ret     := to_unsigned(v_ret_int,length);
      end if;

      -- TODO: what should happen when negative constraints are added and randm() unsigned is called?
      --       1. print alert
      --       2. print alert and ignore negative values
      --       3. ignore negative values
      for i in 0 to priv_int_constraints.ran_incl'length-1 loop
        check_parameters_within_range(length, priv_int_constraints.ran_incl(i).min_value, priv_int_constraints.ran_incl(i).max_value, msg_id_panel, signed_values => false);
      end loop;
      check_parameters_within_range(length, priv_int_constraints.val_incl.all, msg_id_panel, signed_values => false);
      check_parameters_within_range(length, priv_int_constraints.val_excl.all, msg_id_panel, signed_values => false);

      -- TODO: check support for long vectors
      case unsigned'(v_ran_incl_configured & v_val_incl_configured & v_val_excl_configured) is
        ----------------------------------------
        -- RANGE | SET OF VALUES | RANGE + SET OF VALUES | RANGE + EXCLUDE | SET OF VALUES + EXCLUDE | RANGE + SET OF VALUES + EXCLUDE
        ----------------------------------------
        when "100" | "010" | "110" | "101" | "011" | "111" =>
          v_ret_int := randm(msg_id_panel, C_LOCAL_CALL);
          v_ret     := to_unsigned(v_ret_int,length);
        ----------------------------------------
        -- EXCLUDE
        ----------------------------------------
        when "001" =>
          v_ret := rand(length, EXCL, t_natural_vector(priv_int_constraints.val_excl.all), priv_cyclic_mode, msg_id_panel);
          return v_ret;
        ----------------------------------------
        -- NO CONSTRAINTS
        ----------------------------------------
        when "000" =>
          v_ret := rand(length, priv_cyclic_mode, msg_id_panel, C_LOCAL_CALL);

        when others =>
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unexpected constraints: " & to_string(unsigned'(v_ran_incl_configured & v_val_incl_configured &
            v_val_excl_configured)), priv_scope);
          return v_ret;
      end case;

      log(ID_RAND_GEN, C_LOCAL_CALL & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), priv_scope, msg_id_panel);
      return v_ret;
    end function;

  end protected body t_rand;

end package body rand_pkg;
