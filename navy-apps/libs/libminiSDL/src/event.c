#include <NDL.h>
#include <SDL.h>
#include <string.h>

#define keyname(k) #k,

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

int SDL_PushEvent(SDL_Event *ev) {
  return 0;
}

int SDL_PollEvent(SDL_Event *ev) {
  char buf[20];
  int res = NDL_PollEvent(buf, sizeof(buf));
  if (!res) return 0;
  ev->type = buf[1] == 'd' ? SDL_KEYDOWN : SDL_KEYUP;
  *strchr(buf + 3, '\n') = '\0';
  for (int i = 0; i < sizeof(keyname) / sizeof(const char *); ++i) {
    if (!strcmp(keyname[i], buf + 3)) {
      ev->key.keysym.sym = i;
      break;
    }
  }
  return 1;
}

int SDL_WaitEvent(SDL_Event *event) {
  char buf[20];
  while (1) {
    int res = NDL_PollEvent(buf, sizeof(buf));
    if (!res) continue;
    event->type = buf[1] == 'd' ? SDL_KEYDOWN : SDL_KEYUP;
    *strchr(buf + 3, '\n') = '\0';
    for (int i = 0; i < sizeof(keyname) / sizeof(const char *); ++i) {
      if (!strcmp(keyname[i], buf + 3)) {
        event->key.keysym.sym = i;
        break;
      }
    }
    return 1;
  }
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  return 0;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
  return NULL;
}
