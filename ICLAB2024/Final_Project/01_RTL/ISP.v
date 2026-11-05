module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input [1:0] in_mode,
    input [1:0] in_ratio_mode,

    // Output Signals
    output reg out_valid,
    output reg [7:0] out_data,
    

    // ------------------------
    // <<<<< AXI WRITE >>>>>
    // ------------------------
    // DRAM Signals
    // axi write address channel
    // src master
    output reg[3:0]  awid_s_inf,
    output reg[31:0] awaddr_s_inf,
    output reg[2:0]  awsize_s_inf,
    output reg[1:0]  awburst_s_inf,
    output reg[7:0]  awlen_s_inf,
    output reg       awvalid_s_inf,
    // src slave
    input         awready_s_inf,
    // -----------------------------
    
    // axi write data channel 
    // src master
    output reg [127:0] wdata_s_inf,
    output reg         wlast_s_inf,
    output reg         wvalid_s_inf,
    // src slave
    input          wready_s_inf,
  
    // axi write response channel 
    // src slave
    input [3:0]    bid_s_inf,
    input [1:0]    bresp_s_inf,
    input          bvalid_s_inf,
    // src master 
    output reg     bready_s_inf,
    // -----------------------------
    // ------------------------
    // <<<<< AXI READ >>>>>
    // ------------------------
    // axi read address channel 
    // src master
    output reg [3:0]   arid_s_inf,
    output reg [31:0]  araddr_s_inf,
    output reg [7:0]   arlen_s_inf,
    output reg [2:0]   arsize_s_inf,
    output reg [1:0]   arburst_s_inf,
    output reg     arvalid_s_inf,
    // src slave
    input          arready_s_inf,
    // -----------------------------
  
    // axi read data channel 
    // slave
    input [3:0]    rid_s_inf,
    input [127:0]  rdata_s_inf,
    input [1:0]    rresp_s_inf,
    input          rlast_s_inf,
    input          rvalid_s_inf,
    // master
    output reg     rready_s_inf
    
);
// ===============================================================
//  					Parameter Declaration 
// ===============================================================
parameter IDLE = 4'd0;
/* mode focus */
parameter AXI_SEND_R = 4'd1;
parameter ADDR = 4'd2;
parameter WAIT_WRITE_DRAM = 4'd3;
parameter WAIT = 4'd4;
parameter EXPOSURE = 4'd5;
/* mode exposure */
parameter FOCUS = 4'd6;
parameter OUT = 4'd11;
parameter CHECK = 4'd12;
/* mode average */
parameter CAL = 4'd7;
integer a, b, c, d;
// ===============================================================
//  					  Assign Declaration 
// ===============================================================
assign awid_s_inf    = 4'd0;
assign awsize_s_inf  = 3'b100;
assign awburst_s_inf = 2'b01;
assign arid_s_inf    = 4'd0;
assign arsize_s_inf  = 3'b100;
assign arburst_s_inf = 2'b01;
assign awlen_s_inf   = 8'd191; // take all
assign arlen_s_inf   = 8'd191;
//==================================================================
//                          reg & wire
//==================================================================
/* count */
reg [1:0]count;
reg [7:0]cnt;
reg [1:0]dram_cnt[15:0];
reg [7:0]zero_cnt;
/* FSM */
reg [3:0] current_state, next_state;
reg [3:0]save_pic_no;
reg [7:0]save_pic_no_addr;
reg [1:0]save_ratio;
reg [1:0] save_mode;

reg [7:0]addr;
/* FOCUS */

wire [1:0]focus_result;
reg [9:0] focus_map2;
reg [12:0] focus_map4;
reg [13:0] focus_map6;
reg [7:0] select1, select2, select3, select4;
reg [1:0]save_focus_result;
reg [7:0]result1, result2;
reg [8:0]result3;

reg [20:0]save_out;
reg [8:0]cal, cal1, cal2, cal3, cal4, cal5, cal6, cal7;
reg [9:0]cal8, cal9, cal10, cal11;
reg [10:0]cal12, cal13;
reg [11:0]cal14;

reg [9:0]buffer;
reg [7:0]read[15:0];
reg [7:0]focus_read[35:0];
reg [1:0]save_ans[15:0]; 
/* average */
reg [8:0]average;
reg [7:0]compare_max;
reg [7:0]compare_min;
reg [7:0]save_average[15:0];
reg [7:0]save_exposure[15:0];
reg [7:0]min, min1, min2, min3, min4, min5, min6, min7, min8, min9, min10, min11, min12, min13, min14;
reg [9:0]save_max; 
reg [9:0]save_min; 
// ===============================================================
//  					       FSM
// ===============================================================

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        current_state <= IDLE; 
    end
    else begin
        current_state <= next_state;
    end
end

always@(*) begin
	case(current_state)
        
        IDLE : begin
            if(in_valid)next_state = CHECK;
            else next_state = IDLE;
        end
        
        
        CHECK : begin
            if(dram_cnt[save_pic_no] == 1)next_state = OUT;
            else if(save_ans[save_pic_no] !=3 && save_mode == 0)next_state = OUT; 
            else if(save_exposure[save_pic_no] !=0 && save_mode == 1)next_state = OUT;
            else if(save_average[save_pic_no] !=0 && save_mode == 2)next_state = OUT;
            else next_state = AXI_SEND_R;
        end
        
        AXI_SEND_R: begin
            if(arready_s_inf)begin
                if(save_mode == 0)next_state = FOCUS;
                else if(save_mode == 2)next_state = FOCUS;
                else next_state = ADDR;
            end
			else next_state = AXI_SEND_R;
		end
        ADDR : begin
            if(awready_s_inf)next_state = WAIT_WRITE_DRAM;
            else next_state = ADDR;
        end
        
        WAIT_WRITE_DRAM : begin
            if(wready_s_inf && wvalid_s_inf) next_state = WAIT; 
            else next_state = WAIT_WRITE_DRAM;
        end
        WAIT : begin
            next_state = EXPOSURE;
        end
        
        EXPOSURE : begin
            if(cnt == 194)next_state = OUT;
            else next_state = EXPOSURE;
        end
        FOCUS : begin
            if(rlast_s_inf)begin
                if(save_mode==0)next_state = OUT;
                else next_state = CAL;
            end
            else next_state = FOCUS;
        end
        CAL : begin
            if(cnt==7)next_state = OUT;
            else next_state = CAL;
        end
        OUT : begin
            next_state = IDLE ;  
        end
        default : next_state = IDLE;
        
        
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        for(b=0;b<16;b=b+1)begin
            save_ans[b] <= 3;  
        end
    end
    else begin
        if(save_mode == 0)begin
            if(save_ans[save_pic_no]!=3)begin
                save_ans[save_pic_no] <= save_ans[save_pic_no];
            end
            else if(current_state == OUT)begin
                save_ans[save_pic_no] <= save_focus_result;
            end
            else begin
                save_ans[save_pic_no] <= save_ans[save_pic_no];
            end
        end
        else begin
            if(save_ratio == 2)begin
                save_ans[save_pic_no] <= save_ans[save_pic_no];
            end
            else begin
                save_ans[save_pic_no] <= 3;
            end
        end
    end
end

// ===============================================================
//  	                     AXI4 READ
// ===============================================================

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
        arvalid_s_inf <= 0;
        rready_s_inf <= 0;
    end
    else begin
        if(next_state == AXI_SEND_R)begin
            arvalid_s_inf <= 1;
            rready_s_inf <= 0;
        end
        else if(current_state == WAIT_WRITE_DRAM)begin
            arvalid_s_inf <= 0;
            if(wready_s_inf)rready_s_inf <= 1;
            else rready_s_inf <= 0;
        end    
        else if(current_state == WAIT)begin
            arvalid_s_inf <= 0;
            rready_s_inf <= 1;
        end
        else if(current_state == EXPOSURE)begin
            arvalid_s_inf <= 0;
            if(rvalid_s_inf)rready_s_inf <= 1;
            else rready_s_inf <= 0;
        end
        else if(current_state == FOCUS)begin
            arvalid_s_inf <= 0;
            rready_s_inf <= 1;
        end
        /*else if(current_state ==CAL)begin
            arvalid_s_inf <= 0;
            rready_s_inf <= 0;
        end*/
        else if(current_state == OUT) begin
            arvalid_s_inf <= 0;
            rready_s_inf <= 0;
        end
        else begin
            arvalid_s_inf <= 0;
            rready_s_inf <= 0;
        end
    end
	
