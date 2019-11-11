`timescale 1ns/1ps

/*************************************************************
address mapping
idx	|			address			| MSB[2:0] 	|function 
 0	| 0x0000_0000 ~ 0x1FFF_FFFF	| 3'b000	|	ROM
 1	| 0x0000_0000 ~ 0x3FFF_FFFF	| 3'b001	|	SPM
 2	| 0x0000_0000 ~ 0x5FFF_FFFF	| 3'b010	|	timer
 3	| 0x0000_0000 ~ 0x7FFF_FFFF	| 3'b011	|	uart
 4	| 0x0000_0000 ~ 0x9FFF_FFFF	| 3'b100	|	gpio
 5	| 0x0000_0000 ~ 0xBFFF_FFFF	| 3'b101	|	----
 6	| 0x0000_0000 ~ 0xDFFF_FFFF	| 3'b110	|	----
 6	| 0x0000_0000 ~ 0xFFFF_FFFF	| 3'b111	|	----
*************************************************************/

module bus_addr_dec#(
		parameter ADDR_WIDTH = 32,
		parameter ADDR_IDX_WIDTH = 3
	)(
		input	logic[ADDR_WIDTH-1:0]	s_addr_i,
		output	logic					s0_cs_o,
		output	logic					s1_cs_o,
		output	logic					s2_cs_o,
		output	logic					s3_cs_o,
		output	logic					s4_cs_o,
		output	logic					s5_cs_o,
		output	logic					s6_cs_o,
		output	logic					s7_cs_o
	);
	
	logic 	[ADDR_IDX_WIDTH-1:0]s_idx = s_addr_i[ADDR_WIDTH-1:ADDR_WIDTH-ADDR_IDX_WIDTH];
	logic	[7:0] slav_cs = {s7_cs_o,s6_cs_o,s5_cs_o,s4_cs_o,s3_cs_o,s2_cs_o,s1_cs_o,s0_cs_o};
	
	always_comb@(*)begin
		case(s_idx)
			3'b000:	begin slav_cs = 8'b0000_0001;end
			3'b000:	begin slav_cs = 8'b0000_0010;end
			3'b000:	begin slav_cs = 8'b0000_0100;end
			3'b000:	begin slav_cs = 8'b0000_1000;end
			3'b000:	begin slav_cs = 8'b0001_0000;end
			3'b000:	begin slav_cs = 8'b0010_0000;end
			3'b000:	begin slav_cs = 8'b0100_0000;end
			3'b000:	begin slav_cs = 8'b1000_0000;end
			default:begin slav_cs = 8'b0000_0000;end
		endcase
	end
	
endmodule
