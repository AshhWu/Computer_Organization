`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    00:00:00 03/16/2015
// Design Name:
// Module Name:    testbench
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module testbench;

parameter PATTERN_NUMBER = 6'd11;

reg          clk;
reg          rst_n;
reg [32-1:0] src1_in;
reg [32-1:0] src2_in;
reg  [4-1:0] operation_in;

reg  [8-1:0] mem_src1   [0:(PATTERN_NUMBER*4-1)];
reg  [8-1:0] mem_src2   [0:(PATTERN_NUMBER*4-1)];
reg  [8-1:0] mem_opcode [0:(PATTERN_NUMBER-1)];
reg  [8-1:0] mem_result [0:(PATTERN_NUMBER*4-1)];
reg  [8-1:0] mem_zcv    [0:(PATTERN_NUMBER-1)];

reg  [6-1:0] pattern_count;
reg          start_check;
reg  [6-1:0] error_count;
reg  [6-1:0] error_count_tmp; 

wire [32-1:0] result_out;
wire          zero_out;
wire          cout_out;
wire          overflow_out;
wire  [8-1:0] zcv_correct;
wire  [8-1:0] opcode_tmp;
wire [32-1:0] result_correct;



assign opcode_tmp = mem_opcode[pattern_count];
assign result_correct = {mem_result[4*(pattern_count-1) + 5'd3],
                         mem_result[4*(pattern_count-1) + 5'd2],
                         mem_result[4*(pattern_count-1) + 5'd1],
                         mem_result[4*(pattern_count-1) + 5'd0]};

assign zcv_correct = mem_zcv[pattern_count-1];

initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    src1_in = 32'd0;
    src2_in = 32'd0;
    operation_in = 4'h0;
    start_check = 1'd0;
    error_count = 6'd0;
    error_count_tmp = 6'd0;
    pattern_count = 6'd0;
    
    $readmemh("src1.txt", mem_src1);
    $readmemh("src2.txt", mem_src2);
    $readmemh("op.txt", mem_opcode);
    $readmemh("result.txt", mem_result);
	$readmemh("zcv.txt", mem_zcv);
    
    #100 rst_n = 1'b1;
         start_check = 1'd1;
end

always #5 clk = ~clk;

ALU ALU(
        .rst_n(rst_n),
        .src1_i(src1_in),
        .src2_i(src2_in),
        .ctrl_i(operation_in),
        .result_o(result_out),
        .zero_o(zero_out)
       );

always@(posedge clk) begin
   if(pattern_count == (PATTERN_NUMBER+1)) begin
		//if(error_count == 5'd0) begin
			$display("***************************************************");
         $display(" Congratulation! All data are correct! ");
         $display("***************************************************");
	//	end
      $stop;
	end
   else if(rst_n) begin
		src1_in       <= {mem_src1[4*pattern_count + 6'd3],
                        mem_src1[4*pattern_count + 6'd2],
                        mem_src1[4*pattern_count + 6'd1],
                        mem_src1[4*pattern_count + 6'd0]};
      src2_in       <= {mem_src2[4*pattern_count + 6'd3],
                        mem_src2[4*pattern_count + 6'd2],
                        mem_src2[4*pattern_count + 6'd1],
                        mem_src2[4*pattern_count + 6'd0]};
      operation_in  <= opcode_tmp[4-1:0];
      pattern_count <= pattern_count + 6'd1;
	end
end

always@(posedge clk) begin
	if(start_check) begin
		if(pattern_count)
			if(result_out == result_correct) 
			begin
				if(((mem_opcode[pattern_count-1] == 4'd2) || (mem_opcode[pattern_count-1] == 4'd6)) && (zero_out != zcv_correct[3-1:0])) 
				begin
				$display("***************************************************");  
				$display(" 0No.%2d error!",pattern_count);
				$display(" Correct result: %h     Correct Zero Flag: %b",result_correct, zcv_correct[0]);
				$display(" Your result: %h        Your Zero Flag: %b\n",result_out, zero_out);
				$display("***************************************************");    
				error_count <= error_count + 6'd1;	
				end
				else if(zero_out != zcv_correct) 
				begin
				$display("***************************************************");  
				$display(" 1No.%2d error!",pattern_count);
				$display(" Correct result: %h     Correct Zero Flag: %b",result_correct, zcv_correct[0]);
				$display(" Your result: %h        Your Zero Flag: %b\n",result_out, zero_out);
				$display("***************************************************");    
				error_count <= error_count + 6'd1;	
				end
				
			end
			else begin
			   $display("***************************************************");    
			   case(mem_opcode[pattern_count-1])
				4'd0:$display(" AND error! ");                  
				4'd1:$display(" OR error! ");
				4'd2:$display(" ADD error! ");
				4'd3:$display(" MULT error! ");
				4'd4:$display(" SEQZ error! ");
				4'd6:$display(" SUB error! ");
				4'd7:$display(" SLT error! ");
				4'd11:$display(" SEQ error! ");
				4'd8:$display(" SGT error! ");
				4'd9:$display(" SLE error! ");
				4'd10:$display(" SGE error! ");
				4'd14:$display(" SNE error! ");
				4'd12:$display(" NOR error! ");
				4'd13:$display(" NAND error! ");
            default: begin
            end
			   endcase
				$display(" 2No.%2d error!",pattern_count);
				$display(" Correct result: %h     Correct Zero Flag: %b",result_correct, zcv_correct[0]);
				$display(" Your result: %h     Your Zero Flag: %b\n",result_out, zero_out);
				$display("***************************************************");    
				error_count <= error_count + 6'd1;
			end
	end
end

endmodule