end


// ===============================================================
//  	                     AXI4 WRITE
// ===============================================================

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        wlast_s_inf <= 0;
		awvalid_s_inf <= 0;
		wvalid_s_inf <= 0;
        wdata_s_inf <= 0;
		bready_s_inf <= 0;
    end
    else begin
	case(current_state)
        ADDR : begin
            awvalid_s_inf <= (awready_s_inf) ? (0) : (1);
			wvalid_s_inf <= 0;
			wdata_s_inf <= 0;
			bready_s_inf <= 0;
			wlast_s_inf <= 0;
        end
        
		WAIT_WRITE_DRAM: begin
			awvalid_s_inf <= 0;
			wvalid_s_inf <= (rvalid_s_inf) ? ((wready_s_inf) ? (0) : (1)) : (0);
			wdata_s_inf <= {read[15],read[14],read[13],read[12],read[11],read[10],read[9],read[8],read[7],read[6],read[5],read[4],read[3],read[2],read[1],read[0]};
			bready_s_inf <= 0;
			wlast_s_inf <= 0;
		end
        WAIT: begin
			awvalid_s_inf <= 0;
			wvalid_s_inf <= 0;
			bready_s_inf <= 1;
            wdata_s_inf <= {read[15],read[14],read[13],read[12],read[11],read[10],read[9],read[8],read[7],read[6],read[5],read[4],read[3],read[2],read[1],read[0]};
			wlast_s_inf <= 0;
		end
		EXPOSURE: begin
			awvalid_s_inf <= 0;
            bready_s_inf <= 1;
            if(wlast_s_inf)wvalid_s_inf <= 0;
            else wvalid_s_inf <= 1;
            wdata_s_inf <= {read[15],read[14],read[13],read[12],read[11],read[10],read[9],read[8],read[7],read[6],read[5],read[4],read[3],read[2],read[1],read[0]};
			if(rlast_s_inf) wlast_s_inf <= 1;
			else wlast_s_inf <= 0;
		end 
		OUT: begin
			wvalid_s_inf <= 0; 
			awvalid_s_inf <= 0;
			if(bvalid_s_inf)bready_s_inf <= 0;
            else bready_s_inf <= 1;
            wdata_s_inf <= 0;
			wlast_s_inf <= 0; 
		end
		default: begin
			wlast_s_inf <= 0;
			awvalid_s_inf <= 0;
			wvalid_s_inf <= 0;
            wdata_s_inf <= 0;
			bready_s_inf <= 0;
		end
	endcase
    end
end


// ===============================================================
//  	            save pic_no & mode & ratio
// ===============================================================

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        save_pic_no <= 0;
    end
    else begin
        if(in_valid)save_pic_no <= in_pic_no;
        else save_pic_no <= save_pic_no;
    end 
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        save_mode <= 0;
    end
    else begin
        if(in_valid)save_mode <= in_mode;
        else save_mode <= save_mode;
    end 
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        save_ratio <= 0;
    end
    else begin
        if(in_valid && in_mode == 1)begin
            save_ratio <= in_ratio_mode; 
        end
        //else if(in_valid && in_mode==0)save_ratio <= 0;
        //else if(in_valid && in_mode==2)save_ratio <= 0;
        else begin
            save_ratio <= save_ratio;
        end
    end 
end

always @(*) begin
    case (save_pic_no)
        4'd0: save_pic_no_addr = 8'h00;
        4'd1: save_pic_no_addr = 8'h0C;
        4'd2: save_pic_no_addr = 8'h18;
        4'd3: save_pic_no_addr = 8'h24;
        4'd4: save_pic_no_addr = 8'h30;
        4'd5: save_pic_no_addr = 8'h3C;
        4'd6: save_pic_no_addr = 8'h48;
        4'd7: save_pic_no_addr = 8'h54;
        4'd8: save_pic_no_addr = 8'h60;
        4'd9: save_pic_no_addr = 8'h6C;
        4'd10: save_pic_no_addr = 8'h78;
        4'd11: save_pic_no_addr = 8'h84;
        4'd12: save_pic_no_addr = 8'h90;
        4'd13: save_pic_no_addr = 8'h9C;
        4'd14: save_pic_no_addr = 8'hA8;
        4'd15: save_pic_no_addr = 8'hB4;
        default: save_pic_no_addr = 8'h00;
    endcase
end
assign awaddr_s_inf = {12'h1, save_pic_no_addr, 8'h00};
assign araddr_s_inf = {12'h1, save_pic_no_addr, 8'h00};

// ===============================================================
//  	                      COUNT
// ===============================================================


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        count <= 0; 
    end
    else begin
        if(current_state == IDLE)count <= 0;
        else if(current_state == AXI_SEND_R)count <= 0;
        else if (current_state == EXPOSURE) begin
            if(cnt == 65)count <= 1;
            else if(cnt == 129)count <= 2;
            else count <= count;
        end
        else if (current_state == FOCUS && rvalid_s_inf) begin
            if(cnt == 63)count <= count + 1'b1;
            else count <= count ;
        end
        else count <= 0;
        
    end
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cnt <= 0; 
    end
    else begin
        if(current_state == IDLE) cnt <= 0;
        else if(current_state == AXI_SEND_R) cnt <= 0;
        else if (current_state == EXPOSURE) begin
            cnt <= cnt + 1'b1;
        end 
        else if (current_state == FOCUS && rvalid_s_inf) begin
            if(cnt == 63)cnt <= 0;
            else cnt <= cnt + 1;
        end
        else if (current_state == CAL) begin
            if(cnt == 8)cnt <= 0;
            else cnt <= cnt + 1;
        end
        else cnt <= 0;
    end
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        for(a=0;a<16;a=a+1)begin
            dram_cnt[a] <= 0; 
        end
    end
    else begin
        if(save_mode == 1)begin 
            if(zero_cnt==197)begin
                dram_cnt[save_pic_no] <= 1;
            end
            else begin
                dram_cnt[save_pic_no] <= dram_cnt[save_pic_no];
            end
        end
        else begin
            if(zero_cnt==192)begin
                dram_cnt[save_pic_no] <= 1;
            end
            else begin
                dram_cnt[save_pic_no] <= dram_cnt[save_pic_no];
            end
        end
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        zero_cnt <= 0; 
    end
    else if(current_state == IDLE)begin
        zero_cnt <= 0;
    end
    else begin
        if(rvalid_s_inf)begin
            if(rdata_s_inf == 0)begin
                zero_cnt <= zero_cnt + 1;
            end
            else begin
                zero_cnt <= 0;
            end
        end
        else zero_cnt <= 0;
    end
end
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        for(c=0;c<16;c=c+1)begin
            save_average[c] <= 0;  
        end
    end
    else begin
        if(save_mode == 2)begin
            if(save_average[save_pic_no]!=0)begin
                save_average[save_pic_no] <= save_average[save_pic_no];
            end
            else if(current_state == OUT)begin
                if(average>>1 == 127)save_average[save_pic_no] <= 1;
                else save_average[save_pic_no] <= 0;
            end
            else begin
                save_average[save_pic_no] <= save_average[save_pic_no];
            end
        end
        else if(save_mode == 1)begin
            if(save_ratio == 2)begin
                save_average[save_pic_no] <= save_average[save_pic_no];
            end
            else begin
                save_average[save_pic_no] <= 0;
            end
        end
        else begin
            save_average[save_pic_no] <= save_average[save_pic_no];
        end
    end
