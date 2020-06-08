/*
 * prefab.cpp
 *
 *  Created on: 13 May 2020
 *      Author: gc1610
 */

#include <Rcpp.h>
#include "../inst/include/ProcessAPI.h"

//'@title create a listener to update the state of the target population
//'@param individual the name of the individual type
//'@param state the state to transition to
//'@export
//[[Rcpp::export]]
Rcpp::XPtr<listener_t> update_state_listener(
    const std::string individual,
    const std::string state
    ) {
    return Rcpp::XPtr<listener_t>(
        new listener_t([=] (
                ProcessAPI& api,
                const individual_index_t& target
            ) {
            api.queue_state_update(individual, state, target);
        }),
        true
    );
}

//'@title create a listener to schedule a target population for a new event
//'@param event the name of the event to schedule
//'@param delay the delay for the new event
//'@export
//[[Rcpp::export]]
Rcpp::XPtr<listener_t> reschedule_listener(const std::string event, double delay) {
    return Rcpp::XPtr<listener_t>(
        new listener_t([=] (
                ProcessAPI& api,
                const individual_index_t& target
            ) {
            api.schedule(event, target, delay);
        }),
        true
    );
}

//'@title create a process to transition individuals between states at a constant rate
//'@param individual the name of an individual
//'@param from_state the name of the source state
//'@param to_state the name of the target state
//'@param rate the rate at which state transitions occur
//'@export
//[[Rcpp::export]]
Rcpp::XPtr<process_t> fixed_probability_state_change_process(
    const std::string individual,
    const std::string from_state,
    const std::string to_state,
    double rate
    ) {
    return Rcpp::XPtr<process_t>(
        new process_t([=] (
            ProcessAPI& api) {
            auto target_individuals = api.get_state(individual, from_state);
            const auto& random = Rcpp::runif(target_individuals.size());
            auto random_index = 0;
            for (const auto individual : target_individuals) {
                if (random[random_index] > rate) {
                    target_individuals.erase(individual);
                }
                ++random_index;
            }
            api.queue_state_update(individual, to_state, target_individuals);
        }),
        true
    );
}

//'@title create a process to render the number of individuals in the specified states
//'@param individual the name of an individual
//'@param states a vector of state names
//'@export
//[[Rcpp::export]]
Rcpp::XPtr<process_t> state_count_renderer_process(
    const std::string individual,
    const std::vector<std::string> states
    ) {
    return Rcpp::XPtr<process_t>(
        new process_t([=] (
            ProcessAPI& api) {
            for (const auto& state : states) {
                const auto& state_index = api.get_state(individual, state);
                std::stringstream name;
                name << individual << '_' << state << "_count";
                api.render(name.str(), state_index.size());
            }
        }),
        true
    );
}

//'@title create a process to render the mean value of the specified variables
//'@param individual the name of an individual
//'@param variables a vector of variable names
//'@export
//[[Rcpp::export]]
Rcpp::XPtr<process_t> variable_mean_renderer_process(
    const std::string individual,
    const std::vector<std::string> variables
    ) {
    return Rcpp::XPtr<process_t>(
        new process_t([=] (
            ProcessAPI& api) {
            for (const auto& variable : variables) {
                const auto& values = api.get_variable(individual, variable);
                std::stringstream name;
                name << individual << '_' << variable << "_mean";
                auto mean = 0.;
                for (auto value : values) {
                    mean += value;
                }
                api.render(name.str(), mean / values.size());
            }
        }),
        true
    );
}


//[[Rcpp::export]]
void execute_process(Rcpp::XPtr<process_t> process, Rcpp::XPtr<ProcessAPI> api) {
    (*process)(*api);
}