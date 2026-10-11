
`timescale 1ns / 1ps

module fifo_assertions #(
    parameter integer DEPTH = 16,
    parameter integer COUNT_WIDTH = $clog2(DEPTH + 1)
) (
    input wire clk,
    input wire rst,
    input wire full,
    input wire empty,
    input wire [COUNT_WIDTH-1:0] count
);

    always @(posedge clk) begin
        if (!rst) begin
            // Check occupancy bounds
            if (count > DEPTH)
                $error("ASSERTION FAILED: FIFO count exceeds DEPTH");

            // Check full flag
            if (full !== (count == DEPTH))
                $error("ASSERTION FAILED: Full flag mismatch");

            // Check empty flag
            if (empty !== (count == 0))
                $error("ASSERTION FAILED: Empty flag mismatch");
        end
    end

endmodule
