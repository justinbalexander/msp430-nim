type
  RingBuffer*[N: static[int],T] = object
    buf: array[N,T]
    head, tail: int

proc initRingBuffer*[N: static[int],T](self: var RingBuffer[N,T]) =
    self.head = 0
    self.tail = 0
    assert N in [2,4,8,16,32,64,128,256,512,1024,2048]

proc add*[N: static[int],T](self: var RingBuffer[N,T], data: T) =
  if ((self.tail - 1) and (N - 1)) != self.head:
    self.buf[self.head] = data
    self.head = (self.head + 1) and (N - 1)

proc remove*[N: static[int],T](self: var RingBuffer[N,T]): T =
  if (self.tail != self.head):
    result = self.buf[self.tail]
    self.tail = (self.tail + 1) and (N - 1)



