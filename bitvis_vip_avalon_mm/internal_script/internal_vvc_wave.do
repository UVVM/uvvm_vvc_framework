onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /avalon_mm_vvc_tb/C_CLK_PERIOD
add wave -noupdate /avalon_mm_vvc_tb/i_test_harness/avalon_mm_if
add wave -noupdate /avalon_mm_vvc_tb/i_test_harness/clk
add wave -noupdate /avalon_mm_vvc_tb/i_test_harness/empty
add wave -noupdate /avalon_mm_vvc_tb/i_test_harness/full
add wave -noupdate /avalon_mm_vvc_tb/i_test_harness/usedw
add wave -noupdate /avalon_mm_vvc_tb/i_test_harness/usedw
add wave -noupdate /avalon_mm_vvc_tb/i_test_harness/rst
add wave -noupdate -childformat {{/avalon_mm_vvc_tb/i_test_harness/i1_avalon_mm_vvc/transaction_info.operation} {/avalon_mm_vvc_tb/i_test_harness/i1_avalon_mm_vvc/transaction_info.addr -radix unsigned} {/avalon_mm_vvc_tb/i_test_harness/i1_avalon_mm_vvc/transaction_info.data -radix unsigned} {/avalon_mm_vvc_tb/i_test_harness/i1_avalon_mm_vvc/transaction_info.byte_enable} {/avalon_mm_vvc_tb/i_test_harness/i1_avalon_mm_vvc/transaction_info.msg}} /avalon_mm_vvc_tb/i_test_harness/i1_avalon_mm_vvc/transaction_info
add wave -noupdate -childformat {{/avalon_mm_vvc_tb/i_test_harness/i2_avalon_mm_vvc/transaction_info.operation} {/avalon_mm_vvc_tb/i_test_harness/i2_avalon_mm_vvc/transaction_info.addr -radix unsigned} {/avalon_mm_vvc_tb/i_test_harness/i2_avalon_mm_vvc/transaction_info.data -radix unsigned} {/avalon_mm_vvc_tb/i_test_harness/i2_avalon_mm_vvc/transaction_info.byte_enable} {/avalon_mm_vvc_tb/i_test_harness/i2_avalon_mm_vvc/transaction_info.msg}} /avalon_mm_vvc_tb/i_test_harness/i2_avalon_mm_vvc/transaction_info
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {596937 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 431
configure wave -valuecolwidth 94
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {4452 ns}
