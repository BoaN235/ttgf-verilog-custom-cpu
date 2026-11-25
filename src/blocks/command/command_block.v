module command_block (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] instruction,

    output reg        restart_program,
    output reg  [3:0] executing,

    output reg        write_enable,
    output reg  [5:0] data_address,
    output reg  [6:0] cmd_address
);

    always @(posedge clk) begin
        if (reset) begin
            restart_program <= 1'b0;
            executing       <= 4'b1111;
            write_enable    <= 1'b0;
            data_address    <= 6'd0;
            cmd_address     <= 7'd0;
        end else begin
            restart_program <= 1'b0;
            cmd_address     <= 7'd0;
            write_enable    <= 1'b0;

            executing <= instruction[7:4];

            case (instruction[7:4])
                4'b0000: begin // End / restart program
                    restart_program <= 1'b1;
                end

                4'b0001: begin // Read from data address
                    data_address <= instruction[5:0];
                end

                4'b0010: begin // Save to data address
                    write_enable <= 1'b1;
                    data_address <= instruction[5:0];
                end

                4'b0011: begin // Write literal: address is 6 bits
                    write_enable <= 1'b1;
                    data_address <= instruction[5:0];
                end

                4'b0100: begin // Copy
                    data_address <= instruction[5:0];
                end

                4'b0101, // Math
                4'b0110, // Logic
                4'b1011: begin // Shift
                    data_address <= instruction[5:0];
                end

                4'b0111: begin // Wait
                    cmd_address <= instruction[6:0];
                end

                4'b1100, // Conditional branch
                4'b1101, // Return
                4'b1110: begin // Unconditional jump
                    cmd_address <= instruction[6:0];
                end

                default: begin
                    executing <= 4'b0000;
                end
            endcase
        end
    end

endmodule