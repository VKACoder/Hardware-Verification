class transaction;
  
  rand bit d, rst;
  bit q;
  
  constraint rst_val {
    rst dist{0:=20, 1:=80}; 
  }
  
  constraint d_val {
    d dist{0:=10, 1:=10}; 
  }
  
  function void display(input string comp);
    $display("[%0s]: d = %0b, rst = %0b, q = %0b", comp, d, rst, q);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.d = d;
    copy.rst = rst;
    copy.q = q;
  endfunction
  
endclass

class generator;
  
  transaction trg;
  mailbox #(transaction) mbxscb;
  mailbox #(transaction) mbxdrv;
  event next;
  event done;
  int count;
  
  function new(mailbox #(transaction) mbxscb, mailbox #(transaction) mbxdrv);
    this.mbxscb = mbxscb;
    this.mbxdrv = mbxdrv;
    trg = new();
  endfunction
  
  task run();
    for (int i = 0; i < count; i++) begin
      assert (trg.randomize()) else $error("RANDOMIZATION FAILED!");
      mbxscb.put(trg.copy());
      mbxdrv.put(trg.copy());
      trg.display("GEN");
      @(next);
    end
    ->done;
  endtask
  
endclass

class driver;
  
  transaction trd;
  mailbox #(transaction) mbxgen;
  virtual dff_if dif;
  
  function new(mailbox #(transaction) mbxgen);
    this.mbxgen = mbxgen;
  endfunction
  
  task reset();
    dif.rst <= 1'b 0;
    repeat(5) @(posedge dif.clk);
    dif.rst <= 1'b 1;
    @(posedge dif.clk);
    $display("[DRV]: Reset performed");
  endtask
  
  task run();
    forever begin
      mbxgen.get(trd);
      dif.din <= trd.d;
      dif.rst <= trd.rst;
      @(posedge dif.clk);
      trd.display("DRV");
      dif.din <= 1'b 0;
      dif.rst <= 1'b 1;
      @(posedge dif.clk);
    end
  endtask
  
endclass

class monitor;
  
  transaction trm;
  mailbox #(transaction) mbxscb;
  virtual dff_if dif;
  
  function new(mailbox #(transaction) mbxscb);
    this.mbxscb = mbxscb;
    trm = new();
  endfunction
  
  task run();
    forever begin
      repeat(2) @(posedge dif.clk);
      trm.q = dif.dout;
      mbxscb.put(trm);
      trm.display("MON");
    end
  endtask
  
endclass

class scoreboard;
  
  mailbox #(transaction) mbxgen;
  mailbox #(transaction) mbxmon;
  transaction trg, trm;
  event next;
  
  function new(mailbox #(transaction) mbxgen, mailbox #(transaction) mbxmon);
    this.mbxmon = mbxmon;
    this.mbxgen = mbxgen;
  endfunction
  
  task run();
    forever begin
      mbxgen.get(trg);
      mbxmon.get(trm);
      trg.display("GEN-SCB");
      trm.display("MON-SCB");
      if (trg.rst == 1'b 0) begin
        if (trm.q == 1'b 0) begin
          $display("[SCB]: Reset success");
        end
      end
      else if (trm.q == trg.d) begin
        $display("[SCB]: Testcase passed!");
      end
      else begin
        $error("[SCB]: Testcase failed!");
      end
      $display("-----------------------------------------------------------------------------------");
      ->next;
    end
  endtask
  
  
endclass

class environment;
  
  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;
  event done, next;
  
  mailbox #(transaction) mbxgd, mbxgs, mbxms;
  
  function new(virtual dff_if dif);
    mbxgd = new();
    mbxgs = new();
    mbxms = new();
    
    gen = new(mbxgs, mbxgd);
    drv = new(mbxgd);
    mon = new(mbxms);
    scb = new(mbxgs, mbxms);
    
    gen.next = next;
    scb.next = next;
    done = gen.done;
    
    drv.dif = dif;
    mon.dif = dif;
  endfunction
  
  task pre_test();
    drv.reset();
  endtask
  
  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_none
  endtask
  
  task post_test();
    wait(done.triggered);
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
  
endclass

module top;
  
  environment env;
  
  dff_if dif();
  
  dff DUT(dif);
  
  always #5 dif.clk = ~dif.clk;
  
  initial begin
    dif.clk = 1'b 0;
  end
  
  initial begin
    env = new(dif);
    env.gen.count = 30;
    env.run();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
