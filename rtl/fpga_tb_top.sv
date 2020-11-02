module fpga_top(
  clk,
  rst_n,

  fetch_enable_i,

  spi_clk_i,
  spi_cs_i,
  spi_mode_o,
  spi_sdo0_o,
  spi_sdo1_o,
  spi_sdo2_o,
  spi_sdo3_o,
  spi_sdi0_i,
  spi_sdi1_i,
  spi_sdi2_i,
  spi_sdi3_i,

  spi_master_clk_o,
  spi_master_csn0_o,
  spi_master_csn1_o,
  spi_master_csn2_o,
  spi_master_csn3_o,
  spi_master_mode_o,
  spi_master_sdo0_o,
  spi_master_sdo1_o,
  spi_master_sdo2_o,
  spi_master_sdo3_o,
  spi_master_sdi0_i,
  spi_master_sdi1_i,
  spi_master_sdi2_i,
  spi_master_sdi3_i,

  uart_tx,
  uart_rx,
  uart_rts,
  uart_dtr,
  uart_cts,
  uart_dsr,

  scl_i,
  scl_o,
  scl_oen_o,
  sda_i,
  sda_o,
  sda_oen_o,

  gpio_in,
  gpio_out,
  gpio_dir,

  tck_i,
  trstn_i,
  tms_i,
  tdi_i,
  tdo_o
);

  output         clk;
  output         rst_n;

  output         fetch_enable_i;

  output       spi_clk_i;
  output       spi_cs_i;
  input  [1:0] spi_mode_o;
  input        spi_sdo0_o;
  input        spi_sdo1_o;
  input        spi_sdo2_o;
  input        spi_sdo3_o;
  output       spi_sdi0_i;
  output       spi_sdi1_i;
  output       spi_sdi2_i;
  output       spi_sdi3_i;

  input        spi_master_clk_o;
  input        spi_master_csn0_o;
  input        spi_master_csn1_o;
  input        spi_master_csn2_o;
  input        spi_master_csn3_o;
  input  [1:0] spi_master_mode_o;
  input        spi_master_sdo0_o;
  input        spi_master_sdo1_o;
  input        spi_master_sdo2_o;
  input        spi_master_sdo3_o;
  output       spi_master_sdi0_i;
  output       spi_master_sdi1_i;
  output       spi_master_sdi2_i;
  output       spi_master_sdi3_i;

  input        uart_tx;
  output       uart_rx;
  input        uart_rts;
  input        uart_dtr;
  output       uart_cts;
  output       uart_dsr;

  output       scl_i;
  input        scl_o;
  input        scl_oen_o;
  output       sda_i;
  input        sda_o;
  input        sda_oen_o;

  output  [31:0] gpio_in;
  input [31:0] gpio_out;
  input [31:0] gpio_dir;

  // JTAG signals
  output  tck_i;
  output  trstn_i;
  output  tms_i;
  output  tdi_i;
  input   tdo_o;

  parameter USE_ZERO_RISCY = 0;
  parameter RISCY_RV32F = 0;
  parameter ZERO_RV32M = 0;
  parameter ZERO_RV32E = 0;

endmodule