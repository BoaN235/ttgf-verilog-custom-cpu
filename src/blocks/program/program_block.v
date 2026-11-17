
module program_block (
    input wire clk,
    input wire reset,
    input wire restart_program,
    input wire executing,

    output reg write_enable,
    output reg [6:0] program_data_address
);

    always @(posedge clk) begin
        if (reset) begin
            program_data_address <= 7'd0;
            write_enable <= 1'b1;
        end

        else if (write_enable) begin
            if (program_data_address == 7'd127) begin
                write_enable <= 1'b0;
                program_data_address <= 7'd0;
            end else begin
                program_data_address <= program_data_address + 1'b1;
            end
        end

        else if (executing) begin
            if (restart_program) begin
                program_data_address <= 7'd0;
            end
            else if (program_data_address == 7'd127) begin
                program_data_address <= 7'd0;
            end
            else begin
                program_data_address <= program_data_address + 1'b1;
            end
        end
    end

endmodule
