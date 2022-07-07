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
    auto bitmap = individual_index_t(event->size());
    bitmap.insert_safe(target.cbegin(), target.cend());
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
Rcpp::XPtr<individual_index_t> targeted_event_get_scheduled(
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
    if (target->max_size() != event->size()) {
        Rcpp::stop("incompatible size bitset used to schedule TargetedEvent");
    }
    event->schedule(*target, delay);
}

//[[Rcpp::export]]
void targeted_event_queue_shrink_bitset(
    const Rcpp::XPtr<TargetedEvent> event,
    const Rcpp::XPtr<individual_index_t> index
    ) {
    if (index->max_size() != event->size()) {
        Rcpp::stop("incompatible size bitset used to shrink TargetedEvent");
    }
    event->queue_shrink(*index);
}

//[[Rcpp::export]]
void targeted_event_queue_shrink(
    const Rcpp::XPtr<TargetedEvent> event,
    std::vector<size_t>& index
    ) {
    decrement(index);
    event->queue_shrink(index);
}

//[[Rcpp::export]]
void targeted_event_queue_extend(
    const Rcpp::XPtr<TargetedEvent> event,
    size_t n
    ) {
    event->queue_extend(n);
}

//[[Rcpp::export]]
void targeted_event_queue_extend_with_schedule(
    const Rcpp::XPtr<TargetedEvent> event,
    const std::vector<double>& delays
    ) {
    event->queue_extend(delays);
}

//[[Rcpp::export]]
void targeted_event_schedule_vector(
    const Rcpp::XPtr<TargetedEvent> event,
    std::vector<size_t> target,
    double delay) {
    decrement(target);
    auto bitmap = individual_index_t(event->size());
    bitmap.insert_safe(target.cbegin(), target.cend());
    event->schedule(bitmap, delay);
}

//[[Rcpp::export]]
void targeted_event_schedule_multi_delay(
        const Rcpp::XPtr<TargetedEvent> event,
        const Rcpp::XPtr<individual_index_t> target,
        const std::vector<double> delay) {
    if (target->max_size() != event->size()) {
        Rcpp::stop("incompatible size bitset used to schedule TargetedEvent");
    }
    if (target->size() != delay.size()) {
        Rcpp::stop("incompatible size bitset and delay vector used to schedule TargetedEvent");
    }
    event->schedule(*target, delay);
}


//[[Rcpp::export]]
void targeted_event_schedule_multi_delay_vector(
    const Rcpp::XPtr<TargetedEvent> event,
    std::vector<size_t> target,
    const std::vector<double> delay) {
    if (target.size() != delay.size()) {
        Rcpp::stop("incompatible size target and delay vector used to schedule TargetedEvent");
    }
    decrement(target);
    event->schedule(target, delay);
}

//[[Rcpp::export]]
size_t event_get_timestep(const Rcpp::XPtr<EventBase> event) {
    return event->get_time();
}

//[[Rcpp::export]]
bool event_should_trigger(const Rcpp::XPtr<EventBase> event) {
    return event->should_trigger();
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> targeted_event_get_target(const Rcpp::XPtr<TargetedEvent> event) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(event->current_target()),
        true
    );
}

// [[Rcpp::export]]
void targeted_event_resize(const Rcpp::XPtr<TargetedEvent> event) {
    event->resize();
}

// [[Rcpp::export]]
void process_listener(
    const Rcpp::XPtr<Event> event,
    const Rcpp::XPtr<listener_t> listener
) {
    size_t t = event->get_time();
    (*listener)(t);
}

// [[Rcpp::export]]
void process_targeted_listener(
    const Rcpp::XPtr<Event> event,
    const Rcpp::XPtr<targeted_listener_t> listener,
    const Rcpp::XPtr<individual_index_t> target
) {
    size_t t = event->get_time();
    (*listener)(t, *target.get());
}
