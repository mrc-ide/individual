# individual 0.1.9

  * All variables and targeted events are resizable
  * Ragged variables for integers and doubles

# individual 0.1.8

  * [fix bug](https://github.com/mrc-ide/individual/pull/163) with C++ event
  listeners

# individual 0.1.7

  * Check for bad bitset input when queueing updates to CategoricalVariable objects 
  [PR here](https://github.com/mrc-ide/individual/pull/145)
  * Add "bench" package to suggests and include benchmarking scripts of major 
  functionality in `tests/performance` [PR here](https://github.com/mrc-ide/individual/pull/151)
  * Update to latest version of "testthat" package so that C++ tests of `IterableBitset`
  object can be run without giving LTO check errors (see `src/test-bitset.cpp`)
  * Add CITATION file
  * Add method `Bitset$clear` to zero out all set bits in bitsets [PR here](https://github.com/mrc-ide/individual/pull/157)
  * Fix bug ([issue here](https://github.com/mrc-ide/individual/issues/152)) where `DoubleVariable` and `IntegerVariable` updates could change size of the variable object [PR here](https://github.com/mrc-ide/individual/pull/156)
  
# individual 0.1.6

  * Added a `NEWS.md` file to track changes to the package.
  * Add Mac OS files to .gitignore
  * Update pkgdown reference organization.
  * Update [R-CMD-check workflow](https://github.com/r-lib/actions/tree/master/examples#standard-ci-workflow).
  * `Event.h` now defines class methods outside of the class definition for 
  easier readability, and add documentation.
  * `TargetedEvent$schedule` now dispatches to different C++ functions in `event.cpp`
  and `Event.h` depending on if input index is a bitset or vector (previous 
  behavior used bitset's $to_vector$ method in R to pass a vector).
  * `test-event.R` now only contains tests for `Event` class, new test file
  `test-targetedevent.R` contains a much updated suite of tests for the
  `TargetedEvent` class.
  * Fix bug where `CategoricalVariable` could be queued updates for indices in
  a vector that were outside the range of the population.
  * Update `Bitset$not` to operate in place. inplace = FALSE will be deprecated
    in 0.2.0
  * Rename the IterableBitset ~ operator to !

# individual 0.1.5

  * Added package logo.
  * Update DESCRIPTION and remove "reshape2" from suggested packages.
  * If given a `Bitset` for argument `index`, `queue_update` methods for 
  `IntegerVariable` and `DoubleVariable` pass the bitset directly to the C++ 
  functions `integer_variable_queue_update_bitset` and `double_variable_queue_update_bitset`
  rather than converting to vector and using vector methods.
  * `CategoricalVariable.h`, `IntegerVariable.h`, and `DoubleVariable.h` now define
  class methods outside of the class definition for easier readability, and add
  documentation.
  * `CategoricalVariable`, `IntegerVariable`, and `DoubleVariable` classes define
  a virtual destructor with default implementation.
  * `get_index_of_set` and `get_size_of_set_vector` methods for `IntegerVariable`
  now pass arguments by reference.
  * `get_values` method for `IntegerVariable` and `DoubleVariable` corrected to
  return value rather than reference.
  * add overload for `get_values` for `IntegerVariable` and `DoubleVariable` to
  accept `std::vector<size_t>` as argument rather than converting to bitset.
  * add function `bitset_to_vector_internal` to `IterableBitset.h`.
  * split `testthat/test/test-variables.R` into `testthat/test/test-categoricalvariable.R`,
  `testthat/test/test-integervariable.R`, and `testthat/test/test-doublevariable.R`
  * remove unnecessary `#include` statements from header files.
  * remove unnecessary comparisons for `size_t` types.
  
