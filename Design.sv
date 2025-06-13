module apb_ram (
  input presetn,
  input pclk,
  input psel,
  input penable,
  input pwrite,
  input [31:0] paddr, pwdata,
  output reg [31:0] prdata,
  output reg pready, pslverr
);
  
  /*
presetn  input  If presetn = 0 → reset is active
pclk	 input clock	Peripheral Clock — timing signal for everything (like a heartbeat).
psel 	 input	Peripheral Select — high when master selects this RAM module.
penable	 input	Enable signal — goes high to indicate transfer is active.
pwrite	 input	Write Enable — 1 = write to RAM, 0 = read from RAM.
paddr	 input [7:0]	Address (8-bit) — which RAM location to read or write.
pwdata	 input [31:0]	Write Data — the data to store in RAM (for writing).
prdata	 output [31:0]	Read Data — the data read from RAM (for reading
pready	output	reg	Peripheready to transfer data./If pready = 0, the master waits
pslverr	output	reg	Slave Error — tells the master that something went wrong./Goes HIGH if an error an invalid address).
*/
  
  reg [31:0] mem [32];
  
  typedef enum {idle = 0, setup = 1, access = 2, transfer = 3} state_type;

  state_type state = idle; 
  
  always@(posedge pclk)
    begin
      if(presetn == 1'b0) //active low 
        begin
        state <= idle;
        prdata <= 32'h00000000;
        pready <= 1'b0;
        pslverr <= 1'b0;
        
        for(int i = 0; i < 32; i++) 
        begin
          mem[i] <= 0;
        end
        
       end 
      else 
        begin
    
      case(state)
      idle : 
      begin
        prdata <= 32'h00000000;
        pready <= 1'b0;
        pslverr <= 1'b0;
        state   <= setup;
      end
      
      setup: ///start of transaction
      begin
           if(psel == 1'b1)
             state <= access;
           else
             state <= setup;
          
      end
        
      access: 
      begin 
        if(pwrite && penable) 
          begin
            if(paddr < 32) 
            begin
            mem[paddr] <= pwdata;
            state <= transfer;
            pslverr <= 1'b0;
            pready  <= 1'b1;
            end
            else 
            begin
            state <= transfer;
            pready <= 1'b1;
            pslverr <= 1'b1;
            end
          end
        else if (!pwrite && penable)
            begin
            if(paddr < 32) 
            begin
            prdata <= mem[paddr];
            state <= transfer;
            pready <= 1'b1;
            pslverr <= 1'b0;
            end
            else 
            begin
            state <= transfer;
            pready <= 1'b1;
            pslverr <= 1'b1;
            prdata <= 32'hxxxxxxxx;
            end
          end
        else
           state <= setup;
       end  
        
        
        
        transfer: begin
          state <= setup;
          pready <= 1'b0;
          pslverr <= 1'b0;
        end
        
  
      
      default : state <= idle;
   
      endcase
      
    end
  end
  
  
endmodule



//////////////////////////////////////////////////
interface apb_if ();
  // Signals
  logic              pclk;
  logic              presetn;
  logic       [31:0] paddr;
  logic              pwrite;
  logic       [31:0] pwdata;
  logic              penable;
  logic              psel;
  logic       [31:0] prdata;
  logic              pslverr;
  logic              pready;


endinterface : apb_if
