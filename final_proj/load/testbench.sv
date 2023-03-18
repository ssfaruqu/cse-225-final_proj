`timescale 1ns/1ps
module testbench();

   localparam depth_A = 58;
   localparam depth_B = 34;
   logic [23:0] mem_A [depth_A:0];
   logic [23:0] mem_B [depth_B:0];
   
   wire [0:0]  clk_i;
   wire [0:0]  reset_i;
   logic [0:0]  kpyd_A_i = 0;
   logic [0:0]  kpyd_B_i = 0;
   wire [23:0] sound_o;

   wire [0:0] error_B_o;
   wire [0:0] error_A_o;
   logic [0:0] error_o;
   logic [5:0] counter_A_l;
   logic [5:0] counter_B_l;
   logic [23:0] correct_sound_A;
   logic [23:0] correct_sound_B;

   assign error_A_o = (sound_o !== mem_A[counter_A_l]); 
   assign error_B_o = (sound_o !== mem_B[counter_B_l]);

   int i;
   logic [1:0] test_vector [10:0];
   logic [1:0] val_r;
   initial begin
    test_vector[0] = 2'b01;
    test_vector[1] = 2'b01;
    test_vector[2] = 2'b01;
    test_vector[3] = 2'b10;
    test_vector[4] = 2'b11;
    test_vector[5] = 2'b10;
    test_vector[6] = 2'b10;
    test_vector[7] = 2'b10;
    test_vector[8] = 2'b01;
    test_vector[9] = 2'b01;
    test_vector[10] = 2'b00;
   end

   initial begin
    $readmemh("test_A.hex", mem_A);
    $readmemh("test_B.hex", mem_B);
   end

   nonsynth_clock_gen
     #(.cycle_time_p(10))
   cg
     (.clk_o(clk_i));

   nonsynth_reset_gen
     #(.num_clocks_p(1)
       ,.reset_cycles_lo_p(1)
       ,.reset_cycles_hi_p(10))
   rg
     (.clk_i(clk_i)
      ,.async_reset_o(reset_i));

    load #()
    dut
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     ,.kpyd_A_i(kpyd_A_i)
     ,.kpyd_B_i(kpyd_B_i)
     ,.kpyd_3_i(0)
     ,.kpyd_6_i(0)
     ,.sound_o(sound_o)
     );

     initial begin
`ifdef VERILATOR
      $dumpfile("verilator.fst");
`else
      $dumpfile("iverilog.vcd");
`endif
      $dumpvars;

      $display();
      
      $display("  ______          __  __                    __       __ ");
      $display(" /_  __/__  _____/ /_/ /_  ___  ____  _____/ /_     /   ");
      $display("  / / / _ \\/ ___/ __/ __ \\/ _ \\/ __ \\/ ___/ __      ");
      $display(" / / /  __(__  ) /_/ /_/ /  __/ / / / /__/ / / /  /     ");
      $display("/_/  \\___/____/\\__/_.___/\\___/_/ /_/\\___/_/ /       ");

      #10;
      $display("Begin Test:");
      $display();

      @(negedge reset_i);

      for(i= 0; i < 11; i++) begin
         val_r = test_vector[i];
         kpyd_A_i = val_r[1];
         kpyd_B_i = val_r[0];

         #10;
         if(kpyd_A_i & (~kpyd_B_i))begin
           error_o = error_A_o;
         end else begin
            if((~kpyd_A_i) & kpyd_B_i) begin
              error_o = error_B_o;
            end
         end

         $display("[%d] sound_o= %h, kpyd_A_i= %b, kpyd_b_i= %b", i, sound_o, kpyd_A_i, kpyd_B_i);
         if(error_o) begin
           if(kpyd_A_i & (~kpyd_B_i))begin
             $display("Got %h, but should be %h, counter_A_l= %d", sound_o, mem_A[counter_A_l], counter_A_l);
           end else begin
            if((~kpyd_A_i) & kpyd_B_i) begin
             $display("Got %h, but should be %h, counter_B_l= %d", sound_o, mem_B[counter_B_l], counter_B_l);
            end
         end
        
           $finish();
         end
      end

      $finish();
     end

     always_ff @(posedge clk_i) begin
        if(kpyd_A_i & (~kpyd_B_i))begin
           if(counter_A_l < depth_A) begin
                counter_A_l <= counter_A_l + 1;
           end else begin
                counter_A_l <= '0;
           end

           counter_B_l <= '1; //Will roll over back to 0 when starts counting
           correct_sound_A <= mem_A[counter_A_l];
         end else begin

          if((~kpyd_A_i) & kpyd_B_i) begin
            if(counter_B_l < depth_B) begin
                  counter_B_l <= counter_B_l + 1;
            end else begin
                  counter_B_l <= '0;
            end

            counter_A_l <= '1; //Will roll over back to 0 when starts counting
            correct_sound_B <= mem_B[counter_B_l];
          end
         end
        
        if(kpyd_A_i & kpyd_B_i) begin
          counter_A_l <= '1;
          counter_B_l <= '1;
        end
        if(~kpyd_A_i & ~kpyd_B_i) begin
          counter_A_l <= '1;
          counter_B_l <= '1;
        end

     end

     final begin
        $display("Simulation time is %t", $time);
        if(error_o) begin
	        $display("\033[0;31m    ______                    \033[0m");
	        $display("\033[0;31m   / ____/_____________  _____\033[0m");
	        $display("\033[0;31m  / __/ / ___/ ___/ __ \\/ ___/\033[0m");
	        $display("\033[0;31m / /___/ /  / /  / /_/ / /    \033[0m");
	        $display("\033[0;31m/_____/_/  /_/   \\____/_/     \033[0m");
	        $display();
	        $display("Simulation Failed");
     end else begin
	    $display("\033[0;32m    ____  ___   __________\033[0m");
	    $display("\033[0;32m   / __ \\/   | / ___/ ___/\033[0m");
	    $display("\033[0;32m  / /_/ / /| | \\__ \\\__ \ \033[0m");
	    $display("\033[0;32m / ____/ ___ |___/ /__/ / \033[0m");
	    $display("\033[0;32m/_/   /_/  |_/____/____/  \033[0m");
	    $display();
	    $display("Simulation Succeeded!");
      end
   end
endmodule
