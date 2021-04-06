.arch femto16
.org 0x8000
.len 256

      mov       sp,@$6fff
      mov       dx,@Fib
      jsr       dx
      reset
Fib:
      mov       ax,#1
      mov       bx,#0
Loop:
      mov       cx,ax
      add       ax,bx
      mov       bx,cx
      push      ax
      pop       ax
      mov       [42],ax
      mov       ax,[42]
      bcc       Loop
      rts
