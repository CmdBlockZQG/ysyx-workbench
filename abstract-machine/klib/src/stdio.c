#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

#define ABS(x) ((x) < 0 ? -(x) : (x))

static void write_char(char **p, char c) {
  if (*p) *(*p)++ = c;
  else putch(c);
}

static void reverse(char *s, size_t n) {
  char t;
  for (int i = 0; i < (n >> 1); ++i) {
    t = s[i];
    s[i] = s[n - i - 1];
    s[n - i - 1] = t;
  }
}

static int vtnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  size_t t = 0;
  char int_buf[25];
  int_buf[0] = '-';
  while (*fmt && t < n - 1) {
    if (*fmt == '%') {
      ++fmt;
      char *src;
      if (!strncmp(fmt, "s", 1)) {
        ++fmt;
        src = va_arg(ap, char *);
      } else if (!strncmp(fmt, "d", 1)) {
        ++fmt;
        int x = va_arg(ap, int);
        char *p = int_buf + 1;
        src = x < 0 ? int_buf : int_buf + 1; // '-'
        if (x == 0) {
          *p++ = '0';
          *p = '\0';
        } else {
          while (x) {
            *p++ = '0' + ABS(x % 10);
            x /= 10;
          }
          *p = '\0';
          reverse(int_buf + 1, p - int_buf - 1);
        }
      } else {
        panic("Not implemented");
      }
      while (*src && t < n - 1) write_char(&out, *src++), ++t;
    } else {
      write_char(&out, *fmt++);
      ++t;
    }
  }
  write_char(&out, '\0');
  return t;
}

int printf(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int t = vtnprintf(NULL, -1, fmt, ap);
  va_end(ap);
  return t;
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

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  return vtnprintf(out, n, fmt, ap);
}

#endif
