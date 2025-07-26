module ALU_Control (
    input        ALUOp1,    // de ControlUnit: 1→R‐type, 0→I/Load/Store/Branch
    input        ALUOp0,    // de ControlUnit: 1→Branch (beq), 0→outros
    input  [3:0] funct,     // {funct7[5], funct3[2:0]}
    output [3:0] operation  // código de operação para a ALU
);

    // sinais intermediários
    wire isR  = ALUOp1 & ~ALUOp0;  // instruções R‐type
    wire isB  = ~ALUOp1 &  ALUOp0;  // branches (beq)
    wire isI  = ~ALUOp1 & ~ALUOp0;  // loads, stores e I‐type (ori, lb)

    wire [2:0] f3   = funct[2:0];  // funct3
    wire       f7_5 = funct[3];    // bit 5 de funct7

    // detectores de cada operação
    wire sel_add = (isR & (f3 == 3'b000) & ~f7_5) | isI; // ADD se R‐type com funct3=000 e funct7[5]=0, ou qualquer I‐type (lw, lb, ori→mas só ori usa OR na ALU)
    wire sel_sub =  isR & (f3 == 3'b000) &  f7_5;       // SUB se R‐type com funct3=000 e funct7[5]=1
    wire sel_and =  isR & (f3 == 3'b111);               // AND se funct3=111
    wire sel_or  =  isR & (f3 == 3'b110);               // OR  se funct3=110
    wire sel_srl =  isR & (f3 == 3'b101) & ~f7_5;       // SRL se funct3=101 e funct7[5]=0
    wire sel_ori =  isI & (f3 == 3'b110);               // ORI se I‐type (ALUOp=00) e funct3=110

    // montagem do código de operação ‟operation[3:0]”  
    //      ADD  = 0010  
    //      SUB  = 0110  
    //      AND  = 0000  
    //      OR   = 0001  
    //      SRL  = 0101  
    //      ORI  = 0001 (mesmo código de OR)

    // bit 3 sempre 0 para todas essas operações
    assign operation[3] = 1'b0;

    // bit 2 = 1 em ADD e SUB
    or  (operation[2], sel_add, sel_sub);

    // bit 1 = 1 em SUB e AND
    or  (operation[1], sel_sub, sel_and);

    // bit 0 = 1 em OR, SRL e ORI
    or  (operation[0], sel_or, sel_srl, sel_ori);

endmodule