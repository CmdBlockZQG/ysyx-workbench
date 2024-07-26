#include <fcntl.h>
#include <unistd.h>

#define SDL_malloc  malloc
#define SDL_free    free
#define SDL_realloc realloc

#define SDL_STBIMAGE_IMPLEMENTATION
#include "SDL_stbimage.h"

SDL_Surface* IMG_Load_RW(SDL_RWops *src, int freesrc) {
  assert(src->type == RW_TYPE_MEM);
  assert(freesrc == 0);

  size_t sz = src->size(src);
  void *buf = malloc(sz);
  src->seek(src, 0, RW_SEEK_SET);
  src->read(src, buf, sz, 1);

  SDL_Surface *res = STBIMG_LoadFromMemory(buf, sz);
  free(buf);
  return res;
}

SDL_Surface* IMG_Load(const char *filename) {
  int fd = open(filename, O_RDONLY);
  size_t sz = lseek(fd, 0, SEEK_END);
  void *buf = malloc(sz);
  lseek(fd, 0, SEEK_SET);

  size_t bytes_left = sz;
  while (bytes_left) {
    bytes_left -= read(fd, buf + sz - bytes_left, bytes_left);
  }

  SDL_Surface *res = STBIMG_LoadFromMemory(buf, sz);
  free(buf);
  close(fd);
  return res;
}

int IMG_isPNG(SDL_RWops *src) {
  uint64_t t;
  src->seek(src, 0, RW_SEEK_SET);
  src->read(src, &t, 8, 1);
  return t == 0x0A1A0A0D474E5089;
}

SDL_Surface* IMG_LoadJPG_RW(SDL_RWops *src) {
  return IMG_Load_RW(src, 0);
}

char *IMG_GetError() {
  return "Navy does not support IMG_GetError()";
}
