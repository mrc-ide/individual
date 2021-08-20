/*
 *  Event.h
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_EVENT_H_
#define INST_INCLUDE_EVENT_H_

#include "common_types.h"
#include <Rcpp.h>
#include <set>
#include <map>
#include <functional>

using listener_t = std::function<void (size_t)>;
using targeted_listener_t = std::function<void (size_t, const individual_index_t&)>;


//' @title round a double, will error if input is negative or not finite
inline size_t round_double(double x) {
    if (x < 0.0 || !std::isfinite(x)) {
        Rcpp::stop("delay must be >= 0");
    } else {
        return static_cast<size_t>(std::round(x));
    }
}

//' @title round a vector of doubles
inline std::vector<size_t> round_delay(const std::vector<double>& delay) {
    auto rounded = std::vector<size_t>(delay.size());
    for (auto i = 0u; i < delay.size(); ++i) {
        rounded[i] = round_double(delay[i]);
    }
    return rounded;
}

//' @title abstract base class for events
struct EventBase {
    size_t t = 1;

    virtual void tick();
    
    virtual bool should_trigger() = 0;
    virtual ~EventBase() = default;
};

//' @title increase time step by one
inline void EventBase::tick() {
    ++t;
}


//' @title a general event in the simulation
//' @description This class provides functionality for general events which are 
//' applied to all individuals in the simulation. It inherits from EventBase.
//' It contains the following data members:
//'     * t: current simulation time step
//'     * simple_schedule: a set of times the event will fire
struct Event : public EventBase {

    std::set<size_t> simple_schedule;
    
    virtual ~Event() = default;

    virtual void process(Rcpp::XPtr<listener_t> listener);
    virtual bool should_trigger() override;
    virtual void tick() override;

    virtual void schedule(std::vector<double> delays);
    virtual void clear_schedule();
    
};

//' @title process an event by calling a listener
inline void Event::process(Rcpp::XPtr<listener_t> listener) {
    (*listener)(t);
}

//' @title should first event fire on this timestep?
inline bool Event::should_trigger() {
    return *simple_schedule.begin() == t;
}

//' @title delete current time step from simple_schedule and increase time step
inline void Event::tick() {
    simple_schedule.erase(t);
    EventBase::tick();
}

//' @title schedule a vector of events
inline void Event::schedule(std::vector<double> delays) {
    for (auto delay : round_delay(delays)) {
        simple_schedule.insert(t + delay);
    }
}

//' @title clear all scheduled events
inline void Event::clear_schedule() {
    simple_schedule.clear();
}


//' @title a targeted event in the simulation
//' @description This class provides functionality for targeted events which are 
//' applied to a subset of individuals in the simulation. It inherits from EventBase.
//' It contains the following data members:
//'     * t: current simulation time step
//'     * targeted_schedule: a map of times and bitsets of scheduled individuals
//'     * size: size of population
struct TargetedEvent : public EventBase {

    std::map<size_t, individual_index_t> targeted_schedule;
    size_t size = 0;

    TargetedEvent(size_t size);
    virtual ~TargetedEvent() = default;

    virtual bool should_trigger() override;
    virtual void process(Rcpp::XPtr<targeted_listener_t> listener);

    virtual individual_index_t& current_target();
    virtual void tick() override;

    virtual void schedule(
        const individual_index_t& target_bitset,
        const std::vector<double>& delay
    );
    virtual void schedule(
        const std::vector<size_t>& target_vector,
        const std::vector<double>& delay
    );
    virtual void schedule(
        const individual_index_t& target,
        double delay
    );
    virtual void schedule(
        const individual_index_t& target,
        size_t delay
    );

    virtual void clear_schedule(const individual_index_t& target);
    virtual individual_index_t get_scheduled() const;

};

inline TargetedEvent::TargetedEvent(size_t size) : size(size) {};

//' @title should first event fire on this timestep?
inline bool TargetedEvent::should_trigger() {
    if (targeted_schedule.begin() == targeted_schedule.end()) {
        return false;
    }
    return targeted_schedule.begin()->first == t;
}

//' @title process an event by calling a listener
inline void TargetedEvent::process(Rcpp::XPtr<targeted_listener_t> listener) {
    (*listener)(t, current_target());
}

//' @title get bitset of individuals scheduled for the next event
inline individual_index_t& TargetedEvent::current_target() {
    return targeted_schedule.begin()->second;
}

//' @title delete current time step from simple_schedule and increase time step
inline void TargetedEvent::tick() {
    targeted_schedule.erase(t);
    EventBase::tick();
}

//' @title schedule events
//' @description Schedule each individual in `target_bitset` to fire an event
//' at a corresponding `delay` timestep in the future.
//' Delays may be continuous but our timeline is discrete, 
//' so delays are rounded to the nearest timestep
inline void TargetedEvent::schedule(
    const individual_index_t& target_bitset,
    const std::vector<double>& delay
) {
    
    //round the delays to find a discrete timestep to trigger each event
    auto rounded = round_delay(delay);
    
    //get unique timesteps
    auto delay_values = std::unordered_set<size_t>(
        rounded.begin(),
        rounded.end()
    );
    
    // iterate through unique delay vals;
    // for each delay go through target_bitset and delay and add to target
    // for that delay if the delay matches the unique value
    for (auto v : delay_values) {
        auto target = individual_index_t(size);
        auto bitset_it = target_bitset.cbegin();
        for (auto i = 0u; i < rounded.size(); ++i) {
            if (rounded[i] == v) {
                target.insert(*bitset_it);
            }
            ++bitset_it;
        }
        schedule(target, v);
    }
}

//' @title schedule events
//' @description Schedule each individual in `target_vector` to fire an event
//' at a corresponding `delay` timestep in the future.
//' Delays may be continuous but our timeline is discrete, 
//' so delays are rounded to the nearest timestep
inline void TargetedEvent::schedule(
    const std::vector<size_t>& target_vector,
    const std::vector<double>& delay
) {
    
    //round the delays to find a discrete timestep to trigger each event
    auto rounded = round_delay(delay);
    
    //get unique timesteps
    auto delay_values = std::unordered_set<size_t>(
        rounded.begin(),
        rounded.end()
    );
    
    for (auto v : delay_values) {
        auto target = individual_index_t(size);
        for (auto i = 0u; i < rounded.size(); ++i) {
            if (rounded[i] == v) {
                target.insert_safe(target_vector[i]);
            }
        }
        schedule(target, v);
    }
}

//' @title schedule events
//' @description Schedule every individual in bitset `target` to fire an event
//' at `delay` timesteps in the future.
inline void TargetedEvent::schedule(
    const individual_index_t& target,
    double delay
) {
    schedule(target, round_double(delay));
}

//' @title schedule events
//' @description Schedule every individual in bitset `target` to fire an event
//' at `delay` timesteps in the future.
inline void TargetedEvent::schedule(
    const individual_index_t& target,
    size_t delay
) {
    
    auto target_timestep = t + delay;
    if (targeted_schedule.find(target_timestep) == targeted_schedule.end()) {
        targeted_schedule.insert(
            {target_timestep, individual_index_t(size)}
        );
    }
    targeted_schedule.at(target_timestep) |= target;
}

//' @title clear scheduled events for `target` individuals
inline void TargetedEvent::clear_schedule(const individual_index_t& target) {
    auto not_target = !target;
    for (auto& entry : targeted_schedule) {
        entry.second &= not_target;
    }
}

//' @title get all individuals scheduled for events
inline individual_index_t TargetedEvent::get_scheduled() const {
    auto scheduled = individual_index_t(size);
    for (auto& entry : targeted_schedule) {
        scheduled |= entry.second;
    }
    return scheduled;
}



#endif /* INST_INCLUDE_EVENT_H_ */
