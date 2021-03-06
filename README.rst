:Date: 15 May 2009
:Author: Anand Patil
:Contact: anand.prabhakar.patil@gmail.com
:Web site: github.com/malaria-atlas-project/generic-mbg
:Copyright: Anand Patil, 2009.
:License: GPL, see GPL in this directory.

The generic MBG package allows us to write PyMC probability models for each 
project that works with spatial or spatiotemporal count data, then turn the
model over to the project team for fitting, mapping and experimentation using 
three easy shell commands:

* ``mbg-infer`` runs the MCMC algorithm using the given model & an input dataset,
  stored in a csv file, and stores the traces in an HDF5 archive.

* ``mbg-map`` takes the HDF5 archive produced by mbg-infer, and an ASCII file with
  a MISSING entry in its header. Produces a set of bespoke summary maps on the grid
  expressed by the ASCII header. The missing pixels are missing in the output also.
  
* ``mbg-validate`` takes the HDF5 archive produced by mbg-infer and a 'holdout'
  dataset, stored in a csv file, and creates a set of predictive samples at the
  holdout locations and some validation plots.
  
If the project's members are interested in changing the model or specifying a
subjective prior, there are two additional shell commands available to help:

* ``mbg-scalar-priors`` draws samples from the prior for all scalar parameters
  (including deterministics) and plots histograms for inspection.
  
* ``mbg-realize-prior`` draws all scalar parameters from the prior, and realizes
  and plots the random field on grids matching a number of input ASCIIs.
  
* ``mbg-describe-tracefile`` provides information about the circumstances under which
  traces were produced.

All shell commands can be run with only the ``-h`` option to print some help to the
screen. However, if you're reading this document, you don't really need to do that.


***************************
Detailed usage instructions
***************************

If you want to use the shell commands, this section is for you.


``mbg-infer``
=============
::

    mbg-infer module database-file input [options]
    
Produces the requested database file. Also produces plots of the dynamic traces of all
scalar parameters as PDF's, and saves them in the folder ``name-plots``, where ``name``
is the name of the database file. You will need to inspect these plots to determine how
many 'burnin' iterations should be discarded when making maps.

If you determine that more MCMC samples are needed, simply run mbg-infer with the same 
database file argument to pick up where you left off and keep sampling.

Required arguments
------------------

1. The name of the module containing the model specification.

2. The name of the database file to be produced. If you do not want it to go in the current
   directory, specify a path, eg ``/home/anand/traces/run-01-04-2009``. If the database file
   already exists, you will be prompted about whether you want to continue sampling into it
   or remove it.

3. The name of a csv file containing the input data. If it is a different directory, specify
   the path to it, eg ``/home/anand/data/query-01-04-2009.csv``. This csv file must have the
   following columns:
     
   * ``lon``, ``lat`` : The coordinates of the observation in decimal degrees
     
   * ``t`` : Time in decimal years. This is only required for spatiotemporal models.

   All other columns are interpreted as covariates, eg ``ndvi`` etc., UNLESS the module 
   implements the ``non_cov_columns`` attribute. For example, MBGWorld expects
   lo_age, up_age columns, pos and neg columns, but does not interpret them as covariates.
   

Options
-------

* ``-t`` or ``--thin`` : If thin is 10, every 10th MCMC iteration will be stored in the 
  database. Small values are good but slow. 1 is best.

* ``-i`` or ``--iter`` : The number of MCMC iterations to perform. Large values are good
  but slow.

* ``-n`` or ``-ncpus`` : The maximum number of CPU cores to make available to the MCMC 
  algorithm. Should be less than or equal to the number of cores in your computer. The 
  All the cores you make available may not be utilized. Use top or the Activity Monitor
  to monitor your actual CPU usage. Large values are good but tie up more of your computer.

``mbg-describe-tracefile``
==========================
::

    mbg-describe-tracefile path

If path is a database file, inspects the database file. Prints out the version of the 
generic package, the module that produced the file and the date the run was started. 
Writes the input data to csv with filename ``database-file-input-csv``, substituting 
the actual filename.

If the path is a directory, walks the filesystem starting from the directory, inspecting
every database file it finds. Does not produce any csvs.

Required arguments
------------------

1. The name of the database file or path to be inspected.


