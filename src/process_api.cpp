/*
 * process_api.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#include "../inst/include/ProcessAPI.h"

//[[Rcpp::export]]
Rcpp::XPtr<ProcessAPI> create_process_api(
    Rcpp::XPtr<State> state,
    Rcpp::XPtr<scheduler_t> scheduler,
    Rcpp::List params,
    Rcpp::Environment renderer) {
    auto api = new ProcessAPI(state, scheduler, params, renderer);
    return Rcpp::XPtr<ProcessAPI>(api, true);
}

//[[Rcpp::export]]
std::vector<size_t> process_get_state(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::vector<std::string> states) {
    auto result = std::vector<size_t>();
    for (const auto& state : states) {
        const auto& index = api->get_state(individual, state);
        result.insert(result.end(), cbegin(index), cend(index));
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
    const std::vector<size_t> index
    ) {
    auto result = std::vector<double>();
    api->get_variable(individual, variable, index, result);
    return result;
}

//[[Rcpp::export]]
void process_queue_state_update(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string state,
    const std::vector<size_t> index_vector
) {
    auto index = individual_index_t(index_vector.begin(), index_vector.end());
    api->queue_state_update(individual, state, index);
}

//[[Rcpp::export]]
void process_queue_variable_update(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string variable,
    const std::vector<size_t> index,
    const std::vector<double> values
) {
    api->queue_variable_update(individual, variable, index, values);
}

//[[Rcpp::export]]
void process_schedule(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string event,
    const std::vector<size_t> index_vector,
    double delay
) {
    auto index = individual_index_t(index_vector.begin(), index_vector.end());
    api->schedule(event, index, delay);
}

//[[Rcpp::export]]
std::vector<size_t> process_get_scheduled(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string event
) {
    auto result = individual_index_t();
    api->get_scheduled(event, result);
    return std::vector<size_t>(result.begin(), result.end());
}

//[[Rcpp::export]]
void process_clear_schedule(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string event,
    const std::vector<size_t> index
) {
    api->clear_schedule(event, index);
}

//[[Rcpp::export]]
size_t process_get_timestep(Rcpp::XPtr<ProcessAPI> api) {
    return api->get_timestep();
}
