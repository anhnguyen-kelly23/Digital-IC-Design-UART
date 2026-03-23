`timescale 1ns/1ps

module uart_simplex_tb;

	parameter CLOCK_PERIOD_NS = 510;   // 1 clock cycle = 510ns, 1/510ns = 1.96 MHz
 	parameter CLKS_PER_BIT    = 17; 	// 1 bit mất 17 chu kỳ clock
  	parameter BIT_PERIOD      = 8680;  // 1/115200 baud = ~8680 ns

  	reg tb_clock = 0; 	//clock mô phỏng
  	reg tb_enable = 0;	//kích hoạt truyền UART
  	reg [7:0] tb_testdata = 8'b10110101;	//dữ liệu muốn truyền (ở đây là 10110101)
  	wire tx_active;		// Cờ báo UART TX đang truyền
	wire tx_serial;		//dữ liệu đầu ra từ UART TX → nối vào RX
	wire tx_done;		//Cờ báo TX hoàn tất
  	wire [7:0] rx_data;	//dữ liệu đầu ra từ UART RX
  	wire rx_data_valid;	//cờ báo dữ liệu hợp lệ


  	// Clock generator
  	always #(CLOCK_PERIOD_NS / 2) tb_clock <= ~tb_clock; //Clock tạo xung vuông: 510 ns chu kỳ → tương đương 1.96 MHz

  	// Instantiate Transmitter
  	uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) tx_ins ( //Khởi tạo module truyền UART với tham số CLKS_PER_BIT = 17
    		.clk(tb_clock),
    		.enable(tb_enable),
    		.data_in(tb_testdata),
    		.active(tx_active),
    		.serial_out(tx_serial),
    		.done(tx_done)
  	);

  	// Instantiate Receiver
  	uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_ins (
    		.clk(tb_clock),
    		.serial_in(tx_serial),
    		.data_valid(rx_data_valid),
    		.received_data(rx_data)
  	);

  	// Monitor data when received
  	always @(posedge rx_data_valid) //Khi rx_data_valid được kích ở cạnh lên → in ra dữ liệu nhận


	begin
    		$display("Data received: %b", rx_data); //in giá trị của rx_data (dữ liệu nhận được) ra console dưới dạng nhị phân (%b).
  	end
	
	initial begin
    		tb_enable <= 1'b0;
    		#(5 * BIT_PERIOD); //Đợi một khoảng nhỏ (5 bit = 43.4 μs) để ổn định trước khi truyền
		
		//Test case
		$display("[TEST] Sending data: %b", tb_testdata);
    		tb_enable <= 1'b1;
    		@(posedge tb_clock);  
    		tb_enable <= 1'b0;

    		wait(tx_done);
    		#(5 * BIT_PERIOD);

		$display("[TEST] Simulation completed");
    		$finish;
  	end
endmodule
