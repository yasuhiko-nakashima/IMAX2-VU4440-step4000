//------------------------------------------------------------------------------
// ACCESS CONTROL TOPMODEL
//------------------------------------------------------------------------------
// ACC_CTRL モジュール
// (1) アクセスコントロール回路
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : acc_ctrl.v
// Module         : ACC_CTRL
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/05/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/05/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module ACC_CTRL	(
				input	wire							RESET_N,			// 
				input	wire							WCLK,				// 
				input	wire							RCLK,				// 
				input	wire							WR_WREN,			// 
				input	wire							RD_WREN,			// 
				input	wire							WR_RDEN,			// 
				input	wire							RD_RDEN,			// 
				output	wire							ACC_BIT				// 
	);


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	reg		[127:0]		sr_acc;					// 
	reg		[6:0]		sr_acc_wcnt;			// 
	reg		[6:0]		sr_acc_rcnt;			// 


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------
	assign		ACC_BIT						=			sr_acc[sr_acc_rcnt];


//------------------------------------------------------------------------------
// 制御部
//------------------------------------------------------------------------------

	always@( posedge WCLK or negedge RESET_N )begin
		if( RESET_N == 1'b0 )begin
			sr_acc[127:0]		<=		128'd0;
		end else if( WR_WREN == 1'b1 && RD_WREN == 1'b1 )begin
			sr_acc[sr_acc_wcnt]			<=		1'b1;
			sr_acc[sr_acc_wcnt+1]		<=		1'b0;
		end else if( WR_WREN == 1'b1 && RD_WREN == 1'b0 )begin
			sr_acc[sr_acc_wcnt]			<=		1'b1;
		end else if( WR_WREN == 1'b0 && RD_WREN == 1'b1 )begin
			sr_acc[sr_acc_wcnt]			<=		1'b0;
		end
	end

	always@( posedge WCLK or negedge RESET_N )begin
		if( RESET_N == 1'b0 )begin
			sr_acc_wcnt[6:0]		<=		7'b000_0000;
		end else if( WR_WREN == 1'b1 && RD_WREN == 1'b1 )begin
			sr_acc_wcnt[6:0]		<=		sr_acc_wcnt[6:0] + 7'b000_0010;
		end else if( WR_WREN == 1'b1 && RD_WREN == 1'b0 )begin
			sr_acc_wcnt[6:0]		<=		sr_acc_wcnt[6:0] + 7'b000_0001;
		end else if( WR_WREN == 1'b0 && RD_WREN == 1'b1 )begin
			sr_acc_wcnt[6:0]		<=		sr_acc_wcnt[6:0] + 7'b000_0001;
		end
	end

	always@( posedge RCLK or negedge RESET_N )begin
		if( RESET_N == 1'b0 )begin
			sr_acc_rcnt[6:0]		<=		7'b000_0000;
		end else if( WR_RDEN == 1'b1 && RD_RDEN == 1'b1 )begin
			sr_acc_rcnt[6:0]		<=		sr_acc_rcnt[6:0] + 7'b000_0010;
		end else if( WR_RDEN == 1'b1 && RD_RDEN == 1'b0 )begin
			sr_acc_rcnt[6:0]		<=		sr_acc_rcnt[6:0] + 7'b000_0001;
		end else if( WR_RDEN == 1'b0 && RD_RDEN == 1'b1 )begin
			sr_acc_rcnt[6:0]		<=		sr_acc_rcnt[6:0] + 7'b000_0001;
		end
	end



endmodule

