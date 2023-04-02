//------------------------------------------------------------------------------
// RESET CTRL MODEL
//------------------------------------------------------------------------------
// RESET CTRL モジュール
// (1) リセット制御処理
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : reset_ctrl.v
// Module         : RESET_CTRL
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/05/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/05/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

`include "reset_common.vh" 

module RESET_CTRL (
					MAIN_CLK,								// 
					MAIN_RESET_N,							// 
					EXT_RESET,								// 
					DCM_LOCKED,								// 

					CPU_RESET_P,							// 
					CPU_RESET_N,							// 
					USER_RESET_P,							// 
					USER_RESET_N,							// 
					PERI_RESET_P,							// 
					PERI_RESET_N							// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input							MAIN_CLK;				// 
	input							MAIN_RESET_N;			// 
	input							EXT_RESET;				// 
	input							DCM_LOCKED;				// 
//	output							CPU_RESET_P;			// 
//	output							CPU_RESET_N;			// 
//	output							USER_RESET_P;			// 
//	output							USER_RESET_N;			// 
//	output							PERI_RESET_P;			// 
//	output							PERI_RESET_N;			// 


	(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CPU_RESET_P, POLARITY ACTIVE_HIGH, TYPE PROCESSOR, INSERT_VIP 0" *) (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 CPU_RESET_P RST" *)	output	CPU_RESET_P;
	(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CPU_RESET_N, POLARITY ACTIVE_LOW,  TYPE PROCESSOR, INSERT_VIP 0" *) (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 CPU_RESET_N RST" *)	output	CPU_RESET_N;


	(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME USER_RESET_P, POLARITY ACTIVE_HIGH, TYPE INTERCONNECT, INSERT_VIP 0" *) (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 USER_RESET_P RST" *)	output	USER_RESET_P;
	(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME USER_RESET_N, POLARITY ACTIVE_LOW,  TYPE INTERCONNECT, INSERT_VIP 0" *) (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 USER_RESET_N RST" *)	output	USER_RESET_N;


	(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PERI_RESET_P, POLARITY ACTIVE_HIGH, TYPE PERIPHERAL, INSERT_VIP 0" *) (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 PERI_RESET_P RST" *)	output	PERI_RESET_P;
	(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PERI_RESET_N, POLARITY ACTIVE_LOW,  TYPE PERIPHERAL, INSERT_VIP 0" *) (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 PERI_RESET_N RST" *)	output	PERI_RESET_N;


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire							s_reset_n;				// 

`ifdef BUFG_ENABLE
	wire							s_cpu_reset;			// 
	wire							s_cpu_reset_n;			// 
	wire							s_user_rese;			// 
	wire							s_user_reset_n;			// 
	wire							s_peri_reset;			// 
	wire							s_peri_reset_n;			// 
`endif


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	reg								sr_cpu_reset;			// 
	reg								sr_user_reset;			// 
	reg								sr_peri_reset;			// 
	reg		[31:0]					sr_reset_cnt;			// 


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

`ifdef BUFG_ENABLE
	BUFG	inst_bufg_cpu		( .I( sr_cpu_reset),  .O(s_cpu_reset) );
	BUFG	inst_bufg_cpu_n		( .I(~sr_cpu_reset),  .O(s_cpu_reset_n) );
	BUFG	inst_bufg_user		( .I( sr_user_reset), .O(s_user_reset) );
	BUFG	inst_bufg_user_n	( .I(~sr_user_reset), .O(s_user_reset_n) );
	BUFG	inst_bufg_peri		( .I( sr_peri_reset), .O(s_peri_reset) );
	BUFG	inst_bufg_peri_n	( .I(~sr_peri_reset), .O(s_peri_reset_n) );
`endif


//------------------------------------------------------------------------------
// Initial
//------------------------------------------------------------------------------
initial
	begin
		sr_reset_cnt[31:0]		=	32'h0000_0000;
		sr_cpu_reset			=	1'b1;
		sr_user_reset			=	1'b1;
		sr_peri_reset			=	1'b1;
	end


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------

`ifdef BUFG_ENABLE
	assign		CPU_RESET_P					=		s_cpu_reset;
	assign		CPU_RESET_N					=		s_cpu_reset_n;

	assign		USER_RESET_P				=		s_user_reset;
	assign		USER_RESET_N				=		s_user_reset_n;

	assign		PERI_RESET_P				=		s_peri_reset;
	assign		PERI_RESET_N				=		s_peri_reset_n;
`else
	assign		CPU_RESET_P					=		sr_cpu_reset;
	assign		CPU_RESET_N					=		~sr_cpu_reset;

	assign		USER_RESET_P				=		sr_user_reset;
	assign		USER_RESET_N				=		~sr_user_reset;

	assign		PERI_RESET_P				=		sr_peri_reset;
	assign		PERI_RESET_N				=		~sr_peri_reset;
`endif


//------------------------------------------------------------------------------
// リセット制御部
//------------------------------------------------------------------------------

	assign	s_reset_n		=		( MAIN_RESET_N == 1'b0 || EXT_RESET == 1'b1 || DCM_LOCKED == 1'b0 ) ? 1'b0 : 1'b1;

	always@( posedge MAIN_CLK or negedge s_reset_n )begin
		if( s_reset_n == 1'b0 )begin
			sr_reset_cnt[31:0]		<=	32'h0000_0000;
		end else if( sr_reset_cnt[31:0] != 32'hFFFF_FFFF )begin
			sr_reset_cnt[31:0]		<=		sr_reset_cnt[31:0] + 32'h0000_0001;
		end
	end

	always@( posedge MAIN_CLK or negedge s_reset_n )begin
		if( s_reset_n == 1'b0 )begin
//			sr_cpu_reset		<=		1'b0;
			sr_cpu_reset		<=		1'b1;
		end else if( sr_reset_cnt[31:0] == `CPU_RESET_CNT )begin
			sr_cpu_reset		<=		1'b0;
		end else if( sr_reset_cnt[31:0] == 32'h0000_0001 )begin
			sr_cpu_reset		<=		1'b1;
		end
	end

	always@( posedge MAIN_CLK or negedge s_reset_n )begin
		if( s_reset_n == 1'b0 )begin
//			sr_user_reset		<=		1'b0;
			sr_user_reset		<=		1'b1;
		end else if( sr_reset_cnt[31:0] == `USER_RESET_CNT )begin
			sr_user_reset		<=		1'b0;
		end else if( sr_reset_cnt[31:0] == 32'h0000_0001 )begin
			sr_user_reset		<=		1'b1;
		end
	end

	always@( posedge MAIN_CLK or negedge s_reset_n )begin
		if( s_reset_n == 1'b0 )begin
//			sr_peri_reset		<=		1'b0;
			sr_peri_reset		<=		1'b1;
		end else if( sr_reset_cnt[31:0] == `PERI_RESET_CNT )begin
			sr_peri_reset		<=		1'b0;
		end else if( sr_reset_cnt[31:0] == 32'h0000_0001 )begin
			sr_peri_reset		<=		1'b1;
		end
	end



endmodule

