module uart_tx 
	#(parameter CLKS_PER_BIT = 17) (
   		input       clk,
   		input       enable,
   		input [7:0] data_in, 
   		output      active,
   		output reg  serial_out, 
   		output      done
   	);
  
  	parameter IDLE          = 3'b000;
  	parameter START_BIT  	= 3'b001;
  	parameter DATA_BITS  	= 3'b010;
	parameter PARITY_BIT 	= 3'b011;
  	parameter STOP_BIT   	= 3'b100;
  	parameter RESET       	= 3'b101;
   
  	reg [2:0]    current_state     	= 0; 
  	reg [7:0]    clk_count 		= 0;
  	reg [2:0]    bit_index   	= 0;
  	reg [7:0]    data_buffer     	= 0;
  	reg          done_flag     	= 0;
  	reg          active_flag   	= 0;
     	reg          even_parity      	= 0;

  	always @(posedge clk) 
	begin
    		case (current_state)
      		IDLE: 
		begin
        		serial_out   <= 1'b1; // Đường UART ở mức cao khi rỗi
        		done_flag    <= 1'b0;
        		clk_count    <= 0;
        		bit_index    <= 0;
			even_parity  <= 0; 

        		if (enable == 1'b1) 
			begin
          			active_flag 	<= 1'b1;
          			data_buffer 	<= data_in;
				even_parity 	<= ^data_in; // Tính even parity ,XOR tất cả các bit
          			current_state  	<= START_BIT;
        		end
      		end

      		START_BIT: 
		begin
        		serial_out <= 1'b0;
        		if (clk_count < CLKS_PER_BIT-1)// 0-16 --> 17 clock truyen 1 bit 
          			clk_count <= clk_count + 1;
        		else
			begin
          			clk_count <= 0;
          			current_state <= DATA_BITS;
        		end
      		end

      		DATA_BITS: 
		begin
        		serial_out <= data_buffer[bit_index];
        		if (clk_count < CLKS_PER_BIT-1)
          			clk_count <= clk_count + 1;
        		else 
			begin
          			clk_count <= 0;
          			if (bit_index < 7)
            				bit_index <= bit_index + 1; //Nếu chưa đủ 8 bit → tăng bit_index
          			else
            				current_state <= PARITY_BIT; // Nếu đủ 8 bit → sang PARITY_BIT
        		end
      		end
		
      		PARITY_BIT: 
		begin
        		serial_out <= even_parity; // Truyền bit parity
        		if (clk_count < CLKS_PER_BIT-1)
          			clk_count <= clk_count + 1;
        		else 
			begin
          			clk_count <= 0;
          			current_state <= STOP_BIT; // Đợi đủ chu kỳ → sang STOP_BIT
        		end
      		end

      		STOP_BIT: 
		begin
        		serial_out <= 1'b1;
        		if (clk_count < CLKS_PER_BIT-1)
          			clk_count <= clk_count + 1;
        		else 
			begin
          			done_flag     	<= 1'b1; //Đặt done_flag = 1 -- > truyen xong
          			active_flag   	<= 1'b0; // Gỡ active_flag, trạng thái không truyền nữa
          			clk_count 	<= 0;
          			current_state  	<= RESET;
        		end
      		end

      		RESET: 
		begin
        		done_flag <= 1'b0; //Xóa cờ done , Chuẩn bị vòng truyền tiếp theo
        		current_state <= IDLE;
      		end
      		default: current_state <= IDLE;

    		endcase
  	end

  	assign active = active_flag;
  	assign done   = done_flag;
endmodule

//-----------------------------------
module uart_rx 
	#(parameter CLKS_PER_BIT = 17) (
   		input        clk,
   		input        serial_in, // dữ liệu nhận vào nối tiếp
   		output       data_valid, // báo hiệu khi dữ liệu nhận đã sẵn sàng
   		output [7:0] received_data // byte dữ liệu nhận được
   	);
    
  	parameter IDLE          = 3'b000;
  	parameter START_BIT  	= 3'b001;
  	parameter DATA_BITS  	= 3'b010;
	parameter PARITY_BIT 	= 3'b011;
  	parameter STOP_BIT   	= 3'b100;
  	parameter RESET       	= 3'b101;
   
  	reg           async_capture    	= 1'b1;
