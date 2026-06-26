`default_nettype none 

module counter(
    input wire clk,
    input wire rst_n,
    input wire count_start,
    input wire [7:0] count_in,
    output wire [7:0] count_out
);
    //signals and reg
    reg [7:0] counter_reg;
    
    //logic
    //procedural statements
    always@(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin 
            counter_reg  <= 0;
        end else begin 
            counter_reg <= counter_reg + 1;
            if(count_start) begin 
                    counter_reg <= count_in;
            end 
        end 
    end 
    assign count_out = counter_reg;

endmodule 