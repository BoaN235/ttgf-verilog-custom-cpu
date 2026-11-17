module command_block (
    input wire clk,
    input wire reset,

    output reg restart_program,
    output reg executing,

    output reg write_enable,
    output reg [5:0] data_address
);

    reg selector [3:0];
    
    alu_logic_block alu_logic (clk, reset, selector, executing, write_enable, data_address);
    control_flow_block control_flow (clk, reset, selector, executing, write_enable, data_address);
    data_transfer_block data_transfer (clk, reset, selector, executing, write_enable, data_address);

    always @(command) begin
        if (selector == 0) begin // I split it up so its easier to read and understand each cmd
            case (command [3:0])  // -> = return value to working memory when cmd ends
                4'b0000:   selector = 0; // 0000 End x
                                    // [ DATA TRANSFER - saving or reading data ]
                4'b0001:   selector = 1;  // 0001 Read (output Num at address) Done
                4'b0010:   selector = 2;  // 0010 Save (Save -> at address) Done
                4'b0011:   selector = 3;  // 0011 Write (Save Num x at address) Done
                4'b0100:   selector = 4;  // 0100 Copy (Copy value @ address x to address y) x
                                    // [ ALU - Math & Logic ]
                4'b0101:   selector = 5;  // 0101 Math (See Math Instructions) x
                4'b0111:   selector = 6;  // 1001 Logic (See Logic Instruction) x
                4'b1011:   selector = 11; // 1100 Shift R/L (See Shift Instructions) x
                                    // [ Control FLow - Functions & Conditionals ]
                4'b1100:   selector = 12;  // 1100 If () x
                4'b1101:   selector = 13;  // 1100 Return () x
                4'b1110:   selector = 14;  // 1100 Jump () x
                4'b1111:   selector = 14;  // 1100 Wait () x
                default: selector = 0;  // 0000 End
            endcase
        end
        if (selector == 0) begin
            restart_program <= 1'b1
        end
    end
endmodule