/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include "sdb.h"

#define NR_WP 32

typedef struct watchpoint {
  int NO;
  struct watchpoint *next;

  word_t val;
  char *expr;
} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;
static int wp_no = 0;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

WP *new_wp(char *str, word_t val) {
  if (free_ == NULL) return NULL;
  WP *p = free_;
  free_ = p->next;

  p->NO = ++wp_no;
  p->next = head;
  p->val = val;
  p->expr = str;

  head = p;
  return p;
}

void free_wp(int no) {
  WP *p = NULL, *i;
  if (head->NO == no) {
    p = head;
    head = p->next;
    goto found;
  }
  for (i = head; i->next; i = i->next) {
    if (i->next->NO == no) {
      p = i->next;
      i->next = p->next;
      goto found;
    }
  }
  if (i->NO == no) p = i;
  else return;
  found:
  p->next = free_;
  free_ = p;
}

void print_wp(WP *p) {
  printf(
    MUXDEF(CONFIG_RV64, "%-3s %-18s %s\n", "%-3s %-10s %s\n"),
    "No", "Value", "Expr"
  );
  printf(
    MUXDEF(CONFIG_RV64, "%-3d 0x%-16llx %s\n", "%-3d 0x%-8x %s\n"),
    p->NO, p->val, p->expr
  );
}

void wps_display() {
  printf(
    MUXDEF(CONFIG_RV64, "%-3s %-18s %s\n", "%-3s %-10s %s\n"),
    "No", "Value", "Expr"
  );
  for (WP *p = head; p; p = p->next) {
    printf(
      MUXDEF(CONFIG_RV64, "%-3d 0x%-16llx %s\n", "%-3d 0x%-8x %s\n"),
      p->NO, p->val, p->expr
    );
  }
}
