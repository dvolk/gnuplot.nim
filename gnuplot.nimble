mode = ScriptMode.Verbose

# Package
packageName = "gnuplot"
version = "0.6"
author = "dvolk"
description = "Interface to Gnuplot"
license = "MIT"
skipDirs = @["examples"]

# Deps
requires "nim >= 0.9.2"

when defined(nimdistros):
  import distros
  foreignDep "gnuplot"
