#include <Rcpp.h>
#include <individual.h>
#include <testthat.h>
#include <mockcpp.h>
#include "code.h"

/*
 * Derive a mock api class from the ProcessAPI
 * See https://github.com/rollbear/trompeloeil
 */
class MockAPI : public ProcessAPI {
public:
    MockAPI() : ProcessAPI( // Initialise the ProcessAPI using some empty state
        Rcpp::XPtr<State>(static_cast<State *>(nullptr), false),
        Rcpp::XPtr<Scheduler<ProcessAPI>>(static_cast<Scheduler<ProcessAPI>*>(nullptr), false),
        Rcpp::List(),
        Rcpp::Environment()
    ) {};
    MAKE_CONST_MOCK2(get_state, const individual_index_t&(const std::string& individual, const std::string& state), override);
    MAKE_MOCK2(render, void(const std::string& label, double value), override);
};


context("State rendering") {
    test_that("state rendering returns the correct counts") {
          MockAPI api;
          auto population_size = 20;
          
          /*
           * Check the get_state calls
           */
          auto S = individual_index_t(
            population_size,
            std::vector<size_t>{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
          );
          auto I = individual_index_t(
            population_size,
            std::vector<size_t>{10, 11, 12, 13, 14}
          );
          auto R = individual_index_t(
            population_size,
            std::vector<size_t>{15, 16}
          );
          REQUIRE_CALL(api, get_state("human", "susceptible")).RETURN(S);
          REQUIRE_CALL(api, get_state("human", "infected")).RETURN(I);
          REQUIRE_CALL(api, get_state("human", "recovered")).RETURN(R);
          
          /*
           * Check the render calls
           */
          REQUIRE_CALL(api, render("susceptible_counts", 10));
          REQUIRE_CALL(api, render("infected_counts", 5));
          REQUIRE_CALL(api, render("recovered_counts", 2));
          
          /*
           * Call the render process with our mocked api
           */
          auto renderer = create_render_process();
          (*renderer)(api);
    }
}
