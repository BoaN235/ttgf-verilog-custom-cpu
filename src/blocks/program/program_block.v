module program_block(
    input wire clk,
    input wire reset,
    input wire restart_program,

    input wire executing;

    output reg write_enable,
    output reg [6:0] program_data_address
);

    reg program_start;

    always @(posedge clk) begin

            if (reset) begin // If reset pin is high restart download
                program_data_address <= 7'd0;
                write_enable <= 1'b0;
                program_start <= 1'b0
            end 
            
            else if (write_enable)
                
                if (program_data_address == 7'd127) begin // If memory is full stop downloading
                    write_enable <= 1'b1;
                    program_start <= 1'b1;
                end 
                
                else begin // Else increment counter
                    program_data_address <= program_data_address + 1'b1;
                end 
            
            else if (~executing) begin 

                if (restart_program) begin // Start the program if download finished (program_start and write_enable) or restart program from memory
                    program_data_address <= 7'd0;
                end

                else if (program_data_address == 7'd127) begin // Restart program if done
                    program_start <= 1'b1;
                end 
                
                else begin
                    program_data_address <= program_data_address + 1'b1;
                end 

            end

        end



endmodule