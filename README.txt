to do:

- diffusionPathUpdate or hiddenStateUpdate first in .converge?

- replace mleXXX.diffusionPathUpdate with calls to spt.diffusionPathUpdate

- get rid of redundant model fields W.dim, dat.dim, W.numStates,W.YZ.Fs_yz?
W.YZ.i0,i0 W.lnL too?

- consistent parameter dimensions: row index = state in P.lambda

- cinsistently use W.P.aggregate 
