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

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ, TK_DEC
};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {
  {" +", TK_NOTYPE},    // spaces
  {"\\+", '+'},         // plus
  {"-", '-'},           // minus
  {"\\*", '*'},         // multiply
  {"\\/", '/'},         // divide
  {"\\(", '('},         // left parentheses
  {"\\)", ')'},         // right parentheses
  {"[0-9]+", TK_DEC},     // decimal number
  {"==", TK_EQ},        // equal
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[128] __attribute__((used)) = {};
static int nr_token __attribute__((used)) = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        /*Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);*/

        position += substr_len;

        switch (rules[i].token_type) {
          case '+': tokens[nr_token++].type = '+'; break;
          case '-': tokens[nr_token++].type = '-'; break;
          case '*': tokens[nr_token++].type = '*'; break;
          case '/': tokens[nr_token++].type = '/'; break;
          case '(': tokens[nr_token++].type = '('; break;
          case ')': tokens[nr_token++].type = ')'; break;

          case TK_DEC:
            if (substr_len >= 32) {
              printf("number too big at position %d\n%s\n%*.s^\n", position, e, position, "");
              return false;
            }
            tokens[nr_token].type = TK_DEC;
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len] = '\0';
            ++nr_token;
          break;
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

static bool eval_err = false;
static int stack[32];

static word_t eval(int l, int r) {
  // printf("eval: %d %d\n", l, r);
  if (l > r) { /* Bad expr */
    eval_err = true;
    // Log("Bad expr: %d %d\n", l, r);
    return -1;
  }
  if (l == r || l + 1 == r) { /* 1~2 token, should be number */
    bool mn = (l + 1 == r);
    if (tokens[r].type != TK_DEC || (mn && tokens[l].type != '-')) {
      eval_err = true;
      // Log("Bad number: %d %d\n", l, r);
      return -1;
    }
    word_t val = 0;
    for (int i = 0; i < strlen(tokens[r].str); ++i) {
      val = val * 10 + (tokens[r].str[i] - '0');
    }
    return mn ? -val : val;
  }
  if (tokens[l].type == '(' && tokens[r].type == ')') {
    int top = 0;
    for (int i = l; i < r; ++i) {
      if (tokens[i].type == '(') stack[top++] = i;
      else if (tokens[i].type == ')') {
        if (top == 0) { eval_err = true; return -1; }
        --top;
      }
    }
    if (top == 1 && stack[0] == l) return eval(l + 1, r - 1);
  }
  int op = -1, dep = 0;
  for (int i = l; i <= r; ++i) {
    if (tokens[i].type == '(') ++dep;
    else if (tokens[i].type == ')') --dep;
    else if (dep == 0) {
      switch (tokens[i].type) {
        case '+': op = i; break;
        case '-': 
          if (i != l && (tokens[i - 1].type == TK_DEC || tokens[i - 1].type == ')')) {
            op = i; break;
          }
        case '*':
        case '/':
          if (op == -1 || tokens[op].type == '*' || tokens[op].type == '/') {
            op = i; break;
          }
      }
    }
  }
  /* dep == 0 is just a sufficient condition of bad parentheses */
  if (op == -1 || dep != 0) {
    eval_err = true;
    // Log("No op: %d %d\n", l, r);
    return -1;
  }
  word_t val1 = eval(l, op - 1);
  if (eval_err) return -1;
  word_t val2 = eval(op + 1, r);
  if (eval_err) return -1;

  switch (tokens[op].type) {
    case '+': return val1 + val2;
    case '-': return val1 - val2;
    case '*': return val1 * val2;
    case '/': return val1 / val2;
    default: assert(0);
  }
}

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  word_t val = eval(0, nr_token - 1);
  *success = !eval_err;
  return val;
}
