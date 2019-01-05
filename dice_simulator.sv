module dice_simulator_ver(
	input logic CLK, Switch2,
	output logic Dseg2[6:0], test2
);
	assign test2 = CLK & Switch2;
	assign Dseg2[0] = CLK & Switch2;
endmodule