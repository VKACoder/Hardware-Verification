class transaction;
  
  randc bit [3:0] A, B;
  randc bit Cin;
  bit [3:0] sum;
  bit cout;
  
  function void display();
    $display("[TRANS]: A = %0d, B = %0d, Cin = %0b, Sum = %0d, Cout = %0b", A, B, Cin, sum, cout);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.A = A;
    copy.B = B;
    copy.Cin = Cin;
    copy.sum = sum;
    copy.cout = cout;
  endfunction
  
endclass

interface addsub_if;
  
  logic [3:0] A, B;
  logic Cin;
  logic [3:0] sum;
  logic cout;
  
endinterface

class generator;
  transaction trans_gen;
  mailbox #(transaction) mbx_to_drv;
  mailbox #(transaction) mbx_to_scb;
  event done;
  event scb_next;
  //event drv_next;
  int count;
  
  function new(mailbox #(transaction) mbx_to_drv, mailbox #(transaction) mbx_to_scb);
    this.mbx_to_drv = mbx_to_drv;
    this.mbx_to_scb = mbx_to_scb;
    trans_gen = new();
  endfunction
  
  task run;
    repeat(count) begin
      assert (trans_gen.randomize()) else $error("[GEN]: Randomization failed!!");
      mbx_to_drv.put(trans_gen.copy());
      mbx_to_scb.put(trans_gen.copy());
      $display("[GEN]: A = %0d, B = %0d, Cin = %0b, Sum = %0d, Cout = %0b", trans_gen.A, trans_gen.B, trans_gen.Cin, trans_gen.sum, trans_gen.cout);
      //@(drv_next);
      @(scb_next);
    end
    ->done;
  endtask
  
endclass

class driver;
  virtual addsub_if asif;
  transaction trans_drv;
  mailbox #(transaction) mbx_from_gen;
  event drv_next;
  
  function new(mailbox #(transaction) mbx_from_gen);
    this.mbx_from_gen = mbx_from_gen;
  endfunction
  
  task run();
    forever begin
      mbx_from_gen.get(trans_drv);
      asif.A = trans_drv.A;
      asif.B = trans_drv.B;
      asif.Cin = trans_drv.Cin;
      $display("[DRV]: A = %0d, B = %0d, Cin = %0b, Sum = %0d, Cout = %0b", trans_drv.A, trans_drv.B, trans_drv.Cin, trans_drv.sum, trans_drv.cout);
      //->drv_next;
      #1;
    end
  endtask
endclass

class monitor;
  mailbox #(transaction) mbx_to_scb;
  transaction trans_mon;
  virtual addsub_if asif;
  
  function new(mailbox #(transaction) mbx_to_scb);
    this.mbx_to_scb = mbx_to_scb;
  endfunction
  
  task run();
    trans_mon = new();
    forever begin
      #1;
      trans_mon.sum = asif.sum;
      trans_mon.cout = asif.cout;
      mbx_to_scb.put(trans_mon);
      $display("[MON]: A = %0d, B = %0d, Cin = %0b, Sum = %0d, Cout = %0b", trans_mon.A, trans_mon.B, trans_mon.Cin, trans_mon.sum, trans_mon.cout);
    end
  endtask
endclass

class scoreboard;
  transaction trans_gen;
  transaction trans_mon;
  mailbox #(transaction) mbx_from_gen;
  mailbox #(transaction) mbx_from_mon;
  event scb_next;
  
  bit [3:0] golden_sum;
  bit golden_cout;
  
  function new(mailbox #(transaction) mbx_from_gen, mailbox #(transaction) mbx_from_mon);
    this.mbx_from_gen = mbx_from_gen;
    this.mbx_from_mon = mbx_from_mon;
    trans_gen = new();
    trans_mon = new();
  endfunction
  
  task run();
    forever begin
      mbx_from_gen.get(trans_gen);
      mbx_from_mon.get(trans_mon);
      $display("[SCB-GEN]: A = %0d, B = %0d, Cin = %0b, Sum = %0d, Cout = %0b", trans_gen.A, trans_gen.B, trans_gen.Cin, trans_gen.sum, trans_gen.cout);
      $display("[SCB-MON]: A = %0d, B = %0d, Cin = %0b, Sum = %0d, Cout = %0b", trans_mon.A, trans_mon.B, trans_mon.Cin, trans_mon.sum, trans_mon.cout);
      
      //Compute golden reference
      if (trans_gen.Cin == 0) begin
        {golden_cout, golden_sum} = trans_gen.A + trans_gen.B;
      end
      else begin
        {golden_cout, golden_sum} = trans_gen.A - trans_gen.B;
      end
      
      //Comparison
      if (golden_sum == trans_mon.sum && golden_cout == trans_mon.cout) begin
        $display("[SCB]: TESTCASE PASSED");
      end
      else begin
        $display("[SCB]: TESTCASE FAILED");
      end
    end
  endtask
endclass
