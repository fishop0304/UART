module Uart_Baud_Rate (
    input i_clk,
    input i_rst,
    
    output o_signal
);

parameter Mhz = 125;
parameter Baud_Rate = 115200;
// parameter Clk_Baud = 1085; // 125Mhz / 115200 = 1085
// parameter WIDTH = 11; 

integer cnt;
integer Clk_Baud = Mhz * 1000000 / Baud_Rate;

assign o_signal = (cnt == (Clk_Baud - 1));

always@(posedge i_clk)begin
    if(i_rst | o_signal) 
        cnt <= 0;
    else begin
        cnt <= cnt + 1;
    end    
end

endmodule