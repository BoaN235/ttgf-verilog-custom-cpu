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
        if (reset) begin // On reset start the load counter of the program to RAM
            program_data_address <= 7'd0;
            write_enable <= 1'b1;
        end

        else if (write_enable) begin // load each chunk of the program to a part of memory
            if (program_data_address == 7'd127) begin // If the loading is done set the ram to read only and start the program at 0
                write_enable <= 1'b0;
                program_data_address <= 7'd0;
            end 
            
            else begin // if the loading is not done increase the program load address by one
                program_data_address <= program_data_address + 1'b1;
            end
        end

        else if (!hold_program) begin // If there is no command executing and program is not being loaded start the run counter
            if (restart_program || program_data_address == 7'd127) begin // If a reset program signal was sent or if the program reached the end then restart counter
                program_data_address <= 7'd0;
            end 
            else if (jump_bool) begin // if any of the jump commands are sent stop counting and send the cmd address 
                program_data_address <= cmd_address;
            end 
            else begin
                program_data_address <= program_data_address + 7'b11;
            end
            new_program_address <= 1'b1
        end else begin
            new_program_address <= 1'b0
        end
    end

endmodule
