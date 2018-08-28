# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up bitvis_uart_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_uart"
quietly set part_name "bitvis_uart"
# path from mpf-file in sim
quietly set bitvis_uart_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set bitvis_uart_part_path "$1/..//$part_name"
  unset 1
}

do $bitvis_uart_part_path/internal_script/internal_1_compile_src.do $bitvis_uart_part_path


