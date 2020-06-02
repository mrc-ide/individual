/*
 * Process.h
 *
 *  Created on: 18 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_PROCESSAPI_H_
#define INST_INCLUDE_PROCESSAPI_H_

#include "State.h"
#include "Scheduler.h"

using params_t = named_array_t<std::vector<double>>;

class ProcessAPI;

using scheduler_t = Scheduler<ProcessAPI>;
using process_t = std::function<void (ProcessAPI&)>;
using listener_t = std::function<void (ProcessAPI&, const individual_index_t&)>;

class ProcessAPI {
private:
    Rcpp::XPtr<State> state;
    Rcpp::XPtr<scheduler_t> scheduler;
    Rcpp::Environment renderer;
    params_t params;
public:
    ProcessAPI(Rcpp::XPtr<State>, Rcpp::XPtr<scheduler_t>, Rcpp::List, Rcpp::Environment);
    const individual_index_t& get_state(const std::string&, const std::string&) const;
    const variable_vector_t& get_variable(const std::string&, const std::string&) const;
    void get_variable(
        const std::string&,
        const std::string&,
        const std::vector<size_t>&,
        std::vector<double>&) const;
    template<class TIndex>
    void schedule(const std::string&, const TIndex&, double);
    individual_index_t get_scheduled(const std::string&) const;
    template<class TIndex>
    void clear_schedule(const std::string&, const TIndex&);
    void render(const std::string&, double, size_t);
    void render(const std::string&, double);
    size_t get_timestep() const;
    const params_t& get_parameters() const;
    void queue_state_update(
        const std::string&,
        const std::string&,
        const individual_index_t&
    );
    void queue_state_update(
        const std::string&,
        const std::string&,
        const std::vector<size_t>&
    );
    void queue_variable_update(
        const std::string&,
        const std::string&,
        const std::vector<size_t>&,
        const variable_vector_t&
    );
};

inline ProcessAPI::ProcessAPI(
    Rcpp::XPtr<State> state,
    Rcpp::XPtr<scheduler_t> scheduler,
    Rcpp::List r_params,
    Rcpp::Environment renderer)
    :state(state),
     renderer(renderer),
     scheduler(scheduler) {
    if (r_params.size() > 0) {
        const auto& names = Rcpp::as<std::vector<std::string>>(r_params.names());
        for (const auto& name : names) {
            params.insert({ name, Rcpp::as<std::vector<double>>(r_params[name]) });
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

template<class TIndex>
inline void ProcessAPI::schedule(
    const std::string& event,
    const TIndex& index,
    double delay) {
    scheduler->schedule(event, index, delay);
}

inline individual_index_t ProcessAPI::get_scheduled(const std::string& event) const {
    return scheduler->get_scheduled(event);
}

template<class TIndex>
inline void ProcessAPI::clear_schedule(
    const std::string& event,
    const TIndex& index) {
    scheduler->clear_schedule(event, index);
}

inline void ProcessAPI::render(const std::string& name, double value, size_t timestep) {
    Rcpp::Function f = renderer["add"];
    f(name, value, timestep);
}

inline void ProcessAPI::render(const std::string& name, double value) {
    render(name, value, get_timestep());
}

inline size_t ProcessAPI::get_timestep() const {
    return scheduler->get_timestep();
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

#endif /* INST_INCLUDE_PROCESSAPI_H_ */
