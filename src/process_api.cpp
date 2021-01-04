/*
 * process_api.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#include "../inst/include/ProcessAPI.h"

inline void decrement(std::vector<size_t>& x) {
    for (auto i = 0u; i < x.size(); ++i) {
        --x[i];
    }
}

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
    auto i = 0u;
    for (const auto& state : states) {
        const auto& index = api->get_state(individual, state);
        for (auto v : index) {
            result.push_back(v + 1);
            ++i;
        }
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

//[[Rcpp::export]]
void process_schedule(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string event,
    std::vector<size_t> index_vector,
    double delay
) {
    decrement(index_vector);
    api->schedule(event, index_vector, delay);
}

//[[Rcpp::export]]
void process_schedule_multi_delay(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string event,
    std::vector<size_t> index_vector,
    std::vector<double> delay
) {
    decrement(index_vector);
    api->schedule(event, index_vector, delay);
}

//[[Rcpp::export]]
std::vector<size_t> process_get_scheduled(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string event
) {
    const auto result = api->get_scheduled(event);
    auto r_result = std::vector<size_t>(result.size());
    auto i = 0u;
    for (auto r : result) {
        r_result[i] = r + 1;
        ++i;
    }
    return r_result;
}

//[[Rcpp::export]]
void process_clear_schedule(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string event,
    std::vector<size_t> index
) {
    decrement(index);
    api->clear_schedule(event, index);
}

//[[Rcpp::export]]
size_t process_get_timestep(Rcpp::XPtr<ProcessAPI> api) {
    return api->get_timestep();
}