end
*/
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        for(c=0;c<16;c=c+1)begin
            save_average[c] <= 0;  
        end
    end
    else begin
        if(save_mode == 2)begin
            if(save_average[save_pic_no]!=0)begin
                save_average[save_pic_no] <= save_average[save_pic_no];
            end
            else if(current_state == OUT)begin
                save_average[save_pic_no] <= average >> 1;
            end
            else begin
                save_average[save_pic_no] <= save_average[save_pic_no];
            end
        end
        else if(save_mode == 1)begin
            if(save_ratio == 2)begin
                save_average[save_pic_no] <= save_average[save_pic_no];
            end
            else begin
                save_average[save_pic_no] <= 0;
            end
        end
        else begin
            save_average[save_pic_no] <= save_average[save_pic_no];
        end
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        for(d=0;d<16;d=d+1)begin
            save_exposure[d] <= 0;  
        end
    end
    else begin
        if(save_mode == 1)begin
            if(save_ratio == 2)begin
                save_exposure[save_pic_no] <= save_exposure[save_pic_no];
            end
            else if(current_state == OUT)begin
                save_exposure[save_pic_no] <= save_out>>10;
            end
            else begin
                save_exposure[save_pic_no] <= 0;
            end
        end
        else begin
            save_exposure[save_pic_no] <= save_exposure[save_pic_no];
        end
    end
end
// ===============================================================
//  	                   OUTPUT_DRAM
// ===============================================================
integer i, j, k;
always@(*) begin
    if(!rst_n)begin
        for (i = 0; i < 16; i = i + 1) begin
            read[i] = 0;
        end 
    end
    else begin
        if(current_state == EXPOSURE || current_state == WAIT || current_state == WAIT_WRITE_DRAM)begin
            case(save_ratio)
                0 : begin
                    read[0] = rdata_s_inf[7:0] >> 2;
                    read[1] = rdata_s_inf[15:8] >> 2;
                    read[2] = rdata_s_inf[23:16] >> 2;
                    read[3] = rdata_s_inf[31:24] >> 2;
                    read[4] = rdata_s_inf[39:32] >> 2;
                    read[5] = rdata_s_inf[47:40] >> 2;
                    read[6] = rdata_s_inf[55:48] >> 2;
                    read[7] = rdata_s_inf[63:56] >> 2;
                    read[8] = rdata_s_inf[71:64] >> 2;
                    read[9] = rdata_s_inf[79:72] >> 2;
                    read[10] = rdata_s_inf[87:80] >> 2;
                    read[11] = rdata_s_inf[95:88] >> 2;
                    read[12] = rdata_s_inf[103:96] >> 2;
                    read[13] = rdata_s_inf[111:104] >> 2;
                    read[14] = rdata_s_inf[119:112] >> 2;
                    read[15] = rdata_s_inf[127:120] >> 2;
                end
                1 : begin
                    read[0] = rdata_s_inf[7:0] >> 1;
                    read[1] = rdata_s_inf[15:8] >> 1;
                    read[2] = rdata_s_inf[23:16] >> 1;
                    read[3] = rdata_s_inf[31:24] >> 1;
                    read[4] = rdata_s_inf[39:32] >> 1;
                    read[5] = rdata_s_inf[47:40] >> 1;
                    read[6] = rdata_s_inf[55:48] >> 1;
                    read[7] = rdata_s_inf[63:56] >> 1;
                    read[8] = rdata_s_inf[71:64] >> 1;
                    read[9] = rdata_s_inf[79:72] >> 1;
                    read[10] = rdata_s_inf[87:80] >> 1;
                    read[11] = rdata_s_inf[95:88] >> 1;
                    read[12] = rdata_s_inf[103:96] >> 1;
                    read[13] = rdata_s_inf[111:104] >> 1;
                    read[14] = rdata_s_inf[119:112] >> 1;
                    read[15] = rdata_s_inf[127:120] >> 1;
                end
                2 : begin
                    read[0] = rdata_s_inf[7:0];
                    read[1] = rdata_s_inf[15:8];
                    read[2] = rdata_s_inf[23:16];
                    read[3] = rdata_s_inf[31:24];
                    read[4] = rdata_s_inf[39:32];
                    read[5] = rdata_s_inf[47:40];
                    read[6] = rdata_s_inf[55:48];
                    read[7] = rdata_s_inf[63:56];
                    read[8] = rdata_s_inf[71:64];
                    read[9] = rdata_s_inf[79:72];
                    read[10] = rdata_s_inf[87:80];
                    read[11] = rdata_s_inf[95:88];
                    read[12] = rdata_s_inf[103:96];
                    read[13] = rdata_s_inf[111:104];
                    read[14] = rdata_s_inf[119:112];
                    read[15] = rdata_s_inf[127:120];
                end
                3 : begin
                   
                    read[0] = (rdata_s_inf[7:0] > 127) ? 255 : (rdata_s_inf[7:0] << 1);
                    read[1] = (rdata_s_inf[15:8] > 127) ? 255 : (rdata_s_inf[15:8] << 1);
                    read[2] = (rdata_s_inf[23:16] > 127) ? 255 : (rdata_s_inf[23:16] << 1);
                    read[3] = (rdata_s_inf[31:24] > 127) ? 255 : (rdata_s_inf[31:24] << 1);
                    read[4] = (rdata_s_inf[39:32] > 127) ? 255 : (rdata_s_inf[39:32] << 1);
                    read[5] = (rdata_s_inf[47:40] > 127) ? 255 : (rdata_s_inf[47:40] << 1);
                    read[6] = (rdata_s_inf[55:48] > 127) ? 255 : (rdata_s_inf[55:48] << 1);
                    read[7] = (rdata_s_inf[63:56] > 127) ? 255 : (rdata_s_inf[63:56] << 1);
                    read[8] = (rdata_s_inf[71:64] > 127) ? 255 : (rdata_s_inf[71:64] << 1);
                    read[9] = (rdata_s_inf[79:72] > 127) ? 255 : (rdata_s_inf[79:72] << 1);
                    read[10] = (rdata_s_inf[87:80] > 127) ? 255 : (rdata_s_inf[87:80] << 1);
                    read[11] = (rdata_s_inf[95:88] > 127) ? 255 : (rdata_s_inf[95:88] << 1);
                    read[12] = (rdata_s_inf[103:96] > 127) ? 255 : (rdata_s_inf[103:96] << 1);
                    read[13] = (rdata_s_inf[111:104] > 127) ? 255 : (rdata_s_inf[111:104] << 1);
                    read[14] = (rdata_s_inf[119:112] > 127) ? 255 : (rdata_s_inf[119:112] << 1);
                    read[15] = (rdata_s_inf[127:120] > 127) ? 255 : (rdata_s_inf[127:120] << 1);
                end 
                default : begin
                    for (i = 0; i < 16; i = i + 1) begin
                        read[i] = 0;
                    end
                end
            endcase
        end
        else if(current_state == FOCUS && save_mode == 2)begin
            read[0] = rdata_s_inf[7:0];
            read[1] = rdata_s_inf[15:8];
            read[2] = rdata_s_inf[23:16];
            read[3] = rdata_s_inf[31:24];
            read[4] = rdata_s_inf[39:32];
            read[5] = rdata_s_inf[47:40];
            read[6] = rdata_s_inf[55:48];
            read[7] = rdata_s_inf[63:56];
            read[8] = rdata_s_inf[71:64];
            read[9] = rdata_s_inf[79:72];
            read[10] = rdata_s_inf[87:80];
            read[11] = rdata_s_inf[95:88];
            read[12] = rdata_s_inf[103:96];
            read[13] = rdata_s_inf[111:104];
            read[14] = rdata_s_inf[119:112];
            read[15] = rdata_s_inf[127:120];
        end
        else begin
            for (i = 0; i < 16; i = i + 1) begin
                read[i] = 0;
            end
        end	
    end
