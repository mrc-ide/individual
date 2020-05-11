/*
 * Process.cpp
 *
 *  Created on: 11 May 2020
 *      Author: gc1610
 */

#include "process.h"
#include <Rcpp.h>

Rcpp::Environment make_handle(std::string name) {
    Rcpp::Environment env();
    env.assign("name", name);
    return env;
}

ProcessAPI::ProcessAPI(StateCppAPI &state, Rcpp::Environment rapi)
    :state(state),
     rapi(rapi) {
    Rcpp::Function f = rapi["get_parameters"];
    Rcpp::List r_params = f();
    for (std::string name : r_params.names()) {
        params.insert({ name, Rcpp::as<std::vector<double>>(r_params["name"]) });
    }
}

const individual_index_t& ProcessAPI::get_state(std::string individual,
    std::vector<std::string> states) const {
    return state.get_state(individual, states);
}

const variable_vector_t& ProcessAPI::get_variable(std::string individual,
    std::string variable) const {
    return state.get_variable(individual, variable);
}

void ProcessAPI::schedule(std::string event, individual_index_t& index, double delay) {
    Rcpp::Function schedule = rapi["schedule"];
    auto index_vector = std::vector<size_t>(index.size());
    index_vector.insert(std::end(index_vector), std::cbegin(index), std::cend(index));
    schedule(make_handle(event), index_vector, delay);
}

individual_index_t ProcessAPI::get_scheduled(std::string event) const {
    Rcpp::Function f = rapi["get_scheduled"];
    f(make_handle(event));
}

void ProcessAPI::clear_schedule(std::string event, individual_index_t& index) {
    Rcpp::Function f = rapi["clear_scheduled"];
    auto index_vector = std::vector<size_t>(index.size());
    index_vector.insert(std::end(index_vector), std::cbegin(index), std::cend(index));
    f(make_handle(event), index_vector);
}

size_t ProcessAPI::get_timestep() const {
    Rcpp::Function f = rapi["get_timestep"];
    return f();
}

const params_t& ProcessAPI::get_parameters() const {
    return params;
}
