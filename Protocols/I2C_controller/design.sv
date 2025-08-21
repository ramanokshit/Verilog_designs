module piso(input [7:0] data_in, input clk, load, output reg data_out);
  reg [7:0]shift_reg;
  always@(posedge clk) begin
    if(load) begin
    shift_reg<=data_in;
    end else begin
      data_out<=shift_reg[7];
	    shift_reg <={shift_reg[6:0],1'b1};
    end
  end
endmodule

module sipo (input data_in, clk, rst, output reg  [7:0] data_out, output reg done);
  reg [7:0] shift_reg;
  reg [2:0] sipo_counter;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      shift_reg<= 8'b0;
      sipo_counter<= 3'd0;
      data_out<= 8'b0;
	  done<=1'b0;
    end else begin
      shift_reg<={shift_reg[6:0],data_in};
      sipo_counter<=sipo_counter+1;
      if (sipo_counter==3'd7) begin
	  done<=1'b1;
      data_out<=shift_reg;
      sipo_counter <= 0;
    end
  end
  end
endmodule

module freq_gen_100khz (
    input  wire clk, rst,       // 100 MHz input clock
    output reg  clk_out    // 100 kHz output clock
);
    reg [9:0]counter;
    
    always @(posedge clk or posedge rst) begin
      if(!rst) begin
       clk_out<=1'b0;
       counter<=1'b0;
     end else if (counter==10'd499) begin
        counter<= 10'd0;
        clk_out<=~clk_out;
      end else begin
        counter<=counter+10'd1;
      end
    end
endmodule

// I2C controller with 1 master 2 slave configuration
// Can transfer 1 bytes of data in one operation with acks
module I2C_controller(input clk_100m, rst, start, ack_begin, ack_done, write, input [6:0] addr, input [7:0] data_in, output reg busy, done, output reg [7:0] data_out);
  
  //key components
  tri scl, sda;
  logic target;
  logic [7:0] master_port, slave_port_1, slave_port_2;
  logic [6:0] slave_addr_1, slave_addr_2;
  
  assign slave_addr_1=7'd14;
  assign slave_addr_2=7'd34;
  
  //states
  typedef enum logic [2:0]{ START=3'b000, ADDR=3'b001, ACK_1=3'b010, LOAD=3'b100, TRANSFER=3'b101 , ACK_2=3'b110, STOP=3'b111} state_t;
  state_t state;
  
  //clk gen
  logic clk_100k;
  freq_gen_100khz c1(clk_100m,rst,clk_100k);
  
  //sender->sender_buffer->sda->reciever_buffer->reciever
  
  //master block
  logic m_load, m_clear; //ip flags
  logic m_sipo_done; //op flags
  logic m_buff, m_sdabuff, sda_mbuff; //buffer regs
  
  piso p1(master_port, clk_100k, m_load, m_drive);
  assign sda_mbuff=(m_drive==0)?1'b0:1'bz;
  
  assign m_buff=(m_sdabuff==1'b0)?1'b0:1'b1;
  sipo s1(m_buff, clk_100k, m_clear, master_port, m_sipo_done);
  
  //s1 block
  logic s1_load, s1_clear; //ip flags
  logic s1_sipo_done; //op flags
  logic s1_buff, s1_sdabuff, sda_s1buff; //buffer regs
  
  piso p2(slave_port_1, clk_100k, s1_load, s1_drive);
  assign sda_s1buff=(s1_drive==0)?1'b0:1'bz;
  
  assign s1_buff=(s1_sdabuff==1'b0)?1'b0:1'b1;
  sipo s2(s1_buff, clk_100k, s1_clear, slave_port_1, s1_sipo_done);
  
  //s2 block
  logic s2_load, s2_clear; //ip flags
  logic s2_sipo_done; //op flags
  logic s2_buff, s2_sdabuff, sda_s2buff; //buffer regs
  
  piso p3(slave_port_2, clk_100k, s2_load, s2_drive);
  assign sda_s2buff=(s2_drive==0)?1'b0:1'bz;
  
  assign s2_buff=(s2_sdabuff==1'b0)?1'b0:1'b1;
  sipo s3(s2_buff, clk_100k, s2_clear, slave_port_2, s2_sipo_done);
  
  logic [1:0] conn;
  logic success;
  
  //connections block
  logic sda_reg,sda_conn;

  always @(*) begin
    case(conn)
      2'b11: sda_conn=sda_mbuff;// master? s1
      2'b10: sda_conn=sda_mbuff;// master? s2
      2'b01: sda_conn=sda_s1buff;// s1? master
      2'b00: sda_conn=sda_s2buff;// s2? master
      default: sda_conn=1'bz;    
    endcase
    
    case (state)
      STOP: sda_reg=1'bz; // release bus
      START: sda_reg=1'b0; // pull low for one clk cycle
      ADDR: sda_reg=sda_mbuff;
      default: sda_reg=sda_conn;
    endcase
  end

  assign sda = sda_reg;

  
  always@(posedge scl)begin
    case(conn)
      
      //master write s1 read
      2'b11: begin
        s1_sdabuff<=sda;
        {s2_sdabuff,m_sdabuff}<=4'bzzzz;
      end
      
      //master write s2 read
      2'b10: begin
        s2_sdabuff<=sda;
        {s1_sdabuff,m_sdabuff}<=4'bzzzz;
      end
      
      //master read s1 write
      2'b01: begin
        m_sdabuff<=sda;
        {s2_sdabuff,s1_sdabuff}<=4'bzzzz;
      end
      
      //master read s2 write
      2'b00: begin
        m_sdabuff<=sda;
        {s2_sdabuff,s1_sdabuff}<=4'bzzzz;
      end
      default:{s1_sdabuff,s2_sdabuff,m_sdabuff}<=3'bzzz;
      
    endcase
  end
        
  
  //scl logic block
  logic clk_temp;
  
  always@(*)begin
    if(busy==1'b1) clk_temp=1'b0;
    else if (state==STOP) clk_temp=1'bz;
	  else clk_temp=clk_100k;
	 end
	    
	 assign scl=clk_temp;
   
  //sda logic block
  logic [3:0]ack_counter;
  logic [1:0] check;
  
  always@(posedge clk_100k or posedge rst) begin
    if(rst) begin
      state<=STOP;
    end
    
    case(state)
      STOP: begin
        done<=1'b0;
        target <= 1'b0;
        conn <= 2'b00;
        success <= 1'b0;
        ack_counter<=0;
        
        if(start) begin
          busy<=1'b0;
          state<=START;
        end else begin
          busy<=1'b1;
          state<=STOP;
        end
      end
      
      START: begin
        state<=ADDR;
        check<=2'b00;
      end
      
      ADDR: begin
        if(check!=2'b11)begin
          check<=2'b01;
          state<=LOAD;
        end
      else begin
        {m_load,s1_clear,s2_clear}<=3'b000;
        s1_sdabuff<=sda;
        s2_sdabuff<=sda;
        
        if(addr==slave_addr_1) target<=1'b1;
        else if(addr==slave_addr_2) target<=1'b0;
        conn<={write,target};
        state<=ACK_1;
        end
      end
        
      ACK_1: begin
        check<=2'b00;
        if(!ack_begin)begin
          busy<=1'b1;
          ack_counter<=ack_counter+1;
          if(ack_counter==4'd15) state<=STOP;
          else state<=ACK_1;
        end else begin
          busy<=1'b0;
          state<=LOAD;
        end
      end
      
      LOAD: begin
        if(check==2'b01) begin
          master_port<={addr,write};
          {m_load,s1_clear,s2_clear}<=3'b111;
          state<=ADDR;
          check<=2'b11;
        end else begin
        case({write,target})
          2'b11:begin
            master_port<=data_in;
            {m_load,s1_clear}<=2'b11;
            
          end
          
          2'b10:begin
            master_port<=data_in;
            {m_load,s2_clear}<=2'b11;
          end
          
          2'b01:begin
            slave_port_1<=data_in;
            {s1_load,m_clear}<=2'b11;
          end
          
          2'b00:begin
            slave_port_2<=data_in;
            {s2_load,m_clear}<=2'b11;
          end
        endcase
        {m_sipo_done, s1_sipo_done, s2_sipo_done}<=3'd0;
        state<=TRANSFER;
        end
      end
       
       TRANSFER: begin
         case({write,target})
          2'b11:begin
            {m_load,s1_clear}<=2'b00;
            success<=s1_sipo_done;
          end
          
          2'b10:begin
            {m_load,s2_clear}<=2'b00;
            success<=s2_sipo_done;
          end
          
          2'b00:begin
            {s2_load,m_clear}<=2'b00;
            success<=m_sipo_done;
          end
          
          2'b01:begin
            {s1_load,m_clear}<=2'b00;
            success<=m_sipo_done;
          end
        endcase
        if(success==1'b0) state<=TRANSFER;
        else begin
          case({write,target})
          2'b10: data_out<=slave_port_2;
          2'b11: data_out<=slave_port_1;
          2'b00: data_out<=master_port;
          2'b01: data_out<=master_port;
        endcase
        
        ack_counter<=4'b0;
        state<=ACK_2;
        end
      end
      
       ACK_2: begin
        if(!ack_done)begin
          busy<=1'b1;
          ack_counter<=ack_counter+1;
          if(ack_counter==4'd15) state<=STOP;
          else state<=ACK_2;
        end else begin
          busy<=1'b0;
          done<=1'b1;
          state<=STOP;
        end
      end
      default: state<=STOP;
    endcase
  end
  endmodule
