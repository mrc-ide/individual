/*
 * prefab.cpp
 *
 *  Created on: 24 Feb 2021
 *      Author: slwu89
 */

#include "../inst/include/DoubleVariable.h"
#include "../inst/include/CategoricalVariable.h"
#include "../inst/include/IntegerVariable.h"
#include "utils.h"


//' @title Multinomial process
//' @description Simulates a two-stage process where all individuals
//' in a given 'source_state' sample whether to leave or not with probability
//' 'rate'; those who leave go to one of the 'destination_states' with
//' probabilities contained in the vector 'destination_probabilities'.
//' @param variable a \code{\link{CategoricalVariable}} object
//' @param source_state a string representing the source state
//' @param destination_states a vector of strings representing the destination states
//' @param rate probability of individuals in source state to leave
//' @param destination_probabilities probability vector of destination states
//' @export
// [[Rcpp::export]]
Rcpp::XPtr<process_t> fixed_probability_multinomial_process(
    const Rcpp::Environment variable,
    const std::string source_state,
    const std::vector<std::string> destination_states,
    const double rate,
    const std::vector<double> destination_probabilities 
){
    // array of cumulative probabilities
    std::vector<double> cdf(destination_probabilities);
    std::partial_sum(destination_probabilities.begin(),destination_probabilities.end(),cdf.begin(),std::plus<double>()); 

    // the internal CategoricalVariable object
    Rcpp::XPtr<CategoricalVariable> catvar = variable[".variable"];

    // make pointer to lambda function and return XPtr to R
    return Rcpp::XPtr<process_t>(
        new process_t([catvar,source_state,destination_states,rate,cdf](size_t t){      

            // sample leavers
            individual_index_t leaving_individuals(catvar->get_index_of(std::vector<std::string>{source_state}));
            bitset_sample_internal(leaving_individuals, rate);

            // empty bitsets to put them (their destinations)
            std::vector<individual_index_t> destination_individuals;
            size_t n = destination_states.size();
            for (size_t i=0; i<n; i++) {
                destination_individuals.emplace_back(leaving_individuals.max_size());
            }

            // random variate for each leaver to see where they go
            const auto random = Rcpp::runif(leaving_individuals.size());
            auto random_index = 0;
            for (auto it = std::begin(leaving_individuals); it != std::end(leaving_individuals); ++it) {
                auto dest_it = std::upper_bound(cdf.begin(), cdf.end(), random[random_index]);
                int dest = std::distance(cdf.begin(), dest_it);
                destination_individuals[dest].insert(*it);
                ++random_index;
            }

            // queue state updates
            for (size_t i=0; i<n; i++) {
                catvar->queue_update(destination_states[i], destination_individuals[i]);
            }

        }),
        true
    ); 
};


//' @title Overdispersed multinomial process
//' @description Simulates a two-stage process where all individuals
//' in a given 'source_state' sample whether to leave or not with a
//' individual probability specified by the \code{\link{DoubleVariable}}
//' object 'rate_variable'; those who leave go to one of the 'destination_states' with
//' probabilities contained in the vector 'destination_probabilities'.
//' @param variable a \code{\link{CategoricalVariable}} object
//' @param source_state a string representing the source state
//' @param destination_states a vector of strings representing the destination states
//' @param rate_variable \code{\link{DoubleVariable}} giving individual probability of each individual in source state to leave
//' @param destination_probabilities probability vector of destination states
//' @export
// [[Rcpp::export]]
Rcpp::XPtr<process_t> multi_probability_multinomial_process(
    const Rcpp::Environment variable,
    const std::string source_state,
    const std::vector<std::string> destination_states,
    const Rcpp::Environment rate_variable,
    const std::vector<double> destination_probabilities 
){
    // array of cumulative probabilities
    std::vector<double> cdf(destination_probabilities);
    std::partial_sum(destination_probabilities.begin(),destination_probabilities.end(),cdf.begin(),std::plus<double>()); 

    // the internal CategoricalVariable object
    Rcpp::XPtr<CategoricalVariable> catvar = variable[".variable"];

    // the internal DoubleVariable object
    Rcpp::XPtr<DoubleVariable> ratevar = rate_variable[".variable"];

    // make pointer to lambda function and return XPtr to R
    return Rcpp::XPtr<process_t>(
        new process_t([catvar,source_state,destination_states,ratevar,cdf](size_t t){      

            // sample leavers with their unique prob
            individual_index_t leaving_individuals(catvar->get_index_of(std::vector<std::string>{source_state}));
            std::vector<double> rate_vector = ratevar->get_values(leaving_individuals);
            bitset_sample_multi_internal(leaving_individuals, rate_vector.begin(), rate_vector.end());

            // empty bitsets to put them (their destinations)
            std::vector<individual_index_t> destination_individuals;
            size_t n = destination_states.size();
            for(size_t i=0; i<n; i++) {
                destination_individuals.emplace_back(leaving_individuals.max_size());
            }

            // random variate for each leaver to see where they go
            const auto random = Rcpp::runif(leaving_individuals.size());
            auto random_index = 0;
            for (auto it = std::begin(leaving_individuals); it != std::end(leaving_individuals); ++it) {
                auto dest_it = std::upper_bound(cdf.begin(), cdf.end(), random[random_index]);
                int dest = std::distance(cdf.begin(), dest_it);
                destination_individuals[dest].insert(*it);
                ++random_index;
            }

            // queue state updates
            for (size_t i=0; i<n; i++) {
                catvar->queue_update(destination_states[i], destination_individuals[i]);
            }

        }),
        true
    ); 
};


//' @title Overdispersed Bernoulli process
//' @description Simulates a Bernoulli process where all individuals
//' in a given source state 'from' sample whether or not 
//' to transition to destination state 'to' with a
//' individual probability specified by the \code{\link{DoubleVariable}}
//' object 'rate_variable'.
//' @param variable a \code{\link{CategoricalVariable}} object
//' @param from a string representing the source state
//' @param to a string representing the destination state
//' @param rate_variable \code{\link{DoubleVariable}} giving individual probability of each individual in source state to leave
//' @export
// [[Rcpp::export]]
Rcpp::XPtr<process_t> multi_probability_bernoulli_process(
    const Rcpp::Environment variable,
    const std::string from,
    const std::string to,
    const Rcpp::Environment rate_variable
){
    // the internal CategoricalVariable object
    Rcpp::XPtr<CategoricalVariable> catvar = variable[".variable"];

    // the internal DoubleVariable object
    Rcpp::XPtr<DoubleVariable> ratevar = rate_variable[".variable"];

    // make pointer to lambda function and return XPtr to R
    return Rcpp::XPtr<process_t>(
        new process_t([catvar,ratevar,from,to](size_t t){      

            // sample leavers with their unique prob
            individual_index_t leaving_individuals(catvar->get_index_of(std::vector<std::string>{from}));
            std::vector<double> rate_vector = ratevar->get_values(leaving_individuals);
            bitset_sample_multi_internal(leaving_individuals, rate_vector.begin(), rate_vector.end());

            catvar->queue_update(to, leaving_individuals);

        }),
        true
    ); 
};

