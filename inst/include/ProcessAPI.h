/*
 * Process.h
 *
 *  Created on: 18 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_PROCESSAPI_H_
#define INST_INCLUDE_PROCESSAPI_H_

#include "State.h"

using params_t = named_array_t<std::vector<double>>;

class ProcessAPI;

using process_t = std::function<void (ProcessAPI&)>;

class ProcessAPI {
private:
    Rcpp::XPtr<State> state;
    params_t params;
public:
    ProcessAPI(Rcpp::XPtr<State>, Rcpp::List);
    virtual const individual_index_t& get_state(const std::string&, const std::string&) const;
    virtual const variable_vector_t& get_variable(const std::string&, const std::string&) const;
    virtual void get_variable(
        const std::string&,
        const std::string&,
        const std::vector<size_t>&,
        std::vector<double>&) const;
    virtual const params_t& get_parameters() const;
    virtual void queue_state_update(
        const std::string&,
        const std::string&,
        const individual_index_t&
    );
    virtual void queue_state_update(
        const std::string&,
        const std::string&,
        const std::vector<size_t>&
    );
    virtual void queue_variable_update(
        const std::string&,
        const std::string&,
        const std::vector<size_t>&,
        const variable_vector_t&
    );
    virtual void queue_variable_fill(
            const std::string&,
            const std::string&,
            const double
    );

    //virtual dtor
    virtual ~ProcessAPI() = default;

    //moving is still supported
    ProcessAPI(ProcessAPI&&) = default;
    ProcessAPI& operator=(ProcessAPI&&) = default;

    //copying is still supported
    ProcessAPI(ProcessAPI&) = default;
    ProcessAPI& operator=(ProcessAPI&) = default;
};

inline ProcessAPI::ProcessAPI(
    Rcpp::XPtr<State> state,
    Rcpp::List r_params
    )
    :state(state) {
    if (r_params.size() > 0) {
        const auto& names = Rcpp::as<std::vector<std::string>>(r_params.names());
        for (const auto& name : names) {
            if (Rf_isNull(r_params[name])) {
                params.insert({ name, std::vector<double>() });
            } else {
                params.insert({ name, Rcpp::as<std::vector<double>>(r_params[name]) });
            }
        }
    }
}

inline const individual_index_t& ProcessAPI::get_state(
    const std::string& individual,
    const std::string& state_name) const {
    return state->get_state(individual, state_name);
}

inline const variable_vector_t& ProcessAPI::get_variable(
    const std::string& individual,
    const std::string& variable) const {
    return state->get_variable(individual, variable);
}

inline void ProcessAPI::get_variable(
    const std::string& individual,
    const std::string& variable,
    const std::vector<size_t>& index,
    std::vector<double>& result
    ) const {
    state->get_variable(individual, variable, index, result);
}

inline const params_t& ProcessAPI::get_parameters() const {
    return params;
}

inline void ProcessAPI::queue_state_update(
    const std::string& individual,
    const std::string& state,
    const individual_index_t& index) {
    this->state->queue_state_update(individual, state, index);
}

inline void ProcessAPI::queue_state_update(
    const std::string& individual,
    const std::string& state,
    const std::vector<size_t>& index) {
    this->state->queue_state_update(individual, state, index);
}

inline void ProcessAPI::queue_variable_update(
    const std::string& individual,
    const std::string& state,
    const std::vector<size_t>& index,
    const variable_vector_t& values) {
    this->state->queue_variable_update(individual, state, index, values);
}

inline void ProcessAPI::queue_variable_fill(
        const std::string& individual,
        const std::string& state,
        const double value) {
    this->state->queue_variable_update(individual, state, std::vector<size_t>(), std::vector<double>(1, value));
}

#endif /* INST_INCLUDE_PROCESSAPI_H_ */
