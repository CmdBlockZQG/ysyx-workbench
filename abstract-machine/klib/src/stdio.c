#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  return vsnprintf(out, -1, fmt, ap);
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int t = vsprintf(out, fmt, ap);
  va_end(ap);
  return t;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int t = vsnprintf(out, n, fmt, ap);
  va_end(ap);
  return t;
}

static void reverse(char *s, size_t n) {
  char t;
  for (int i = 0; i < (n >> 1); ++i) {
    t = s[i];
    s[i] = s[n - i - 1];
    s[n - i - 1] = t;
  }
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  size_t t = 0;
  char buf[25];
  buf[0] = '-';
  while (*fmt && t < n) {
    if (*fmt == '%') {
      ++fmt;
      char *src;
      if (!strncmp(fmt, "s", 1)) {
        ++fmt;
        src = va_arg(ap, char *);
      } else if (!strncmp(fmt, "d", 1)) {
        ++fmt;
        int x = va_arg(ap, int);
        char *p = buf + 1;
        src = x < 0 ? buf : buf + 1; // '-'
        while (x) {
          *p++ = '0' + x % 10;
          x /= 10;
        }
        *p = '\0';
        reverse(buf + 1, p - buf - 1);
      } else {
        panic("Not implemented");
      }
      while (*src && t <= n) *out++ = *src++, ++t;
    } else {
      *out++ = *fmt++;
      ++t;
    }
  }
  if (t < n) *out = '\0';
  return t;
}

#endif
