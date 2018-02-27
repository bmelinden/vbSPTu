uSPT : a suite of tools learning diffusive HMMs with motion blur and
localization errors.

Basic model:
s(t)    : a discrete hidden Markov process
x(t,i)  : position data, i=1,...,dim

Position uncertainty in the form of uncorrelated position variances
can be supplied as an input variable, in which case v(t,i) is the
variance of x(t,i), or as a single model parameter (same for all
dimensions) v, or as a state-dependent parameter v(s).
---------------------------------------------------------------------
contents
---------------------------------------------------------------------
+spt/ : set of functions to handle data, runinput files, and prior
      	distributions
HMMcore/ : low-level math functions for the VB/EM iterations,
	   implemented as C/C++ mex functions. IOf needed, recompile
	   with the compile_code.m function.
tools/ : misc. tools, including handling of paths och options structs,
       	 and functions related to 
gui/   : the graphical user interface for uSPT
testdata1_zMax/ : contains a script to generate some simple test data set 

+YZShmm/ : contains classes, functions, and analysis methods for the
	   uSPT HMM ananlysis. 

+YZShmm/@YZS0: HMM base class (abstract)
+YZShmm/@dXt : HMM class with explicit point-wise variances, e.g.,
	       indata is (x(t), v(t)).
+YZShmm/@dX  : HMM class where the overall localization variance is a
	       fit parameter. NOTE: this class is mainly implemented
	       for demonstration purposes, not extensively tested, and
	       the YZShmm.modelSearch and YZShmm.modelSearchFixedSize
	       functions are optimized for the YZShmm.dXt class.

+mleYZdX/, +mleYZdXs/, +mleYZdXt/, +vbYZdXt/ : struct-based legacy
implementations of combinations of model (dX, dXs, dXt) and types of
learning mle/vb. Some of them are used in constructin the diffusive
running average initial guesses for q(Y,Z).

---------------------------------------------------------------------

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

