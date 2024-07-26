#include <NDL.h>
#include <SDL.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

void CallbackHelper();

#define keyname(k) #k,

#define NR_KEY (sizeof(keyname) / sizeof(const char *))

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

static uint8_t key_state[NR_KEY];

typedef struct EventNode {
  SDL_Event ev;
  struct EventNode *prev, *next;
} EventNode;
EventNode *head = NULL, *tail = NULL;

int SDL_PushEvent(SDL_Event *ev) {
  EventNode *node = malloc(sizeof(EventNode));
  memcpy(&node->ev, ev, sizeof(SDL_Event));
  if (tail) {
    tail->next = node;
    node->prev = tail;
  } else {
    node->prev = NULL;
    head = node;
  }
  node->next = NULL;
  tail = node;
  return 0;
}

static int poll_kbd_event() {
  char buf[20];
  SDL_Event ev;
  int res = 0;
  while (NDL_PollEvent(buf, sizeof(buf))) {
    ev.type = buf[1] == 'd' ? SDL_KEYDOWN : SDL_KEYUP;
    *strchr(buf + 3, '\n') = '\0';
    for (int i = 0; i < NR_KEY; ++i) {
      if (!strcmp(keyname[i], buf + 3)) {
        ev.key.keysym.sym = i;
        key_state[i] = buf[1] == 'd';
        break;
      }
    }
    SDL_PushEvent(&ev);
    res = 1;
  }
  return res;
}

int SDL_PollEvent(SDL_Event *ev) {
  CallbackHelper();
  poll_kbd_event();
  if (!head) return 0;

  EventNode *node = head;
  memcpy(ev, &node->ev, sizeof(SDL_Event));
  if (node->next) node->next->prev = NULL;
  if (tail == node) tail = NULL;
  head = node->next;
  free(node);

  return 1;
}

int SDL_WaitEvent(SDL_Event *event) {
  while (!head) poll_kbd_event();
  SDL_PollEvent(event);
  return 1;
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  assert(numevents == 1);
  assert(action == SDL_GETEVENT);

  CallbackHelper();
  poll_kbd_event();

  if (!head) return 0;
  int res = 0;
  for (EventNode *node = head; node; node = node->next) {
    if (!(SDL_EVENTMASK(node->ev.type) & mask)) continue;
    res = 1;
    if (node->prev) node->prev->next = node->next;
    if (node->next) node->next->prev = node->prev;
    if (head == node) head = node->next;
    if (tail == node) tail = node->prev;
    memcpy(ev, &node->ev, sizeof(SDL_Event));
    free(node);
    break;
  }

  return res;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
  return key_state;
}
