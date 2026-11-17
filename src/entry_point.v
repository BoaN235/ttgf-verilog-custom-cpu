/*
 * Copyright (c) 2026 opilitethesmartdev
 * SPDX-License-Identifier: Apache-2.0
 *
 * Tiny Tapeout GF180MCU Dual SRAM example.
 * sram1 (128×8): Program memory
 * sram2 (64×8):  Data memory
 *
 * ui_in[6:0]  Address (program memory uses all 7 bits, data memory uses lower 6)
 * ui_in[7]    Memory select (0=program, 1=data)
 * ui_in[6]    Write enable (active high)
 * uio_in      Write data
 * uo_out      Read data
 *
 * The SRAM itself has no reset. rst_n is used only to hold CEN inactive
 * until the system has completed reset.
 */

`default_nettype none

module tt_um_cpu (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [7:0] program_data_out;  // Program memory output
    wire [7:0] data_out;  // Data memory output

    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    wire program_write_enable;
    wire [6:0] program_data_address;

    wire data_write_enable;
    wire [5:0] data_address;

    wire executing

    // Output multiplexer: select which SRAM based on ui_in[7]
    assign uo_out  = ui_in[7] ? data_out : program_data_out;

    reg restart_program = 1'b0;

    program_block programs (.clk(clk), .reset(rst_n), .restart_program(restart_program), .executing(executing_cmd) .read_enable(program_write_enable), .program_data_address(program_data_address));

`ifdef SYNTH
    // Tiny Tapeout's FPGA workflow defines SYNTH. Use inferred memories
    // on FPGA; the GF180 hard macros are only available in the ASIC flow.
    reg [7:0] fpga_program [0:127];  // 128×8 program memory
    reg [7:0] fpga_data [0:63];      // 64×8 data memory
    reg [7:0] fpga_q1, fpga_q2;

    always @(posedge clk) begin
        if (!rst_n) begin
            fpga_q1 <= 8'h00;
            fpga_q2 <= 8'h00;
        end else if (ena) begin
            // Program memory
            if (program_write_enable) begin
                fpga_program[program_data_address] <= uio_in;
            end else begin
                fpga_q1 <= fpga_program[program_data_address];
            end
            // Data memory
            if (data_write_enable) begin
                fpga_data[data_address] <= uio_in;
            end else begin
                fpga_q2 <= fpga_data[data_address];
            end
        end
    end

    assign program_data_out = fpga_q1;
    assign data_out = fpga_q2;

`elsif __pnr__
    // LibreLane defines __pnr__ and supplies the black-box header through
    // the MACROS configuration. VPWR/VGND are internal PDN nets, not user pins.
    wire VPWR;
    wire VGND;

    gf180mcu_fd_ip_sram__sram128x8m8wm1 program_data (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~program_write_enable),
        .WEN  (8'h00),
        .A    (program_data_address),
        .D    (uio_in),
        .Q    (program_data_out)
    );

    gf180mcu_fd_ip_sram__sram64x8m8wm1 sram2 (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~data_write_enable),
        .WEN  (8'h00),
        .A    (data_address),
        .D    (uio_in),
        .Q    (data_out)
    );

`else
    // RTL simulation uses the official Google/GlobalFoundries timing model.
    // Its power pins are tied off here; the functional model does not model
    // power sequencing. The ASIC flow uses the physical macro branch above.
    wire model_vdd = 1'b1;
    wire model_vss = 1'b0;

    gf180mcu_fd_ip_sram__sram128x8m8wm1 program_data (
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~program_write_enable),
        .WEN  (8'h00),
        .A    (program_data_address),
        .D    (uio_in),
        .Q    (program_data_out),
        .VDD  (model_vdd),
        .VSS  (model_vss)
    );

    gf180mcu_fd_ip_sram__sram64x8m8wm1 sram2 (
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~data_write_enable),
        .WEN  (8'h00),
        .A    (data_address),
        .D    (uio_in),
        .Q    (data_out),
        .VDD  (model_vdd),
        .VSS  (model_vss)
    );

`endif

    // ui_in[7] is used for memory select (0=program, 1=data)

endmodule

`default_nettype wire
