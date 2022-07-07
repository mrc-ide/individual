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


// [[Rcpp::export]]
Rcpp::XPtr<process_t> fixed_probability_multinomial_process_internal(
    Rcpp::XPtr<CategoricalVariable> variable,
    const std::string source_state,
    const std::vector<std::string> destination_states,
    const double rate,
    const std::vector<double> destination_probabilities 
){
    // array of cumulative probabilities
    std::vector<double> cdf(destination_probabilities);
    std::partial_sum(destination_probabilities.begin(),destination_probabilities.end(),cdf.begin(),std::plus<double>()); 

    // make pointer to lambda function and return XPtr to R
    return Rcpp::XPtr<process_t>(
        new process_t([variable,source_state,destination_states,rate,cdf](size_t t){

            // sample leavers
            individual_index_t leaving_individuals(variable->get_index_of(source_state));
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
                variable->queue_update(destination_states[i], destination_individuals[i]);
            }

        }),
        true
    ); 
}


// [[Rcpp::export]]
Rcpp::XPtr<process_t> multi_probability_multinomial_process_internal(
    Rcpp::XPtr<CategoricalVariable> variable,
    const std::string source_state,
    const std::vector<std::string> destination_states,
    const Rcpp::XPtr<DoubleVariable> rate_variable,
    const std::vector<double> destination_probabilities 
){
    // array of cumulative probabilities
    std::vector<double> cdf(destination_probabilities);
    std::partial_sum(destination_probabilities.begin(),destination_probabilities.end(),cdf.begin(),std::plus<double>()); 

    // make pointer to lambda function and return XPtr to R
    return Rcpp::XPtr<process_t>(
        new process_t([variable,source_state,destination_states,rate_variable,cdf](size_t t){

            // sample leavers with their unique prob
            individual_index_t leaving_individuals(variable->get_index_of(source_state));
            std::vector<double> rate_vector = rate_variable->get_values(leaving_individuals);
            bitset_sample_multi_internal(leaving_individuals, rate_vector.begin(), rate_vector.end());

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
                variable->queue_update(destination_states[i], destination_individuals[i]);
            }

        }),
        true
    ); 
}

// [[Rcpp::export]]
Rcpp::XPtr<process_t> multi_probability_bernoulli_process_internal(
    Rcpp::XPtr<CategoricalVariable> variable,
    const std::string from,
    const std::string to,
    const Rcpp::XPtr<DoubleVariable> rate_variable
){

    // make pointer to lambda function and return XPtr to R
    return Rcpp::XPtr<process_t>(
        new process_t([variable,rate_variable,from,to](size_t t){

            // sample leavers with their unique prob
            individual_index_t leaving_individuals(variable->get_index_of(from));
            std::vector<double> rate_vector = rate_variable->get_values(leaving_individuals);
            bitset_sample_multi_internal(leaving_individuals, rate_vector.begin(), rate_vector.end());

            variable->queue_update(to, leaving_individuals);

        }),
        true
    ); 
}

// [[Rcpp::export]]
Rcpp::XPtr<process_t> infection_age_process_internal(
    Rcpp::XPtr<CategoricalVariable> state,
    const std::string susceptible,
    const std::string exposed,
    const std::string infectious,
    const Rcpp::XPtr<IntegerVariable> age,
    const int age_bins,
    const double p,
    const double dt,
    const Rcpp::NumericMatrix mixing
) {
    // make pointer to lambda function and return XPtr to R
    return Rcpp::XPtr<process_t>(
        new process_t([state,age,age_bins,susceptible,exposed,infectious,p,dt,mixing](size_t t){

            // data structures we need to compute the age-structured force of infection
            // need NumericVector for sugar elementwise addition, division, and sum
            Rcpp::NumericVector N(age_bins); 
            Rcpp::NumericVector I(age_bins);
            std::vector<individual_index_t> S(age_bins, state->size());

            // get number of infectious and total individuals in each age bin
            // and indices of susceptible individuals in each age bin
            for (int a=1; a <= age_bins; ++a) {

                individual_index_t I_a = state->get_index_of(infectious);             
                individual_index_t N_a = age->get_index_of_set(a);
                I_a &= N_a;
                N[a-1] = N_a.size();
                I[a-1] = I_a.size();

                S[a-1] = state->get_index_of(susceptible);
                S[a-1] &= N_a;
            }

            // compute foi and sample infection for susceptible individuals in each age bin
            for (int a=1; a <= age_bins; ++a) {
                double foi = p * Rcpp::sum(mixing.row(a-1) * (I/N));
                bitset_sample_internal(S[a-1], Rf_pexp(foi * dt, 1., 1, 0));
                state->queue_update(exposed, S[a-1]);
            }

        }),
        true
    );
}
