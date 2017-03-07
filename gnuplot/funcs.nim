
template rangeFloat(incr: untyped): untyped {.dirty.} =
  var res = a
  while res <= b:
    yield res
    incr

iterator `..`*(a, b: float): float {.inline.} =
  rangeFloat:
    res += 1.0

iterator range*(a, b: float, step = 1.0): float {.inline.} =
  rangeFloat:
    res += step

iterator linspace*(a, b: float, num = 50): float {.inline.} =
  let step = (b - a) / float(num)
  rangeFloat:
    res += step

proc range*(a, b: float, step = 1.0): seq[float] =
  accumulateResult(range(a, b, step))

proc linspace*(a, b: float, num = 50): seq[float] =
  accumulateResult(linspace(a, b, num))


when isMainModule:
  import sequtils

  # Tests
  var d: seq[float] = @[]
  for i in 1.0..5.0:
    d.add(i)

  assert d == @[1.0, 2.0, 3.0, 4.0, 5.0]
  assert toSeq(range(0.0, 20.0, 3.0)) == @[0.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0]
  assert toSeq(linspace(0.0, 10.0, 8)) == @[0.0, 1.25, 2.5, 3.75, 5.0, 6.25, 7.5, 8.75, 10.0]

  assert range(0.0, 20.0, 3.0) == @[0.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0]
  assert linspace(0.0, 10.0, 8) == @[0.0, 1.25, 2.5, 3.75, 5.0, 6.25, 7.5, 8.75, 10.0]
