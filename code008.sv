/*
minimum requirements for including RAL
  
  1) atlest single register/ memory exist in DUT
  2) register have atleast single field
  3) registers should have address
 
*/
 
////////////////////////////
module top (
  input clk, write,
  input [31:0] data_in,
  output reg [31:0] data_out,
  output done
 
);
  
  reg [31:0] temp;/// [31:16] --> addr  [15:0] --> data
  
  
//   not address mapped, hence cant be included in RAL env
  always@(posedge clk)
  begin
    if(write)
       temp <= data_in;
    else
       data_out <= temp;
  end
  
  
  
endmodule
 
 
 
 
 
//////////////////////////////////////////////////////////////
 
module top (
  input clk, write,addr,
  input [31:0] data_in,
  output reg [31:0] data_out,
  output done
);
  
  reg [31:0] temp;
  
  
  always@(posedge clk)
  begin
    if(write) 
      begin
        
        if(addr == 0) 
          begin
           temp <= data_in;
          end
      end 
    else
       begin
        if(addr == 0) 
          begin
           data_out <= temp;
          end
      end
  end
    //   all 3 criteria are satisfied, hence can be included in RAL env
  
  
  
endmodule