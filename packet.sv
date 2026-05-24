typedef enum {IDLE,RESET,STIMULUS} pkt_type_t;


class packet;
	rand bit [7:0] sa;
	rand bit [7:0] da;
	bit [31:0] len;
	bit [31:0] crc;
	rand bit [7:0] payload[];
	
	bit [7:0] inp_stream[$];
	bit [7:0] outp_stream[$];
	int i;
	
	pkt_type_t kind;
	bit [7:0] reset_cycles;
	
	function void pack(ref bit [7:0] q_inp[$]);
		q_inp = {<<8{this.payload,this.crc,this.len,this.da,this.sa}};
	endfunction
	
	function void unpack(ref bit [7:0] q_inp[$]);
		{<<8{this.payload,this.crc,this.len,this.da,this.sa}} = q_inp;
	endfunction
	
	function void print();
		$display("[Packet Print] Sa=%0d Da=%0d Len=%0d Crc=%0d",sa,da,len,crc);
		
      $display("payload=%0p",payload);
	endfunction
	
	constraint valid {
		sa inside {[1:8]};
		da inside {[1:8]};
		
		payload.size() inside {[2:19]};
		
		foreach(payload[i])
			payload[i] inside {[0:255]};
		
	}
	
	function void post_randomize();
		len = payload.size() +1+1+4+4;
		crc=payload.sum();
		this.pack(inp_stream);
	endfunction

	function void copy(packet rhs);
		if(rhs==null) begin
			$display("[ERROR] NULL handle passed to copy method");
			$finish;
		end
		this.sa=rhs.sa;
		this.da=rhs.da;
		this.len=rhs.len;
		this.crc=rhs.crc;
		this.payload=rhs.payload;
		this.inp_stream=rhs.inp_stream;
		
	endfunction
		
	function bit compare(packet dut_pkt);
		bit status;

      if (this.inp_stream.size() != dut_pkt.outp_stream.size()) begin
			$display("[Error Compare] input packet (size=%0d) not matching with output packet (size=%0d) ",this.inp_stream.size(),dut_pkt.outp_stream.size());
			$display("[INFO] check the input driven with the output packet collected and cehck why they are different");
			return 0;
		end
		status=1;
		foreach(this.inp_stream[i]) begin
			status = status && (this.inp_stream[i] == dut_pkt.outp_stream[i]);
		end
		return status;
	endfunction
	
endclass