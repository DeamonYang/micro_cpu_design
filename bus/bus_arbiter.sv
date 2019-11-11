`timescale 1ns/1ps

module bus_arbiter(
	input	logic		clk_i,
	input	logic		rst_n_i,
	/*arbiter channel 0*/
	input	logic		m0_req_i,
	output	logic		m0_grnt_o,

	input	logic		m1_req_i,
	output	logic		m1_grnt_o,
	
	input	logic		m2_req_i,
	output	logic		m2_grnt_o,
	
	input	logic		m3_req_i,
	output	logic		m3_grnt_o
);
	
	localparam BUS_WIDTH = 2;
	localparam BUS_OWNER_MASTER_0 = 2'd0;
	localparam BUS_OWNER_MASTER_1 = 2'd1;
	localparam BUS_OWNER_MASTER_2 = 2'd2;
	localparam BUS_OWNER_MASTER_3 = 2'd3;
	
	logic[BUS_WIDTH-1:0] bus_owner;

	/*generate grant idx according to request signal priority*/
	always_ff@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		bus_owner <= BUS_OWNER_MASTER_0;
	else begin
		case(bus_owner)
			BUS_OWNER_MASTER_0:begin
				if(m0_req_i)
					bus_owner <= BUS_OWNER_MASTER_0;
				else if(m1_req_i)
					bus_owner <= BUS_OWNER_MASTER_1;
				else if(m2_req_i)
					bus_owner <= BUS_OWNER_MASTER_2;
				else if(m3_req_i)
					bus_owner <= BUS_OWNER_MASTER_3;
				else
					bus_owner <= bus_owner;
			end
			
			BUS_OWNER_MASTER_1:begin
				if(m1_req_i)
					bus_owner <= BUS_OWNER_MASTER_1;
				else if(m2_req_i)
					bus_owner <= BUS_OWNER_MASTER_2;
				else if(m3_req_i)
					bus_owner <= BUS_OWNER_MASTER_3;
				else if(m0_req_i)
					bus_owner <= BUS_OWNER_MASTER_0;
				else
					bus_owner <= bus_owner;
			end

			BUS_OWNER_MASTER_2:begin
				if(m2_req_i)
					bus_owner <= BUS_OWNER_MASTER_2;
				else if(m3_req_i)
					bus_owner <= BUS_OWNER_MASTER_3;
				else if(m0_req_i)
					bus_owner <= BUS_OWNER_MASTER_0;
				else if(m1_req_i)
					bus_owner <= BUS_OWNER_MASTER_1;
				else
					bus_owner <= bus_owner;
			end
			BUS_OWNER_MASTER_3:begin
				if(m3_req_i)
					bus_owner <= BUS_OWNER_MASTER_3;
				else if(m0_req_i)
					bus_owner <= BUS_OWNER_MASTER_0;
				else if(m1_req_i)
					bus_owner <= BUS_OWNER_MASTER_1;
				else if(m2_req_i)
					bus_owner <= BUS_OWNER_MASTER_2;
				else
					bus_owner <= bus_owner;
			end
		endcase
	end

	/*generate grant signal*/
	always_comb@(*)begin
		{m0_grnt_o,m1_grnt_o,m2_grnt_o,m3_grnt_o} <= 4'd0;
		case(bus_owner)
			BUS_OWNER_MASTER_0:begin
				m0_grnt_o = 1'b1;					
			end
			BUS_OWNER_MASTER_1:begin
				m1_grnt_o = 1'b1;
			end
			BUS_OWNER_MASTER_2:begin
				m2_grnt_o = 1'b1;
			end
			BUS_OWNER_MASTER_3:begin
				m3_grnt_o = 1'b1;
			end
		endcase
	end


endmodule

