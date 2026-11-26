module data_transfer_block (
    input wire clk, 
    input wire reset, 
    input wire [3:0] selector, 
    input wire [23:0] values,
    input wire [23:0] command,
    output reg [5:0] data_address, 
    output reg [6:0] cmd_address
);

    cmd_read(
        .clk(clk), 
        .reset(reset), 
        .selector(selector), 
        .full_command(command), 
        .values(values)
        );


endmodule

module cmd_read (
    input clk,
    input reset,
    input [3:0] selector,
    input [23:0] full_command,
    input [23:0] values
);


    always @(posedge clk) begin
        if (selector == 0) begin
            
        end
    end


endmodule
