//------------------------------------------------------------------------------
// BUFF_16bxnW MODEL
//------------------------------------------------------------------------------
// BUFF_16bxnw モジュール
// (1) BUFF
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : buff_16bxnw.v
// Module         : BUFF_16BXNW
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/05/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/05/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module BUFF_16BXNW # (
					parameter	BUFF_WORD		=	8,	// 
					parameter	CNT_BIT			=	3	// 
				) (
					RST_N,								// 
					CLK,								// 
					WREN,								// 
					WDATA,								// 
					RDEN,								// 
					RDATA,								// 
					CNT									// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input					RST_N;						// 
	input					CLK;						// 
	input					WREN;						// 
	input	[15:0]			WDATA;						// 
	input					RDEN;						// 
	output	[15:0]			RDATA;						// 
	output	[CNT_BIT:0]		CNT;						// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire	[15:0]			s_rdata;					// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	(* ram_style = "register" *)	reg	[15:0]	sr_data[0:BUFF_WORD-1];	// 
	reg		[CNT_BIT-1:0]	sr_wcnt;					// 
	reg		[CNT_BIT-1:0]	sr_rcnt;					// 
	reg		[CNT_BIT:0]		sr_cnt;						// 


//------------------------------------------------------------------------------
// integer
//------------------------------------------------------------------------------
	integer					bc;


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------
	assign		RDATA[15:0]				=		s_rdata[15:0];
	assign		CNT[CNT_BIT:0]			=		sr_cnt[CNT_BIT:0];


//------------------------------------------------------------------------------
// ライトBUFF制御部
//------------------------------------------------------------------------------

	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			for (bc=0;bc<BUFF_WORD;bc=bc+1) begin
				sr_data[bc]		=		16'd0;
			end
		end else if( WREN == 1'b1 )begin
			sr_data[sr_wcnt[CNT_BIT-1:0]]		<=		WDATA[15:0];
		end
	end

	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_wcnt[CNT_BIT-1:0]		<=		{CNT_BIT{1'b0}};
		end else if( WREN == 1'b1 )begin
			sr_wcnt[CNT_BIT-1:0]		<=		sr_wcnt[CNT_BIT-1:0] + { {CNT_BIT-1{1'b0}}, {1{1'b1}} };
		end
	end



//------------------------------------------------------------------------------
// リードFIFO制御部
//------------------------------------------------------------------------------

	assign		s_rdata[15:0]			=		sr_data[sr_rcnt[CNT_BIT-1:0]];


	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_rcnt[CNT_BIT-1:0]		<=		{CNT_BIT{1'b0}};
		end else if( RDEN == 1'b1 )begin
			sr_rcnt[CNT_BIT-1:0]		<=		sr_rcnt[CNT_BIT-1:0] + { {CNT_BIT-1{1'b0}}, {1{1'b1}} };
		end
	end

	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_cnt[CNT_BIT:0]			<=		{CNT_BIT+1{1'b0}};
		end else if( WREN == 1'b1 && RDEN == 1'b0 )begin
			sr_cnt[CNT_BIT:0]			<=		sr_cnt[CNT_BIT:0] + { {CNT_BIT{1'b0}}, {1{1'b1}} };
		end else if( WREN == 1'b0 && RDEN == 1'b1 )begin
			sr_cnt[CNT_BIT:0]			<=		sr_cnt[CNT_BIT:0] - { {CNT_BIT{1'b0}}, {1{1'b1}} };
		end
	end



endmodule

