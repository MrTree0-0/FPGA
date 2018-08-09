module ppu_ri
(
  
  input wire        clk_in,                     
  input wire        rst_in,
  input wire [ 2:0] sel_in,                             //which ri
  input wire        ncs_in,                               //when it goes from high to low, it means we can do something to register
  input wire        r_nw_in,                                //read or write
  input wire [ 7:0] d_in,     //cpu_d_in                  //the input data from CPU which changes the ri's value
  input wire        vbl_in,  //vblank_in                  //vblank in
  input wire [ 7:0] spr_ram_d_in,                           
  input wire        spr_overflow_in,
  input wire        spr_pri_col_in,
  input wire [13:0] vram_a_in,
  input wire [ 7:0] vram_d_in,
  input wire [ 7:0] pram_d_in,
  
  output wire[ 7:0]   d_out, //cpu_d_out
  output reg [ 7:0] vram_d_out,
  output reg        pram_wr_out,         
  output reg        vram_wr_out, //vram_wr_out            //ram write or not 
  output wire        v_out,
  output wire        h_out,
  output wire [ 2:0] fv_out,
  output wire [ 4:0] vt_out,
  output wire [ 2:0] fh_out,
  output wire [ 4:0] ht_out,
  output wire        bg_pt_lr_out,   //s_out           //background pattern table is right half or left half
  output reg        inc_addr_out,
  output wire        inc_addr_amt_out,
  output wire        nvbl_en_out,
  output wire        vblank_out,
  output wire        bg_enable_out,  //bg_en_out          //background enable out 
  output wire        spr_enable_out,
  output wire        bg_ls_clip_out,
  output wire        spr_ls_clip_out,
  output wire        spr_h_out,
  output wire        spr_pt_sel_out,
  output wire [ 7:0] spr_ram_a_out,
  output reg  [ 7:0] spr_ram_d_out,
  output reg         spr_ram_wr_out,
  output wire        upd_cntrs_out
);


reg q_ncs_in;                                   //last register enable
reg q_add_cnt, d_add_cnt;                       //to know the num of which turn of address
reg q_v, d_v;
reg q_h, d_h;
reg q_spr_pt_sel, d_spr_pt_sel;
reg q_spr_h_out, d_spr_h_out;
reg q_bg_pt_lr, d_bg_pt_lr;
reg q_inc_amt, d_inc_amt;
reg q_nbvl_en, d_nbvl_en;
reg [ 2:0] q_fv, d_fv;
reg [ 2:0] q_fh, d_fh;
reg [ 4:0] q_vt, d_vt;
reg [ 4:0] q_ht, d_ht;
reg q_nvbl_en, d_nvbl_en;
reg q_bg_ls_clip, d_bg_ls_clip;
reg q_spr_ls_clip, d_spr_ls_clip;
reg q_bg_enable, d_bg_enable;
reg q_spr_enable, d_spr_enable;
reg [ 7:0] q_spr_ram_a, d_spr_ram_a;
reg [13:0] q_vram_a, d_vram_a;                 
reg [ 7:0] q_d_out, d_d_out;
reg q_vblank, d_vblank;




//every clock d and q
always @(posedge clk_in)
    begin 
    if(rst_in)
        begin
            q_ncs_in <= 1'b1;
            q_add_cnt <= 1'b0;
            q_v <= 1'b0;
            q_h <= 1'b0;
            q_spr_pt_sel <= 1'b0;
            q_spr_h_out <= 1'b0;
            q_bg_pt_lr <= 1'b0;
            q_inc_amt <= 1'b0;
            q_nbvl_en <= 1'b0;
            q_fv <= 4'h0;
            q_fh <= 4'h0;
            q_vt <= 5'h00;
            q_ht <= 5'h00;
            q_bg_ls_clip <= 1'b0;
            q_spr_ls_clip <= 1'b0;
            q_bg_enable <= 1'b0;
            q_spr_enable <= 1'b0;
            q_spr_ram_a <= 16'h0000;
            q_vram_a <= 14'h0000;
            q_d_out <= 7'h0;
            q_vblank <= 1'b0;
        end
    else
        begin
            q_ncs_in <= ncs_in;
            q_add_cnt <= d_add_cnt;
            q_v <= d_v;
            q_h <= d_h;
            q_spr_pt_sel <= d_spr_pt_sel;
            q_spr_h_out <= d_spr_h_out;
            q_bg_pt_lr <= d_bg_pt_lr;
            q_inc_amt <= d_inc_amt;
            q_nbvl_en <= d_nbvl_en;
            q_fv <= d_fv;
            q_fh <= d_fh;
            q_vt <= d_vt;
            q_ht <= d_ht;
            q_bg_ls_clip <= d_bg_ls_clip;
            q_spr_ls_clip <= d_spr_ls_clip;
            q_bg_enable <= d_bg_enable;
            q_spr_enable <= d_spr_enable;
            q_spr_ram_a <= d_spr_ram_a;
            q_vram_a <= d_vram_a;
            q_d_out <= d_d_out;
            q_vblank <= d_vblank;
        end
    
    end




