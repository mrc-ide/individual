/*
 * resizeable_integer.cpp
 *
 *  Created on: 08 Dec 2021
 *      Author: gc1610
 */


#include "../inst/include/ResizeableIntegerVariable.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<ResizeableIntegerVariable> create_resizeable_integer_variable(
    const std::vector<int>& values
    ) {
    return Rcpp::XPtr<ResizeableIntegerVariable>(
        new ResizeableIntegerVariable(values),
        true
    );
}

//[[Rcpp::export]]
std::vector<int> resizeable_integer_variable_get_values(
    Rcpp::XPtr<ResizeableIntegerVariable> variable
    ) {
    const auto& values = variable->get_values();
    return std::vector<int>(std::cbegin(values), std::cend(values));
}

//[[Rcpp::export]]
std::vector<int> resizeable_integer_variable_get_values_at_index(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    Rcpp::XPtr<individual_index_t> index
    ) {
    return variable->get_values(*index);
}

//[[Rcpp::export]]
std::vector<int> resizeable_integer_variable_get_values_at_index_vector(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    std::vector<size_t> index
    ) {
    decrement(index);
    return variable->get_values(index);
}

// [[Rcpp::export]]
Rcpp::XPtr<individual_index_t> resizeable_integer_variable_get_index_of_range(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    const double a,
    const double b
) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(variable->get_index_of_range(a, b)),
        true
    );
}

// [[Rcpp::export]]
size_t resizeable_integer_variable_get_size_of_range(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    const double a,
    const double b
) {
    return variable->get_size_of_range(a, b);
}

//[[Rcpp::export]]
void resizeable_integer_variable_queue_fill(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    const std::vector<int> value
) {
    variable->queue_update(value, std::vector<size_t>());
}

//[[Rcpp::export]]
void resizeable_integer_variable_queue_update(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    const std::vector<int> value,
    std::vector<size_t> index
) {
    decrement(index);
    variable->queue_update(value, index);
}

//[[Rcpp::export]]
void resizeable_integer_variable_queue_update_bitset(
        Rcpp::XPtr<ResizeableIntegerVariable> variable,
        const std::vector<int> value,
        Rcpp::XPtr<individual_index_t> index
) {
    if (index->max_size() != variable->size()) {
        Rcpp::stop("incompatible size bitset used to queue update for IntegerVariable");
    }
    auto index_vec = bitset_to_vector_internal(*index, false);
    variable->queue_update(value, index_vec);
}

//[[Rcpp::export]]
void resizeable_integer_variable_update(Rcpp::XPtr<ResizeableIntegerVariable> variable) {
    variable->update();
}

//[[Rcpp::export]]
void resizeable_integer_variable_queue_extend(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    const std::vector<int>& values
) {
    variable->queue_extend(values);
}

//[[Rcpp::export]]
void resizeable_integer_variable_queue_shrink_bitset(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    Rcpp::XPtr<individual_index_t> index
) {
    variable->queue_shrink(*index);
}

//[[Rcpp::export]]
void resizeable_integer_variable_queue_shrink(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    std::vector<size_t> index
) {
    decrement(index);
    variable->queue_shrink(index);
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> resizeable_integer_variable_get_index_of_set_vector(
    Rcpp::XPtr<ResizeableIntegerVariable> variable,
    std::vector<int> values_set
) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(variable->get_index_of_set(values_set)),
        true
    );
}

//[[Rcpp::export]]
size_t resizeable_integer_variable_size(
    Rcpp::XPtr<ResizeableIntegerVariable> variable
) {
    return variable->size();
}
