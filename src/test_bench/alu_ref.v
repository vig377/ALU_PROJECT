module alu_refrence #(parameter n = 8, parameter m = 4)
(mode,cmd,opa,opb,cin,inp_valid, exp_res,exp_oflow,exp_cout,exp_g,exp_l,exp_e,exp_err);
 
input mode, cin;
input [1:0] inp_valid;
input [m-1:0] cmd;
input [n-1:0] opa, opb;
 
output reg [2*n-1:0] exp_res;
output reg exp_oflow, exp_cout;
output reg exp_g, exp_l, exp_e;
output reg exp_err;
localparam shift_width=$clog2(n);
wire [shift_width-1:0]rot_amt;
assign rot_amt=opb[shift_width-1:0];
wire [n-1:0] rol_result;
wire [n-1:0] ror_result;
assign rol_result = (opa << rot_amt) | (opa >> (n - rot_amt));
assign ror_result = (opa >> rot_amt) | (opa << (n - rot_amt));
 
reg signed [n:0] sres;
wire signed [n-1:0] A = opa;
wire signed [n-1:0] B = opb;
 
always @(*)
begin
    exp_res    = 0;
    exp_oflow  = 0;
    exp_cout   = 0;
    exp_g      = 0;
    exp_l      = 0;
    exp_e      = 0;
    exp_err    = 0;
    if(mode)
    begin
 
        case(cmd)
        0:
            begin
                if(inp_valid == 2'b11)
                begin
                      exp_res  = opa + opb;
                      exp_cout= ({1'b0, opa} + {1'b0, opb}) > {n{1'b1}};
                end
            else
                exp_err = 1;
        end
        1:
            begin
                 if(inp_valid == 2'b11)
                    begin
                        exp_res = opa - opb;
                        exp_oflow = (opa < opb);
                     end
            else
                exp_err = 1;
        end
        2:
              begin
                    if(inp_valid == 2'b11)
                        begin
                            exp_res = opa+opb+cin;
                            exp_cout= ({1'b0, opa} + {1'b0, opb}+cin) > {n{1'b1}};
                        end
            else
                exp_err = 1;
        end
        3:
        begin
            if(inp_valid == 2'b11)
            begin
                exp_res = opa - opb - cin;
                exp_oflow = ({1'b0,opb}+cin)>opa;
            end
            else
                exp_err = 1;
        end
        4:
        begin
            if(inp_valid == 2'b01||inp_valid == 2'b11)
                exp_res = (opa+1)&{n{1'b1}};
            else
                exp_err = 1;
        end
        5:
        begin
            if(inp_valid == 2'b01||inp_valid == 2'b11)
                exp_res = opa - 1&{n{1'b1}};
            else
                exp_err = 1;
        end
        6:
        begin
            if(inp_valid == 2'b10||inp_valid == 2'b11)
                exp_res = (opb+1)&{n{1'b1}};
            else
                exp_err = 1;
        end
        7:
        begin
            if(inp_valid == 2'b10||inp_valid == 2'b11)
                exp_res = opb - 1;
            else
                exp_err = 1;
        end
        8:
        begin
            if(inp_valid == 2'b11)
            begin
                exp_e = (opa == opb);
                exp_l = (opa < opb);
                exp_g = (opa > opb);
            end
            else
                exp_err = 1;
        end
        9:
        begin
            if(inp_valid == 2'b11)
                exp_res = (opa + 1) * (opb + 1);
            else
                exp_err = 1;
        end
        10:
        begin
            if(inp_valid == 2'b11)
                exp_res = (opa << 1) * opb;
            else
                exp_err = 1;
        end
        11:
        begin
            if(inp_valid == 2'b11)
            begin
                sres = A + B;
                exp_res = sres;
                exp_oflow =(A[n-1] == B[n-1]) &&(sres[n-1] != A[n-1]);
                exp_e = (A == B);
                exp_l = (A < B);
                exp_g = (A > B);
            end
            else
                exp_err = 1;
        end
        12:
        begin
            if(inp_valid == 2'b11)
            begin
                sres = A - B;
                exp_res = sres;
                exp_oflow =(A[n-1] != B[n-1]) &&(sres[n-1] != A[n-1]);
                exp_e = (A == B);
                exp_l = (A < B);
                exp_g = (A > B);
            end
            else
                exp_err = 1;
        end
 
        default:
        begin
            exp_res = 0;
            exp_err = 1;
        end
 
        endcase
    end
    else
    begin
 
        case(cmd)
        0:
        begin
            if(inp_valid == 2'b11)
                exp_res = opa & opb;
            else
                exp_err = 1;
        end
        1:
        begin
            if(inp_valid == 2'b11)
                exp_res = { {n{1'b0}}, ~(opa & opb) };
            else
                exp_err = 1;
        end
        2:
        begin
            if(inp_valid == 2'b11)
                exp_res = { {n{1'b0}},opa | opb};
            else
                exp_err = 1;
        end
        3:
        begin
            if(inp_valid == 2'b11)
                exp_res = { {n{1'b0}},~(opa | opb)};
            else
                exp_err = 1;
        end
        4:
        begin
            if(inp_valid == 2'b11)
                exp_res = { {n{1'b0}},opa ^ opb};
            else
                exp_err = 1;
        end
        5:
        begin
            if(inp_valid == 2'b11)
                exp_res = { {n{1'b0}},~(opa ^ opb)};
            else
                exp_err = 1;
        end
        6:
        begin
            if(inp_valid == 2'b01||inp_valid==2'b11)
                exp_res = { {n{1'b0}},~opa};
            else
                exp_err = 1;
        end
        7:
        begin
            if(inp_valid == 2'b10||inp_valid == 2'b11)
                exp_res = { {n{1'b0}},~opb};
            else
                exp_err = 1;
        end
        8:
        begin
            if(inp_valid == 2'b01||inp_valid == 2'b11)
                exp_res = { {n{1'b0}},opa >> 1};
            else
                exp_err = 1;
        end
        9:
        begin
            if(inp_valid == 2'b01||inp_valid == 2'b11)
                exp_res = { {n{1'b0}},opa << 1};
            else
                exp_err = 1;
        end
        10:
        begin
            if(inp_valid == 2'b10||inp_valid == 2'b11)
                exp_res = { {n{1'b0}},opb >> 1};
            else
                exp_err = 1;
        end
        11:
        begin
            if(inp_valid == 2'b10||inp_valid == 2'b11)
                exp_res = { {n{1'b0}},opb << 1};
            else
                exp_err = 1;
        end
        12:
        begin
            if(inp_valid == 2'b11)
            begin
               exp_err = |opb[n-1:n/2];
                    if(rot_amt==0)
                        exp_res= opa;
                    else
                        exp_res= {{n{1'b0}}, rol_result};
            end
            else
                exp_err = 1;
        end
        13:
        begin
            if(inp_valid == 2'b11)
            begin
               exp_err = |opb[n-1:n/2];
                    if(rot_amt==0)
                        exp_res= opa;
                    else
                        exp_res= {{n{1'b0}}, ror_result};
            end
            else
                exp_err = 1;
        end
 
        default:
        begin
            exp_res = 0;
            exp_err = 1;
        end
 
        endcase
    end
end
 

endmodule