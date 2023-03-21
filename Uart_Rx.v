module Uart_Rx (
    input               i_clk,
    input               i_rst,
    input               i_srx,
    input               i_signal,
    
    output              o_Rx_valid,
    output reg [7:0]    o_Rx_data
);

localparam S0_Start = 0;
localparam S1_Data  = 1;
localparam S2_Send  = 2;
localparam S3_Wait  = 3;

reg [1:0] State, Next_State;
reg [2:0] Data_Count;

assign o_Rx_valid = (State == S2_Send);
//============================================================== State
always@(posedge i_clk) State <= i_rst? S0_Start: Next_State;

always@(*)begin
    case(State)
        S0_Start:   Next_State = (i_signal & !i_srx)? S1_Data: S0_Start;
        S1_Data:    Next_State = (i_signal & (&Data_Count))? S2_Send: S1_Data;
        S2_Send:    Next_State = S3_Wait;
        S3_Wait:    Next_State = (i_signal)? S0_Start: S3_Wait;
        default:    Next_State = S0_Start;
    endcase
end
//============================================================== Data_Count
always @(posedge i_clk) begin
    if(i_rst) Data_Count <= 0;
    else begin
        if(i_signal)begin
            if(State == S1_Data)
                Data_Count <= Data_Count + 1;
            else
                Data_Count <= 0;
        end
    end
end
//============================================================== o_Rx_data
always @(posedge i_clk) begin
    if(i_rst | State == S3_Wait) o_Rx_data <= 0;
    else begin
        if(i_signal & State == S1_Data)
            o_Rx_data <= {i_srx, o_Rx_data[7:1]};
    end
end

endmodule