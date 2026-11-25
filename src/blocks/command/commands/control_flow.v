module control_flow_block (
    input wire clk, 
    input wire reset, 
    input wire selector, 
    output reg executing, 
    output reg write_enable, 
    output reg [5:0] data_address, 
    output reg [6:0] cmd_address
);

endmodule

module cmd_read (
    input clk,
    input reset,
    input selector,
    input program_data
);


    always @(posedge clk) begin
        if (selector == 0) begin
            
        end
    end


endmodule




module cmd_ (
    input clk,
    input reset,
    input selector,
    input program_data
);


    always @(posedge clk) begin
        if (selector == 0) begin
            
        end
    end


endmodule