//Biến async_capture là một thanh ghi (register) được khởi tạo với giá trị ban đầu là 1'b1 (mức logic cao). Biến này được sử dụng để "bắt" (capture) giá trị của tín hiệu đầu vào bất đồng bộ serial_in tại mỗi xung clock.
  	reg           sync_stable      	= 1'b1;
//Biến sync_stable cũng là một thanh ghi, được khởi tạo với giá trị 1'b1. Biến này lưu trữ giá trị của async_capture sau một chu kỳ clock, cung cấp một phiên bản ổn định hơn của tín hiệu serial_in.

//Tín hiệu serial_in được lấy mẫu vào async_capture tại cạnh lên của clock. Sau đó, giá trị của async_capture được chuyển sang sync_stable tại cạnh lên của clock tiếp theo. --> delay 2 clk

  	reg [7:0]     clk_count  	= 0;
  	reg [2:0]     bit_index    	= 0;
  	reg [7:0]     data_buffer      	= 0;
  	reg           valid_flag        = 0;
  	reg [2:0]     current_state     = 0;
	reg           even_parity       = 0; // Bit parity nhận được
  	reg           even_parity_error = 0; // Cờ báo lỗi parity
   
  	always @(posedge clk) 
	begin
    		async_capture <= serial_in;
    		sync_stable   <= async_capture;// sync_stable lưu từng bit của serial_in
  	end

  	always @(posedge clk) 
	begin
    		case (current_state)
      		IDLE: 
		begin
        		valid_flag      <= 1'b0;
        		clk_count 	<= 0;
        		bit_index   	<= 0;
        		if (sync_stable == 1'b0)
          			current_state <= START_BIT;
      		end

      		START_BIT: 
		begin
        		if (clk_count == (CLKS_PER_BIT-1)/2) 
			begin
          			if (sync_stable == 1'b0) 
				begin
            				clk_count     <= 0;
            				current_state <= DATA_BITS;
          			end 
				else
            				current_state <= IDLE;
        		end 
			else 
          			clk_count <= clk_count + 1;
		end

      		DATA_BITS: 
		begin
        		if (clk_count < CLKS_PER_BIT-1)
          			clk_count <= clk_count + 1;
        		else 
			begin
          			clk_count <= 0;
          			data_buffer[bit_index] <= sync_stable;
          			if (bit_index < 7)
           				bit_index <= bit_index + 1;
          			else
            				current_state <= PARITY_BIT;
        		end
      		end
		
		PARITY_BIT: // vì đang ở trạng thái parity nên sync_stable hiện tại cũng là bit parity 
		begin
        		if (clk_count < CLKS_PER_BIT-1)
          			clk_count <= clk_count + 1;
        		else 
			begin
          			even_parity <= sync_stable;
          			even_parity_error <= (^{data_buffer} != sync_stable);           				
				clk_count <= 0;
          			current_state <= STOP_BIT;
        		end
      		end

      		STOP_BIT: 
		begin
        		if (clk_count < CLKS_PER_BIT-1)
          			clk_count <= clk_count + 1;
        		else 
			begin
          			valid_flag 	<= 1'b1;
          			current_state	<= RESET;
          			clk_count 	<= 0;
        		end
      		end

      		RESET: 
		begin
        		current_state  <= IDLE;
        		valid_flag     <= 1'b0;
      		end
		default: current_state <= IDLE;

    		endcase
	end

  	assign received_data = data_buffer;
  	assign data_valid    = valid_flag;
endmodule

module uart_simplex (
	input       	clk,
   	input       	enable,
   	input [7:0] 	data_in, 
   	output      	active,
   	output reg  	serial_out, 
   	output      	done,
   	input        	serial_in,
   	output       	data_valid,
   	output [7:0] 	received_data
);

	uart_tx tx_ins (
		.clk(clk),
		.enable(enable),
		.data_in(data_in),
		.active(active),
		.done(done),
		.serial_out(serial_out)
	);

	uart_rx rx_ins (
		.clk(clk),
		.serial_in(serial_in),
		.data_valid(data_valid),
		.received_data(received_data)
	);
endmodule
