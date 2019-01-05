module dice_simulator_ver(
	input logic CLK, Switch,
	output reg[6:0] Dseg
);
	const int MAX_VAL = 9;
	reg unsigned[31:0] counter = 0; 
	reg unsigned[31:0] prev_val = 6;	
	always@(posedge CLK)
		begin
			if (counter == MAX_VAL) 
				counter <= 0;
			else
				counter <= counter + 1;	
		end
	
	always@(posedge Switch)
		begin
			prev_val = (counter*prev_val) % 8;
			if(prev_val >= 6) 
				prev_val = prev_val - 6;
			prev_val = prev_val + 1;
				
			case(prev_val[2:0])
				3'b001: Dseg <= 7'b1001111;
				3'b010: Dseg <= 7'b0010010;
				3'b011: Dseg <= 7'b0000110;
				3'b100: Dseg <= 7'b1001100;
				3'b101: Dseg <= 7'b0100100;
				3'b110: Dseg <= 7'b0100000;
				default: Dseg <= 7'b0000000;
			endcase
		end
endmodule