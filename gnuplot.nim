import osproc, os, streams, times, random, strutils

## Importing this module will start gnuplot. Array contents are written
## to temporary files (in /tmp) and then loaded by gnuplot. The temporary
## files aren't deleted automatically in case they would be useful later.

type
  Style* = enum
    Lines,
    Points,
    Linepoints,
    Impulses,
    Dots,
    Steps,
    Errorbars,
    Boxes,
    Boxerrorbars

var
  gp: Process
  nplots = 0
  style: Style = Lines
let
  gnuplot_exe = "/usr/bin/gnuplot"

try:
  gp = startProcess gnuplot_exe
except:
  echo "Error: Couldn't start " & gnuplot_exe
  echo "Edit the gnuplot_exe path in gnuplot.nim if your gnuplot executable is elsewhere"
  quit 1

proc plotCmd(): string =
  if nplots == 0: "plot " else: "replot "

proc tmpFilename(): string =
  "/tmp/" & $epochTime() & "-" & $random(1000) & ".tmp"

proc cmd*(cmd: string) =
  echo cmd
  ## send a raw command to gnuplot
  try:
    gp.inputStream.writeLine cmd
    gp.inputStream.flush
  except:
    echo "Error: Couldn't send command to gnuplot"
    quit 1

proc sendPlot(arg: string, title: string, extra: string = "") =
  let
    title_line =
      if title == "": " notitle"
      else: " title \"" & title & "\""
    line = (plotCmd() & arg & extra & title_line &
            " with " & toLowerAscii($style))
  cmd line
  nplots = nplots + 1

proc plot*(equation: string) =
  ## Plot an equation as understood by gnuplot. e.g.:
  ##
  ## .. code-block:: nim
  ##   plot "sin(x)/x"
  sendPlot equation, equation

proc plot*(xs: openarray[float64],
          title = "") =
  ## plot an array or seq of float64 values. e.g.:
  ##
  ## .. code-block:: nim
  ##   import math, sequtils
  ##
  ##   let xs = newSeqWith(20, random(1.0))
  ##
  ##   plot xs, "random values"
  let fname = tmpFilename()
  try:
    let f = open(fname, fmWrite)
    for x in xs:
      writeLine f, x
    f.close
  except:
    echo "Error: Couldn't write to temporary file: " & fname
    quit 1
  sendPlot("\"" & fname & "\"", title)

proc plot*[X, Y](xs: openarray[X],
                ys: openarray[Y],
                title = "") =
  ## plot points taking x and y values from corresponding pairs in
  ## the given arrays.
  ##
  ## With a bit of effort, this can be used to
  ## make date plots. e.g.:
  ##
  ## .. code-block:: nim
  ##   let
  ##       X = ["2014-01-29",
  ##            "2014-02-05",
  ##            "2014-03-15",
  ##            "2014-04-12",
  ##            "2014-05-24",
  ##            "2014-06-02",
  ##            "2014-07-07",
  ##            "2014-08-19",
  ##            "2014-09-04",
  ##            "2014-10-26",
  ##            "2014-11-21",
  ##            "2014-12-07"]
  ##       Y = newSeqWith(len(X), random(10.0))
  ##
  ##   cmd "set timefmt \"%Y-%m-%d\""
  ##   cmd "set xdata time"
  ##
  ##   plot X, Y, "buttcoin value over time"
  ##
  ## or other drawings. e.g.:
  ##
  ## .. code-block:: nim
  ##   var
  ##       X = newSeq[float64](100)
  ##       Y = newSeq[float64](100)
  ##
  ##   for i in 0.. <100:
  ##       let f = float64(i)
  ##       X[i] = f * sin(f)
  ##       Y[i] = f * cos(f)
  ##
  ##   plot X, Y, "spiral"
  assert xs.len == ys.len, "xs and ys must have same length"
  let fname = tmpFilename()
  try:
    let f = open(fname, fmWrite)
    for i in xs.low..xs.high:
      writeLine f, xs[i], " ", ys[i]
    f.close
  except:
    echo "Error: Couldn't write to temporary file: " & fname
    quit 1
  sendPlot("\"" & fname & "\"", title, " using 1:2")

proc set_style*(s: Style) =
  ## set plotting style
  style = s
