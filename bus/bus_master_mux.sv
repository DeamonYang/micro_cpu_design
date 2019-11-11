`timescale 1ns/1ps


module bus_master_mux#(
		parameter BUS_ADD_WIDTH = 32,
		parameter BUS_DAT_WIDTH = 32,
	)(
	input	logic[BUS_ADD_WIDTH-1:0]	m0_addr_i,		//master address bus
	input	logic						m0_addr_cs_i,	//address chip select
	input	logic						m0_rw_i,		//read/write
	input	logic[BUS_DAT_WIDTH-1:0]	m0_wr_data_i,		//data bus
	input	logic						m0_grnt_i,		//grant bus signal generate from arbiter

	input	logic[BUS_ADD_WIDTH-1:0]	m1_addr_i,		//master address bus
	input	logic						m1_addr_cs_i,	//address chip select
	input	logic						m1_rw_i,		//read/write
	input	logic[BUS_DAT_WIDTH-1:0]	m1_wr_data_i,		//data bus
	input	logic						m1_grnt_i,		//grant bus signal generate from arbiter
	
	input	logic[BUS_ADD_WIDTH-1:0]	m2_addr_i,		//master address bus
	input	logic						m2_addr_cs_i,	//address chip select
	input	logic						m2_rw_i,		//read/write
	input	logic[BUS_DAT_WIDTH-1:0]	m2_wr_data_i,		//data bus
	input	logic						m2_grnt_i,		//grant bus signal generate from arbiter

	input	logic[BUS_ADD_WIDTH-1:0]	m3_addr_i,		//master address bus
	input	logic						m3_addr_cs_i,	//address chip select
	input	logic						m3_rw_i,		//read/write
	input	logic[BUS_DAT_WIDTH-1:0]	m3_wr_data_i,		//data bus
	input	logic						m3_grnt_i,		//grant bus signal generate from arbiter	
	
	output	logic[BUS_ADD_WIDTH-1:0]	s_addr_o,		//master address bus
	output	logic						s_addr_cs_o,	//address chip select
	output	logic						s_rw_o,			//read/write
	output	logic[BUS_DAT_WIDTH-1:0]	s_data_o		//data bus
	);
	
	localparam GRANT_M0 = 4'b0001;
	localparam GRANT_M1 = 4'b0010;
	localparam GRANT_M2 = 4'b0100;
	localparam GRANT_M3 = 4'b1000;
	
	
	logic [3:0]grant;
	assign grant = {m3_grnt_i,m2_grnt_i,m1_grnt_i,m0_grnt_i};
	
	always_comb@(*)begin
		case(grant)
			GRANT_M0:begin
				s_addr_o = m0_addr_i;
				s_addr_cs_o = m0_addr_cs_i;
				s_rw_o = m0_rw_i;
				s_data_o = m0_wr_data_i;
			end
			
			GRANT_M1:begin
				s_addr_o = m1_addr_i;
				s_addr_cs_o = m1_addr_cs_i;
				s_rw_o = m1_rw_i;
				s_data_o = m1_wr_data_i;
			end
			
			GRANT_M2:begin
				s_addr_o = m2_addr_i;
				s_addr_cs_o = m2_addr_cs_i;
				s_rw_o = m2_rw_i;
				s_data_o = m2_wr_data_i;
			end
			
			GRANT_M3:begin
				s_addr_o = m3_addr_i;
				s_addr_cs_o = m3_addr_cs_i;
				s_rw_o = m3_rw_i;
				s_data_o = m3_wr_data_i;
			end
			
			default:begin
				s_addr_o = 'd0;
				s_addr_cs_o = 1'b0;
				s_rw_o = 1'b0;
				s_data_o = 'd0;
			end
	end


endmodule













