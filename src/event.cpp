/*
 * scheduler.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#include "../inst/include/Event.h"

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
void event_process(const Rcpp::XPtr<EventBase> event) {
    event->process();
}
