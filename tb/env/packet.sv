`include "router_defines.sv"

typedef enum {
  IDLE,
  RESET,
  STIMULUS
} pkt_type_t;

class packet #(
    parameter int DATA_WIDTH = `DEFAULT_DATA_WIDTH,
    parameter int NUM_PORTS  = `DEFAULT_NUM_PORTS
);
  rand bit [DATA_WIDTH-1:0] sa;
  rand bit [DATA_WIDTH-1:0] da;
  bit [31:0] len;
  bit [31:0] crc;
  rand bit [DATA_WIDTH-1:0] payload[];

  bit [DATA_WIDTH-1:0] inp_stream[$];
  bit [DATA_WIDTH-1:0] outp_stream[$];
  int i;

  pkt_type_t kind;
  bit [7:0] reset_cycles;

  localparam int WordSize = (32 + DATA_WIDTH - 1) / DATA_WIDTH;

  function void pack(ref bit [DATA_WIDTH-1:0] q_inp[$]);
    q_inp = {<< DATA_WIDTH {this.payload, this.crc, this.len, this.da, this.sa}};
  endfunction

  function void unpack(ref bit [DATA_WIDTH-1:0] q_inp[$]);
    {<< DATA_WIDTH {this.payload, this.crc, this.len, this.da, this.sa}} = q_inp;
  endfunction

  function void print();
    $display("[Packet Print] Sa=%0d Da=%0d Len=%0d Crc=%0d", sa, da, len, crc);
    $display("payload=%0p", payload);
  endfunction

  constraint valid_c {
    sa inside {[0 : NUM_PORTS-1]};
    da inside {[0 : NUM_PORTS-1]};

    payload.size() inside {[0 : 2000]};

    // Distribute sizes to hit all coverage bins reliably
    payload.size() dist {
      [0 : 1]       :/ 15,  // short_length
      [2 : 40]      :/ 20,  // length_small
      [41 : 190]    :/ 20,  // length_medium
      [191 : 989]   :/ 20,  // length_big
      [990 : 1990]  :/ 20,  // jumbo_pkts
      [1991 : 2000] :/ 5    // max_length
    };

    foreach (payload[i]) payload[i] inside {[0 : (1<<DATA_WIDTH)-1]};
  }

  function void post_randomize();
    // 2 is sa and da elements (1 each). 2 * WordSize is len and crc elements.
    len = payload.size() + 2 + 2 * WordSize;
    crc = payload.sum();
    this.pack(inp_stream);
  endfunction

  function void copy(packet #(DATA_WIDTH, NUM_PORTS) rhs);
    if (rhs == null) begin
      $display("[ERROR] NULL handle passed to copy method");
      $finish;
    end
    this.sa = rhs.sa;
    this.da = rhs.da;
    this.len = rhs.len;
    this.crc = rhs.crc;
    this.payload = rhs.payload;
    this.inp_stream = rhs.inp_stream;
  endfunction

  function bit compare(packet #(DATA_WIDTH, NUM_PORTS) dut_pkt);
    bit status;

    if (this.inp_stream.size() != dut_pkt.outp_stream.size()) begin
      $display(
          "[Error Compare] input packet (size=%0d) not matching with output packet (size=%0d) ",
          this.inp_stream.size(), dut_pkt.outp_stream.size());
      return 0;
    end
    status = 1;
    foreach (this.inp_stream[i]) begin
      status = status && (this.inp_stream[i] == dut_pkt.outp_stream[i]);
    end
    return status;
  endfunction

endclass
