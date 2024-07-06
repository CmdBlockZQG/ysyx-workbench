.section ssbl, "ax"
.global _ssbl
.type _ssbl, @function

_ssbl:

  la t0, _text_src
  la t1, _text_start
  la t2, _text_end
  .align 5
.L1:
  lbu a2, 0(t0)
  addi t0, t0, 1
  sb a2, 0(t1)
  addi t1, t1, 1
  bne t1, t2, .L1

  la t0, _rodata_src
  la t1, _rodata_start
  la t2, _rodata_end
  .align 5
.L2:
  lbu a2, 0(t0)
  addi t0, t0, 1
  sb a2, 0(t1)
  addi t1, t1, 1
  bne t1, t2, .L2

  tail _start

.size _ssbl, . - _ssbl
