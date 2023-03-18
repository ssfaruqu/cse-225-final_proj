module debouncer
  (input [0:0] clk_i
  ,input [0:0] reset_i
  ,input [0:0] press_i
  ,output [0:0] debouncer_o);

   logic [0:0] debounce_r;
   logic [9:0] debounce_counter_r;

   assign debouncer_o = debounce_r;

   always_ff @(posedge clk_i) begin
      if(reset_i) begin
        debounce_r <= '0;
        debounce_counter_r <= '0;
      end else begin
        if(press_i) begin
          case(debounce_counter_r)
            '1: debounce_r <= 1'b1;
            default: debounce_counter_r <= debounce_counter_r + 1;
          endcase
        end else begin
          case(debounce_counter_r)
            '0: debounce_r <= 1'b0;
            default: debounce_counter_r <= debounce_counter_r - 1;
          endcase
        end
      end
   end
    
endmodule