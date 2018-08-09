module ppu_bg
(
  input wire clk_in,
  input wire rst_in,
  input wire enable_in,      //is_enable
  input wire ls_clip_in,
  input wire [ 2:0] fv_in,
  input wire [ 4:0] vt_in,
  input wire        v_in,
  input wire [ 2:0] fh_in,
  input wire        h_in,
  input wire [ 4:0] ht_in,
  input wire        bg_pt_lr_in,
  input wire [ 9:0] nes_x,          //the current x
  input wire [ 9:0] nes_y,          //the current y
  input wire [ 9:0] nes_y_next,     //the next y
//  input wire [ 7:0] scroll_x_pos,
//  input wire [ 7:0] scroll_y_pos,
//  input wire [ 1:0] base_nt,
  input wire        pix_pulse_in,
  input wire [ 7:0] vram_d_in,
  input wire        ri_upd_cntrs_in,
  input wire        ri_inc_addr_in,
  input wire        ri_inc_addr_amt_in,
//  input wire        bg_pattern,    //the screen pattern        
  output reg [13:0] vram_a_out,    //the vram address out
  output wire [ 9:0] sys_palette_idx//the palette idx
);

reg [ 1:0] q_shift_bits2_reg, d_shift_bits2_reg;         //attribute table
reg [ 1:0] q_shift_bits3_reg, d_shift_bits3_reg;         //attribute table
reg [15:0] q_shift_bits0_reg, d_shift_bits0_reg;         //pattern table
reg [15:0] q_shift_bits1_reg, d_shift_bits1_reg;         //pattern table 

//reg [ 1:0] q_nt, d_nt;
reg         q_bg_pt_lr, d_bg_pt_lr;              //which nametable 
reg [ 1:0]  q_at, d_at;                      //which attributetable
reg [ 3:0]  q_pt0, d_pt0;                    //which patterntable
reg [ 3:0]  q_pt1, d_pt1;                    //which patterntable
reg [ 3:0]  q_pattern_idx, d_pattern_idx;    //which pattern it's in
reg         q_v, d_v;
reg         q_h, d_h;
reg  [ 4:0] q_vt, d_vt;
reg  [ 4:0] q_ht, d_ht;
reg  [ 2:0] q_fv, d_fv;
reg  [ 2:0] q_fh, d_fh;
reg         add_x_pos, add_y_pos;

always @(posedge clk_in)
    begin
    if(rst_in)
        begin
            q_shift_bits2_reg <= 2'b00;
            q_shift_bits3_reg <= 2'b00;
            q_shift_bits0_reg <= 4'h0;
            q_shift_bits1_reg <= 4'h0;
            q_pattern_idx <= 4'h0;
            add_x_pos <= 1'b0;
            add_y_pos <= 1'b0;
            q_v <= 1'b0;
            q_h <= 1'b0;
            q_vt <= 4'h0;
            q_ht <= 4'h0;
            q_fv <= 2'b00;
            q_fh <= 2'b00;   
        end
    else
        begin
            q_shift_bits2_reg <= d_shift_bits2_reg;
            q_shift_bits3_reg <= d_shift_bits3_reg;
            q_shift_bits0_reg <= d_shift_bits0_reg;
            q_shift_bits1_reg <= d_shift_bits1_reg;
            q_pattern_idx <= d_pattern_idx;
            q_v <= d_v;
            q_h <= d_h;
            q_vt <= d_vt;
            q_ht <= d_ht;
            q_fv <= d_fv;
            q_fh <= d_fh;
        end
    end

//
//the pos increment
//



