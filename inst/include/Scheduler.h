/*
 * Scheduler.h
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_SCHEDULER_H_
#define INST_INCLUDE_SCHEDULER_H_

#include "common_types.h"

using event_t = std::pair<std::string, std::vector<SEXP>>;
using timeline_t = std::unordered_map<size_t, individual_index_t>;

template<class TProcessAPI>
using listener_template_t = std::function<void (TProcessAPI&, individual_index_t&)>;

template<class TProcessAPI>
class Scheduler {
    std::vector<event_t> events;
    size_t current_timestep;
    named_array_t<timeline_t> schedule_map;
public:
    Scheduler(const std::vector<event_t>&);
    size_t get_timestep() const;
    void tick();
    void process_events(Rcpp::XPtr<TProcessAPI>, Rcpp::Environment api);
    void clear_schedule(const std::string&, const individual_index_t&);
    void clear_schedule(const std::string&, const std::vector<size_t>&);
    void get_scheduled(const std::string&, individual_index_t&) const;
    void schedule(const std::string&, const individual_index_t&, double);
};

template<class TProcessAPI>
inline Scheduler<TProcessAPI>::Scheduler(const std::vector<event_t>& events)
    : events(events), current_timestep(1u) {
    for (const auto& event : events) {
        schedule_map[event.first] = timeline_t();
    }
}

template<class TProcessAPI>
inline size_t Scheduler<TProcessAPI>::get_timestep() const { return current_timestep; }

template<class TProcessAPI>
inline void Scheduler<TProcessAPI>::tick() {
    for (const auto& event : events) {
        schedule_map.at(event.first).erase(current_timestep);
    }
    ++current_timestep;
}

template<class TProcessAPI>
inline void Scheduler<TProcessAPI>::process_events(
    Rcpp::XPtr<TProcessAPI> cpp_api,
    Rcpp::Environment r_api) {
    for (const auto& event : events) {
        auto& timeline = schedule_map.at(event.first);
        if (timeline.find(current_timestep) != timeline.end()) {
            for (const auto& listener : event.second) {
                if (TYPEOF(listener) == EXTPTRSXP) {
                    auto cpp_listener = Rcpp::as<Rcpp::XPtr<
                        listener_template_t<TProcessAPI>
                    >>(listener);
                    (*cpp_listener)(*cpp_api, timeline.at(current_timestep));
                } else {
                    Rcpp::Function r_listener = listener;
                    const auto& target = timeline.at(current_timestep);
                    r_listener(
                        r_api,
                        std::vector<size_t>(std::cbegin(target), std::cend(target))
                    );
                }
            }
        }
    }
}

template<class TProcessAPI>
inline void Scheduler<TProcessAPI>::clear_schedule(
    const std::string& event,
    const individual_index_t& to_remove) {
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
inline void Scheduler<TProcessAPI>::clear_schedule(
    const std::string& event,
    const std::vector<size_t>& to_remove) {
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
inline void Scheduler<TProcessAPI>::get_scheduled(
    const std::string& event,
    individual_index_t& scheduled) const {
    const auto& timeline = schedule_map.at(event);
    for (auto& index : timeline) {
        scheduled.insert(std::cbegin(index.second), std::cend(index.second));
    }
}

template<class TProcessAPI>
inline void Scheduler<TProcessAPI>::schedule(
    const std::string& event,
    const individual_index_t& target,
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
        timeline[target_timestep] = individual_index_t();
    }
    timeline.at(target_timestep).insert(std::cbegin(target), std::cend(target));
}

#endif /* INST_INCLUDE_SCHEDULER_H_ */
