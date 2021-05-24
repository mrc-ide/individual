/*
 * Scheduler.h -> Event.h
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_SCHEDULER_H_
#define INST_INCLUDE_SCHEDULER_H_

#include "common_types.h"
#include <Rcpp.h>
#include <set>
#include <map>
#include <functional>

using listener_t = std::function<void (size_t)>;
using targeted_listener_t = std::function<void (size_t, const individual_index_t&)>;

inline std::vector<size_t> round_delay(const std::vector<double>& delay) {
    auto rounded = std::vector<size_t>(delay.size());
    for (auto i = 0u; i < delay.size(); ++i) {
        if (delay[i] < 0) {
            Rcpp::stop("delay must be >= 0");
        }
        rounded[i] = static_cast<size_t>(round(delay[i]));
    }
    return rounded;
}

struct EventBase {
    size_t t = 1;

    virtual void tick() {
        ++t;
    }

    virtual bool should_trigger() = 0;
    virtual ~EventBase() {};
};

struct Event : public EventBase {

    std::set<size_t> simple_schedule;

    virtual void process(Rcpp::XPtr<listener_t> listener) {
        (*listener)(t);
    }

    virtual bool should_trigger() override {
        return *simple_schedule.begin() == t;
    }

    virtual void tick() override {
        simple_schedule.erase(t);
        EventBase::tick();
    }

    virtual void schedule(std::vector<double> delays) {
        for (auto delay : round_delay(delays)) {
            simple_schedule.insert(t + delay);
        }
    }

    virtual void clear_schedule() {
        simple_schedule.clear();
    }

    virtual ~Event() {};
};

struct TargetedEvent : public EventBase {

    std::map<size_t, individual_index_t> targeted_schedule;

    size_t size = 0;

    TargetedEvent(size_t size) : size(size) {};

    virtual bool should_trigger() override {
        if (targeted_schedule.begin() == targeted_schedule.end()) {
            return false;
        }
        return targeted_schedule.begin()->first == t;
    }

    virtual void process(Rcpp::XPtr<targeted_listener_t> listener) {
        (*listener)(t, current_target());
    }

    virtual individual_index_t& current_target() {
        return targeted_schedule.begin()->second;
    }

    virtual void tick() override {
        targeted_schedule.erase(t);
        EventBase::tick();
    }

    //Schedule each individual in `target_vector` to fire an event
    //at a corresponding `delay` timestep in the future.
    //Delays may be continuous but our timeline is discrete.
    //So delays are rounded to the nearest timestep
    virtual void schedule(
        const std::vector<size_t>& target_vector,
        const std::vector<double>& delay) {

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
                    target.insert(target_vector[i]);
                }
            }
            schedule(target, v);
        }
    }

    virtual void schedule(
        const individual_index_t& target,
        double delay) {
        schedule(target, static_cast<size_t>(round(delay)));
    }

    virtual void schedule(
        const individual_index_t& target,
        size_t delay) {

        auto target_timestep = t + delay;
        if (targeted_schedule.find(target_timestep) == targeted_schedule.end()) {
            targeted_schedule.insert(
                {target_timestep, individual_index_t(size)}
            );
        }
        targeted_schedule.at(target_timestep) |= target;
    }

    virtual void clear_schedule(const individual_index_t& target) {
        auto not_target = ~target;
        for (auto& entry : targeted_schedule) {
           entry.second &= not_target;
        }
    }

    virtual individual_index_t get_scheduled() const {
        auto scheduled = individual_index_t(size);
        for (auto& entry : targeted_schedule) {
           scheduled |= entry.second;
        }
        return scheduled;
    }

    virtual ~TargetedEvent() {};
};

#endif /* INST_INCLUDE_SCHEDULER_H_ */
