#include <individual.h>
#include <Rcpp.h>

//[[Rcpp::export]]
Rcpp::XPtr<process_t> create_render_process() {
    return Rcpp::XPtr<process_t>(
        new process_t([=] (ProcessAPI& api) {
              api.render(
                "susceptible_counts",
                api.get_state("human", "susceptible").size()
              );
              api.render(
                "infected_counts",
                api.get_state("human", "infected").size()
              );
              api.render(
                "recovered_counts",
                api.get_state("human", "recovered").size()
              );
        }),
        true
    );
}
