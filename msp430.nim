import macros, volatile

type 
  SFRb* = distinct ptr uint8
  SFRw* = distinct ptr uint16
  SFRa* = distinct ptr uint16

template declareSpecialFunctionRegisterOperators(distinctType, pointsToType: typedesc) =
  template `[]`*(reg: distinctType) : untyped = 
    volatileLoad[pointsToType]((ptr pointsToType)(reg))
  template `[]=`*(reg: distinctType, val: SomeInteger) = 
    volatileStore[pointsToType]((ptr pointsToType)(reg), pointsToType(val))

declareSpecialFunctionRegisterOperators(SFRb, uint8)
declareSpecialFunctionRegisterOperators(SFRw, uint16)
declareSpecialFunctionRegisterOperators(SFRa, uint16)

proc enableInterrupts*() {.header: "<in430.h>", importc: "__enable_interrupt".}
proc disableInterrupts*() {.header: "<in430.h>", importc: "__disable_interrupt".}
proc nop*() {.header: "<in430.h>", importc: "__no_operation".}
proc getInterruptState*() {.header: "<in430.h>", importc: "__get_interrupt_state".}
proc setInterruptState*(x: SomeInteger) {.header: "<in430.h>", importc: "__set_interrupt_state".}
proc bicSRRegister(x: SomeInteger) {.header: "<in430.h>", importc: "__bic_SR_register".}
proc bisSRRegister(x: SomeInteger) {.header: "<in430.h>", importc: "__bis_SR_register".}
proc getSRRegister {.header: "<in430.h>", importc: "__get_SR_register".}
proc swapBytes(x: untyped) {.header: "<in430.h>", importc: "__swap_bytes".}
proc bicSRRegisterOnExit(x: SomeInteger) {.header: "<in430.h>", importc: "__bic_SR_register_on_exit".}
proc bisSRRegisterOnExit(x: SomeInteger) {.header: "<in430.h>", importc: "__bis_SR_register_on_exit".}
proc LPM0()  {.header: "<in430.h>", importc: "__low_power_mode_0".}
proc LPM1()  {.header: "<in430.h>", importc: "__low_power_mode_1".}
proc LPM2()  {.header: "<in430.h>", importc: "__low_power_mode_2".}
proc LPM3()  {.header: "<in430.h>", importc: "__low_power_mode_3".}
proc LPM4()  {.header: "<in430.h>", importc: "__low_power_mode_4".}
proc LPMOffOnExit()  {.header: "<in430.h>", importc: "__low_power_mode_off_on_exit".}



template setPragma(node: typed, name: string, value: string) =
  if node.pragma.kind==nnkEmpty:
    node.pragma=newNimNode(nnkPragma)
  node.pragma.add(newNimNode(nnkExprColonExpr)
                  .add(newIdentNode(name))
                  .add(newStrLitNode(value)))

template setPragma(node: typed, name: string) =
  if node.pragma.kind==nnkEmpty:
    node.pragma=newNimNode(nnkPragma)
  node.pragma.add(newIdentNode(name))

macro ISR*(procs: untyped): untyped =
  ## Statement macro that modifies a proc to work as interrupt handler
  # The vectors are only resolved at C level, so this routine does not
  # need to know which exist. 
  let keeps = newNimNode(nnkStmtList)
  for node in procs.children:
    node.expectKind(nnkProcDef)
    let name : string = $node.name.ident
    # Rename the ISR to not collide with C macros
    node.setPragma("exportc", "ISR_" & name)
    node.pragma.add(newNimNode(nnkExprColonExpr)
                    .add(newIdentNode("codegenDecl"))
                    .add(parseExpr("\"$# __attribute__((interrupt((\"& $"&name&"_VECTOR&\"/2) + 1))) $# $#\"")))
  return procs.add(keeps)

# Example usage
#ISR:
#  proc SYSNMI() =
#    return
