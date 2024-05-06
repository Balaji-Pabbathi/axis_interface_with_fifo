module final_top(input clk,
                 input en,
                 input we,
                 input re,
                 input [7:0] s_axis_data,
                 input s_axis_valid,
                 input s_axis_last,
                 output s_axis_ready,
                 
                 output [7:0] m_axis_data,
                 output reg  m_axis_valid,
                output m_axis_last,
                input m_axis_ready,
                
                output full,
                 output empty);
  
  
  
  
  reg [8:0] data_in;
  
  wire [8:0] data_out;
  
  
  wire re_en_fifo;
  
  
  //read_enable for FIFO 
  
  assign re_en_fifo=re && m_axis_ready;
  
  
  
  assign we_fifo=s_axis_ready && s_axis_valid && we;
  
  
  top_fifo dutt(clk,en,we_fifo,re_en_fifo,data_in,data_out,empty,full);
  
  
  assign s_axis_ready=m_axis_ready;
 
  always@(*)
    	begin
          if(s_axis_valid && s_axis_ready)
            	data_in[7:0]=s_axis_data;
          else
            data_in[7:0]=0;
        end
  
  assign data_in[8]=s_axis_last;
  
  
  assign m_axis_last=data_out[8];
  
  assign m_axis_data=data_out[7:0];
  
  
 // assign m_axis_valid=(re && m_axis_ready)?1'b1:1'b0;
  
  
  always@(posedge clk)
    	begin
          if(re && m_axis_ready)
            	m_axis_valid<=1;
          else
            	m_axis_valid<=0;
        end  
  
  
  
  
endmodule
            		
            	
  
  













module top_fifo(input clk,input en,input we,input re,input [8:0] din,output [8:0] dout,output empty,output full);
  
  wire [8:0] dout1;
  
  wire empty1;
  
  wire full1;
  
  wire w_en2;
  
  reg w_en2_delay;
  
  fifo fifo1(clk,en,we,w_en2,din,dout1,empty1,full);
  
  assign w_en2= (~(empty1 | full1));
  
  always@(posedge clk)
    	begin
          	w_en2_delay=w_en2;
        end 
  
  fifo fifo2(clk,en,w_en2_delay,re,dout1,dout,empty,full1);
  
  
  
  
endmodule  







module fifo(input clk,
            input en,
            input  we,
            input re,
            input [8:0] din,
            output [8:0] dout,
            output empty,
            output full
            );
            
     reg [11:0] rd_ptr;
     reg [11:0] wr_ptr;
     
  
  //differenct write enable and read_enable for ram 
  
    wire w_en_ram;
    wire r_en_ram;
  
  	assign w_en_ram= we ;
  
    assign r_en_ram= re & ~empty ;
  
  
  
  
     
  ram uut(clk,en,w_en_ram,r_en_ram,wr_ptr[10:0],rd_ptr[10:0],din,dout);
 
  
  //to reset all the locations of the FIFO to zero.
  
  initial begin:bala
    	integer i;
    for(i=0;i<2048;i=i+1)
      	begin
          uut.mem[i]<=0;
        end
  end
     
     
     
     
    always@(posedge clk)
        begin
            if(~en)
                begin
                    rd_ptr<=0;
                    wr_ptr<=0;
                end
          else if( (we && ~full)  && (re && ~empty))
            	begin
                    wr_ptr<=wr_ptr+1;
                    rd_ptr<=rd_ptr+1;
                end
            
          else if(we && ~full)
                begin
                    wr_ptr<=wr_ptr+1;
                    rd_ptr<=rd_ptr;
                end
           else if(re && ~empty)
                begin
                    rd_ptr<=rd_ptr+1;
                    wr_ptr<=wr_ptr;
                end
          else
                begin
                    rd_ptr<=rd_ptr;
                    wr_ptr<=wr_ptr;
                 end
     end 
     
     
     assign full={~wr_ptr[11],wr_ptr[10:0]}==(rd_ptr[11:0]);
     
     assign empty= (rd_ptr==wr_ptr);              
                                         
                            
                    
     
     
     
     
     
     
endmodule       



















module ram #(parameter Data_width=9)(input clk,
           input en,
            input we,
            input re,
            input [10:0] waddr,
            input [10:0] raddr,
            input [Data_width-1:0] din,
            output reg  [Data_width-1:0] dout
 );

        reg [8:0] mem[2047:0];
    
        always@(posedge clk)
            begin
                if(en)
                    begin
                        if(we)
                            mem[waddr]<=din;
                    end
           end
           
           always@(posedge clk)
                begin
                    if(re)
                        dout<=mem[raddr];
                 
               end                          
                                  
                            


endmodule
