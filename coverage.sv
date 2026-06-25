class coverage;
  packet pkt;
  mailbox #(packet) mbx;
  real coverage_score;

  covergroup fcov with function sample (bit [7:0] sa, bit [7:0] da, int len);
    coverpoint sa {
      bins sa0 = {0};
      bins sa1 = {1};
      bins sa2 = {2};
      bins sa3 = {3};
    }
    coverpoint da {
      bins da0 = {0};
      bins da1 = {1};
      bins da2 = {2};
      bins da3 = {3};
    }
    coverpoint len {
      bins length_small = {[12 : 50]};
      bins length_medium = {[51 : 200]};
      bins length_big = {[201 : 999]};
      bins jumbo_pkts = {[1000 : 2000]};
      bins short_length = {[$ : 11]};
      bins max_length = {[2001 : $]};
    }

    cross sa, da;
    cross sa, len;
    cross da, len;
  endgroup

  function new(input mailbox#(packet) mbx_arg);
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
