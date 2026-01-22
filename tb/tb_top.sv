`timescale 1ns/1ps

module tb_top;

  logic clk;
  logic rst_n;

  // 1. Define Dummy Memory Signals
  logic        mem_ready;
  logic [31:0] mem_rdata;

  // 2. Instantiate the DUT
  //    Connect the memory inputs so the CPU doesn't hang!
  asic_top dut (
    .clk      (clk),
    .resetn   (rst_n),
    .mem_ready(mem_ready),  // FIX: Drive this input
    .mem_rdata(mem_rdata)   // FIX: Drive this input
  );

  // 3. Simple "Always Ready" Memory Responder
  //    This tells the CPU: "Yes, here is your data, go to next cycle."
  assign mem_ready = 1'b1;         
  assign mem_rdata = 32'h00000013; // RISC-V NOP (addi x0, x0, 0)

  // 4. Clock Generation (100MHz)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // 5. Reset Sequence
  initial begin
    rst_n = 1'b0;
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
  end

  // 6. Verification Logic (Hierarchical Peeking)
  logic [31:0] last_addr;
  int change_count;

  initial begin
    $display("---------------------------------------------------");
    $display(" Simulation Start: Xcelium Verification ");
    $display("---------------------------------------------------");

    last_addr = 'x;
    change_count = 0;

    // Wait for reset release
    @(posedge rst_n);
    $display("[INFO] Reset released. CPU starting...");

    // Run for 500 cycles
    repeat (500) begin
      @(posedge clk);
      
      // HIERARCHICAL ACCESS: Look inside the core
      if (dut.u_core.mem_valid) begin
        if (dut.u_core.mem_addr !== last_addr) begin
          change_count++;
          last_addr = dut.u_core.mem_addr;
          // Only print every 5th fetch to keep logs clean
          if (change_count % 5 == 0) 
            $display("[RUN] Fetching Address: %h (Count: %0d)", last_addr, change_count);
        end
      end
    end

    // 7. Final Pass/Fail Check
    if (change_count >= 10) begin
      $display("---------------------------------------------------");
      $display(" [PASS] Core is alive. Instructions fetched: %0d", change_count);
      $display("---------------------------------------------------");
    end else begin
      $display("---------------------------------------------------");
      $display(" [FAIL] Core stuck. Instructions fetched: %0d", change_count);
      $display("---------------------------------------------------");
    end
    
    $finish;
  end

endmodule
