import msp430, msp430f5510, ring, volatile

var buf: RingBuffer[16,uint8]

proc initTimerISR() =
  volatileStore[uint16](TA0CTL, MC_STOP)
  volatileStore[uint16](TA0CCTL0, OUTMOD_VAL_4)
  volatileStore[uint16](TA0CCR0, 0x1000'u16)
  volatileStore[uint16](TA0CTL, TASSEL_SMCLK + MC_UP + ID_VAL_8 + TACLR + TAIE)

proc initPorts() =
  P4OUT[] = P4OUT[] and (not BIT7)
  P4DIR[] = P4DIR[] or (BIT7)

ISR:
  proc TIMER0_A0() =
    buf.add(0x01)
    P4OUT[] = P4OUT[] xor BIT7

proc main =
  WDTCTL[] = WDTPW + WDTHOLD
  initTimerISR()
  initPorts()
  while true:
    var temp: uint8
    temp = buf.remove()

main()
