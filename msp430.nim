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

proc enableInterrupts*() {.header: "<in430.h>", importc: "__enable_interrupt", used.}
proc disableInterrupts*() {.header: "<in430.h>", importc: "__disable_interrupt", used.}
proc nop*() {.header: "<in430.h>", importc: "__no_operation", used.}
proc getInterruptState*() {.header: "<in430.h>", importc: "__get_interrupt_state", used.}
proc setInterruptState*(x: SomeInteger) {.header: "<in430.h>", importc: "__set_interrupt_state", used.}
proc bicSRRegister(x: SomeInteger) {.header: "<in430.h>", importc: "__bic_SR_register", used.}
proc bisSRRegister(x: SomeInteger) {.header: "<in430.h>", importc: "__bis_SR_register", used.}
proc getSRRegister {.header: "<in430.h>", importc: "__get_SR_register", used.}
proc swapBytes(x: untyped) {.header: "<in430.h>", importc: "__swap_bytes", used.}
proc bicSRRegisterOnExit(x: SomeInteger) {.header: "<in430.h>", importc: "__bic_SR_register_on_exit", used.}
proc bisSRRegisterOnExit(x: SomeInteger) {.header: "<in430.h>", importc: "__bis_SR_register_on_exit", used.}
proc LPM0()  {.header: "<in430.h>", importc: "__low_power_mode_0", used.}
proc LPM1()  {.header: "<in430.h>", importc: "__low_power_mode_1", used.}
proc LPM2()  {.header: "<in430.h>", importc: "__low_power_mode_2", used.}
proc LPM3()  {.header: "<in430.h>", importc: "__low_power_mode_3", used.}
proc LPM4()  {.header: "<in430.h>", importc: "__low_power_mode_4", used.}
proc LPMOffOnExit()  {.header: "<in430.h>", importc: "__low_power_mode_off_on_exit", used.}



template setPragma(node: typed, name: string, value: string){.used.} =
  if node.pragma.kind==nnkEmpty:
    node.pragma=newNimNode(nnkPragma)
  node.pragma.add(newNimNode(nnkExprColonExpr)
                  .add(newIdentNode(name))
                  .add(newStrLitNode(value)))

template setPragma(node: typed, name: string){.used.} =
  if node.pragma.kind==nnkEmpty:
    node.pragma=newNimNode(nnkPragma)
  node.pragma.add(newIdentNode(name))

macro ISR*(procs: untyped): untyped {.used.}=
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
