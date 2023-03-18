`timescale 1ns/1ps
module testbench();

   wire [0:0]  clk_i;
   wire [0:0]  reset_i;
   logic [0:0] press_i = 0;
   wire [0:0] debouncer_o;

   logic [9:0] debounce_counter_r = 0;
   logic [0:0] error_o;

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

    debouncer #()
    dut
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     ,.press_i(press_i)
     ,.debouncer_o(debouncer_o)
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

      //TEST COUNTING UP
      press_i = 1;

      while (debounce_counter_r < 10'b1111111111) begin
         debounce_counter_r = debounce_counter_r + 1;
         #10;

         $display("debounce_counter= %b, debouncer_o= %b", debounce_counter_r, debouncer_o);
      end

      #10;
      $display("debounce_counter= %b, debouncer_o= %b", debounce_counter_r, debouncer_o);
      if(debouncer_o !== 1) begin
         error_o = 1;
         $display("debounce_o= %b, but should be 1", debouncer_o);
         $finish();
      end


      //TEST COUNTING DOWN
      press_i = 0;

      while (debounce_counter_r > 0) begin
         debounce_counter_r = debounce_counter_r - 1;
         #10;

         $display("debounce_counter= %b, debouncer_o= %b", debounce_counter_r, debouncer_o);
      end

      #10;
      $display("debounce_counter= %b, debouncer_o= %b", debounce_counter_r, debouncer_o);
      if(debouncer_o !== 0) begin
         error_o = 1;
         $display("debouncer_o= %b, but should be 0", debouncer_o);
         $finish();
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