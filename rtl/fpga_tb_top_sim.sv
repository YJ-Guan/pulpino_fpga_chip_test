///////////////////////////////////////////////////////////////////////////////
// Copyright(C) YJ-Guan. Open source License: MIT.
// ALL RIGHT RESERVED
// File name   : fpga_tb_top_sim.sv
// Author      : YJGuan               
// Date        : 2020-11-19
// Version     : 0.1
// Description : verify the function of the fpga implemented testbench in NCSim simulation
//  
// Modification History:
//   Date   |   Author   |   Version   |   Change Description
//==============================================================================
// 20-11-19 |  YJ-Guan   |     0.1     |  Original Version
////////////////////////////////////////////////////////////////////////////////

`include "config.sv"        // config file for pulpino in asic simulation

module fpga_tb_top_sim(
  input rst_n,
  input s_clk,        // s_clk    = 25 MHz
  input jtag_clk,     // jtag_clk = 10 kHz
  input spi_clk       // spi_clk  = 10 MHz  T = 100 ns
);


  parameter  USE_ZERO_RISCY = 0;
  parameter  RISCY_RV32F    = 0;
  parameter  ZERO_RV32M     = 1;
  parameter  ZERO_RV32E     = 0;

  parameter STATE_DELAY = 3'h0 , STATE_SPI1 = 3'h1 , STATE_JTAG = 3'h2, 
            STATE_SPI2 = 3'h3, STATE_HALT =3'h4, STATE_RST = 3'h5, STATE_FETCH = 3'h6;

  //int           exit_status = `EXIT_ERROR; // modelsim exit code, will be overwritten when successful

  //string        memload;
  reg           s_rst_n ;

  reg           fetch_enable ;

  logic [1:0]   padmode_spi_master; // SPI master Signals to drive pulp
  logic         spi_sck;
  logic         spi_csn ;           // chip select
  logic [1:0]   spi_mode;           // CPOL (Clock polarity) + CPHA (Clock phase)   
  logic         spi_sdo0;
  logic         spi_sdo1;
  logic         spi_sdo2;
  logic         spi_sdo3;
  logic         spi_sdi0;
  logic         spi_sdi1;
  logic         spi_sdi2;
  logic         spi_sdi3;
  logic         spi_halt;
  logic         spi_done;
  logic         spi_start1;
  logic         spi_start2;

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
  logic         jtag_halt;
  logic         jtag_done;

  reg   [2:0]   CS;
  logic [2:0]   CS_r;
  logic [2:0]   NS;

  assign tck     = (~ jtag_done && ~ jtag_halt) ? !jtag_clk :0;
  assign spi_sck = (~ spi_done  && ~ spi_halt && ~ spi_csn) ? !spi_clk : 0;

  jtag_com jtag_com_i 
  (
    .jtag_clk_i        ( jtag_clk   ),
    .tdo               ( tdo        ),
    .jtag_start        ( jtag_start ),
    .rst_n             ( rst_n      ),
    .trstn             ( trstn      ),
    .tms               ( tms        ),
    .tdi               ( tdi        ),
    .jtag_halt         ( jtag_halt  ),  
    .jtag_done         ( jtag_done  )
  );

  spi_com spi_com_i
  (
    .spi_clk_i          ( spi_clk    ),
    .rst_n              ( rst_n      ),
    .spi_cs_i           ( spi_csn    ),
    .spi_mode_o         ( spi_mode   ),
    .spi_sdo0_o         ( spi_sdo0   ),
    .spi_sdo1_o         ( spi_sdo1   ),
    .spi_sdo2_o         ( spi_sdo2   ),
    .spi_sdo3_o         ( spi_sdo3   ),
    .spi_start1         ( spi_start1 ),
    .spi_start2         ( spi_start2 ),
    .spi_sdi0_i         ( spi_sdi0   ),
    .spi_sdi1_i         ( spi_sdi1   ),
    .spi_sdi2_i         ( spi_sdi2   ),
    .spi_sdi3_i         ( spi_sdi3   ),
    .spi_halt           ( spi_halt  ),
    .spi_done           ( spi_done   )
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
    .spi_sdo0_o        ( spi_sdo0     ),
    .spi_sdo1_o        ( spi_sdo1     ),
    .spi_sdo2_o        ( spi_sdo2     ),
    .spi_sdo3_o        ( spi_sdo3     ),
    .spi_sdi0_i        ( spi_sdi0     ),
    .spi_sdi1_i        ( spi_sdi1     ),
    .spi_sdi2_i        ( spi_sdi2     ),
    .spi_sdi3_i        ( spi_sdi3     ),

    .spi_master_clk_o  ( /*spi_master.clk    */ ),
    .spi_master_csn0_o ( /*spi_master.csn    */ ),
    .spi_master_csn1_o ( /*                  */ ),
    .spi_master_csn2_o ( /*                  */ ),
    .spi_master_csn3_o ( /*                  */ ),
    .spi_master_mode_o ( /*spi_master.padmode*/ ),
    .spi_master_sdo0_o ( /*spi_master.sdo[0] */ ),
    .spi_master_sdo1_o ( /*spi_master.sdo[1] */ ),
    .spi_master_sdo2_o ( /*spi_master.sdo[2] */ ),
    .spi_master_sdo3_o ( /*spi_master.sdo[3] */ ),
    .spi_master_sdi0_i ( /*spi_master.sdi[0] */ ),
    .spi_master_sdi1_i ( /*spi_master.sdi[1] */ ),
    .spi_master_sdi2_i ( /*spi_master.sdi[2] */ ),
    .spi_master_sdi3_i ( /*spi_master.sdi[3] */ ),

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


  logic [3:0] delay_cnt;
  logic       reset_cnt_n;
  logic       delay_out;

    /* FSM to switch the control of test output signal control */
  always_ff @(posedge s_clk , negedge rst_n) begin
    if ( !rst_n )  begin
      CS <= STATE_HALT;
      CS_r <= STATE_HALT;
    end
    else begin
      CS <= NS;
      if (CS != STATE_DELAY) CS_r <= CS;
    end
  end

  always_comb begin     // next state logic
    if ( !rst_n )  NS = STATE_HALT;
    else begin
    case (CS)
        STATE_HALT:         NS = STATE_DELAY;
        STATE_DELAY:
          begin
            if      ( delay_out == 1'b0 ) 
                            NS = STATE_DELAY;
            else if ( delay_out == 1'b1 ) begin
              case (CS_r)
                STATE_HALT: NS = STATE_RST;
                STATE_RST : NS = STATE_SPI1;
                STATE_SPI2: NS = STATE_FETCH;
                default:    NS = STATE_RST;
              endcase
            end
          end
        STATE_RST:          NS = STATE_DELAY;
        STATE_SPI1:         NS = spi_done  ? STATE_JTAG : STATE_SPI1;
        STATE_JTAG:         NS = jtag_done ? STATE_SPI2 : STATE_JTAG;
        STATE_SPI2:         NS = spi_done  ? STATE_DELAY: STATE_SPI2;
        STATE_FETCH:        NS = STATE_FETCH;
        default:            NS = STATE_HALT;
      endcase
    end
  end

  always_comb  begin    // fsm output logic
    s_rst_n  = 1'b1; fetch_enable = 1'b0; 
    spi_start1 = 1'b0; spi_start2 = 1'b0; jtag_start = 1'b0;
    case (CS)
      STATE_DELAY:
        begin
          case (CS_r)
            STATE_HALT: begin s_rst_n = 1'b0; fetch_enable = 1'b0; end
            STATE_RST:  begin s_rst_n = 1'b1; fetch_enable = 1'b0; end
            default :   begin s_rst_n = 1'b1; fetch_enable = 1'b0; end
          endcase
        end 
      STATE_HALT: 
        begin
          s_rst_n = 1'b0; fetch_enable = 1'b0;
        end
      STATE_RST:    s_rst_n = 1'b1;
      STATE_FETCH:  fetch_enable = 1'b1;
      STATE_SPI1:   spi_start1 = 1'b1;
      STATE_JTAG:   jtag_start = 1'b1;
      STATE_SPI2:   spi_start2 = 1'b1;
      default:
        begin
          s_rst_n = 1'b1; fetch_enable = 1'b0;
        end
    endcase
  end


    /* counter to generate 10 clk delay */
  always_ff @(posedge s_clk, negedge rst_n) begin
    if ( rst_n == 1'b0 || NS != STATE_DELAY) begin
      delay_cnt <= 4'b0;
      delay_out <= 1'b0;
    end
    else if ( delay_cnt == 10 ) begin
      delay_cnt <= 4'b0;
      delay_out <= 1'b1;
    end
    else if ( NS == STATE_DELAY )
      delay_cnt  <= delay_cnt + 1;
    else delay_cnt <= delay_cnt;
  end


endmodule