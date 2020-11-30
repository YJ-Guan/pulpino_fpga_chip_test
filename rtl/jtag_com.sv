///////////////////////////////////////////////////////////////////////////////
// Copyright(C) YJ-Guan. Open source License: MIT.
// ALL RIGHT RESERVED
// File name   : jtag_com.sv
// Author      : YJGuan               
// Date        : 2020-11-09
// Version     : 0.1
// Description : generate jtag simulation stimuli
//
// Modification History:
//   Date   |   Author   |   Version   |   Change Description
//==============================================================================
// 20-11-09 |  YJ-Guan   |     0.1     |  Original Version
////////////////////////////////////////////////////////////////////////////////

module jtag_com(
    input  logic     jtag_clk_i,           // jtag_clk = 10 kHZ
    input  logic     tdo,
    input  logic     jtag_start,
    input  logic     rst_n,
    output logic     trstn,
    output logic     tms  ,
    output logic     tdi  ,
    output logic     jtag_halt,
    output logic     jtag_done
);

    logic [7:0]      jtag_cnt;
    logic [4:0]      jtag_output;
    logic            jtag_start_r;
    parameter [52:0] addr = {5'h3,32'h1A10_7008,16'b1};
    parameter [31:0] data = 32'h0000_0000;

    assign {trstn,tms,tdi,jtag_halt,jtag_done} = jtag_output;

    always_ff @(posedge jtag_clk_i, negedge rst_n) begin
        if ( !rst_n  ) jtag_start_r <= 1'b0;
        else           jtag_start_r <= jtag_start;
    end

    always_ff @(posedge jtag_clk_i , negedge rst_n) begin
        if ( !rst_n  ) begin
            jtag_cnt    <= 8'b11111111;
        end 
        else if (jtag_start == 1'b1 && jtag_start_r == 1'b0) begin
            jtag_cnt    <= 8'b0;           
        end
        else if (jtag_done == 1'b1 ) begin
            jtag_cnt    <= 8'b11111110;
        end 
        else if (jtag_cnt < 8'b11111110) begin
            jtag_cnt    <= jtag_cnt + 1; 
        end
    end

    always_comb begin
        if (rst_n == 1'b0) begin
            jtag_output <= 5'b00010;
        end 
        else begin
            case (jtag_cnt) inside
            // jtag_output = {trstn,tms,tdi,jtag_halt,jtag_done}

                /************   JTAG Part *****************/
                    0:     jtag_output = 5'b10000; 
                    1:     jtag_output = 5'b00000;    // jtag_reset
                    2:     jtag_output = 5'b00000;
                    3:     jtag_output = 5'b10000;
                    [4:8]:     jtag_output = 5'b11000;    // jtag_softreset
                    9:     jtag_output = 5'b10000;
                    10,11:    jtag_output = 5'b11000;   // jtag_initial // jtag_goto_SHIFT_IR
                    12,13:    jtag_output = 5'b10000;
                    14:    jtag_output = 5'b10000;   // jtag_initial // jtag_shift_SHIFT_IR
                    15:    jtag_output = 5'b10000;
                    16:    jtag_output = 5'b10000;
                    17:    jtag_output = 5'b11100;
                    18:    jtag_output = 5'b11000;   // jtag_initial // idle
                    19:    jtag_output = 5'b10000;
                    20:    jtag_output = 5'b11000;   // axi_write // start_shift jtag_goto_SHIFT_DR
                    21:    jtag_output = 5'b10000;
                    22:    jtag_output = 5'b10000;
                    23:    jtag_output = 5'b10000;   // axi_write // shift_nbits(6, 6'b100000, dataout)
                    24:    jtag_output = 5'b10000;
                    25:    jtag_output = 5'b10000;
                    26:    jtag_output = 5'b10000;
                    27:    jtag_output = 5'b10000;
                    28:    jtag_output = 5'b11100;
                    29:    jtag_output = 5'b11000;   // axi_write // update_and_goto_shift
                    30:    jtag_output = 5'b11000;
                    31:    jtag_output = 5'b10000;
                    [32:83]:                         // axi_write // shift_nbits(53,{5'h3,32'h1A10_7008,16'b1}, dataout);
                           jtag_output = {2'b10, addr[jtag_cnt - 32], 2'b00};     
                    84:    jtag_output = 5'b11000;
                    85:    jtag_output = 5'b11000;   // axi_write // update_and_goto_shift
                    86:    jtag_output = 5'b11000;
                    87:    jtag_output = 5'b10000;
                    88:    jtag_output = 5'b10000;
                    89:    jtag_output = 5'b10100;   // axi_write // shift_nbits_noex(32 + 1, {data[0], 1'b1}, dataout);
                    [90:121]:
                           jtag_output = 5'b10000;
                    [122:153]:
                           jtag_output = {2'b10,(jtag_cnt-120) % 4 == 1 ,2'b00};
                                                     // axi_write // shift_nbits(34, {2'b0, 32'h11111111}, dataout);
                    154:   jtag_output = 5'b10000;
                    155:   jtag_output = 5'b11000;
                    156:   jtag_output = 5'b11000;   // axi_write // idle
                    157:   jtag_output = 5'b10000;
                    158:   jtag_output = 5'b10000;
                    159:   jtag_output = 5'b10001;   // done
                /************   Halt & Done ****************/
                    8'b11111110: jtag_output = 5'b10001;
                    8'b11111111: jtag_output = 5'b10010;
            default:       jtag_output = 5'bxxxxx;
            endcase
        end
    end

endmodule