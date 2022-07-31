#include <stdint.h>
#include <stdio.h>

/* Compile with c99 */
/* Source by: https://github.com/maeln/zalgo */

uint64_t seed = 1;
uint32_t rand() { return (seed = ((seed * 0x21a7) % 0x7fffffff)); }

uint32_t rand_diacritique() {
  uint32_t base = 0x0300;
  uint32_t acc = rand() % 112;
  return base + acc;
}

void p2bc(uint32_t code) {
  const char utf8[3] = {0xc0 | ((code >> 6) & 0x1f), 0x80 | (code & 0x3f),
                        0x00};
  fputs(utf8, stdout);
}

int main() {
  int c;
  while ((c = getchar()) > 0) {
    putc(c, stdout);
    uint32_t n = rand() % 6;
    while (n--) {
      p2bc(rand_diacritique());
    }
  }
  return 0;
}
