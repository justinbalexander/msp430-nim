import macros

proc enableInterrupts*() {.header: "<intrinsics.h>", importc: "_EINT".}
proc disableInterrupts*() {.header: "<intrinsics.h>", importc: "_DINT".}

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
