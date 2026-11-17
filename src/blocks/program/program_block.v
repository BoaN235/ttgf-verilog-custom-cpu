module program_block(
    input wire clk,
    input wire reset,
    input wire restart_program,

    output reg read_enable,
    output reg [7:0] program_data_address
);

    reg program_start = 1'b0;

    always @(posedge clk) begin
        if (reset || ~read_enable) begin // If downloading (read_enable) or restart pin is high restart download
            if (reset) begin // If reset pin is high restart download
                program_data_address <= 0;
                read_enable <= 1'b0;
            end else if (program_data_address == 255) begin // If memory is full stop downloading
                read_enable <= 1'b1;
                program_start <= 1'b1;
            end else begin // Else increment counter
                program_data_address <= program_data_address + 1;
            end
        end else begin // If not restarting or downloading start program
            if ((program_start && read_enable) || restart_program) begin // Start the program if download finished (program_start and read_enable) or restart program from memory
                program_data_address <= 0;
                read_enable <= 1'b0;
                program_start <= 1'b0;
            end else if (program_data_address == 255) begin // Restart program if done
                program_start <= 1'b1;
            end else begin
                program_data_address <= program_data_address + 1;
            end
        end
    end


endmodule