///////////////////////////////////////////////////////////////////////////////
// Copyright(C) YJ-Guan. Open source License: MIT.
// ALL RIGHT RESERVED
// File name   : spi_com.sv
// Author      : YJGuan               
// Date        : 2020-11-09
// Version     : 0.1
// Description : generate spi simulation stimuli
//
// Modification History:
//   Date   |   Author   |   Version   |   Change Description
//==============================================================================
// 20-11-09 |  YJ-Guan   |     0.1     |  Original Version
////////////////////////////////////////////////////////////////////////////////

module spi_com(              /* spi_enable_qpi / spi_write_reg(0,8'h1,8'h1); */
    
    input   logic              spi_clk_i,   // spi_clk = 10 MHZ  T = 100 ns
    input   logic              rst_n,
    output  logic              spi_cs_i , 
    input   logic [1:0]        spi_mode_o,
    input   logic              spi_sdo0_o,
    input   logic              spi_sdo1_o,
    input   logic              spi_sdo2_o,
    input   logic              spi_sdo3_o,
    input   logic              spi_start1,
    input   logic              spi_start2,
    output  logic              spi_sdi0_i,
    output  logic              spi_sdi1_i,
    output  logic              spi_sdi2_i,
    output  logic              spi_sdi3_i,
    output  logic              spi_halt,
    output  logic              spi_done
);

    logic [5:0] spi_cnt;
    logic [6:0] spi_output;
    parameter [31:0] addr = 32'h1A10_7008;
    parameter [31:0] data = 32'h0000_0000;

    assign {spi_cs_i,spi_sdi0_i,spi_sdi1_i,spi_sdi2_i,spi_sdi3_i,spi_done} = spi_output;

    always_ff @(posedge spi_clk_i , negedge rst_n) begin
        if (rst_n == 1'b0 ) begin
            spi_cnt    <= 6'b111111;
        end 
        else if (spi_start1 == 1'b1) begin
            spi_cnt    <= 6'b0;
        end           
        else if (spi_start2 == 1'b1) begin
            spi_cnt    <= 6'd50;           
        end
        else if (spi_done == 1'b1 ) begin
            spi_cnt    <= 6'b111110;
        end 
        else if (spi_cnt < 6'b111110) begin
            spi_cnt    <= spi_cnt + 1; 
        end
    end

    always_ff @(posedge spi_clk_i , negedge rst_n) begin
        if (rst_n == 1'b0) begin
            spi_output <= 7'bxxxxxx;
        end 
        else begin
            case (spi_cnt)
            // {spi_cs_i,spi_sdi0_i,spi_sdi1_i,spi_sdi2_i,spi_sdi3_i,spi_halt,spi_done}
            
                /************   SPI_1 Part *****************/
                    0:      spi_output <= 7'b0xxx000;
                    1:      spi_output <= 7'b0xxx000;   //spi_enable_qpi();
                    [2:8]:
                            spi_output <= 7'b00xxx00;
                    9:      spi_output <= 7'b01xxx00;
                    [10:16]:
                            spi_output <= 7'b00xxx00;
                    17:     spi_output <= 7'b01xxx01;
                /************   SPI_2 Part *****************/    
                    50:     spi_output <= 7'b1100000;
                /************   Halt & Done ****************/
                    6'b111110: spi_output <= 7'b0000001;
                    6'b111110: spi_output <= 7'b0000010;
            default:       spi_output <= 7'bxxxxxxx;
            endcase
        end
    end

endmodule