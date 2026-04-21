module cpu_single_cycle (clk, reset, alu_out);
    input logic clk, reset;
    output logic [63:0] alu_out;
    logic [63:0] pc_out, pc_plus4, shifter_out, br_adder_out, pc_mux_out; // pc related signals
    logic [31:0] instruction;
    logic [63:0] rd_addr2, rd_data1, rd_data2, wr_data; // regfile signals
    logic [63:0] sign_extender_out, shifter_out, alu_B, alu_out, datamem_out;



    program_counter pc (.clk(clk), .reset(reset), .data_in(pc_mux_out), .data_out(pc_out));

    // dedicated adder to add 4 every cycle to the program counter
    pc_adder pc_add (.A(pc_out), .sum(pc_plus4));

    shifter shifter (.value(sign_extender_out), .direction(1'd0), .distance(2'd2), .result(shifter_out));

    // 64-bit adder to determine the branch address in bytes: PC=PC+(4*[branch address--in instruction count])
    branch_adder br_add (.A(pc_out), .B(shifter_out), .sum(br_adder_out));

    // 2:1 mux to choose between PC+4 and branch address
    mux2_1 pc_mux (.y(pc_mux_out), .x({br_adder_out, pc_plus4}), .sel(CONTROL));

    instructmem instr_mem (.address(pc_out), .instruction(instruction), .clk(clk));

    // 2:1 mux to choose between Rm and Rd to go into 2nd read address
    mux5x2_1 rd_data2_mux (.y(rd_addr2), .x({instruction[20:16], instruction[4:0]}), .sel(CONTROL));

    regfile reg_file (.ReadRegister1(instruction[9:5]), .ReadRegister2(rd_addr2), .WriteRegister(instruction[4:0]),
                      .WriteData(MUX_OUT_3), .RegWrite(CONTROL), .clk(clk), .ReadData1(rd_data1), .ReadData2(rd_data2));

    sign_extender sign_ex ();

    mux64x2_1 alu_mux (.y(alu_B), .x({sign_extender_out, rd_data2}), .sel(CONTROL));

    alu alu (.A(rd_data1), .B(alu_B), .cntrl(CONTROL), .result(alu_out),
             .negative(CONTROL), .zero(CONTROL), .overflow(CONTROL), .carry_out(CONTROL));
    
    datamem datamem (.address(alu_out), .write_enable(CONTROL), .read_enable(CONTROL), .write_data(rd_data2),
                     .clk(clk), .xfer_size(4'd8), read_data(datamem_out));

    mux64x2_1 wr_data_mux (.y(wr_data), .x({datamem_out, alu_out}), .sel(CONTROL));

    







endmodule