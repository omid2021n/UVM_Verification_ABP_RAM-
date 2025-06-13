`timescale 1ns / 1ps
`include "uvm_macros.svh"
 import uvm_pkg::*;
/*



CPU says: “Hey RAM, I want to write data 0xDEADBEEF to address 0x05.”

It sets: PSEL=1, PWRITE=1, PADDR=0x05, PWDATA=0xDEADBEEF

Then it sets PENABLE=1 to confirm.

RAM stores it at that location.

Or:

CPU says: “Hey RAM, give me data at address 0x05.”

It sets: PSEL=1, PWRITE=0, PADDR=0x05

Then sets PENABLE=1 — RAM gives data back on PRDATA.


*/



//                                    Agent  Config

class abp_config extends uvm_object; //                        Atcive  Driver  in Agent 
  `uvm_object_utils(abp_config)
  
  function new(string name = "abp_config");
    super.new(name);
  endfunction
  
  
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
 
endclass



typedef enum bit [1:0]   {readd = 0, writed = 1, rst = 2} oper_mode;

//                                    Transaction 

class transaction extends uvm_sequence_item;
  


  
    rand oper_mode   op;
    rand logic            	PWRITE;
	rand logic [31 : 0]   	PWDATA;
	rand logic [31 : 0]	  	PADDR;
	logic				    PREADY;
	logic 				    PSLVERR;
    logic [31: 0]		    PRDATA;

        `uvm_object_utils_begin(transaction)
        `uvm_field_int (PWRITE,UVM_ALL_ON)
        `uvm_field_int (PWDATA,UVM_ALL_ON)
        `uvm_field_int (PADDR,UVM_ALL_ON)
        `uvm_field_int (PREADY,UVM_ALL_ON)
        `uvm_field_int (PSLVERR,UVM_ALL_ON)
        `uvm_field_int (PRDATA,UVM_ALL_ON)
        `uvm_field_enum(oper_mode, op, UVM_DEFAULT)
        `uvm_object_utils_end
  
  constraint addr_c { PADDR <= 31; }
 //  new
  function new(string name = "transaction");
    super.new(name);
  endfunction

endclass : transaction


///                                  Reset 

class reset_dut extends uvm_sequence#(transaction);
  `uvm_object_utils(reset_dut)
  
  transaction tr;

  // new 
  function new(string name = "reset_dut");
    super.new(name);
  endfunction
//  Body 
  
  virtual task body();
     begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
       
        start_item(tr);
        assert(tr.randomize);
        tr.op = rst;
        finish_item(tr);
      end
  endtask
  

endclass

//                                 Write and Read Data 

class writeb_readb extends uvm_sequence#(transaction);
  `uvm_object_utils(writeb_readb)
  
  transaction tr;
//    new 
  function new(string name = "writeb_readb");
    super.new(name);
  endfunction
  
// body 
  
  virtual task body();
    
    repeat(15) begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        
        start_item(tr);
        assert(tr.randomize);
        tr.op = writed;
        finish_item(tr);
      
      
    end
      
      
    repeat(15) begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        
        start_item(tr);
        assert(tr.randomize);
        tr.op = readd;
        finish_item(tr);
      
    end
  endtask
  

endclass