always @*
   begin
    d_v = q_v;
    d_h = q_h;
    d_vt = q_vt;
    d_ht = q_ht;
    d_fv = q_fv;
    d_fh = q_fh;
    
    if(ri_inc_addr_in)
        begin
            if(ri_inc_addr_amt_in)
                {d_fv, d_v, d_h, d_vt, d_ht } =  {d_fv, d_v, d_h, d_vt, d_ht} + 15'h0001;//it's from ri, so it all depends on ri 
            else
                {d_fv, d_v, d_h, d_vt, d_ht} = {d_fv,d_v, d_h, d_vt, d_ht} + 15'b000000000100000;
        end
    else
        begin
        if(add_y_pos)
            begin
                if({q_vt, q_fv} == 8'b11101111)
                    begin
                        if(q_v == 1'b1)
                            {d_v, d_vt, d_fv} = {1'b0, 8'h00};
                        if(q_v == 1'b0)
                            {d_v, d_vt, d_fv} = {1'b1, 8'h00}; 
                    end
                else
                    begin
                        {d_v, d_vt, d_fv} = {q_v, q_vt, q_fv} + 9'h001;
                    end
            end
       if(add_x_pos)
            begin
                {d_h, d_ht, d_fh} = {q_h, q_ht, q_fh} + 9'h001;
            end
       end     

   end

    

//
//vram address make
//

reg [ 2:0] vram_sel_in;//it's to choose what
parameter vram_read_nt = 0;
parameter vram_read_at = 1;
parameter vram_read_pt0 = 2;
parameter vram_read_pt1 = 3;

always @*
    begin
        case (vram_sel_in)
            vram_read_nt:
                begin
                    vram_a_out = { 2'b10, q_v, q_h, q_vt, q_ht};
                end
            vram_read_at:
                begin
                    vram_a_out = { 2'b10, q_v, q_h, 4'b1111, q_vt[ 4:2], q_ht[ 4:2]};
                end
            vram_read_pt0:
                begin
                    vram_a_out = { 1'b0, q_bg_pt_lr, q_pattern_idx , 1'b0, q_fv };
                end
            vram_read_pt1:
                begin
                    vram_a_out = { 1'b0, q_bg_pt_lr, q_pattern_idx, 1'b1, q_fv };
                end
            default:
               begin
                    vram_a_out = {d_fv[1:0], d_v, d_h, d_vt, d_ht };//it's the address from 
               end 
        endcase
    end


//
//plattes num
//



always @*
begin
    d_shift_bits2_reg = q_shift_bits2_reg;//at
    d_shift_bits3_reg = q_shift_bits3_reg;//at
    d_shift_bits0_reg = q_shift_bits0_reg;//pt0
    d_shift_bits1_reg = q_shift_bits1_reg;//pt1
    d_at = q_at;
    d_pattern_idx = q_pattern_idx;
    d_pt0 = q_pt0;
    d_pt1 = q_pt1;
    vram_sel_in = 3'b111;
    if(pix_pulse_in & enable_in)
        begin
            if(nes_y < 239 || nes_y_next == 0)         //when the scanline is 0 - 239
                begin
                    if(nes_y != nes_y_next)
                        add_y_pos = 1; 
                    if(nes_x < 256 || (nes_x > 320 && nes_x < 336))//when the circle is  1 - 256 \\ 321 - 336
                        begin
                        add_x_pos = 1;
                            if(nes_x[ 2:0] == 7)//which means we need to get the next
                                begin
                                   d_shift_bits2_reg = {q_shift_bits2_reg[1], q_at[1:0]};//move to the right and let the new at in
                                   d_shift_bits3_reg = {q_shift_bits3_reg[1], q_at[1:0]};//move to the right and let the new at in
                                   
                                   d_shift_bits0_reg[8] = q_pt0[7];
                                   d_shift_bits0_reg[9] = q_pt0[6];
                                   d_shift_bits0_reg[10] = q_pt0[5];
                                   d_shift_bits0_reg[11] = q_pt0[4];
                                   d_shift_bits0_reg[12] = q_pt0[3];
                                   d_shift_bits0_reg[13] = q_pt0[2];
                                   d_shift_bits0_reg[14] = q_pt0[1];
                                   d_shift_bits0_reg[15] = q_pt0[0];
                                   
                                   d_shift_bits1_reg[8] = q_pt1[7];
                                   d_shift_bits1_reg[9] = q_pt1[6];
                                   d_shift_bits1_reg[10] = q_pt1[5];
                                   d_shift_bits1_reg[11] = q_pt1[4];
                                   d_shift_bits1_reg[12] = q_pt1[3];
                                   d_shift_bits1_reg[13] = q_pt1[2];
                                   d_shift_bits1_reg[14] = q_pt1[1];
                                   d_shift_bits1_reg[15] = q_pt1[0];
                                end
                            else
                                begin
                                    //the at dont have to change
                                    d_shift_bits0_reg = {1'b0, q_shift_bits0_reg[15:1]};//move to the right
                                    d_shift_bits1_reg = {1'b0, q_shift_bits1_reg[15:1]};//move to the right
                                end
                        end
                end
                
            case (nes_x[2:0])
                3'b000://this time it read 
                    begin
                        vram_sel_in = vram_read_nt;
                        d_pattern_idx = vram_d_in;
                    end
                3'b001:
                    begin
                        vram_sel_in = vram_read_at;
                        d_at = vram_d_in >> {q_vt[1], q_ht[1]};//to get the bits in which block of 1 byte
                    end
                3'b010:
                    begin
                        vram_sel_in = vram_read_pt0;
                        d_pt0 = vram_d_in;
                    end
                3'b011:
                    begin
                        vram_sel_in = vram_read_pt1;
                        d_pt1 = vram_d_in;
                    end 
            endcase 
        end
end


assign sys_palette_idx = {1'b0, q_shift_bits3_reg[fh_in], q_shift_bits2_reg[fh_in], q_shift_bits1_reg[fh_in], q_shift_bits0_reg[fh_in]};


endmodule

