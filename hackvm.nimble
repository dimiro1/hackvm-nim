version = "0.1.0"
author = "Claudemiro"
description = "A new awesome nimble package"
license = "MIT"
srcDir = "src"
bin = @["hackvm"]

requires "nim >= 1.6.4"

task clean, "Clean build files":
  exec "rm -f hackvm"
  exec "rm -f outputGotten.txt"
  exec "rm -rf testresults"
  exec "rm -f tests/test_hackvm"
  exec "rm -f src/hackvm"
