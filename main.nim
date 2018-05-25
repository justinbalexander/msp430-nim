import msp430, msp430f5510, ring, volatile

var buf: RingBuffer[16,uint8]


proc initTimerISR() =
  TA0CTL[] = MC_STOP
  TA0CCTL0[] = OUTMOD_VAL_4 + CCIE
  TA0CCR0[] = 0x1000.uint16
  TA0CTL[] = TASSEL_SMCLK + MC_UP + ID_VAL_8 + TACLR

proc initPorts() =
  P4OUT[] = P4OUT[] and not BIT7.uint8
  P4DIR[] = P4DIR[] or BIT7.uint8

ISR:
  proc TIMER0_A0() =
    buf.add(0x01)
    P4OUT[] = P4OUT[] xor BIT7.uint8

proc main {.noreturn.}=
  WDTCTL[] = WDTPW + WDTHOLD
  initTimerISR()
  initPorts()
  enableInterrupts()

  while true:
    discard buf.remove()
    nop()

main()
