`timaecale 1ns/1ps
/****************************************************************
@file name	: alu.sv
@description: arithmetic and logic uni
=================================================================
revision		data		author		commit
  0.1		2019/11/16	  deamonyang	draft
****************************************************************/
`include "cpu.h"

module alu#(
		parameter ALU_DAT_WIDTH = 32,
		parameter ALU_OP_BUS	= 4
	)(
		input	wire	[ALU_DAT_WIDTH-1:0]		in_0_i	,
		input	wire	[ALU_DAT_WIDTH-1:0]		in_1_i	,	
		input	wire	[ALU_OP_BUS-1:0]		op_i	,
		output	logic	[ALU_DAT_WIDTH-1:0]		out_o	,
		output	logic							of_o	,//overflow flag
	);
	
	logic signed [ALU_DAT_WIDTH-1:0]	s_in_0 = $signed(in_0_i);
	logic signed [ALU_DAT_WIDTH-1:0]	s_in_1 = $signed(in_1_i);
	logic signed [ALU_DAT_WIDTH-1:0]	s_out =  $signed(out_o);	
	
	
	/*arithmetic and logic processing*/
	always_comb@(*)begin
		case (op_i)			
			`ALU_OP_AND	: begin out_o = in_0_i & in_1_i; 				end
			`ALU_OP_OR	: begin out_o = in_0_i | in_1_i; 				end
			`ALU_OP_XOR	: begin out_o = in_0_i ^ in_1_i; 				end
			`ALU_OP_ADDS: begin out_o = in_0_i + in_1_i; 				end	
			`ALU_OP_ADDU: begin out_o = in_0_i + in_1_i; 				end	
			`ALU_OP_SUBS: begin out_o = in_0_i - in_1_i; 				end	
			`ALU_OP_SUBU: begin out_o = in_0_i - in_1_i; 				end	
			`ALU_OP_SHRL: begin out_o = in_0_i >> in_1_i[`ShAmountLoc]; end	
			`ALU_OP_SHLL: begin out_o = in_0_i << in_1_i[`ShAmountLoc]; end	
			default		: begin	out_o = in_0_i; 						end
		endcase
	end

	/*check overflow*/
	always_comb@(*)begin
		case(op_i)
			`ALU_OP_ADDS : begin
				if(((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||
				   ((s_in_0 < 0) && (s_in_1 < 0) && (s_out > 0)) )begin
					of_o = 1'b1;
				end else begin
					of_o = 1'b0;
				end
			end
			
			`ALU_OP_SUBS :begin
				if(((s_in_0 < 0) && (s_in_1 > 0) && (s_out > 0))||
				   ((s_in_0 > 0) && (s_in_1 < 0) && (s_out < 0)))
					of_o = 1'b1;
				else
					of_o = 1'b0;
			end
			default : begin
				of_o = 1'b0;
			end
		endcase
	end


endmodule

