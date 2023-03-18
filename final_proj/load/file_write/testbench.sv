//NOT REALLY A TESTBENCH, JUST USED TO COMPILE AND RUN file_write

`timescale 1ns/1ps
module testbench();

    int i;

    file_write #()
    file_write_inst();

    initial begin
        for(i = 0; i < 200; i++) begin
            #10;
        end
        $finish();
    end
endmodule
