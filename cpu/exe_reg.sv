`timaecale 1ns/1ps
/****************************************************************
@file name	: exe_reg.sv
@description: execute pipline reg
=================================================================
revision		data		author		commit
  0.1		2019/11/16	  deamonyang	draft
****************************************************************/

`include "cpu.h"

module exe_reg#(
		parameter WORD_DATA_WIDTH 	= 32,
		parameter WORD_ADDR_WIDTH 	= 30,
		parameter MEM_OP_BUS		= 2 ,
		parameter CTRL_OP_BUS	 	= 2 ,
		parameter REG_ADDR_BUS		= 5 ,
		parameter ISA_EXP_BUS		= 3
	)(
		input	wire							clk_i				,
		input	wire							rst_n_i				,
		/*alu output data*/	
		input	wire	[WORD_DATA_WIDTH-1:0]	alu_out_i			,
		input	wire							alu_of_i			,
		/*pipline state*/	
		input	wire 							stall_i				,
		input	wire 							flush_i				,
		input	wire 							int_detect_i		,//interrupt detect
		/*ID->EXE*/	
		input	wire 	[WORD_ADDR_WIDTH-1:0]	id_pc_i				,
		input	wire 							id_en_i				,
		input	wire 							id_br_flag_i		,
		input	wire 	[MEM_OP_BUS-1:0]		id_mem_op_i			,
		input	wire 	[WORD_DATA_WIDTH-1:0]	id_mem_wr_data_i	,
		input	wire 	[CTRL_OP_BUS-1:0]		id_ctrl_op_i		,
		input	wire 	[REG_ADDR_BUS-1:0]		id_dst_addr_i		,
		input	wire 							id_gpr_wre_i		,
		input	wire 	[ISA_EXP_BUS-1:0]		id_exp_code_i		,
		/*EXE->MEM*/
		output 	logic 	[WORD_ADDR_WIDTH-1:0]	exe_pc_o			,
		output 	logic 							exe_en_o			,
		output 	logic 							exe_br_flag_o		,
		output 	logic 	[MEM_OP_BUS-1:0]		exe_mem_op_o		,
		output 	logic 	[WORD_DATA_WIDTH-1:0]	exe_mem_wr_data_o	,
		output 	logic 	[CTRL_OP_BUS-1:0]		exe_ctrl_op_o		,
		output 	logic 	[REG_ADDR_BUS-1:0]		exe_dst_addr_o		,
		output 	logic 							exe_gpr_wre_o		,
		output 	logic 	[ISA_EXP_BUS-1:0]		exe_exp_code_o		,
		output 	logic 	[WORD_DATA_WIDTH-1:0]	exe_out_o			
	);

	always_ff@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)begin
		exe_pc_o			<= 'd0;
		exe_en_o			<= 1'b0;
		exe_br_flag_o 		<= 1'b0;
		exe_mem_op_o 		<= `MEM_OP_NOP;
		exe_mem_wr_data_o	<= 'd0;
		exe_ctrl_op_o 		<= `CTRL_OP_NOP;
		exe_dst_addr_o 		<= 'd0;
		exe_gpr_wre_o 		<= 1'b0;
		exe_exp_code_o 		<= `ISA_EXP_NO_EXP;
		exe_out_o 			<= 'd0;
	end else begin
		if(stall_i)begin
			if(flush_i)begin //flush
				exe_pc_o			<= 'd0;
				exe_en_o			<= 1'b0;
				exe_br_flag_o 		<= 1'b0;
				exe_mem_op_o 		<= `MEM_OP_NOP;
				exe_mem_wr_data_o	<= 'd0;
				exe_ctrl_op_o 		<= `CTRL_OP_NOP;
				exe_dst_addr_o 		<= 'd0;
				exe_gpr_wre_o 		<= 1'b0;
				exe_exp_code_o 		<= `ISA_EXP_NO_EXP;
				exe_out_o 			<= 'd0;				
			end else if(int_detect_i)begin //interrupt 
				exe_pc_o			<= id_pc_i;
				exe_en_o			<= id_en_i;
				exe_br_flag_o 		<= id_br_flag_i;
				exe_mem_op_o 		<= `MEM_OP_NOP;
				exe_mem_wr_data_o	<= 'd0;
				exe_ctrl_op_o 		<= `CTRL_OP_NOP;
				exe_dst_addr_o 		<= 'd0;
				exe_gpr_wre_o 		<= 1'b0;
				exe_exp_code_o 		<= `ISA_EXP_NO_EXP;
				exe_out_o 			<= 'd0;				
			end else if(alu_of_i)begin	//overflow
				exe_pc_o			<= id_pc_i;
				exe_en_o			<= id_en_i;
				exe_br_flag_o 		<= id_br_flag_i;
				exe_mem_op_o 		<= `MEM_OP_NOP;
				exe_mem_wr_data_o	<= 'd0;
				exe_ctrl_op_o 		<= `CTRL_OP_NOP;
				exe_dst_addr_o 		<= 'd0;
				exe_gpr_wre_o 		<= 1'b0;
				exe_exp_code_o 		<= `ISA_EXP_NO_EXP;
				exe_out_o 			<= 'd0;					
			end else begin
				exe_pc_o			<= id_pc_i;
				exe_en_o			<= id_en_i;
				exe_br_flag_o 		<= id_br_flag_i;
				exe_mem_op_o 		<= id_mem_op_i;
				exe_mem_wr_data_o	<= id_mem_wr_data_i;
				exe_ctrl_op_o 		<= id_ctrl_op_i;
				exe_dst_addr_o 		<= id_dst_addr_i;
				exe_gpr_wre_o 		<= id_gpr_wre_i;
				exe_exp_code_o 		<= id_exp_code_i;
				exe_out_o 			<= alu_out_i;				
			end
		end
	end
endmodule

