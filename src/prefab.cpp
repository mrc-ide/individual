/*
 * prefab.cpp
 *
 *  Created on: 13 May 2020
 *      Author: gc1610
 */

#include "prefab.h"

listener_t update_state(const std::string individual, const std::string state) {
    return [=] (
            ProcessAPI& api,
            individual_index_t& target
        ) {
        api.queue_state_update(individual, state, target);
    };
}

listener_t reschedule(const std::string event, double delay) {
    return [=] (
            ProcessAPI& api,
            individual_index_t& target
        ) {
        api.schedule(event, target, delay);
    };
}

process_t fixed_probability_state_change(
    const std::string individual,
    const std::string from_state,
    const std::string to_state,
    double rate
    ) {
    return [=] (ProcessAPI& api) {
        const auto& source_individuals = api.get_state(individual, from_state);
        const auto& random = Rcpp::runif(source_individuals.size());
        auto target_individuals = individual_index_t();
        auto random_index = 0;
        for (const auto individual : source_individuals) {
            if (random[random_index] < rate) {
                target_individuals.insert(individual);
            }
            ++random_index;
        }
        api.queue_state_update(individual, to_state, target_individuals);
    };
}

process_t state_count_renderer(
    const std::string individual,
    const std::vector<std::string> states
    ) {
    return [=] (ProcessAPI& api) {
        for (const auto& state : states) {
            const auto& state_index = api.get_state(individual, state);
            std::stringstream name;
            name << individual << '_' << state << "_count";
            api.render(name.str(), state_index.size());
        }
    };
}

process_t variable_mean_renderer(
    const std::string individual,
    const std::vector<std::string> variables
    ) {
    return [=] (ProcessAPI& api) {
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
    };
}
