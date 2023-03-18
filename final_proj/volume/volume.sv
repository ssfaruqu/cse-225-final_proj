module volume
   (input [0:0] clk_i
   ,input [0:0] reset_i
   ,input [23:0] sound_i
   ,input [0:0] up_i
   ,input [0:0] down_i
   ,output [23:0] sound_o
   );

   logic [2:0] counter_r;
   wire [1:0] one_hot_w;
   assign one_hot_w = {up_i, down_i};
   assign sound_o = sound_i >> counter_r;
   
   always_ff @(posedge clk_i) begin
        if(reset_i) begin
            counter_r <= 3'b011;
        end else begin
            case(one_hot_w) 
                2'b10: begin
                    if(counter_r < 7) begin
                        counter_r <= counter_r + 1;
                    end
                end
                2'b01: begin
                    if(counter_r > 1) begin
                        counter_r <= counter_r - 1;
                    end
                end
                default: counter_r <= counter_r;
            endcase
        end
    end

endmodule
