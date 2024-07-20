#include <NDL.h>
#include <SDL.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>

#define SBUF_SIZE 64

static void (*callback)(void *userdata, uint8_t *stream, int len);
static bool audio_pause;
static void *userdata;
static uint32_t interval;
static uint32_t last_call;
static uint8_t *sbuf;
static bool re_entry;

void CallbackHelper(int force) {
  if (!callback || audio_pause || re_entry) return;
  re_entry = true;
  uint32_t t = NDL_GetTicks();
  if (force || t >= last_call + interval) {
    int len = NDL_QueryAudio();
    while (len) {
      int c = len > SBUF_SIZE ? SBUF_SIZE : len;
      callback(userdata, sbuf, c);
      NDL_PlayAudio(sbuf, c);
      len -= c;
    }
    last_call = t;
  }
  re_entry = false;
}

int SDL_OpenAudio(SDL_AudioSpec *desired, SDL_AudioSpec *obtained) {
  if (obtained) {
    memcpy(obtained, desired, sizeof(SDL_AudioSpec));
  }
  NDL_OpenAudio(desired->freq, desired->channels, desired->samples);
  callback = desired->callback;
  userdata = desired->userdata;
  audio_pause = true;
  interval = desired->samples * 1000 / desired->freq;
  re_entry = false;
  sbuf = malloc(SBUF_SIZE);
  return 0;
}

void SDL_CloseAudio() {
  callback = NULL;
  free(sbuf);
  NDL_CloseAudio();
}

void SDL_PauseAudio(int pause_on) {
  if (pause_on) {
    audio_pause = true;
  } else {
    audio_pause = false;
    CallbackHelper(1);
  }
}

void SDL_MixAudio(uint8_t *dst, uint8_t *src, uint32_t len, int volume) {
  int16_t *d = (int16_t *)dst;
  int16_t *s = (int16_t *)src;
  for (int i = 0; i < len / 2; ++i) {
    int t = s[i];
    d[i] = t * volume / SDL_MIX_MAXVOLUME;
  }
}

static void nread(int fd, void *buf, int n) {
  while (n > 0) {
    int c = read(fd, buf, n);
    n -= c;
    buf += c;
  }
}

SDL_AudioSpec *SDL_LoadWAV(const char *file, SDL_AudioSpec *spec, uint8_t **audio_buf, uint32_t *audio_len) {
  printf("%s\n", file);
  int fd = open(file, O_RDONLY);
  lseek(fd, 0, SEEK_SET);
  uint32_t t;
  uint16_t s;
  nread(fd, &t, 4);
  assert(t == 0x46464952);

  lseek(fd, 8, SEEK_SET);
  nread(fd, &t, 4);
  assert(t == 0x45564157);

  lseek(fd, 22, SEEK_SET);
  nread(fd, &s, 2);
  spec->channels = s - 1;

  lseek(fd, 24, SEEK_SET);
  nread(fd, &t, 4);
  spec->freq = t;

  lseek(fd, 40, SEEK_SET);
  nread(fd, &t, 4);
  spec->size = t;

  // spec->samples = 1024;

  void *buf = malloc(t);
  *audio_buf = buf;
  *audio_len = t;
  nread(fd, buf, t);
  close(fd);

  return spec;
}

void SDL_FreeWAV(uint8_t *audio_buf) {
  free(audio_buf);
}

void SDL_LockAudio() {
}

void SDL_UnlockAudio() {
}
