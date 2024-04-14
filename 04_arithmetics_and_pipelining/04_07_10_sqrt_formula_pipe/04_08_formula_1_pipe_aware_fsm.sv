//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    // States
  enum logic[1:0]
  {
     st_load_a = 2'd0,
     st_load_b = 2'd1,
     st_load_c = 2'd2
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    case (state)

      st_load_a : if(arg_vld) new_state = st_load_b;
      st_load_b : new_state = st_load_c;
      st_load_c : new_state = st_load_a;
      
    endcase
  end

  // State update
  always_ff @ (posedge clk)
    if (rst)
      state <= st_load_a;
    else
      state <= new_state;

    
    // Data path

    always_comb begin

    isqrt_x = 'x;

    case (state)
        st_load_a :
        begin
            if (arg_vld) 
            begin
                isqrt_x = a;   
                isqrt_x_vld = '1;  
            end else
                isqrt_x_vld = '0;
        end
        
        st_load_b : isqrt_x = b;
        st_load_c : isqrt_x = c;
      
    endcase    
    end

    logic [1:0] computedArgs; 

    always_ff @( posedge clk ) begin
        if (rst)
            computedArgs <= '0;
        else

        if (computedArgs == 3)
            computedArgs <= '0;

        else if (isqrt_y_vld)
            computedArgs <= computedArgs + 2'b1;  


        // if (isqrt_y_vld && computedArgs != 3)
    end


    always_ff @( posedge clk ) begin
        if (rst)
            res <= '0;
        else

        if (isqrt_y_vld)
            if (computedArgs != 3)
                res <= res + isqrt_y;
            else
                res <= isqrt_y;
        else
            res <= '0;

    end


    assign res_vld = computedArgs == 3;  



endmodule
