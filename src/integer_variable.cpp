/*
 * IntegerVariable.cpp
 *
 *  Created on: 16 Feb 2021
 *      Author: slwu89
 */


#include "../inst/include/IntegerVariable.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<IntegerVariable> create_integer_variable(
    const std::vector<int>& values
    ) {
    return Rcpp::XPtr<IntegerVariable>(
        new IntegerVariable(values),
        true
    );
}

//[[Rcpp::export]]
std::vector<int> integer_variable_get_values(
    Rcpp::XPtr<IntegerVariable> variable
    ) {
    return variable->get_values();
}

//[[Rcpp::export]]
std::vector<int> integer_variable_get_values_at_index(
    Rcpp::XPtr<IntegerVariable> variable,
    Rcpp::XPtr<individual_index_t> index
    ) {
    return variable->get_values(*index);
}

//[[Rcpp::export]]
std::vector<int> integer_variable_get_values_at_index_vector(
        Rcpp::XPtr<IntegerVariable> variable,
        std::vector<size_t> index
) {
    decrement(index);
    return variable->get_values(index);
}

// [[Rcpp::export]]
Rcpp::XPtr<individual_index_t> integer_variable_get_index_of_set_vector(
    Rcpp::XPtr<IntegerVariable> variable,
    std::vector<int> values_set
) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(variable->get_index_of_set(values_set)),
        true
    );
}

// [[Rcpp::export]]
Rcpp::XPtr<individual_index_t> integer_variable_get_index_of_set_scalar(
        Rcpp::XPtr<IntegerVariable> variable,
        const int values_set
) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(variable->get_index_of_set(values_set)),
        true
    );
}

// [[Rcpp::export]]
Rcpp::XPtr<individual_index_t> integer_variable_get_index_of_range(
    Rcpp::XPtr<IntegerVariable> variable,
    const int a,
    const int b
) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(variable->get_index_of_range(a, b)),
        true
    );
}

// [[Rcpp::export]]
size_t integer_variable_get_size_of_set_vector(
    Rcpp::XPtr<IntegerVariable> variable,
    const std::vector<int> values_set
) {
    return variable->get_size_of_set_vector(values_set);
}

// [[Rcpp::export]]
size_t integer_variable_get_size_of_set_scalar(
        Rcpp::XPtr<IntegerVariable> variable,
        const int value
) {
    return variable->get_size_of_set_scalar(value);
}

// [[Rcpp::export]]
size_t integer_variable_get_size_of_range(
    Rcpp::XPtr<IntegerVariable> variable,
    const int a,
    const int b
) {
    return variable->get_size_of_range(a, b);
}


//[[Rcpp::export]]
void integer_variable_queue_fill(
    Rcpp::XPtr<IntegerVariable> variable,
    const std::vector<int> value
) {
    variable->queue_update(value, std::vector<size_t>());
}

//[[Rcpp::export]]
void integer_variable_queue_update(
    Rcpp::XPtr<IntegerVariable> variable,
    const std::vector<int> value,
    std::vector<size_t> index
) {
    decrement(index);
    variable->queue_update(value, index);
}

//[[Rcpp::export]]
void integer_variable_queue_update_bitset(
        Rcpp::XPtr<IntegerVariable> variable,
        const std::vector<int> value,
        Rcpp::XPtr<individual_index_t> index
) {
    if (index->max_size() != variable->size) {
        Rcpp::stop("incompatible size bitset used to queue update for IntegerVariable");
    }
    auto index_vec = bitset_to_vector_internal(*index, false);
    variable->queue_update(value, index_vec);
}

//[[Rcpp::export]]
void integer_variable_update(Rcpp::XPtr<IntegerVariable> variable) {
    variable->update();
}
