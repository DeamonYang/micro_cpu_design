`timaecale 1ns/1ps
/****************************************************************
@file name	: if_reg.sv
@description: instruction reg
=================================================================
revision		data		author		commit
  0.1		2019/11/13	  deamonyang	draft
****************************************************************/
`include "isa.h"

module if_reg#(
		parameter DAT_WIDTH = 32,
		parameter ADD_WIDTH = 30
	)(
		input	wire						clk_i,
		input	wire						rst_n_i,
		
		input	wire	[DAT_WIDTH-1:0]		instru_i,
		
		input	wire						stall_i,//pipline delay
		input	wire						flush_i,
		input	wire	[ADD_WIDTH-1:0]		new_pc_i,
		input	wire						br_taken_i,
		input	wire	[ADD_WIDTH-1:0]		br_addr,
		
		output	logic	[ADD_WIDTH-1:0]		if_pc_o,
		output	logic	[DAT_WIDTH-1:0]		if_instru_o,
		output	logic						if_en_o		//pipline data is valid
	); 
	
	always_ff@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)begin
		if_pc_o <= 'd0;
		if_instru_o <= `ISA_NOP;
		if_en_o <= 1'b0;
	end else begin
		if(!stall_i)begin
			if(flush_i)begin
				if_pc_o <= new_pc_i;
				if_instru_o <= `ISA_NOP;
				if_en_o <= 1'b0;
			end else if(br_taken_i)begin
				if_pc_o <= br_taken_i;
				if_instru_o <= instru_i;
				if_en_o <= 1'b1;
			end else begin
				if_pc_o <= if_pc_o + 1'b1;
				if_instru_o <= instru_i;
				if_en_o <= 1'b1;
			end
		end
	end
		
	
	
	
endmodule





