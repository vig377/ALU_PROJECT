module alu_param #(parameter n=4,m=4 )(OPA,OPB,CIN,CLK,RST,CE,MODE,INP_VALID,CMD,ERR,RES,OFLOW,COUT,G,L,E);
input [n-1:0]OPA,OPB;
input CIN,CLK,RST,CE,MODE;
input [1:0]INP_VALID;
input [m-1:0]CMD;
output reg ERR,OFLOW,COUT,G,L,E;
output reg [2*n-1:0]RES;
reg [2*n-1:0]temp_res,temp_res_2;
reg [1:0]count,count_2,count_3,count_4;
localparam shift_width=$clog2(n);
wire [shift_width-1:0]rot_amt;
assign rot_amt=OPB[shift_width-1:0];
wire [n-1:0] rol_result;
wire [n-1:0] ror_result;
reg signed [n:0] sres;

assign rol_result = (OPA << rot_amt) | (OPA >> (n - rot_amt));
assign ror_result = (OPA >> rot_amt) | (OPA << (n - rot_amt));

reg ERR_d, OFLOW_d, COUT_d, G_d, L_d, E_d;
reg [2*n-1:0] RES_d;

always@(posedge CLK or posedge RST)
begin
if(RST)
begin
ERR_d   <= 1'b0;
RES_d   <= {2*n{1'b0}};
COUT_d  <= 1'b0;
OFLOW_d <= 1'b0;
G_d     <= 1'b0;
L_d     <= 1'b0;
E_d     <= 1'b0;
ERR  <= 1'b0;
RES  <= {2*n{1'b0}};
COUT <= 1'b0;
OFLOW<= 1'b0;
G    <= 1'b0;
L    <= 1'b0;
E    <= 1'b0;
count   <= 2'd0;
count_2 <= 2'd0;
count_3 <= 2'd0;
count_4 <= 2'd0;
temp_res   <= 1'b0;
temp_res_2 <= 1'b0;
end
else if(CE)
begin
ERR   <= ERR_d;
RES   <= RES_d;
COUT  <= COUT_d;
OFLOW <= OFLOW_d;
G     <= G_d;
L     <= L_d;
E     <= E_d;
ERR_d   <= 1'b0;
RES_d   <= {2*n{1'b0}};
COUT_d  <= 1'b0;
OFLOW_d <= 1'b0;
G_d     <= 1'b0;
L_d     <= 1'b0;
E_d     <= 1'b0;

if(MODE)
begin
case(CMD)
0:begin
    if(INP_VALID==2'b11)
        begin
         RES_d  <= OPA + OPB;
         COUT_d <= ({1'b0, OPA} + {1'b0, OPB}) > {n{1'b1}};
        end
    else
        ERR_d <= 1'b1;
    end
1:begin
    if(INP_VALID==2'b11)
        begin
            if(OPB>OPA)
            begin
            RES_d <= OPA-OPB;
               OFLOW_d <= 1;
            end
            else
               RES_d <= OPA-OPB;
        end
    else
        ERR_d <= 1'b1;
    end
2:begin
    if(INP_VALID==2'b11)
        begin
            RES_d  <= OPA+OPB+CIN;
            COUT_d <= ({1'b0, OPA} + {1'b0, OPB}) > {n{1'b1}};
        end
    else
        ERR_d <= 1'b1;
   end
3:begin
    if(INP_VALID==2'b11)
        begin
            RES_d   <= OPA-OPB-CIN;
            OFLOW_d <= ({1'b0,OPB}+CIN)>OPA;
        end
    else
        ERR_d <= 1'b1;
    end
4:begin
    if(INP_VALID==2'b01||INP_VALID==2'b11)
        begin
          RES_d <= OPA+1'b1&{n{1'b1}};
         end
    else
        ERR_d <= 1'b1;
   end
5:begin
    if(INP_VALID==2'b01||INP_VALID==2'b11)
        begin
            RES_d <= OPA-1'b1&{n{1'b1}};
        end
    else
        ERR_d <= 1'b1;
   end
6:begin
    if(INP_VALID==2'b10||INP_VALID==2'b11)
        RES_d <= OPB+1'b1&{n{1'b1}};
    else
        ERR_d <= 1'b1;
    end
7:begin
    if(INP_VALID==2'b10||INP_VALID==2'b11)
        begin
            RES_d <= OPB-1'b1&{n{1'b1}};
        end
    else
        ERR_d <= 1'b1;
   end
8:begin
     if(INP_VALID==2'b11)
        begin
            if(OPA==OPB)
                E_d <= 1'b1;
            else if(OPA>OPB)
                G_d <= 1'b1;
            else
                L_d <= 1'b1;
        end
      else
        ERR_d <= 1'b1;
  end
9:begin
     if(INP_VALID==2'b11)
        begin
            if(count==0)
            begin
                temp_res<=((OPA+1)*(OPB+1));
                count<=count+1;
            end
            else if(count ==2'd2)
                begin
                    RES<=temp_res;
                    temp_res<=((OPA+1)*(OPB+1));
                    count<=2'd1;
                end
            else
                count<=count+1;
        end
     else
        begin
            if(count_3==2'd2)
            begin
                ERR<=1'b1;
            end
            else
                count_3<=count_3+1;
        end
  end
10:begin
     if(INP_VALID==2'b11)
        begin
            if(count_2==0)
            begin
               temp_res_2<=((OPA<<1)*(OPB));
               count_2<=count_2+1;
            end
            else if(count_2 ==2'd2)
                begin
                    RES<=temp_res_2;
                    temp_res_2<=((OPA<<1)*(OPB));
                      count_2<=2'd1;
                end
            else
                count_2<=count_2+1;
        end
     else
           begin
            if(count_4==2'd2)
               begin
                ERR<=1'b1;
               end
            else
                count_4<=count_4+1;
        end
  end
11: begin
    if (INP_VALID == 2'b11) begin
        sres = $signed(OPA) + $signed(OPB);
        RES_d <= sres;
        OFLOW_d <= (OPA[n-1] == OPB[n-1]) && (sres[n-1] != OPA[n-1]);
        if ($signed(OPA) > $signed(OPB))
            G_d <= 1'b1;
        else if ($signed(OPA) < $signed(OPB))
            L_d <= 1'b1;
        else
            E_d <= 1'b1;
    end
    else begin
        ERR_d <= 1'b1;
    end
end
12: begin
    if (INP_VALID == 2'b11) begin
        sres = $signed(OPA) - $signed(OPB);
        RES_d <= sres;
        OFLOW_d <= (OPA[n-1] != OPB[n-1]) && (sres[n-1] != OPA[n-1]);
        if ($signed(OPA) > $signed(OPB))
            G_d <= 1'b1;
        else if ($signed(OPA) < $signed(OPB))
            L_d <= 1'b1;
        else
            E_d <= 1'b1;
    end
    else begin
        ERR_d <= 1'b1;
    end
end
default: ERR_d <= 1'b1;
endcase
end
else if(!MODE)
begin
    case(CMD)
        0: begin
            if(INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},(OPA & OPB)};
            else
                ERR_d <= 1'b1;
        end
        1: begin
            if(INP_VALID == 2'b11)
                RES_d <={{n{1'b0}}, ~(OPA & OPB)};
            else
                ERR_d <= 1'b1;
        end
        2: begin
            if(INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},OPA | OPB};
            else
                ERR_d <= 1'b1;
        end
        3: begin
            if(INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},~(OPA | OPB)};
            else
                ERR_d <= 1'b1;
        end
        4: begin
            if(INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},OPA ^ OPB};
            else
                ERR_d <= 1'b1;
        end
        5: begin
            if(INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},~(OPA ^ OPB)};
            else
                ERR_d <= 1'b1;
        end
        6: begin
            if(INP_VALID == 2'b01||INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},~OPA};
            else
                ERR_d <= 1'b1;
        end
        7: begin
            if(INP_VALID == 2'b10||INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},~OPB};
            else
                ERR_d <= 1'b1;
        end
        8: begin
            if(INP_VALID == 2'b01||INP_VALID == 2'b11)
                RES_d <={{n{1'b0}}, OPA >> 1};
            else
                ERR_d <= 1'b1;
        end
        9: begin
            if(INP_VALID == 2'b01||INP_VALID == 2'b11)
                RES_d <={{n{1'b0}}, OPA << 1};
            else
                ERR_d <= 1'b1;
        end
        10: begin
            if(INP_VALID == 2'b10||INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},OPB >> 1};
            else
                ERR_d <= 1'b1;
        end
        11: begin
            if(INP_VALID == 2'b10||INP_VALID == 2'b11)
                RES_d <= {{n{1'b0}},OPB << 1};
            else
                ERR_d <= 1'b1;
        end
        12:begin
            if(INP_VALID==2'b11)
                begin
                    ERR_d <= |OPB[n-1:n/2];
                    if(rot_amt==0)
                        RES_d <= OPA;
                    else
                        RES_d <= {{n{1'b0}}, rol_result};
                end
           else
                begin
                    ERR_d <= 1'b1;
                    RES_d <= {n{1'b0}};
                end
           end
        13:begin
            if(INP_VALID==2'b11)
                begin
                    ERR_d <= |OPB[n-1:n/2];
                    if(rot_amt==0)
                        RES_d <= OPA;
                    else
                        RES_d <= {{n{1'b0}}, ror_result};
                end
           else
                begin
                    ERR_d <= 1'b1;
                    RES_d <= {n{1'b0}};
                end
           end
        default: ERR_d <= 1'b1;
    endcase
end
end
end
endmodule
