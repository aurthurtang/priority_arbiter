//////////////////////////////////////////////////////////////
//
//
// Requirement:
//    1.  Equal priority grant
//    2.  Serve all the event before allow the new set of event
//
////////////////////////////////////////////////////////////

module arbitor #(parameter N = 8)
(
  input  wire  clk,
  input  wire  reset_b,

  input  wire [N-1:0]  request,
  
  output reg [N-1:0]  grant,
  output wire          stall
);

genvar i;

reg [N-1:0] req_reg;
reg [N-1:0] mask;

//Mux to select qualifier
wire [N-1:0] qualifer = (stall) ? /* synopsys infer_mux_override */ 
                         req_reg : request;

//Generate a grant mask.
assign mask[0] = qualifer[0];

generate
  for (i=1;i<N;i++) begin: GEN_MASK
    assign mask[i] = qualifer[i] & ~{|mask[i-1:0]};
  end
endgenerate

//Always only allow constant value.  Cannot have i-1
//always_comb begin
//  mask[0] = request[0];
//  for (i=1;i<N;i++) mask[i] = qualifer[i] & ~{|mask[i-1:0]};
//end
  
//Generate the grant output.  
//Update the request queue list.  When req_reg is empty, it then can open for next request
always_ff @(posedge clk or negedge reset_b)
  if (!reset_b) begin 
    req_reg <= 'b0;
    grant <= 'b0;
  end else begin 
    req_reg <= qualifer ^ mask;
    grant <= mask;
  end

//stall will be set when req_reg is not zero
assign stall = |{req_reg};

endmodule
