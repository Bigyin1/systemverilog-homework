//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm


    logic [31:0] bDelayed;
    logic        bDelayedValid;

    logic [31:0] aDelayed;
    logic        aDelayedValid;

    logic [15:0] cSqrt;
    logic        cSqrtValid;

    logic [15:0] sum1Sqrt;
    logic        sum1SqrtValid;

    logic [15:0] sum2Sqrt;
    logic        sum2SqrtValid;


    logic [31:0] sum1;
    logic [31:0] sum2;

    assign sum1 = cSqrt + bDelayed;
    assign sum2 = sum1Sqrt + aDelayed;

    assign res = sum2Sqrt;
    assign res_vld = sum2SqrtValid;




    shift_register_with_valid #(32, 4) shiftReg1
    (
        .clk(clk),
        .rst(rst),
        .in_vld(arg_vld),
        .in_data(b),

        .out_vld(bDelayedValid),
        .out_data(bDelayed)
    );


    shift_register_with_valid #(32, 8) shiftReg2
    (
        .clk(clk),
        .rst(rst),
        .in_vld(arg_vld),
        .in_data(a),

        .out_vld(aDelayedValid),
        .out_data(aDelayed)
    );


    isqrt #(.n_pipe_stages(4)) i_isqrt_1
    (
        .clk   ( clk       ),
        .rst   ( rst       ),
        .x_vld ( arg_vld   ),
        .x     ( c         ),
        .y_vld ( cSqrtValid ),
        .y     ( cSqrt)
    );

    isqrt #(.n_pipe_stages(4)) i_isqrt_2
    (
        .clk   ( clk       ),
        .rst   ( rst       ),
        .x_vld ( bDelayedValid ),
        .x     ( sum1         ),
        .y_vld ( sum1SqrtValid ),
        .y     ( sum1Sqrt)
    );

    isqrt #(.n_pipe_stages(4)) i_isqrt_3
    (
        .clk   ( clk       ),
        .rst   ( rst       ),
        .x_vld ( aDelayedValid ),
        .x     ( sum2      ),
        .y_vld ( sum2SqrtValid ),
        .y     ( sum2Sqrt)
    );



endmodule
