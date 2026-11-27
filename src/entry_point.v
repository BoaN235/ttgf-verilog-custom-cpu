/*
 * Copyright (c) 2026 opilitethesmartdev
 * SPDX-License-Identifier: Apache-2.0
 *
 * Tiny Tapeout GF180MCU Dual SRAM example.
 * sram1 (128×8): Program memory
 * sram2 (64×8):  Data memory
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
    wire [7:0] data_out;          // Data memory output

    assign uio_oe  = 8'h00;

    wire program_write_enable;
    reg [6:0] program_data_address;
    wire [6:0] target_program_data_address; // Changed from reg to wire (driven by submodule)

    wire data_write_enable;
    wire [5:0] data_address;

    wire unused = &{1'b0, ui_in[6:0]};

    // Output multiplexer: select which SRAM based on ui_in[7]
    assign uo_out  = ui_in[7] ? data_out : program_data_out;

    wire [6:0] cmd_address;

    reg [23:0] command_mem;
    reg [23:0] value_mem = 24'd0;

    wire jump_bool;
    wire [7:0] result;

    reg [1:0] command_length;

    reg hold_program;
    reg hold_command;
    wire restart_program;
    wire command_done;
    wire new_program_address;

    assign uio_out = result;

    command_block command (
        .clk(clk),
        .reset(~rst_n),
        .hold_command(hold_command),
        .command_mem(command_mem),
        .value_mem(value_mem),
        .restart_program(restart_program),
        .jump_bool(jump_bool),
        .cmd_address(cmd_address),
        .write_enable(data_write_enable),
        .data_address(data_address),
        .result(result),
        .command_done(command_done)
    );

    wire unused_yes = &{1'b0, command_done};

    program_block programs (
        .clk(clk),
        .reset(~rst_n),
        .restart_program(restart_program),
        .hold_program(hold_program),
        .cmd_address(cmd_address),
        .jump_bool(jump_bool),
        .write_enable(program_write_enable),
        .program_data_address(target_program_data_address),
        .new_program_address(new_program_address)
    );

    always @(posedge clk) begin
        if (~rst_n) begin
            command_length <= 2'b00;
            hold_command <= 1'b1;
            hold_program <= 1'b0;
        end
        else begin
            // Start fetching a new command
            if (new_program_address) begin
                command_length <= 2'b00;
                hold_program <= 1'b1;
                hold_command <= 1'b1;
            end
            // Fetch command bytes
            else if (hold_program) begin
                case (command_length)
                    2'b00: begin
                        program_data_address <= target_program_data_address;
                        command_length <= 2'b01;
                    end
                    2'b01: begin
                        command_mem[7:0] <= program_data_out;
                        program_data_address <= target_program_data_address + 7'd1;
                        command_length <= 2'b10;
                    end
                    2'b10: begin
                        command_mem[15:8] <= program_data_out;
                        program_data_address <= target_program_data_address + 7'd2;
                        command_length <= 2'b11;
                    end
                    2'b11: begin
                        command_mem[23:16] <= program_data_out;
                        command_length <= 2'b00;
                        hold_program <= 1'b0;
                        hold_command <= 1'b0;
                    end
                endcase
            end
        end
    end

`ifdef SYNTH
    // Tiny Tapeout's FPGA workflow defines SYNTH.
    reg [7:0] fpga_program [0:127];  // 128×8 program memory
    reg [7:0] fpga_data [0:63];      // 64×8 data memory
    reg [7:0] fpga_q1, fpga_q2;

    always @(posedge clk) begin
        if (!rst_n) begin
            fpga_q1 <= 8'h00;
            fpga_q2 <= 8'h00;
        end else if (ena) begin
            if (program_write_enable) begin
                fpga_program[program_data_address] <= uio_in;
            end else begin
                fpga_q1 <= fpga_program[program_data_address];
            end

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
    wire VPWR;
    wire VGND;

    // ------------------------------------------------------------------------
    // HOLD-TIMING FIX (GF180MCU Standard-Cell Delay Buffers)
    //
    // Explicit standard-cell instantiation prevents Yosys/OpenROAD from
    // optimizing away the combinational delay needed to meet SRAM hold time.
    // ------------------------------------------------------------------------

    wire [6:0] sram_program_address;
    wire       sram_data_write_enable;

    // 7-bit delay buffer chain for sram1 address
    genvar i;
    generate
        for (i = 0; i < 7; i = i + 1) begin : gen_prog_addr_dly
            wire dly_mid;
            (* keep = "true" *)
            gf180mcu_fd_sc_mcu7t5v0__dlyb_1 u_dly_addr_1 (
                .I   (program_data_address[i]),
                .Z   (dly_mid),
                .VDD (VPWR),
                .VSS (VGND),
                .VNW (VPWR),
                .VPW (VGND)
            );
            (* keep = "true" *)
            gf180mcu_fd_sc_mcu7t5v0__dlyb_1 u_dly_addr_2 (
                .I   (dly_mid),
                .Z   (sram_program_address[i]),
                .VDD (VPWR),
                .VSS (VGND),
                .VNW (VPWR),
                .VPW (VGND)
            );
        end
    endgenerate

    // 1-bit delay buffer chain for sram2 write enable
    wire we_dly_mid;
    (* keep = "true" *)
    gf180mcu_fd_sc_mcu7t5v0__dlyb_1 u_dly_we_1 (
        .I   (data_write_enable),
        .Z   (we_dly_mid),
        .VDD (VPWR),
        .VSS (VGND),
        .VNW (VPWR),
        .VPW (VGND)
    );
    (* keep = "true" *)
    gf180mcu_fd_sc_mcu7t5v0__dlyb_1 u_dly_we_2 (
        .I   (we_dly_mid),
        .Z   (sram_data_write_enable),
        .VDD (VPWR),
        .VSS (VGND),
        .VNW (VPWR),
        .VPW (VGND)
    );

    // ------------------------------------------------------------------------
    // Program SRAM
    // ------------------------------------------------------------------------
    gf180mcu_fd_ip_sram__sram128x8m8wm1 sram1 (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~program_write_enable),
        .WEN  (8'h00),
        .A    (sram_program_address),
        .D    (uio_in),
        .Q    (program_data_out)
    );

    // ------------------------------------------------------------------------
    // Data SRAM
    // ------------------------------------------------------------------------
    gf180mcu_fd_ip_sram__sram64x8m8wm1 sram2 (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~sram_data_write_enable),
        .WEN  (8'h00),
        .A    (data_address),
        .D    (uio_in),
        .Q    (data_out)
    );

`else
    // RTL simulation uses the official Google/GlobalFoundries timing model.
    wire model_vdd = 1'b1;
    wire model_vss = 1'b0;

    gf180mcu_fd_ip_sram__sram128x8m8wm1 sram1 (
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

endmodule
