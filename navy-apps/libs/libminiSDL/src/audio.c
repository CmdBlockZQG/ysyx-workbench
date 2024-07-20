#include <NDL.h>
#include <SDL.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define SBUF_SIZE 64

static void (*callback)(void *userdata, uint8_t *stream, int len);
static bool pause;
static void *userdata;
static uint32_t interval;
static uint32_t last_call;
static uint8_t *sbuf;
static bool re_entry;

void CallbackHelper(int force) {
  if (!callback || pause || re_entry) return;
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
  pause = true;
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
    pause = true;
  } else {
    pause = false;
    CallbackHelper(1);
  }
}

void SDL_MixAudio(uint8_t *dst, uint8_t *src, uint32_t len, int volume) {
}

SDL_AudioSpec *SDL_LoadWAV(const char *file, SDL_AudioSpec *spec, uint8_t **audio_buf, uint32_t *audio_len) {
  return NULL;
}

void SDL_FreeWAV(uint8_t *audio_buf) {
}

void SDL_LockAudio() {
}

void SDL_UnlockAudio() {
}
