/*------------------------------------------*/
/*  Test bench for FPU                      */
/*              Y.Nakashima 2020/2/10       */
/*------------------------------------------*/

`timescale 1ns/1ns

`include "stage2.v"
`include "stage3.v"
`include "stage4.v"
`include "nbit_csa.v"
`include "nbit_ndepth_queue.v"
`include "nbit_register.v"
`include "bit24_booth_wallace.v"
       
module tb_fpu;
   reg  [9:0] 		         system_cycle;
   reg [15:0] 			 error;
   reg 				 ACLK;
   reg 				 RSTN;

   wire [1:0] 			 op   = 2'h0; // FMA
   reg  [31:0] 			 ex1;
   reg  [31:0] 			 ex2;
   reg  [31:0] 			 ex3;
   reg 				 cfma_force0;
   wire [31:0] 			 exd;

   wire 			 ex1_d_s;
   wire [8:0] 			 ex1_d_exp;
   wire [24+`PEXT:0] 		 ex1_d_csa_s; //¢£¢£¢£
   wire [24+`PEXT:0] 		 ex1_d_csa_c; //¢£¢£¢£
   wire 			 ex1_d_zero;
   wire 			 ex1_d_inf;
   wire 			 ex1_d_nan;
   wire 			 fadd_s1_s;
   wire [8:0] 			 fadd_s1_exp;
   wire [24+`PEXT:0] 		 fadd_s1_frac; //¢£¢£¢£
   wire 			 fadd_s1_zero;
   wire 			 fadd_s1_inf;
   wire 			 fadd_s1_nan;

   fpu1 fpu1
     (
      .ACLK               (ACLK                 ),
      .RSTN               (RSTN                 ),
      .op                 (op                   ),
      .ex1                (ex1[31:0]            ),
      .ex2                (ex2[31:0]            ),
      .ex3                (ex3[31:0]            ),
      .force0             (1'b0                 ),
      .ex1_d_s            (ex1_d_s              ),
      .ex1_d_exp          (ex1_d_exp            ),
      .ex1_d_csa_s        (ex1_d_csa_s          ),
      .ex1_d_csa_c        (ex1_d_csa_c          ),
      .ex1_d_zero         (ex1_d_zero           ),
      .ex1_d_inf          (ex1_d_inf            ),
      .ex1_d_nan          (ex1_d_nan            ),
      .fadd_s1_s          (fadd_s1_s            ),
      .fadd_s1_exp        (fadd_s1_exp          ),
      .fadd_s1_frac       (fadd_s1_frac         ),
      .fadd_s1_zero       (fadd_s1_zero         ),
      .fadd_s1_inf        (fadd_s1_inf          ),
      .fadd_s1_nan        (fadd_s1_nan          )
      );

   wire 			 ex2_d_s;
   wire [ 8:0] 			 ex2_d_exp;
   wire [25+`PEXT:0] 		 ex2_d_frac; //¢£¢£¢£
   wire 			 ex2_d_inf;
   wire 			 ex2_d_nan;

   fpu2 fpu2
     (
      .ACLK               (ACLK                 ),
      .RSTN               (RSTN                 ),
      .ex1_d_s            (ex1_d_s              ),
      .ex1_d_exp          (ex1_d_exp            ),
      .ex1_d_csa_s        (ex1_d_csa_s          ),
      .ex1_d_csa_c        (ex1_d_csa_c          ),
      .ex1_d_zero         (ex1_d_zero           ),
      .ex1_d_inf          (ex1_d_inf            ),
      .ex1_d_nan          (ex1_d_nan            ),
      .fadd_s1_s          (fadd_s1_s            ),
      .fadd_s1_exp        (fadd_s1_exp          ),
      .fadd_s1_frac       (fadd_s1_frac         ),
      .fadd_s1_zero       (fadd_s1_zero         ),
      .fadd_s1_inf        (fadd_s1_inf          ),
      .fadd_s1_nan        (fadd_s1_nan          ),
      .ex2_d_s            (ex2_d_s              ),
      .ex2_d_exp          (ex2_d_exp            ),
      .ex2_d_frac         (ex2_d_frac           ),
      .ex2_d_inf          (ex2_d_inf            ),
      .ex2_d_nan          (ex2_d_nan            )
      );

   fpu3 fpu3 /* normalize, no register slice, just combination logic */
     (
      .ex2_d_s     (ex2_d_s          ),
      .ex2_d_exp   (ex2_d_exp        ),
      .ex2_d_frac  (ex2_d_frac       ),
      .ex2_d_inf   (ex2_d_inf        ),
      .ex2_d_nan   (ex2_d_nan        ),
      .f           (exd              )
      );

   parameter TIC1G        = 10;      // CPU CYCLE TIME
   parameter SDELAY       = 1;       // CLKÊÑ²½¤«¤é¾¯¤·ÂÔ¤Ä
   
   always #(TIC1G/2) ACLK = ~ACLK;

   task WAIT_CYCLE;
      input   [15:0]  wait_cycle;
      reg     [15:0]  timer;
      begin
        timer[15:0] = 16'h0000;
        while( timer[15:0] != wait_cycle[15:0] ) begin
          #(TIC1G*1);
          timer[15:0] = timer[15:0] + 16'h0001;
        end
      end
   endtask

   task CHECK_FPU;
      input   [31:0]  ex1in;
      input   [31:0]  ex2in;
      input   [31:0]  ex3in;
      input   [31:0]  exdin;
      begin
	ex1 = ex1in;
	ex2 = ex2in;
	ex3 = ex3in;
	#(SDELAY);      // ->stage2
	@(posedge ACLK); //
	#(SDELAY);      // ->stage3
	@(posedge ACLK); //
	#(SDELAY);      // ->stage4
        if (exd != exdin) begin
	  $display("[%t] ----- ERROR ex1=%h ex2=%h ex3=%h exd=%h should be %h -----",$time, ex1in, ex2in, ex3in, exd, exdin);
	  error = error +16'h1;
	end
      end
   endtask

   initial begin

     system_cycle = 16'h0000;
     error        = 16'h0000;
     ACLK = 1'b0;
     RSTN = 1'b0;
     $display("[%t] ----- Global Reset -----",$time);
     WAIT_CYCLE(16'h0004);
     RSTN = 1'b1;
     WAIT_CYCLE(16'h0004);
     
`include "tb_fpu.dat"

     if (error == 16'h0000)
       $display("======== OK ^^/========\n");
     else
       $display("======== NG ;_;========\n");
     $stop;
   end
endmodule
