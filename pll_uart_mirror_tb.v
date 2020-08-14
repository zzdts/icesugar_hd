`timescale 1ns / 10ps
module tb_top;

  reg         clk      ;
  reg         RX       ;
  wire        TX       ;
  wire        LED_R    ;
  
  top uut (
    .clk      (    clk      ),
    .RX       (    RX       ),
    .TX       (    TX       ),
    .LED_R    (    LED_R    )
  );
  
  parameter PERIOD = 83.333333;

	reg [4095:0] vcdfile;
		
  initial begin
    // $dumpfile("db_tb_top.vcd");
    // $dumpvars(0, tb_top);
    if ($value$plusargs("vcd=%s", vcdfile)) begin
			$dumpfile(vcdfile);
			$dumpvars(0, tb_top);
		end
    clk = 1'b0;
    #(PERIOD/2);
    forever
    #(PERIOD/2) clk = ~clk;
  end


  initial begin
    repeat (100 * PERIOD) @(posedge clk);

		// turn all LEDs off
		send_byte("1");
		send_byte("3");
		send_byte("5");

		// turn all LEDs on
		send_byte("1");
		send_byte("2");
		send_byte("3");
		send_byte("4");
		send_byte("5");

		// turn all LEDs off
		send_byte("1");
		send_byte("2");
		send_byte("3");
		send_byte("4");
		send_byte("5");

		repeat (10 * PERIOD) @(posedge clk);

		$finish;
  end
  

	task send_byte;
		input [7:0] c;
		integer i;
		begin
			RX <= 0;
			repeat (PERIOD) @(posedge clk);

			for (i = 0; i < 8; i = i+1) begin
				RX <= c[i];
				repeat (PERIOD) @(posedge clk);
			end

			RX <= 1;
			repeat (PERIOD) @(posedge clk);
		end
	endtask

endmodule
