module fifo_1r1w
 #(parameter [31:0] width_p = 10
  ,parameter [31:0] depth_p = 20
  ) 
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [width_p - 1:0] data_i
  ,input [0:0] valid_i
  ,output [0:0] ready_o 

  ,output [0:0] valid_o 
  ,output [width_p - 1:0] data_o 
  ,input [0:0] yumi_i
  );

  logic [0:0] ready_r;
  logic [0:0] valid_r;

  assign ready_o = ready_r;
  assign valid_o = valid_r;
  
  always_ff @(posedge clk_i) begin
    if(reset_i) begin
      ready_r <= '1;
      valid_r <= '0;
    end else begin
      if(yumi_i & valid_o) begin //once yumi-valid handshake done, set valid_r low 
        valid_r <= 1'b0;
      end else begin
        if(rd_addr_ptr_r != wr_addr_ptr_r) begin //if FIFO isn't empty
          valid_r <= 1'b1;
        end
      end


      if(valid_i & ready_o) begin //once ready-valid handshake done, set ready_r low
        ready_r <= 1'b0;
      end else begin
        if(rd_addr_ptr_r != wr_addr_ptr_r + 1) begin //if the FIFO isn't full
          ready_r <= 1'b1;
        end
      end
    end
  end

  logic [$clog2(depth_p) - 1 : 0] wr_addr_ptr_r; 
  logic [$clog2(depth_p) - 1 : 0] rd_addr_ptr_r;
  wire [31:0] rd_addr_compare_w;
  assign rd_addr_compare_w [$clog2(depth_p) - 1 : 0] = rd_addr_ptr_r;
  assign rd_addr_compare_w [31 : $clog2(depth_p)] = '0;
  wire [31:0] wr_addr_compare_w;
  assign wr_addr_compare_w [$clog2(depth_p) - 1 : 0] = wr_addr_ptr_r;
  assign wr_addr_compare_w [31 : $clog2(depth_p)] = '0;

  always_ff @(posedge clk_i) begin
    if(reset_i) begin
      rd_addr_ptr_r <= '0;
      wr_addr_ptr_r <= '0;
    end else begin
      if(yumi_i & valid_o) begin // IF ALLOWED TO POP FIFO
        case(rd_addr_compare_w >= depth_p-1)
          1: rd_addr_ptr_r <= '0; //if at max depth, loop back around
          default: rd_addr_ptr_r <= rd_addr_ptr_r + 1;
        endcase
      end

      if(valid_i & ready_o) begin // IF ALLOWED TO QUEUE FIFO
        case(wr_addr_compare_w >= depth_p-1)
          1: wr_addr_ptr_r <= '0; //if at max depth, loop back around
          default: wr_addr_ptr_r <= wr_addr_ptr_r + 1;
        endcase
      end
    end
  end 

  // USE FOR MEMORY 
  ram_1r1w_sync #(.width_p(width_p), .depth_p(depth_p))
  ram_1r1w_sync_inst
   (.clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.wr_valid_i(valid_i & ready_r)
    ,.wr_data_i(data_i)
    ,.wr_addr_i(wr_addr_ptr_r)

    ,.rd_addr_i(rd_addr_ptr_r)
    ,.rd_data_o(data_o)
    );

endmodule