end

// ===============================================================
//  	                     EXPOSURE
// ===============================================================
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        save_out <= 0; 
    end
    else begin
        if(current_state == EXPOSURE)begin
            save_out <= save_out + cal14;
        end
        else if(current_state == OUT)save_out <= save_out;  
        else save_out <= 0;
    end
end

// ===============================================================
//  	                     AVERAGE
// ===============================================================
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        save_max <= 0; 
    end
    else begin
        if(current_state==FOCUS)begin
            if(count==1 && cnt ==4)begin
                save_max <= compare_max;
            end
            else if(count==2 && cnt ==4)begin
                save_max <=save_max + compare_max;
            end
            else save_max <= save_max;
        end
        else if(current_state==CAL && cnt==4)begin
            save_max <=save_max + compare_max;
        end
        else begin
            save_max <= save_max;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        save_min <= 0; 
    end
    else begin
        if(current_state==FOCUS)begin
            if(count==1 && cnt ==4)begin
                save_min <= compare_min;
            end
            else if(count==2 && cnt ==4)begin
                save_min <=save_min + compare_min;
            end
            else save_min <= save_min;
        end
        else if(current_state==CAL && cnt==4)begin
            save_min <=save_min + compare_min;
        end
        else begin
            save_min <= save_min;
        end
    end
end
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        buffer <= 0;
    end
    else if(current_state == IDLE)begin
        buffer <= 0;
    end
    else begin
        if(current_state == CAL && cnt==5)buffer <= save_max/3 ;
        else if(current_state == CAL && cnt==6)buffer <= save_min/3 ;
        else buffer <= 0;
    end
end
*/
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        average <= 0;
    end
    else if(current_state == IDLE)begin
        average <= 0;
    end
    else if(current_state == CAL)begin
        if(cnt==5)average <= save_max/3 ;
        else if(cnt==6)average <= average + save_min/3 ;
    end
    else begin
        average <= average;
    end
end
/*
reg [7:0]test;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        test <= 0;
    end
    else if(current_state == IDLE)begin
        test <= 0;
    end
    else if(current_state == OUT)begin
        test <= average>>1;
    end
    else begin
        test <= 0;
    end
end
*/
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        compare_max <= 0;
    end
    else begin
        if(current_state==IDLE)compare_max <= 0;
        else if(count==0 && cnt==4)compare_max <= cal14;
        else if(count==1 && cnt==4)compare_max <= cal14;
        else if(count==2 && cnt==4)compare_max <= cal14;
        else begin
            if(compare_max > cal14)compare_max <= compare_max;
            else compare_max <= cal14;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        compare_min <= 0;
    end
    else begin
        if(current_state == FOCUS && count == 0 && cnt == 4)compare_min <= 8'd255;
        else if(count==1 && cnt==4)compare_min <= min14;
        else if(count==2 && cnt==4)compare_min <= min14;
        else if(current_state == FOCUS || current_state == CAL)begin
            if(compare_min > min14)compare_min <= min14;
            else compare_min <= compare_min;
        end
        else begin
            compare_min <= 0;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        min8 <= 0; 
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(min < min1)min8 <= min;
        else min8 <= min1;
    end
    else begin
        min8 <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        min9 <= 0; 
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(min2 < min3)min9 <= min2;
        else min9 <= min3;
    end
    else begin
        min9 <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        min10 <= 0; 
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(min4 < min5)min10 <= min4;
        else min10 <= min5;
    end
    else begin
        min10 <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        min11 <= 0; 
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(min6 < min7)min11 <= min6;
        else min11 <= min7;
    end
    else begin
        min11 <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        min12 <= 0; 
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(min8 < min9)min12 <= min8;
        else min12 <= min9;
    end
    else begin
        min12 <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        min13 <= 0; 
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(min10 < min11)min13 <= min10;
        else min13 <= min11;
    end
    else begin
        min13 <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        min14 <= 0; 
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(min12 < min13)min14 <= min12;
        else min14 <= min13;
    end
    else begin
        min14 <= 0;
    end
end
// ===============================================================
//  	                       FOCUS
// ===============================================================


