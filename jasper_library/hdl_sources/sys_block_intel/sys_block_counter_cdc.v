// Carries the free-running sys_block clock counter from user_clk into the
// AXI-Lite clock domain in Gray code. Only one bit changes per count, so a
// sample taken mid-increment reads the old or the new value instead of a
// mix of the two. Requires the source to change by at most one per cycle.
module sys_block_counter_cdc #(
    parameter DATA_WIDTH = 32
) (
    input                       src_clk,
    input      [DATA_WIDTH-1:0] src_count,
    input                       dst_clk,
    output reg [DATA_WIDTH-1:0] dst_count
);

    reg [DATA_WIDTH-1:0] src_gray;
    reg [DATA_WIDTH-1:0] dst_gray_meta;
    reg [DATA_WIDTH-1:0] dst_gray;
    integer i;

    always @(posedge src_clk)
        src_gray <= src_count ^ (src_count >> 1);

    always @(posedge dst_clk) begin
        dst_gray_meta <= src_gray;
        dst_gray      <= dst_gray_meta;
        // Binary bit i is the XOR of Gray bits i and above
        for (i = 0; i < DATA_WIDTH; i = i + 1)
            dst_count[i] <= ^(dst_gray >> i);
    end

endmodule
