class coverage #(
    parameter int DATA_WIDTH = `DEFAULT_DATA_WIDTH,
    parameter int NUM_PORTS  = `DEFAULT_NUM_PORTS
);
  packet #(DATA_WIDTH, NUM_PORTS) pkt;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS)) mbx;
  real coverage_score;

  localparam int WordSize = (32 + DATA_WIDTH - 1) / DATA_WIDTH;
  localparam int MinValidLen = 2 + 2*WordSize + 2;

  covergroup fcov with function sample (bit [DATA_WIDTH-1:0] sa, bit [DATA_WIDTH-1:0] da, int len);
    coverpoint sa {
      bins sa_bins[] = {[0 : NUM_PORTS-1]};
    }
    coverpoint da {
      bins da_bins[] = {[0 : NUM_PORTS-1]};
    }
    coverpoint len {
      bins length_small = {[MinValidLen : 50]};
      bins length_medium = {[51 : 200]};
      bins length_big = {[201 : 999]};
      bins jumbo_pkts = {[1000 : 2000]};
      bins short_length = {[$ : MinValidLen-1]};
      bins max_length = {[2001 : $]};
    }

    cross sa, da;
    cross sa, len;
    cross da, len;
  endgroup

  function new(input mailbox#(packet #(DATA_WIDTH, NUM_PORTS)) mbx_arg);
    this.mbx = mbx_arg;
    fcov = new;
  endfunction

  virtual task run();
    while (1) begin
      mbx.get(pkt);
      fcov.sample(pkt.sa, pkt.da, pkt.len);
      coverage_score = fcov.get_coverage();
      $display("[FCOV] Sampled packet: sa=%0d, da=%0d, len=%0d. Current Coverage=%0f%%",
               pkt.sa, pkt.da, pkt.len, coverage_score);
    end
  endtask

  function void report();
    $display("************ Functional Coverage**********");
    $display("**coverage_score=%0f%%", coverage_score);
    $display("********************************************");
  endfunction
endclass
