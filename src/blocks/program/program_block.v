module program_block (
    input wire clk,
    input wire reset,
    input wire restart_program,

    input wire hold_program,
    input wire jump_bool,
    input wire [6:0] cmd_address,

    output reg write_enable,
    output reg [6:0] program_data_address,
    output reg new_program_address
);

    always @(posedge clk) begin
        if (reset) begin
            // Start loading the program into SRAM.
            program_data_address <= 7'd0;
            write_enable <= 1'b1;
            new_program_address <= 1'b0;
        end

        else if (write_enable) begin
            // Load each byte of the program into memory.
            if (program_data_address == 7'd127) begin
                // Loading is complete.
                write_enable <= 1'b0;
                program_data_address <= 7'd0;
                new_program_address <= 1'b0;
            end
            else begin
                program_data_address <= program_data_address + 7'd1;
                new_program_address <= 1'b0;
            end
        end

        else if (!hold_program) begin
            // Start the run counter when the program is not being held.
            if (restart_program || program_data_address == 7'd127) begin
                program_data_address <= 7'd0;
            end

            else if (jump_bool) begin
                program_data_address <= cmd_address;
            end

            else begin
                // Commands are three bytes long.
                program_data_address <= program_data_address + 7'd3;
            end

            new_program_address <= 1'b1;
        end

        else begin
            new_program_address <= 1'b0;
        end
    end

endmodule