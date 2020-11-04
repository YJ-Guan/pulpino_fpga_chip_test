///////////////////////////////////////////////////////////////////////////////
// Copyright(C) YJ-Guan. Open source License: MIT.
// ALL RIGHT RESERVED
// File name   : fpga_tb_top_sim.sv
// Author      : YJGuan               
// Date        : 2020-11-04
// Version     : 0.1
// Description : verify the function of the fpga implemented testbench in NCSim simulation
//  
// Modification History:
//   Date   |   Author   |   Version   |   Change Description
//==============================================================================
// 20-11-04 |  YJ-Guan   |     0.1     |  Original Version
////////////////////////////////////////////////////////////////////////////////

`include "tb_jtag_pkg.sv"
`include "config.sv"        // config file for pulpino in asic simulation

module fpga_tb_top_sim(
  input s_rst_n,
  input s_clk,
  input jtag_clk
);

  // +MEMLOAD= valid values are "SPI", "STANDALONE" "PRELOAD", "" (no load of L2)
  parameter  SPI            = "QUAD";    // valid values are "SINGLE", "QUAD"
  parameter  BAUDRATE       = 781250;    // 1562500
  parameter  CLK_USE_FLL    = 0;         // 0 or 1
  parameter  TEST           = "";        //valid values are "" (NONE), "DEBUG"
  parameter  USE_ZERO_RISCY = 0;
  parameter  RISCY_RV32F    = 0;
  parameter  ZERO_RV32M     = 1;
  parameter  ZERO_RV32E     = 0;


  //int           exit_status = `EXIT_ERROR; // modelsim exit code, will be overwritten when successful

  //string        memload;
  logic         s_clk   = 1'b0;
  logic         s_rst_n = 1'b0;

  logic         fetch_enable = 1'b0;

  logic [1:0]   padmode_spi_master; // SPI master Signals to drive pulp
  logic         spi_sck   = 1'b0;
  logic         spi_csn   = 1'b1;   // chip select
  logic [1:0]   spi_mode;           // CPOL (Clock polarity) + CPHA (Clock phase)   
  logic         spi_sdo0;
  logic         spi_sdo1;
  logic         spi_sdo2;
  logic         spi_sdo3;
  logic         spi_sdi0;
  logic         spi_sdi1;
  logic         spi_sdi2;
  logic         spi_sdi3;

  logic         uart_tx;              
  logic         uart_rx;
  logic         s_uart_dtr;
  logic         s_uart_rts;

  logic         scl_pad_i;
  logic         scl_pad_o;
  logic         scl_padoen_o;

  logic         sda_pad_i;
  logic         sda_pad_o;
  logic         sda_padoen_o;

  tri1          scl_io;
  tri1          sda_io;

  logic [31:0]  gpio_in = '0;
  logic [31:0]  gpio_dir;
  logic [31:0]  gpio_out;

  logic [31:0]  recv_data;

  logic         tck    ;         
  logic         trstn  ; 
  logic         tms    ; 
  logic         tdi    ; 
  logic         tdo    ; 
  logic         jtag_start;
  logic         jtag_done;
  assign tck = jtag_clk;

  jtag_com jtag_com_i 
  (
    .jtag_clk_i        ( jtag_clk   ),
    .tdo               ( tdo        ),
    .jtag_start        ( jtag_start ),
    .rst_n             ( rst_n      ),
    .trstn             ( trstn      ),
    .tms               ( tms        ),
    .tdi               ( tdi        ),  
    .jtag_done         ( jtag_done  )
  );
  

  pulpino_top
  #(
    .USE_ZERO_RISCY    ( USE_ZERO_RISCY ),
    .RISCY_RV32F       ( RISCY_RV32F    ),
    .ZERO_RV32M        ( ZERO_RV32M     ),
    .ZERO_RV32E        ( ZERO_RV32E     )
   )
  top_i
  (
    .clk               ( s_clk        ),
    .rst_n             ( s_rst_n      ),

    .clk_sel_i         ( 1'b0         ),
    .testmode_i        ( 1'b0         ),
    .fetch_enable_i    ( fetch_enable ),

    .spi_clk_i         ( spi_sck      ),        // spi slave port in pulp
    .spi_cs_i          ( spi_csn      ),
    .spi_mode_o        ( spi_mode     ),
    .spi_sdo0_o        ( spi_sdi0     ),
    .spi_sdo1_o        ( spi_sdi1     ),
    .spi_sdo2_o        ( spi_sdi2     ),
    .spi_sdo3_o        ( spi_sdi3     ),
    .spi_sdi0_i        ( spi_sdo0     ),
    .spi_sdi1_i        ( spi_sdo1     ),
    .spi_sdi2_i        ( spi_sdo2     ),
    .spi_sdi3_i        ( spi_sdo3     ),

    .spi_master_clk_o  ( spi_master.clk     ),
    .spi_master_csn0_o ( spi_master.csn     ),
    .spi_master_csn1_o (                    ),
    .spi_master_csn2_o (                    ),
    .spi_master_csn3_o (                    ),
    .spi_master_mode_o ( spi_master.padmode ),
    .spi_master_sdo0_o ( spi_master.sdo[0]  ),
    .spi_master_sdo1_o ( spi_master.sdo[1]  ),
    .spi_master_sdo2_o ( spi_master.sdo[2]  ),
    .spi_master_sdo3_o ( spi_master.sdo[3]  ),
    .spi_master_sdi0_i ( spi_master.sdi[0]  ),
    .spi_master_sdi1_i ( spi_master.sdi[1]  ),
    .spi_master_sdi2_i ( spi_master.sdi[2]  ),
    .spi_master_sdi3_i ( spi_master.sdi[3]  ),

    .scl_pad_i         ( scl_pad_i    ),
    .scl_pad_o         ( scl_pad_o    ),
    .scl_padoen_o      ( scl_padoen_o ),
    .sda_pad_i         ( sda_pad_i    ),
    .sda_pad_o         ( sda_pad_o    ),
    .sda_padoen_o      ( sda_padoen_o ),


    .uart_tx           ( uart_rx      ),
    .uart_rx           ( uart_tx      ),
    .uart_rts          ( s_uart_rts   ),    // not used in tb
    .uart_dtr          ( s_uart_dtr   ),    // not used in tb
    .uart_cts          ( 1'b0         ),
    .uart_dsr          ( 1'b0         ),

    .gpio_in           ( gpio_in      ),
    .gpio_out          ( gpio_out     ),
    .gpio_dir          ( gpio_dir     ),
    .gpio_padcfg       (              ),

    .tck_i             ( tck          ),
    .trstn_i           ( trstn        ),
    .tms_i             ( tms          ),
    .tdi_i             ( tdi          ),
    .tdo_o             ( tdo          )
  ); 

  always_ff @(negedge s_rst_n) begin
    if (s_rst == 1'b0) begin
      /* Configure JTAG and set boot address */
    
    end
  end


endmodule