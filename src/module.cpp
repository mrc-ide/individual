/*
 * module.cpp
 *
 *  Created on: 2 Mar 2020
 *      Author: giovanni
 */

#include <Rcpp.h>
#include "Process.h"
#include "State.h"

/*
 * State exports
 */

//[[Rcpp::export]]
Rcpp::XPtr<State> create_state(const Rcpp::List individuals) {
    const auto state = new State(individuals);
    return Rcpp::XPtr<State>(&state, true);
}

//[[Rcpp::export]]
void state_apply_updates(Rcpp::XPtr<State> state) {
    state->apply_updates();
}


/*
 * ProcessAPI exports
 */

//[[Rcpp::export]]
Rcpp::XPtr<ProcessAPI> create_process_api(
    Rcpp::XPtr<State> state,
    Rcpp::Environment scheduler,
    Rcpp::List params) {
    const auto api = new ProcessAPI(state, scheduler, params);
    return Rcpp::XPtr<State>(&api, true);
}

//[[Rcpp::export]]
std::vector<size_t> process_get_state(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::vector<std::string> states) {
    const auto& result = api->get_state(individual, states);
    auto result_vector = std::vector<size_t>(result.size());
    result_vector.insert(end(result_vector), cbegin(result), cend(result));
    return result_vector;
}

//[[Rcpp::export]]
std::vector<double> process_get_variable(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string variable) {
    const auto& result = api->get_variable(individual, variable);
    auto result_vector = std::vector<double>(result.size());
    result_vector.insert(end(result_vector), cbegin(result), cend(result));
    return result_vector;
}

//[[Rcpp::export]]
void process_queue_state_update(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string state,
    const vector<size_t> index_vector
) {
    auto index = individual_index_t(index_vector.begin(), index_vector.end());
    api->queue_state_update(individual, state, index);
}

//[[Rcpp::export]]
void process_queue_variable_update(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string variable,
    const vector<size_t> index_vector,
    const vector<double> values
) {
    auto index = individual_index_t(index_vector.begin(), index_vector.end());
    api->queue_state_update(individual, variable, index, values);
}
