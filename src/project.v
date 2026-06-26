`default_nettype none 

// ==========================================================
// 1. THE INNER COMPONENT: COUNTER
// ==========================================================
module counter (
    input wire clk,
    input wire rst_n,
    input wire count_start,       
    input wire [7:0] count_in,    
    output wire [7:0] cout_out    
);
    reg [7:0] counter_reg;
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            counter_reg <= 8'h00;
        end else begin 
            if (count_start) begin 
                counter_reg <= count_in;  
            end else begin 
                counter_reg <= counter_reg + 1'b1; 
            end 
        end 
    end 
    
    assign cout_out = counter_reg;
    
endmodule

// ==========================================================
// 2. THE TINY TAPEOUT TOP-LEVEL WRAPPER
// ==========================================================
module tt_um_kvsh2050_counter (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // Bidirectional IOs: Input path
    output wire [7:0] uio_out,  // Bidirectional IOs: Output path
    output wire [7:0] uio_oe,   // Bidirectional IOs: Enable (1=output)
    input  wire       ena,       
    input  wire       clk,
    input  wire       rst_n
);

    wire [7:0] count_io;

    // Instantiating the inner module defined right above
    counter my_counter_instance (    
        .clk            (clk),
        .rst_n          (rst_n),
        .count_start    (ui_in[0]), 
        .count_in       (uio_in),
        .cout_out       (count_io)  
    );

    assign uo_out  = count_io;
    
    // Safety Tie-offs
    assign uio_out = 8'h00;      
    assign uio_oe  = 8'h00;      // All bidirectional pins configured as inputs

endmodule