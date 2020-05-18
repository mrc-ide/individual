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
