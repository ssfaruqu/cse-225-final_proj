
module file_write();
    int seed = 980; //NEED TO MANUALLY CHANGE SEED TO GET DIFFERENT FILES
    bit [31:0] sound_bound_r;
    bit [31:0] interleave_bound_r;
    int i, j, k;
    int fd;

    bit [31:0] test = $random(seed);
    
    initial begin
        sound_bound_r = $urandom_range(1,10);
        #10;
        interleave_bound_r = $urandom_range(1, 20);
        #10;
        $display("sound= %d, interleave= %d", sound_bound_r, interleave_bound_r);
    `ifdef VERILATOR
        fd = $fopen("test_A.hex", "wb");

        for (i=0; i < 10; i++) begin
            for(j=0; j < sound_bound_r; j++) begin
                test = $random();
                #10;
                $fdisplayh(fd, test[23:0]);
            end

            for(k=0; k < interleave_bound_r; k++) begin
                test = '0;
                #10;
                $fdisplayh(fd, test[23:0]);
            end

        end

        #10;
        $fclose(fd);
    `endif
    end
endmodule
