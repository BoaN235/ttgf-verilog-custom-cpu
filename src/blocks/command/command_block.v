module command_block (
    input wire clk,
    input wire reset,
    input wire hold_command,

    input wire [23:0] command_mem,
    input wire [23:0] value_mem,

    output wire jump_bool,
    output reg write_enable,
    output reg [5:0] data_address,
    output reg [6:0] cmd_address,
    output reg restart_program,
    output reg hold_program,
    output reg [7:0] result
);

    reg [3:0] selector;
    reg [1:0] command_length;
    reg [3:0] counter;
    

    always @(posedge clk) begin
        if (!hold_command) begin // I split it up so its easier to read and understand each cmd
            case (command_mem [3:0])  // -> = return value to working memory when cmd ends
                
                4'b0000:   selector = 0; // 0000 End x
                
                                    // [ DATA TRANSFER  saving or reading data ]
                
                4'b0001: begin  // 0001 Read (output Num at address) Done 
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd1; 
                            write_enable = 1'b0; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                4'b0010: begin // 0010 Save (Save -> at address) Done
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd2; 
                            write_enable = 1'b1; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end
                
                4'b0011: begin // 0011 Write (Save Num x at address) Done  
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd3; 
                            write_enable = 1'b1; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                4'b0100: begin // 0100 Copy (Copy value @ address x to address y) x  
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd4; 
                            write_enable = 1'b1; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end
                
                                    // [ ALU - Math & Logic ]
                
                4'b0101: begin  // 0101 Math (See Math Instructions) x
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd5; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                4'b0110: begin   // 1001 Logic (See Logic Instruction) x
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd6;
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                4'b0111: begin // 1100 Shift R/L (See Shift Instructions) x  
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd7; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                                    // [ Control FLow - Functions & Conditionals ]

                4'b1000: begin  // 1100 If () x  
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd8; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                4'b1001: begin  // 1100 Return () x  
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd9; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                4'b1010: begin  // 1100 Jump () x  
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd10; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                4'b1011: begin  // 1100 Wait () x  
    
                    case(counter)
                    
                        2'b00: begin 

                            selector = 4'd11; 
                            counter <= 2'b01;

                        end
                        2'b01: begin 

                            counter <= 2'b10;

                        end
                        2'b10: begin 

                            counter <= 2'b11;

                        end
                        2'b11: begin 

                            counter <= 2'b00;

                        end
                        default: begin

                            selector = 4'd15;
                            hold_program = 1'b0;

                        end

                    endcase
                end

                default: selector = 15;  // 0000 End
            endcase
        end
    end
endmodule