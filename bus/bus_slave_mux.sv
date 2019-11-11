`timescale 1ns/1ps

module bus_slave_mux#(
		parameter DATA_BUS_WIDTH = 32
	)(
		input							s0_cs_i,
		input							s1_cs_i,
		input							s2_cs_i,
		input							s3_cs_i,
		input							s4_cs_i,
		input							s5_cs_i,
		input							s6_cs_i,
		input							s7_cs_i,
		
		input	[DATA_BUS_WIDTH-1:0]	s0_rd_data_i,
		input							s0_rdy_i,
		
		input	[DATA_BUS_WIDTH-1:0]	s1_rd_data_i,
		input							s1_rdy_i,
		
		input	[DATA_BUS_WIDTH-1:0]	s2_rd_data_i,
		input							s2_rdy_i,
		
		input	[DATA_BUS_WIDTH-1:0]	s3_rd_data_i,
		input							s3_rdy_i,
		
		input	[DATA_BUS_WIDTH-1:0]	s4_rd_data_i,
		input							s4_rdy_i,
		
		input	[DATA_BUS_WIDTH-1:0]	s5_rd_data_i,
		input							s5_rdy_i,
		
		input	[DATA_BUS_WIDTH-1:0]	s6_rd_data_i,
		input							s6_rdy_i,
		
		input	[DATA_BUS_WIDTH-1:0]	s7_rd_data_i,
		input							s7_rdy_i,
		
		output	[DATA_BUS_WIDTH-1:0]	m_rd_data_o,
		output							m_rdy_o
	);
	
	logic [7:0]sc_cs = {s7_cs_i,s6_cs_i,s5_cs_i,s4_cs_i,s3_cs_i,s2_cs_i,s1_cs_i,s0_cs_i};
	
	always_comb@(*)begin
		case(sc_cs)
			8'b0000_0001:	begin m_rd_data_o <= s0_rd_data_i; m_rdy_o <= s0_rdy_i; end
			8'b0000_0010:	begin m_rd_data_o <= s1_rd_data_i; m_rdy_o <= s1_rdy_i; end
			8'b0000_0100:	begin m_rd_data_o <= s2_rd_data_i; m_rdy_o <= s2_rdy_i; end
			8'b0000_1000:	begin m_rd_data_o <= s3_rd_data_i; m_rdy_o <= s3_rdy_i; end
			8'b0001_0000:	begin m_rd_data_o <= s4_rd_data_i; m_rdy_o <= s4_rdy_i; end
			8'b0010_0000:	begin m_rd_data_o <= s5_rd_data_i; m_rdy_o <= s5_rdy_i; end
			8'b0100_0000:	begin m_rd_data_o <= s6_rd_data_i; m_rdy_o <= s6_rdy_i; end
			8'b1000_0000:	begin m_rd_data_o <= s7_rd_data_i; m_rdy_o <= s7_rdy_i; end
			default		:	begin m_rd_data_o <= 'd0; m_rdy_o <= 'b0; end
		endcase
	end
	
	
	
	
	