#include <sys/file.h>

int main() {
  return !(LOCK_SH != 0);
}
