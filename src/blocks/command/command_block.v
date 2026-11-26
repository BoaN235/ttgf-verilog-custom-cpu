module command_block (
    input wire clk,
    input wire reset,
    input wire [7:0] program_ram_data,

    output reg restart_program,
    output reg [3:0] executing,

    output reg write_enable,
    output reg [5:0] data_address,
    output reg [6:0] cmd_address
);

    reg value_mem [23:0]
    reg command_mem [23:0]
    reg [3:0] selector;
    reg [1:0] command_length;
    
    control_flow_block control_flow (clk, reset, selector, value_mem, command_mem, write_enable, data_address, cmd_address);

    always @(selector) begin
        command_length = 2'b0
    end 

    always @(posedge clk) begin
        if (selector == 15) begin // I split it up so its easier to read and understand each cmd
            case (program_ram_data [3:0])  // -> = return value to working memory when cmd ends
                4'b0000:   selector = 0; // 0000 End x
                                    // [ DATA TRANSFER  saving or reading data ]
                4'b0001:   selector = 1;  // 0001 Read (output Num at address) Done
                4'b0010:   selector = 2;  // 0010 Save (Save -> at address) Done
                4'b0011:   selector = 3;  // 0011 Write (Save Num x at address) Done
                4'b0100:   selector = 4;  // 0100 Copy (Copy value @ address x to address y) x
                                    // [ ALU - Math & Logic ]
                4'b0101:   selector = 5;  // 0101 Math (See Math Instructions) x
                4'b0110:   selector = 6;  // 1001 Logic (See Logic Instruction) x
                4'b0111:   selector = 7; // 1100 Shift R/L (See Shift Instructions) x
                                    // [ Control FLow - Functions & Conditionals ]
                4'b1000:   selector = 8;  // 1100 If () x
                4'b1001:   selector = 9;  // 1100 Return () x
                4'b1010:   selector = 10;  // 1100 Jump () x
                4'b1011:   selector = 11;  // 1100 Wait () x
                default: selector = 0;  // 0000 End
            endcase
        end
        if (selector == 0) begin
            restart_program <= 1'b1
        end
    end

    assign executing = selector;
endmodule