///////////////////////////////////////////////////////////////////////////////
// Copyright(C) YJ-Guan. Open source License: MIT.
// ALL RIGHT RESERVED
// File name   : spi_com.sv
// Author      : YJGuan               
// Date        : 2020-11-16
// Version     : 0.1
// Description : generate spi simulation stimuli
//
// Modification History:
//   Date   |   Author   |   Version   |   Change Description
//==============================================================================
// 20-11-16 |  YJ-Guan   |     0.1     |  Original Version
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

    logic [15:0]          spi_cnt;
    logic [6:0]           spi_output;

    logic [63:0]          stimuli  [10000:0];   // array for the stimulus vectors
    int                   num_stim = 0;
    logic                 more_stim = 1;

    logic [31:0]          spi_data;
    logic [31:0]          spi_data_recv;
    logic [31:0]          spi_addr;
    logic [31:0]          spi_addr_old;
    logic                 spi_start1_r;
    logic                 spi_start2_r;

    assign {spi_cs_i,spi_sdi3_i,spi_sdi2_i,spi_sdi1_i,spi_sdi0_i,spi_halt,spi_done} = spi_output;
    
    initial begin   // read in the stimuli vectors  == address_value
        $readmemh("./slm_files/spi_stim.txt", stimuli);  
    end

    always_ff @(posedge spi_clk_i) begin    // start signals delay 1 clk
        spi_start1_r <= spi_start1;
        spi_start2_r <= spi_start2;
    end

    always_ff @(posedge spi_clk_i , negedge rst_n) begin
        if (rst_n == 1'b0 ) begin
            spi_cnt    <= 16'b1111_1111_1111_1111;
        end 
        else if (spi_start1 == 1'b1 && spi_start1_r == 1'b0) begin
            spi_cnt    <= 16'b1;
        end           
        else if (spi_start2 == 1'b1 && spi_start2_r == 1'b0) begin
            spi_cnt    <= 16'd51;           
        end
        else if (spi_done == 1'b1 ) begin
            spi_cnt    <= 16'b1111_1111_1111_1110;
        end 
        else if (spi_cnt < 16'b1111_1111_1111_1110) begin
            spi_cnt    <= spi_cnt + 1; 
        end
    end

    always_comb begin
        if (rst_n == 1'b0) begin
            spi_output = 7'b000000;
        end 
        else begin
            case (spi_cnt) inside
            // {spi_cs_i,spi_sdi3_i,spi_sdi2_i,spi_sdi1_i,spi_sdi0_i,spi_halt,spi_done}
            
                /************   SPI_1 Part *****************/
                    0:      spi_output = 7'b0000000;   // spi_enable_qpi();
                    [1:7]:
                            spi_output = 7'b0000000;
                    8:      spi_output = 7'b0000100;
                    [9:15]:
                            spi_output = 7'b0000000;
                    16:     spi_output = 7'b0000100;
                    17:     spi_output = 7'b0000001;
                /************   SPI_2 Part *****************/    
                    // spi_send_cmd_addr(use_qspi,8'h2,spi_addr);
                    51:     spi_output = 7'b0000000;    // spi_addr = stimuli[0][63:32]
                    52:     spi_output = 7'b0001000;
                    [53:60]:
                    begin
                            spi_addr = stimuli[0][63:32];
                            spi_output = {1'b0,spi_addr[31-(spi_cnt-53)*4 -: 4],2'b0};
                    end
                    // spi_send_data  instruction reg
                    [61:61+1131*8-1]:
                    begin
                            spi_data = stimuli[(spi_cnt-61)/8][31:0];
                            spi_output = {1'b0,spi_data[31-(spi_cnt-61)%8*4 -: 4],2'b0};
                    end
                    9109:   spi_output = 7'b0000000;
                    9110:   spi_output = 7'b1000000;
                    9111:   spi_output = 7'b0000000;    // spi_addr = stimuli[0][63:32]
                    9112:   spi_output = 7'b0001000;
                    [9113:9120]:
                    begin
                            spi_addr = stimuli[1131][63:32];
                            spi_output = {1'b0,spi_addr[31-(spi_cnt-9113)*4 -: 4],2'b0};
                    end                   
                    [9121:9121+134*8-1]:
                    begin
                            spi_data = stimuli[(spi_cnt-9121)/8+1131][31:0];
                            spi_output = {1'b0,spi_data[31-(spi_cnt-9121)%8*4 -: 4],2'b0}; 
                    end
                    10193:  spi_output = 7'b1000001;
                /************   Halt & Done ****************/
                    16'b1111_1111_1111_1110: spi_output = 7'b1000001;
                    16'b1111_1111_1111_1111: spi_output = 7'b1000010;
            default:           spi_output = 7'bxxxxxxx;
            endcase
        end
    end

endmodule