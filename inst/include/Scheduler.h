/*
 * Scheduler.h
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_SCHEDULER_H_
#define INST_INCLUDE_SCHEDULER_H_

#include "common_types.h"

//'@title event type
//'@description a description of an event
//'There are three components:
//'
//' 1. The name of the event, e.g. 'infection'
//' 2. The max size of the target population, e.g. 60,000 humans.
//' 3. A vector of listeners to execute when the event is triggered.
using event_t = std::tuple<std::string, size_t, std::vector<SEXP>>;

//'@title timeline type
//'@description a map from timesteps to target individuals
using timeline_t = std::unordered_map<size_t, individual_index_t>;

template<class TProcessAPI>
using listener_template_t = std::function<void (TProcessAPI&, const individual_index_t&)>;

template<class TProcessAPI>
class Scheduler {
    std::vector<event_t> events;
    named_array_t<size_t> size_map;
    size_t current_timestep;
    named_array_t<timeline_t> schedule_map;
public:
    Scheduler(const std::vector<event_t>&);
    size_t get_timestep() const;
    void tick();
    void process_events(Rcpp::XPtr<TProcessAPI>, Rcpp::Environment api);
    template<class TIndex>
    void clear_schedule(const std::string&, const TIndex&);
    individual_index_t get_scheduled(const std::string&) const;
    template<class TIndex>
    void schedule(const std::string&, const TIndex&, double);
};

template<class TProcessAPI>
inline Scheduler<TProcessAPI>::Scheduler(const std::vector<event_t>& events)
    : events(events), current_timestep(1u) {
    for (auto i = 0u; i < events.size(); ++i) {
        const auto& event = events[i];
        schedule_map[std::get<0>(event)] = timeline_t();
        size_map[std::get<0>(event)] = std::get<1>(event);
    }
}

template<class TProcessAPI>
inline size_t Scheduler<TProcessAPI>::get_timestep() const { return current_timestep; }

template<class TProcessAPI>
inline void Scheduler<TProcessAPI>::tick() {
    for (const auto& event : events) {
        schedule_map.at(std::get<0>(event)).erase(current_timestep);
    }
    ++current_timestep;
}

template<class TProcessAPI>
inline void Scheduler<TProcessAPI>::process_events(
    Rcpp::XPtr<TProcessAPI> cpp_api,
    Rcpp::Environment r_api) {
    for (const auto& event : events) {
        auto& timeline = schedule_map.at(std::get<0>(event));
        if (timeline.find(current_timestep) != timeline.end()) {
            const auto& target = timeline.at(current_timestep);
            for (const auto& listener : std::get<2>(event)) {
                if (TYPEOF(listener) == EXTPTRSXP) {
                    auto cpp_listener = Rcpp::as<Rcpp::XPtr<
                        listener_template_t<TProcessAPI>
                    >>(listener);
                    (*cpp_listener)(*cpp_api, target);
                } else {
                    Rcpp::Function r_listener = listener;
                    auto r_target = std::vector<size_t>(target.size());
                    auto i = 0;
                    for (auto t : timeline.at(current_timestep)) {
                        r_target[i] = t + 1;
                        ++i;
                    }
                    r_listener(r_api, r_target);
                }
            }
        }
    }
}

template<class TProcessAPI>
template<class TIndex>
inline void Scheduler<TProcessAPI>::clear_schedule(
    const std::string& event,
    const TIndex& to_remove) {
    auto& timeline = schedule_map.at(event);
    auto it = timeline.begin();
    while(it != timeline.end()) {
        for (auto r : to_remove) {
            (*it).second.erase(r);
        }
        if ((*it).second.size() == 0) {
            it = timeline.erase(it);
        } else {
            ++it;
        }
    }
}

template<class TProcessAPI>
inline individual_index_t Scheduler<TProcessAPI>::get_scheduled(
    const std::string& event) const {
    const auto& timeline = schedule_map.at(event);
    auto scheduled = individual_index_t(size_map.at(event));
    for (auto& index : timeline) {
        scheduled.insert(index.second.cbegin(), index.second.cend());
    }
    return scheduled;
}

template<class TProcessAPI>
template<class TIndex>
inline void Scheduler<TProcessAPI>::schedule(
    const std::string& event,
    const TIndex& target,
    double delay) {
    auto d = static_cast<size_t>(round(delay));

    if (d < 1) {
        Rcpp::stop("delay must be >= 1");
    }

    if (schedule_map.find(event) == schedule_map.end()) {
        Rcpp::stop("Unknown event");
    }

    auto target_timestep = current_timestep + d;
    auto& timeline = schedule_map.at(event);
    if (timeline.find(target_timestep) == timeline.end()) {
        timeline.insert({target_timestep, individual_index_t(size_map.at(event))});
    }
    timeline.at(target_timestep).insert(target.cbegin(), target.cend());
}

#endif /* INST_INCLUDE_SCHEDULER_H_ */