``mbg-covariate-traces``
========================
::

    mbg-covariate-traces module database-file [options]

Postprocesses the given database file to produce MCMC traces for the covariate 
coefficients. Produces a directory called database-file-covariate-traces, and populates 
it with pdf images of the covariate coefficient traces and  


Required arguments
------------------

1. The name of the module containing the model specification.

2. The name of the database file containing the MCMC trace.


Options
-------

* ``-t`` or ``--thin`` : If thin is 10, samples of the covariate coefficients will be
  produced for every 10th MCMC sample. Defaults to 1, meaning no thinning.

* ``-b`` or ``--burn`` : Samples of the covariate coefficients will begin after this
  many 'burnin' iterations are discarded. Defaults to 0, meaning no burnin.



``mbg-decluster``
========================
::

    mbg-decluster input prop [options]

A wrapper for the R function getdeclusteredsample that results in two new tables with 
suffix HOLDOUT and THINNED outut to same directory as tablepath  


Required arguments
------------------

1. (string) path to input table. must include columns 'lon' and 'lat'. If
   also 't' will treat as space-time. If only filename given (no path) assumes file
   in current working directory.

2. (float) what proportion of the full data set will be used for hold-out set.


Options
-------

* ``-m`` or ``--minsample`` : (int) optional minimum sample size (supercedes prop.
  if larger)

* ``-d`` or ``--decluster`` : (logical) do we want to draw spatially declustered
  sample (default) or just simple random.

* ``-p`` or ``--makeplot`` : (logical) do we want to export a pdf map showing
  location of data and selected points. This is exported to same directory as
  tablepathoptional minimum sample size (supercedes prop if larger).


``mbg-map``
===========
::

    mbg-map module database-file burn mask [options]

Produces a folder called ``name-maps`` where ``name`` is the name of the database file.
Puts the requested maps in the folder in ascii format. Also produces PDF images of all
the requested maps for quick viewing.

Required arguments
------------------

1. The name of the module containing the model specification.

2. The name of the database file (produced by mbg-infer) to be used to generate the 
   maps. If you do not want it to go in the current directory, specify a path.
   
3. The number of burnin iterations to discard from the trace before making the maps.
   You will need to figure this out by inspecting the traces produced by ``mbg-infer``.
   
4. The name of an ASCII file. The maps will be produced in ASCII files with identical
   headers and identical MISSING pixels. If the file is in a different directory, specify
   the path to it.

Options
-------

* ``-n`` or ``--n-bins`` : The number of bins to use in the histogram from which quantiles
  are computed. Large values are good, but use up more system memory. Decrease this if you
  see memory errors.

* ``-b`` or ``--bufsize`` : The number of buffer pixels to render around the edges of the
  continents. Set to zero unless the ``raster-thin`` option is greater than 1. The buffer
  will not be very good. In general, if you want a buffer you're better off making your 
  own in ArcView rather than using this option.

* ``-q`` or ``--quantiles`` : A string containing the quantiles you want. For example,
  ``'0.25 0.5 0.75'`` would map the lower and upper quartiles and the medial. Default is 
  ``'0.05 0.25 0.5 0.75 0.95'``.

* ``-r`` or ``--raster-thin`` : If you just want a quick preview, you can use this option to 
  render the maps on a degraded grid, then interpolate back to the original grid using splines. 
  For instance, if your input ASCII is on a 5km grid, and you use ``-r 5``, the maps will be 
  rendered on a 25km grid, then interpolated back to a 5km grid when it is time to produce 
  the output ASCIIs. Small values are good but slow. 1 is best.
  
  WARNING: The ``raster_thin`` argument has been implicated in some odd-looking results and 
  should only be used for quick previews.

* ``-t`` or ``--thin`` : The factor by which to thin the MCMC trace stored in the database.
  If you use ``-t 10``, only every 10th stored MCMC iteration will be used to produce the maps.
  Small values are good but slow. 1 is best.

* ``-i`` or ``--iter`` : The total number of predictive samples to use in generating the maps.
  Large values are good but slow. Defaults to 20000.

