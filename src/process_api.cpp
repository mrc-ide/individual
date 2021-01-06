/*
 * process_api.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#include "../inst/include/ProcessAPI.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<ProcessAPI> create_process_api(
    Rcpp::XPtr<State> state,
    Rcpp::List params
    ) {
    auto api = new ProcessAPI(state, params);
    return Rcpp::XPtr<ProcessAPI>(api, true);
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> process_get_state(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    size_t size,
    const std::vector<std::string> states) {
    auto result = new individual_index_t(size);
    for (const auto& state : states) {
        const auto& index = api->get_state(individual, state);
        (*result) |= index;
    }
    return Rcpp::XPtr<individual_index_t>(result, true);
}

// [[Rcpp::export]]
int process_get_state_size(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::vector<std::string> states
){
    int result{0};
    for (const auto& state : states) {
        result += api->get_state_size(individual, state);
    }
    return result;
}

//[[Rcpp::export]]
std::vector<double> process_get_variable(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string variable) {
    return api->get_variable(individual, variable);
}

//[[Rcpp::export]]
std::vector<double> process_get_variable_at_index(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string variable,
    std::vector<size_t> index
    ) {
    auto result = std::vector<double>();
    decrement(index);
    api->get_variable(individual, variable, index, result);
    return result;
}

//[[Rcpp::export]]
void process_queue_state_update(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string state,
    std::vector<size_t> index_vector
) {
    decrement(index_vector);
    api->queue_state_update(individual, state, index_vector);
}

//[[Rcpp::export]]
void process_queue_variable_update(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string variable,
    std::vector<size_t> index,
    const std::vector<double> values
) {
    decrement(index);
    api->queue_variable_update(individual, variable, index, values);
}

//[[Rcpp::export]]
void process_queue_variable_fill(
        Rcpp::XPtr<ProcessAPI> api,
        const std::string individual,
        const std::string variable,
        const double value
) {
    api->queue_variable_fill(individual, variable, value);
}
