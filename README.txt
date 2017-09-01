uSPT : a suite of tools learning diffusive HMMs with motion blur and
localization errors.

Basic model:
s(t)    : a discrete hidden Markov process
x(t,i)  : position data, i=1,...,dim

Position uncertainty in the form of uncorrelated position variances
can be supplied as an input variable, in which case v(t,i) is the
variance of x(t,i), or as a single model parameter (same for all
dimensions) v, or as a state-dependent parameter v(s).

Different model/algorithm combinations
+mleYZdXs
+mleYZdXs_old
+mleYZdXt
+vbYZdXt
+mleYZdXtDs
+mleYZdXu

mle/vb : maximum likelihood estimate or variational Bayes.
 YZdXt : position uncertainty v(t,i) part of input data
 YZdXu : uniform position uncertainty part of the model
 YZdXs : state-dependent position uncertainty part of the model
 Ds    : include state-dependent detachment7death rate in the model

---
to do:

- check that N=1 is handle correctly, in terms of priors and KL-terms
- make tolerance parameters from opt go into model obj and be used by
  convergence function
- make the data a static part of the model objects, using a handle
  calss if nothing lse works...
- rearrange options struct with multiple levels, e.g.,
  opt.input, opt.output, opt.prior, opt.VBanalysis, opt.convergence, opt.init

- change Tmin (used now) two trjLmin (as in vbSPT)?

- the meaning of opt.dim: number of dimensions -> specifying which
  columns to use in x,v?

- B-prior with tunable strength for different sparsity 
- specifying priors explicitly (same for all states)
- diffusionPathUpdate or hiddenStateUpdate first in .converge?

- make more uniform models: all model parameters specified by their
  pseudocount parameters in W.P, W.P0, so that VB-, MLE-, and
  MAP- iterations can be applied to all models.

- replace mleXXX.diffusionPathUpdate with calls to spt.diffusionPathUpdate

- get rid of redundant model fields W.dim, dat.dim, W.numStates,W.YZ.Fs_yz?
W.YZ.i0,i0 W.lnL too?

- consistent parameter dimensions: row index = state in P.lambda

- consistently use W.P.aggregate-type fields for diffusion constant
  and deatch rates
