#include <stdio.h>

// só isso:
int main() {
  int senha, n, t;
  scanf("%d %d", &senha, &n);
  printf("initial begin\n");
  printf("  mem[0] = 8'h00; mem[1] = 8'h00; mem[2] = 8'h00; mem[3] = 8'h%02X;\n", senha);
  printf("  mem[4] = 8'h00; mem[5] = 8'h00; mem[6] = 8'h00; mem[7] = 8'h%02X;\n", n);
  for (int i = 0; i < n; i++) {
    scanf("%d", &t);
    printf("  // tentativa %d\n", i+1);
    printf("  mem[%d] = 8'h%02X;\n", 8 + i, t);
  }
  printf("  // flag final\n");
  printf("  mem[%d] = 8'h01;\n", 8 + n);
  printf("end\n");
  return 0;
}
