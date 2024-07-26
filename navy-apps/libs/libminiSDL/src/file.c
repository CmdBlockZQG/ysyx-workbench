#include <sdl-file.h>
#include <stdlib.h>

static int64_t f_size(SDL_RWops *f) {
  int64_t pos = ftell(f->fp);
  fseek(f->fp, 0, SEEK_END);
  int64_t res = ftell(f->fp);
  fseek(f->fp, pos, SEEK_SET);
  return res;
}

static int64_t f_seek(SDL_RWops *f, int64_t offset, int whence) {
  fseek(f->fp, offset, whence);
  return ftell(f->fp);
}

static size_t f_read(SDL_RWops *f, void *buf, size_t size, size_t nmemb) {
  return fread(buf, size, nmemb, f->fp);
}

static size_t f_write(SDL_RWops *f, const void *buf, size_t size, size_t nmemb) {
  return fwrite(buf, size, nmemb, f->fp);
}

static int f_close(SDL_RWops *f) {
  fclose(f->fp);
  free(f);
  return 0;
}

SDL_RWops* SDL_RWFromFile(const char *filename, const char *mode) {
  SDL_RWops *f = malloc(sizeof(SDL_RWops));
  f->fp = fopen(filename, mode);
  f->size = f_size;
  f->seek = f_seek;
  f->read = f_read;
  f->write = f_write;
  f->close = f_close;
  f->type = RW_TYPE_FILE;
  return f;
}

SDL_RWops* SDL_RWFromMem(void *mem, int size) {
  SDL_RWops *f = malloc(sizeof(SDL_RWops));
  f->fp = fmemopen(mem, size, "rb+");
  f->size = f_size;
  f->seek = f_seek;
  f->read = f_read;
  f->write = f_write;
  f->close = f_close;
  f->type = RW_TYPE_MEM;
  return f;
}
