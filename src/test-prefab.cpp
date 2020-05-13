/*
 * This file uses the Catch unit testing library, alongside
 * testthat's simple bindings, to test a C++ function.
 *
 * For your own packages, ensure that your test files are
 * placed within the `src/` folder, and that you include
 * `LinkingTo: testthat` within your DESCRIPTION file.
 */

#include <testthat.h>
#include <Rcpp.h>
#include "prefab.h"
#include "Process.h"

context("Prefab unittests") {

  test_that("fixed probability state change works as expected") {
      auto state = State(sim_state_spec_t{
          {
              "human",
              {{"S", 100}, {"I", 10}, {"R", 0}},
              {}
          }
      });
      auto api = ProcessAPI(
          Rcpp::XPtr<State>(&state, false),
          Rcpp::new_env(),
          Rcpp::List()
      );
      auto process = fixed_probability_state_change("human", "S", "I", .5);
  }

}
