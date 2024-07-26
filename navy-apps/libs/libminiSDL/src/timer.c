#include <NDL.h>
#include <assert.h>
#include <sdl-timer.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

void CallbackHelper();

typedef struct Timer {
  uint32_t interval;
  SDL_NewTimerCallback callback;
  void *param;
  uint32_t should_call;

  struct Timer *next, *prev; // link list
} Timer;

static Timer *head = NULL;

void TimerCallbackHelper() {
  uint32_t now = NDL_GetTicks();
  for (Timer *t = head; t; t = t->next) {
    if (now < t->should_call) continue;
    t->interval = t->callback(t->interval, t->param);
    t->should_call = now + t->interval;
  }
}

SDL_TimerID SDL_AddTimer(uint32_t interval, SDL_NewTimerCallback callback, void *param) {
  Timer *t = malloc(sizeof(Timer));
  t->interval = interval;
  t->callback = callback;
  t->param = param;
  t->should_call = NDL_GetTicks() + interval;
  t->next = head;
  t->prev = NULL;
  head = t;
  return t;
}

int SDL_RemoveTimer(SDL_TimerID id) {
  Timer *t = id;
  if (t->prev) t->prev->next = t->next;
  if (t->next) t->next->prev = t->prev;
  if (head == t) head = t->next;
  free(t);
  return 1;
}

uint32_t sdl_init_time_ms;

uint32_t SDL_GetTicks() {
  CallbackHelper();
  return NDL_GetTicks() - sdl_init_time_ms;
}

void SDL_Delay(uint32_t ms) {
  uint32_t t = SDL_GetTicks();
  while (SDL_GetTicks() - t <= ms);
}