//                           Driver  
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  virtual apb_if vif;
  transaction tr;
  
 //  new 
  
  function new(input string path = "drv", uvm_component parent = null);
    super.new(path,parent);
  endfunction

  //  build 
  
 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     tr = transaction::type_id::create("tr");
      
      if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
  endfunction
  
  
  
   
  task test_drive();

    forever begin
     
         seq_item_port.get_next_item(tr);
     
     
                   if(tr.op ==  rst)
                          begin
                            vif.presetn   <= 1'b0;
                            vif.paddr     <= 'h0;
                            vif.pwdata    <= 'h0;
                            vif.pwrite    <= 'b0;
                            vif.psel      <= 'b0;
                            vif.penable   <= 'b0;
                            `uvm_info("DRV", "System Reset : Start of Simulation", UVM_MEDIUM);
                            @(posedge vif.pclk);  
                          end

                  else if(tr.op == writed)
                          begin
                            vif.psel    <= 1'b1;
                            vif.paddr   <= tr.PADDR;
                            vif.pwdata  <= tr.PWDATA;
                            vif.presetn <= 1'b1;
                            vif.pwrite  <= 1'b1;
                            @(posedge vif.pclk);
                            vif.penable <= 1'b1;
     `uvm_info("DRV", $sformatf("mode:%0s, addr:%0d, wdata:%0d, rdata:%0d, slverr:%0d",tr.op.name(),tr.PADDR,tr.PWDATA,tr.PRDATA,tr.PSLVERR), UVM_NONE);
                            @(negedge vif.pready);
                            vif.penable <= 1'b0;
                            tr.PSLVERR   = vif.pslverr;
                            
                          end
                      else if(tr.op ==  readd)
                          begin
                            vif.psel    <= 1'b1;
                            vif.paddr   <= tr.PADDR;
                            vif.presetn <= 1'b1;
                            vif.pwrite  <= 1'b0;
                            @(posedge vif.pclk);
                            vif.penable <= 1'b1;
     `uvm_info("DRV", $sformatf("mode:%0s, addr:%0d, wdata:%0d, rdata:%0d, slverr:%0d",tr.op.name(),tr.PADDR,tr.PWDATA,tr.PRDATA,tr.PSLVERR), UVM_NONE);
                            @(negedge vif.pready);
                            vif.penable <= 1'b0;
                            tr.PRDATA     = vif.prdata;
                            tr.PSLVERR    = vif.pslverr;
                          end
       seq_item_port.item_done();
     
   end
  endtask
  
//  rund  phase 
  virtual task run_phase(uvm_phase phase);
    test_drive();
  endtask

endclass

//                              monitor 

class mon extends uvm_monitor;
`uvm_component_utils(mon)

