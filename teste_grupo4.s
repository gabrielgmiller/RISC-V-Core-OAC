    .text
    .globl _start
_start:
    addi x1, x0, 7     # x1 = 7
    sb   x1, 0(x0)     # mem[0] = 7
    lb   x2, 0(x0)     # x2 = 7
    sub  x3, x2, x1    # x3 = 0
    and  x4, x2, x1    # x4 = 7
    ori  x5, x3, 1     # x5 = 1
    srl  x6, x5, x0    # x6 = 1
    beq  x6, x5, fim   # pula para fim
    add  x7, x0, x0    # não executa
fim:
    j fim              # loop infinito