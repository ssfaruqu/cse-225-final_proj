`timescale 1ns/1ps
module testbench();

   wire [0:0]  clk_i;
   wire [0:0]  reset_i;
   logic [0:0] debounce_i = 0;
   wire [0:0] edge_o;

   logic [0:0] error_o;
   logic [1:0] state_counter_r = '0;

   assign error_o = (edge_o !== state_counter_r[0]); 

   int i;
   logic [0:0] test_vector [20:0];
   initial begin
    test_vector[0] = 1;
    test_vector[1] = 1;
    test_vector[2] = 1;
    test_vector[3] = 1;
    test_vector[4] = 1;
    test_vector[5] = 0;
    test_vector[6] = 0;
    test_vector[7] = 0;
    test_vector[8] = 0;
    test_vector[9] = 0;
    test_vector[10] = 1;
    test_vector[11] = 1;
    test_vector[12] = 0;
    test_vector[13] = 0;
    test_vector[14] = 1;
    test_vector[15] = 0;
    test_vector[16] = 1;
    test_vector[17] = 1;
    test_vector[18] = 0;
    test_vector[19] = 0;
    test_vector[20] = 1;
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

    edge_state_machine #()
    dut
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     ,.debounce_i(debounce_i)
     ,.edge_o(edge_o)
     );

     initial begin
`ifdef VERILATOR
      $dumpfile("verilator.fst");
`else
      $dumpfile("iverilog.vcd");
`endif
      $dumpvars;

      $display();
      
      $display("  ______          __  __                    __        ");
      $display(" /_  __/__  _____/ /_/ /_  ___  ____  _____/ /_       ");
      $display("  / / / _ \\/ ___/ __/ __ \\/ _ \\/ __ \\/ ___/ __    ");
      $display(" / / /  __(__  ) /_/ /_/ /  __/ / / / /__/ / / /  /   ");
      $display("/_/  \\___/____/\\__/_.___/\\___/_/ /_/\\___/_/ /     ");

      #10;
      $display("Begin Test:");
      $display();

      @(negedge reset_i);

      for(i = 0; i < 21; i++) begin
         debounce_i = test_vector[i];
         if(debounce_i) begin
            if(state_counter_r < 2) begin
               state_counter_r = state_counter_r + 1;
            end
         end else begin
            state_counter_r = '0;
         end
         #10;

         $display("[%d] debounce_i= %b, edge_o= %b", i, debounce_i, edge_o);
         if(error_o) begin
            $display("edge_o should be %b, but got %b", state_counter_r[0], edge_o);
            $finish();
         end
      end
      

      $finish();
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