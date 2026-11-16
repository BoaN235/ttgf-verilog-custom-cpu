module program_block(
    input clk,
    input reset,

    input data_valid,
    input [7:0] incoming_data,

    input read_enable,

    output [7:0] read_data
);



























reg we = 1'b1;
reg download = 1'b1;

wire [7:0] read_address;

// clock counter
reg [7:0] write_address;
always @(posedge clk) begin
    if (reset) begin
            write_address <= 0;
            we = 1'b1; // set write
    end
    else if (data_valid) begin
        write_address <= write_address + 1;
    end 
    
    if (write_address >= 127) begin
    download = 1'b0;
end
end



reg [7:0] program_counter = 127;
always @(posedge clk) begin
    if (!download & program_counter >= 127) begin
            program_counter <= 0;
            we = 1'b0; // set read
    end
    else if (data_valid) begin 
        program_counter <= program_counter + 1;
    end
end
assign read_address = program_counter

endmodule