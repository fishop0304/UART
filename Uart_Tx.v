module Uart_Tx (
    input       i_clk,
    input       i_rst,
    input       i_signal,
    input       i_Tx_valid,
    input [7:0] i_Tx_data,
    
    output reg  o_stx
);
localparam S0_Start = 0;
localparam S1_Wait  = 1;
localparam S2_Wait  = 2;
localparam S3_Data  = 3;
localparam S4_Wait  = 4;

reg [2:0] State, Next_State;
reg [2:0] Data_Count;
reg [7:0] tmp;
//============================================================== State
always@(posedge i_clk) State <= i_rst? S0_Start: Next_State;

always@(*)begin
    case(State)
        S0_Start:   Next_State = (i_Tx_valid)? S1_Wait: S0_Start;
        S1_Wait:    Next_State = (i_signal)? S2_Wait: S1_Wait;
        S2_Wait:    Next_State = (i_signal)? S3_Data: S2_Wait;
        S3_Data:    Next_State = (i_signal & (&Data_Count))? S4_Wait: S3_Data;
        S4_Wait:    Next_State = (i_signal)? S0_Start: S4_Wait;
        default:    Next_State = S0_Start;
    endcase
end
//============================================================== Data_Count
always @(posedge i_clk) begin
    if(i_rst) Data_Count <= 0;
    else begin
        if(i_signal)begin
            if(State == S3_Data)
                Data_Count <= Data_Count + 1;
            else
                Data_Count <= 0;
        end
    end
end
//============================================================== tmp
always @(posedge i_clk) begin
    if(i_rst) tmp <= 0;
    else begin
        if(i_Tx_valid)
            tmp <= i_Tx_data;
        end
end
//============================================================== o_stx
always @(posedge i_clk) begin
    if(i_rst) o_stx <= 0;
    else begin
        case(State)
            S2_Wait:    o_stx <= 0;
            S3_Data:    o_stx <= tmp[Data_Count];
            default:    o_stx <= 1;
        endcase
    end
end

endmodule