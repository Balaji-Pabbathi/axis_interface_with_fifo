// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2024 21:26:56
// Design Name: 
// Module Name: fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ffifo_tb;
    parameter DW=8;
    
    reg wr_en;
    reg rd_en;
    
    reg clk;
    reg reset;
    
  reg [DW-1:0] s_data_in;
  	reg s_valid;
    reg s_last;
  
  	wire s_ready;
    
  wire [DW-1:0] m_data_out;
  	wire m_valid;
    wire m_last;
  
  	reg m_ready;
  
    wire empty;
    wire full;
    
    
    integer i;
    
  final_top dut(clk,reset,wr_en,rd_en,s_data_in,s_valid,s_last,s_ready,m_data_out,m_valid,m_last,m_ready,full,empty);
    
    initial begin
        clk=0;
        forever #1 clk=~clk;
    end
    
    initial begin
        reset=0;
        #10;
        reset=1;
        rd_en=0;
    /* 	fork
          case2_ready;
		  case2(10);
          case2_read_en;
        
        join */
     
      /*	case_full;	*/
      
      fork 
        	case1;
        	case1_read_en;
      join   
        
      	
      	
	   end 
  
  task case1;
    	begin
           for(i=0;i<10;i=i+1)
            begin
              	m_ready=1;
                @(posedge  clk)
                    wr_en<=1;
                    s_data_in<={$random}%60;
              		s_valid<=1;
              		s_last<=0;
            end 
      			@(posedge  clk)
      				wr_en<=1;
                    s_data_in<={$random}%60;
              		s_valid<=1;
              		s_last<=1;
          @(posedge  clk)
       			@(posedge  clk)
      				wr_en<=0;
                    s_data_in<=0;
              		s_valid<=0;
              		s_last<=0;
          
        end
  endtask  
  
  task case1_read_en;
    	begin
          repeat(50) @(posedge clk);
    		rd_en=1;
          repeat(50) @(posedge clk);
        end
  endtask
  
  
  
  
   task case2_read_en;
    	begin
          repeat(50) @(posedge clk);
    		rd_en=1;
          repeat(50) @(posedge clk);
        end
  endtask
  
  
  
  
  
  
  task case2(input [3:0] count);
    integer  counter=0;
    	begin
          while(counter<(count-1))
           
            	begin
                  @(posedge clk)
                  if(m_ready==0)
                    begin
                    wr_en=1;  
                    s_data_in<=s_data_in;
                  	s_valid<=1;
                  	s_last<=0;
                    end 	
                 else	
                  	begin
                  s_data_in<={$random}%60;
                  s_valid<=1;
                  s_last<=0;
                      counter=counter+1;
                    end 
                  
                end
          
          @(posedge clk)
          		begin
                  force m_ready=1;
                  s_data_in<={$random}%60;
                  s_valid<=1;
                  s_last<=1;
                  counter<=0;
                end	
          //this is for providing delay to write in fifo2
          @(posedge clk)
          		begin
                 // release m_ready;
                  s_data_in<=0;
                  s_valid<=1;
                  s_last<=0;
                  counter<=0;
                end 
          @(posedge clk)
                begin
                 release m_ready;
                  s_data_in<=0;
                  s_valid<=0;
                  s_last<=0;
                  counter<=0;
                end
          		
        end
  endtask
  
  task case2_ready;
    	begin
          repeat(25)
            @(posedge clk) m_ready=$random %15;
        end
  endtask
          	
   
   initial begin
            #3000;
            for(i=0;i<2048;i=i+1)
                 begin
                   $display("fifo[%0d]=%0d\n",i,dut.dutt.fifo2.uut.mem[i][7:0]);
                 end
          $finish;      
     end  
   
  
  
  
  task case_full;
    	begin
           m_ready=1;
          for(i=0;i<4096;i=i+1) begin
        @(negedge clk)
        	s_data_in=$random;
      		wr_en=1;
      		s_valid=1;
      		s_last=0;
      end
       @(negedge clk)
        	s_data_in=$random;
      		wr_en=1;
      		s_valid=1;
      		s_last=1;
          
          @(negedge clk);
      
		  @(negedge clk)
        	s_data_in=0;
      		wr_en=0;
      		s_valid=0;
      		s_last=0;      
      		
        end
  endtask
 
  initial begin
    $dumpfile("a.vcd");
    $dumpvars;
  end  
        
   
   
                          
        
endmodule








































/*module fifo_tb;
// Inputs
	reg clk;
	reg en;
  reg [8:0] datain;
	reg read_n;
	reg write_n;
// Outputs
  wire [8:0] dataout;
	wire full;
	wire empty;
// Instantiate the Unit Under Test (UUT)
  top_fifo dut (clk,en,write_n,read_n,datain,dataout,empty,full);
task reset;
begin
read_n=0;
write_n=0;
  @(negedge clk)en=0;
  @(negedge clk) en=1;
end
endtask
task fullcheck;
begin
  repeat(2048)
begin
@(negedge clk) datain={$random}%256;
write_n=1;
read_n=0;
end
end
endtask
task readwrite;
fork
begin
  repeat(100)
begin
@(negedge clk) write_n=1;
datain={$random}%256;
end
  repeat(2) @(negedge clk);
  	write_n=0;
end
  
begin
@(negedge clk);
@(negedge clk) read_n=1;
end
join
endtask
initial begin
clk=0;
forever #1 clk=~clk;
end
initial begin:block
integer i;
reset;
//fullcheck;
readwrite;
#100;
 for(i=0;i<2048;i=i+1)
begin
  $display("mem[%d]=%d",i,dut.fifo2.uut.mem[i]);
end
#5 $finish;
end
  
  initial begin
    $dumpfile("a.vcd");
    $dumpvars;
  end  
endmodule */


