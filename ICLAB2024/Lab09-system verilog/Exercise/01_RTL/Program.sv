module Program(input clk, INF.Program_inf inf);
import usertype::*;
//================================================================
// typedef 
//================================================================
typedef enum logic [3:0]{
    IDLE,
    WAIT_READ_DRAM,
    /* index_check */
    INDEX_CHECK,

    /* date_valid_check */
    WAIT,
    WAIT_UPDATE,
    DATE_CHECK,
    /* update */
    UPDATE,
    WAITE_WRITE_BACK,
    WRITE_BACK,
    WAITE_BVALID,
	OUT
} state;
/*
typedef union packed{ 
    Action [35:0] d_act;  // 2
    Formula_Type [23:0] d_formula;  // 3
    Mode [35:0] d_mode;  // 2
    Date [7:0] d_date;  // 9
    Data_No [8:0] d_data_no;  // 8
    Index [5:0] d_index;  // 12
} Data;
*/
//================================================================
//                        reg & wire 
//================================================================
state current_state, next_state;
Action save_action;
Date save_date;
Warn_Msg warning;
Data_Dir data_dram;
Formula_Type save_formula;
Mode save_mode;

integer i;
logic [11:0]save_d_index[3:0];
logic [11:0]one, two, three, four, update_cal, sort_wire1, sort_wire2, sort_wire3, sort_wire4, save_R;
logic [13:0]R;
logic d1, d2, d3, d4;
logic [7:0]data_addr;
logic [63:0]data;
logic date_violation,mode_flag,update_flag_a,update_flag_b,update_flag_c,update_flag_d, flag;
logic [2:0]count, cnt;
logic [1:0]index_cnt;
//================================================================
//                          assign 
//================================================================
//assign inf.AR_ADDR = {6'b100000, data_addr,3'b000};
//assign inf.AW_ADDR = {6'b100000, data_addr,3'b000};
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) inf.AR_ADDR <= 0;
    else begin
        inf.AR_ADDR <= {6'b100000, data_addr,3'b000};
    end
end
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) inf.AW_ADDR <= 0;
    else begin
        inf.AW_ADDR <= {6'b100000, data_addr,3'b000};
    end
end
//================================================================
//                           FSM
//================================================================
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) current_state <= IDLE;
    else current_state <= next_state;
end

always_comb begin
    case(current_state)
        IDLE : begin
            if(inf.data_no_valid)next_state = WAIT_READ_DRAM;
            else next_state = IDLE;
        end
        WAIT_READ_DRAM : begin
            if(inf.AR_READY)begin
                if(save_action == Index_Check)next_state = INDEX_CHECK;
                else if(save_action == Update) next_state = UPDATE;
                else if(save_action == Check_Valid_Date) next_state = DATE_CHECK;
                else next_state = WAIT_READ_DRAM;
            end
		    else begin
                next_state = WAIT_READ_DRAM;
            end
        end
        
        INDEX_CHECK : begin
            if((save_formula == Formula_A) || (save_formula == Formula_B) || (save_formula == Formula_C) || (save_formula == Formula_D))begin
                if(cnt == 5 && count > 3)next_state = WAIT;
                else next_state = INDEX_CHECK;
            end
            else begin
                if(index_cnt == 3)next_state = WAIT;
                else next_state = INDEX_CHECK; 
            end
        end
        DATE_CHECK : begin
            if(inf.R_VALID)next_state = WAIT;
            else next_state = DATE_CHECK;
        end
        WAIT : begin
            next_state = OUT;
        end
        WAIT_UPDATE : begin
            next_state = WAITE_WRITE_BACK;
        end
        UPDATE : begin
            if(count==5 && inf.R_VALID)next_state = WAIT_UPDATE;
            else next_state = UPDATE;
        end
        WAITE_WRITE_BACK : begin
            if(inf.AW_READY)next_state = WRITE_BACK;
            else next_state = WAITE_WRITE_BACK;
        end
        WRITE_BACK : begin 
            if(inf.W_READY)next_state = WAITE_BVALID;
            else next_state = WRITE_BACK;
        end

        WAITE_BVALID : begin
            if(inf.B_VALID)next_state = OUT;
            else next_state = WAITE_BVALID;
        end

        OUT : begin
            next_state = IDLE;
        end
        default : begin
            next_state = IDLE;
        end
    endcase
end

//================================================================
//                         AXI_DRAM 
//================================================================
/* read */
always_ff @( posedge clk or negedge inf.rst_n) begin 
    if (!inf.rst_n) inf.AR_VALID <= 0;
    else begin
        case(next_state)		
            WAIT_READ_DRAM: inf.AR_VALID <= 1;
            default: inf.AR_VALID <= 0;
        endcase
    end
