
`include "hglobal.v"

`default_nettype	none

`define NS_DBG_NXT_ADDR(adr)  ((adr >= MAX_ADDR)?(MIN_ADDR):(adr + 1))

`define NS_DBG_SRC 9

`define NS_DBG_RED 10


module io_bug_03
#(parameter 
	MIN_ADDR=1, 
	MAX_ADDR=1, 
	OPER_1=`NS_GT_OP, 
	REF_VAL_1=0, 
	IS_RANGE=`NS_FALSE, 
	OPER_2=`NS_GT_OP, 
	REF_VAL_2=0, 
	ASZ=`NS_ADDRESS_SIZE, 
	DSZ=`NS_DATA_SIZE, 
	RSZ=`NS_REDUN_SIZE
)(
	input wire src0_clk,
	input wire snk0_clk,
	
	// SRC
	`NS_DECLARE_OUT_CHNL(o0),
	
	// SNK_0
	`NS_DECLARE_IN_CHNL(i0),
	
	`NS_DECLARE_DBG_CHNL(dbg)
);
	`NS_DECLARE_REG_DBG(rg_dbg)
	reg [RSZ-1:0] err_mg_redun = 0;

	reg [3:0] cnt_0 = 0;
	reg [3:0] cnt_1 = 0;

	reg [DSZ-1:0] r_dat1 = 0;
	
	// SRC regs
	reg [0:0] ro0_has_dst = `NS_OFF;	
	reg [0:0] ro0_has_dat = `NS_OFF;	
	reg [0:0] ro0_has_red = `NS_OFF;	
	reg [0:0] ro0_busy = `NS_OFF;	
	reg [ASZ-1:0] ro0_src = `NS_DBG_SRC;
	reg [DSZ-1:0] ro0_dat = 0;
	reg [ASZ-1:0] ro0_dst = MIN_ADDR;
	reg [RSZ-1:0] ro0_red = 0;
	reg [0:0] ro0_req = `NS_OFF;
	reg [0:0] ro0_err = `NS_OFF;
	
	// SNK_0 regs
 	reg [3:0] err0_case = 0;
	reg [0:0] has_inp0 = `NS_OFF;
	reg [0:0] inp0_has_redun = `NS_OFF;
	reg [0:0] inp0_done_cks = `NS_OFF;
	`NS_DECLARE_REG_MSG(inp0)
	wire [RSZ-1:0] inp0_calc_redun;
	reg [RSZ-1:0] inp0_redun = 0;
	calc_redun #(.ASZ(ASZ), .DSZ(DSZ), .RSZ(RSZ)) 
		md_calc_red0 (inp0_src, inp0_dst, inp0_dat, inp0_calc_redun);
	
	
	reg [0:0] inp0_ack = `NS_OFF;
	reg [DSZ-1:0] inp0_ck_dat = 15;
	reg [0:0] inp0_err = `NS_OFF;


	wire [RSZ-1:0] ro0_redun;
	calc_redun #(.ASZ(ASZ), .DSZ(DSZ), .RSZ(RSZ)) 
		r1 (ro0_src, ro0_dst, ro0_dat, ro0_redun);
	
	//SRC
	always @(posedge src0_clk)
	begin
		if((! ro0_req) && (! o0_ack)) begin
			if(! ro0_has_dst) begin
				ro0_has_dst <= `NS_ON;
				//ro0_dst <= `NS_DBG_NXT_ADDR(ro0_dst);
				ro0_dst <= 10;
			end
			else
			if(! ro0_has_dat) begin
				ro0_has_dat <= `NS_ON;
				/* DO NOT REMOVE THIS COMMENT BECAUSE IT WILL WORK  !!!! (REMOVE COMPLETE LINES)
				if(ro0_dat > 15) begin
					ro0_err <= `NS_ON;
				end
				if(ro0_dat < 0) begin
					ro0_err <= `NS_ON;
				end*/
				if(! `NS_RANGE_CMP_OP(IS_RANGE, OPER_1, REF_VAL_1, ro0_dst, OPER_2, REF_VAL_2, ro0_dst)) begin
					ro0_dat[3:0] <= cnt_0;
					cnt_0 <= cnt_0 + 1;
				end else begin
					ro0_dat[3:0] <= cnt_1;
					cnt_1 <= cnt_1 + 1;
				end
			end
			else
			if(! ro0_has_red) begin
				ro0_has_red <= `NS_ON;
				ro0_red <= ro0_redun;
			end
			if(ro0_has_red) begin
				ro0_req <= `NS_ON;
			end
		end
		if(ro0_req && o0_ack) begin
			ro0_has_dst <= `NS_OFF;
			ro0_has_dat <= `NS_OFF;
			ro0_has_red <= `NS_OFF;
			ro0_req <= `NS_OFF;
		end
	end
	
	
	//SNK_0
	always @(posedge snk0_clk)
	begin
		if(i0_req && (! inp0_ack)) begin
			if(! has_inp0) begin
				has_inp0 <= `NS_ON;
				`NS_MOV_REG_MSG(inp0, i0)
			end
			else
			if(! inp0_has_redun) begin
				inp0_has_redun <= `NS_ON;
				inp0_redun <= inp0_calc_redun;
			end
			else
			if(! inp0_done_cks) begin
				inp0_done_cks <= `NS_ON;
				if(! inp0_err) begin
					if(inp0_red != inp0_redun) begin
						inp0_err <= `NS_ON;
					end

					if((inp0_ck_dat <= 14) && ((inp0_ck_dat + 1) != inp0_dat)) begin
						inp0_err <= `NS_ON;
						
						rg_dbg_disp0 <= inp0_ck_dat[3:0];
						rg_dbg_disp1 <= inp0_dat[3:0];
					end 
					else 
					begin 
						inp0_ck_dat <= inp0_dat;
					end
				end
			end
			if(inp0_done_cks) begin
				has_inp0 <= `NS_OFF;
				inp0_has_redun <= `NS_OFF;
				inp0_done_cks <= `NS_OFF;
				
				inp0_ack <= `NS_ON;
			end
		end
		//else
		if((! i0_req) && inp0_ack) begin
			inp0_ack <= `NS_OFF;
		end
	end
	
	//SRC
	`NS_ASSIGN_OUT_MSG(o0, ro0)
	assign o0_req = ro0_req;

	//SNK_0
	assign i0_ack = inp0_ack;
	
	//`NS_ASSIGN_OUT_DBG(dbg, rg_dbg)
	assign dbg_leds[0:0] = inp0_err;
	assign dbg_leds[1:1] = 0;
	assign dbg_leds[2:2] = ro0_err;
	assign dbg_leds[3:3] = 0;
	assign dbg_disp0 = rg_dbg_disp0;
	assign dbg_disp1 = rg_dbg_disp1;
	
endmodule
