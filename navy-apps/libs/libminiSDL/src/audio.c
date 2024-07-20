#include <NDL.h>
#include <SDL.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define SBUF_SIZE 16384

static void (*callback)(void *userdata, uint8_t *stream, int len);
static bool pause;
static void *userdata;
static uint32_t interval;
static uint32_t last_call;
static void *buf;

void CallbackHelper(int force) {
  if (!callback || pause) return;
  uint32_t t = NDL_GetTicks();
  if (force || t >= last_call + interval) {
    last_call = t;
    int len = NDL_QueryAudio();
    len = len > SBUF_SIZE ? SBUF_SIZE : len;
    callback(userdata, buf, len);
    NDL_PlayAudio(buf, len);
  }
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
  buf = malloc(SBUF_SIZE);
  return 0;
}

void SDL_CloseAudio() {
  callback = NULL;
  free(buf);
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