end

always_comb begin   
    case(current_state)		
        //UPDATE,DATE_CHECK,INDEX_CHECK: inf.R_READY <= 1;
        WAIT: inf.R_READY = 1;
        WAIT_UPDATE: inf.R_READY = 1;
        default: inf.R_READY = 0;
    endcase
end

always_comb begin   
    case(current_state)		
        WAITE_WRITE_BACK: inf.AW_VALID <= 1;
        default: inf.AW_VALID <= 0;
    endcase
end

always_comb begin     
    case(current_state)		
        WRITE_BACK : inf.W_VALID = 1;
        default: inf.W_VALID = 0;
    endcase
end

always_ff @( posedge clk or negedge inf.rst_n) begin   
    if(!inf.rst_n)inf.B_READY <= 0;  
    else begin
        case(current_state)
            WRITE_BACK : inf.B_READY <= 1; 
            //WAIT : inf.B_READY <= 1;
            WAITE_BVALID : begin		
                inf.B_READY <= 1;
            end
            OUT : begin
                if(inf.B_VALID==0) inf.B_READY <= 0;
                else inf.B_READY<= inf.B_READY;
            end
            default : inf.B_READY <= 0;
        endcase
    end
end
//================================================================
//                       save action
//================================================================
/* action */
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) save_action<= 0;
    else begin
        if(inf.sel_action_valid) save_action<= inf.D.d_act[0];
		else save_action<= save_action;
	end
end
/* data_no */
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) data_addr <= 0;
    else begin
		if(inf.data_no_valid) data_addr <= inf.D.d_data_no[0];
		else data_addr <= data_addr;
	end
end
/* date */
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) save_date <= 0;
    else begin
		if(inf.date_valid)begin 
            save_date.M <= inf.D.d_date[0][8:5];
			save_date.D <= inf.D.d_date[0][4:0];
        end
		else begin
            save_date <= save_date;
        end
	end
end
/* formula */
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) save_formula <= 0;
    else begin
		if(inf.formula_valid) save_formula <= inf.D.d_formula[0];
		else save_formula <= save_formula;
	end
end
/* mode */
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) save_mode <= 0;
    else begin
		if(inf.mode_valid) save_mode <= inf.D.d_mode[0];
		else save_mode <= save_mode;
	end
end


always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n)begin
        for(i=0;i<4;i=i+1)begin
            save_d_index[i] <= 0;
        end
    end
    else if(current_state == IDLE)begin
        for(i=0;i<4;i=i+1)begin
            save_d_index[i] <= 0;
        end
    end
    else begin
        if(inf.index_valid)begin
            if(count==0)save_d_index[0] <= inf.D.d_index[0];
            else if(count==1)save_d_index[1] <= inf.D.d_index[0];
            else if(count==2)save_d_index[2] <= inf.D.d_index[0];
            else if(count==3)save_d_index[3] <= inf.D.d_index[0];
            else save_d_index <= save_d_index;
        end
		else save_d_index <= save_d_index;
    end
end

//================================================================
//                   count
//================================================================
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n)begin
        count <= 0;
    end
    else if(current_state==IDLE)count <= 0;
    else if(current_state==DATE_CHECK)count <= count + 1;
    else begin
        if(inf.index_valid) count <= count + 1;
        else if(count==4)count <= 5;
		else count <= count;
    end
end
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n)begin
        cnt <= 0;
    end
    else if(current_state==IDLE)cnt <= 0;
    else if(inf.R_VALID)begin
        if(cnt==5)cnt<=cnt;
        else cnt <= cnt + 1;
    end
    else begin
        cnt<=0; 
    end
end

always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n)begin
        index_cnt <= 0;
    end
    else if(cnt>=4 && count>=4)begin
        index_cnt <= index_cnt + 1;
    end
    else begin
        index_cnt <= 0; 
    end
end

//================================================================
//                   data in dram 
//================================================================

always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n)begin
        data_dram <= 0;
    end
    else begin
        case(current_state)
            IDLE : data_dram <= 0;
            INDEX_CHECK,UPDATE,DATE_CHECK : begin
                data_dram.M <= inf.R_DATA[39:32];
                data_dram.D <= inf.R_DATA[7:0];
                data_dram.Index_A <= inf.R_DATA[63:52];
                data_dram.Index_B <= inf.R_DATA[51:40];
                data_dram.Index_C <= inf.R_DATA[31:20]; 
                data_dram.Index_D <= inf.R_DATA[19:8];
            end
            default : data_dram <= data_dram;
        endcase
    end
