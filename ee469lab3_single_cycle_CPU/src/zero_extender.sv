module zero_extender #(parameter INPUT_WIDTH, parameter OUTPUT_WIDTH=64) (x, y);
    input logic [INPUT_WIDTH-1:0] x;
    output logic [OUTPUT_WIDTH-1:0] y;

    //          zero extend                    + input
    assign y = {{(OUTPUT_WIDTH-INPUT_WIDTH){1'b0}}, x};

endmodule

module zero_extender_tb();
    parameter  INPUT_WIDTH = 8; parameter OUTPUT_WIDTH = 16;
    logic [INPUT_WIDTH-1:0] x;
    logic [OUTPUT_WIDTH-1:0] y;

    zero_extender #(8, 16) dut (.*);

    initial begin
        x = 8'b10000000;
        #(100);
        $display("x: %b, y: %b", x, y);
    end
endmodule