///////////////////////////////////////////////////////////////////////////////
// Copyright(C) YJ-Guan. Open source License: MIT.
// ALL RIGHT RESERVED
// File name   : sim_tb.sv
// Author      : YJGuan               
// Date        : 2020-11-09
// Version     : 0.1
// Description : verify the function of the fpga implemented testbench in NCSim simulation
//  
// Modification History:
//   Date   |   Author   |   Version   |   Change Description
//==============================================================================
// 20-11-09 |  YJ-Guan   |     0.1     |  Original Version
////////////////////////////////////////////////////////////////////////////////

`define CLK_PERIOD       40.00ns      // 25 MHz
`define JTAG_PERIOD      100.00us     // 10 kHz
`define SPI_PERIOD      100.00ns     // 10 MHz

module sim_tb(
    
);

  timeunit      1ns;
  timeprecision 1ps;

    logic rst_n;
    logic s_clk; 
    logic jtag_clk;
    logic spi_clk ;

    fpga_tb_top_sim fpga_tb_top_sim_i
    (
        .rst_n      ( rst_n  ),
        .s_clk      ( s_clk    ),
        .jtag_clk   ( jtag_clk ),
        .spi_clk    ( spi_clk  )
    );

      initial
      begin 
        s_clk = 1'b0;               // 25 MHz
        forever s_clk = #(`CLK_PERIOD/2) ~s_clk;
      end

      initial
      begin 
        jtag_clk = 1'b0;               // 25 MHz
        forever jtag_clk = #(`JTAG_PERIOD/2) ~jtag_clk;
      end

      initial
      begin 
        spi_clk = 1'b0;               // 10 MHz
        forever spi_clk = #(`SPI_PERIOD/2) ~spi_clk;
      end

      initial 
      begin
          rst_n = 1'b0;
          # 500ns;
          rst_n = 1'b1;
          # 20ms  $stop();
      end

endmodule