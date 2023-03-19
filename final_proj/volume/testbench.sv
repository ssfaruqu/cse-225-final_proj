`timescale 1ns/1ps
module testbench();

   wire [0:0]  clk_i;
   wire [0:0]  reset_i;
   logic [23:0]  sound_i = '0;
   logic [0:0] up_i = 0;
   logic [0:0] down_i = 0;
   wire [23:0] sound_o;
   logic [2:0] counter_r = 3'b011;

   wire [0:0] error_o;
   wire [23:0] correct_sound_o;
   assign correct_sound_o = sound_i >> counter_r;
   assign error_o = (sound_o != correct_sound_o); 

   int i;
   logic [1:0] test_vector [11:0];
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
    test_vector[10] = 2'b10;
    test_vector[11] = 2'b00;
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

    volume #()
    dut
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     ,.sound_i(sound_i)
     ,.up_i(up_i)
     ,.down_i(down_i)
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
      
      $display("  ______          __  __                    __        ");
      $display(" /_  __/__  _____/ /_/ /_  ___  ____  _____/ /_       ");
      $display("  / / / _ \\/ ___/ __/ __ \\/ _ \\/ __ \\/ ___/ __    ");
      $display(" / / /  __(__  ) /_/ /_/ /  __/ / / / /__/ / / /  /   ");
      $display("/_/  \\___/____/\\__/_.___/\\___/_/ /_/\\___/_/ /     ");

      #10;
      $display("Begin Test:");
      $display();

      @(negedge reset_i);

      for(i= 0; i < 12; i++) begin
         val_r = test_vector[i];
         up_i = val_r[0];
         down_i = val_r[1];

         #10;

         $display("[%d] sound_i= %h, sound_o= %h, up_i= %b, down_i= %b, counter_r= %d", i, sound_i, sound_o, up_i, down_i, counter_r);
         if(error_o) begin
            $display("Got %h, but should have been %h", sound_o, correct_sound_o);
            $finish();
         end

         sound_i = (sound_i + 1) * 2;
      end

      $finish();
     end

     always_ff @(posedge clk_i) begin
      case({up_i, down_i})
            2'b10: begin
                if(counter_r < 7) begin
                    counter_r = counter_r + 1;
                end
            end
            2'b01: begin
                if(counter_r > 1) begin
                    counter_r = counter_r - 1;
                end
            end
            default: counter_r = counter_r;
         endcase
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