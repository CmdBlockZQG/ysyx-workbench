#include <stdio.h>
#include <sys/time.h>
#include <assert.h>

int main() {
  int cnt = 0;
  long lstu = 0;
  
  while (1) {
    struct timeval tv;
    assert(gettimeofday(&tv, NULL) == 0);
    if (tv.tv_usec - lstu >= 500000) {
      printf("-0.5s x%d\n", ++cnt);
      lstu = tv.tv_usec;
    }
  }

  return 0;
}
