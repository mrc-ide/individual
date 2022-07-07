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
#include <unordered_set>
#include <queue>

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
class EventBase {
    size_t t = 1;
public:
    virtual void tick();
    virtual size_t get_time() const;
    
    virtual bool should_trigger() = 0;
    virtual ~EventBase() = default;
};

//' @title increase time step by one
inline void EventBase::tick() {
    ++t;
}

inline size_t EventBase::get_time() const {
    return t;
}


//' @title a general event in the simulation
//' @description This class provides functionality for general events which are 
//' applied to all individuals in the simulation. It inherits from EventBase.
//' It contains the following data members:
//'     * t: current simulation time step
//'     * simple_schedule: a set of times the event will fire
class Event : public EventBase {

    std::set<size_t> simple_schedule;

public:
    virtual ~Event() = default;

    virtual void process(Rcpp::XPtr<listener_t> listener);
    virtual bool should_trigger() override;
    virtual void tick() override;

    virtual void schedule(std::vector<double> delays);
    virtual void clear_schedule();
    
};

//' @title process an event by calling a listener
inline void Event::process(Rcpp::XPtr<listener_t> listener) {
    (*listener)(get_time());
}

//' @title should first event fire on this timestep?
inline bool Event::should_trigger() {
    return *simple_schedule.begin() == get_time();
}

//' @title delete current time step from simple_schedule and increase time step
inline void Event::tick() {
    simple_schedule.erase(get_time());
    EventBase::tick();
}

//' @title schedule a vector of events
inline void Event::schedule(std::vector<double> delays) {
    for (auto delay : round_delay(delays)) {
        simple_schedule.insert(get_time() + delay);
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
//'     * targeted_schedule: a map of times and bitsets of scheduled individuals
//'     * extensions: a queue of extension operations
//'     * shrink_index: an index of individuals to remove
//'     * size: size of population
class TargetedEvent : public EventBase {

    size_t _size = 0;
    std::map<size_t, individual_index_t> targeted_schedule;
    std::queue<std::function<void ()>> extensions;
    individual_index_t shrink_index;

public:
    TargetedEvent(size_t);
    virtual ~TargetedEvent() = default;

    virtual bool should_trigger() override;
    virtual void process(Rcpp::XPtr<targeted_listener_t> listener);

    virtual individual_index_t& current_target();
    virtual void tick() override;

    virtual void schedule(
        const individual_index_t&,
        const std::vector<double>&
    );
    virtual void schedule(
        const std::vector<size_t>&,
        const std::vector<double>&
    );
    virtual void schedule(const individual_index_t&, double);
    virtual void schedule(const individual_index_t&, size_t);
    virtual void queue_shrink(const individual_index_t&);
    virtual void queue_shrink(const std::vector<size_t>&);
    virtual void queue_extend(size_t);
    virtual void queue_extend(const std::vector<double>&);
    virtual size_t size() const;
    virtual void resize();

    virtual void clear_schedule(const individual_index_t&);
    virtual individual_index_t get_scheduled() const;

};

inline TargetedEvent::TargetedEvent(size_t size)
    : _size(size), shrink_index(individual_index_t(size)) {}

//' @title should first event fire on this timestep?
inline bool TargetedEvent::should_trigger() {
    if (targeted_schedule.begin() == targeted_schedule.end()) {
        return false;
    }
    return targeted_schedule.begin()->first == get_time();
}

//' @title process an event by calling a listener
inline void TargetedEvent::process(Rcpp::XPtr<targeted_listener_t> listener) {
    (*listener)(get_time(), current_target());
}

//' @title get bitset of individuals scheduled for the next event
inline individual_index_t& TargetedEvent::current_target() {
    return targeted_schedule.begin()->second;
}

//' @title delete current time step from simple_schedule and increase time step
inline void TargetedEvent::tick() {
    targeted_schedule.erase(get_time());
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
        auto target = individual_index_t(size());
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
        auto target = individual_index_t(size());
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
    
    auto target_timestep = get_time() + delay;
    if (targeted_schedule.find(target_timestep) == targeted_schedule.end()) {
        targeted_schedule.insert(
            {target_timestep, individual_index_t(size())}
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
    auto scheduled = individual_index_t(size());
    for (auto& entry : targeted_schedule) {
        scheduled |= entry.second;
    }
    return scheduled;
}

inline void TargetedEvent::queue_extend(size_t n) {
    extensions.push([&, n=n]() {
        for (auto& entry : targeted_schedule) {
            entry.second.extend(n);
        }
        _size += n;
    });
}

inline void TargetedEvent::queue_extend(const std::vector<double>& delays) {
    extensions.push([&, delays=delays]() {
        for (auto& entry : targeted_schedule) {
            entry.second.extend(delays.size());
        }
        auto target = std::vector<size_t>();
        target.reserve(delays.size());
        for (auto i = _size; i < _size + delays.size(); ++i) {
            target.push_back(i);
        }
        _size += delays.size();
        schedule(target, delays);
    });
}

inline void TargetedEvent::queue_shrink(const individual_index_t& index) {
    if (index.max_size() != size()) {
        Rcpp::stop("Invalid bitset size for variable shrink");
    }
    shrink_index |= index;
}

inline void TargetedEvent::queue_shrink(const std::vector<size_t>& index) {
    for (const auto& x : index) {
        if (x >= size()) {
            Rcpp::stop("Invalid vector index for variable shrink");
        }
    }
    shrink_index.insert(index.cbegin(), index.cend());
}

inline size_t TargetedEvent::size() const {
    return _size;
}

inline void TargetedEvent::resize() {
    auto size_changed = false;
    // perform shrinks
    if (shrink_index.size() > 0) {
        const auto index = std::vector<size_t>(
            shrink_index.begin(),
            shrink_index.end()
        );
        for (auto& entry : targeted_schedule) {
            entry.second.shrink(index);
        }
        _size -= index.size();
        size_changed = true;
    }

    while(extensions.size() > 0) {
        const auto& update = extensions.front();
        update();
        extensions.pop();
        size_changed = true;
    }

    if (size_changed) {
        shrink_index = individual_index_t(size());
    }
}

#endif /* INST_INCLUDE_EVENT_H_ */
