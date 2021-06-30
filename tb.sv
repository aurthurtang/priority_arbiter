module arbitor_tb();

//timeunit 1 ns;
//timeprecision 1ps;

localparam N = 8;

reg clk;
reg resetb;
reg [N-1:0] request;

wire [N-1:0] grant;
wire stall;


initial begin
  $timeformat(-9,2,"ps",10);
  $recordfile("tb.trn");
  $recordvars();

  clk = 0;

end

initial begin
  forever #(10) clk = ~clk;
end

initial begin
  #50000;
  $finish;
end

//Test
initial begin
  resetb = 0;
  request = 0;
  #400 resetb = 1;

  request = $random;
  @(negedge stall) request = $random;
  @(negedge stall) request = $random;
  @(negedge stall) request = $random;
  @(negedge stall) request = $random;
  @(negedge stall) request = 8'b1111_1111;
  @(posedge clk) request = 8'b0000_0000;
  repeat(100) @(posedge clk); 
  request = $random;
  @(posedge clk) request = 8'b0000_0000;
  repeat(10) @(posedge clk);

  $finish;
end

arbitor #(N) Iarbitor (
  .clk (clk),
  .reset_b (resetb),
  .request (request),
  .grant (grant),
  .stall (stall)
);

endmodule
