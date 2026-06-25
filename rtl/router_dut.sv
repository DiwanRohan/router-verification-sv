module router_dut (
    input clk,
    input reset,
    input [7:0] dut_inp,
    input inp_valid,
    output reg [7:0] dut_outp0, dut_outp1, dut_outp2, dut_outp3,
    output reg outp_valid0, outp_valid1, outp_valid2, outp_valid3,
    output reg busy,
    output reg [3:0] error
);

  // Internal memory buffer
  reg [7:0] memory [2048];
  reg [11:0] wr_ptr;
  reg [11:0] rd_ptr;
  reg [11:0] pkt_size;

  // FSM States
  typedef enum logic [2:0] {
    IDLE     = 3'b000,
    RECEIVE  = 3'b001,
    CHECK    = 3'b010,
    TRANSMIT = 3'b011,
    ERROR    = 3'b100
  } state_t;

  state_t state;

  // Temp variables (blocking assignment targets for same-cycle evaluation)
  reg [31:0] len_recv;
  reg [31:0] crc_recv;
  reg [7:0]  crc_sum;
  reg [7:0]  da_recv;

  bit debug_enable;
  initial begin
    int dummy;
    if ($value$plusargs("dut_debug=%d", dummy)) begin
      debug_enable = (dummy != 0);
    end else begin
      debug_enable = 0;
    end
  end

  // Statistics counters
  reg [31:0] total_inp_pkt_count;
  reg [31:0] total_outp_pkt_count;
  reg [31:0] crc_dropped_count;
  reg [31:0] pkt_len_dropped_count;
  reg [31:0] pkt_corrupt_dropped_count;

  // Protocol check
  reg error_protocol;

  // Protocol assertion simulation equivalent
  always @(inp_valid or dut_inp) begin
    if (busy && (state != RECEIVE) && inp_valid) begin
      error_protocol <= 1;
    end else begin
      error_protocol <= 0;
    end
  end

  // Synchronous State Machine
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      wr_ptr <= 0;
      rd_ptr <= 0;
      pkt_size <= 0;
      busy <= 0;
      error <= 0;
      dut_outp0 <= 8'hzz;
      dut_outp1 <= 8'hzz;
      dut_outp2 <= 8'hzz;
      dut_outp3 <= 8'hzz;
      outp_valid0 <= 0;
      outp_valid1 <= 0;
      outp_valid2 <= 0;
      outp_valid3 <= 0;
      crc_sum <= 0;
      total_inp_pkt_count <= 0;
      total_outp_pkt_count <= 0;
      crc_dropped_count <= 0;
      pkt_len_dropped_count <= 0;
      pkt_corrupt_dropped_count <= 0;
    end else begin
      if (error_protocol) begin
        error <= 1;
      end else begin
        case (state)
          IDLE: begin
            busy <= 0;
            wr_ptr <= 0;
            rd_ptr <= 0;
            pkt_size <= 0;
            dut_outp0 <= 8'hzz;
            dut_outp1 <= 8'hzz;
            dut_outp2 <= 8'hzz;
            dut_outp3 <= 8'hzz;
            outp_valid0 <= 0;
            outp_valid1 <= 0;
            outp_valid2 <= 0;
            outp_valid3 <= 0;
            crc_sum <= 0;
            error <= 0;

            if (inp_valid) begin
              memory[0] <= dut_inp;
              wr_ptr <= 1;
              busy <= 1;
              state <= RECEIVE;
            end
          end

          RECEIVE: begin
            if (inp_valid) begin
              if (wr_ptr < 2048) begin
                memory[wr_ptr] <= dut_inp;
                wr_ptr <= wr_ptr + 1;
                if (wr_ptr >= 10) begin
                  crc_sum <= crc_sum + dut_inp;
                end
              end else begin
                // Buffer Overflow
                error <= 4;
                pkt_len_dropped_count <= pkt_len_dropped_count + 1;
                state <= ERROR;
              end
            end else begin
              pkt_size <= wr_ptr;
              total_inp_pkt_count <= total_inp_pkt_count + 1;
              state <= CHECK;
            end
          end

          CHECK: begin
            // Use blocking assignments to read fields immediately for evaluation in same clock cycle
            len_recv = {memory[5], memory[4], memory[3], memory[2]};
            da_recv  = memory[1];
            crc_recv = {memory[9], memory[8], memory[7], memory[6]};

            if (pkt_size < 12) begin
              error <= 3;
              pkt_len_dropped_count <= pkt_len_dropped_count + 1;
              if (debug_enable) begin
                $display("[DUT ERROR] Packet %0d too short (size=%0d) at time=%0t",
                         total_inp_pkt_count, pkt_size, $time);
              end
              state <= ERROR;
            end else if (pkt_size > 2000) begin
              error <= 4;
              pkt_len_dropped_count <= pkt_len_dropped_count + 1;
              if (debug_enable) begin
                $display("[DUT ERROR] Packet %0d too long (size=%0d) at time=%0t",
                         total_inp_pkt_count, pkt_size, $time);
              end
              state <= ERROR;
            end else if (pkt_size != len_recv) begin
              error <= 5;
              pkt_corrupt_dropped_count <= pkt_corrupt_dropped_count + 1;
              if (debug_enable) begin
                $display(
                "[DUT ERROR] Packet %0d length mismatch: pkt_size=%0d, len_recv=%0d at time=%0t",
                total_inp_pkt_count, pkt_size, len_recv, $time);
              end
              state <= ERROR;
            end else if (crc_sum != crc_recv[7:0]) begin
              error <= 2;
              crc_dropped_count <= crc_dropped_count + 1;
              if (debug_enable) begin
                $display("[DUT ERROR] Packet %0d CRC mismatch: calc=%0d, received=%0d at time=%0t",
                         total_inp_pkt_count, crc_sum, crc_recv[7:0], $time);
              end
              state <= ERROR;
            end else if (da_recv > 3) begin
              error <= 6; // Custom error code 6: Invalid destination port index > 3
              if (debug_enable) begin
                $display("[DUT ERROR] Packet %0d invalid dest address=%0d at time=%0t",
                         total_inp_pkt_count, da_recv, $time);
              end
              state <= ERROR;
            end else begin
              error <= 0;
              state <= TRANSMIT;
              if (debug_enable) begin
                $display("[DUT Input] Packet %0d collected size=%0d dest=%0d time=%0t",
                         total_inp_pkt_count, pkt_size, da_recv, $time);
              end
            end
          end

          TRANSMIT: begin
            if (rd_ptr < pkt_size) begin
              case (da_recv)
                8'd0: begin dut_outp0 <= memory[rd_ptr]; outp_valid0 <= 1; end
                8'd1: begin dut_outp1 <= memory[rd_ptr]; outp_valid1 <= 1; end
                8'd2: begin dut_outp2 <= memory[rd_ptr]; outp_valid2 <= 1; end
                8'd3: begin dut_outp3 <= memory[rd_ptr]; outp_valid3 <= 1; end
                default: begin
                  dut_outp0 <= 8'hzz; outp_valid0 <= 0;
                  dut_outp1 <= 8'hzz; outp_valid1 <= 0;
                  dut_outp2 <= 8'hzz; outp_valid2 <= 0;
                  dut_outp3 <= 8'hzz; outp_valid3 <= 0;
                end
              endcase
              if (debug_enable) begin
                $strobe("[DUT Output] port=%0d byte=%0d data=%0d time=%0t",
                        da_recv, rd_ptr, memory[rd_ptr], $time);
              end
              rd_ptr <= rd_ptr + 1;
            end else begin
              dut_outp0 <= 8'hzz; outp_valid0 <= 0;
              dut_outp1 <= 8'hzz; outp_valid1 <= 0;
              dut_outp2 <= 8'hzz; outp_valid2 <= 0;
              dut_outp3 <= 8'hzz; outp_valid3 <= 0;
              busy <= 0;
              total_outp_pkt_count <= total_outp_pkt_count + 1;
              state <= IDLE;
            end
          end

          ERROR: begin
            busy <= 0;
            state <= IDLE;
          end

          default: begin
            state <= IDLE;
          end
        endcase
      end
    end
  end
endmodule
