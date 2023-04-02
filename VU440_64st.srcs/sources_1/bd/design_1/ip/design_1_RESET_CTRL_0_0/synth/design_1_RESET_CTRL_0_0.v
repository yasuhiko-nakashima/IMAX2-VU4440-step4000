// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:RESET_CTRL:1.0
// IP Revision: 1

(* X_CORE_INFO = "RESET_CTRL,Vivado 2018.3.1" *)
(* CHECK_LICENSE_TYPE = "design_1_RESET_CTRL_0_0,RESET_CTRL,{}" *)
(* CORE_GENERATION_INFO = "design_1_RESET_CTRL_0_0,RESET_CTRL,{x_ipProduct=Vivado 2018.3.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=RESET_CTRL,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=VERILOG}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_RESET_CTRL_0_0 (
  MAIN_CLK,
  MAIN_RESET_N,
  EXT_RESET,
  DCM_LOCKED,
  CPU_RESET_P,
  CPU_RESET_N,
  USER_RESET_P,
  USER_RESET_N,
  PERI_RESET_P,
  PERI_RESET_N
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME MAIN_CLK, FREQ_HZ 150000000, PHASE 0.000, CLK_DOMAIN design_1_clk_150m_buff_0_IBUF_OUT, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 MAIN_CLK CLK" *)
input wire MAIN_CLK;
input wire MAIN_RESET_N;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME EXT_RESET, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 EXT_RESET RST" *)
input wire EXT_RESET;
input wire DCM_LOCKED;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CPU_RESET_P, POLARITY ACTIVE_HIGH, TYPE PROCESSOR, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 CPU_RESET_P RST" *)
output wire CPU_RESET_P;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CPU_RESET_N, POLARITY ACTIVE_LOW, TYPE PROCESSOR, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 CPU_RESET_N RST" *)
output wire CPU_RESET_N;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME USER_RESET_P, POLARITY ACTIVE_HIGH, TYPE INTERCONNECT, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 USER_RESET_P RST" *)
output wire USER_RESET_P;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME USER_RESET_N, POLARITY ACTIVE_LOW, TYPE INTERCONNECT, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 USER_RESET_N RST" *)
output wire USER_RESET_N;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PERI_RESET_P, POLARITY ACTIVE_HIGH, TYPE PERIPHERAL, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 PERI_RESET_P RST" *)
output wire PERI_RESET_P;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PERI_RESET_N, POLARITY ACTIVE_LOW, TYPE PERIPHERAL, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 PERI_RESET_N RST" *)
output wire PERI_RESET_N;

  RESET_CTRL inst (
    .MAIN_CLK(MAIN_CLK),
    .MAIN_RESET_N(MAIN_RESET_N),
    .EXT_RESET(EXT_RESET),
    .DCM_LOCKED(DCM_LOCKED),
    .CPU_RESET_P(CPU_RESET_P),
    .CPU_RESET_N(CPU_RESET_N),
    .USER_RESET_P(USER_RESET_P),
    .USER_RESET_N(USER_RESET_N),
    .PERI_RESET_P(PERI_RESET_P),
    .PERI_RESET_N(PERI_RESET_N)
  );
endmodule
