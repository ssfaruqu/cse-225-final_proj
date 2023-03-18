module sync
  (input [0:0] clk_i
  ,input [0:0] signal_i
  ,output [0:0] sync_o
  );

   wire signal_n_sync_r;
   wire signal_sync_r;

   dff
     #()
   sync_a
     (.clk_i(clk_i)
     ,.reset_i(1'b0)
     ,.d_i(signal_i)
     ,.q_o(signal_n_sync_r));

   inv
     #()
   inv
     (.a_i(signal_n_sync_r)
     ,.b_o(signal_sync_r));

   dff
     #()
   sync_b
     (.clk_i(clk_i)
     ,.reset_i(1'b0)
     ,.d_i(signal_sync_r)
     ,.q_o(sync_o));

endmodule