integer m;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        for(m=0;m<36;m=m+1)begin
            focus_read[m] <= 0;
        end
    end
    else begin
        if(current_state == FOCUS)begin
            case(count)
               0 : begin
                    if(cnt == 26)begin
                        focus_read[0] <= rdata_s_inf[111:104]>>2;
                        focus_read[1] <= rdata_s_inf[119:112]>>2;
                        focus_read[2] <= rdata_s_inf[127:120]>>2;
                    end
                    else if(cnt == 27)begin
                        
                        focus_read[3] <= rdata_s_inf[7:0]>>2;
                        focus_read[4] <= rdata_s_inf[15:8]>>2;
                        focus_read[5] <= rdata_s_inf[23:16]>>2;
                    end
                    else if(cnt == 28)begin
                        focus_read[6] <= rdata_s_inf[111:104]>>2;
                        focus_read[7] <= rdata_s_inf[119:112]>>2;
                        focus_read[8] <= rdata_s_inf[127:120]>>2;
                    end
                    else if(cnt == 29)begin
                        focus_read[9] <= rdata_s_inf[7:0]>>2;
                        focus_read[10] <= rdata_s_inf[15:8]>>2;
                        focus_read[11] <= rdata_s_inf[23:16]>>2;
                    end
                    else if(cnt == 30)begin
                        focus_read[12] <= rdata_s_inf[111:104]>>2;
                        focus_read[13] <= rdata_s_inf[119:112]>>2;
                        focus_read[14] <= rdata_s_inf[127:120]>>2;
                        
                    end
                    else if(cnt == 31)begin
                        focus_read[15] <= rdata_s_inf[7:0]>>2;
                        focus_read[16] <= rdata_s_inf[15:8]>>2;
                        focus_read[17] <= rdata_s_inf[23:16]>>2;
                    end
                    else if(cnt == 32)begin
                        focus_read[18] <= rdata_s_inf[111:104]>>2;
                        focus_read[19] <= rdata_s_inf[119:112]>>2;
                        focus_read[20] <= rdata_s_inf[127:120]>>2;
                    end
                    else if(cnt == 33)begin
                        focus_read[21] <= rdata_s_inf[7:0]>>2;
                        focus_read[22] <= rdata_s_inf[15:8]>>2;
                        focus_read[23] <= rdata_s_inf[23:16]>>2;
                    end
                    else if(cnt == 34)begin
                        focus_read[24] <= rdata_s_inf[111:104]>>2;
                        focus_read[25] <= rdata_s_inf[119:112]>>2;
                        focus_read[26] <= rdata_s_inf[127:120]>>2;
                    end
                    else if(cnt == 35)begin
                        focus_read[27] <= rdata_s_inf[7:0]>>2;
                        focus_read[28] <= rdata_s_inf[15:8]>>2;
                        focus_read[29] <= rdata_s_inf[23:16]>>2;
                    end
                    else if(cnt == 36)begin
                        focus_read[30] <= rdata_s_inf[111:104]>>2;
                        focus_read[31] <= rdata_s_inf[119:112]>>2;
                        focus_read[32] <= rdata_s_inf[127:120]>>2;
                    end
                    else if(cnt == 37)begin
                        focus_read[33] <= rdata_s_inf[7:0]>>2;
                        focus_read[34] <= rdata_s_inf[15:8]>>2;
                        focus_read[35] <= rdata_s_inf[23:16]>>2;
                    end
                    else begin
                        focus_read <= focus_read;
                    end
                end
                1 : begin
                    if(cnt == 26)begin
                        focus_read[0] <= focus_read[0] + {1'b0,rdata_s_inf[111:104]>>1};
                        focus_read[1] <= focus_read[1] + {1'b0,rdata_s_inf[119:112]>>1};
                        focus_read[2] <= focus_read[2] + {1'b0,rdata_s_inf[127:120]>>1};
                    end
                    else if(cnt == 27)begin
                        
                        focus_read[3] <= focus_read[3] + {1'b0,rdata_s_inf[7:0]>>1};
                        focus_read[4] <= focus_read[4] + {1'b0,rdata_s_inf[15:8]>>1};
                        focus_read[5] <= focus_read[5] + {1'b0,rdata_s_inf[23:16]>>1};
                    end
                    else if(cnt == 28)begin
                        focus_read[6] <= focus_read[6] + {1'b0,rdata_s_inf[111:104]>>1};
                        focus_read[7] <= focus_read[7] + {1'b0,rdata_s_inf[119:112]>>1};
                        focus_read[8] <= focus_read[8] + {1'b0,rdata_s_inf[127:120]>>1};
                    end
                    else if(cnt == 29)begin
                        focus_read[9] <= focus_read[9] + {1'b0,rdata_s_inf[7:0]>>1};
                        focus_read[10] <= focus_read[10] + {1'b0,rdata_s_inf[15:8]>>1};
                        focus_read[11] <= focus_read[11] + {1'b0,rdata_s_inf[23:16]>>1};
                    end
                    else if(cnt == 30)begin
                        
                        focus_read[12] <= focus_read[12] + {1'b0,rdata_s_inf[111:104]>>1};
                        focus_read[13] <= focus_read[13] + {1'b0,rdata_s_inf[119:112]>>1};
                        focus_read[14] <= focus_read[14] + {1'b0,rdata_s_inf[127:120]>>1};
                    end
                    else if(cnt == 31)begin
                        
                        focus_read[15] <= focus_read[15] + {1'b0,rdata_s_inf[7:0]>>1};
                        focus_read[16] <= focus_read[16] + {1'b0,rdata_s_inf[15:8]>>1};
                        focus_read[17] <= focus_read[17] + {1'b0,rdata_s_inf[23:16]>>1};
                    end
                    else if(cnt == 32)begin
                        
                        focus_read[18] <= focus_read[18] + {1'b0,rdata_s_inf[111:104]>>1};
                        focus_read[19] <= focus_read[19] + {1'b0,rdata_s_inf[119:112]>>1};
                        focus_read[20] <= focus_read[20] + {1'b0,rdata_s_inf[127:120]>>1};
                    end
                    else if(cnt == 33)begin
                        
                        focus_read[21] <= focus_read[21] + {1'b0,rdata_s_inf[7:0]>>1};
                        focus_read[22] <= focus_read[22] + {1'b0,rdata_s_inf[15:8]>>1};
                        focus_read[23] <= focus_read[23] + {1'b0,rdata_s_inf[23:16]>>1};
                    end
                    else if(cnt == 34)begin
                        
                        focus_read[24] <= focus_read[24] + {1'b0,rdata_s_inf[111:104]>>1};
                        focus_read[25] <= focus_read[25] + {1'b0,rdata_s_inf[119:112]>>1};
                        focus_read[26] <= focus_read[26] + {1'b0,rdata_s_inf[127:120]>>1};
                    end
                    else if(cnt == 35)begin
                        
                        focus_read[27] <= focus_read[27] + {1'b0,rdata_s_inf[7:0]>>1};
                        focus_read[28] <= focus_read[28] + {1'b0,rdata_s_inf[15:8]>>1};
                        focus_read[29] <= focus_read[29] + {1'b0,rdata_s_inf[23:16]>>1};
                    end
                    else if(cnt == 36)begin
                        
                        focus_read[30] <= focus_read[30] + {1'b0,rdata_s_inf[111:104]>>1};
                        focus_read[31] <= focus_read[31] + {1'b0,rdata_s_inf[119:112]>>1};
                        focus_read[32] <= focus_read[32] + {1'b0,rdata_s_inf[127:120]>>1};
                    end
                    else if(cnt == 37)begin
                        
                        focus_read[33] <= focus_read[33] + {1'b0,rdata_s_inf[7:0]>>1};
                        focus_read[34] <= focus_read[34] + {1'b0,rdata_s_inf[15:8]>>1};
                        focus_read[35] <= focus_read[35] + {1'b0,rdata_s_inf[23:16]>>1};
                    end
                    else begin
                        focus_read <= focus_read;
                    end
                end
                2 : begin
                    if(cnt == 26)begin
                        focus_read[0] <= focus_read[0] + {1'b0,rdata_s_inf[111:104]>>2};
                        focus_read[1] <= focus_read[1] + {1'b0,rdata_s_inf[119:112]>>2};
                        focus_read[2] <= focus_read[2] + {1'b0,rdata_s_inf[127:120]>>2};
                    end
                    else if(cnt == 27)begin
                        
                        focus_read[3] <= focus_read[3] + {1'b0,rdata_s_inf[7:0]>>2};
                        focus_read[4] <= focus_read[4] + {1'b0,rdata_s_inf[15:8]>>2};
                        focus_read[5] <= focus_read[5] + {1'b0,rdata_s_inf[23:16]>>2};
                    end
                    else if(cnt == 28)begin
                        focus_read[6] <= focus_read[6] + {1'b0,rdata_s_inf[111:104]>>2};
                        focus_read[7] <= focus_read[7] + {1'b0,rdata_s_inf[119:112]>>2};
                        focus_read[8] <= focus_read[8] + {1'b0,rdata_s_inf[127:120]>>2};
                    end
                    else if(cnt == 29)begin
                        focus_read[9] <= focus_read[9] + {1'b0,rdata_s_inf[7:0]>>2};
                        focus_read[10] <= focus_read[10] + {1'b0,rdata_s_inf[15:8]>>2};
                        focus_read[11] <= focus_read[11] + {1'b0,rdata_s_inf[23:16]>>2};
                    end
                    else if(cnt == 30)begin
                        
                        focus_read[12] <= focus_read[12] + {1'b0,rdata_s_inf[111:104]>>2};
                        focus_read[13] <= focus_read[13] + {1'b0,rdata_s_inf[119:112]>>2};
                        focus_read[14] <= focus_read[14] + {1'b0,rdata_s_inf[127:120]>>2};
                    end
                    else if(cnt == 31)begin
                        
                        focus_read[15] <= focus_read[15] + {1'b0,rdata_s_inf[7:0]>>2};
                        focus_read[16] <= focus_read[16] + {1'b0,rdata_s_inf[15:8]>>2};
                        focus_read[17] <= focus_read[17] + {1'b0,rdata_s_inf[23:16]>>2};
                    end
                    else if(cnt == 32)begin
                        
                        focus_read[18] <= focus_read[18] + {1'b0,rdata_s_inf[111:104]>>2};
                        focus_read[19] <= focus_read[19] + {1'b0,rdata_s_inf[119:112]>>2};
                        focus_read[20] <= focus_read[20] + {1'b0,rdata_s_inf[127:120]>>2};
                    end
                    else if(cnt == 33)begin
                        
                        focus_read[21] <= focus_read[21] + {1'b0,rdata_s_inf[7:0]>>2};
                        focus_read[22] <= focus_read[22] + {1'b0,rdata_s_inf[15:8]>>2};
                        focus_read[23] <= focus_read[23] + {1'b0,rdata_s_inf[23:16]>>2};
                    end
                    else if(cnt == 34)begin
                        
                        focus_read[24] <= focus_read[24] + {1'b0,rdata_s_inf[111:104]>>2};
                        focus_read[25] <= focus_read[25] + {1'b0,rdata_s_inf[119:112]>>2};
                        focus_read[26] <= focus_read[26] + {1'b0,rdata_s_inf[127:120]>>2};
                    end
                    else if(cnt == 35)begin
                        
                        focus_read[27] <= focus_read[27] + {1'b0,rdata_s_inf[7:0]>>2};
                        focus_read[28] <= focus_read[28] + {1'b0,rdata_s_inf[15:8]>>2};
                        focus_read[29] <= focus_read[29] + {1'b0,rdata_s_inf[23:16]>>2};
                    end
                    else if(cnt == 36)begin
                        
                        focus_read[30] <= focus_read[30] + {1'b0,rdata_s_inf[111:104]>>2};
                        focus_read[31] <= focus_read[31] + {1'b0,rdata_s_inf[119:112]>>2};
                        focus_read[32] <= focus_read[32] + {1'b0,rdata_s_inf[127:120]>>2};
                    end
                    else if(cnt == 37)begin
                        
                        focus_read[33] <= focus_read[33] + {1'b0,rdata_s_inf[7:0]>>2};
                        focus_read[34] <= focus_read[34] + {1'b0,rdata_s_inf[15:8]>>2};
                        focus_read[35] <= focus_read[35] + {1'b0,rdata_s_inf[23:16]>>2}; 
                    end
                    
                    else if(cnt == 63)begin
                        for(m=0;m<36;m=m+1)begin
                            focus_read[m] <= 0;
                        end
                    end
                    else begin
                        focus_read <= focus_read;
                    end
                end
            endcase
        end
		else begin
            for(m=0;m<36;m=m+1)begin
                focus_read[m] <= 0;
            end
		end
    end
end

/* map6 */
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        focus_map6 <= 13'd0; 
    end
    else begin
        if(current_state == IDLE)begin
            focus_map6 <= 13'd0; 
        end
        else if(current_state == FOCUS && count == 2)begin
            focus_map6 <= focus_map6 + {5'd0, result3};  
        end
        else begin
            focus_map6 <= focus_map6; 
        end
    end
end

/* map4 */
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        focus_map4 <= 0; 
    end
    else begin
        if(current_state == IDLE)begin
            focus_map4 <= 0; 
        end
        else if(current_state == FOCUS && count == 2)begin
            
            if(cnt == 35)focus_map4 <= result1 ;
            else if(cnt == 36)focus_map4 <= focus_map4 + result1;
            else if(cnt == 37)focus_map4 <= focus_map4 + result1;
            else if(cnt == 38)focus_map4 <= focus_map4 + result2 ;
            else if(cnt == 39)focus_map4 <= focus_map4 + result2;
            else if(cnt == 40)focus_map4 <= focus_map4 + result1 + result2;
            else if(cnt == 41)focus_map4 <= focus_map4 + result1 + result2;
            else if(cnt == 42)focus_map4 <= focus_map4 + result1;
            
            else if(cnt == 44)focus_map4 <= focus_map4 + result2 ;
            else if(cnt == 45)focus_map4 <= focus_map4 + result2 + result1 ;
            else if(cnt == 46)focus_map4 <= focus_map4 + result2 + result1 ;
            else if(cnt == 47)focus_map4 <= focus_map4 + result2 + result1 ;

            else if(cnt == 50)focus_map4 <= focus_map4 + result2 + result1;
            else if(cnt == 51)focus_map4 <= focus_map4 + result2 + result1;
            else if(cnt == 52)focus_map4 <= focus_map4 + result2 + result1;
            else if(cnt == 53)focus_map4 <= focus_map4 + result2;
            else focus_map4 <= focus_map4;

        end
        else begin
            focus_map4 <= focus_map4; 
        end
    end
end
/* map2 */
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        focus_map2 <= 0; 
    end
    else begin
        if(current_state == IDLE)begin
            focus_map2 <= 0;  
        end
        else if(current_state == FOCUS && count == 2)begin
            
            if(cnt == 41)focus_map2 <= focus_map2 + result1 ;
            else if(cnt == 45)focus_map2 <= focus_map2 + result2;
            else if(cnt == 46)focus_map2 <= focus_map2 + result1 + result2;
            else focus_map2 <= focus_map2;
        end
        else begin
            focus_map2 <= focus_map2; 
        end
    end
end
// ===============================================================
//  	                  FOCUS PIPELINE
// ===============================================================
always @(*) begin
    if(current_state == FOCUS && count == 2)begin
        case (cnt)
           27 : select1 = focus_read[0]; 
           28 : select1 = focus_read[1];
           29 : select1 = focus_read[2]; 
           30 : select1 = focus_read[3];
           31 : select1 = focus_read[4]; 

           32 : select1 = focus_read[6]; 
           33 : select1 = focus_read[7];
           34 : select1 = focus_read[8]; 
           35 : select1 = focus_read[9];
           36 : select1 = focus_read[10]; 

           37 : select1 = focus_read[12]; 
           38 : select1 = focus_read[13];
           39 : select1 = focus_read[14]; 
           40 : select1 = focus_read[15];
           41 : select1 = focus_read[16]; 
           
           42 : select1 = focus_read[18];
           43 : select1 = focus_read[19]; 
           44 : select1 = focus_read[20];
           45 : select1 = focus_read[21]; 
           46 : select1 = focus_read[22];
            
           47 : select1 = focus_read[24];
           48 : select1 = focus_read[25];
           49 : select1 = focus_read[26]; 
           50 : select1 = focus_read[27];
           51 : select1 = focus_read[28]; 
          
           52 : select1 = focus_read[30];
           53 : select1 = focus_read[31]; 
           54 : select1 = focus_read[32];
           55 : select1 = focus_read[33]; 
           56 : select1 = focus_read[34];
           default : select1 = 0;
           
        endcase
    end
    else select1 = 0;
end

always @(*) begin
    if(current_state == FOCUS && count == 2)begin
        case (cnt)
           27 : select2 = focus_read[1]; 
           28 : select2 = focus_read[2];
           29 : select2 = focus_read[3]; 
           30 : select2 = focus_read[4];
           31 : select2 = focus_read[5]; 

           32 : select2 = focus_read[7]; 
           33 : select2 = focus_read[8];
           34 : select2 = focus_read[9]; 
           35 : select2 = focus_read[10];
           36 : select2 = focus_read[11]; 

           37 : select2 = focus_read[13]; 
           38 : select2 = focus_read[14];
           39 : select2 = focus_read[15]; 
           40 : select2 = focus_read[16];
           41 : select2 = focus_read[17]; 
           
           42 : select2 = focus_read[19];
           43 : select2 = focus_read[20]; 
           44 : select2 = focus_read[21];
           45 : select2 = focus_read[22]; 
           46 : select2 = focus_read[23];
            
           47 : select2 = focus_read[25];
           48 : select2 = focus_read[26];
           49 : select2 = focus_read[27]; 
           50 : select2 = focus_read[28];
           51 : select2 = focus_read[29]; 
          
           52 : select2 = focus_read[31];
           53 : select2 = focus_read[32]; 
           54 : select2 = focus_read[33];
           55 : select2 = focus_read[34]; 
           56 : select2 = focus_read[35];
           default : select2 = 0;
           
        endcase
    end
    else select2 = 0;
end

always @(*) begin
    if(current_state == FOCUS && count == 2)begin
        case (cnt)
           29 : select3 = focus_read[0]; 
           30 : select3 = focus_read[1];
           31 : select3 = focus_read[2]; 
           32 : select3 = focus_read[3]; 
           33 : select3 = focus_read[4];
           34 : select3 = focus_read[5]; 
           35 : select3 = focus_read[6];
           36 : select3 = focus_read[7]; 
           37 : select3 = focus_read[8]; 
           38 : select3 = focus_read[9];
           39 : select3 = focus_read[10]; 
           40 : select3 = focus_read[11];
           41 : select3 = focus_read[12]; 
           42 : select3 = focus_read[13];
           43 : select3 = focus_read[14]; 
           44 : select3 = focus_read[15];
           45 : select3 = focus_read[16]; 
           46 : select3 = focus_read[17];
           47 : select3 = focus_read[18];
           48 : select3 = focus_read[19];
           49 : select3 = focus_read[20]; 
           50 : select3 = focus_read[21];
           51 : select3 = focus_read[22]; 
           52 : select3 = focus_read[23];
           53 : select3 = focus_read[24]; 
           54 : select3 = focus_read[25];
           55 : select3 = focus_read[26]; 
           56 : select3 = focus_read[27];
           57 : select3 = focus_read[28];
           58 : select3 = focus_read[29]; 
           
           default : select3 = 0;
           
        endcase
    end
    else select3 = 0;
end

always @(*) begin
    if(current_state == FOCUS && count == 2)begin
        case (cnt)
            29 : select4 = focus_read[6];
            30 : select4 = focus_read[7];
            31 : select4 = focus_read[8];
            32 : select4 = focus_read[9];
            33 : select4 = focus_read[10];
            34 : select4 = focus_read[11];
            35 : select4 = focus_read[12];
            36 : select4 = focus_read[13];
            37 : select4 = focus_read[14];
            38 : select4 = focus_read[15];
            39 : select4 = focus_read[16];
            40 : select4 = focus_read[17];
            41 : select4 = focus_read[18];
            42 : select4 = focus_read[19];
            43 : select4 = focus_read[20];
            44 : select4 = focus_read[21];
            45 : select4 = focus_read[22];
            46 : select4 = focus_read[23];
            47 : select4 = focus_read[24];
            48 : select4 = focus_read[25];
            49 : select4 = focus_read[26];
            50 : select4 = focus_read[27];
            51 : select4 = focus_read[28];
            52 : select4 = focus_read[29];
            53 : select4 = focus_read[30];
            54 : select4 = focus_read[31];
            55 : select4 = focus_read[32];
            56 : select4 = focus_read[33];
            57 : select4 = focus_read[34];
            58 : select4 = focus_read[35];
            default : select4 = 0;
        endcase
    end
    else select4 = 0;
end



// ===============================================================
//  	                       OUTPUT
// ===============================================================
//compare comp_result(.a(focus_map2), .b(focus_map4), .c(focus_map6), .out(focus_result));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        save_focus_result <= 0; 
    end
    else begin
        if (current_state == FOCUS && count == 2 && save_mode == 0)begin
            if(((focus_map2 >> 2)>=(focus_map4>>4)) && ((focus_map2 >> 2)>=(focus_map6/36)))save_focus_result <= 0;
            else if(((focus_map4 >> 4)>(focus_map2 >> 2)) && ((focus_map4 >> 4)>=(focus_map6/36)))save_focus_result <= 1;
            else if(((focus_map6/36)>(focus_map4 >> 4)) && ((focus_map6/36)>(focus_map2 >> 2)))save_focus_result <= 2;
            else save_focus_result <= save_focus_result;
        end
        else if (current_state == OUT)begin 
            save_focus_result <= save_focus_result;
        end
        else save_focus_result <= 0;	
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_valid <= 0;
        out_data <= 0;
    end
    else begin
        if(current_state == OUT && dram_cnt[save_pic_no]==1)begin
            out_valid <= 1;
            out_data <= 0;
        end
        else if(current_state == OUT && save_mode == 0)begin
            if(save_ans[save_pic_no]!=3)begin
                out_valid <= 1;
                out_data <= save_ans[save_pic_no];
            end
            else begin
                out_valid <= 1;
                out_data <= {6'd0, save_focus_result};
            end
        end
        else if(current_state == OUT && save_mode == 1)begin
            if(save_exposure[save_pic_no]!=0)begin
                out_valid <= 1;
                out_data <= save_exposure[save_pic_no];
            end
            else begin
                out_valid <= 1;
                out_data <= save_out >> 10;
            end
        end
        else if(current_state == OUT && save_mode == 2)begin
            if(save_average[save_pic_no]!=0)begin
                out_valid <= 1;
                out_data <= save_average[save_pic_no];
            end
            else begin
                out_valid <= 1;
                out_data <= average/2;
            end
        end
        else begin
            out_valid <= 0;
            out_data <= 0;
        end
    end
end
// ===============================================================
//  	              EXPOSURE PIPELINE
// ===============================================================
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal <= 0; 
        min <= 0;
    end
    else begin
        if((current_state == WAIT || current_state == EXPOSURE) && count == 0)begin 
            cal <= ( read[0]>> 2) + (read[1]>> 2) ; 
            min <= 0;
        end
        else if(current_state == EXPOSURE && count == 1)begin           
            cal <= ( read[0]>> 1) + ( read[1]>> 1) ;
            min <= 0;
        end
        else if (current_state == EXPOSURE && count == 2)begin 
            cal <= ( read[0]>> 2) + ( read[1]>> 2) ;
            min <= 0;
        end 
        else if (current_state == FOCUS)begin
            //if(select1 > select2)cal <= select1;
            //else cal <= select2;
            if(save_mode == 0)begin
                if(select1 > select2)begin
                    cal <= select1;
                    min <= 0;
                end
                else begin
                    cal <= select2;
                    min <= 0;
                end
            end
            else begin
                if(read[0] > read[1])begin
                    cal <= read[0];
                    min <= read[1];
                end
                else begin
                    cal <= read[1];
                    min <= read[0];
                end
            end
        end
        else begin
            cal <= 0;
            min <= 0;	
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal1 <= 0;
        min1 <= 0; 
    end
    else begin
        if((current_state == WAIT || current_state == EXPOSURE) && count == 0)begin 
            cal1 <=( read[2]>> 2) + ( read[3]>> 2); 
            min1 <= 0;
        end
        else if(current_state == EXPOSURE && count == 1)begin           
            cal1 <=( read[2]>> 1) + ( read[3]>> 1);
            min1 <= 0;
        end
        else if (current_state == EXPOSURE && count == 2)begin 
            cal1 <=( read[2]>> 2) + ( read[3]>> 2);
            min1 <= 0;
        end 
        else if (current_state == FOCUS)begin 
            if(save_mode == 0)begin
                if(select1 < select2)begin
                    cal1 <= select1;
                    min1 <= 0;
                end
                else begin
                    cal1 <= select2;
                    min1 <= 0;
                end
            end
            else begin
                if(read[2] > read[3])begin
                    cal1 <= read[2];
                    min1 <= read[3];
                end
                else begin
                    cal1 <= read[3];
                    min1 <= read[2];
                end
            end
        end
        else begin
            cal1 <= 0;	
            min1 <= 0;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        result1 <= 0; 
    end
    else begin
        if (current_state == FOCUS)result1 <= cal - cal1;
        else result1 <= 0;	
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal2 <= 0; 
        min2 <= 0;
    end
    else begin
        if((current_state == WAIT || current_state == EXPOSURE) && count == 0)begin 
            cal2 <=( read[4]>> 2) + ( read[5]>> 2); 
            min2 <= 0;
        end
        else if(current_state == EXPOSURE && count == 1)begin           
            cal2 <=( read[4]>> 1) + ( read[5]>> 1);
            min2 <= 0;
        end
        else if (current_state == EXPOSURE && count == 2)begin 
            cal2 <=( read[4]>> 2) + ( read[5]>> 2);
            min2 <= 0;
        end
        else if (current_state == FOCUS && save_mode == 2)begin 
            if(read[4] > read[5])begin
                    cal2 <= read[4];
                    min2 <= read[5];
            end
            else begin
                    cal2 <= read[5];
                    min2 <= read[4];
            end
        end
        else begin
            cal2 <= 0;	
            min2 <= 0;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal3 <= 0; 
        min3 <= 0;
    end
    else begin
        if((current_state == WAIT || current_state == EXPOSURE) && count == 0)begin 
            cal3 <=( read[6]>> 2) + ( read[7]>> 2);
            min3 <= 0; 
        end
        else if(current_state == EXPOSURE && count == 1)begin           
            cal3 <=( read[6]>> 1) + ( read[7]>> 1);
            min3 <= 0;
        end
        else if (current_state == EXPOSURE && count == 2)begin 
            cal3 <=( read[6]>> 2) + ( read[7]>> 2);
            min3 <= 0;
        end 
        else if (current_state == FOCUS)begin
            if(save_mode == 0)begin
                if(select3 > select4)begin
                    cal3 <= select3;
                    min3 <= 0;
                end
                else begin 
                    cal3 <= select4;
                    min3 <= 0;
                end
            end
            else begin
                if(read[6] > read[7])begin
                    cal3 <= read[6];
                    min3 <= read[7];
                end
                else begin
                    cal3 <= read[7];
                    min3 <= read[6];
                end
            end
        end
        else begin
            cal3 <= 0;
            min3 <= 0;	
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal4 <= 0; 
        min4 <= 0;
    end
    else begin
        if((current_state == WAIT || current_state == EXPOSURE) && count == 0)begin 
            cal4 <= ( read[8]>> 2) + (read[9]>> 2);
            min4 <= 0; 
        end
        else if(current_state == EXPOSURE && count == 1)begin           
            cal4 <= ( read[8]>> 1) + ( read[9]>> 1) ;
            min4 <= 0;
        end
        else if (current_state == EXPOSURE && count == 2)begin 
            cal4 <= ( read[8]>> 2) + ( read[9]>> 2) ;
            min4 <= 0;
        end 
        else if (current_state == FOCUS)begin 
            if(save_mode == 0)begin
                if(select3 < select4)begin
                    cal4 <= select3;
                    min4 <= 0;
                end
                else begin
                    cal4 <= select4;
                    min4 <= 0;
                end
            end
            else begin
                if(read[8] > read[9])begin
                    cal4 <= read[8];
                    min4 <= read[9];
                end
                else begin
                    cal4 <= read[9];
                    min4 <= read[8];
                end
            end
        end
        else begin
            cal4 <= 0;	
            min4 <= 0;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal5 <= 0;
        min5 <= 0; 
    end
    else begin
        if((current_state == WAIT || current_state == EXPOSURE) && count == 0)begin 
            cal5 <= ( read[10]>> 2) + (read[11]>> 2); 
            min5 <= 0;
        end
        else if(current_state == EXPOSURE && count == 1)begin           
            cal5 <= ( read[10]>> 1) + ( read[11]>> 1) ;
            min5 <= 0;
        end
        else if (current_state == EXPOSURE && count == 2)begin 
            cal5 <= ( read[10]>> 2) + ( read[11]>> 2) ;
            min5 <= 0;
        end
        else if (current_state == FOCUS && save_mode == 2)begin 
            if(read[10] > read[11])begin
                    cal5 <= read[10];
                    min5 <= read[11];
            end
            else begin
                    cal5 <= read[11];
                    min5 <= read[10];
            end
        end
        else begin
            cal5 <= 0;
            min5 <= 0;	
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        result2 <= 0; 
    end
    else begin
        if (current_state == FOCUS)result2 <= cal3 - cal4;
        else result2 <= 0;	
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        result3 <= 0; 
    end
    else begin
        if (current_state == FOCUS)result3 <= result1 + result2;
        else result3 <= 0;	
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal6 <= 0;
        min6 <= 0; 
    end
    else begin
        if((current_state == WAIT || current_state == EXPOSURE) && count == 0)begin 
            cal6 <= ( read[12]>> 2) + (read[13]>> 2) ;
            min6 <= 0; 
        end
        else if(current_state == EXPOSURE && count == 1)begin           
            cal6 <= ( read[12]>> 1) + ( read[13]>> 1) ;
            min6 <= 0;
        end
        else if (current_state == EXPOSURE && count == 2)begin 
            cal6 <= ( read[12]>> 2) + ( read[13]>> 2);
            min6 <= 0;
        end 
        else if (current_state == FOCUS && save_mode == 2)begin 
            if(read[12] > read[13])begin
                    cal6 <= read[12];
                    min6 <= read[13];
            end
            else begin
                cal6 <= read[13];
                min6 <= read[12];
            end
        end
        else begin
            cal6 <= 0;
            min6 <= 0;
        end	
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal7 <= 0; 
        min7 <= 0;
    end
    else begin
        if((current_state == WAIT || current_state == EXPOSURE) && count == 0)begin 
            cal7 <= ( read[14]>> 2) + (read[15]>> 2); 
            min7 <= 0;
        end
        else if(current_state == EXPOSURE && count == 1)begin           
            cal7 <= ( read[14]>> 1) + ( read[15]>> 1) ;
            min7 <= 0;
        end
        else if (current_state == EXPOSURE && count == 2)begin 
            cal7 <= ( read[14]>> 2) + ( read[15]>> 2) ;
            min7 <= 0;
        end 
        else if (current_state == FOCUS && save_mode == 2)begin 
            if(read[14] > read[15])begin
                    cal7 <= read[14];
                    min7 <= read[15];
            end
            else begin
                    cal7 <= read[15];
                    min7 <= read[14];
            end
        end
        else begin
            cal7 <= 0;	
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal8 <= 0; 
    end
    else if(current_state == WAIT || current_state == EXPOSURE)begin
        cal8 <= cal + cal1;	
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(cal > cal1)cal8 <= cal;
        else cal8 <= cal1;
    end
    else begin
        cal8 <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal9 <= 0; 
    end
    else if(current_state == WAIT || current_state == EXPOSURE)begin
        cal9 <= cal2 + cal3;	
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(cal2 > cal3)cal9 <= cal2;
        else cal9 <= cal3;
    end
    else begin
        cal9 <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal10 <= 0; 
    end
    else if(current_state == WAIT || current_state == EXPOSURE)begin
        cal10 <= cal4 + cal5;	
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(cal4 > cal5)cal10 <= cal4;
        else cal10 <= cal5;
    end
    else begin
        cal10 <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal11 <= 0; 
    end
    else if(current_state == WAIT || current_state == EXPOSURE)begin
        cal11 <= cal6 + cal7;	
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(cal6 > cal7)cal11 <= cal6;
        else cal11 <= cal7;
    end
    else begin
        cal11 <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal12 <= 0; 
    end
    else if(current_state == WAIT || current_state == EXPOSURE)begin
        cal12 <= cal8 + cal9;	
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(cal8 > cal9)cal12 <= cal8;
        else cal12 <= cal9;
    end
    else begin
        cal12 <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal13 <= 0; 
    end
    else if(current_state == WAIT || current_state == EXPOSURE)begin
        cal13 <= cal10 + cal11;	
    end
    else if ((current_state == FOCUS||current_state == CAL) && save_mode == 2)begin 
        if(cal10 > cal11)cal13 <= cal10;
        else cal13 <= cal11;
    end
    else begin
        cal13 <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cal14 <= 0; 
    end
    else if(current_state == WAIT || current_state == EXPOSURE)begin
        cal14 <= cal12 + cal13;	
    end
    else if ((current_state == FOCUS||current_state == CAL)&& save_mode == 2)begin 
        if(cal12 > cal13)cal14 <= cal12;
        else cal14 <= cal13;
    end
    else begin
        cal14 <= 0;
    end
end


endmodule






/*
module compare(a, b, c,out); // a=0,b=1,c=2;
input [9:0]a;
input [12:0]b;
input [13:0]c;
output reg [1:0]out;

reg [7:0]d;
reg [8:0]e;
reg [8:0]f;

assign d = a >> 2;
assign e = b >> 4;
assign f = c/36;

always@(*)begin
	if(d >= e && d >= f)out = 0;
	else if( e >=f && e > d)out = 1; 
	else if( f > d && f > e)out = 2;
	else out = 3;
end
endmodule*/