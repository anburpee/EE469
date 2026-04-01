// This module is an enabled D flip-flop with no reset.
module DFF_enabled (en, data_in, data_out);
    output logic data_out;
    input logic en, data_in;
    logic temp;

    always_ff begin
        temp <= data_in;
        data_out <= temp;
    end

endmodule //DFF_enabled