end

//================================================================
//                    Write Back Dram
//================================================================

always_comb begin
    if(current_state == WRITE_BACK)begin
        inf.W_DATA[39:32] = {4'd0, save_date.M};
        inf.W_DATA[7:0] = {3'd0, save_date.D};

        if(save_d_index[0] <= 11'd2047)begin
            inf.W_DATA[63:52] = ((data_dram.Index_A + save_d_index[0]) > 4095) ? 4095 : data_dram.Index_A + save_d_index[0];
        end
        else begin
            inf.W_DATA[63:52] = ((data_dram.Index_A + save_d_index[0]) <= 4095) ? 0 : data_dram.Index_A + save_d_index[0] - 13'd4096;
        end
        
        if(save_d_index[1] <= 11'd2047)begin
            inf.W_DATA[51:40] = ((data_dram.Index_B + save_d_index[1]) > 4095) ? 4095 : data_dram.Index_B + save_d_index[1];
        end
        else begin
            inf.W_DATA[51:40] = ((data_dram.Index_B + save_d_index[1]) <= 4095) ? 0 : data_dram.Index_B + save_d_index[1] - 13'd4096;
        end
        
        if(save_d_index[2] <= 11'd2047)begin
            inf.W_DATA[31:20] = ((data_dram.Index_C + save_d_index[2]) > 4095) ? 4095 : data_dram.Index_C + save_d_index[2];
        end
        else begin
            inf.W_DATA[31:20] = ((data_dram.Index_C + save_d_index[2]) <= 4095) ? 0 : data_dram.Index_C + save_d_index[2] - 13'd4096;
        end

        if(save_d_index[3] <= 11'd2047)begin
            inf.W_DATA[19:8] = ((data_dram.Index_D + save_d_index[3]) > 4095) ? 4095 : data_dram.Index_D + save_d_index[3];
        end
        else begin
            inf.W_DATA[19:8] = ((data_dram.Index_D + save_d_index[3]) <= 4095) ? 0 : data_dram.Index_D + save_d_index[3] - 13'd4096;
        end
    end
    else begin
        inf.W_DATA = 0;
    end
end

always_comb begin
    if(current_state == WRITE_BACK)begin
        //A
        if(save_d_index[0] < 2048)begin
            if((save_d_index[0] + data_dram.Index_A) > 4095)update_flag_a = 1;
            else update_flag_a = 0;
        end
        else begin
            if((save_d_index[0] + data_dram.Index_A) <= 4095)update_flag_a = 1;
            else update_flag_a = 0;
        end
		
    end
    else update_flag_a = 0;
end

always_comb begin
    if(current_state == WRITE_BACK)begin
        if(save_d_index[1] < 2048)begin  
            if((save_d_index[1] + data_dram.Index_B) > 4095)update_flag_b = 1;
            else update_flag_b = 0;
        end
        else begin
            if((save_d_index[1] + data_dram.Index_B) <= 4095)update_flag_b = 1;
            else update_flag_b = 0;
        end
    end
    else update_flag_b = 0;
end

always_comb begin
    if(current_state == WRITE_BACK)begin
        if(save_d_index[2] < 2048)begin
            if((save_d_index[2] + data_dram.Index_C) > 4095)update_flag_c = 1;
            else update_flag_c = 0;
        end 
        else begin
            if((save_d_index[2] + data_dram.Index_C) <= 4095)update_flag_c = 1;
            else update_flag_c = 0;
        end
    end
    else update_flag_c = 0;
end

always_comb begin
    if(current_state == WRITE_BACK)begin
        if(save_d_index[3] < 2048)begin
            if((save_d_index[3] + data_dram.Index_D) > 4095)update_flag_d = 1;
            else update_flag_d = 0;
        end
        else begin
            if((save_d_index[3] + data_dram.Index_D) <= 4095)update_flag_d = 1;
            else update_flag_d = 0;
        
        end
    end
    else update_flag_d = 0;
end


//================================================================
//                    Index Check Formula
//================================================================
always_comb begin
    if(current_state == INDEX_CHECK)begin
    case(save_formula)
        Formula_B, Formula_C, Formula_A,Formula_D: begin
            sort_wire1 = data_dram.Index_A;
            sort_wire2 = data_dram.Index_B;
            sort_wire3 = data_dram.Index_C;
            sort_wire4 = data_dram.Index_D;
        end
        Formula_G, Formula_H, Formula_F: begin
            if(save_d_index[0] > data_dram.Index_A)sort_wire1 = save_d_index[0] - data_dram.Index_A;
            else sort_wire1 = data_dram.Index_A - save_d_index[0];

            if(save_d_index[1] > data_dram.Index_B)sort_wire2 = save_d_index[1] - data_dram.Index_B;
            else sort_wire2 = data_dram.Index_B - save_d_index[1];

            if(save_d_index[2] > data_dram.Index_C)sort_wire3 = save_d_index[2] - data_dram.Index_C;
            else sort_wire3 = data_dram.Index_C - save_d_index[2];

            if(save_d_index[3] > data_dram.Index_D)sort_wire4 = save_d_index[3] - data_dram.Index_D;
            else sort_wire4 = data_dram.Index_D - save_d_index[3];
        end
        default : begin
            sort_wire1 = 0;
            sort_wire2 = 0;
            sort_wire3 = 0;
            sort_wire4 = 0;
        end
    endcase
    end
    else begin
        sort_wire1 = 0;
        sort_wire2 = 0;
        sort_wire3 = 0;
        sort_wire4 = 0;
    end
end

sort4(.a(sort_wire1), .b(sort_wire2), .c(sort_wire3), .d(sort_wire4), .first(one), .second(two), .third(three), .min(four));

always_comb begin
    if(current_state == IDLE)begin
        d1 = 0;
        d2 = 0;
        d3 = 0;
        d4 = 0;
    end
    else begin
        if(count > 3 && cnt !=0 )begin
            d1 = (data_dram.Index_A >= save_d_index[0])?1:0;
            d2 = (data_dram.Index_B >= save_d_index[1])?1:0;
            d3 = (data_dram.Index_C >= save_d_index[2])?1:0;
            d4 = (data_dram.Index_D >= save_d_index[3])?1:0;
        end
        else begin
            d1 = 0;
            d2 = 0;
            d3 = 0;
            d4 = 0;
        end
    end
end



always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n)begin
        R <= 0;
    end
    else begin
        if(current_state == IDLE)begin
            R <= 0;
        end
        else if(current_state == INDEX_CHECK)begin
            case(save_formula)
                Formula_A : begin
                    if(cnt == 1)R <= sort_wire1;
                    else if(cnt == 2)R <= R + sort_wire2;
                    else if(cnt == 3)R <= R + sort_wire3;
                    else if(cnt == 4)R <= R + sort_wire4;
                    //else if(cnt == 5)R <= R >> 2;
                    else begin
                        R <= R;
                    end
                end
                Formula_B : begin
                    if(cnt < 4)R <= one;
                    else if(cnt == 4)R <= R - four;
                    else R <= R;
                end
                Formula_C : begin
                    R <= four;
                end
                Formula_D : begin
                    if(cnt == 1 && (sort_wire1 >= 2047))R <= R + 1;
                    else if(cnt == 2 && (sort_wire2 >= 2047))R <= R + 1;
                    else if(cnt == 3 && (sort_wire3 >= 2047))R <= R + 1;
                    else if(cnt == 4 && (sort_wire4 >= 2047))R <= R + 1;
                    else begin
                        R <= R;
                    end
                end
                Formula_E : begin
                    if(count >= 4 && cnt >= 4)begin
                        if(index_cnt==0)R <= d1;
                        else if(index_cnt==1)R <= R + d2;
                        else if(index_cnt==2)R <= R + d3;
                        else if(index_cnt==3)R <= R + d4;
                        else R <= R;
                    end
                    else R <= R;
                end 
                Formula_F : begin
                    if(count >= 4 && cnt >= 4)begin
                        if(index_cnt==0)R <= four;
                        else if(index_cnt==1)R <= R + three;
                        else if(index_cnt==2)R <= R + two;
                         else if(index_cnt==3)R <= R/3;
                        else R <= R;
                    end
                    else R <= R;
                    
                end
                Formula_G : begin
                    if(count >= 4 && cnt >= 4)begin
                        if(index_cnt==0)R <= (four>>1);
                        else if(index_cnt==1)R <= R + (three>>2);
                        else if(index_cnt==2)R <= R + (two>>2);
                        else R <= R;
                    end
                    else R <= R;
                end
                Formula_H : begin
                    if(count >= 4 && cnt >= 4)begin
                        if(index_cnt==0)R <= sort_wire1;
                        else if(index_cnt==1)R <= R + sort_wire2;
                        else if(index_cnt==2)R <= R + sort_wire3;
                        else if(index_cnt==3)R <= R + sort_wire4;
                        else R <= R;
                    end
                    else R <= R;
                end
            endcase
        end
    end
end

//================================================================
//                         warning
//================================================================
always_comb begin
    date_violation = ({save_date.M , save_date.D} < {inf.R_DATA[35:32],inf.R_DATA[4:0]})? 1:0;
end

always_comb begin
    if(save_action == Index_Check)begin
    case(current_state)
    WAIT : begin
        if(save_mode == Insensitive)begin
            case(save_formula)
                Formula_A : begin
                    if((R>>2)>=2047)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_B : begin
                    if(R>=800)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_C : begin
                    if(R>=2047)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_D : begin
                    if(R>=3)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_E : begin
                    if(R>=3)mode_flag = 1;
                    else mode_flag = 0;
                end 
                Formula_F : begin
                    if(R>=800)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_G : begin
                    if(R>=800)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_H : begin
                    if((R>>2)>=800)mode_flag = 1;
                    else mode_flag = 0;
                end
            endcase
        end
        else if(save_mode == Normal && count==5)begin
            case(save_formula)
                Formula_A : begin
                    if((R>>2)>=1023)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_B : begin
                    if(R>=400)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_C : begin
                    if(R>=1023)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_D : begin
                    if(R>=2)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_E : begin
                    if(R>=2)mode_flag = 1;
                    else mode_flag = 0;
                end 
                Formula_F : begin
                    if(R>=400)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_G : begin
                    if(R>=400)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_H : begin
                    if((R>>2)>=400)mode_flag = 1;
                    else mode_flag = 0;
                end
            endcase
        end
        else if(save_mode ==  Sensitive && count==5)begin
            case(save_formula)
                Formula_A : begin
                    if((R>>2)>=511)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_B : begin
                    if(R>=200)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_C : begin
                    if(R>=511)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_D : begin
                    if(R>=1)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_E : begin
                    if(R>=1)mode_flag = 1;
                    else mode_flag = 0;
                end 
                Formula_F : begin
                    if(R>=200)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_G : begin
                    if(R>=200)mode_flag = 1;
                    else mode_flag = 0;
                end
                Formula_H : begin
                    if((R>>2)>=200)mode_flag = 1;
                    else mode_flag = 0;
                end
            endcase
        end
        else mode_flag = 0;
    end
    default : mode_flag = 0;
    endcase
    end
    else mode_flag = 0;
end

always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) warning <= No_Warn;
    else begin
		
		if(current_state == IDLE)warning <= No_Warn;
		else if(current_state == WAIT && save_action == Index_Check)begin
                if(date_violation) warning <= Date_Warn;
                else if(mode_flag) warning <= Risk_Warn;
                //if(mode_flag) warning <= Risk_Warn;
                //else if(date_violation) warning <= Date_Warn;
                else warning <= warning;
        end    
        else if(current_state == WRITE_BACK)begin
                if(update_flag_a || update_flag_b ||update_flag_c || update_flag_d) warning <= Data_Warn;
                else warning <= warning;
        end
        else if(current_state == DATE_CHECK)begin
            if(date_violation) warning <= Date_Warn;
            else warning <= warning;
        end
		else warning <= warning;	

		
	end
end
//================================================================
//                         OUTPUT
//================================================================

always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) inf.out_valid <= 0;
    else begin
        if(current_state == OUT)inf.out_valid <= 1;
        else inf.out_valid <= 0;
    end
end
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) inf.warn_msg <= 0;
    else begin
        if(current_state == OUT)inf.warn_msg <= warning;
        else inf.warn_msg <= No_Warn;
    end
end
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) inf.complete <= 0;
    else begin
        if(current_state == OUT && warning == No_Warn)inf.complete <= 1;
        else inf.complete <= 0;
    end
end
endmodule


module sort4(a, b, c, d, first, second, third, min);
    input [11:0]a, b, c, d;
    output reg[11:0]first,second,third,min;
    reg[11:0]t0,t1,t2,t3,t4,t5;
    always_comb begin
        t0 = (a > c) ? a : c; 
        t2 = (a > c) ? c : a; 
        t1 = (b > d) ? b : d; 
        t3 = (b > d) ? d : b; 
        first  = (t0 > t1) ? t0 : t1; 
        t4 = (t0 > t1) ? t1 : t0; 
        min   = (t2 > t3) ? t3 : t2;
        t5 = (t2 > t3) ? t2 : t3;
        second = (t4 > t5) ? t4 : t5;
        third = (t4 > t5) ? t5 : t4;   
    end
endmodule