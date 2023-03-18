// Top-level design file for the icebreaker FPGA board
module top
  (input [0:0] clk_12mhz_i
  // n: Negative Polarity (0 when pressed, 1 otherwise)
  // async: Not synchronized to clock
  // unsafe: Not De-Bounced
  ,input [0:0] reset_n_async_unsafe_i
  // async: Not synchronized to clock
  // unsafe: Not De-Bounced
  ,input [3:1] button_async_unsafe_i

  // Line Out (Green)
  // Main clock (for synchronization)
  ,output tx_main_clk_o
  // Selects between L/R channels, but called a "clock"
  ,output tx_lr_clk_o
  // Data clock
  ,output tx_data_clk_o
  // Output Data
  ,output tx_data_o

  // Line In (Blue)
  // Main clock (for synchronization)
  ,output rx_main_clk_o
  // Selects between L/R channels, but called a "clock"
  ,output rx_lr_clk_o
  // Data clock
  ,output rx_data_clk_o
  // Input data
  ,input  rx_data_i

  ,input [3:0] kpyd_row_i
  ,output [3:0] kpyd_col_o

  ,output [5:1] led_o
  );

   wire reset_n_sync_r;
   wire reset_sync_r;
   wire reset_r; // Use this as your reset_signal

   dff
     #()
   sync_a
     (.clk_i(clk_o)
     ,.reset_i(1'b0)
     ,.d_i(reset_n_async_unsafe_i)
     ,.q_o(reset_n_sync_r));

   inv
     #()
   inv
     (.a_i(reset_n_sync_r)
     ,.b_o(reset_sync_r));

   dff
     #()
   sync_b
     (.clk_i(clk_o)
     ,.reset_i(1'b0)
     ,.d_i(reset_sync_r)
     ,.q_o(reset_r));
       
   wire [23:0] axis_tx_data;
   wire        axis_tx_valid;
   wire        axis_tx_ready;
   wire        axis_tx_last;
   
   wire [23:0] axis_rx_data;
   wire        axis_rx_valid;
   wire        axis_rx_ready;
   wire        axis_rx_last;
   wire        clk_o;

  SB_PLL40_PAD 
    #(.FEEDBACK_PATH("SIMPLE")
     ,.PLLOUT_SELECT("GENCLK")
     ,.DIVR(4'b0000)
     ,.DIVF(7'b1000011)
     ,.DIVQ(3'b101)
     ,.FILTER_RANGE(3'b001)
     )
   pll_inst
     (.PACKAGEPIN(clk_12mhz_i)
     ,.PLLOUTCORE(clk_o)
     ,.RESETB(1'b1)
     ,.BYPASS(1'b0)
     );
  
   assign axis_clk = clk_o;

   axis_i2s2 
     #()
   i2s2_inst
     (.axis_clk(axis_clk)
     ,.axis_resetn(~reset_r)
      
     ,.tx_axis_c_data(axis_tx_data)
     ,.tx_axis_c_valid(axis_tx_valid)
     ,.tx_axis_c_ready(axis_tx_ready)
     ,.tx_axis_c_last(axis_tx_last)
     
     ,.rx_axis_p_data(axis_rx_data)
     ,.rx_axis_p_valid(axis_rx_valid)
     ,.rx_axis_p_ready(axis_rx_ready)
     ,.rx_axis_p_last(axis_rx_last)
     
     ,.tx_mclk(tx_main_clk_o)
     ,.tx_lrck(tx_lr_clk_o)
     ,.tx_sclk(tx_data_clk_o)
     ,.tx_sdout(tx_data_o)
     ,.rx_mclk(rx_main_clk_o)
     ,.rx_lrck(rx_lr_clk_o)
     ,.rx_sclk(rx_data_clk_o)
     ,.rx_sdin(rx_data_i)
     );

     wire [3:0] kpyd_signal_w;
     wire [0:0] kpyd_valid_w;
     wire [23:0] final_data_w;
     wire [23:0] sound_w;
     logic [0:0] mute_r = 1;
     logic [0:0] vol_down_r = 0;
     logic [0:0] vol_up_r = 0;
     logic [3:0] key_on_r = '0;
     wire [0:0] kpyd_A_w = (kpyd_signal_w == 4'b1010); // File A
     wire [0:0] kpyd_B_w = (kpyd_signal_w == 4'b1011); // File B
     wire [0:0] kpyd_3_w = (kpyd_signal_w == 4'b0011); // File 3
     wire [0:0] kpyd_6_w = (kpyd_signal_w == 4'b0110); // File 6
     wire [0:0] kpyd_C_w = (kpyd_signal_w == 4'b1100); // Mute
     wire [0:0] kpyd_D_w = (kpyd_signal_w == 4'b1101); // Volume Up 
     wire [0:0] kpyd_E_w = (kpyd_signal_w == 4'b1110); // Volume Down

     always_ff @(posedge axis_clk) begin
          if(kpyd_valid_w & kpyd_C_w) begin
            mute_r <= ~mute_r;
          end

          if(kpyd_valid_w & kpyd_A_w) begin
            key_on_r[0] <= ~key_on_r[0];
            key_on_r[1] <= 0;
            key_on_r[2] <= 0;
            key_on_r[3] <= 0;
          end

          if(kpyd_valid_w & kpyd_B_w) begin
            key_on_r[1] <= ~key_on_r[1];
            key_on_r[0] <= 0;
            key_on_r[2] <= 0;
            key_on_r[3] <= 0;
          end

          if(kpyd_valid_w & kpyd_3_w) begin
            key_on_r[2] <= ~key_on_r[2];
            key_on_r[0] <= 0;
            key_on_r[1] <= 0;
            key_on_r[3] <= 0;
          end

          if(kpyd_valid_w & kpyd_6_w) begin
            key_on_r[3] <= ~key_on_r[3];
            key_on_r[0] <= 0;
            key_on_r[1] <= 0;
            key_on_r[2] <= 0;
          end

          if(kpyd_valid_w & kpyd_D_w) begin
            vol_up_r <= 1;
          end else begin
            vol_up_r <= 0;
          end

          if(kpyd_valid_w & kpyd_E_w) begin
            vol_down_r <= 1;
          end else begin
            vol_down_r <= 0;
          end
     end
     
     debounced_kpyd #()
     kpyd_inst
      (.clk_i(axis_clk)
      ,.reset_i(reset_r)
      ,.kpyd_row_i(kpyd_row_i)
      ,.kpyd_col_o(kpyd_col_o)
      ,.valid_o(kpyd_valid_w)
      ,.led_o(led_o[2:1]) // USED FOR DEBUGGING PURPOSES
      ,.symbol_o(kpyd_signal_w));

     load #()
     load_inst
      (.clk_i(axis_clk)
      ,.reset_i(reset_r)
      ,.kpyd_A_i(key_on_r[0])
      ,.kpyd_B_i(key_on_r[1])
      ,.kpyd_3_i(key_on_r[2])
      ,.kpyd_6_i(key_on_r[3])
      ,.sound_o(sound_w)
      );

     volume #()
     volume_inst
      (.clk_i(axis_clk)
      ,.reset_i(reset_r)
      ,.sound_i(sound_w)
      ,.up_i(vol_down_r)
      ,.down_i(vol_up_r)
      ,.sound_o(final_data_w)
      );

     fifo_1r1w #(.width_p(25))
     fifo_1r1w_inst
      (.clk_i(axis_clk)
      ,.reset_i(reset_r)
      
      ,.data_i({axis_rx_last, final_data_w})
      ,.valid_i(mute_r)
      ,.ready_o(axis_rx_ready)

      ,.valid_o(axis_tx_valid)
      ,.data_o({axis_tx_last, axis_tx_data})
      ,.yumi_i(mute_r)
      );

endmodule
