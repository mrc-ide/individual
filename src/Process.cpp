/*
 * Process.cpp
 *
 *  Created on: 11 May 2020
 *      Author: gc1610
 */

#include "process.h"
#include <Rcpp.h>

Rcpp::Environment make_handle(std::string name) {
    Rcpp::Environment env = Rcpp::new_env(1);
    env.assign("name", name);
    return env;
}

ProcessAPI::ProcessAPI(Rcpp::XPtr<State> state, Rcpp::Environment scheduler, Rcpp::List r_params)
    :state(state),
     scheduler(scheduler) {
    if (r_params.size() > 0) {
        const auto& names = Rcpp::as<std::vector<std::string>>(r_params.names());
        for (const auto& name : names) {
            params.insert({ name, Rcpp::as<std::vector<double>>(r_params["name"]) });
        }
    }
}

const individual_index_t ProcessAPI::get_state(
    const std::string individual,
    const std::vector<std::string> states) const {
    return state->get_state(individual, states);
}

const variable_vector_t& ProcessAPI::get_variable(
    const std::string individual,
    const std::string variable) const {
    return state->get_variable(individual, variable);
}

void ProcessAPI::schedule(const std::string event, const individual_index_t& index, double delay) {
    Rcpp::Function schedule = scheduler["schedule"];
    auto index_vector = std::vector<size_t>(index.size());
    index_vector.insert(std::end(index_vector), std::cbegin(index), std::cend(index));
    schedule(make_handle(event), index_vector, delay);
}

individual_index_t ProcessAPI::get_scheduled(const std::string event) const {
    Rcpp::Function f = scheduler["get_scheduled"];
    Rcpp::IntegerVector result_vector = f(make_handle(event));
    return individual_index_t(std::cbegin(result_vector), std::cend(result_vector));
}

void ProcessAPI::clear_schedule(const std::string event, const individual_index_t& index) {
    Rcpp::Function f = scheduler["clear_scheduled"];
    auto index_vector = std::vector<size_t>(index.size());
    index_vector.insert(std::end(index_vector), std::cbegin(index), std::cend(index));
    f(make_handle(event), index_vector);
}

size_t ProcessAPI::get_timestep() const {
    Rcpp::Function f = scheduler["get_timestep"];
    return Rcpp::as<size_t>(f());
}

const params_t& ProcessAPI::get_parameters() const {
    return params;
}

void ProcessAPI::queue_state_update(
    const std::string individual,
    const std::string state,
    const individual_index_t& index) {
    this->state->queue_state_update(individual, state, index);
}

void ProcessAPI::queue_variable_update(
    const std::string individual,
    const std::string state,
    const std::vector<size_t>& index,
    const variable_vector_t& values) {
    this->state->queue_variable_update(individual, state, index, values);
}
