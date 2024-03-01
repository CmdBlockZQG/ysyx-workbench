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
  char buf[25];
  buf[0] = '-';
  while (*fmt && t < n - 1) {
    if (*fmt == '%') {
      ++fmt;
      char *src;
      switch (*fmt) {
        case '%':
          src = buf + 1;
          src[0] = '%';
          src[1] = '\0';
          break;
        case 's':
          src = va_arg(ap, char *);
          break;
        case 'd':
        case 'x':
          int x = va_arg(ap, int);
          int base = *fmt == 'd' ? 10 : 16;
          char *p = buf + 1;
          src = x < 0 ? buf : buf + 1; // '-'
          if (x == 0) {
            *p++ = '0';
            *p = '\0';
          } else {
            while (x) {
              int dig = ABS(x % base);
              *p++ = (dig < 10 ? '0' : 'a' - 10) + dig;
              x /= base;
            }
            *p = '\0';
            reverse(buf + 1, p - buf - 1);
          }
          break;
        case 'f':
          
        default:
          panic("Not implemented");
          break;
      }
      ++fmt;
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
