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
 dXt : position uncertainty v(t,i) part of input data
 dX  : uniform position uncertainty part of the model
 dXs : state-dependent position uncertainty part of the model
 Ds    : include state-dependent detachment7death rate in the model

---
to do:
- compute KL_xxx (VB) or lnPxxx (MAP) during Piter, and clear/remove
  fields from other move types, and use those results to compute lnL
  in Siter.
- write simple test scripts, that systematically tests and
  demonstrates all functionality of all model classes
- check that N=1 is handle correctly, in terms of priors and KL-terms
- separate state estimates from Siter
- make Xiter(...,iType) a YSZmodel function that calls child-class
  functions Xiter_mle, Xiter_map, Xiter_vb.
- VBsearch and fixedSizeSearch should take initial guess models and
  improve upon them,
- make the data a static part of the model objects, using a handle
  class if nothing lse works...
- change Tmin (used now) two trjLmin (as in vbSPT)?

- the meaning of opt.dim: number of dimensions -> specifying which
  columns to use in x,v?

- B-prior with tunable strength for different sparsity 
- specifying priors explicitly (same for all states)

- get rid of redundant model fields W.dim, dat.dim, W.numStates,W.YZ.Fs_yz?
  W.YZ.i0,i0 W.lnL too?

- consistently use W.P.aggregate-type fields for diffusion constant
  and deatch rates

less important
- make tolerance parameters from opt go into model obj and be used by
  convergence function
