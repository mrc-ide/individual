/*
 * module.cpp
 *
 *  Created on: 2 Mar 2020
 *      Author: giovanni
 */

#include <Rcpp.h>
#include "Process.h"
#include "State.h"
#include "prefab.h"

/*
 * State exports
 */

//[[Rcpp::export]]
Rcpp::XPtr<State> create_state(const Rcpp::List individuals) {
    auto sim_state_spec = sim_state_spec_t();
    for (const Rcpp::Environment& individual : individuals) {
        auto individual_name = Rcpp::as<std::string>(individual["name"]);
        auto state_spec = std::vector<state_spec_t>();
        auto pop_size = 0u;
        Rcpp::List state_descriptors(individual["states"]);
        for (Rcpp::Environment state : state_descriptors) {
            auto state_size = Rcpp::as<size_t>(state["initial_size"]);
            pop_size += state_size;
            state_spec.push_back({
                Rcpp::as<std::string>(state["name"]),
                state_size
            });
        }

        auto variable_spec = std::vector<variable_spec_t>();
        Rcpp::List variable_descriptors(individual["variables"]);
        for (Rcpp::Environment variable : variable_descriptors) {
            Rcpp::Function initialiser(variable["initialiser"]);
            auto initial_values = Rcpp::as<variable_vector_t>(initialiser(pop_size));
            variable_spec.push_back({
                Rcpp::as<std::string>(variable["name"]),
                initial_values
            });
        }
        sim_state_spec.push_back({individual_name, state_spec, variable_spec});
    }
    auto state = new State(sim_state_spec);
    return Rcpp::XPtr<State>(state, true);
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
    auto api = new ProcessAPI(state, scheduler, params);
    return Rcpp::XPtr<ProcessAPI>(api, true);
}

//[[Rcpp::export]]
std::vector<size_t> process_get_state(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::vector<std::string> states) {
    const auto result = api->get_state(individual, states);
    auto result_vector = std::vector<size_t>();
    result_vector.insert(end(result_vector), cbegin(result), cend(result));
    return result_vector;
}

//[[Rcpp::export]]
std::vector<double> process_get_variable(
    Rcpp::XPtr<ProcessAPI> api,
    const std::string individual,
    const std::string variable) {
    const auto& result = api->get_variable(individual, variable);
    auto result_vector = std::vector<double>();
    result_vector.insert(end(result_vector), cbegin(result), cend(result));
    return result_vector;
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

/*
 * Process execution
 */

//[[Rcpp::export]]
void execute_process(Rcpp::XPtr<process_t> process, Rcpp::XPtr<ProcessAPI> api) {
    (*process)(*api);
}

//[[Rcpp::export]]
void execute_listener(
    Rcpp::XPtr<listener_t> listener,
    Rcpp::XPtr<ProcessAPI> api,
    std::vector<size_t> target
    ) {
    auto target_index = individual_index_t(target.begin(), target.end());
    (*listener)(*api, target_index);
}

/*
 * Prefab processes and listeners
 */

//' @export
//[[Rcpp::export]]
Rcpp::XPtr<process_t> fixed_probability_state_change_process(
    const std::string individual,
    const std::string state_from,
    const std::string state_to,
    double rate
    ) {
    auto process = fixed_probability_state_change(individual, state_from, state_to, rate);
    return Rcpp::XPtr<process_t>(new process_t(process), true);
}

//' @export
//[[Rcpp::export]]
Rcpp::XPtr<listener_t> update_state_listener(const std::string individual, const std::string state) {
    auto listener = update_state(individual, state);
    return Rcpp::XPtr<listener_t>(new listener_t(listener), true);
}

//' @export
//[[Rcpp::export]]
Rcpp::XPtr<listener_t> reschedule_listener(const std::string event, double delay) {
    auto listener = reschedule(event, delay);
    return Rcpp::XPtr<listener_t>(new listener_t(listener), true);
}
