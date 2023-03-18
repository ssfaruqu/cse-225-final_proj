module load
   (input [0:0] clk_i
   ,input [0:0] reset_i
   ,input [0:0] kpyd_A_i
   ,input [0:0] kpyd_B_i
   ,input [0:0] kpyd_3_i
   ,input [0:0] kpyd_6_i
   ,output [23:0] sound_o
   );

   // ALTER THESE VALUES TO MATCH THE FILE LINES OF LOADED IN FILES
   localparam depth_A = 58;
   localparam depth_B = 5;
   localparam depth_3 = 198;
   localparam depth_6 = 34;

   initial begin
    $readmemh("test_A.hex", mem_A);
    $readmemh("test_B.hex", mem_B);
    $readmemh("test_3.hex", mem_3);
    $readmemh("test_6.hex", mem_6);
   end

   // COUNTER BITWDTH, MEM DEPTH, AND LOOP BOUND DEPENDANT FILE LINE COUNT
   logic [23:0] mem_A [depth_A:0];
   logic [23:0] mem_B [depth_B:0];
   logic [23:0] mem_3 [depth_3:0];
   logic [23:0] mem_6 [depth_6:0];

   wire [3:0] one_hot_w;
   assign one_hot_w = {kpyd_A_i, kpyd_B_i, kpyd_3_i, kpyd_6_i};

   logic [$clog2(depth_A)-1:0] counter_A_l;
   logic [$clog2(depth_B)-1:0] counter_B_l;
   logic [$clog2(depth_3)-1:0] counter_3_l;
   logic [$clog2(depth_6)-1:0] counter_6_l;
   
   logic [23:0] sound_l;
   assign sound_o = sound_l;

   always_ff @(posedge clk_i) begin
    if(reset_i) begin
        sound_l <= '0;
        counter_A_l <= '0;
        counter_B_l <= '0;
        counter_3_l <= '0;
        counter_6_l <= '0;
    end else begin
        case(one_hot_w)
            4'b1000: sound_l <= mem_A[counter_A_l];
            4'b0100: sound_l <= mem_B[counter_B_l];
            4'b0010: sound_l <= mem_3[counter_3_l];
            4'b0001: sound_l <= mem_6[counter_6_l];
            default: sound_l <= sound_l;
        endcase

        case(one_hot_w)
            4'b1000: begin
                if(counter_A_l < depth_A) begin
                    counter_A_l <= counter_A_l + 1;
                end else begin
                    counter_A_l <= '0;
                end

                counter_B_l <= '0;
                counter_3_l <= '0;
                counter_6_l <= '0;
            end
            4'b0100: begin
                if(counter_B_l < depth_B) begin
                    counter_B_l <= counter_B_l + 1;
                end else begin
                    counter_B_l <= '0;
                end

                counter_A_l <= '0;
                counter_3_l <= '0;
                counter_6_l <= '0;
            end
            4'b0010: begin
                if(counter_3_l < depth_3) begin
                    counter_3_l <= counter_3_l + 1;
                end else begin
                    counter_3_l <= '0;
                end

                counter_A_l <= '0;
                counter_B_l <= '0;
                counter_6_l <= '0;
            end
            4'b0001: begin
                if(counter_6_l < depth_6) begin
                    counter_6_l <= counter_6_l + 1;
                end else begin
                    counter_6_l <= '0;
                end

                counter_A_l <= '0;
                counter_B_l <= '0;
                counter_3_l <= '0;
            end
            default begin
                counter_A_l <= '0;
                counter_B_l <= '0;
                counter_3_l <= '0;
                counter_6_l <= '0;
            end
        endcase
    end
   end



endmodule
