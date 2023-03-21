`include "Uart_Baud_Rate.v"
`include "Uart_Rx.v"
`include "Uart_Tx.v"

module Uart_Top (
    input           i_clk,
    input           i_rst,
    //=== RX ===
    input           i_srx,
    output          o_Rx_valid,
    output [7:0]    o_Rx_data,
    //=== TX ===
    output          o_stx,
    input           i_Tx_valid,
    input [7:0]     i_Tx_data
);

parameter Mhz = 125;
parameter Baud_Rate = 115200;
wire signal;

Uart_Baud_Rate #(
    .Mhz(Mhz),
    .Baud_Rate(Baud_Rate)
) u_baud_rate (
    .i_clk(i_clk),
    .i_rst(i_rst),

    .o_signal(signal)
);

Uart_Rx u_rx(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_signal(signal),
    .i_srx(i_srx),

    .o_Rx_valid(o_Rx_valid),
    .o_Rx_data(o_Rx_data)
);

Uart_Tx u_tx(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_signal(signal),
    .i_Tx_valid(i_Tx_valid),
    .i_Tx_data(i_Tx_data),

    .o_stx(o_stx)
);

endmodule