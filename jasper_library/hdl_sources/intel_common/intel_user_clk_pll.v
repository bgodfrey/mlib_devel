// User IP clock for Intel SoC platforms: a fractional PLL running from the
// board oscillator, plus a user-domain reset that is held until the PLL locks.
//
// The output clock is asynchronous to the AXI-Lite clock, so every signal
// that crosses between the two must go through a synchroniser.
module intel_user_clk_pll #(
    parameter REF_CLK_FREQ = "50.0 MHz",
    parameter OUT_CLK_FREQ = "100.000000 MHz"
) (
    input  refclk,
    input  rst_in,      // asynchronous, active high; also resets the PLL
    output user_clk,
    output user_rst,    // synchronous to user_clk, active high
    output locked
);

    altera_pll #(
        .fractional_vco_multiplier("true"),
        .reference_clock_frequency(REF_CLK_FREQ),
        .operation_mode("direct"),
        .number_of_clocks(1),
        .output_clock_frequency0(OUT_CLK_FREQ),
        .phase_shift0("0 ps"),
        .duty_cycle0(50),
        .pll_type("General"),
        .pll_subtype("General")
    ) altera_pll_i (
        .rst(rst_in),
        .outclk(user_clk),
        .locked(locked),
        .fboutclk(),
        .fbclk(1'b0),
        .refclk(refclk)
    );

    // Assert asynchronously; release on user_clk once the PLL has locked
    wire rst_async = rst_in | ~locked;
    reg [2:0] rst_sync = 3'b111;

    always @(posedge user_clk or posedge rst_async) begin
        if (rst_async)
            rst_sync <= 3'b111;
        else
            rst_sync <= {rst_sync[1:0], 1'b0};
    end

    assign user_rst = rst_sync[2];

endmodule
