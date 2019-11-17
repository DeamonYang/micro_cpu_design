`timaecale 1ns/1ps
/****************************************************************
@file name	: mem_reg.sv
@description: mem  ctral pipline register
=================================================================
revision		data		author		commit
  0.1		2019/11/16	  deamonyang	draft
****************************************************************/

`include "isa.h"
`include "cpu.h"

module	mem_reg#(
		parameter WORD_DATA_WIDTH 	= 32,
		parameter WORD_ADDR_WIDTH	= 30,
		parameter CTRL_OP_BUS		= 2 ,
		parameter ISA_EXP_BUS		= 3 ,
		parameter REG_ADDR_BUS		= 5
	)(
		input	wire 							clk_i			,
		input	wire 							rst_n_i			,
		input	wire 	[WORD_DATA_WIDTH-1:0]	out_i			,
		input	wire 							miss_align_i	,
		input	wire 							stall_i			,
		input	wire 							flush_i			,
		/*EXE->MEM*/		
		input	wire 	[WORD_ADDR_WIDTH-1:0]	exe_pc_i		,
		input	wire 							exe_en_i		,
		input	wire 							exe_br_flag_i	,
		input	wire 	[CTRL_OP_BUS-1:0]		exe_ctrl_op_i	,
		input	wire 	[REG_ADDR_BUS-1:0]		exe_dst_addr_i	,
		input	wire 							exe_gpr_wre_i	,
		input	wire 	[ISA_EXP_BUS-1:0]		exe_exp_code_i	,
		/*MEM->WB*/
		output	logic 	[WORD_ADDR_WIDTH-1:0]	mem_pc_o		,
		output	logic 							mem_en_o		,
		output	logic 							mem_br_flag_o	,
		output	logic 	[CTRL_OP_BUS-1:0]		mem_ctrl_op_o	,
		output	logic 	[REG_ADDR_BUS-1:0]		mem_dst_addr_o	,
		output	logic 							mem_gpr_wre_o	,
		output	logic 	[ISA_EXP_BUS-1:0]		mem_exp_code_o	,
		output	logic 	[WORD_DATA_WIDTH-1]		mem_out_o
	);
	
	always_ff@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)begin
		mem_pc_o		<= 'd0;
		mem_en_o		<= 1'b0;
		mem_br_flag_o	<= 1'b0;
		mem_ctrl_op_o	<= `CTRL_OP_NOP;
		mem_dst_addr_o	<= 'd0;
		mem_gpr_wre_o	<= 1'b0;
		mem_exp_code_o	<= `ISA_EXP_NO_EXP;
		mem_out_o		<= 'd0;
	end else begin
		if(!stall_i)begin
			if(flush_i)begin
				mem_pc_o		<= 'd0;
				mem_en_o		<= 1'b0;
				mem_br_flag_o	<= 1'b0;
				mem_ctrl_op_o	<= `CTRL_OP_NOP;
				mem_dst_addr_o	<= 'd0;
				mem_gpr_wre_o	<= 1'b0;
				mem_exp_code_o	<= `ISA_EXP_NO_EXP;
				mem_out_o		<= 'd0;				
			end else if(miss_align_i)begin
				mem_pc_o		<= exe_pc_i;
				mem_en_o		<= exe_en_i;
				mem_br_flag_o	<= exe_br_flag_i;
				mem_ctrl_op_o	<= `CTRL_OP_NOP;
				mem_dst_addr_o	<= 'd0;
				mem_gpr_wre_o	<= 1'b0;
				mem_exp_code_o	<= `ISA_EXP_NO_EXP;
				mem_out_o		<= 'd0;				
			end else begin
				mem_pc_o		<= exe_pc_i;
				mem_en_o		<= exe_en_i;
				mem_br_flag_o	<= exe_br_flag_i;
				mem_ctrl_op_o	<= exe_ctrl_op_i;
				mem_dst_addr_o	<= exe_dst_addr_i;
				mem_gpr_wre_o	<= exe_gpr_wre_i;
				mem_exp_code_o	<= exe_exp_code_i;
				mem_out_o		<= out_i;				
			end
		end
	end
	
	
endmodule



