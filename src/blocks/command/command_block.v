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
    reg [1:0] counter;

    // Temporary placeholder until jump functionality is implemented.
    assign jump_bool = 1'b0;

    always @(posedge clk) begin
        if (reset) begin
            selector         <= 4'd0;
            command_length   <= 2'd0;
            counter          <= 2'd0;
            write_enable     <= 1'b0;
            data_address     <= 6'd0;
            cmd_address      <= 7'd0;
            restart_program  <= 1'b0;
            hold_program     <= 1'b0;
            result           <= 8'd0;
        end
        else if (!hold_command) begin
            // Each command is selected using the lowest 4 bits.
            case (command_mem[3:0])

                4'b0000: begin // End
                    selector <= 4'd0;
                end

                // DATA TRANSFER

                4'b0001: begin // Read

                    case (counter)
                        2'b00: begin
                            selector <= 4'd1;
                            write_enable <= 1'b0;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                4'b0010: begin // Save

                    case (counter)
                        2'b00: begin
                            selector <= 4'd2;
                            write_enable <= 1'b1;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                4'b0011: begin // Write

                    case (counter)
                        2'b00: begin
                            selector <= 4'd3;
                            write_enable <= 1'b1;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                4'b0100: begin // Copy

                    case (counter)
                        2'b00: begin
                            selector <= 4'd4;
                            write_enable <= 1'b1;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                // ALU - MATH AND LOGIC

                4'b0101: begin // Math

                    case (counter)
                        2'b00: begin
                            selector <= 4'd5;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                4'b0110: begin // Logic

                    case (counter)
                        2'b00: begin
                            selector <= 4'd6;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                4'b0111: begin // Shift R/L

                    case (counter)
                        2'b00: begin
                            selector <= 4'd7;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                // CONTROL FLOW - FUNCTIONS AND CONDITIONALS

                4'b1000: begin // If

                    case (counter)
                        2'b00: begin
                            selector <= 4'd8;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                4'b1001: begin // Return

                    case (counter)
                        2'b00: begin
                            selector <= 4'd9;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                4'b1010: begin // Jump

                    case (counter)
                        2'b00: begin
                            selector <= 4'd10;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                4'b1011: begin // Wait

                    case (counter)
                        2'b00: begin
                            selector <= 4'd11;
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
                            selector <= 4'd15;
                            hold_program <= 1'b0;
                        end
                    endcase
                end

                default: begin
                    selector <= 4'd15;
                end

            endcase
        end
    end

endmodule
