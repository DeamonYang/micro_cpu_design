`timaecale 1ns/1ps
/****************************************************************
@file name	: mem_ctrl.sv
@description: mem contro unit
=================================================================
revision		data		author		commit
  0.1		2019/11/16	  deamonyang	draft
****************************************************************/
`include "isa.h"
`include "cpu.h"

module mem_ctrl#(
		parameter MEM_OP_BUS		= 2 ,
		parameter WORD_DATA_WIDTH 	= 32,
		parameter WORD_ADDR_WIDTH	= 30
	)(
		input	wire 								exe_en_i			,
		input	wire 	[MEM_OP_BUS-1:0]			exe_mem_op_i		,
		input	wire 	[WORD_DATA_WIDTH-1:0]		exe_mem_wr_data_i	,
		input	wire 	[WORD_DATA_WIDTH-1:0]		exe_out_i			,
		input	wire 	[WORD_DATA_WIDTH-1:0]		rd_data_i			,
		output	logic 	[WORD_ADDR_WIDTH-1:0]		addr_o				,
		output	logic 								addrs_o				,
		output	logic 								rw_o				,
		output	logic 	[WORD_DATA_WIDTH-1:0]		wr_data_o			,
		output	logic 	[WORD_DATA_WIDTH-1:0]		out_o					,
		output	logic 								miss_align_o		
	);
	
	logic	[MEM_OP_BUS-1:0]	offset;

	assign wr_data_o = exe_mem_wr_data_i;
	assign addr_o = exe_out_i[WORD_DATA_WIDTH-1:MEM_OP_BUS];
	assign offset = exe_out_i[MEM_OP_BUS-1:0];
	
	always_comb@(*)begin
		miss_align_o	= 1'b0;
		out_o			= 'd0;
		addrs_o 		= 1'b0;
		rw_o 			= 1'b1; //read
		if(exe_en_i)begin
			case(exe_mem_op_i)
				`MEM_OP_LDW:begin
					if(offset == 2'b00)begin
						out_o = rd_data_i;
						addrs_o = 1'b1;
					end else begin
						miss_align_o = 1'b1;
					end
				end
				`MEM_OP_STW:begin
					if(offset == 2'b00)begin
						rw_o = 1'b1;//write
						addrs_o = 1'b1;
					end else begin
						miss_align_o = 1'b1;
					end
				end
				default:begin
					out_o = exe_out_i;
				end
				
			endcase
		end
	end
	
	

endmodule

