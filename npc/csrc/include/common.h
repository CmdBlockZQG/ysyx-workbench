#ifndef __COMMON_H__
#define __COMMON_H__

#include <cstdlib>

#include <cassert>
#include <cstdint>

typedef uint32_t word_t;
typedef int32_t sword_t;

typedef word_t paddr_t;

#define FMT_WORD "0x%016x"
#define FMT_PADDR "0x%016x"

#include "debug.h"

#endif
