`timaecale 1ns/1ps
/****************************************************************
@file name	: id_reg.sv
@description: instruction decoder pipline reg
=================================================================
revision		data		author		commit
  0.1		2019/11/15	  deamonyang	draft
****************************************************************/
`include "isa.h"
`include "cpu.h"

module #(
		parameter ALU_OP_BUS = 4,
		parameter ID_DAT_WIDTH = 32,
		parameter ID_ADD_WIDTH = 30,
		parameter MEM_OP_BUS = 2,
		parameter CTRL_OP_BUS = 2,
		parameter REG_ADD_BUS = 5,
		parameter ISA_EXP_BUS = 3
	)(
		input	wire							clk_i,
		input	wire							rst_n_i,
		/*decode result input port*/
		input	wire	[ALU_OP_BUS-1:0]		alu_op_i,
		input	wire	[ID_DAT_WIDTH-1:0]		alu_in_0_i,
		input	wire	[ID_DAT_WIDTH-1:0]		alu_in_1_i,
		input	wire							br_flag_i,
		input	wire	[MEM_OP_BUS-1:0]		mem_op_i,
		input	wire	[ID_DAT_WIDTH-1:0]		mem_wr_data_i,
		input	wire	[CTRL_OP_BUS-1:0]		ctrl_op_i,
		input	wire	[REG_ADD_BUS-1:0]		dst_addr_i,
		input	wire							gpr_wre_i,
		input	wire	[ISA_EXP_BUS-1:0]		exp_code_i,
		/*pipline control signal*/
		input	wire							stall_i,
		input	wire							flush_i,
		/*IF->ID pipline reg*/
		input	wire	[ID_ADD_WIDTH-1:0]		if_pc_i,
		input	wire							if_en_i,
		/*ID->EX*/	
		output	logic	[ID_ADD_WIDTH-1:0]		id_pc_o,
		output	logic							id_en_o,
		output	logic	[ALU_OP_BUS-1:0]		id_alu_op_o,
		output	logic	[ID_DAT_WIDTH-1:0]		id_alu_in_0_o,
		output	logic	[ID_DAT_WIDTH-1:0]		id_alu_in_1_o,
		output	logic							id_br_flag_o,
		output	logic	[MEM_OP_BUS-1:0]		id_mem_op_o,
		output	logic	[ID_DAT_WIDTH-1:0]		id_mem_wr_data_o,
		output	logic	[CTRL_OP_BUS-1:0]		id_ctrl_op_o,
		output	logic	[REG_ADD_BUS-1:0]		id_dst_addr_o,
		output	logic							id_gpr_wre_o,
		output	logic	[ISA_EXP_BUS-1:0]		id_exp_code_o
	);

	always_ff@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)begin
		id_pc_o <= 'd0;
		id_en_o <= 1'b0;
		id_alu_op_o <= `ALU_OP_NOP;
		id_alu_in_0_o <= 'd0;
		id_alu_in_1_o <= 'd0;
		id_br_flag_o <= 1'b0;
		id_mem_op_o <= `MEM_OP_NOP;
		id_mem_wr_data_o <= 'd0;
		id_ctrl_op_o <= `CTRL_OP_NOP;
		id_dst_addr_o <= 'd0;
		id_gpr_wre_o <= 1'b0;
		id_exp_code_o <= `ISA_EXP_NO_EXP;
	end else begin
		if(!stall_i) begin
			if(flush_i)begin
				id_pc_o <= 'd0;
				id_en_o <= 1'b0;
				id_alu_op_o <= `ALU_OP_NOP;
				id_alu_in_0_o <= 'd0;
				id_alu_in_1_o <= 'd0;
				id_br_flag_o <= 1'b0;
				id_mem_op_o <= `MEM_OP_NOP;
				id_mem_wr_data_o <= 'd0;
				id_ctrl_op_o <= `CTRL_OP_NOP;
				id_dst_addr_o <= 'd0;
				id_gpr_wre_o <= 1'b0;
				id_exp_code_o <= `ISA_EXP_NO_EXP;	
			end else begin
				id_pc_o <= if_pc_i;
				id_en_o <= if_en_i;
				id_alu_op_o <= alu_op_i;
				id_alu_in_0_o <= alu_in_0_i;
				id_alu_in_1_o <= alu_in_1_i;
				id_br_flag_o <= br_flag_i;
				id_mem_op_o <= mem_op_i;
				id_mem_wr_data_o <= mem_wr_data_i;
				id_ctrl_op_o <= ctrl_op_i;
				id_dst_addr_o <= dst_addr_i;
				id_gpr_wre_o <= gpr_wre_i;
				id_exp_code_o <= exp_code_i;
			end
		end
	end


endmodule































