onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axilite_tb/clk
add wave -noupdate /axilite_tb/areset
add wave -noupdate /axilite_tb/clock_ena
add wave -noupdate /axilite_tb/C_CLK_PERIOD
add wave -noupdate /axilite_tb/C_ADDR_WIDTH_1
add wave -noupdate /axilite_tb/C_DATA_WIDTH_1
add wave -noupdate /axilite_tb/C_ADDR_WIDTH_2
add wave -noupdate /axilite_tb/C_DATA_WIDTH_2
add wave -noupdate -radix hexadecimal /axilite_tb/axilite_if_1
add wave -noupdate -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.write_address_channel -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.write_address_channel.awaddr -radix hexadecimal} {/axilite_tb/axilite_if_2.write_address_channel.awvalid -radix hexadecimal} {/axilite_tb/axilite_if_2.write_address_channel.awprot -radix hexadecimal} {/axilite_tb/axilite_if_2.write_address_channel.awready -radix hexadecimal}}} {/axilite_tb/axilite_if_2.write_data_channel -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.write_data_channel.wdata -radix hexadecimal} {/axilite_tb/axilite_if_2.write_data_channel.wstrb -radix hexadecimal} {/axilite_tb/axilite_if_2.write_data_channel.wvalid -radix hexadecimal} {/axilite_tb/axilite_if_2.write_data_channel.wready -radix hexadecimal}}} {/axilite_tb/axilite_if_2.write_repsonse_channel -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.write_repsonse_channel.bready -radix hexadecimal} {/axilite_tb/axilite_if_2.write_repsonse_channel.bresp -radix hexadecimal} {/axilite_tb/axilite_if_2.write_repsonse_channel.bvalid -radix hexadecimal}}} {/axilite_tb/axilite_if_2.read_address_channel -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_address_channel.araddr -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arvalid -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arprot -radix binary -childformat {{/axilite_tb/axilite_if_2.read_address_channel.arprot(2) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arprot(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arprot(0) -radix hexadecimal}}} {/axilite_tb/axilite_if_2.read_address_channel.arready -radix hexadecimal}}} {/axilite_tb/axilite_if_2.read_data_channel -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_data_channel.rready -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_data_channel.rdata(63) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(62) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(61) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(60) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(59) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(58) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(57) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(56) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(55) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(54) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(53) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(52) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(51) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(50) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(49) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(48) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(47) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(46) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(45) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(44) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(43) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(42) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(41) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(40) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(39) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(38) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(37) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(36) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(35) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(34) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(33) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(32) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(31) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(30) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(29) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(28) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(27) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(26) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(25) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(24) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(23) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(22) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(21) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(20) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(19) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(18) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(17) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(16) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(15) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(14) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(13) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(12) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(11) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(10) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(9) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(8) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(7) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(6) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(5) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(4) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(3) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(2) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(0) -radix hexadecimal}}} {/axilite_tb/axilite_if_2.read_data_channel.rresp -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_data_channel.rresp(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rresp(0) -radix hexadecimal}}} {/axilite_tb/axilite_if_2.read_data_channel.rvalid -radix hexadecimal}}}} -subitemconfig {/axilite_tb/axilite_if_2.write_address_channel {-height 15 -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.write_address_channel.awaddr -radix hexadecimal} {/axilite_tb/axilite_if_2.write_address_channel.awvalid -radix hexadecimal} {/axilite_tb/axilite_if_2.write_address_channel.awprot -radix hexadecimal} {/axilite_tb/axilite_if_2.write_address_channel.awready -radix hexadecimal}}} /axilite_tb/axilite_if_2.write_address_channel.awaddr {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_address_channel.awvalid {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_address_channel.awprot {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_address_channel.awready {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_data_channel {-height 15 -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.write_data_channel.wdata -radix hexadecimal} {/axilite_tb/axilite_if_2.write_data_channel.wstrb -radix hexadecimal} {/axilite_tb/axilite_if_2.write_data_channel.wvalid -radix hexadecimal} {/axilite_tb/axilite_if_2.write_data_channel.wready -radix hexadecimal}}} /axilite_tb/axilite_if_2.write_data_channel.wdata {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_data_channel.wstrb {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_data_channel.wvalid {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_data_channel.wready {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_repsonse_channel {-height 15 -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.write_repsonse_channel.bready -radix hexadecimal} {/axilite_tb/axilite_if_2.write_repsonse_channel.bresp -radix hexadecimal} {/axilite_tb/axilite_if_2.write_repsonse_channel.bvalid -radix hexadecimal}}} /axilite_tb/axilite_if_2.write_repsonse_channel.bready {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_repsonse_channel.bresp {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.write_repsonse_channel.bvalid {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_address_channel {-height 15 -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_address_channel.araddr -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arvalid -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arprot -radix binary -childformat {{/axilite_tb/axilite_if_2.read_address_channel.arprot(2) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arprot(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arprot(0) -radix hexadecimal}}} {/axilite_tb/axilite_if_2.read_address_channel.arready -radix hexadecimal}}} /axilite_tb/axilite_if_2.read_address_channel.araddr {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_address_channel.arvalid {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_address_channel.arprot {-height 15 -radix binary -childformat {{/axilite_tb/axilite_if_2.read_address_channel.arprot(2) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arprot(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_address_channel.arprot(0) -radix hexadecimal}}} /axilite_tb/axilite_if_2.read_address_channel.arprot(2) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_address_channel.arprot(1) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_address_channel.arprot(0) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_address_channel.arready {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel {-height 15 -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_data_channel.rready -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_data_channel.rdata(63) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(62) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(61) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(60) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(59) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(58) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(57) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(56) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(55) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(54) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(53) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(52) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(51) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(50) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(49) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(48) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(47) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(46) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(45) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(44) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(43) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(42) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(41) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(40) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(39) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(38) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(37) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(36) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(35) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(34) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(33) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(32) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(31) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(30) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(29) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(28) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(27) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(26) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(25) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(24) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(23) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(22) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(21) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(20) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(19) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(18) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(17) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(16) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(15) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(14) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(13) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(12) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(11) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(10) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(9) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(8) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(7) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(6) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(5) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(4) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(3) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(2) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(0) -radix hexadecimal}}} {/axilite_tb/axilite_if_2.read_data_channel.rresp -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_data_channel.rresp(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rresp(0) -radix hexadecimal}}} {/axilite_tb/axilite_if_2.read_data_channel.rvalid -radix hexadecimal}}} /axilite_tb/axilite_if_2.read_data_channel.rready {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata {-height 15 -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_data_channel.rdata(63) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(62) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(61) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(60) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(59) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(58) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(57) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(56) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(55) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(54) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(53) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(52) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(51) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(50) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(49) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(48) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(47) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(46) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(45) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(44) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(43) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(42) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(41) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(40) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(39) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(38) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(37) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(36) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(35) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(34) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(33) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(32) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(31) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(30) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(29) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(28) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(27) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(26) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(25) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(24) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(23) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(22) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(21) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(20) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(19) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(18) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(17) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(16) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(15) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(14) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(13) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(12) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(11) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(10) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(9) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(8) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(7) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(6) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(5) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(4) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(3) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(2) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rdata(0) -radix hexadecimal}}} /axilite_tb/axilite_if_2.read_data_channel.rdata(63) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(62) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(61) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(60) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(59) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(58) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(57) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(56) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(55) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(54) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(53) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(52) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(51) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(50) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(49) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(48) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(47) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(46) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(45) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(44) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(43) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(42) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(41) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(40) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(39) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(38) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(37) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(36) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(35) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(34) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(33) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(32) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(31) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(30) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(29) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(28) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(27) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(26) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(25) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(24) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(23) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(22) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(21) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(20) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(19) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(18) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(17) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(16) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(15) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(14) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(13) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(12) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(11) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(10) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(9) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(8) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(7) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(6) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(5) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(4) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(3) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(2) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(1) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rdata(0) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rresp {-height 15 -radix hexadecimal -childformat {{/axilite_tb/axilite_if_2.read_data_channel.rresp(1) -radix hexadecimal} {/axilite_tb/axilite_if_2.read_data_channel.rresp(0) -radix hexadecimal}} -expand} /axilite_tb/axilite_if_2.read_data_channel.rresp(1) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rresp(0) {-height 15 -radix hexadecimal} /axilite_tb/axilite_if_2.read_data_channel.rvalid {-height 15 -radix hexadecimal}} /axilite_tb/axilite_if_2
add wave -noupdate -expand -group {VVC Transactions} /axilite_tb/i_axilite_test_harness/i1_axilite_vvc/transaction_info
add wave -noupdate -expand -group {VVC Transactions} /axilite_tb/i_axilite_test_harness/i2_axilite_vvc/transaction_info
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1386 ns}
