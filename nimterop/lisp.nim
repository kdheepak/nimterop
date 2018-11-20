import strutils

import regex

import globals

var
  gTokens {.compiletime.}: seq[string]
  idx {.compiletime.} = 0

proc tokenize(fullpath: string) =
  var collect = ""
  
  gTokens = @[]
  idx = 0
  for i in staticExec("toast " & fullpath):
    case i:
      of ' ', '\n', '\r', ')':
        if collect.nBl:
          gTokens.add(collect)
          collect = ""
        if i == ')':
          gTokens.add(")")
      of '(':
        gTokens.add("(")
      else:
        collect &= $i

proc readFromTokens(): Ast =
  if idx == gTokens.len():
    echo "Bad AST"
    quit(1)

  if gTokens[idx] == "(":
    if gTokens.len() - idx < 2:
      echo "Corrupt AST"
      quit(1)
    result.sym = gTokens[idx+1]
    result.start = gTokens[idx+2].parseInt()
    result.stop = gTokens[idx+3].parseInt()
    idx += 4
    result.children = @[]
    while gTokens[idx] != ")":
      var res = readFromTokens()
      if res.sym.nBl:
        res.parent = addr result
        result.children.add(res)
    idx += 1
    return
  elif gTokens[idx] == ")":
    echo "Poor AST"
    quit(1)
  
  idx += 1

proc printAst*(node: Ast, offset=""): string =
  result = offset & "(" & node.sym & " " & $node.start & " " & $node.stop
  if node.children.len() != 0:
    result &= "\n"
    for child in node.children:
      result &= printAst(child, offset & " ")
    result &= offset & ")\n"
  else:
    result &= ")\n"

proc parseLisp*(fullpath: string): Ast =
  tokenize(fullpath)
        
  return readFromTokens()