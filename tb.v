`timescale 1ns/1ns
`define CYCLE     8.0 // 125 Mhz
`define End_CYCLE  10000000
`define CYCLE_PER 8680.0 // 125M /115200 * 8

module tb();

reg CLK = 0;
reg RST = 0;


integer rx_pass=0;
integer tx_pass=0;

reg [8:0] data;


// Rx var
reg srx=1;

wire [7:0] Rx_data;
wire  Rx_valid;

// Tx var

reg       tx_valid=0;
reg [7:0] tx_data=0;
wire      stx;


Uart_Top uart(
    .i_clk(CLK),
    .i_rst(RST),

    .i_srx(srx),
    .o_Rx_data(Rx_data),
    .o_Rx_valid(Rx_valid),

    .i_Tx_valid(tx_valid),
    .i_Tx_data(tx_data),

    .o_stx(stx)
);

initial begin
    `ifdef FSDB
        $fsdbDumpfile("uart.fsdb");
        $fsdbDumpvars("+all");
        $fsdbDumpvars();
    `endif
end


initial begin
    @(posedge CLK);  #2 RST = 1'b1; 
    #(`CYCLE*2);  
    @(posedge CLK);  #2  RST = 1'b0;
end

always begin #(`CYCLE/2) CLK = ~CLK; end 

// RX
task UART_RX_BYTE;
    input [7:0] Data;
    integer idx;

    begin
        srx = 0; 
        #(`CYCLE_PER);

        for(idx=0; idx < 8; idx=idx+1) begin
            srx = Data[idx];
            #(`CYCLE_PER); 
        end

        srx = 1; 

        #(`CYCLE_PER);
    end
endtask

always@(posedge Rx_valid) begin
    if(data[7:0] === Rx_data) begin
        rx_pass = rx_pass + 1;
    end else begin
        $display("rx time: %t error: valid=%d expect=%d, out=%d\n", $realtime, Rx_valid, data, Rx_data);
    end
end


// TX
task UART_TX_BYTE;
    input [7:0] Data;
    integer idx;

    reg [7:0] data_tmp;
    begin
        @(posedge CLK)
        tx_valid = 1;
        tx_data  = Data;
        #(`CYCLE)
        @(posedge CLK)
        tx_valid = 0;
        tx_data  = 0;


        @(negedge stx)
        #(`CYCLE_PER);
        #(`CYCLE_PER/2);

        for(idx=0;idx<8;idx=idx+1) begin
            data_tmp[idx] = stx;
            #(`CYCLE_PER);
        end
        #(`CYCLE_PER);

        if(data_tmp === Data) begin
            tx_pass = tx_pass + 1;
        end else begin
            $display("tx time: %t error: expect=%b, out=%b\n", $realtime, Data, data_tmp);
        end

        tx_valid = 0;
        tx_data  = 0;
    end
endtask


initial begin
    @(negedge RST);
    #(`CYCLE * 2)

    
    `ifdef SIM_RX
        $display("start rx Simulation....");
        @(posedge CLK);
        for(data=0;data<=8'hff;data=data+1) begin
            UART_RX_BYTE(data[7:0]);
        end

        $display("Final Simulation Result as below: \n");         
        $display("----------------------- RX --------------------------\n");
        $display("Pass:   %3d \n", rx_pass);
        $display("Error:  %3d \n", (256 - rx_pass));
        $display("-----------------------------------------------------\n");
    `endif

    `ifdef SIM_TX
        $display("start tx Simulation....");
        @(posedge CLK);
        for(data=0; data<=8'hff; data=data+1) begin
            UART_TX_BYTE(data[7:0]);
        end

        $display("----------------------- TX --------------------------\n");
        $display("Pass:   %3d \n", tx_pass);
        $display("Error:  %3d \n", (256 - tx_pass));
        $display("-----------------------------------------------------\n");
    `endif

    $finish;
end

reg [31:0] cycle=0;
always@(posedge CLK) begin
    cycle = cycle + 1;
    if(cycle > `End_CYCLE) begin
        $finish;
    end
end


endmodule
