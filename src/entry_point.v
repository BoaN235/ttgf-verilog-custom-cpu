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

    wire [7:0] sram1_q;  // Program memory output
    wire [7:0] sram2_q;  // Data memory output

    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;
    // Output multiplexer: select which SRAM based on ui_in[7]
    assign uo_out  = ui_in[7] ? sram2_q : sram1_q;


//program_block programs (clk, rst_n, );

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
            if (ui_in[6]) begin
                fpga_program[ui_in[6:0]] <= uio_in;
            end else begin
                fpga_q1 <= fpga_program[ui_in[6:0]];
            end
            // Data memory
            if (ui_in[6]) begin
                fpga_data[ui_in[5:0]] <= uio_in;
            end else begin
                fpga_q2 <= fpga_data[ui_in[5:0]];
            end
        end
    end

    assign sram1_q = fpga_q1;
    assign sram2_q = fpga_q2;

`elsif __pnr__
    // LibreLane defines __pnr__ and supplies the black-box header through
    // the MACROS configuration. VPWR/VGND are internal PDN nets, not user pins.
    wire VPWR;
    wire VGND;

    gf180mcu_fd_ip_sram__sram128x8m8wm1 sram1 (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~ui_in[6]),
        .WEN  (8'h00),
        .A    (ui_in[6:0]),
        .D    (uio_in),
        .Q    (sram1_q)
    );

    gf180mcu_fd_ip_sram__sram64x8m8wm1 sram2 (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~ui_in[6]),
        .WEN  (8'h00),
        .A    (ui_in[5:0]),
        .D    (uio_in),
        .Q    (sram2_q)
    );

`else
    // RTL simulation uses the official Google/GlobalFoundries timing model.
    // Its power pins are tied off here; the functional model does not model
    // power sequencing. The ASIC flow uses the physical macro branch above.
    wire model_vdd = 1'b1;
    wire model_vss = 1'b0;

    gf180mcu_fd_ip_sram__sram128x8m8wm1 sram1 (
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~ui_in[6]),
        .WEN  (8'h00),
        .A    (ui_in[6:0]),
        .D    (uio_in),
        .Q    (sram1_q),
        .VDD  (model_vdd),
        .VSS  (model_vss)
    );

    gf180mcu_fd_ip_sram__sram64x8m8wm1 sram2 (
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~ui_in[6]),
        .WEN  (8'h00),
        .A    (ui_in[5:0]),
        .D    (uio_in),
        .Q    (sram2_q),
        .VDD  (model_vdd),
        .VSS  (model_vss)
    );

`endif

    // ui_in[7] is used for memory select (0=program, 1=data)

endmodule

`default_nettype wire