* ``-a`` or ``--ascii-path`` : The path to the ASCII files containing the covariate rasters.
  These files' headers must match those of the input raster, and their missing pixels must match
  those of the input raster also. There must be a file corresponding to every covariate column
  in input 3 of mbg-infer. For example, if you used ``rain`` and ``ndvi`` as your column headers,
  files ``rain.asc`` and ``ndvi.asc`` in the ascii path should be present in the ascii path.
  Defaults to the current working directory.

* ``-y`` or ``--year`` : If your model is spatiotemporal, you must provide the decimal year at 
  which you want your map produced. For example, Jan 1 2008 would be ``-y 2008``.


``mbg-validate``
================
::

    mbg-validate module database-file burn pred-pts [options]
    
mbg-validate produces a folder called ``name-validation``, ``name`` being the name of the database file.
It populates this folder with two csv files called ``p-samps`` and ``n-samps`` containing posterior
predictive samples of the probability of positivity and the number of individuals positive at each 
prediction location.

It also writes three of the four MBG world validation panels into the folder as PDF's.

Required arguments
------------------

1. The name of the module containing the model specification.

2. The name of the database file (produced by mbg-infer) to be used to generate the 
   maps. If you do not want it to go in the current directory, specify a path.
   
3. The number of burnin iterations to discard from the trace before making the maps.
   You will need to figure this out by inspecting the traces produced by ``mbg-infer``.
   
4. A csv file containing the 'holdout' dataset. It should be in exactly the same format
   as the third required input to ``mbg-infer``.

Options
-------

* ``-t`` or ``--thin`` : The factor by which to thin the MCMC trace stored in the database.
  Small values are good but slow. 1 is best.

* ``-i`` or ``--iter`` : The total number of predictive samples you want to generate. Large
  values are good but slow. Defaults to 20000.


``mbg-scalar-priors``
=====================
::

    mbg-scalar-priors module [options]

Required arguments
------------------

1. The name of the module containing the model specification.

Options
-------

* ``-i`` or ``--iter`` : The total number of predictive samples you want to generate. Large
  values are good but slow. Defaults to 20000.


``mbg-realize-prior``
=====================
::

    mbg-realize-prior module ascii0.asc ascii1.asc ... [options]
    
mbg-realize-prior produces a number of prior realizations of the target surface (eg parasite
rate, gene frequency, etc). on several different asciis. Joint or 'conditional' simulations
of surfaces are very expensive, so you can only afford to evaluate them on a few thousand
pixels. 

The multiple asciis are meant to be at multiple resolutions: you can make a coarse one over 
your entire area of interest, a medium-resolution one on a zoomed-in subset, and a few fine 
ones over small areas scattered around. That way you can see the large- and small-scale
properties of the surface allowed by your prior without having to render the entire surface
at full resolution.

Outputs a number of surfaces, evaluated onto the masks indicated by the input asciis. Each set
of realizations is coherent across the input asciis; that is, the 'same' surface is evaluated
on each ascii. That means you can meaningfully overlay the output asciis at different
resolutions.

NOTE: All the parameters of the model will be drawn from the prior before generating each
realization. If you want to fix a variable, you must set its ``observed`` flag.

Required arguments
------------------

1. The name of the module containing the model specification.

2. Several ascii files. Realizations will be evaluated on the union of the unmasked regions
   of these files.
   
Options
-------

* ``-n`` or ``--n-realizations`` : The number of realizations to generate. Defaults to 5.

* ``-m`` or ``--mean`` : The value of the global mean to use. Defaults to 0.

* ``-y`` or ``-year`` : If your model is spatiotemporal, you must provide the decimal year at 
  which you want your realizations produced. For example, Jan 1 2008 would be ``-y 2008``.



Module requirements
===================

This section tells you how to write new modules that will work with the shell commands.
You don't need to read this section to use the shell commands.

``make_model``
--------------

The primary thing a module must do to use the generic stuff is implement the function::

    make_model(pos, neg, lon, lat, [t], covariate_values, cpus=1, **non_covariate_columns)
    
The ``pos``, ``neg``, ``lon`` and ``lat`` columns are the obvious; longitude and
latitude should be in decimal degrees. The ``t`` column is only required for
spatiotemporal models, but if given it should be in units of decimal years.
The ``cpus`` argument specifies how many processor cores should be made available to
the current process.

