set lib_name "bitvis_uart"

if { [info exists ::env(SIMULATOR)] } {
  set simulator $::env(SIMULATOR)
  puts "Simulator: $simulator"

  if [string equal $simulator "MODELSIM"] {
    set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
  } elseif [string equal $simulator "RIVIERAPRO"] {
    set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
  } else {
    puts "No simulator! Trying with modelsim"
    quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
  }
} else {
  puts "No simulator! Trying with modelsim0"
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
}

#------------------------------------------------------
# Compile tb files
#------------------------------------------------------
set root_path "../.."
set tb_path "$root_path/bitvis_uart/tb/maintenance_tb"

echo "\n\n\n=== Compiling TB\n"

echo "eval vcom  $compdirectives  $tb_path/../uart_vvc_demo_th.vhd"
eval vcom  $compdirectives  $tb_path/../uart_vvc_demo_th.vhd

echo "eval vcom  $compdirectives  $tb_path/uart_bfm_tb.vhd"
eval vcom  $compdirectives  $tb_path/uart_bfm_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/uart_vvc_tb.vhd"
eval vcom  $compdirectives  $tb_path/uart_vvc_tb.vhd

