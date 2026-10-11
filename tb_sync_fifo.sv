
`timescale 1ns / 1ps

module tb_sync_fifo;

    localparam DATA_WIDTH = 8;
    localparam DEPTH      = 16;
    localparam COUNT_WIDTH = $clog2(DEPTH + 1);

    logic clk;
    logic rst;
    logic wr_en;
    logic rd_en;

    logic [DATA_WIDTH-1:0] din;
    logic [DATA_WIDTH-1:0] dout;

    logic full;
    logic empty;

    integer errors = 0;
    integer i;

    // ------------------------------------------------
    // DUT: Device Under Test
    // ------------------------------------------------
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // ------------------------------------------------
    // Assertion checker
    // ------------------------------------------------
    fifo_assertions #(
        .DEPTH(DEPTH),
        .COUNT_WIDTH(COUNT_WIDTH)
    ) assertion_checker (
        .clk(clk),
        .rst(rst),
        .full(full),
        .empty(empty),
        .count(dut.count)
    );

    // ------------------------------------------------
    // Clock generation: 10 ns period
    // ------------------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ------------------------------------------------
    // Check full and empty flags
    // ------------------------------------------------
    task automatic check_flag(
        input logic expected_full,
        input logic expected_empty,
        input string test_name
    );
        begin
            if (full !== expected_full ||
                empty !== expected_empty) begin

                $error("FAIL: %s | full=%b empty=%b",
                       test_name, full, empty);

                errors = errors + 1;

            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    // ------------------------------------------------
    // Write transaction
    // ------------------------------------------------
    task automatic write_data(
        input logic [DATA_WIDTH-1:0] value
    );
        begin
            @(negedge clk);
            wr_en = 1'b1;
            rd_en = 1'b0;
            din   = value;

            @(posedge clk);
            #1;

            @(negedge clk);
            wr_en = 1'b0;
        end
    endtask

    // ------------------------------------------------
    // Read transaction and compare expected data
    // ------------------------------------------------
    task automatic read_data(
        input logic [DATA_WIDTH-1:0] expected
    );
        begin
            @(negedge clk);
            wr_en = 1'b0;
            rd_en = 1'b1;

            @(posedge clk);
            #1;

            if (dout !== expected) begin

                $error("FAIL: Expected %02h, received %02h",
                       expected, dout);

                errors = errors + 1;

            end else begin

                $display("PASS: Read data %02h", dout);

            end

            @(negedge clk);
            rd_en = 1'b0;
        end
    endtask

    // ------------------------------------------------
    // Main test sequence
    // ------------------------------------------------
    initial begin

        rst   = 1'b1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        din   = '0;

        // TEST 1: Reset
        repeat (2) @(posedge clk);
        #1;

        check_flag(1'b0, 1'b1, "Reset state");

        @(negedge clk);
        rst = 1'b0;

        // TEST 2: Basic write and read
        write_data(8'h11);
        write_data(8'h22);
        write_data(8'h33);

        check_flag(1'b0, 1'b0, "After three writes");

        read_data(8'h11);
        read_data(8'h22);
        read_data(8'h33);

        check_flag(1'b0, 1'b1, "FIFO empty after reads");

        // TEST 3: Underflow protection
        @(negedge clk);
        rd_en = 1'b1;

        @(posedge clk);
        #1;

        check_flag(1'b0, 1'b1, "Underflow protection");

        @(negedge clk);
        rd_en = 1'b0;

        // TEST 4: Fill FIFO completely
        for (i = 0; i < DEPTH; i = i + 1)
            write_data(i);

        check_flag(1'b1, 1'b0, "FIFO full");

        // TEST 5: Overflow protection
        @(negedge clk);
        wr_en = 1'b1;
        din   = 8'hEE;

        @(posedge clk);
        #1;

        check_flag(1'b1, 1'b0, "Overflow protection");

        @(negedge clk);
        wr_en = 1'b0;

        // TEST 6: Read every original entry
        for (i = 0; i < DEPTH; i = i + 1)
            read_data(i);

        check_flag(1'b0, 1'b1, "FIFO empty after draining");

        // TEST 7: Simultaneous read and write
        write_data(8'hA5);
        write_data(8'h5A);

        @(negedge clk);
        wr_en = 1'b1;
        rd_en = 1'b1;
        din   = 8'hC3;

        @(posedge clk);
        #1;

        if (dout !== 8'hA5) begin

            $error("FAIL: Simultaneous read expected A5, got %02h",
                   dout);

            errors = errors + 1;

        end else begin

            $display("PASS: Simultaneous read returns A5");

        end

        @(negedge clk);
        wr_en = 1'b0;
        rd_en = 1'b0;

        read_data(8'h5A);
        read_data(8'hC3);

        check_flag(1'b0, 1'b1, "Final empty state");

        // ------------------------------------------------
        // Final result
        // ------------------------------------------------
        if (errors == 0) begin

            $display("--------------------------------");
            $display("ALL TESTS PASSED");
            $display("FIFO ASSERTIONS ENABLED");
            $display("--------------------------------");

        end else begin

            $display("--------------------------------");
            $display("TESTS FAILED: %0d errors", errors);
            $display("--------------------------------");

        end

        $finish;

    end

endmodule
