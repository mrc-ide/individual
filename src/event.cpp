/*
 * scheduler.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#include "../inst/include/Event.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<EventBase> create_event() {
    return Rcpp::XPtr<EventBase>(new Event(), true);
}

//[[Rcpp::export]]
Rcpp::XPtr<EventBase> create_targeted_event(size_t size) {
    return Rcpp::XPtr<EventBase>(new TargetedEvent(size), true);
}

//[[Rcpp::export]]
void event_tick(const Rcpp::XPtr<EventBase> event) {
    event->tick();
}

//[[Rcpp::export]]
void event_schedule(const Rcpp::XPtr<Event> event, std::vector<double> delays) {
    event->schedule(delays);
}

//[[Rcpp::export]]
void event_clear_schedule(const Rcpp::XPtr<Event> event) {
    event->clear_schedule();
}

//[[Rcpp::export]]
void targeted_event_clear_schedule_vector(
    const Rcpp::XPtr<TargetedEvent> event,
    std::vector<size_t> target
    ) {
    decrement(target);
    auto bitmap = individual_index_t(event->size);
    bitmap.insert(target.cbegin(), target.cend());
    event->clear_schedule(bitmap);
}

//[[Rcpp::export]]
void targeted_event_clear_schedule(
    const Rcpp::XPtr<TargetedEvent> event,
    const Rcpp::XPtr<individual_index_t> target
    ) {
    event->clear_schedule(*target);
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> event_get_scheduled(
    const Rcpp::XPtr<TargetedEvent> event
    ) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(event->get_scheduled()),
        true
    );
}

//[[Rcpp::export]]
void targeted_event_schedule(
    const Rcpp::XPtr<TargetedEvent> event,
    const Rcpp::XPtr<individual_index_t> target,
    double delay) {
    event->schedule(*target, delay);
}

//[[Rcpp::export]]
void targeted_event_schedule_vector(
    const Rcpp::XPtr<TargetedEvent> event,
    std::vector<size_t> target,
    double delay) {
    decrement(target);
    auto bitmap = individual_index_t(event->size);
    bitmap.insert(target.begin(), target.end());
    event->schedule(bitmap, delay);
}

//[[Rcpp::export]]
void targeted_event_schedule_multi_delay(
    const Rcpp::XPtr<TargetedEvent> event,
    std::vector<size_t> target,
    const std::vector<double> delay) {
    decrement(target);
    event->schedule(target, delay);
}

//[[Rcpp::export]]
size_t event_get_timestep(const Rcpp::XPtr<EventBase> event) {
    return event->t;
}

//[[Rcpp::export]]
bool event_should_trigger(const Rcpp::XPtr<EventBase> event) {
    return event->should_trigger();
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> event_get_target(const Rcpp::XPtr<TargetedEvent> event) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(event->current_target()),
        true
    );
}
