/*------------------------------------------*/
/*  Test bench for emax6.v                  */
/*              Y.Nakashima 2017/9/20       */
/*------------------------------------------*/

`timescale 1ns/1ns

`include "emax6.v"
`include "fsm.v"
`include "unit.v"
`include "lmring.v"
`include "stage1.v"
`include "stage2.v"
`include "stage3.v"
`include "stage4.v"
`include "stage5.v"
`include "nbit_csa.v"
`include "nbit_ndepth_queue.v"
`include "nbit_register.v"
`include "bit24_booth_wallace.v"
`include "tb_axi_fifo.v"
`include "tb_axi_interconnect.v"

`define NCHIP 4
       
module tb_top;
   reg  [9:0] 		         system_cycle;
   reg  [15:0] 			 error;

   reg                           CLK;
   reg 			         RSTN;
   reg  [`AXI_S_DATA_BITS-1:0] 	 RDDATA;
   
   reg 				 axi_s_arvalid;
   wire 			 axi_s_arready;
   reg  [`AXI_ZCU_ADDR_BITS-1:0] axi_s_araddr ;
   reg  [`AXI_S_LENG_BITS-1:0] 	 axi_s_arlen  ;
   reg  [`AXI_S_SIZE_BITS-1:0] 	 axi_s_arsize ;
   wire 			 axi_s_rvalid ;
   reg 				 axi_s_rready ;
   wire 			 axi_s_rlast  ;
   wire [`AXI_S_DATA_BITS-1:0] 	 axi_s_rdata  ;
   wire [`AXI_S_RESP_BITS-1:0]	 axi_s_rresp  ;
   reg 				 axi_s_awvalid;
   wire 			 axi_s_awready;
   reg  [`AXI_ZCU_ADDR_BITS-1:0] axi_s_awaddr ;
   reg  [`AXI_S_LENG_BITS-1:0] 	 axi_s_awlen  ;
   reg  [`AXI_S_SIZE_BITS-1:0] 	 axi_s_awsize ;
   reg 				 axi_s_wvalid ;
   wire 			 axi_s_wready ;
   reg 			         axi_s_wlast  ;
   reg  [`AXI_S_DATA_BITS-1:0] 	 axi_s_wdata  ;
   reg  [`AXI_S_DATA_BYTES-1:0]  axi_s_wstrb  ;
   wire 			 axi_s_bvalid ;
   reg 				 axi_s_bready ;
   wire [`AXI_S_RESP_BITS-1:0]	 axi_s_bresp  ;

   wire 			 axi_arvalid[`NCHIP-1:0];
   wire 			 axi_arready[`NCHIP-1:0];
   wire [`AXI_ZCU_ADDR_BITS-1:0] axi_araddr [`NCHIP-1:0];
   wire [`AXI_S_LENG_BITS-1:0] 	 axi_arlen  [`NCHIP-1:0];
   wire [`AXI_S_SIZE_BITS-1:0] 	 axi_arsize [`NCHIP-1:0];
   wire 			 axi_rvalid [`NCHIP-1:0];
   wire 			 axi_rready [`NCHIP-1:0];
   wire 			 axi_rlast  [`NCHIP-1:0];
   wire [`AXI_S_DATA_BITS-1:0]   axi_rdata  [`NCHIP-1:0];
   wire [`AXI_S_RESP_BITS-1:0]	 axi_rresp  [`NCHIP-1:0];
   wire 			 axi_awvalid[`NCHIP-1:0];
   wire 			 axi_awready[`NCHIP-1:0];
   wire [`AXI_ZCU_ADDR_BITS-1:0] axi_awaddr [`NCHIP-1:0];
   wire [`AXI_S_LENG_BITS-1:0] 	 axi_awlen  [`NCHIP-1:0];
   wire [`AXI_S_SIZE_BITS-1:0] 	 axi_awsize [`NCHIP-1:0];
   wire 			 axi_wvalid [`NCHIP-1:0];
   wire 			 axi_wready [`NCHIP-1:0];
   wire 			 axi_wlast  [`NCHIP-1:0];
   wire [`AXI_S_DATA_BITS-1:0] 	 axi_wdata  [`NCHIP-1:0];
   wire [`AXI_S_DATA_BYTES-1:0]  axi_wstrb  [`NCHIP-1:0];
   wire 			 axi_bvalid [`NCHIP-1:0];
   wire 			 axi_bready [`NCHIP-1:0];
   wire [`AXI_S_RESP_BITS-1:0]	 axi_bresp  [`NCHIP-1:0];
   wire                          next_linkup[`NCHIP-1:0];

   wire 			 c2c_arvalid[`NCHIP-1:0];
   wire 			 c2c_arready[`NCHIP-1:0];
   wire [`AXI_ZCU_ADDR_BITS-1:0] c2c_araddr [`NCHIP-1:0];
   wire [`AXI_S_LENG_BITS-1:0] 	 c2c_arlen  [`NCHIP-1:0];
   wire [`AXI_S_SIZE_BITS-1:0] 	 c2c_arsize [`NCHIP-1:0];
   wire 			 c2c_rvalid [`NCHIP-1:0];
   wire 			 c2c_rready [`NCHIP-1:0];
   wire 			 c2c_rlast  [`NCHIP-1:0];
   wire [`AXI_S_DATA_BITS-1:0]   c2c_rdata  [`NCHIP-1:0];
   wire [`AXI_S_RESP_BITS-1:0]	 c2c_rresp  [`NCHIP-1:0];
   wire 			 c2c_awvalid[`NCHIP-1:0];
   wire 			 c2c_awready[`NCHIP-1:0];
   wire [`AXI_ZCU_ADDR_BITS-1:0] c2c_awaddr [`NCHIP-1:0];
   wire [`AXI_S_LENG_BITS-1:0] 	 c2c_awlen  [`NCHIP-1:0];
   wire [`AXI_S_SIZE_BITS-1:0] 	 c2c_awsize [`NCHIP-1:0];
   wire 			 c2c_wvalid [`NCHIP-1:0];
   wire 			 c2c_wready [`NCHIP-1:0];
   wire 			 c2c_wlast  [`NCHIP-1:0];
   wire [`AXI_S_DATA_BITS-1:0] 	 c2c_wdata  [`NCHIP-1:0];
   wire [`AXI_S_DATA_BYTES-1:0]  c2c_wstrb  [`NCHIP-1:0];
   wire 			 c2c_bvalid [`NCHIP-1:0];
   wire 			 c2c_bready [`NCHIP-1:0];
   wire [`AXI_S_RESP_BITS-1:0]	 c2c_bresp  [`NCHIP-1:0];

   genvar c_emax6;
   generate
     for (c_emax6=0; c_emax6<`NCHIP; c_emax6=c_emax6+1) begin: chip
       assign next_linkup[c_emax6] = (c_emax6 < `NCHIP-1) ? 1'b1 : 1'b0;
       if (c_emax6 == 0) begin
	 c2c c2c
	   (
	    .ACLK        (CLK),
	    .ARESETN     (RSTN),
	    .c2c_s_arvalid (axi_s_arvalid),
	    .c2c_s_arready (axi_s_arready),
	    .c2c_s_araddr  (axi_s_araddr ),
	    .c2c_s_arlen   (axi_s_arlen  ),
	    .c2c_s_arsize  (axi_s_arsize ),
	    .c2c_s_arburst (2'b00        ),
	    .c2c_s_arcache (4'b0000      ),
	    .c2c_s_arprot  (3'b000       ),
	    .c2c_s_arid    (16'h0000     ),
	    .c2c_s_rvalid  (axi_s_rvalid ),
	    .c2c_s_rready  (axi_s_rready ),
	    .c2c_s_rlast   (axi_s_rlast  ),
	    .c2c_s_rdata   (axi_s_rdata  ),
	    .c2c_s_rresp   (axi_s_rresp  ),
	    .c2c_s_rid     (             ),

	    .c2c_s_awvalid (axi_s_awvalid),
	    .c2c_s_awready (axi_s_awready),
	    .c2c_s_awaddr  (axi_s_awaddr ),
	    .c2c_s_awlen   (axi_s_awlen  ),
	    .c2c_s_awsize  (axi_s_awsize ),
	    .c2c_s_awburst (2'b00        ),
	    .c2c_s_awcache (4'b0000      ),
	    .c2c_s_awprot  (3'b000       ),
	    .c2c_s_awid    (16'h0000     ),
	    .c2c_s_wvalid  (axi_s_wvalid ),
	    .c2c_s_wready  (axi_s_wready ),
	    .c2c_s_wlast   (axi_s_wlast  ),
	    .c2c_s_wdata   (axi_s_wdata  ),
	    .c2c_s_wstrb   (axi_s_wstrb  ),
	    .c2c_s_bvalid  (axi_s_bvalid ),
	    .c2c_s_bready  (axi_s_bready ),
	    .c2c_s_bresp   (axi_s_bresp  ),
	    .c2c_s_bid     (             ),

	    .c2c_m_arvalid (c2c_arvalid[0]),
	    .c2c_m_arready (c2c_arready[0]),
	    .c2c_m_araddr  (c2c_araddr [0]),
	    .c2c_m_arlen   (c2c_arlen  [0]),
	    .c2c_m_arsize  (c2c_arsize [0]),
	    .c2c_m_arburst (             ),
	    .c2c_m_arcache (             ),
	    .c2c_m_arprot  (             ),
	    .c2c_m_arid    (             ),
	    .c2c_m_rvalid  (c2c_rvalid [0]),
	    .c2c_m_rready  (c2c_rready [0]),
	    .c2c_m_rlast   (c2c_rlast  [0]),
	    .c2c_m_rdata   (c2c_rdata  [0]),
	    .c2c_m_rresp   (c2c_rresp  [0]),
	    .c2c_m_rid     (16'h0000      ),

	    .c2c_m_awvalid (c2c_awvalid[0]),
	    .c2c_m_awready (c2c_awready[0]),
	    .c2c_m_awaddr  (c2c_awaddr [0]),
	    .c2c_m_awlen   (c2c_awlen  [0]),
	    .c2c_m_awsize  (c2c_awsize [0]),
	    .c2c_m_awburst (             ),
	    .c2c_m_awcache (             ),
	    .c2c_m_awprot  (             ),
	    .c2c_m_awid    (             ),
	    .c2c_m_wvalid  (c2c_wvalid [0]),
	    .c2c_m_wready  (c2c_wready [0]),
	    .c2c_m_wlast   (c2c_wlast  [0]),
	    .c2c_m_wdata   (c2c_wdata  [0]),
	    .c2c_m_wstrb   (c2c_wstrb  [0]),
	    .c2c_m_bvalid  (c2c_bvalid [0]),
	    .c2c_m_bready  (c2c_bready [0]),
	    .c2c_m_bresp   (c2c_bresp  [0]),
	    .c2c_m_bid     (16'h0000      )
	  );
       end
       else begin
	 c2c c2c
	   (
	    .ACLK        (CLK),
	    .ARESETN     (RSTN),
	    .c2c_s_arvalid (axi_arvalid[c_emax6-1]),
	    .c2c_s_arready (axi_arready[c_emax6-1]),
	    .c2c_s_araddr  (axi_araddr [c_emax6-1]),
	    .c2c_s_arlen   (axi_arlen  [c_emax6-1]),
	    .c2c_s_arsize  (axi_arsize [c_emax6-1]),
	    .c2c_s_arburst (2'b00        ),
	    .c2c_s_arcache (4'b0000      ),
	    .c2c_s_arprot  (3'b000       ),
	    .c2c_s_arid    (16'h0000     ),
	    .c2c_s_rvalid  (axi_rvalid [c_emax6-1]),
	    .c2c_s_rready  (axi_rready [c_emax6-1]),
	    .c2c_s_rlast   (axi_rlast  [c_emax6-1]),
	    .c2c_s_rdata   (axi_rdata  [c_emax6-1]),
	    .c2c_s_rresp   (axi_rresp  [c_emax6-1]),
	    .c2c_s_rid     (             ),

	    .c2c_s_awvalid (axi_awvalid[c_emax6-1]),
	    .c2c_s_awready (axi_awready[c_emax6-1]),
	    .c2c_s_awaddr  (axi_awaddr [c_emax6-1]),
	    .c2c_s_awlen   (axi_awlen  [c_emax6-1]),
	    .c2c_s_awsize  (axi_awsize [c_emax6-1]),
	    .c2c_s_awburst (2'b00        ),
	    .c2c_s_awcache (4'b0000      ),
	    .c2c_s_awprot  (3'b000       ),
	    .c2c_s_awid    (16'h0000     ),
	    .c2c_s_wvalid  (axi_wvalid [c_emax6-1]),
	    .c2c_s_wready  (axi_wready [c_emax6-1]),
	    .c2c_s_wlast   (axi_wlast  [c_emax6-1]),
	    .c2c_s_wdata   (axi_wdata  [c_emax6-1]),
	    .c2c_s_wstrb   (axi_wstrb  [c_emax6-1]),
	    .c2c_s_bvalid  (axi_bvalid [c_emax6-1]),
	    .c2c_s_bready  (axi_bready [c_emax6-1]),
	    .c2c_s_bresp   (axi_bresp  [c_emax6-1]),
	    .c2c_s_bid     (             ),

	    .c2c_m_arvalid (c2c_arvalid[c_emax6]),
	    .c2c_m_arready (c2c_arready[c_emax6]),
	    .c2c_m_araddr  (c2c_araddr [c_emax6]),
	    .c2c_m_arlen   (c2c_arlen  [c_emax6]),
	    .c2c_m_arsize  (c2c_arsize [c_emax6]),
	    .c2c_m_arburst (             ),
	    .c2c_m_arcache (             ),
	    .c2c_m_arprot  (             ),
	    .c2c_m_arid    (             ),
	    .c2c_m_rvalid  (c2c_rvalid [c_emax6]),
	    .c2c_m_rready  (c2c_rready [c_emax6]),
	    .c2c_m_rlast   (c2c_rlast  [c_emax6]),
	    .c2c_m_rdata   (c2c_rdata  [c_emax6]),
	    .c2c_m_rresp   (c2c_rresp  [c_emax6]),
	    .c2c_m_rid     (16'h0000     ),

	    .c2c_m_awvalid (c2c_awvalid[c_emax6]),
	    .c2c_m_awready (c2c_awready[c_emax6]),
	    .c2c_m_awaddr  (c2c_awaddr [c_emax6]),
	    .c2c_m_awlen   (c2c_awlen  [c_emax6]),
	    .c2c_m_awsize  (c2c_awsize [c_emax6]),
	    .c2c_m_awburst (             ),
	    .c2c_m_awcache (             ),
	    .c2c_m_awprot  (             ),
	    .c2c_m_awid    (             ),
	    .c2c_m_wvalid  (c2c_wvalid [c_emax6]),
	    .c2c_m_wready  (c2c_wready [c_emax6]),
	    .c2c_m_wlast   (c2c_wlast  [c_emax6]),
	    .c2c_m_wdata   (c2c_wdata  [c_emax6]),
	    .c2c_m_wstrb   (c2c_wstrb  [c_emax6]),
	    .c2c_m_bvalid  (c2c_bvalid [c_emax6]),
	    .c2c_m_bready  (c2c_bready [c_emax6]),
	    .c2c_m_bresp   (c2c_bresp  [c_emax6]),
	    .c2c_m_bid     (16'h0000     )
	  );
       end
       emax6 emax6
	   (
	    .ACLK        (CLK),
	    .ARESETN     (RSTN),
	    .axi_s_arvalid (c2c_arvalid[c_emax6]),
	    .axi_s_arready (c2c_arready[c_emax6]),
	    .axi_s_araddr  (c2c_araddr [c_emax6]),
	    .axi_s_arlen   (c2c_arlen  [c_emax6]),
	    .axi_s_arsize  (c2c_arsize [c_emax6]),
	    .axi_s_arburst (2'b00        ),
	    .axi_s_arcache (4'b0000      ),
	    .axi_s_arprot  (3'b000       ),
	    .axi_s_arid    (16'h0000     ),
	    .axi_s_rvalid  (c2c_rvalid [c_emax6]),
	    .axi_s_rready  (c2c_rready [c_emax6]),
	    .axi_s_rlast   (c2c_rlast  [c_emax6]),
	    .axi_s_rdata   (c2c_rdata  [c_emax6]),
	    .axi_s_rresp   (c2c_rresp  [c_emax6]),
	    .axi_s_rid     (             ),

	    .axi_s_awvalid (c2c_awvalid[c_emax6]),
	    .axi_s_awready (c2c_awready[c_emax6]),
	    .axi_s_awaddr  (c2c_awaddr [c_emax6]),
	    .axi_s_awlen   (c2c_awlen  [c_emax6]),
	    .axi_s_awsize  (c2c_awsize [c_emax6]),
	    .axi_s_awburst (2'b00        ),
	    .axi_s_awcache (4'b0000      ),
	    .axi_s_awprot  (3'b000       ),
	    .axi_s_awid    (16'h0000     ),
	    .axi_s_wvalid  (c2c_wvalid [c_emax6]),
	    .axi_s_wready  (c2c_wready [c_emax6]),
	    .axi_s_wlast   (c2c_wlast  [c_emax6]),
	    .axi_s_wdata   (c2c_wdata  [c_emax6]),
	    .axi_s_wstrb   (c2c_wstrb  [c_emax6]),
	    .axi_s_bvalid  (c2c_bvalid [c_emax6]),
	    .axi_s_bready  (c2c_bready [c_emax6]),
	    .axi_s_bresp   (c2c_bresp  [c_emax6]),
	    .axi_s_bid     (             ),

	    .axi_m_arvalid (axi_arvalid[c_emax6]),
	    .axi_m_arready (axi_arready[c_emax6]),
	    .axi_m_araddr  (axi_araddr [c_emax6]),
	    .axi_m_arlen   (axi_arlen  [c_emax6]),
	    .axi_m_arsize  (axi_arsize [c_emax6]),
	    .axi_m_arburst (             ),
	    .axi_m_arcache (             ),
	    .axi_m_arprot  (             ),
	    .axi_m_arid    (             ),
	    .axi_m_rvalid  (axi_rvalid [c_emax6]),
	    .axi_m_rready  (axi_rready [c_emax6]),
	    .axi_m_rlast   (axi_rlast  [c_emax6]),
	    .axi_m_rdata   (axi_rdata  [c_emax6]),
	    .axi_m_rresp   (axi_rresp  [c_emax6]),
	    .axi_m_rid     (16'h0000     ),

	    .axi_m_awvalid (axi_awvalid[c_emax6]),
	    .axi_m_awready (axi_awready[c_emax6]),
	    .axi_m_awaddr  (axi_awaddr [c_emax6]),
	    .axi_m_awlen   (axi_awlen  [c_emax6]),
	    .axi_m_awsize  (axi_awsize [c_emax6]),
	    .axi_m_awburst (             ),
	    .axi_m_awcache (             ),
	    .axi_m_awprot  (             ),
	    .axi_m_awid    (             ),
	    .axi_m_wvalid  (axi_wvalid [c_emax6]),
	    .axi_m_wready  (axi_wready [c_emax6]),
	    .axi_m_wlast   (axi_wlast  [c_emax6]),
	    .axi_m_wdata   (axi_wdata  [c_emax6]),
	    .axi_m_wstrb   (axi_wstrb  [c_emax6]),
	    .axi_m_bvalid  (axi_bvalid [c_emax6]),
	    .axi_m_bready  (axi_bready [c_emax6]),
	    .axi_m_bresp   (axi_bresp  [c_emax6]),
	    .axi_m_bid     (16'h0000     ),
	    .next_linkup   (next_linkup[c_emax6])
       );
     end
   endgenerate

   parameter TIC1G        = 10;      // CPU CYCLE TIME
   parameter SDELAY       = 1;       // CLK変化から少し待つ
   
   always #(TIC1G/2) CLK = ~CLK;

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

   // READY=1,VALID=1が揃った時のみ送信成立
   // Masterは事前にREADYを検査してはいけない.送信したい時にVALID=1
   //  一旦VALID=1にしたら，READYが1になるまでVALID=0にできない
   // SlaveはREADYにする前にVALIDを待つ可能性がある.READY=1にしたら必ず受信
   //  READYはいつでも0にできる
   
   task HOST_PIO_W;
      input [`AXI_S_ADDR_BITS-1:0] addr;
      input [`AXI_S_DATA_BYTES-1:0] msk;
      input [`AXI_S_DATA_BITS-1:0] data;
      begin
	@(posedge CLK);
	#(SDELAY);
	axi_s_awaddr  = {`AXI_ZCU_ADDR_HIGH,addr};
	axi_s_awlen   = 1'b0;
	axi_s_awsize  = 3'b101;
	axi_s_awvalid = 1'b1;
        wait (axi_s_awready)
	@(posedge CLK);
	#(SDELAY);
	axi_s_awvalid = 1'b0;
	axi_s_wstrb   = msk;
	axi_s_wdata   = data;
	axi_s_wvalid  = 1'b1;
	axi_s_wlast   = 1'b1;
	axi_s_bready  = 1'b1;
        wait (axi_s_wready)
	@(posedge CLK);
	#(SDELAY);
	axi_s_wvalid  = 1'b0;
	axi_s_wlast   = 1'b0;
        wait (axi_s_bvalid)
	@(posedge CLK);
	#(SDELAY);
	axi_s_bready  = 1'b0;
      end
   endtask

   task HOST_PIO_R;
      input [`AXI_S_ADDR_BITS-1:0] addr;
      begin
	@(posedge CLK);
	#(SDELAY);
	axi_s_araddr  = {`AXI_ZCU_ADDR_HIGH,addr};
	axi_s_arlen   = 1'b0;
	axi_s_arsize  = 3'b101;
	axi_s_arvalid = 1'b1;
        wait (axi_s_arready)
	@(posedge CLK);
	#(SDELAY);
	axi_s_arvalid = 1'b0;
	axi_s_rready = 1'b1;
        wait (axi_s_rvalid)
	RDDATA = axi_s_rdata;
	@(posedge CLK);
	#(SDELAY);
	axi_s_rready = 1'b0;
   // axi_busyが4サイクル周期になるとcmd_EXECに遷移できないのでずらすための追加サイクル
	@(posedge CLK);
	#(SDELAY);
      end
   endtask
   
   task HOST_DMA_AW;
      input [`AXI_S_ADDR_BITS-1:0] addr;
      input [`AXI_S_LENG_BITS-1:0] len;
      begin
	@(posedge CLK);
	#(SDELAY);
	axi_s_awaddr  = {`AXI_ZCU_ADDR_HIGH,addr};
	axi_s_awlen   = len;
	axi_s_awsize  = 3'b101;
	axi_s_awvalid = 1'b1;
	axi_s_bready  = 1'b1;
        wait (axi_s_awready)
	@(posedge CLK);
	#(SDELAY);
	axi_s_awvalid = 1'b0;
      end
   endtask

   task HOST_DMA_DW;
      input last;
      input [`AXI_S_DATA_BYTES-1:0] msk;
      input [`AXI_S_DATA_BITS-1:0] data;
      begin
	@(posedge CLK);
	#(SDELAY);
	axi_s_wstrb   = msk;
	axi_s_wdata   = data;
	axi_s_wvalid  = 1'b1;
	axi_s_wlast   = last;
        wait (axi_s_wready)
	@(posedge CLK);
	#(SDELAY);
	axi_s_wvalid  = 1'b0;
	axi_s_wlast   = 1'b0;
        if (last) begin
	  wait (axi_s_bvalid)
	  @(posedge CLK);
	  #(SDELAY);
	  axi_s_bready  = 1'b0;
	end
      end
   endtask

   task HOST_DMA_AR;
      input [`AXI_S_ADDR_BITS-1:0] addr;
      input [`AXI_S_LENG_BITS-1:0] len;
      begin
	@(posedge CLK);
	#(SDELAY);
	axi_s_araddr  = {`AXI_ZCU_ADDR_HIGH,addr};
	axi_s_arlen   = len;
	axi_s_arsize  = 3'b101;
	axi_s_arvalid = 1'b1;
        wait (axi_s_arready)
	@(posedge CLK);
	#(SDELAY);
	axi_s_arvalid = 1'b0;
      end
   endtask
   
   task HOST_DMA_DR;
      input [`AXI_S_ADDR_BITS-1:0] addr;
      begin
	@(posedge CLK);
	#(SDELAY);
	axi_s_rready = 1'b1;
        wait (axi_s_rvalid)
	RDDATA = axi_s_rdata;
	@(posedge CLK);
	#(SDELAY);
	axi_s_rready = 1'b0;
   // axi_busyが4サイクル周期になるとcmd_EXECに遷移できないのでずらすための追加サイクル
      end
   endtask
   
   initial begin

     system_cycle = 16'h0000;
     error        = 16'h0000;
     CLK = 1'b0;
     RSTN = 1'b0;
     $display("[%t] ----- Global Reset -----",$time);
     WAIT_CYCLE(16'h0004);
     RSTN = 1'b1;
     WAIT_CYCLE(16'h0004);
     axi_s_arvalid = 1'b0;
     axi_s_rready  = 1'b0;
     axi_s_awvalid = 1'b0;
     axi_s_wvalid  = 1'b0;
     axi_s_wlast   = 1'b0;
     axi_s_bready  = 1'b0;
     
`include "tb_top.dat"

     if (error == 16'h0000)
       $display("======== OK ^^/========\n");
     else
       $display("======== NG ;_;========\n");
     $stop;
   end
endmodule

module c2c
(
  input  wire                         ACLK,
  input  wire                         ARESETN,
  input  wire                         c2c_s_arvalid,
  output wire                         c2c_s_arready,
  input  wire [`AXI_ZCU_ADDR_BITS-1:0] c2c_s_araddr,
  input  wire [`AXI_S_LENG_BITS-1:0]  c2c_s_arlen,
  input  wire [`AXI_S_SIZE_BITS-1:0]  c2c_s_arsize,
  input  wire [`AXI_S_BURST_BITS-1:0] c2c_s_arburst,
  input  wire [`AXI_S_CACHE_BITS-1:0] c2c_s_arcache,
  input  wire [`AXI_S_PROT_BITS-1:0]  c2c_s_arprot,
  input  wire [`AXI_S_ID_BITS-1:0]    c2c_s_arid,
  output wire                         c2c_s_rvalid,
  input  wire                         c2c_s_rready,
  output wire                         c2c_s_rlast,
  output wire [`AXI_S_DATA_BITS-1:0]  c2c_s_rdata,
  output wire [`AXI_S_RESP_BITS-1:0]  c2c_s_rresp,
  output wire [`AXI_S_ID_BITS-1:0]    c2c_s_rid,
  input  wire                         c2c_s_awvalid,
  output wire                         c2c_s_awready,
  input  wire [`AXI_ZCU_ADDR_BITS-1:0] c2c_s_awaddr,
  input  wire [`AXI_S_LENG_BITS-1:0]  c2c_s_awlen,
  input  wire [`AXI_S_SIZE_BITS-1:0]  c2c_s_awsize,
  input  wire [`AXI_S_BURST_BITS-1:0] c2c_s_awburst,
  input  wire [`AXI_S_CACHE_BITS-1:0] c2c_s_awcache,
  input  wire [`AXI_S_PROT_BITS-1:0]  c2c_s_awprot,
  input  wire [`AXI_S_ID_BITS-1:0]    c2c_s_awid,
  input  wire                         c2c_s_wvalid,
  output wire                         c2c_s_wready,
  input  wire                         c2c_s_wlast,
  input  wire [`AXI_S_DATA_BITS-1:0]  c2c_s_wdata,
  input  wire [`AXI_S_DATA_BYTES-1:0] c2c_s_wstrb,
  output wire                         c2c_s_bvalid,
  input  wire                         c2c_s_bready,
  output wire [`AXI_S_RESP_BITS-1:0]  c2c_s_bresp,
  output wire [`AXI_S_ID_BITS-1:0]    c2c_s_bid,

  output wire                         c2c_m_arvalid,
  input  wire                         c2c_m_arready,
  output wire [`AXI_ZCU_ADDR_BITS-1:0] c2c_m_araddr,
  output wire [`AXI_S_LENG_BITS-1:0]  c2c_m_arlen,
  output wire [`AXI_S_SIZE_BITS-1:0]  c2c_m_arsize,
  output wire [`AXI_S_BURST_BITS-1:0] c2c_m_arburst,
  output wire [`AXI_S_CACHE_BITS-1:0] c2c_m_arcache,
  output wire [`AXI_S_PROT_BITS-1:0]  c2c_m_arprot,
  output wire [`AXI_S_ID_BITS-1:0]    c2c_m_arid,
  input  wire                         c2c_m_rvalid,
  output wire                         c2c_m_rready,
  input  wire                         c2c_m_rlast,
  input  wire [`AXI_S_DATA_BITS-1:0]  c2c_m_rdata,
  input  wire [`AXI_S_RESP_BITS-1:0]  c2c_m_rresp,
  input  wire [`AXI_S_ID_BITS-1:0]    c2c_m_rid,
  output wire                         c2c_m_awvalid,
  input  wire                         c2c_m_awready,
  output wire [`AXI_ZCU_ADDR_BITS-1:0] c2c_m_awaddr,
  output wire [`AXI_S_LENG_BITS-1:0]  c2c_m_awlen,
  output wire [`AXI_S_SIZE_BITS-1:0]  c2c_m_awsize,
  output wire [`AXI_S_BURST_BITS-1:0] c2c_m_awburst,
  output wire [`AXI_S_CACHE_BITS-1:0] c2c_m_awcache,
  output wire [`AXI_S_PROT_BITS-1:0]  c2c_m_awprot,
  output wire [`AXI_S_ID_BITS-1:0]    c2c_m_awid,
  output wire                         c2c_m_wvalid,
  input  wire                         c2c_m_wready,
  output wire                         c2c_m_wlast,
  output wire [`AXI_S_DATA_BITS-1:0]  c2c_m_wdata,
  output wire [`AXI_S_DATA_BYTES-1:0] c2c_m_wstrb,
  input  wire                         c2c_m_bvalid,
  output wire                         c2c_m_bready,
  input  wire [`AXI_S_RESP_BITS-1:0]  c2c_m_bresp,
  input  wire [`AXI_S_ID_BITS-1:0]    c2c_m_bid
);

   wire   ARESET;
   assign ARESET = ~ARESETN;
   
//`define C2C_PASS_THROUGH
//`define C2C_AXI_FIFO
`define C2C_AXI_INTERCONNECT

`ifdef C2C_PASS_THROUGH
   assign     c2c_m_arvalid = c2c_s_arvalid;
   assign     c2c_s_arready = c2c_m_arready;
   assign     c2c_m_araddr  = c2c_s_araddr;
   assign     c2c_m_arlen   = c2c_s_arlen;
   assign     c2c_m_arsize  = c2c_s_arsize;
   assign     c2c_m_arburst = c2c_s_arburst;
   assign     c2c_m_arcache = c2c_s_arcache;
   assign     c2c_m_arprot  = c2c_s_arprot;
   assign     c2c_m_arid    = c2c_s_arid;
   assign     c2c_s_rvalid  = c2c_m_rvalid;
   assign     c2c_m_rready  = c2c_s_rready;
   assign     c2c_s_rlast   = c2c_m_rlast;
   assign     c2c_s_rdata   = c2c_m_rdata;
   assign     c2c_s_rresp   = c2c_m_rresp;
   assign     c2c_s_rid     = c2c_m_rid;
   assign     c2c_m_awvalid = c2c_s_awvalid;
   assign     c2c_s_awready = c2c_m_awready;
   assign     c2c_m_awaddr  = c2c_s_awaddr;
   assign     c2c_m_awlen   = c2c_s_awlen;
   assign     c2c_m_awsize  = c2c_s_awsize;
   assign     c2c_m_awburst = c2c_s_awburst;
   assign     c2c_m_awcache = c2c_s_awcache;
   assign     c2c_m_awprot  = c2c_s_awprot;
   assign     c2c_m_awid    = c2c_s_awid;
   assign     c2c_m_wvalid  = c2c_s_wvalid;
   assign     c2c_s_wready  = c2c_m_wready;
   assign     c2c_m_wlast   = c2c_s_wlast;
   assign     c2c_m_wdata   = c2c_s_wdata;
   assign     c2c_m_wstrb   = c2c_s_wstrb;
   assign     c2c_s_bvalid  = c2c_m_bvalid;
   assign     c2c_m_bready  = c2c_s_bready;
   assign     c2c_s_bresp   = c2c_m_bresp;
   assign     c2c_s_bid     = c2c_m_bid;
`endif
`ifdef  C2C_AXI_FIFO
   axi_fifo #(
    .DATA_WIDTH(`AXI_S_DATA_BITS),
    .ADDR_WIDTH(`AXI_ZCU_ADDR_BITS),
    .STRB_WIDTH(`AXI_S_DATA_BYTES),
    .ID_WIDTH(`AXI_S_ID_BITS),
    .AWUSER_ENABLE(0),
    .AWUSER_WIDTH (1),
    .WUSER_ENABLE (0),
    .WUSER_WIDTH  (1),
    .BUSER_ENABLE (0),
    .BUSER_WIDTH  (1),
    .ARUSER_ENABLE(0),
    .ARUSER_WIDTH (1),
    .RUSER_ENABLE (0),
    .RUSER_WIDTH  (1),
    .WRITE_FIFO_DEPTH(2),//2<=DEPTH
    .WRITE_FIFO_DELAY(1),//0:AW*のみPASS
    .READ_FIFO_DEPTH (2),//2<=DEPTH
    .READ_FIFO_DELAY (1) //0:AR*のみPASS
    )
   axi_fifo (
 	     .clk            (ACLK),
 	     .rst            (ARESET),
 	     .s_axi_awid     (c2c_s_awid),
 	     .s_axi_awaddr   (c2c_s_awaddr),
 	     .s_axi_awlen    (c2c_s_awlen),
 	     .s_axi_awsize   (c2c_s_awsize),
 	     .s_axi_awburst  (c2c_s_awburst),
 	     .s_axi_awlock   (1'b0),
 	     .s_axi_awcache  (c2c_s_awcache),
 	     .s_axi_awprot   (c2c_s_awprot),
 	     .s_axi_awqos    (4'b0000),
 	     .s_axi_awregion (4'b0000),
 	     .s_axi_awuser   (1'b0),
 	     .s_axi_awvalid  (c2c_s_awvalid),
 	     .s_axi_awready  (c2c_s_awready),
 	     .s_axi_wdata    (c2c_s_wdata),
 	     .s_axi_wstrb    (c2c_s_wstrb),
 	     .s_axi_wlast    (c2c_s_wlast),
 	     .s_axi_wuser    (1'b0),
 	     .s_axi_wvalid   (c2c_s_wvalid),
 	     .s_axi_wready   (c2c_s_wready),
 	     .s_axi_bid      (c2c_s_bid),
 	     .s_axi_bresp    (c2c_s_bresp),
 	     .s_axi_buser    (),
 	     .s_axi_bvalid   (c2c_s_bvalid),
 	     .s_axi_bready   (c2c_s_bready),
 	     .s_axi_arid     (c2c_s_arid),
 	     .s_axi_araddr   (c2c_s_araddr),
 	     .s_axi_arlen    (c2c_s_arlen),
 	     .s_axi_arsize   (c2c_s_arsize),
 	     .s_axi_arburst  (c2c_s_arburst),
 	     .s_axi_arlock   (1'b0),
 	     .s_axi_arcache  (c2c_s_arcache),
 	     .s_axi_arprot   (c2c_s_arprot),
 	     .s_axi_arqos    (4'b0000),
 	     .s_axi_arregion (4'b0000),
 	     .s_axi_aruser   (1'b0),
 	     .s_axi_arvalid  (c2c_s_arvalid),
 	     .s_axi_arready  (c2c_s_arready),
 	     .s_axi_rid      (c2c_s_rid),
 	     .s_axi_rdata    (c2c_s_rdata),
 	     .s_axi_rresp    (c2c_s_rresp),
 	     .s_axi_rlast    (c2c_s_rlast),
 	     .s_axi_ruser    (),
 	     .s_axi_rvalid   (c2c_s_rvalid),
 	     .s_axi_rready   (c2c_s_rready),

 	     .m_axi_awid     (c2c_m_awid),
 	     .m_axi_awaddr   (c2c_m_awaddr),
 	     .m_axi_awlen    (c2c_m_awlen),
 	     .m_axi_awsize   (c2c_m_awsize),
 	     .m_axi_awburst  (c2c_m_awburst),
 	     .m_axi_awlock   (),
 	     .m_axi_awcache  (c2c_m_awcache),
 	     .m_axi_awprot   (c2c_m_awprot),
 	     .m_axi_awqos    (),
 	     .m_axi_awregion (),
 	     .m_axi_awuser   (),
 	     .m_axi_awvalid  (c2c_m_awvalid),
 	     .m_axi_awready  (c2c_m_awready),
 	     .m_axi_wdata    (c2c_m_wdata),
 	     .m_axi_wstrb    (c2c_m_wstrb),
 	     .m_axi_wlast    (c2c_m_wlast),
 	     .m_axi_wuser    (),
 	     .m_axi_wvalid   (c2c_m_wvalid),
 	     .m_axi_wready   (c2c_m_wready),
 	     .m_axi_bid      (c2c_m_bid),
 	     .m_axi_bresp    (c2c_m_bresp),
 	     .m_axi_buser    (1'b0),
 	     .m_axi_bvalid   (c2c_m_bvalid),
 	     .m_axi_bready   (c2c_m_bready),
 	     .m_axi_arid     (c2c_m_arid),
 	     .m_axi_araddr   (c2c_m_araddr),
 	     .m_axi_arlen    (c2c_m_arlen),
 	     .m_axi_arsize   (c2c_m_arsize),
 	     .m_axi_arburst  (c2c_m_arburst),
 	     .m_axi_arlock   (),
 	     .m_axi_arcache  (c2c_m_arcache),
 	     .m_axi_arprot   (c2c_m_arprot),
 	     .m_axi_arqos    (),
 	     .m_axi_arregion (),
 	     .m_axi_aruser   (),
 	     .m_axi_arvalid  (c2c_m_arvalid),
 	     .m_axi_arready  (c2c_m_arready),
 	     .m_axi_rid      (c2c_m_rid),
 	     .m_axi_rdata    (c2c_m_rdata),
 	     .m_axi_rresp    (c2c_m_rresp),
 	     .m_axi_rlast    (c2c_m_rlast),
 	     .m_axi_ruser    (1'b0),
 	     .m_axi_rvalid   (c2c_m_rvalid),
 	     .m_axi_rready   (c2c_m_rready)
);
`endif
`ifdef  C2C_AXI_INTERCONNECT
   axi_interconnect #(
    .S_COUNT (1),
    .M_COUNT (1),
    .DATA_WIDTH(`AXI_S_DATA_BITS),
    .ADDR_WIDTH(`AXI_ZCU_ADDR_BITS),
    .STRB_WIDTH(`AXI_S_DATA_BYTES),
    .ID_WIDTH  (`AXI_S_ID_BITS),
    .AWUSER_ENABLE  (0),
    .AWUSER_WIDTH   (1),
    .WUSER_ENABLE   (0),
    .WUSER_WIDTH    (1),
    .BUSER_ENABLE   (0),
    .BUSER_WIDTH    (1),
    .ARUSER_ENABLE  (0),
    .ARUSER_WIDTH   (1),
    .RUSER_ENABLE   (0),
    .RUSER_WIDTH    (1),
    .FORWARD_ID     (0),
    .M_REGIONS      (1),
    .M_BASE_ADDR    (40'h0400000000),
    .M_ADDR_WIDTH   (32'd32),
    .M_CONNECT_READ (1'b1),
    .M_CONNECT_WRITE(1'b1),
    .M_SECURE       (1'b0)
    )
   axi_interconnect (
 	     .clk            (ACLK),
 	     .rst            (ARESET),
 	     .s_axi_awid     (c2c_s_awid),
 	     .s_axi_awaddr   (c2c_s_awaddr),
 	     .s_axi_awlen    (c2c_s_awlen),
 	     .s_axi_awsize   (c2c_s_awsize),
 	     .s_axi_awburst  (c2c_s_awburst),
 	     .s_axi_awlock   (1'b0),
 	     .s_axi_awcache  (c2c_s_awcache),
 	     .s_axi_awprot   (c2c_s_awprot),
 	     .s_axi_awqos    (4'b0000),
 	     .s_axi_awuser   (1'b0),
 	     .s_axi_awvalid  (c2c_s_awvalid),
 	     .s_axi_awready  (c2c_s_awready),
 	     .s_axi_wdata    (c2c_s_wdata),
 	     .s_axi_wstrb    (c2c_s_wstrb),
 	     .s_axi_wlast    (c2c_s_wlast),
 	     .s_axi_wuser    (1'b0),
 	     .s_axi_wvalid   (c2c_s_wvalid),
 	     .s_axi_wready   (c2c_s_wready),
 	     .s_axi_bid      (c2c_s_bid),
 	     .s_axi_bresp    (c2c_s_bresp),
 	     .s_axi_buser    (),
 	     .s_axi_bvalid   (c2c_s_bvalid),
 	     .s_axi_bready   (c2c_s_bready),
 	     .s_axi_arid     (c2c_s_arid),
 	     .s_axi_araddr   (c2c_s_araddr),
 	     .s_axi_arlen    (c2c_s_arlen),
 	     .s_axi_arsize   (c2c_s_arsize),
 	     .s_axi_arburst  (c2c_s_arburst),
 	     .s_axi_arlock   (1'b0),
 	     .s_axi_arcache  (c2c_s_arcache),
 	     .s_axi_arprot   (c2c_s_arprot),
 	     .s_axi_arqos    (4'b0000),
 	     .s_axi_aruser   (1'b0),
 	     .s_axi_arvalid  (c2c_s_arvalid),
 	     .s_axi_arready  (c2c_s_arready),
 	     .s_axi_rid      (c2c_s_rid),
 	     .s_axi_rdata    (c2c_s_rdata),
 	     .s_axi_rresp    (c2c_s_rresp),
 	     .s_axi_rlast    (c2c_s_rlast),
 	     .s_axi_ruser    (),
 	     .s_axi_rvalid   (c2c_s_rvalid),
 	     .s_axi_rready   (c2c_s_rready),

 	     .m_axi_awid     (c2c_m_awid),
 	     .m_axi_awaddr   (c2c_m_awaddr),
 	     .m_axi_awlen    (c2c_m_awlen),
 	     .m_axi_awsize   (c2c_m_awsize),
 	     .m_axi_awburst  (c2c_m_awburst),
 	     .m_axi_awlock   (),
 	     .m_axi_awcache  (c2c_m_awcache),
 	     .m_axi_awprot   (c2c_m_awprot),
 	     .m_axi_awqos    (),
 	     .m_axi_awregion (),
 	     .m_axi_awuser   (),
 	     .m_axi_awvalid  (c2c_m_awvalid),
 	     .m_axi_awready  (c2c_m_awready),
 	     .m_axi_wdata    (c2c_m_wdata),
 	     .m_axi_wstrb    (c2c_m_wstrb),
 	     .m_axi_wlast    (c2c_m_wlast),
 	     .m_axi_wuser    (),
 	     .m_axi_wvalid   (c2c_m_wvalid),
 	     .m_axi_wready   (c2c_m_wready),
 	     .m_axi_bid      (c2c_m_bid),
 	     .m_axi_bresp    (c2c_m_bresp),
 	     .m_axi_buser    (1'b0),
 	     .m_axi_bvalid   (c2c_m_bvalid),
 	     .m_axi_bready   (c2c_m_bready),
 	     .m_axi_arid     (c2c_m_arid),
 	     .m_axi_araddr   (c2c_m_araddr),
 	     .m_axi_arlen    (c2c_m_arlen),
 	     .m_axi_arsize   (c2c_m_arsize),
 	     .m_axi_arburst  (c2c_m_arburst),
 	     .m_axi_arlock   (),
 	     .m_axi_arcache  (c2c_m_arcache),
 	     .m_axi_arprot   (c2c_m_arprot),
 	     .m_axi_arqos    (),
 	     .m_axi_arregion (),
 	     .m_axi_aruser   (),
 	     .m_axi_arvalid  (c2c_m_arvalid),
 	     .m_axi_arready  (c2c_m_arready),
 	     .m_axi_rid      (c2c_m_rid),
 	     .m_axi_rdata    (c2c_m_rdata),
 	     .m_axi_rresp    (c2c_m_rresp),
 	     .m_axi_rlast    (c2c_m_rlast),
 	     .m_axi_ruser    (1'b0),
 	     .m_axi_rvalid   (c2c_m_rvalid),
 	     .m_axi_rready   (c2c_m_rready)
);
`endif
endmodule
