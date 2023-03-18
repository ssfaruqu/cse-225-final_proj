// PROVIDED BY THE INSTRUCTORS OF UCSC CSE 225, SPRING 2023
`define NULL 0 
`ifndef WIDTH
 `define WIDTH 8
`endif
`ifndef DEPTH
 `define DEPTH 16
`endif
module testbench();
   parameter in_reset = 3'h0,
             out_of_reset = 3'h1,
             write = 3'h3,
             start_read = 3'h2,
             read = 3'h6,
             write_read = 3'h7,
             done = 3'h5;

   logic [0:0] reset_done = 1'b0;

   wire [0:0]  clk_i;
   wire [0:0]  reset_i;
   logic [31:0] error_counter_o;
   
   logic [7:0]  test_wdata_mem1, test_rdata_mem1, test_rdata_mem1_reg, reset_initial;
   logic [31:0] test_wdata_mem2  = 32'hA55Af0f0, test_rdata_mem2;
   
   logic [3:0]  test_addr_mem1;
   logic [3:0]  test_addr_mem2  = '0;
   
   logic        test_validw_mem1, test_validw_mem2;


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

   ram_1r1w_sync
     #( .width_p (`WIDTH)
        , .depth_p (`DEPTH)
        , .filename_p ("memory_init_file.hex") )
   ram1 ( .clk_i (clk_i)
          , .reset_i (reset_i)
          , .wr_valid_i (test_validw_mem1) 
          , .wr_data_i (test_wdata_mem1)
          , .wr_addr_i (test_addr_mem1)
          , .rd_addr_i (test_addr_mem1)
          , .rd_data_o (test_rdata_mem1)
          );
   
   reg [2:0]    next_state, state;
   integer      mem_file, scan_inputs;
   always_ff @ (posedge clk_i)
     begin
        test_rdata_mem1_reg <= test_rdata_mem1;
  	/*test_wdata_mem1  = 8'hA5;
  	 test_addr_mem1  = '0;
  	 test_validw_mem1 = '0;*/
  	/* verilator lint_off CASEINCOMPLETE */
  	case (state)
  	  in_reset :
  	    begin
  	       test_wdata_mem1  <= 8'hA5;
  	       test_addr_mem1  <= '0;
  	       test_validw_mem1 <= '0;	
  	       error_counter_o <= '0;
  	       //reset_initial = 8'h0f;		
  	    end
  	  out_of_reset : 
  	    begin
  	       //reset_initial <= reset_initial - 1;
  	       /*if (!$feof(mem_file))
  		scan_inputs = $fscanf(mem_file, "%h\n", reset_initial);
  		if (test_rdata_mem1 != reset_initial)
  		begin
  		error_counter_o <= error_counter_o + 1;
  		$error("\033[0;31mError!\033[0m: test_rdata_mem1 should be %h, got %h, not returning reset data\n", reset_initial, test_rdata_mem1);
  						end
  		test_addr_mem1  <= test_addr_mem1 + 1'h1;*/
  	       if (next_state == write)
  		 begin
  		    test_validw_mem1 <= '1;		
  		    test_wdata_mem1  <= 8'hA5;	
  		 end	
  	    end
  	  write : 
  	    begin
  	       test_addr_mem1  <= test_addr_mem1 + 1'h1;
  	       test_wdata_mem1 <= test_wdata_mem1 ^ 8'hff;
  	       if (next_state == start_read)
  	         begin
  		    test_validw_mem1 <= '0;
  		 end
  	    end
  	  start_read :
  	    begin
  	       test_addr_mem1  <= test_addr_mem1 + 1;
  	    end
  	  read :
  	    begin
  	       test_addr_mem1  <= test_addr_mem1 + 1;
  	       if (test_addr_mem1 == 4'h0)
  	       	 begin
  	            // do nothing
  	       	 end
  	       else if (test_addr_mem1 == 4'h1)
  	       	 begin
  	       	    if (test_rdata_mem1 !== 8'ha5 )
  		      begin
  		    	 error_counter_o <= error_counter_o + 1;
  		    	 $error("\033[0;31mError!\033[0m: test_rdata_mem1 should be %h, got %h, not returning the last written value\n", 8'ha5, test_rdata_mem1);
  	       	      end
  	       	 end
  	       else if (test_rdata_mem1 !== (test_rdata_mem1_reg ^ 8'hff) )
  		 begin
  		    error_counter_o <= error_counter_o + 1;
  		    $error("\033[0;31mError!\033[0m: test_rdata_mem1 should be %h, got %h, not returning the last written value\n", test_rdata_mem1_reg ^ 8'hff, test_rdata_mem1);
  	    	 end
  	    end
  	  write_read : 
  	    begin
  	       test_addr_mem1  <= test_addr_mem1 + 1'h1;
  	       test_wdata_mem1 <= 8'h00;
  	       if (test_wdata_mem1 === test_rdata_mem1)
  		 begin
  		    error_counter_o <= error_counter_o + 1;
  		    $error("\033[0;31mError!\033[0m: test_rdata_mem1 should not be %h, got %h, returning write of same CC\n", test_wdata_mem1, test_rdata_mem1);
  		 end
  	    end
  	  done :
  	    $finish;
  	endcase
  	/* verilator lint_on CASEINCOMPLETE */
     end
   
   always_ff @ (posedge clk_i)
     begin
	state <= next_state;
     end
   
   always_comb
     begin
  	if (reset_i)
  	  next_state = in_reset;
  	else
  	  begin
  	     next_state = state;
  	     /* verilator lint_off CASEINCOMPLETE */
  	     case (state)
  	       in_reset : next_state = out_of_reset;
  	       out_of_reset :
  		 begin
  		    //if (test_addr_mem1 == 'hf)
  		    next_state = write;
  		 end
  	       write :
  		 begin
  		    if (test_addr_mem1 == 'hf)
  		      next_state = start_read;
  		 end
  	       start_read : next_state = read;
  	       read : 
  		 begin
  		    if (test_addr_mem1 == 'hf)
  		      next_state = write_read;
  		 end
  	       write_read : 
  		 begin
  		    if (test_addr_mem1 == 'hf)
  		      next_state = done;
  		 end
  	     endcase
  	     /* verilator lint_on CASEINCOMPLETE */
  	  end
     end

   initial begin
`ifdef VERILATOR
      $dumpfile("verilator.fst");
`else
      $dumpfile("iverilog.vcd");
`endif
      $dumpvars;

      mem_file = $fopen("memory_init_file.hex", "r");
      if (mem_file == `NULL) begin
    	 $display("mem_file handle was NULL");
    	 $finish;
      end

      $display();
      $display("  ______          __  __                    __                                ___    ___                                   ");
      $display(" /_  __/__  _____/ /_/ /_  ___  ____  _____/ /_     _________ _____ ___      <  /___<  /      __     _______  ______  _____");
      $display("  / / / _ \\/ ___/ __/ __ \\/ _ \\/ __ \\/ ___/ __ \\   / ___/ __ `/ __ `__ \\     / / ___/ / | /| / /    / ___/ / / / __ \\/ ___/");
      $display(" / / /  __(__  ) /_/ /_/ /  __/ / / / /__/ / / /  / /  / /_/ / / / / / /    / / /  / /| |/ |/ /    (__  ) /_/ / / / / /__  ");
      $display("/_/  \\___/____/\\__/_.___/\\___/_/ /_/\\___/_/ /_/  /_/   \\__,_/_/ /_/ /_/____/_/_/  /_/ |__/|__/____/____/\\__, /_/ /_/\\___/  ");
      $display("                                                                     /_____/                /_____/    /____/              ");

      $display();
      $display("Begin Test:");

      @(negedge reset_i);

      reset_done = 1;
      /* verilator lint_off STMTDLY */
      //	#1500;
      /* verilator lint_on STMTDLY */
      //$finish();
   end

   final begin
      $display("Simulation time is %t", $time);
      if(error_counter_o != '0) begin
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