always @*
    begin
            d_add_cnt = q_add_cnt;
            d_v = q_v;
            d_h = q_h;
            d_spr_pt_sel = q_spr_pt_sel;
            d_spr_h_out = q_spr_h_out;
            d_bg_pt_lr = q_bg_pt_lr;
            d_inc_amt = q_inc_amt;
            d_nbvl_en = q_nbvl_en;
            d_fv = q_fv;
            d_fh = q_fh;
            d_vt = q_vt;
            d_ht = q_ht;
            d_bg_ls_clip = q_bg_ls_clip;
            d_spr_ls_clip = q_spr_ls_clip;
            d_bg_enable = q_bg_enable;
            d_spr_enable = q_spr_enable;
            d_spr_ram_a = q_spr_ram_a;
            d_vram_a = q_vram_a;
            d_d_out = q_d_out;
            d_vblank = q_vblank;
            
            vram_d_out = 8'h00;
            pram_wr_out = 8'h00;
            vram_wr_out = 1'b0;
            inc_addr_out = 1'b0;
            spr_ram_d_out = 8'h00;
            spr_ram_wr_out = 8'h0;
            
            q_vblank = (~q_vblank && vbl_in) ? 1'b1: (q_vblank) ? q_vblank : 1'b0;
    
    if(q_ncs_in & ~ncs_in)              //from high to low means we can read the ri
        begin
            if(r_nw_in)                 //it is going to write
                begin
                    case (sel_in)
                        3'h2:
                            begin
                                //d_d_out
                                d_d_out[7] = {q_vblank, spr_pri_col_in, spr_overflow_in, 5'h00000};
                            end
                        3'h4:
                            begin
                                d_d_out = spr_ram_d_in;
                            end
                        3'h7:
                            begin
                                d_d_out = vram_d_in;
                                inc_addr_out = 1'b1;
                            end
                            
                      endcase
                end
            else                        //it is going to read
                begin
                    case (sel_in)
                        3'h0://2000
                            begin
                                d_v = d_in[1];//get the base vertical nametable
                                d_h = d_in[0];
                                d_inc_amt = d_in[2];
                                d_spr_pt_sel = d_in[3];
                                d_bg_pt_lr = d_in[4];//the 4th bit
                                d_spr_h_out = d_in[5];
                                d_nvbl_en = d_in[7];
                            end
                        3'h1://2001
                            begin
                                d_bg_ls_clip = d_in[1];
                                d_spr_ls_clip = d_in[2];
                                d_bg_enable = d_in[3];
                                d_spr_enable = d_in[4];
                            end
                        3'h3://2003 which write the sprite memory address
                            begin
                                d_spr_ram_a = d_in;
                            end
                        3'h4://2004 which mains to output sprite memory data
                            begin
                                spr_ram_d_out = d_in;
                                spr_ram_wr_out = 1'b1;
                            end
                        3'h5://2005
                            begin
                                if(q_add_cnt)//which means it is the second write
                                    begin
                                        d_vt = d_in[7:3];
                                        d_fv = d_in[2:0];
                                        d_add_cnt = 1'h0;
                                    end
                                else
                                    begin
                                        d_vt = d_in[7:3];
                                        d_fv = d_in[2:0];
                                        d_add_cnt = 1'h1;
                                    end
                            end 
                        3'h6:
                            begin
                                if(q_add_cnt)//which means it is the second wirte
                                    begin
                                        d_vram_a[13:8] = d_in[5:0];
                                        d_add_cnt = 1'h1;
                                    end
                                else
                                    begin
                                        d_vram_a[7:0] = d_in;
                                        d_add_cnt = 1'h0;
                                    end
                            end
                        3'h7://2007 CPU use this ri to change the vram
                            begin
                                vram_wr_out = 1'b1;
                                vram_d_out = d_in;
                                inc_addr_out = 1'b1;
                            end
                                   
                    endcase
                end
   
        end
    end


            
assign d_out = (~ncs_in & r_nw_in)?q_d_out:8'h00;
assign v_out = q_v;
assign h_out = q_h;
assign spr_pt_sel_out = q_spr_pt_sel;
assign spr_h_out = q_spr_h_out;
assign fv_out = q_fv;
assign vt_out = q_vt;
assign fh_out = q_fh;
assign ht_out = q_ht;
assign bg_pt_lr_out = q_bg_pt_lr;
assign bg_ls_clip_out = q_bg_ls_clip;
assign spr_ls_clip_out = q_spr_ls_clip;
assign spr_ram_a_out = q_spr_ram_a;
assign inc_addr_amt_out = q_inc_amt;
assign nvbl_en_out = q_nvbl_en;
assign vblank_out = q_vblank;
assign bg_enable_out = 1;
assign spr_enable_out = 1;

endmodule

