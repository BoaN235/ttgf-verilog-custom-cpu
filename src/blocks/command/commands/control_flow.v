module control_flow_block (
    input wire clk, 
    input wire reset, 
    input wire [3:0] selector, 
    input wire [23:0] values,
    input wire [23:0] command,
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




module cmd_save (
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

module cmd_write (
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




module cmd_copy (
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