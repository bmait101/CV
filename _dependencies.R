# renv's dependency scanner skips _targets.R (it treats underscore-prefixed
# paths as build artifacts), so targets/tarchetypes never get picked up by
# renv::dependencies()/renv::snapshot() even though _targets.R uses them.
# This file exists purely so renv sees them as real project dependencies.
library(targets)
library(tarchetypes)
