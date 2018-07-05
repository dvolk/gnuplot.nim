import gnuplot, fresnel

var
    X = newSeq[float64](1500)
    Y = newSeq[float64](len(X))

for i in 0 ..< len(X):
    let
        x = -7.5 + float64(i) / 100.0
        (c, s) = fresnel(x)

    X[i] = c
    Y[i] = s

cmd "set size square"
plot X, Y

discard readChar stdin
