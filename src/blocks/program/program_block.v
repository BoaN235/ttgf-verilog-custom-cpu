module program_block (
    input wire clk,
    input wire reset,
    input wire restart_program,
    input wire [3:0] executing,
    input wire [6:0] cmd_address,

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

        else if (executing == 4'b0000) begin
            if (restart_program) begin
                program_data_address <= 7'd0;
            end 
            else if (executing == 4'b1100 or executing == 4'b1101 or executing == 4'b1110) begin
                if (cmd_address != 1'b0000000) begin
                program_data_address <= cmd_address;
                end
            end 
            else if (program_data_address == 7'd127) begin
                program_data_address <= 7'd0;
            end
            else begin
                program_data_address <= program_data_address + 2'b11;
            end
        end
    end

endmodule