The covariate values should be a dict of ``{name: column}`` pairs. If there are no covariates,
it should be expected to be empty. Modules should NOT use the covariates directly; rather
they should pass them to the function ``cd_and_C_eval`` to be incorporated into the
covariance function. While on the topic, the trivial mean function and its evaluation
should be generated using ``M_and_M_eval``.

The non-covariate columns are any point metadata that are required by the model, but are
not covariates. Examples are ``lo_age`` and ``up_age`` in MBGWorld. These columns must
take defaults, as no values will be provided by ``mbg-map``, ``mbg-realize-prior`` and 
``mbg-scalar-priors``.


The model must be based on a Gaussian random field. The only hard requirements are that 
it contain variables named ``M`` and ``C`` returning the mean and covairance function, 
and that the data depend on these via evaluation at a ``data mesh``, possibly with 
addition of unstructured random noise involved at some point.


Other attributes
----------------

The module must implement the following additional attributes:

* ``f_name`` : The name of the evaluation of the random field in the model. This node's
  trace will be used to generate predictions.
  
* ``x_name`` : The name of the mesh on which the field is evaluated to produce the
  previous node. The value of the mesh is expected to be present in the hdf5 archive's
  metadata. If it is not ``logp_mesh`` or ``data_mesh``, it should be mentioned in the
  ``metadata_keys`` attribute.
  
* ``f_has_nugget`` : A boolean indicating whether the ``f_name`` node is just the evaluation
  of the field, or the evaluation plus the nugget.
  
* ``nugget_name`` : The name of the nugget variance of the field. Not required if ``f_has_nugget``
  is false.

* ``diag_safe`` : A boolean indicating whether it is safe to assume ``C(x) = C.params['amp']**2``.
  Defaults to false.

* ``metadata_keys`` : A list of strings indicating the attributes of the model that should be
  interred in the metadata. These are recorded as PyTables variable-length arrays with object
  atoms, so they can be any picklable objects.

* ``non_cov_columns`` : A dictionary of ``{name : type}`` mappings for all the point metadata
  required by ``make_model`` that are not covariates.
  
* ``postproc`` : When mapping and predicting, ``make_model`` is not called. Rather, the mean and
  covariance are pulled out of the trace and used to generate field realizations, with nugget
  added as appropriate.
  
  At the prediction stage, ``postproc`` is the function that translates these Gaussian 
  realizations to realizations of the target quantity. The most common ``postproc`` is simply
  ``invlogit``. The generic mbg package provides a multithreaded, shape-preserving invlogit
  function that should be used in place of PyMC's.
  
  If the module has any non-covariate columns, ``postproc`` must be a function that has one of two
  behaviors: 
  
  1. If called with a standard Gaussian realization as its lone positional argument, it should 
     automatically apply default values for the non-covariate columns.
     
  2. If it is called with the non-covariate columns as keyword arguments, it should return a
     version of itself that is closed on these values as defaults. For example, for MBGWorld, 
     ``postproc`` would accept ``lo_age`` and ``up_age`` values as input and return a closure. 
     The latter would take Gaussian realizations, pass them through the inverse-logit function, 
     and multiply age-correction factors as needed. 

  Behavior 1 is used for prior realization and map generation, and behavior 2 is used to generate 
  samples for predictive validation.
  
The following attributes are optional:
  
* ``extra_reduce_fns`` : A list of reduction functions to be used in mapping. These should take two
  arguments, the first being the product so far and the second being a realization surface. The
  first argument will be None at the first call. The return value should be a new value for the
  first argument: an updated product so far.
  
* ``extra_finalize`` : A function converting the products of the extra reduce functions to output
  asciis. It should take two arguments, the first being a ``{fn : prod}`` dictionary where ``fn``
  is one of the extra reduce functions and ``prod`` is its final output; and the second being the
  total number of realization surfaces produced. The output should be a ``{name : surface}`` 
  dictionary, where all of the 'surfaces' are vectors ready to be injected into the mask and
  written out as ascii files.
  
  
Version logging and installations
---------------------------------

To avoid unpleasantness when restarting projects after leaving them for a long time in the future,
the SHA1 hash of the active commit of generic_mbg and the specialization module will be written into
the trace hdf5 by mbg-infer.

For this to work correctly, generic_mbg has to be installed using ``setup.py install`` and the 
specialization module using ``setup.py develop``. 