uvm_analysis_port#(transaction) send;
transaction tr;
virtual apb_if vif;
 
  //new 
  
    function new(input string inst = "mon", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
  //  build phase   
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
      if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
        `uvm_error("MON","Unable to access Interface");
    endfunction
      
    //  test monitor   
    
 task test_monitor();
    forever begin
      @(posedge vif.pclk);
      if(!vif.presetn)
        begin
        tr.op      = rst; 
        `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
         send.write(tr);
        end
      else if (vif.presetn && vif.pwrite)
         begin
          @(negedge vif.pready);
          tr.op     = writed;
          tr.PWDATA = vif.pwdata;
          tr.PADDR  =  vif.paddr;
          tr.PSLVERR  = vif.pslverr;
          `uvm_info("MON", $sformatf("DATA WRITE addr:%0d data:%0d slverr:%0d",tr.PADDR,tr.PWDATA,tr.PSLVERR), UVM_NONE); 
          send.write(tr);
         end
      else if (vif.presetn && !vif.pwrite)
         begin
           @(negedge vif.pready);
          tr.op     = readd; 
          tr.PADDR  =  vif.paddr;
          tr.PRDATA   = vif.prdata;
          tr.PSLVERR  = vif.pslverr;
          `uvm_info("MON", $sformatf("DATA READ addr:%0d data:%0d slverr:%0d",tr.PADDR, tr.PRDATA,tr.PSLVERR), UVM_NONE); 
          send.write(tr);
         end
    
    end
   endtask 

  //  rund  phase 
  virtual task run_phase(uvm_phase phase);
    test_monitor();
  endtask
    
      
endclass

//                                  Scorboard 


class sco extends uvm_scoreboard;
`uvm_component_utils(sco)

  uvm_analysis_imp#(transaction,sco) recv;
  bit [31:0] arr[32] = '{default:0};
  bit [31:0] addr    = 0;
  bit [31:0] data_rd = 0;
 
//                  new 

    function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
 
//               build phase   
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    endfunction
    
//               write phase 
  
  virtual function void write(transaction tr);
    if(tr.op == rst)
              begin
                `uvm_info("SCO", "SYSTEM RESET DETECTED", UVM_NONE);
              end  
    else if (tr.op == writed)
      begin
            if(tr.PSLVERR == 1'b1)
                begin
                  `uvm_info("SCO", "SLV ERROR during WRITE OP", UVM_NONE);
                end
              else
                begin
                  arr[tr.PADDR] = tr.PWDATA;
                  `uvm_info("SCO", $sformatf("DATA WRITE OP  addr:%0d, wdata:%0d arr_wr:%0d",tr.PADDR,tr.PWDATA,  arr[tr.PADDR]), UVM_NONE);
                end
      end
    else if (tr.op == readd)
      begin
           if(tr.PSLVERR == 1'b1)
                begin
                  `uvm_info("SCO", "SLV ERROR during READ OP", UVM_NONE);
                end
              else 
                begin
                         data_rd = arr[tr.PADDR];
                 		 if (data_rd == tr.PRDATA)
                 			 `uvm_info("SCO", $sformatf("DATA MATCHED : addr:%0d, rdata:%0d",tr.PADDR,tr.PRDATA), UVM_NONE)
                         else
                           `uvm_info("SCO",$sformatf("TEST FAILED : addr:%0d, rdata:%0d data_rd_arr:%0d",tr.PADDR,tr.PRDATA,data_rd), UVM_NONE) 
                end
 
      end
     
  
    $display("----------------------------------------------------------------");
    endfunction

endclass

///                                              Agent 

class agent extends uvm_agent;
`uvm_component_utils(agent)
  
  abp_config cfg;

function new(input string inst = "agent", uvm_component parent = null);
super.new(inst,parent);
endfunction

 driver d;
 uvm_sequencer#(transaction) seqr;
 mon m;


virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  cfg =  abp_config::type_id::create("cfg"); 
   m = mon::type_id::create("m",this);
  
  if(cfg.is_active == UVM_ACTIVE)
   begin   
   d = driver::type_id::create("d",this);
   seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
   end
  
  
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
  if(cfg.is_active == UVM_ACTIVE) begin  
    d.seq_item_port.connect(seqr.seq_item_export);
  end
endfunction

endclass

//                                           Enviroment  

class env extends uvm_env;
`uvm_component_utils(env)

function new(input string inst = "env", uvm_component c);
super.new(inst,c);
endfunction

agent a;
sco s;

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  a = agent::type_id::create("a",this);
  s = sco::type_id::create("s", this);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
a.m.send.connect(s.recv);
endfunction

endclass

//                                    Test 

class test extends uvm_test;
`uvm_component_utils(test)

function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction

env e;
writeb_readb wrrdb;

reset_dut rst;  
  
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  e      = env::type_id::create("env",this);
  wrrdb  = writeb_readb::type_id::create("wrrdb");
  rst = reset_dut::type_id::create("rst");
endfunction

virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);
  rst.start(e.a.seqr);
  wrrdb.start(e.a.seqr);
phase.drop_objection(this);
endtask
endclass

///                                     TeasBench 
module tb;
  
  
  apb_if vif();
  
  apb_ram dut (.presetn(vif.presetn), .pclk(vif.pclk), .psel(vif.psel), .penable(vif.penable), .pwrite(vif.pwrite), .paddr(vif.paddr), .pwdata(vif.pwdata), .prdata(vif.prdata), .pready(vif.pready), .pslverr(vif.pslverr));
  
  initial begin
    vif.pclk <= 0;
  end

   always #10 vif.pclk <= ~vif.pclk;

  
  
  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", vif);
    run_test("test");
   end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  
endmodule

