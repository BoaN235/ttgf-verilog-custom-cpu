module command_block (
    input wire clk,
    input wire reset,
    input wire hold_command,

    input wire [23:0] command_mem,
    input wire [23:0] value_mem, 

    output wire jump_bool
    output reg write_enable,
    output reg [5:0] data_address,
    output reg [6:0] cmd_address
    output reg restart_program,
    output reg hold_program
);

    reg [3:0] selector;
    reg [1:0] command_length;


    always @(posedge clk) begin
        if (selector == 15 and !hold_command) begin // I split it up so its easier to read and understand each cmd
            case (program_ram_data [3:0])  // -> = return value to working memory when cmd ends
                
                4'b0000:   selector = 0; // 0000 End x
                
                                    // [ DATA TRANSFER  saving or reading data ]
                
                4'b0001: begin  // 0001 Read (output Num at address) Done 
                    selector = 1; 
                    write_enable = 1'b0; 
                end

                4'b0010: begin // 0010 Save (Save -> at address) Done
                    selector = 2; 
                    write_enable = 1'b1; 
                end
                
                4'b0011: begin // 0011 Write (Save Num x at address) Done  
                    selector = 3; 
                    write_enable = 1'b1; 
                end

                4'b0100: begin // 0100 Copy (Copy value @ address x to address y) x  
                    selector = 4; 
                    write_enable = 1'b1; 
                end
                
                                    // [ ALU - Math & Logic ]
                
                4'b0101: begin  // 0101 Math (See Math Instructions) x
                    selector = 5; 
                end

                4'b0110: begin   // 1001 Logic (See Logic Instruction) x
                    selector = 6;
                end

                4'b0111: begin // 1100 Shift R/L (See Shift Instructions) x  
                    selector = 7;
                end

                                    // [ Control FLow - Functions & Conditionals ]

                4'b1000: begin  // 1100 If () x  
                    selector = 8;
                end

                4'b1001: begin  // 1100 Return () x  
                    selector = 9;
                end

                4'b1010: begin  // 1100 Jump () x  
                    selector = 10;
                end

                4'b1011: begin  // 1100 Wait () x  
                    selector = 11;
                end

                default: selector = 15;  // 0000 End
            endcase
        end
    end

    assign {cmd_address, data_address} = 0
endmodule