
module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16,
    parameter int ADDR_WIDTH = $clog2(DEPTH),
    parameter int COUNT_WIDTH = $clog2(DEPTH + 1)
) (
    input  logic                  clk,
    input  logic                  rst,

    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] din,

    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] dout,

    output logic                  full,
    output logic                  empty
);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;
    logic [COUNT_WIDTH-1:0] count;

    logic do_write;
    logic do_read;

    // Reject invalid operations.
    assign do_write = wr_en && !full;
    assign do_read  = rd_en && !empty;

    // Status flags.
    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    // FIFO storage, pointers, and occupancy.
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            dout   <= '0;
        end else begin

            if (do_write) begin
                mem[wr_ptr] <= din;

                if (wr_ptr == DEPTH - 1)
                    wr_ptr <= '0;
                else
                    wr_ptr <= wr_ptr + 1'b1;
            end

            if (do_read) begin
                dout <= mem[rd_ptr];

                if (rd_ptr == DEPTH - 1)
                    rd_ptr <= '0;
                else
                    rd_ptr <= rd_ptr + 1'b1;
            end

            case ({do_write, do_read})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

    // Parameter validity checks for simulation.
    initial begin
        if (DATA_WIDTH < 1)
            $error("DATA_WIDTH must be at least 1");

        if (DEPTH < 2)
            $error("DEPTH must be at least 2");

        if ((DEPTH & (DEPTH - 1)) != 0)
            $error("DEPTH must be a power of 2");
    end

endmodule
