/*
 * scheduler.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#include "../inst/include/ProcessAPI.h"

//[[Rcpp::export]]
Rcpp::XPtr<scheduler_t> create_scheduler(const Rcpp::List individuals) {
    auto event_spec = std::vector<event_t>();
    for (const Rcpp::Environment& individual : individuals) {
        auto pop_size = 0u;
        Rcpp::List state_descriptors(individual["states"]);
        for (Rcpp::Environment state : state_descriptors) {
            auto state_size = Rcpp::as<size_t>(state["initial_size"]);
            pop_size += state_size;
        }
        for (const Rcpp::Environment& event : (Rcpp::List) individual["events"]) {
            auto event_name = Rcpp::as<std::string>(event["name"]);
            Rcpp::List listener_exps = event["listeners"];
            auto listeners = std::vector<SEXP>(
                std::begin(listener_exps),
                std::end(listener_exps)
            );
            event_spec.push_back({event_name, pop_size, listeners});
        }
    }
    auto scheduler = new scheduler_t(event_spec);
    return Rcpp::XPtr<scheduler_t>(scheduler, true);
}

//[[Rcpp::export]]
void scheduler_tick(const Rcpp::XPtr<scheduler_t> scheduler) {
    scheduler->tick();
}

//[[Rcpp::export]]
void scheduler_process_events(
    const Rcpp::XPtr<scheduler_t> scheduler,
    const Rcpp::XPtr<ProcessAPI> cpp_api,
    const Rcpp::Environment r_api
    ) {
    scheduler->process_events(cpp_api, r_api);
}
