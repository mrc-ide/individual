/*
 * SimulationFrame.cpp
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#include "StateAPI.h"

StateAPI::StateAPI(
		StateCppAPI impl,
    )
    : impl(impl)
{}

std::vector<size_t> StateAPI::get_state(
        const Rcpp::Environment individual,
        const Rcpp::List state_descriptors
    ) const {
    auto state_names = std::vector<std::string>(state_descriptors.size());
    for (auto i = 0u; i < state_descriptors.size(); ++i) {
        state_names[i] = Rcpp::as<std::string>(state["name"]);
    }
    return impl.get_state(
        Rcpp::as<std::string>(individual["name"]),
        state_names
    );
}

std::vector<double> StateAPI::get_variable(
		Rcpp::Environment individual,
		Rcpp::Environment variable
    ) const {
    return impl.get_variable(
        Rcpp::as<std::string>(individual["name"]),
        Rcpp::as<std::string>(variable["name"])
    );
}
