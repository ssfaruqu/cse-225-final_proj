module edge_state_machine
  (input [0:0] clk_i
  ,input [0:0] reset_i
  ,input [0:0] debounce_i
  ,output [0:0] edge_o
  );
  enum logic [1:0] { wait_s = 2'b00,
                      edge_s = 2'b01,
                      hold_s = 2'b10
                    }
              edge_r, edge_n;
  
  assign edge_o = edge_r[0];

  // EDGE DETECTION STATE MACHINE CODE
   always_ff @(posedge clk_i) begin
     if(reset_i) begin
       edge_r <= wait_s;
     end else begin
       edge_r <= edge_n;
     end
   end

   always_comb begin
     edge_n = edge_r;
     
     case(edge_n)
      wait_s: begin
        if(debounce_i) begin 
          edge_n = edge_s;
        end
      end
      edge_s: begin
        if(debounce_i) begin
          edge_n = hold_s;
        end else begin
          edge_n = wait_s;
        end
      end
      hold_s: begin
        if(debounce_i) begin
          edge_n = hold_s;
        end else begin
          edge_n = wait_s;
        end
      end
      default: edge_n = edge_n;
     endcase
   end
endmodule