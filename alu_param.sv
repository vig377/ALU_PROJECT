module alu_param #(parameter n=8,m=4 )(OPA,OPB,CIN,CLK,RST,CE,MODE,INP_VALID,CMD,ERR,RES,OFLOW,COUT,G,L,E);
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

assign rol_result = (OPA << rot_amt) | (OPA >> (n - rot_amt));
assign ror_result = (OPA >> rot_amt) | (OPA << (n - rot_amt));

always@(posedge CLK or posedge RST)
begin
if(RST)
begin
ERR<=1'b0;
RES<={{2*n}{1'b0}};
COUT<=1'b0;
OFLOW<=1'b0;
G<=1'b0;
L<=1'b0;
E<=1'b0;
count<=2'd0;
count_2<=2'd0;
temp_res<=1'b0;
temp_res_2<=1'b0;
end
else if(CE)
begin
ERR<=1'b0;
RES<={{2*n}{1'b0}};
COUT<=1'b0;
OFLOW<=1'b0;
G<=1'b0;
L<=1'b0;
E<=1'b0;

if(MODE)
begin
case(CMD)
0:begin
    if(INP_VALID==2'b11)
        begin
            RES<=OPA+OPB;
          
        end
    else
            ERR<=1'b1;
    end
1:begin
    if(INP_VALID==2'b11)
        begin
            RES<=OPA-OPB;
            if(OPB>OPA)
               OFLOW<=1;
            else
               RES<=OPA-OPB;
        end
    else
        ERR<=1'b1;
    end
2:begin
    if(INP_VALID==2'b11)
        begin
            RES<=OPA+OPB+CIN;
            COUT<=RES[n];
        end
    else
        ERR<=1'b1;
   end
3:begin
    if(INP_VALID==2'b11)
        begin
            RES<=OPA-OPB-CIN;
            OFLOW<=(OPB>OPA)?1:0;
        end
    else
        ERR<=1'b1;
    end
4:begin
    if(INP_VALID==2'b01)
        begin
          RES<=OPA+1'b1;
         end
    else
        ERR<=1'b1;
   end
5:begin
    if(INP_VALID==2'b01)
        begin
            
                RES<=OPA-1'b1;
        end
    else
        ERR<=1'b1;
   end
6:begin
    if(INP_VALID==2'b10)    
        RES<=OPB+1'b1;
    else
        ERR<=1'b1;
    end
7:begin
    if(INP_VALID==2'b10)
        begin
          
                RES<=OPB-1'b1;
        end
    else
        ERR<=1'b1;
   end
8:begin
     if(INP_VALID==2'b11)
        begin
            if(OPA==OPB)
            begin
                E<=1'b1;
            end
        else if(OPA>OPB)
          begin
            G<=1'b1;
         end
        else
        begin
            L<=1'b1;
        end
        end
      else
        ERR<=1'b1;
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
                    temp_res<=0;
                    count<=2'd0;
                end
            else
                count<=count+1;
        end
     else
        begin
            if(count_3==2'd1)
                ERR<=1'b1;
            else
                count_3<=count_3+1;
        end
  end
10:begin
     if(INP_VALID==2'b11)
        begin
            if(count_2==0)
               temp_res_2<=((OPA<<1)*(OPB));
            else if(count_2 ==2'd2)
                begin
                    RES<=temp_res_2;
                    temp_res_2<=0;
                      count_2<=2'd0;
                end
            else
                count_2<=count_2+1;
        end
     else
           begin
            if(count_4==2'd1)
                ERR<=1'b1;
            else
                count_4<=count_4+1;
        end
  end    
11: begin
    if (INP_VALID == 2'b11) begin
        RES <= $signed(OPA) + $signed(OPB);
        OFLOW <= (OPA[n-1] == OPB[n-1]) && (RES[n-1] != OPA[n-1]);
        COUT <= RES[n];
    if ($signed(OPA) > $signed(OPB)) begin
            G <= 1'b1;
        end
        else if ($signed(OPA) < $signed(OPB)) begin
            L<=1'b1;
        end
        else begin
            E<=1'b1;
        end
    end
    else begin
        ERR <= 1'b1;
    end
end
12: begin
    if (INP_VALID == 2'b11) begin
        RES <= $signed(OPA) - $signed(OPB);
        OFLOW <= (OPA[n-1] != OPB[n-1]) && (RES[n-1] != OPA[n-1]);
        COUT <= RES[n];
        if ($signed(OPA) > $signed(OPB))
        begin
            G <= 1'b1;
         end
        else if ($signed(OPA) < $signed(OPB))
         begin
            L <= 1'b1;  
          end
        else
        begin
            E <= 1'b1;
        end
    end
    else begin
        ERR <= 1'b1;
    end
end
default:ERR<=1'b1;
endcase
end
else if(!MODE)
begin
    case(CMD)
        0: begin 
            if(INP_VALID == 2'b11)
                RES <= OPA & OPB;
            else
                ERR <= 1'b1;
        end

        1: begin 
            if(INP_VALID == 2'b11)
                RES <= ~(OPA & OPB);
            else
                ERR <= 1'b1;
        end

        2: begin 
            if(INP_VALID == 2'b11)
                RES <= OPA | OPB;
            else
                ERR <= 1'b1;
        end

        3: begin  
            if(INP_VALID == 2'b11)
                RES <= ~(OPA | OPB);
            else
                ERR <= 1'b1;
        end

        4: begin 
            if(INP_VALID == 2'b11)
                RES <= OPA ^ OPB;
            else
                ERR <= 1'b1;
        end

        5: begin  
            if(INP_VALID == 2'b11)
                RES <= ~(OPA ^ OPB);
            else
                ERR <= 1'b1;
        end

        6: begin  
            if(INP_VALID == 2'b01)
                RES <= ~OPA;
            else
                ERR <= 1'b1;
        end

        7: begin 
            if(INP_VALID == 2'b10)
                RES <= ~OPB;
            else
                ERR <= 1'b1;
        end

        8: begin  
            if(INP_VALID == 2'b01)
                RES <= OPA >> 1;
            else
                ERR <= 1'b1;
        end

        9: begin  
            if(INP_VALID == 2'b01)
                RES <= OPA << 1;
            else
                ERR <= 1'b1;
        end

        10: begin  
            if(INP_VALID == 2'b10||INP_VALID == 2'b11)
                RES <= OPB >> 1;
            else
                ERR <= 1'b1;
        end

        11: begin  
            if(INP_VALID == 2'b10||INP_VALID == 2'b11)
                RES <= OPB << 1;
            else
                ERR <= 1'b1;
        end
        12:begin
            if(INP_VALID==2'b11)
                begin 
                    ERR<=|OPB[n-1:n/2];
                if(rot_amt==0)
                    RES<=OPA;
                else
                  RES <= {{n{1'b0}}, rol_result};
                end
           else
                begin
                    ERR<=1'b1;
                    RES<={n{1'b0}};
                end
           end
      13:begin
            if(INP_VALID==2'b11)
                begin 
                    ERR<=|OPB[n-1:n/2];
                if(rot_amt==0)
                    RES<=OPA;
                else
                     RES <= {{n{1'b0}}, ror_result};
                end
           else
                begin
                    ERR<=1'b1;
                    RES<={n{1'b0}};
                end
           end
                    
        default: ERR<= 1'b1;
      

    endcase
end
end
end
endmodule
