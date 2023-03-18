module debounced_kpyd
  (input [0:0] clk_i
  ,input [0:0] reset_i
  ,input [3:0] kpyd_row_i
  ,output [3:0] kpyd_col_o
  ,output [0:0] valid_o
  ,output [2:1] led_o
  ,output [3:0] symbol_o);

  wire [0:0] all_debounce_w;
  wire [0:0] all_edge_w;
  wire [3:0] row_press_w;
  logic [3:0] symbol_r;
  logic [3:0] symbol_n;

  logic [7:0] kpyd_r;
  logic [7:0] kpyd_n;
  assign kpyd_col_o = kpyd_col_r;
  assign symbol_o = symbol_r;
  assign led_o[2] = (symbol_o == 4'b1110);
  assign valid_o = all_edge_w;

 enum logic [3:0] { init_s = 4'b1111,
               col1_s = 4'b1110,
               col2_s = 4'b1101,
               col3_s = 4'b1011,
               col4_s = 4'b0111,
             } 
             kpyd_col_n, kpyd_col_r;

  // SYNC ALL THE ROW INPUTS
  for (genvar i= 0; i < 4; i++) begin
    sync #()
    sync_inst
     (.clk_i(clk_i)
     ,.signal_i(kpyd_row_i[i])
     ,.sync_o(row_press_w[i])
     );
  end

  debouncer #()
  debouncer_inst
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.press_i(row_press_w != '0) //IF ANY BUTTON PRESSED
    ,.debouncer_o(all_debounce_w)
    );

  edge_state_machine #()
  edge_state_machine_inst
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.debounce_i(all_debounce_w)
    ,.edge_o(all_edge_w)
    );

  always_ff @(posedge clk_i) begin
    if(reset_i) begin
      kpyd_col_r <= '1;
      kpyd_r <= '1;
      symbol_r <= '0;
    end else begin
      kpyd_col_r <= kpyd_col_n;
      kpyd_r <= kpyd_n;
      symbol_r <= symbol_n;
    end
  end

  always_comb begin 
    kpyd_col_n = kpyd_col_r;
    kpyd_n = kpyd_r;
    symbol_n = symbol_r;
    case(kpyd_col_n)
      init_s: begin 
        kpyd_col_n = col1_s;
      end
      col1_s: begin 
        case(kpyd_row_i)
          4'b1110: begin
            kpyd_n = {4'b0001, 4'b0001};
            symbol_n = 4'b1101; //D
          end
          4'b1101: begin
            kpyd_n = {4'b0010, 4'b0001};
            symbol_n = 4'b1100; //C
          end
          4'b1011: begin
            kpyd_n = {4'b0100, 4'b0001};
            symbol_n = 4'b1011; //B
          end
          4'b0111: begin
            kpyd_n = {4'b1000, 4'b0001};
            symbol_n = 4'b1010; //A
          end
          default: begin
            kpyd_n = '1;
            kpyd_col_n = col2_s;
          end
        endcase
      end
      col2_s: begin 
        case(kpyd_row_i)
          4'b1110: begin
            kpyd_n = {4'b0001, 4'b0010};
            symbol_n = 4'b1110; //E
          end
          4'b1101: begin
            kpyd_n = {4'b0010, 4'b0010};
            symbol_n = 4'b1001; //9
          end
          4'b1011: begin
            kpyd_n = {4'b0100, 4'b0010};
            symbol_n = 4'b0110; //6
          end
          4'b0111: begin
            kpyd_n = {4'b1000, 4'b0010};
            symbol_n = 4'b0011; //3
          end
          default: begin
            kpyd_n = '1;
            kpyd_col_n = col3_s;
          end
        endcase
      end
      col3_s: begin 
        case(kpyd_row_i)
          4'b1110: begin
            kpyd_n = {4'b0001, 4'b0100};
            symbol_n = 4'b1111; //F
          end
          4'b1101: begin
            kpyd_n = {4'b0010, 4'b0100};
            symbol_n = 4'b1000; //8
          end
          4'b1011: begin
            kpyd_n = {4'b0100, 4'b0100};
            symbol_n = 4'b0101; //5
          end
          4'b0111: begin
            kpyd_n = {4'b1000, 4'b0100};
            symbol_n = 4'b0010; //2
          end
          default: begin
            kpyd_n = '1;
            kpyd_col_n = col4_s;
          end
        endcase
      end
      col4_s: begin 
        case(kpyd_row_i)
          4'b1110: begin
            kpyd_n = {4'b0001, 4'b1000};
            symbol_n = 4'b0000; //0
          end
          4'b1101: begin
            kpyd_n = {4'b0010, 4'b1000};
            symbol_n = 4'b0111; //7
          end
          4'b1011: begin
            kpyd_n = {4'b0100, 4'b1000};
            symbol_n = 4'b0100; //4
          end
          4'b0111: begin
            kpyd_n = {4'b1000, 4'b1000};
            symbol_n = 4'b0001; //1
          end
          default: begin
            kpyd_n = '1;
            kpyd_col_n = col1_s;
          end
        endcase
      end
      default: begin 
        kpyd_col_n = kpyd_col_n;
        kpyd_n = kpyd_n;
      end
    endcase
  end

endmodule
